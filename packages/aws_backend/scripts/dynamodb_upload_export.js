#!/usr/bin/env node
const fs = require('fs');
const fsPromises = fs.promises;
const path = require('path');
const os = require('os');
const zlib = require('zlib');
const readline = require('readline');
const { spawnSync } = require('child_process');

const STORAGE_TYPES = ['auth', 'data'];
const DEFAULT_INPUT_ROOT = 'sltt-exports';
const DEFAULT_REGION = 'us-east-1';
const MAX_BATCH_SIZE = 25;

function parseArgs() {
  const args = {
    storageType: null,
    tableName: null,
    tableArn: null,
    awsProfile: process.env.AWS_PROFILE || null,
    inputRoot: process.env.INPUT_DIR || DEFAULT_INPUT_ROOT,
    exportId: null,
    region: process.env.AWS_REGION || DEFAULT_REGION,
    exportType: 'full',
    help: false,
  };

  for (let i = 2; i < process.argv.length; i += 1) {
    const arg = process.argv[i];
    if (arg === '--storage-type') {
      args.storageType = process.argv[++i];
    } else if (arg.startsWith('--storage-type=')) {
      args.storageType = arg.split('=')[1];
    } else if (arg === '--table-name') {
      args.tableName = process.argv[++i];
    } else if (arg.startsWith('--table-name=')) {
      args.tableName = arg.split('=')[1];
    } else if (arg === '--table-arn') {
      args.tableArn = process.argv[++i];
    } else if (arg.startsWith('--table-arn=')) {
      args.tableArn = arg.split('=')[1];
    } else if (arg === '--aws-profile') {
      args.awsProfile = process.argv[++i];
    } else if (arg.startsWith('--aws-profile=')) {
      args.awsProfile = arg.split('=')[1];
    } else if (arg === '--input-dir') {
      args.inputRoot = process.argv[++i];
    } else if (arg.startsWith('--input-dir=')) {
      args.inputRoot = arg.split('=')[1];
    } else if (arg === '--export-id') {
      args.exportId = process.argv[++i];
    } else if (arg.startsWith('--export-id=')) {
      args.exportId = arg.split('=')[1];
    } else if (arg === '--export-type') {
      args.exportType = process.argv[++i]?.toLowerCase();
    } else if (arg.startsWith('--export-type=')) {
      args.exportType = arg.split('=')[1]?.toLowerCase();
    } else if (arg === '--region') {
      args.region = process.argv[++i];
    } else if (arg.startsWith('--region=')) {
      args.region = arg.split('=')[1];
    } else if (arg === '--help' || arg === '-h') {
      args.help = true;
    } else {
      console.error(`Unknown argument: ${arg}`);
      args.help = true;
    }
  }

  return args;
}

function printUsage() {
  console.log('Usage: node scripts/dynamodb_upload_export.js --storage-type <auth|data> --table-name <tableName> [options]');
  console.log('Options:');
  console.log('  --storage-type=<auth|data>   Choose the export type to load');
  console.log('  --export-type=<full|incremental>  Choose the export kind for directory filtering');
  console.log('  --table-name=<name>          Target DynamoDB table name');
  console.log('  --table-arn=<arn>            Target DynamoDB table ARN (extracts name)');
  console.log('  --aws-profile=<profile>      AWS CLI profile to use');
  console.log('  --input-dir=<path>           Export root directory (default: sltt-exports)');
  console.log('  --export-id=<id>             Specific export directory name under input root');
  console.log('  --region=<region>            AWS region (default: us-east-1)');
  console.log('  --help, -h                   Show this help');
  console.log();
  console.log('Environment variables: AWS_PROFILE, AWS_REGION, INPUT_DIR');
}

function getTableName(args) {
  if (args.tableName) {
    return args.tableName;
  }
  if (args.tableArn) {
    return args.tableArn.split(':').pop();
  }
  return null;
}

async function findLatestStorageRoot(inputRoot, storageType, exportType) {
  const root = path.resolve(inputRoot);
  const entries = await fsPromises.readdir(root, { withFileTypes: true });
  const candidates = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (!entry.name.endsWith(`-${storageType}`)) continue;
    if (exportType === 'incremental' && !entry.name.includes(`-${exportType}`)) continue;
    if (exportType === 'full' && !entry.name.includes('-full')) continue;
    const candidatePath = path.join(root, entry.name);
    const stat = await fsPromises.stat(candidatePath);
    candidates.push({ path: candidatePath, mtimeMs: stat.mtimeMs });
  }

  if (candidates.length === 0) {
    const filter = exportType === 'incremental' ? ` and export type ${exportType}` : '';
    throw new Error(`No export directories found for storage-type=${storageType}${filter} under ${root}`);
  }

  candidates.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return candidates[0].path;
}

