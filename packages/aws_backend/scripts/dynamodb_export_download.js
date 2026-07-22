#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');
const { URL } = require('url');

const DEFAULT_BASE_URL =
  'https://t0e0o97xn5.execute-api.us-east-1.amazonaws.com/prd';
const STORAGE_TYPES = ['auth', 'data'];
const DEFAULT_WAIT_SECONDS = 2;

function parseArgs() {
  const args = {
    baseUrl: process.env.CLOUD_BASE_URL || DEFAULT_BASE_URL,
    token:
      process.env.AUTH_TOKEN ||
      process.env.ACCESS_TOKEN ||
      process.env.BEARER_TOKEN ||
      null,
    outputRoot: process.env.OUTPUT_DIR || 'sltt-exports',
    waitSeconds: DEFAULT_WAIT_SECONDS,
    exportType: 'full',
    exportId: null,
    incrementalFrom: null,
    incrementalTo: null,
  };

  for (let i = 2; i < process.argv.length; i += 1) {
    const arg = process.argv[i];
    if (arg === '--token' || arg === '-t') {
      args.token = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--token=')) {
      args.token = arg.split('=')[1];
    } else if (arg === '--base-url') {
      args.baseUrl = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--base-url=')) {
      args.baseUrl = arg.split('=')[1];
    } else if (arg === '--output-dir') {
      args.outputRoot = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--output-dir=')) {
      args.outputRoot = arg.split('=')[1];
    } else if (arg === '--wait-seconds') {
      args.waitSeconds = parseInt(process.argv[i + 1], 10) || DEFAULT_WAIT_SECONDS;
      i += 1;
    } else if (arg.startsWith('--wait-seconds=')) {
      args.waitSeconds = parseInt(arg.split('=')[1], 10) || DEFAULT_WAIT_SECONDS;
    } else if (arg === '--export-type') {
      args.exportType = process.argv[i + 1]?.toLowerCase();
      i += 1;
    } else if (arg.startsWith('--export-type=')) {
      args.exportType = arg.split('=')[1]?.toLowerCase();
    } else if (arg === '--export-id') {
      args.exportId = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--export-id=')) {
      args.exportId = arg.split('=')[1];
    } else if (arg === '--incremental-from') {
      args.incrementalFrom = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--incremental-from=')) {
      args.incrementalFrom = arg.split('=')[1];
    } else if (arg === '--incremental-to') {
      args.incrementalTo = process.argv[i + 1];
      i += 1;
    } else if (arg.startsWith('--incremental-to=')) {
      args.incrementalTo = arg.split('=')[1];
    } else if (arg === '--help' || arg === '-h') {
      printUsageAndExit(0);
    }
  }

  return args;
}

function printUsageAndExit(code) {
  console.log('Usage: node scripts/dynamodb_export_download.js [options]');
  console.log('Options:');
  console.log('  --base-url=<url>        REST API base URL');
  console.log('  --token=<token>         Bearer token for admin API calls');
  console.log('  --output-dir=<path>     Output directory root (default: sltt-exports)');
  console.log('  --wait-seconds=<secs>   Poll interval in seconds (default: 10)');
  console.log('  --export-type=<full|incremental>  Export type to request');
  console.log('  --export-id=<id>        Use an existing export directory to infer incremental start time');
  console.log('  --incremental-from=<ts> ExportFromTime for incremental export (ISO8601)');
  console.log('  --incremental-to=<ts>   ExportToTime for incremental export (ISO8601)');
  console.log('  --help, -h              Show this help text');
  console.log();
  console.log('Environment variables: CLOUD_BASE_URL, AUTH_TOKEN, ACCESS_TOKEN, BEARER_TOKEN');
  process.exit(code);
}

