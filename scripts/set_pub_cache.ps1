<#
set_pub_cache.ps1

Detect and set PUB_CACHE in the current PowerShell session to your global pub cache.
Usage:
  Dot-source the script to have the variable set in the current session:
    . .\set_pub_cache.ps1

If you run it without dot-sourcing the changes will not persist in your current interactive session.
#>

param(
  [string]$Path
)

if ($env:PUB_CACHE) {
  Write-Host "PUB_CACHE is already set to: $env:PUB_CACHE"
  Write-Host "If you ran this without dot-sourcing, changes may not persist in your current session." -ForegroundColor Yellow
  Write-Host "Use:  . .\\set_pub_cache.ps1  to dot-source, or persist for new shells with:  setx PUB_CACHE `"$env:PUB_CACHE`""
  return
}

if ($Path) {
  $candidate = $Path
} else {
  $candidate = Join-Path $env:APPDATA 'Pub\Cache'
  if (-not (Test-Path $candidate)) { $candidate = Join-Path $env:LOCALAPPDATA 'Pub\Cache' }
  if (-not (Test-Path $candidate)) { $candidate = Join-Path $env:USERPROFILE '.pub-cache' }
}

if (-not (Test-Path $candidate)) {
  Write-Host "Could not find a pub-cache in standard locations."
  Write-Host "Pass the path as argument: .\set_pub_cache.ps1 -Path 'C:\Users\you\AppData\Roaming\Pub\Cache'"
  return
}

$env:PUB_CACHE = $candidate
Write-Host "PUB_CACHE set to: $env:PUB_CACHE" -ForegroundColor Green

# Detect whether the script was dot-sourced: $MyInvocation.InvocationName is '.' when dot-sourced in many cases,
# and $MyInvocation.ExpectingInput is $true. Provide guidance either way.
if ($MyInvocation.InvocationName -ne '.' -and -not $MyInvocation.ExpectingInput) {
  Write-Host "Note: To affect your current interactive session, dot-source this script:" -ForegroundColor Yellow
  Write-Host "  . .\\set_pub_cache.ps1" -ForegroundColor Yellow
}

Write-Host "To persist for new PowerShell/cmd shells, run:" -ForegroundColor DarkCyan
Write-Host "  setx PUB_CACHE `"$env:PUB_CACHE`"" -ForegroundColor DarkCyan
Write-Host "(setx affects future shells; it does not modify the current session)\n"
