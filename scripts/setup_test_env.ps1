# setup_test_env.ps1
# 1) Locate isar.dll in the local Pub cache (hosted pub.dev)
# 2) Copy it into the package .dart_tool\isar folder (so tools that look there find it)
# 3) Prepend the DLL folder to PATH for this session (so the Windows loader can find it when tests run from temp dirs)
# 4) Run `dart test` in the target package (unless -SetupOnly is specified)

param(
  [switch]$SetupOnly
)

$ErrorActionPreference = 'Stop'

# Directory where hosted pub packages are stored
$pubHosted = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'

# Default target package (relative to this script). Change if needed.
$targetPackage = Resolve-Path (Join-Path $PSScriptRoot '..\packages\sync_manager')

# Find isar.dll in pub cache (prefer isar_flutter_libs, fallback to isar)
$foundDll = $null
foreach ($pattern in @('isar_flutter_libs-*','isar-*')) {
  $glob = Join-Path $pubHosted $pattern
  Get-ChildItem -Path $glob -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $dll = Join-Path $_.FullName 'windows\isar.dll'
    if (Test-Path -LiteralPath $dll) {
      $foundDll = $dll
      break
    }
  }
  if ($foundDll) { break }
}

if (-not $foundDll) {
  Write-Error "isar.dll not found in local pub cache under $pubHosted. Run 'dart pub get' in the package that depends on Isar (e.g. packages/sync_manager) and try again."
}

Write-Host "Found isar.dll at $foundDll"

# Ensure target .dart_tool\isar exists
$targetIsarDir = Join-Path $targetPackage '.dart_tool\isar'
if (-not (Test-Path -LiteralPath $targetIsarDir)) {
  New-Item -ItemType Directory -Force -Path $targetIsarDir | Out-Null
}

# Copy the DLL
Copy-Item -LiteralPath $foundDll -Destination $targetIsarDir -Force
Write-Host "Copied isar.dll to $targetIsarDir"

# Prepend the folder that contains the DLL to PATH for this session only
$isarWindowsDir = Split-Path -Parent $foundDll
if ($env:PATH -notlike "*$isarWindowsDir*") {
  $env:PATH = "$isarWindowsDir;$env:PATH"
}
Write-Host "Prepending '$isarWindowsDir' to PATH for this session"

# Also copy DLL to temp directory for test kernels
$tempDir = $env:TEMP
if (-not $tempDir) { $tempDir = $env:TMP }
if ($tempDir -and (Test-Path $tempDir)) {
  Copy-Item -LiteralPath $foundDll -Destination (Join-Path $tempDir 'isar.dll') -Force
  Write-Host "Copied isar.dll to '$tempDir' for test kernel access"
}

# Also set an explicit env var to allow code to use it when resolving the DLL
$env:ISAR_DLL_PATH = $isarWindowsDir
Write-Host "Setting ISAR_DLL_PATH to '$isarWindowsDir'"

if ($SetupOnly) {
  Write-Host 'Setup complete; not running tests (use without -SetupOnly to run tests).'
  exit 0
}

# Run tests in the target package (same PS session, so PATH applies)
Push-Location $targetPackage
try {
  Write-Host "Running tests in $targetPackage"
  & dart test @args
  $exitCode = $LASTEXITCODE
} finally {
  Pop-Location
}
exit $exitCode
