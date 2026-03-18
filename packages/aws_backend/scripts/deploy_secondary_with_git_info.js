#!/usr/bin/env node

const {execSync, spawnSync} = require('child_process');
const path = require('path');

const packageDir = path.resolve(__dirname, '..');
const repoRoot = path.resolve(packageDir, '..', '..');

function runGit(command) {
  return execSync(`git ${command}`, {
    cwd: repoRoot,
    encoding: 'utf8',
  }).trim();
}

function runStep(command, args, env) {
  const result = spawnSync(command, args, {
    cwd: packageDir,
    env,
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

function main() {
  let shortChangeset = 'unknown';
  let dirtyFlag = 'unknown';

  try {
    shortChangeset = runGit('rev-parse --short HEAD');
    dirtyFlag = runGit('status --porcelain').length > 0 ? 'true' : 'false';
  } catch (error) {
    console.warn(
      '[deploy-secondary-with-git-info] Failed to read git metadata; using fallback values.',
    );
  }

  const deployEnv = {
    ...process.env,
    GIT_SHORT_CHANGESET: shortChangeset,
    GIT_DIRTY_FLAG: dirtyFlag,
  };

  console.log(
    `[deploy-secondary-with-git-info] GIT_SHORT_CHANGESET=${shortChangeset} GIT_DIRTY_FLAG=${dirtyFlag}`,
  );

  runStep('npm', ['run', 'build'], deployEnv);

  runStep(
    'npx',
    ['serverless', 'deploy', '--config', 'serverless-secondary-infra.yml', ...process.argv.slice(2)],
    deployEnv,
  );
}

main();
