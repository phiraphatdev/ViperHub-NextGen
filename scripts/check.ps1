$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'setup-tools.ps1')
& node (Join-Path $PSScriptRoot 'pipeline.mjs') check
if ($LASTEXITCODE -ne 0) { throw 'Checks failed' }

