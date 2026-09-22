$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$lock = Get-Content (Join-Path $repoRoot 'dependencies.lock.json') -Raw | ConvertFrom-Json
foreach ($name in @('darklua', 'stylua', 'luau')) {
    $spec = $lock.tools.$name
    $destination = Join-Path $repoRoot ('.tools/' + $name)
    if (Test-Path (Join-Path $destination ($name + '.exe'))) { continue }
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    $archive = Join-Path $repoRoot ('.tools/' + $name + '.zip')
    Invoke-WebRequest -Uri $spec.url -OutFile $archive
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $spec.sha256) { throw "Tool checksum mismatch: $name" }
    Expand-Archive -LiteralPath $archive -DestinationPath $destination -Force
}

