#!/usr/bin/env node
const { execSync } = require('child_process');
const fs = require('fs');

const action = process.argv[2];

const profile = process.env.AWS_PROFILE || 'sltt-dart-prd';
const region = process.env.AWS_REGION || 'us-east-1';

function run(cmd, opts = {}) {
  return execSync(cmd, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'inherit'], ...opts }).trim();
}

function readLastExportArn() {
  try {
    return fs.readFileSync('./last_export_arn', 'utf8').trim();
  } catch (e) {
    return null;
  }
}

function writeLastExportArn(arn) {
  try {
    fs.writeFileSync('./last_export_arn', arn + '\n', 'utf8');
  } catch (e) {
    // ignore
  }
}

try {
  if (action === 'help' || !action) {
    console.log('Usage: node scripts/s3_export_ops.js <export|status|ls|download>');
    console.log('  export: Start a new export of the DynamoDB table to S3. Requires TABLE_ARN, S3_BUCKET, and S3_PREFIX env vars or defaults.');
    console.log('DEFAULTS: TABLE_ARN=arn:aws:dynamodb:us-east-1:379334555674:table/sltt-shared-infra-changes-states, S3_BUCKET=sltt-shared-infra-media-worm-379334555674, S3_PREFIX=dynamodb-exports/diag');
    console.log('  status: Check the status of the export specified by EXPORT_ARN env var or last_export_arn file.');
    console.log('  ls: List the objects in the S3 export specified by EXPORT_ARN env var or last_export_arn file.');
    console.log('  download: Download the objects from the S3 export specified by EXPORT_ARN env var or last_export_arn file.');
    process.exit(0);
  }
  if (action === 'export') {
    const tableArn = process.env.TABLE_ARN || 'arn:aws:dynamodb:us-east-1:379334555674:table/sltt-shared-infra-changes-states';
    const bucket = process.env.S3_BUCKET || 'sltt-shared-infra-media-worm-379334555674';
    const prefix = process.env.S3_PREFIX || 'dynamodb-exports/diag';

    console.log(`Starting export: table=${tableArn} -> s3://${bucket}/${prefix}`);
    const exportArn = run(`aws dynamodb export-table-to-point-in-time --table-arn ${tableArn} --s3-bucket ${bucket} --s3-prefix ${prefix} --export-format DYNAMODB_JSON --profile ${profile} --region ${region} --query ExportDescription.ExportArn --output text`);
    console.log('Export started. ExportArn:', exportArn);
    writeLastExportArn(exportArn);
    console.log('Wrote ./last_export_arn; you can set EXPORT_ARN from it or re-run other scripts.');
    console.log('Using ExportArn:', exportArn);
    process.exit(0);
  }

  if (action === 'status') {
    const exportArn = readLastExportArn();
    if (!exportArn) {
      console.error('ERROR: ./last_export_arn not found. Run `node scripts/s3_export_ops.js export` first.');
      process.exit(2);
    }
    console.log('Using ExportArn:', exportArn);

    const shouldPoll = process.argv[3] === 'poll' || process.env.POLL === '1' || process.env.POLL === 'true';
    const pollInterval = parseInt(process.env.POLL_INTERVAL_SECONDS || '10', 10);

    function getStatus(arn) {
      return run(`aws dynamodb describe-export --export-arn ${arn} --profile ${profile} --region ${region} --query ExportDescription.ExportStatus --output text`);
    }

    function getBucketAndPrefix(arn) {
      const bucket = run(`aws dynamodb describe-export --export-arn ${arn} --profile ${profile} --region ${region} --query ExportDescription.S3Bucket --output text`);
      const prefix = run(`aws dynamodb describe-export --export-arn ${arn} --profile ${profile} --region ${region} --query ExportDescription.S3Prefix --output text`);
      return { bucket, prefix };
    }

    function getLastListedObjectLine(bucket, prefix) {
      try {
        const out = run(`aws s3 ls s3://${bucket}/${prefix} --profile ${profile} --region ${region} --recursive`);
        const lines = out.split(/\r?\n/).map(l => l.trim()).filter(Boolean);
        if (lines.length === 0) return null;
        return lines[lines.length - 1];
      } catch (e) {
        return null;
      }
    }

    const { bucket, prefix } = getBucketAndPrefix(exportArn);

    if (!shouldPoll) {
      const status = getStatus(exportArn);
      const lastLine = bucket ? getLastListedObjectLine(bucket, prefix) : null;
      const ts = new Date().toISOString();
      console.log(`${ts}  Status=${status}${lastLine ? `  LastObject: ${lastLine}` : ''}`);
      process.exit(0);
    }

    console.log(`Polling export status every ${pollInterval}s for ExportArn: ${exportArn}`);
    const sleepCmd = process.platform === 'win32' ? `ping -n ${pollInterval + 1} 127.0.0.1 >nul` : `sleep ${pollInterval}`;

    while (true) {
      const status = getStatus(exportArn);
      const lastLine = bucket ? getLastListedObjectLine(bucket, prefix) : null;
      const ts = new Date().toISOString();
      console.log(`${ts}  Status=${status}${lastLine ? `  LastObject: ${lastLine}` : ''}`);
      if (status === 'COMPLETED' || status === 'FAILED' || status === 'CANCELLED' || status === 'EXPIRED') {
        process.exit(status === 'COMPLETED' ? 0 : 1);
      }
      try { execSync(sleepCmd); } catch (e) { /* ignore */ }
    }
  }

  // For ls/download we support falling back to last_export_arn
  const exportArn = readLastExportArn();
  if (!exportArn) {
    console.error('ERROR: ./last_export_arn not found. Run `node scripts/s3_export_ops.js export` first.');
    process.exit(2);
  }
  console.log('Using ExportArn:', exportArn);

  const bucket = run(`aws dynamodb describe-export --export-arn ${exportArn} --profile ${profile} --region ${region} --query ExportDescription.S3Bucket --output text`);
  const prefix = run(`aws dynamodb describe-export --export-arn ${exportArn} --profile ${profile} --region ${region} --query ExportDescription.S3Prefix --output text`);

  if (!bucket) throw new Error('Export description did not contain S3 bucket information');

  // Append /AWSDynamoDB/<exportId> to the prefix for ls/download
  function getExportId(arn) {
    const parts = arn.split('/');
    return parts[parts.length - 1];
  }
  const exportId = getExportId(exportArn);
  const exportSubdir = `${prefix.replace(/\/+$/, '')}/AWSDynamoDB/${exportId}`;
  const s3uri = `s3://${bucket}/${exportSubdir}`.replace(/\\/g, '/');

  if (action === 'ls') {
    console.log(`Listing objects under ${s3uri}`);
    execSync(`aws s3 ls ${s3uri} --profile ${profile} --region ${region} --recursive`, { stdio: 'inherit' });
  } else if (action === 'download') {
    const dest = './diag-export';
    console.log(`Downloading ${s3uri} -> ${dest}`);
    try { execSync(`mkdir "${dest}" 2>nul || true`); } catch (e) {}
    execSync(`aws s3 cp ${s3uri} ${dest} --profile ${profile} --region ${region} --recursive`, { stdio: 'inherit' });
  } else {
    console.error('Usage: node scripts/s3_export_ops.js <export|status|ls|download>');
    process.exit(2);
  }
} catch (err) {
  console.error('ERROR:', err && err.message ? err.message : err);
  process.exit(1);
}
