param([switch]$Release, [string]$Repository = '', [ValidateSet('Beta', 'Stable')][string]$Tier = 'Stable', [string[]]$Games = @())
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'setup-tools.ps1')
$arguments = @((Join-Path $PSScriptRoot 'pipeline.mjs'), 'build')
if ($Release) {
    $arguments += @('--release', '--repository', $Repository, '--tier', $Tier.ToLowerInvariant())
    if ($Games.Count -gt 0) { $arguments += @('--games', ($Games -join ',')) }
}
& node @arguments
if ($LASTEXITCODE -ne 0) { throw 'Build failed' }