async function resolveStorageRootByExportId(inputRoot, exportId, storageType, exportType) {
  const root = path.resolve(inputRoot);
  if (path.isAbsolute(exportId)) {
    if (await exists(exportId)) {
      return exportId;
    }
    throw new Error(`Export directory not found: ${exportId}`);
  }

  const directPath = path.join(root, exportId);
  if (await exists(directPath)) {
    return directPath;
  }

  const entries = await fsPromises.readdir(root, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (entry.name === exportId) {
      return path.join(root, entry.name);
    }
  }

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (!entry.name.endsWith(`-${storageType}`)) continue;
    if (exportType === 'incremental' && !entry.name.includes(`-${exportType}`)) continue;
    if (exportType === 'full' && !entry.name.includes('-full')) continue;
    if (entry.name.includes(exportId)) {
      return path.join(root, entry.name);
    }
  }

  throw new Error(`No export directory found for export-id=${exportId} under ${root}`);
}

async function findLatestExportDataDir(storageRoot) {
  const awsdynamo = path.join(storageRoot, 'dynamodb-exports', 'diag', 'AWSDynamoDB');
  if (!(await exists(awsdynamo))) {
    throw new Error(`Expected export layout not found: ${awsdynamo}`);
  }

  const entries = await fsPromises.readdir(awsdynamo, { withFileTypes: true });
  const candidates = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const dataDir = path.join(awsdynamo, entry.name, 'data');
    if (await exists(dataDir)) {
      const stat = await fsPromises.stat(dataDir);
      candidates.push({ path: dataDir, mtimeMs: stat.mtimeMs });
    }
  }

  if (candidates.length === 0) {
    throw new Error(`No AWSDynamoDB export data directories found under ${awsdynamo}`);
  }

  candidates.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return candidates[0].path;
}

async function exists(pathToCheck) {
  try {
    await fsPromises.access(pathToCheck);
    return true;
  } catch {
    return false;
  }
}

async function collectJsonExportPaths(dataDir) {
  const results = [];
  const entries = await fsPromises.readdir(dataDir, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    const lower = entry.name.toLowerCase();
    if (lower.endsWith('.json') || lower.endsWith('.json.gz')) {
      results.push(path.join(dataDir, entry.name));
    }
  }
  return results.sort();
}

function createReadStreamForPath(filePath) {
  const input = fs.createReadStream(filePath);
  if (filePath.toLowerCase().endsWith('.gz')) {
    const gunzip = zlib.createGunzip();
    return input.pipe(gunzip);
  }
  return input;
}

async function iterateExportItems(dataFiles, onItem) {
  let total = 0;
  for (const filePath of dataFiles) {
    const stream = createReadStreamForPath(filePath);
    const rl = readline.createInterface({ input: stream, terminal: false });
    for await (const line of rl) {
      const trimmed = line.trim();
      if (!trimmed) continue;
      try {
        const payload = JSON.parse(trimmed);
        const item = payload.Item ?? payload.item ?? null;
        if (item && typeof item === 'object') {
          total += 1;
          await onItem(item);
        }
      } catch {
        continue;
      }
    }
  }
  return total;
}

function runAwsCli(args) {
  const proc = spawnSync('aws', args, {
    stdio: ['ignore', 'pipe', 'pipe'],
    encoding: 'utf8',
  });
  if (proc.error) {
    throw proc.error;
  }
  if (proc.status !== 0) {
    throw new Error(proc.stderr || `aws cli exited with code ${proc.status}`);
  }
  return proc.stdout.trim();
}

function createBatchWriteJson(tableName, items) {
  return {
    [tableName]: items.map((item) => ({ PutRequest: { Item: item } })),
  };
}

