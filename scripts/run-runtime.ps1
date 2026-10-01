param([ValidateRange(1, 65535)][int]$Port = 8766)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$harnessPath = Join-Path $projectRoot 'work/runtime-smoke.lua'
$pidPath = Join-Path $projectRoot 'work/runtime-server.pid'

Push-Location $projectRoot
try {
    & (Join-Path $PSScriptRoot 'build.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Build failed' }

    $listener = $null
    for ($attempt = 1; $attempt -le 20; $attempt++) {
        try {
            $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
            $listener.Start()
            break
        }
        catch {
            if ($attempt -eq 20) { throw }
            if ($null -ne $listener) { try { $listener.Stop() } catch { } }
            Start-Sleep -Milliseconds 500
        }
    }
    [System.IO.File]::WriteAllText($pidPath, [string]$PID)

    Write-Host ''
    Write-Host 'Keep this terminal open, then run this saved line in Potassium:' -ForegroundColor Cyan
    Write-Host "loadstring(game:HttpGet(`"http://127.0.0.1:$Port/runtime-smoke.lua`"))()" -ForegroundColor Yellow
    Write-Host "Serving $harnessPath (Ctrl+C to stop)" -ForegroundColor Green

    $logPath = Join-Path $projectRoot 'work/runtime-access.log'
    $maxLogBytes = 262144
    function Write-Access([string]$who, [string]$path, [string]$status, [int]$bytes) {
        try {
            if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -gt $maxLogBytes) {
                Move-Item -LiteralPath $logPath -Destination "$logPath.old" -Force
            }
            $line = '{0:o} {1} {2} {3} {4}' -f (Get-Date), $who, $path, $status, $bytes
            Add-Content -LiteralPath $logPath -Value $line -Encoding ascii
        }
        catch { }
    }

    while ($true) {
        $client = $null
        try {
            $client = $listener.AcceptTcpClient()
            # A slow or stalled remote client must not block the single-threaded server for long.
            $client.ReceiveTimeout = 5000
            $client.SendTimeout = 20000
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            $who = 'local'
            $headerCount = 0
            while ($null -ne ($line = $reader.ReadLine()) -and $line.Trim() -ne '' -and $headerCount -lt 64) {
                $headerCount++
                if ($line -match '^(?:X-Forwarded-For|CF-Connecting-IP):\s*([0-9a-fA-F\.:,\s]{1,80})$') { $who = ($Matches[1].Trim() -split '\s*,\s*')[0] }
            }
            $path = '-'
            if ($requestLine -match '^GET (/[A-Za-z0-9_\-\.]*)') { $path = $Matches[1] }
            if ($requestLine -match '^GET /runtime-smoke\.lua(?:\?[^ ]*)? HTTP/') {
                $body = [System.IO.File]::ReadAllBytes($harnessPath)
                $status = '200 OK'
            }
            elseif ($requestLine -match '^GET /health(?:\?[^ ]*)? HTTP/') {
                $body = [System.Text.Encoding]::UTF8.GetBytes("ready`n")
                $status = '200 OK'
            }
            else {
                $body = [System.Text.Encoding]::UTF8.GetBytes("not found`n")
                $status = '404 Not Found'
            }
            $headers = "HTTP/1.1 $status`r`nContent-Type: text/plain; charset=utf-8`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headers)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($body, 0, $body.Length)
            $stream.Flush()
            $reader.Dispose()
            Write-Access $who $path $status.Substring(0, 3) $body.Length
        }
        catch {
            Write-Access 'error' '-' '000' 0
        }
        finally {
            if ($null -ne $client) { $client.Dispose() }
        }
    }
}
finally {
    if ($null -ne $listener) {
        try { $listener.Stop() } catch { }
    }
    if (Test-Path -LiteralPath $pidPath) {
        $recordedPid = [System.IO.File]::ReadAllText($pidPath).Trim()
        if ($recordedPid -eq [string]$PID) {
            Remove-Item -LiteralPath $pidPath -Force
        }
    }
    Pop-Location
}
