param([switch]$Release, [string]$Repository = '')
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'setup-tools.ps1')
$arguments = @((Join-Path $PSScriptRoot 'pipeline.mjs'), 'build')
if ($Release) { $arguments += @('--release', '--repository', $Repository) }
& node @arguments
if ($LASTEXITCODE -ne 0) { throw 'Build failed' }

