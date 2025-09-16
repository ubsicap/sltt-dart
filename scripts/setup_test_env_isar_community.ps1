<#
  setup_test_env.ps1

  New behavior:
    See https://github.com/isar-community/isar-community/issues/15#issuecomment-3217486422
    1. Parse packages/sync_manager/pubspec.yaml for `isar_version:` anchor value.
    2. Fetch the GitHub release (tag == version) JSON from the isar-community repo.
    3. Locate a Windows .dll asset (first *.dll match) and download it.
    4. Rename the downloaded file to libisar.dll and place it at packages/sync_manager/libisar.dll.
    5. Also copy (or duplicate) it as isar.dll inside .dart_tool\isar for legacy lookup & add its folder to PATH.
    6. Optionally run `dart test` unless -SetupOnly is provided.

  Notes:
    - Falls back to legacy pub cache scan if GitHub fetch fails.
    - Requires network access to GitHub for automatic download.
    - Idempotent: re-downloads each run (use -SkipDownload to reuse existing file).
#>

param(
  [switch]$SetupOnly,
  [switch]$SkipDownload,
  [switch]$VerboseLogging
)

$ErrorActionPreference = 'Stop'

function Write-Log {
  param([string]$Message,[string]$Level = 'INFO')
  if ($Level -eq 'DEBUG' -and -not $VerboseLogging) { return }
  Write-Host "[$Level] $Message"
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$targetPackage = Resolve-Path (Join-Path $repoRoot 'packages\sync_manager')
$pubspecPath = Join-Path $targetPackage 'pubspec.yaml'
if (-not (Test-Path -LiteralPath $pubspecPath)) {
  throw "pubspec.yaml not found at $pubspecPath"
}

function Get-IsarVersionFromPubspec {
  param([string]$Path)
  $content = Get-Content -LiteralPath $Path
  foreach ($line in $content) {
    # Match: isar_version: &isar_version 3.3.0-dev.2
    if ($line -match '^\s*isar_version:\s*&[A-Za-z0-9_]+\s+([^\s#]+)') {
      return $Matches[1]
    }
    # Or simple: isar_version: 3.3.0-dev.2
    if ($line -match '^\s*isar_version:\s*([^\s#]+)') {
      return $Matches[1]
    }
  }
  throw 'Could not locate isar_version in pubspec.yaml'
}

$isarVersion = Get-IsarVersionFromPubspec -Path $pubspecPath
Write-Log "Detected isar version: $isarVersion" 'INFO'

$downloadedDllPath = $null
$ghReleaseApi = "https://api.github.com/repos/isar-community/isar-community/releases/tags/$isarVersion"

if (-not $SkipDownload) {
  try {
    Write-Log "Querying GitHub release: $ghReleaseApi" 'INFO'
    $releaseJson = Invoke-WebRequest -UseBasicParsing -Uri $ghReleaseApi | ConvertFrom-Json
    if (-not $releaseJson.assets) { throw 'No assets array in release JSON' }
    $dllAsset = $releaseJson.assets | Where-Object { $_.name -match '\\.dll$' } | Select-Object -First 1
    if (-not $dllAsset) { throw 'No .dll asset found in release assets' }
    Write-Log "Found DLL asset: $($dllAsset.name)" 'INFO'
    $tempDir = Join-Path ([IO.Path]::GetTempPath()) "isar_dl_$([Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    $downloadTarget = Join-Path $tempDir $dllAsset.name
    Write-Log "Downloading to $downloadTarget" 'INFO'
    Invoke-WebRequest -UseBasicParsing -Uri $dllAsset.browser_download_url -OutFile $downloadTarget
    $downloadedDllPath = $downloadTarget
  } catch {
    Write-Log "GitHub download failed: $($_.Exception.Message). Will attempt pub cache fallback." 'WARN'
  }
} else {
  Write-Log 'SkipDownload specified; will look for existing libisar.dll' 'INFO'
}

$destLibPath = Join-Path $targetPackage 'libisar.dll'

if ($downloadedDllPath) {
  Copy-Item -LiteralPath $downloadedDllPath -Destination $destLibPath -Force
  Write-Log "Placed libisar.dll at $destLibPath" 'INFO'
} elseif (-not (Test-Path -LiteralPath $destLibPath)) {
  # Fallback to legacy pub cache discovery if download absent.
  Write-Log 'Attempting legacy pub cache discovery for isar.dll' 'INFO'
  $pubHosted = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev'
  $foundDll = $null
  foreach ($pattern in @('isar_flutter_libs-*','isar-*')) {
    $glob = Join-Path $pubHosted $pattern
    Get-ChildItem -Path $glob -Directory -ErrorAction SilentlyContinue | ForEach-Object {
      $dll = Join-Path $_.FullName 'windows\isar.dll'
      if (Test-Path -LiteralPath $dll) { $foundDll = $dll; break }
    }
    if ($foundDll) { break }
  }
  if (-not $foundDll) { throw 'Unable to obtain isar DLL (download + legacy fallback both failed).' }
  Copy-Item -LiteralPath $foundDll -Destination $destLibPath -Force
  Write-Log "Copied fallback isar.dll to $destLibPath (renamed to libisar.dll)" 'INFO'
} else {
  Write-Log 'Existing libisar.dll found; reusing.' 'INFO'
}

# Prepare .dart_tool\isar directory with plain isar.dll (some tooling expects this name/path)
$targetIsarDir = Join-Path $targetPackage '.dart_tool\isar'
if (-not (Test-Path -LiteralPath $targetIsarDir)) {
  New-Item -ItemType Directory -Force -Path $targetIsarDir | Out-Null
}
$compatDll = Join-Path $targetIsarDir 'isar.dll'
Copy-Item -LiteralPath $destLibPath -Destination $compatDll -Force
Write-Log "Copied compatibility isar.dll to $compatDll" 'INFO'

# Update PATH with target package root (so both libisar.dll / isar.dll discoverable)
if ($env:PATH -notlike "*$targetPackage*") {
  $env:PATH = "$targetPackage;$env:PATH"
  Write-Log "Prepended $targetPackage to PATH" 'INFO'
}

# Also copy to %TEMP% as isar.dll for spawned test kernels
$tempDirForKernels = $env:TEMP; if (-not $tempDirForKernels) { $tempDirForKernels = $env:TMP }
if ($tempDirForKernels -and (Test-Path $tempDirForKernels)) {
  Copy-Item -LiteralPath $destLibPath -Destination (Join-Path $tempDirForKernels 'isar.dll') -Force
  Write-Log "Copied isar.dll to $tempDirForKernels for test kernel access" 'DEBUG'
}

# Expose env var for explicit resolution if desired.
$env:ISAR_DLL_PATH = $targetPackage
Write-Log "Set ISAR_DLL_PATH=$targetPackage" 'INFO'

if ($SetupOnly) {
  Write-Host 'Setup complete; not running tests (use without -SetupOnly to run tests).'
  exit 0
}

Push-Location $targetPackage
try {
  Write-Host "Running tests in $targetPackage"
  & dart test @args
  $exitCode = $LASTEXITCODE
} finally {
  Pop-Location
}
exit $exitCode