async function flushBatch(tableName, batch, profile, region, batchIndex) {
  if (batch.length === 0) {
    return;
  }
  const request = createBatchWriteJson(tableName, batch);
  const tempFile = path.join(os.tmpdir(), `dynamodb-upload-${Date.now()}-${batchIndex}.json`);
  await fsPromises.writeFile(tempFile, JSON.stringify(request), 'utf8');

  try {
    console.log(`Uploading batch ${batchIndex} (${batch.length} items)...`);
    const args = ['dynamodb', 'batch-write-item', '--request-items', `file://${tempFile}`, '--region', region];
    if (profile) {
      args.push('--profile', profile);
    }
    const output = runAwsCli(args);
    let response = {};
    if (output) {
      try {
        response = JSON.parse(output);
      } catch (err) {
        throw new Error(`Failed to parse aws batch-write-item output: ${err.message}`);
      }
    }

    let unprocessed = response.UnprocessedItems || {};
    let retryCount = 0;
    while (unprocessed && Object.keys(unprocessed).length > 0) {
      retryCount += 1;
      if (retryCount > 5) {
        throw new Error(`Unprocessed items remain after retries: ${JSON.stringify(unprocessed)}`);
      }
      const retryItems = unprocessed[tableName] || [];
      console.log(`Retrying ${retryItems.length} unprocessed items (attempt ${retryCount})...`);
      await sleep(5000);
      const retryRequest = createBatchWriteJson(tableName, retryItems.map((item) => item.PutRequest.Item));
      await fsPromises.writeFile(tempFile, JSON.stringify(retryRequest), 'utf8');
      const retryOutput = runAwsCli(args);
      if (retryOutput) {
        try {
          response = JSON.parse(retryOutput);
        } catch (err) {
          throw new Error(`Failed to parse retry output: ${err.message}`);
        }
      }
      unprocessed = response.UnprocessedItems || {};
    }
  } finally {
    try {
      await fsPromises.unlink(tempFile);
    } catch {
      // ignore
    }
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const args = parseArgs();
  if (args.help) {
    printUsage();
    process.exit(0);
  }

  if (!args.storageType || !STORAGE_TYPES.includes(args.storageType)) {
    console.error('Missing or invalid --storage-type; expected auth or data');
    printUsage();
    process.exit(1);
  }

  if (!['full', 'incremental'].includes(args.exportType)) {
    console.error('Invalid --export-type; expected full or incremental');
    printUsage();
    process.exit(1);
  }

  const tableName = getTableName(args);
  if (!tableName) {
    console.error('Missing --table-name or --table-arn');
    printUsage();
    process.exit(1);
  }

  const awsProfile = args.awsProfile || null;
  const inputRoot = path.resolve(args.inputRoot);

  console.log(`Using input root: ${inputRoot}`);
  if (args.exportId) {
    console.log(`Using export id: ${args.exportId}`);
  }
  console.log(`Storage type: ${args.storageType}`);
  console.log(`DynamoDB table: ${tableName}`);
  if (awsProfile) {
    console.log(`AWS profile: ${awsProfile}`);
  }
  console.log(`AWS region: ${args.region}`);

  const storageRoot = args.exportId
    ? await resolveStorageRootByExportId(inputRoot, args.exportId, args.storageType, args.exportType)
    : await findLatestStorageRoot(inputRoot, args.storageType, args.exportType);
  console.log(`Resolved export root: ${storageRoot}`);

  const dataDir = await findLatestExportDataDir(storageRoot);
  console.log(`Resolved data directory: ${dataDir}`);

  const dataFiles = await collectJsonExportPaths(dataDir);
  if (dataFiles.length === 0) {
    throw new Error(`No .json or .json.gz files found under ${dataDir}`);
  }
  console.log(`Found ${dataFiles.length} export data file(s)`);

  let batch = [];
  let totalItems = 0;
  let batchIndex = 1;

  async function onItem(item) {
    batch.push(item);
    totalItems += 1;
    if (batch.length >= MAX_BATCH_SIZE) {
      await flushBatch(tableName, batch, awsProfile, args.region, batchIndex);
      batch = [];
      batchIndex += 1;
    }
  }

  const itemCount = await iterateExportItems(dataFiles, onItem);
  if (batch.length > 0) {
    await flushBatch(tableName, batch, awsProfile, args.region, batchIndex);
  }

  console.log(`Uploaded ${itemCount} items to ${tableName} using ${batchIndex} batch(es).`);
}

main().catch((error) => {
  console.error(`Error: ${error.message}`);
  process.exit(1);
});
