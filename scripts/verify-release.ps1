param([switch]$Development)
$ErrorActionPreference = 'Stop'
$arguments = @((Join-Path $PSScriptRoot 'pipeline.mjs'), 'verify')
if ($Development) { $arguments += '--development' }
& node @arguments
if ($LASTEXITCODE -ne 0) { throw 'Artifact verification failed' }

