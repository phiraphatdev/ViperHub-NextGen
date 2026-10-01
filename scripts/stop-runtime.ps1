# Stopping the runtime also stops any tester sharing so nothing stays published without a server.
& (Join-Path $PSScriptRoot 'share-runtime.ps1') -Action stop

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pidPath = Join-Path $projectRoot 'work/runtime-server.pid'

if (-not (Test-Path -LiteralPath $pidPath)) {
    Write-Host 'Runtime server is not running.' -ForegroundColor Yellow
    exit 0
}

$recorded = [System.IO.File]::ReadAllText($pidPath).Trim()
$serverPid = 0
if (-not [int]::TryParse($recorded, [ref]$serverPid)) {
    Remove-Item -LiteralPath $pidPath -Force
    throw 'Runtime PID file was invalid and has been removed.'
}

$process = Get-Process -Id $serverPid -ErrorAction SilentlyContinue
if ($null -eq $process) {
    Remove-Item -LiteralPath $pidPath -Force
    Write-Host 'Removed a stale runtime PID file.' -ForegroundColor Yellow
    exit 0
}

Stop-Process -Id $serverPid
Wait-Process -Id $serverPid -Timeout 5 -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
Write-Host "Runtime server stopped (PID $serverPid)." -ForegroundColor Green
