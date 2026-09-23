import assert from 'node:assert/strict';
import fs from 'node:fs';
import {deriveGames, validateProject, validateSourceManifest, validateReleaseScope, validateEvidence, GAME_IDS, REQUIRED_CHECKS} from '../scripts/release-guards.mjs';

const read = p => fs.readFileSync(new URL('../' + p, import.meta.url), 'utf8');
const manifest = JSON.parse(read('manifest.json'));
const status = JSON.parse(read('status.json'));
const registry = read('src/games/Registry.luau');
const metadata = Object.fromEntries(GAME_IDS.map(id => [id, read(`src/games/${id}/Metadata.luau`)]));
const clone = value => structuredClone(value);
const rejects = (fn, message) => assert.throws(fn, {message: new RegExp(message)});
validateProject(manifest, status, registry, metadata);
assert.deepEqual(deriveGames(registry, metadata), manifest.games);
const nextVersion = '9.9.9';
const changedMetadata = {...metadata, AnimeVanguards: metadata.AnimeVanguards.replace(/local VERSION = "[^"]+"/, `local VERSION = "${nextVersion}"`)};
const syncedManifest = {...manifest, games: deriveGames(registry, changedMetadata)};
assert.equal(syncedManifest.games.AnimeVanguards.version, nextVersion);
validateProject(syncedManifest, status, registry, changedMetadata);
rejects(() => validateProject(manifest, status, registry, changedMetadata), 'metadata mismatch');
const betaManifest = {...manifest, releaseTier: 'beta', releaseGames: ['AnimeVanguards']};
validateReleaseScope(betaManifest, status);
const wronglyReady = clone(status);
wronglyReady.games.AnimeExpeditions.state = 'ready';
rejects(() => validateReleaseScope(betaManifest, wronglyReady), 'Ready game outside release scope');
rejects(() => validateReleaseScope({...betaManifest, releaseGames: ['AnimeVanguards', 'AnimeVanguards']}, status), 'Invalid release scope metadata');
const mixedPlaceMetadata = {...metadata, AnimeVanguards: metadata.AnimeVanguards.replace('placeIds = { 16146832113 }', 'placeIds = { 16146832113, "bad" }')};
rejects(() => validateProject(manifest, status, registry, mixedPlaceMetadata), 'Invalid game metadata Place ID');

const wrongVersion = clone(manifest);
wrongVersion.games.AnimeVanguards.version = '9.9.9';
rejects(() => validateProject(wrongVersion, status, registry, metadata), 'metadata mismatch');
const wrongPlace = clone(manifest);
wrongPlace.games.AnimeExpeditions.placeIds = [123];
rejects(() => validateProject(wrongPlace, status, registry, metadata), 'metadata mismatch');
const missingGame = clone(manifest);
delete missingGame.games.AnimeExpeditions;
rejects(() => validateProject(missingGame, status, registry, metadata), 'Invalid manifest games');
const malformedStatus = clone(status);
malformedStatus.games.AnimeVanguards.state = 'surprise';
rejects(() => validateProject(manifest, malformedStatus, registry, metadata), 'Invalid game status');
const changedSource = clone(manifest);
changedSource.games.AnimeVanguards.version = '9.9.9';
rejects(() => validateSourceManifest(changedSource, manifest), 'source field differs');
const publication = clone(manifest);
publication.artifactRevision = 'a'.repeat(40);
validateSourceManifest(publication, manifest);

const sha = 'a'.repeat(40);
const passed = {
    status: 'passed', sourceCommit: sha,
    artifactHashes: Object.fromEntries(Object.entries(manifest.artifacts).map(([id, a]) => [id, a.sha256])),
    runs: GAME_IDS.map(gameId => ({
        gameId, executor: 'Unlisted test runtime', status: 'passed', executorVersion: 'test fixture', clientVersion: 'test fixture',
        os: 'test fixture', testedAt: '2026-09-23T00:00:00Z', placeId: manifest.games[gameId].placeIds[0],
        checks: Object.fromEntries(REQUIRED_CHECKS.map(name => [name, {result: 'passed', observed: 'fixture observation'}])),
    })),
};
validateEvidence(passed, sha, manifest);
const betaOne = clone(passed);
betaOne.tier = 'beta';
betaOne.targetGames = ['AnimeVanguards'];
betaOne.limits = 'Potassium/Windows foundation only';
betaOne.runs.pop();
delete betaOne.runs[0].checks.rejoinPersistence;
delete betaOne.runs[0].checks.cleanup;
validateEvidence(betaOne, sha, manifest, {tier: 'beta', games: ['AnimeVanguards']});
rejects(() => validateEvidence(betaOne, sha, manifest, {tier: 'beta', games: ['AnimeExpeditions']}), 'scope differs');
rejects(() => validateEvidence(betaOne, sha, manifest, {tier: 'stable', games: ['AnimeVanguards']}), 'Stable release requires all');
const betaWithoutLimits = clone(betaOne);
delete betaWithoutLimits.limits;
rejects(() => validateEvidence(betaWithoutLimits, sha, manifest, {tier: 'beta', games: ['AnimeVanguards']}), 'limitations must be documented');
const betaMissingControl = clone(betaOne);
delete betaMissingControl.runs[0].checks.controls;
rejects(() => validateEvidence(betaMissingControl, sha, manifest, {tier: 'beta', games: ['AnimeVanguards']}), 'Incomplete runtime run');
const partial = clone(passed);
partial.status = 'partial';
rejects(() => validateEvidence(partial, sha, manifest), 'runtime evidence');
const missingRun = clone(passed);
missingRun.runs.pop();
rejects(() => validateEvidence(missingRun, sha, manifest), 'Missing runtime game coverage');
const duplicateRun = clone(passed);
duplicateRun.runs.push(clone(duplicateRun.runs[0]));
rejects(() => validateEvidence(duplicateRun, sha, manifest), 'Duplicate runtime run');
const unnamedExecutor = clone(passed);
unnamedExecutor.runs[0].executor = ' ';
rejects(() => validateEvidence(unnamedExecutor, sha, manifest), 'Invalid runtime run identity');
const missingCheck = clone(passed);
delete missingCheck.runs[0].checks.rejoinPersistence;
rejects(() => validateEvidence(missingCheck, sha, manifest), 'Incomplete runtime run');
const wrongHash = clone(passed);
wrongHash.artifactHashes.loader = 'b'.repeat(64);
rejects(() => validateEvidence(wrongHash, sha, manifest), 'artifact hashes differ');
console.log('PASS: release guard positive and negative cases');
