import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import {discoverGameIds, deriveGames, validateProject, validateReleaseScope, requireReleaseMode, GAME_IDS} from '../scripts/release-guards.mjs';

const root = path.resolve(import.meta.dirname, '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const manifest = JSON.parse(read('manifest.json'));
const status = JSON.parse(read('status.json'));
const registry = read('src/games/Registry.luau');
const metadata = Object.fromEntries(GAME_IDS.map(id => [id, read(`src/games/${id}/Metadata.luau`)]));
const clone = value => structuredClone(value);
const rejects = (fn, message) => assert.throws(fn, {message:new RegExp(message)});

assert.deepEqual(GAME_IDS, discoverGameIds());
const fixture = path.join(root, 'work', 'game-discovery-fixture');
fs.mkdirSync(path.join(fixture, 'SampleGame'), {recursive:true});
fs.writeFileSync(path.join(fixture, 'SampleGame', 'Metadata.luau'), '-- fixture only\n');
assert.deepEqual(discoverGameIds(fixture), ['SampleGame']);
const sampleSource = metadata[GAME_IDS[0]].replaceAll(GAME_IDS[0], 'SampleGame');
const sampleRegistry = 'return { require("./SampleGame/Metadata") }';
const sampleGames = deriveGames(sampleRegistry, {SampleGame:sampleSource}, ['SampleGame']);
const commentedUniverse = sampleSource.replace(/gameIds\s*=/, '-- gameIds = { 123 }\n    gameIds =');
assert.deepEqual(deriveGames(sampleRegistry, {SampleGame:commentedUniverse}, ['SampleGame']).SampleGame.gameIds,
    sampleGames.SampleGame.gameIds);
const duplicateIds = sampleSource.replace(/gameIds\s*=\s*\{[^}]+\}/,
    '$&\n    gameIds = { 123 }');
rejects(() => deriveGames(sampleRegistry, {SampleGame:duplicateIds}, ['SampleGame']), 'duplicate game metadata gameIds');
validateProject({schemaVersion:1,games:sampleGames},
    {schemaVersion:1,games:{SampleGame:{state:'disabled',reason:'fixture'}}},
    sampleRegistry, {SampleGame:sampleSource}, ['SampleGame']);

validateProject(manifest, status, registry, metadata);
const loaderVersion = read('src/bootstrap/Main.luau').match(/local LOADER_VERSION\s*=\s*"([^"]+)"/)?.[1];
assert.equal(manifest.version, loaderVersion);
assert.equal(manifest.loaderVersion, loaderVersion);
assert.equal(manifest.minLoaderVersion, loaderVersion);
for (const game of Object.values(manifest.games)) assert.equal(game.version, loaderVersion);
assert.deepEqual(deriveGames(registry, metadata), manifest.games);
const changedMetadata = {...metadata, [GAME_IDS[0]]:metadata[GAME_IDS[0]].replace(/local VERSION = "[^"]+"/, 'local VERSION = "9.9.9"')};
const syncedManifest = {...manifest, games:deriveGames(registry, changedMetadata)};
assert.equal(syncedManifest.games[GAME_IDS[0]].version, '9.9.9');
validateProject(syncedManifest, status, registry, changedMetadata);
rejects(() => validateProject(manifest, status, registry, changedMetadata), 'metadata mismatch');
rejects(() => deriveGames(registry.replace(`require("./${GAME_IDS[0]}/Metadata")`, ''), metadata), 'Registry games differ');

const wrongPlace = clone(manifest);
wrongPlace.games[GAME_IDS[0]].placeIds = [123];
rejects(() => validateProject(wrongPlace, status, registry, metadata), 'metadata mismatch');
const wrongUniverse = clone(manifest);
wrongUniverse.games[GAME_IDS[0]].gameIds = [123];
rejects(() => validateProject(wrongUniverse, status, registry, metadata), 'metadata mismatch');
const duplicateUniverse = {...metadata};
duplicateUniverse[GAME_IDS[1]] = metadata[GAME_IDS[1]].replace(/gameIds\s*=\s*\{[^}]+\}/,
    metadata[GAME_IDS[0]].match(/gameIds\s*=\s*\{[^}]+\}/)[0]);
rejects(() => deriveGames(registry, duplicateUniverse), 'duplicate Universe ID');
const missingGame = clone(manifest);
delete missingGame.games[GAME_IDS[0]];
rejects(() => validateProject(missingGame, status, registry, metadata), 'Invalid manifest games');
const malformedStatus = clone(status);
malformedStatus.games[GAME_IDS[0]].state = 'surprise';
rejects(() => validateProject(manifest, malformedStatus, registry, metadata), 'Invalid game status');

validateReleaseScope(manifest, status);
requireReleaseMode({...manifest, mode:'release'});
rejects(() => requireReleaseMode({...manifest, mode:'development'}), 'release-mode build');
const narrower = {...manifest, releaseGames:[GAME_IDS[0]]};
validateReleaseScope(narrower, status); // Operational ready state is independent of release metadata.
rejects(() => validateReleaseScope({...manifest, releaseGames:[GAME_IDS[0],GAME_IDS[0]]}, status), 'Invalid release scope');
rejects(() => validateReleaseScope({...manifest, releaseTier:'unknown'}, status), 'Invalid release scope');
const manifestTextPath = path.join(root, 'manifest.txt');
const manifestText = fs.readFileSync(manifestTextPath);
const fileRetry = operation => {
    for (let attempt = 0; attempt < 5; attempt++) {
        try { return operation(); }
        catch (error) {
            if (!['EBUSY', 'EPERM', 'UNKNOWN'].includes(error.code) || attempt === 4) throw error;
            Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 100);
        }
    }
};
try {
    fileRetry(() => fs.appendFileSync(manifestTextPath, 'tampered\n'));
    assert.throws(() => execFileSync('node', ['scripts/pipeline.mjs','verify'],
        {cwd:root,stdio:'pipe'}), error => error.stderr?.toString().includes('manifest.txt differs'));
} finally {
    fileRetry(() => fs.writeFileSync(manifestTextPath, manifestText));
}
console.log('PASS: dynamic game discovery and local release guards');