function jsonRequest(method, requestUrl, body, token) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(requestUrl);
    const lib = urlObj.protocol === 'https:' ? https : http;
    const bodyString = body ? JSON.stringify(body) : null;
    const headers = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
      ...
        (token
          ? {
              Authorization: `Bearer ${token}`,
            }
          : {}),
    };
    if (bodyString) {
      headers['Content-Length'] = Buffer.byteLength(bodyString);
    }

    const request = lib.request(
      urlObj,
      {
        method,
        headers,
      },
      (response) => {
        let responseBody = '';
        response.setEncoding('utf8');
        response.on('data', (chunk) => {
          responseBody += chunk;
        });
        response.on('end', () => {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            try {
              resolve(responseBody ? JSON.parse(responseBody) : {});
            } catch (error) {
              reject(new Error(`Invalid JSON response: ${error.message}`));
            }
          } else {
            const message = `HTTP ${response.statusCode} ${response.statusMessage}`;
            reject(new Error(`${message}: ${responseBody}`.trim()));
          }
        });
      },
    );

    request.on('error', reject);
    if (bodyString) {
      request.write(bodyString);
    }
    request.end();
  });
}

function downloadUrlToFile(downloadUrl, outputFilePath) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(downloadUrl);
    const lib = urlObj.protocol === 'https:' ? https : http;
    mkdirRecursive(path.dirname(outputFilePath));
    const fileStream = fs.createWriteStream(outputFilePath);
    const request = lib.get(urlObj, (response) => {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        response.pipe(fileStream);
        fileStream.on('finish', () => {
          fileStream.close(resolve);
        });
      } else {
        response.resume();
        reject(
          new Error(
            `Failed to download ${downloadUrl}: HTTP ${response.statusCode} ${response.statusMessage}`,
          ),
        );
      }
    });

    request.on('error', (error) => {
      fileStream.close(() => reject(error));
    });
  });
}

