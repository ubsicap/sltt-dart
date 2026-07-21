#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');
const { URL } = require('url');

const DEFAULT_BASE_URL =
  'https://t0e0o97xn5.execute-api.us-east-1.amazonaws.com/prd';
const STORAGE_TYPES = ['auth', 'data'];
const DEFAULT_WAIT_SECONDS = 1;

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

async function fetchExportData(baseUrl, storageType, token) {
  const url = `${baseUrl.replace(/\/$/, '')}/api/admin/storage/${storageType}/export/create`;
  const body = {
    ExportFormat: 'DYNAMODB_JSON',
    ExportType: 'FULL_EXPORT',
  };
  return await jsonRequest('POST', url, body, token);
}

async function fetchListFiles(baseUrl, storageType, exportArn, token) {
  const query = `exportArn=${encodeURIComponent(exportArn)}`;
  const url = `${baseUrl.replace(/\/$/, '')}/api/admin/storage/${storageType}/export/list-files?${query}`;
  return await jsonRequest('GET', url, null, token);
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

async function waitForItems(baseUrl, storageType, exportArn, token, waitSeconds) {
  process.stdout.write(`Waiting for ${storageType} export files`);
  while (true) {
    try {
      const response = await fetchListFiles(baseUrl, storageType, exportArn, token);
      const items = Array.isArray(response.items) ? response.items : [];
      if (items.length > 0) {
        process.stdout.write('\n');
        return response;
      }
    } catch (error) {
      process.stdout.write(`\nError while listing files: ${error.message}\n`);
      throw error;
    }

    process.stdout.write('.');
    await sleep(waitSeconds * 1000);
  }
}

async function run() {
  const { baseUrl, token, outputRoot, waitSeconds } = parseArgs();

  if (!token) {
    console.error(
      'Missing bearer token. Set AUTH_TOKEN, ACCESS_TOKEN, BEARER_TOKEN, or pass --token.',
    );
    printUsageAndExit(1);
  }

  const exportResults = [];

  for (const storageType of STORAGE_TYPES) {
    console.log(`\n=== Starting export for ${storageType} storage ===`);
    const exportResponse = await fetchExportData(baseUrl, storageType, token);
    const exportArn = getExportArn(exportResponse);
    if (!exportArn) {
      throw new Error(
        `Could not resolve exportArn from ${storageType} export create response`,
      );
    }

    const startTime = getStartTime(exportResponse) || new Date().toISOString();
    const startTimeIso = normalizeFolderName(new Date(startTime).toISOString());
    const outputDir = path.join(outputRoot, `${startTimeIso}-${storageType}`);
    mkdirRecursive(outputDir);

    const metadataFile = path.join(outputDir, 'export-response.json');
    fs.writeFileSync(metadataFile, JSON.stringify(exportResponse, null, 2), 'utf8');
    console.log(`Saved export metadata to ${metadataFile}`);
    console.log(`ExportArn: ${exportArn}`);

    const listResponse = await waitForItems(
      baseUrl,
      storageType,
      exportArn,
      token,
      waitSeconds,
    );

    const items = Array.isArray(listResponse.items) ? listResponse.items : [];
    if (items.length === 0) {
      console.log(`No files found for ${storageType} export after polling.`);
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
