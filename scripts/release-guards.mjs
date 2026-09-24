// Local project checks do not depend on Git history or runtime evidence files.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const DATE = /^\d{4}-\d{2}-\d{2}$/;
const fail = message => { throw Error(message); };
const record = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const keysEqual = (value, expected) => record(value) && Object.keys(value).sort().join(',') === [...expected].sort().join(',');

export function discoverGameIds(directory = path.join(root, 'src/games')) {
    return fs.readdirSync(directory, {withFileTypes:true})
        .filter(entry => entry.isDirectory() && /^[A-Za-z][A-Za-z0-9_]*$/.test(entry.name) &&
            fs.existsSync(path.join(directory, entry.name, 'Metadata.luau')))
        .map(entry => entry.name).sort();
}

export const GAME_IDS = discoverGameIds();

export function readMetadata(source) {
    if (typeof source !== 'string') fail('Invalid game metadata source');
    const single = (pattern, label) => {
        const matches = [...source.matchAll(pattern)];
        if (matches.length !== 1) fail('Invalid or duplicate game metadata ' + label);
        return matches[0][1];
    };
    const field = name => single(new RegExp(`^[ \\t]*${name}[ \\t]*=[ \\t]*"([^"]+)"`, 'gm'), name);
    const id = field('id');
    const name = field('name');
    const version = single(/^[ \t]*local VERSION[ \t]*=[ \t]*"([^"]+)"/gm, 'VERSION');
    const lastUpdated = single(/^[ \t]*local LAST_UPDATED[ \t]*=[ \t]*"([^"]+)"/gm, 'LAST_UPDATED');
    const ids = (fieldName, required) => {
        const assignments = [...source.matchAll(new RegExp(`^[ \\t]*${fieldName}[ \\t]*=`, 'gm'))];
        if (!assignments.length && !required) return undefined;
        if (assignments.length !== 1) fail('Invalid or duplicate game metadata ' + fieldName);
        const match = source.match(new RegExp(`^[ \\t]*${fieldName}[ \\t]*=[ \\t]*\\{([^}]+)\\}`, 'm'));
        if (!match) fail('Invalid game metadata ' + fieldName);
        return match[1].split(',').map(s => {
            const token = s.trim();
            if (!/^[1-9]\d*$/.test(token)) fail('Invalid game metadata ID');
            const value = Number(token);
            if (!Number.isSafeInteger(value)) fail('Invalid game metadata ID');
            return value;
        });
    };
    const placeIds = ids('placeIds', true);
    const gameIds = ids('gameIds', false);
    if (!id || !name || !version || !lastUpdated || !DATE.test(lastUpdated) || !placeIds?.length ||
        new Set(placeIds).size !== placeIds.length || (gameIds && (!gameIds.length || new Set(gameIds).size !== gameIds.length)))
        fail('Invalid game metadata source');
    return {id, name, version, lastUpdated, placeIds, ...(gameIds ? {gameIds} : {})};
}

export function deriveGames(registrySource, metadata, gameIds = GAME_IDS) {
    const registryEntries = [...registrySource.matchAll(/require\("\.\/(\w+)\/Metadata"\)/g)].map(m => m[1]);
    if (!gameIds.length || registryEntries.length !== gameIds.length ||
        new Set(registryEntries).size !== gameIds.length || registryEntries.some(id => !gameIds.includes(id)))
        fail('Registry games differ from discovered games');
    const allPlaces = new Set();
    const allUniverses = new Set();
    const games = {};
    for (const id of gameIds) {
        const game = readMetadata(metadata[id]);
        if (game.id !== id) fail('Game metadata mismatch: ' + id);
        for (const placeId of game.placeIds) {
            if (allPlaces.has(placeId)) fail('Invalid or duplicate Place ID: ' + id);
            allPlaces.add(placeId);
        }
        for (const gameId of game.gameIds || []) {
            if (allUniverses.has(gameId)) fail('Invalid or duplicate Universe ID: ' + id);
            allUniverses.add(gameId);
        }
        games[id] = {version:game.version, lastUpdated:game.lastUpdated, name:game.name, placeIds:game.placeIds,
            ...(game.gameIds ? {gameIds:game.gameIds} : {})};
    }
    return games;
}

export function validateProject(manifest, status, registrySource, metadata, gameIds = GAME_IDS) {
    if (!record(manifest) || manifest.schemaVersion !== 1 || !keysEqual(manifest.games, gameIds)) fail('Invalid manifest games');
    if (!record(status) || status.schemaVersion !== 1 || !keysEqual(status.games, gameIds)) fail('Invalid status games');
    const games = deriveGames(registrySource, metadata, gameIds);
    for (const id of gameIds) {
        const game = games[id];
        const manifestGame = manifest.games[id];
        if (!record(manifestGame) || manifestGame.version !== game.version || manifestGame.lastUpdated !== game.lastUpdated ||
            manifestGame.name !== game.name || JSON.stringify(manifestGame.placeIds) !== JSON.stringify(game.placeIds) ||
            JSON.stringify(manifestGame.gameIds) !== JSON.stringify(game.gameIds))
            fail('Game metadata mismatch: ' + id);
        const state = status.games[id];
        if (!record(state) || !['disabled','maintenance','ready'].includes(state.state) ||
            typeof state.reason !== 'string' || !state.reason.trim()) fail('Invalid game status: ' + id);
    }
}

export function validateReleaseScope(manifest, status, gameIds = GAME_IDS) {
    if (!record(manifest) || !record(status?.games)) fail('Invalid release scope metadata');
    if (manifest.releaseTier !== undefined && !['beta','stable'].includes(manifest.releaseTier)) fail('Invalid release scope metadata');
    if (manifest.releaseGames !== undefined && (!Array.isArray(manifest.releaseGames) ||
        new Set(manifest.releaseGames).size !== manifest.releaseGames.length ||
        manifest.releaseGames.some(id => !gameIds.includes(id)))) fail('Invalid release scope metadata');
}

export function requireReleaseMode(manifest) {
    if (manifest?.mode !== 'release') fail('Release verification requires a release-mode build');
}
