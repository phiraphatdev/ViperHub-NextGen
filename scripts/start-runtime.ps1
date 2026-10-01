$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pidPath = Join-Path $projectRoot 'work/runtime-server.pid'
$runScript = Join-Path $PSScriptRoot 'run-runtime.ps1'

if (Test-Path -LiteralPath $pidPath) {
    $recorded = [System.IO.File]::ReadAllText($pidPath).Trim()
    $serverPid = 0
    if ([int]::TryParse($recorded, [ref]$serverPid)) {
        if (Get-Process -Id $serverPid -ErrorAction SilentlyContinue) {
            Write-Host "Runtime server is already running in background (PID $serverPid)." -ForegroundColor Yellow
            Write-Host 'Paste this line into Potassium:' -ForegroundColor Cyan
            Write-Host '  loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()' -ForegroundColor Yellow
            exit 0
        }
    }
    Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Starting runtime server in background..." -ForegroundColor Cyan

$psExe = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { 'pwsh.exe' } else { 'powershell.exe' }
$process = Start-Process -FilePath $psExe -ArgumentList "-NoLogo", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$runScript`"" -WindowStyle Hidden -PassThru

for ($i = 0; $i -lt 30; $i++) {
    if (Test-Path -LiteralPath $pidPath) {
        break
    }
    Start-Sleep -Milliseconds 200
}

if (Test-Path -LiteralPath $pidPath) {
    $currentPid = [System.IO.File]::ReadAllText($pidPath).Trim()
    Write-Host "[OK] Runtime server is running in background (PID $currentPid, Port 8766)." -ForegroundColor Green
    Write-Host ''
    Write-Host 'Paste this line into Potassium:' -ForegroundColor Cyan
    Write-Host '  loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'To stop the server, choose option 4 or run: ViperHub.cmd stop' -ForegroundColor DarkGray
} else {
    Write-Host "[WARNING] Runtime server started (Process $($process.Id)), awaiting port 8766 listener." -ForegroundColor Yellow
}
