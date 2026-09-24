param([switch]$Development)
$ErrorActionPreference = 'Stop'
$arguments = @((Join-Path $PSScriptRoot 'pipeline.mjs'), 'verify')
& node @arguments
if ($LASTEXITCODE -ne 0) { throw 'Artifact verification failed' }
