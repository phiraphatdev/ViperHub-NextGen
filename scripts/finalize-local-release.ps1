param(
    [Parameter(Mandatory = $true)][string]$Repository,
    [ValidateSet('Beta', 'Stable')][string]$Tier = 'Beta',
    [string[]]$Games = @('AnimeVanguards', 'AnimeExpeditions'),
    [switch]$Commit
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not $Commit) {
    Write-Host 'Dry run: no files or commits changed. Pass -Commit only after source commit S and runtime evidence are ready.'
    & node (Join-Path $PSScriptRoot 'pipeline.mjs') verify
    if ($LASTEXITCODE -ne 0) { throw 'Existing release verification failed' }
    return
}

# Build is the gate: it requires clean S and matching real-client evidence.
& (Join-Path $PSScriptRoot 'build.ps1') -Release -Repository $Repository -Tier $Tier -Games $Games
if ($LASTEXITCODE -ne 0) { throw 'Release build failed' }
$changed = @(git diff --name-only)
$unexpected = @($changed | Where-Object { $_ -notin @('manifest.json', 'manifest.txt') -and $_ -notlike 'dist/*' })
if ($unexpected.Count -gt 0) { throw "Unexpected changed files after build: $($unexpected -join ', ')" }
& git add -- manifest.json manifest.txt dist
if ($LASTEXITCODE -ne 0) { throw 'Failed to stage artifacts' }
& git commit -m "build(release): generate $Tier artifacts"
if ($LASTEXITCODE -ne 0) { throw 'Artifact commit A failed' }
$artifactRevision = (& git rev-parse HEAD).Trim()
$manifest = Get-Content manifest.json -Raw | ConvertFrom-Json
$manifest.artifactRevision = $artifactRevision
[System.IO.File]::WriteAllText((Join-Path (Get-Location) 'manifest.json'), (($manifest | ConvertTo-Json -Depth 20) + "`n"), [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::AppendAllText((Join-Path (Get-Location) 'manifest.txt'), "artifactRevision: $artifactRevision`n", [System.Text.UTF8Encoding]::new($false))
& git add -- manifest.json manifest.txt
if ($LASTEXITCODE -ne 0) { throw 'Failed to stage publication metadata' }
& git commit -m 'chore(release): record artifact revision'
if ($LASTEXITCODE -ne 0) { throw 'Metadata commit B failed' }
& (Join-Path $PSScriptRoot 'verify-release.ps1')
Write-Host "Local release commits A=$artifactRevision B=$((& git rev-parse HEAD).Trim()); not pushed, tagged or activated"
