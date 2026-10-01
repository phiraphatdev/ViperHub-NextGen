param([switch]$Preview)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$launcher = Join-Path $root 'ViperHub.cmd'
$work = Join-Path $root 'work'
$pidFile = Join-Path $work 'runtime-server.pid'
$shareFile = Join-Path $work 'runtime-share.json'
$logFile = Join-Path $work 'runtime-access.log'
$version = try { (Get-Content (Join-Path $root 'manifest.json') -Raw | ConvertFrom-Json).version } catch { 'dev' }
$inner = 63

function Write-Line([string]$text = '', [ConsoleColor]$color = 'Gray') {
    Write-Host $text -ForegroundColor $color
}

function Write-Row([string]$left, [string]$right = '', [ConsoleColor]$color = 'Gray', [ConsoleColor]$rightColor = $color) {
    $content = '  ' + $left
    $gap = [Math]::Max(1, $inner - $content.Length - $right.Length - 1)
    Write-Host '  │' -ForegroundColor DarkCyan -NoNewline
    Write-Host $content -ForegroundColor $color -NoNewline
    Write-Host (' ' * $gap) -NoNewline
    Write-Host $right -ForegroundColor $rightColor -NoNewline
    Write-Host ' │' -ForegroundColor DarkCyan
}

function Write-Rule([string]$kind = 'mid') {
    $bar = '─' * $inner
    switch ($kind) {
        'top' { Write-Line "  ╭$bar╮" DarkCyan }
        'bottom' { Write-Line "  ╰$bar╯" DarkCyan }
        default { Write-Line "  ├$bar┤" DarkCyan }
    }
}

function Get-ServerStatus {
    if (-not (Test-Path -LiteralPath $pidFile)) { return 'OFFLINE' }
    $serverPid = 0
    $value = (Get-Content -LiteralPath $pidFile -Raw).Trim()
    if (-not [int]::TryParse($value, [ref]$serverPid)) { return 'STALE PID' }
    if (Get-Process -Id $serverPid -ErrorAction SilentlyContinue) { return 'ONLINE' }
    return 'STALE PID'
}

function Get-Share {
    if (-not (Test-Path -LiteralPath $shareFile)) { return $null }
    try { return Get-Content -LiteralPath $shareFile -Raw | ConvertFrom-Json } catch { return $null }
}

function Get-RequestCount {
    if (-not (Test-Path -LiteralPath $logFile)) { return 0 }
    try { return @(Get-Content -LiteralPath $logFile).Count } catch { return 0 }
}

function Show-Dashboard {
    if (-not $Preview) { Clear-Host }
    $status = Get-ServerStatus
    $share = Get-Share
    $sharing = $null -ne $share -and $status -eq 'ONLINE'
    Write-Line ''
    Write-Rule 'top'
    Write-Row 'VIPERHUB  /  NEXTGEN' "v$version" Cyan
    Write-Row 'Developer console  •  local workspace' '' DarkGray
    Write-Rule
    Write-Row 'RUNTIME SERVER' $status $(if ($status -eq 'ONLINE') { 'Green' } else { 'Yellow' })
    Write-Row 'Local endpoint' '127.0.0.1:8766' Gray
    Write-Row 'Remote testers' $(if ($sharing) { 'SHARING' } else { 'OFF' }) Gray $(if ($sharing) { 'Magenta' } else { 'DarkGray' })
    if ($sharing) {
        $url = [string]$share.url
        if ($url.Length -gt 52) { $url = $url.Substring(0, 49) + '...' }
        Write-Row "via $($share.provider)" $url DarkGray Magenta
        Write-Row 'Requests logged' ([string](Get-RequestCount)) DarkGray Gray
    }
    Write-Rule
    Write-Row 'BUILD & VALIDATE' '' Cyan
    Write-Row '[1]  Build development artifacts'
    Write-Row '[2]  Run full local checks'
    Write-Rule
    Write-Row 'RUNTIME' '' Cyan
    Write-Row '[3]  Build + start runtime server' 'BACKGROUND' Gray DarkGray
    Write-Row '[4]  Stop runtime server (and sharing)'
    Write-Row '[5]  Open generated files'
    Write-Rule
    Write-Row 'SHARE WITH TESTERS' '' Magenta
    Write-Row '[8]  Share over the internet (copies the link)' 'BACKGROUND' Gray DarkGray
    Write-Row '[9]  Stop sharing (server keeps running)'
    Write-Row '[C]  Copy the tester link again'
    Write-Row '[L]  View access log'
    Write-Rule
    Write-Row 'RELEASE TOOLS' '' Cyan
    Write-Row '[6]  Build release artifacts'
    Write-Row '[7]  Verify release artifacts'
    Write-Rule
    Write-Row '[H]  Help' '[0]  Exit' DarkGray
    Write-Rule 'bottom'
    Write-Line ''
    Write-Line '     Press a key to choose an action...' DarkGray
    Write-Line ''
}

function Show-Help {
    Clear-Host
    Write-Line ''
    Write-Line '  ╭─ QUICK START ─────────────────────────────────────────────────╮' Cyan
    Write-Row '1  Select [3] to build and start the local server in background.'
    Write-Row '2  Paste the loadstring line below into Potassium on this PC.'
    Write-Row '3  To let a tester on another network try it: select [8].'
    Write-Row '   The server stays on 127.0.0.1; a cloudflared quick tunnel'
    Write-Row '   (must be installed) publishes it.'
    Write-Row '4  Send the copied loadstring line to the tester.'
    Write-Row '5  Finish with [9]; remote access stops immediately.'
    Write-Line '  ╰───────────────────────────────────────────────────────────────╯' Cyan
    Write-Line ''
    Write-Line '  loadstring(game:HttpGet("http://127.0.0.1:8766/runtime-smoke.lua"))()' Yellow
    Write-Line ''
    Write-Line '  Anyone with the shared link can download the dev script: share it only' DarkYellow
    Write-Line '  with people you trust. The access log never stores the link itself.' DarkYellow
    Write-Line ''
    Write-Line '  CLI: ViperHub.cmd build | check | run | stop | share | unshare | link | log | release | verify' DarkGray
    Write-Line ''
    [void](Read-Host '  Press Enter to return')
}

if ($Preview) {
    Show-Dashboard
    return
}

while ($true) {
    Show-Dashboard
    $key = [Console]::ReadKey($true).KeyChar.ToString().ToUpperInvariant()
    if ($key -eq '0') { break }
    if ($key -eq 'H') { Show-Help; continue }
    if ($key -eq '5') {
        if (-not (Test-Path $work)) { New-Item -ItemType Directory -Path $work | Out-Null }
        Start-Process explorer.exe -ArgumentList $work
        continue
    }
    $command = switch ($key) {
        '1' { 'build' }
        '2' { 'check' }
        '3' { 'run' }
        '4' { 'stop' }
        '6' { 'release' }
        '7' { 'verify' }
        '8' { 'share' }
        '9' { 'unshare' }
        'C' { 'link' }
        'L' { 'log' }
        default { $null }
    }
    if (-not $command) { continue }
    Clear-Host
    Write-Line "  VIPERHUB  /  $($command.ToUpperInvariant())" Cyan
    Write-Line '  ───────────────────────────────────────────────────────────────' DarkCyan
    & $launcher $command
    Write-Line ''
    [void](Read-Host '  Press Enter to return to dashboard')
}
