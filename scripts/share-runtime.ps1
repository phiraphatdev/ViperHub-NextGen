param(
    [ValidateSet('start', 'stop', 'status', 'link', 'log')][string]$Action = 'status',
    [ValidateRange(1, 65535)][int]$Port = 8766
)

# Shares the local runtime server (127.0.0.1 only) with remote testers through a cloudflared quick tunnel that
# runs in the background. No dependency is added to the project; the server itself never listens on a public
# interface, so stopping the tunnel stops all remote access.

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$work = Join-Path $projectRoot 'work'
$shareFile = Join-Path $work 'runtime-share.json'
$logFile = Join-Path $work 'runtime-access.log'
$tunnelLog = Join-Path $work 'runtime-tunnel.log'
$pidPath = Join-Path $work 'runtime-server.pid'
if (-not (Test-Path -LiteralPath $work)) { New-Item -ItemType Directory -Path $work | Out-Null }

function Say([string]$text, [ConsoleColor]$color = 'Gray') { Write-Host $text -ForegroundColor $color }

function Test-ServerRunning {
    if (-not (Test-Path -LiteralPath $pidPath)) { return $false }
    $value = (Get-Content -LiteralPath $pidPath -Raw).Trim()
    $serverPid = 0
    return [int]::TryParse($value, [ref]$serverPid) -and [bool](Get-Process -Id $serverPid -ErrorAction SilentlyContinue)
}

function Get-Share {
    if (-not (Test-Path -LiteralPath $shareFile)) { return $null }
    try { return Get-Content -LiteralPath $shareFile -Raw | ConvertFrom-Json } catch { return $null }
}

function Test-TunnelRunning($share) {
    return $null -ne $share -and $share.pid -and [bool](Get-Process -Id ([int]$share.pid) -ErrorAction SilentlyContinue)
}

function Get-LoadLine([string]$baseUrl) {
    return 'loadstring(game:HttpGet("' + $baseUrl.TrimEnd('/') + '/runtime-smoke.lua"))()'
}

function Show-Link {
    $share = Get-Share
    if ($null -eq $share) {
        Say '[INFO] Not sharing. Choose "Share with testers" first.' Yellow
        return
    }
    $line = Get-LoadLine $share.url
    Say ''
    Say "Send this line to testers (started $($share.startedAt)):" Cyan
    Say "  $line" Yellow
    try { Set-Clipboard -Value $line; Say '[OK] Copied to clipboard.' Green } catch { }
}

function Stop-Share {
    $share = Get-Share
    if ($null -eq $share) {
        Say '[INFO] Not sharing.' Yellow
        return
    }
    if ($share.pid) { Stop-Process -Id ([int]$share.pid) -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $shareFile -Force -ErrorAction SilentlyContinue
    Say '[OK] Sharing stopped. The runtime server is now reachable from this computer only.' Green
}

function Start-Share {
    if (-not (Test-ServerRunning)) {
        Say 'Starting the runtime server first...' Cyan
        & (Join-Path $PSScriptRoot 'start-runtime.ps1')
        if (-not (Test-ServerRunning)) { throw 'Runtime server did not start.' }
    }
    $existing = Get-Share
    if ($null -ne $existing) {
        if (Test-TunnelRunning $existing) {
            Say '[INFO] Already sharing.' Yellow
            Show-Link
            return
        }
        Remove-Item -LiteralPath $shareFile -Force -ErrorAction SilentlyContinue
    }
    $cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue
    if (-not $cloudflared) {
        Say 'cloudflared was not found. Install it, then choose "Share with testers" again:' Red
        Say '  https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/' Gray
        Say '  (Windows: winget install --id Cloudflare.cloudflared)' Gray
        exit 1
    }
    Say ''
    Say 'WARNING: this makes the local dev script downloadable by anyone who has the link.' Yellow
    Say 'Only send the link to trusted testers; use "Stop sharing" when finished.' Yellow
    Say ''
    Remove-Item -LiteralPath $tunnelLog -Force -ErrorAction SilentlyContinue
    $proc = Start-Process -FilePath $cloudflared.Source -ArgumentList 'tunnel', '--url', "http://127.0.0.1:$Port", '--no-autoupdate', '--logfile', "`"$tunnelLog`"" -WindowStyle Hidden -PassThru
    $url = $null
    for ($i = 0; $i -lt 40 -and -not $url; $i++) {
        Start-Sleep -Milliseconds 500
        if (Test-Path -LiteralPath $tunnelLog) {
            $m = [regex]::Match((Get-Content -LiteralPath $tunnelLog -Raw), 'https://[a-z0-9\-]+\.trycloudflare\.com')
            if ($m.Success) { $url = $m.Value }
        }
    }
    if (-not $url) {
        Stop-Process -Id $proc.Id -ErrorAction SilentlyContinue
        throw 'cloudflared did not report a public URL.'
    }
    $record = @{ provider = 'cloudflared'; url = $url; startedAt = (Get-Date).ToString('s'); pid = $proc.Id }
    ($record | ConvertTo-Json) | Set-Content -LiteralPath $shareFile -Encoding ascii
    Say '[OK] Sharing started in the background. Stop it with: ViperHub.cmd unshare (or stop, which stops everything).' Green
    Show-Link
}

function Show-Status {
    $share = Get-Share
    $running = Test-ServerRunning
    Say ('Runtime server : ' + $(if ($running) { 'ONLINE (127.0.0.1:' + $Port + ')' } else { 'OFFLINE' })) $(if ($running) { 'Green' } else { 'Yellow' })
    if ($share -and (Test-TunnelRunning $share)) { Say "Sharing        : ON via $($share.provider) since $($share.startedAt)" Green; Say "Public URL     : $($share.url)" Gray }
    elseif ($share) { Say 'Sharing        : STALE (tunnel process is gone); run unshare' Yellow }
    else { Say 'Sharing        : OFF (local only)' Gray }
}

function Show-Log {
    if (-not (Test-Path -LiteralPath $logFile)) { Say 'No access log yet.' Yellow; return }
    Say "Last 25 requests ($logFile):" Cyan
    Get-Content -LiteralPath $logFile -Tail 25 | ForEach-Object { Say "  $_" Gray }
}

switch ($Action) {
    'start' { Start-Share }
    'stop' { Stop-Share }
    'link' { Show-Link }
    'log' { Show-Log }
    default { Show-Status }
}