function mkdirRecursive(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function normalizeFolderName(value) {
  return value.replace(/[:\.]/g, '-').replace(/[^a-zA-Z0-9_\-]/g, '_');
}

function toEpochSeconds(value) {
  if (typeof value === 'number') {
    return value;
  }
  if (typeof value !== 'string') {
    return value;
  }
  return new Date(value).getTime() / 1000;
}

async function resolveExportDirByExportId(outputRoot, exportId) {
  const root = path.resolve(outputRoot);
  const entries = await fs.promises.readdir(root, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (entry.name === exportId) {
      return path.join(root, entry.name);
    }

    const metadataPath = path.join(root, entry.name, 'export-response.json');
    try {
      const raw = await fs.promises.readFile(metadataPath, 'utf8');
      const payload = JSON.parse(raw);
      const arn = payload?.ExportDescription?.ExportArn ?? payload?.ExportArn ?? null;
      if (typeof arn === 'string') {
        if (arn === exportId || arn.endsWith(exportId) || arn.includes(`/export/${exportId}`)) {
          return path.join(root, entry.name);
        }
      }
    } catch {
      continue;
    }
  }

  throw new Error(`No export directory found for export-id=${exportId} under ${outputRoot}`);
}

async function fetchExportData(baseUrl, storageType, token, exportType, incrementalFrom, incrementalTo) {
  const url = `${baseUrl.replace(/\/$/, '')}/api/admin/storage/${storageType}/export/create`;
  const body = {
    ExportFormat: 'DYNAMODB_JSON',
    ExportType: exportType,
  };
  if (exportType === 'incremental') {
    body.ExportType = 'INCREMENTAL_EXPORT';
    body.IncrementalExportSpecification = {};
    if (incrementalFrom) {
      body.IncrementalExportSpecification.ExportFromTime = toEpochSeconds(incrementalFrom);
    }
    if (incrementalTo) {
      body.IncrementalExportSpecification.ExportToTime = toEpochSeconds(incrementalTo);
    }
  } else {
    body.ExportType = 'FULL_EXPORT';
  }
  return await jsonRequest('POST', url, body, token);
}

async function fetchExportStatus(baseUrl, storageType, token) {
  const query = 'includeDetails=true&MaxResults=5';
  const url = `${baseUrl.replace(/\/$/, '')}/api/admin/storage/${storageType}/export/list?${query}`;
  return await jsonRequest('GET', url, null, token);
}

async function fetchListFiles(baseUrl, storageType, exportArn, token) {
  const query = `exportArn=${encodeURIComponent(exportArn)}`;
  const url = `${baseUrl.replace(/\/$/, '')}/api/admin/storage/${storageType}/export/list-files?${query}`;
  return await jsonRequest('GET', url, null, token);
}

function findExportSummary(response, exportArn) {
  const summaries = Array.isArray(response.ExportSummaries)
    ? response.ExportSummaries
    : [];
  return summaries.find((summary) => {
    if (!summary || typeof summary !== 'object') {
      return false;
    }
    if (summary.ExportArn === exportArn) {
      return true;
    }
    if (
      summary.ExportDescription &&
      summary.ExportDescription.ExportArn === exportArn
    ) {
      return true;
    }
    return false;
  });
}

function getExportArn(response) {
  if (response == null || typeof response !== 'object') {
    return null;
  }
  if (typeof response.ExportArn === 'string') {
    return response.ExportArn;
  }
  if (response.ExportDescription && typeof response.ExportDescription.ExportArn === 'string') {
    return response.ExportDescription.ExportArn;
  }
  return null;
}

function getStartTime(response) {
  if (response == null || typeof response !== 'object') {
    return null;
  }
  const desc = response.ExportDescription || response;
  const raw = desc?.StartTime ?? desc?.ExportTime;
  if (raw == null) {
    return null;
  }

  if (typeof raw === 'number') {
    return new Date(Math.round(raw * 1000)).toISOString();
  }
  if (typeof raw === 'string') {
    const numeric = Number(raw);
    if (!Number.isNaN(numeric)) {
      return new Date(Math.round(numeric * 1000)).toISOString();
    }
    return raw;
  }
  return null;
}

function sanitizeItemKey(key) {
  return key.replace(/^\/+/, '');
}

async function waitForExportCompletion(baseUrl, storageType, exportArn, token, waitSeconds) {
  process.stdout.write(`Waiting for ${storageType} export completion`);
  while (true) {
    try {
      const response = await fetchExportStatus(baseUrl, storageType, token);
      const summary = findExportSummary(response, exportArn);
      const status = summary && summary.ExportStatus;
      if (status === 'COMPLETED') {
        process.stdout.write('\n');
        return summary;
      }
      if (status === 'FAILED' || status === 'CANCELLED' || status === 'EXPIRED') {
        process.stdout.write('\n');
        throw new Error(
          `Export ${exportArn} ended with terminal status: ${status}`,
        );
      }
    } catch (error) {
      process.stdout.write(`\nError while polling export status: ${error.message}\n`);
      throw error;
    }

    process.stdout.write('.');
    await sleep(waitSeconds * 1000);
  }
}

async function run() {
  const args = parseArgs();
  const {
    baseUrl,
    token,
    outputRoot,
    waitSeconds,
    exportType,
  } = args;
  let incrementalFrom = args.incrementalFrom;
  let incrementalTo = args.incrementalTo;

  if (!token) {
    console.error(
      'Missing bearer token. Set AUTH_TOKEN, ACCESS_TOKEN, BEARER_TOKEN, or pass --token.',
    );
    printUsageAndExit(1);
  }

  if (!['full', 'incremental'].includes(exportType)) {
    console.error('Invalid --export-type; expected full or incremental');
    printUsageAndExit(1);
  }

  if (exportType === 'incremental' && args.exportId) {
    const exportDir = await resolveExportDirByExportId(outputRoot, args.exportId);
    console.log(`Resolved export-id ${args.exportId} to directory ${exportDir}`);
    const metadataFile = path.join(exportDir, 'export-response.json');
    const metadataRaw = await fs.promises.readFile(metadataFile, 'utf8');
    const metadata = JSON.parse(metadataRaw);
    const startTime = metadata?.ExportDescription?.StartTime ?? metadata?.ExportDescription?.ExportTime;
    if (startTime) {
      const startIso = typeof startTime === 'number'
        ? new Date(Math.round(startTime * 1000)).toISOString()
        : new Date(startTime).toISOString();
      incrementalFrom = startIso;
      console.log(`Computed incremental-from=${incrementalFrom} from export-id metadata`);
    }
    if (!incrementalTo) {
      incrementalTo = new Date().toISOString();
      console.log(`Defaulted incremental-to=${incrementalTo} to current time`);
    }
  }

  if (exportType === 'incremental' && !incrementalFrom && !incrementalTo) {
    console.warn('Incremental export requested without --incremental-from or --incremental-to; requesting latest incremental export.');
  }

  const pendingExports = [];

  for (const storageType of STORAGE_TYPES) {
    console.log(`\n=== Creating export for ${storageType} storage ===`);
    const exportResponse = await fetchExportData(
      baseUrl,
      storageType,
      token,
      exportType,
      incrementalFrom,
      incrementalTo,
    );
    const exportArn = getExportArn(exportResponse);
    if (!exportArn) {
      throw new Error(
        `Could not resolve exportArn from ${storageType} export create response`,
      );
    }

    const startTime = getStartTime(exportResponse) || new Date().toISOString();
    const startTimeIso = normalizeFolderName(new Date(startTime).toISOString());
    const humanStartTime = new Date(startTime).toLocaleString();
    const exportTypeLabel = args.exportType === 'incremental' ? 'incremental' : 'full';
    const suffixParts = [storageType, exportTypeLabel];
    if (args.exportType === 'incremental') {
      const rangePart = [];
      if (args.incrementalFrom) rangePart.push(`from-${normalizeFolderName(args.incrementalFrom)}`);
      if (args.incrementalTo) rangePart.push(`to-${normalizeFolderName(args.incrementalTo)}`);
      if (rangePart.length > 0) {
        suffixParts.push(rangePart.join('-'));
      }
      if (args.exportId) {
        suffixParts.push(`base-${normalizeFolderName(args.exportId)}`);
      }
    }
    const outputDir = path.join(args.outputRoot, `${startTimeIso}-${suffixParts.join('-')}`);
    mkdirRecursive(outputDir);

    const metadataFile = path.join(outputDir, 'export-response.json');
    fs.writeFileSync(metadataFile, JSON.stringify(exportResponse, null, 2), 'utf8');
    console.log(`Saved export metadata to ${metadataFile}`);
    console.log(`ExportArn: ${exportArn}`);
    console.log(`Creation time: ${humanStartTime}`);

    pendingExports.push({
      storageType,
      exportArn,
      outputDir,
      startTime,
      humanStartTime,
    });
  }

  const exportResults = [];

  for (const pending of pendingExports) {
    const { storageType, exportArn, outputDir } = pending;
    console.log(`\n=== Waiting for ${storageType} export completion ===`);
    await waitForExportCompletion(
      baseUrl,
      storageType,
      exportArn,
      token,
      waitSeconds,
    );

    const listResponse = await fetchListFiles(baseUrl, storageType, exportArn, token);
    const items = Array.isArray(listResponse.items) ? listResponse.items : [];
    if (items.length === 0) {
      console.log(
        `No files found for ${storageType} export after completion polling.`,
      );
      exportResults.push({ storageType, exportArn, outputDir, downloadedItems: 0 });
      continue;
    }

    console.log(`Found ${items.length} exported items for ${storageType}.`);
    for (const item of items) {
      if (!item || typeof item !== 'object') {
        continue;
      }
      const key = String(item.key || '');
      const getUrl = String(item.getUrl || '');
      if (!getUrl) {
        console.warn(`Skipping item with missing getUrl: ${key}`);
        continue;
      }
      const relativePath = sanitizeItemKey(key);
      const filePath = path.join(outputDir, relativePath);
      console.log(`Downloading ${relativePath}`);
      await downloadUrlToFile(getUrl, filePath);
    }

    exportResults.push({ storageType, exportArn, outputDir, downloadedItems: items.length });
    console.log(`Downloaded ${items.length} files for ${storageType} into ${outputDir}`);
  }

  console.log('\nAll exports completed successfully.');
  console.log(JSON.stringify(exportResults, null, 2));
}

run().catch((error) => {
  console.error(`Error: ${error.message}`);
  process.exit(1);
});
