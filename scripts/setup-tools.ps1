$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$lock = Get-Content (Join-Path $repoRoot 'dependencies.lock.json') -Raw | ConvertFrom-Json
foreach ($name in @('darklua', 'stylua', 'luau')) {
    $spec = $lock.tools.$name
    $destination = Join-Path $repoRoot ('.tools/' + $name)
    $valid = $true
    foreach ($entry in $spec.executables.PSObject.Properties) {
        $binary = Join-Path $destination ($entry.Name + '.exe')
        if (-not (Test-Path -LiteralPath $binary -PathType Leaf)) { $valid = $false; break }
        if ((Get-FileHash -LiteralPath $binary -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.Value) {
            $valid = $false
            break
        }
    }
    if ($valid) { continue }
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    $archive = Join-Path $repoRoot ('.tools/' + $name + '.zip')
    Invoke-WebRequest -Uri $spec.url -OutFile $archive
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $spec.sha256) { throw "Tool checksum mismatch: $name" }
    Expand-Archive -LiteralPath $archive -DestinationPath $destination -Force
    foreach ($entry in $spec.executables.PSObject.Properties) {
        $binary = Join-Path $destination ($entry.Name + '.exe')
        if (-not (Test-Path -LiteralPath $binary -PathType Leaf) -or
            (Get-FileHash -LiteralPath $binary -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.Value) {
            throw "Tool binary checksum mismatch after install: $($entry.Name)"
        }
    }
}
