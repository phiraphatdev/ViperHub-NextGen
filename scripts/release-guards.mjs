// Release invariants are deliberately independent of Roblox and third-party packages.
export const GAME_IDS = ['AnimeVanguards', 'AnimeExpeditions'];
export const REQUIRED_CHECKS = ['startup', 'ui', 'controls', 'configReadback', 'rejoinPersistence', 'cleanup'];
export const BETA_CHECKS = ['startup', 'ui', 'controls', 'configReadback'];
const SHA = /^[a-f0-9]{40}$/;
const HASH = /^[a-f0-9]{64}$/;
const DATE = /^\d{4}-\d{2}-\d{2}$/;
const fail = message => { throw Error(message); };
const record = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const keysEqual = (value, expected) => record(value) && Object.keys(value).sort().join(',') === [...expected].sort().join(',');

export function readMetadata(source) {
    const field = name => source.match(new RegExp(`\\b${name}\\s*=\\s*"([^"]+)"`))?.[1];
    const id = field('id');
    const name = field('name');
    const version = source.match(/local VERSION\s*=\s*"([^"]+)"/)?.[1];
    const lastUpdated = source.match(/local LAST_UPDATED\s*=\s*"([^"]+)"/)?.[1];
    const places = source.match(/placeIds\s*=\s*\{([^}]+)\}/)?.[1];
    const placeIds = places?.split(',').map(s => {
        const token = s.trim();
        if (!/^[1-9]\d*$/.test(token)) fail('Invalid game metadata Place ID');
        const id = Number(token);
        if (!Number.isSafeInteger(id)) fail('Invalid game metadata Place ID');
        return id;
    });
    if (!id || !name || !version || !lastUpdated || !DATE.test(lastUpdated) || !placeIds?.length || new Set(placeIds).size !== placeIds.length)
        fail('Invalid game metadata source');
    return {id, name, version, lastUpdated, placeIds};
}

export function deriveGames(registrySource, metadata) {
    const registryEntries = [...registrySource.matchAll(/require\("\.\/(\w+)\/Metadata"\)/g)].map(m => m[1]);
    if (registryEntries.length !== GAME_IDS.length || new Set(registryEntries).size !== GAME_IDS.length ||
        registryEntries.some(id => !GAME_IDS.includes(id))) fail('Registry games differ from manifest');
    const allPlaces = new Set();
    const games = {};
    for (const id of GAME_IDS) {
        const game = readMetadata(metadata[id]);
        if (game.id !== id) fail('Game metadata mismatch: ' + id);
        for (const placeId of game.placeIds) {
            if (allPlaces.has(placeId)) fail('Invalid or duplicate Place ID: ' + id);
            allPlaces.add(placeId);
        }
        games[id] = {version: game.version, lastUpdated: game.lastUpdated, name: game.name, placeIds: game.placeIds};
    }
    return games;
}

export function validateProject(manifest, status, registrySource, metadata) {
    if (!record(manifest) || manifest.schemaVersion !== 1 || !keysEqual(manifest.games, GAME_IDS)) fail('Invalid manifest games');
    if (!record(status) || status.schemaVersion !== 1 || !keysEqual(status.games, GAME_IDS)) fail('Invalid status games');
    const games = deriveGames(registrySource, metadata);
    for (const id of GAME_IDS) {
        const game = games[id];
        const manifestGame = manifest.games[id];
        if (!record(manifestGame) || manifestGame.version !== game.version || manifestGame.lastUpdated !== game.lastUpdated ||
            manifestGame.name !== game.name || JSON.stringify(manifestGame.placeIds) !== JSON.stringify(game.placeIds)) fail('Game metadata mismatch: ' + id);
        const state = status.games[id];
        if (!record(state) || !['disabled', 'maintenance', 'ready'].includes(state.state) || typeof state.reason !== 'string' || !state.reason.trim()) fail('Invalid game status: ' + id);
    }
}

export function validateSourceManifest(current, source) {
    if (!record(source) || !record(current)) fail('Invalid source manifest');
    // B may set artifactRevision and status; build-owned hashes/mode/sourceCommit may change in A.
    for (const field of ['schemaVersion', 'version', 'loaderVersion', 'minLoaderVersion', 'repository', 'games']) {
        if (JSON.stringify(current[field]) !== JSON.stringify(source[field])) fail('Manifest source field differs: ' + field);
    }
}

export function validateReleaseScope(manifest, status) {
    const tier = manifest?.releaseTier;
    const games = manifest?.releaseGames;
    if (!['beta', 'stable'].includes(tier) || !Array.isArray(games) || !games.length ||
        new Set(games).size !== games.length || games.some(id => !GAME_IDS.includes(id)) ||
        (tier === 'stable' && games.length !== GAME_IDS.length)) fail('Invalid release scope metadata');
    if (!record(status?.games)) fail('Invalid release status');
    for (const id of GAME_IDS) if (status.games[id]?.state === 'ready' && !games.includes(id)) fail('Ready game outside release scope: ' + id);
}

export function validateEvidence(evidence, sourceCommit, manifest, options = {}) {
    const tier = options.tier ?? 'stable';
    const targetGames = options.games ?? GAME_IDS;
    if (!['beta', 'stable'].includes(tier) || !Array.isArray(targetGames) || !targetGames.length ||
        new Set(targetGames).size !== targetGames.length || targetGames.some(gameId => !GAME_IDS.includes(gameId))) fail('Invalid release scope');
    if (tier === 'stable' && targetGames.length !== GAME_IDS.length) fail('Stable release requires all registered games');
    const requiredChecks = tier === 'beta' ? BETA_CHECKS : REQUIRED_CHECKS;
    if (!record(evidence) || evidence.status !== 'passed' || evidence.sourceCommit !== sourceCommit || !SHA.test(sourceCommit)) fail('Current-source runtime evidence is required');
    if ((evidence.tier ?? 'stable') !== tier || (evidence.targetGames && JSON.stringify(evidence.targetGames) !== JSON.stringify(targetGames))) fail('Runtime evidence scope differs');
    if (tier === 'beta' && (typeof evidence.limits !== 'string' || !evidence.limits.trim())) fail('Beta limitations must be documented');
    if (!record(evidence.artifactHashes) || Object.entries(manifest.artifacts).some(([id, a]) => evidence.artifactHashes[id] !== a.sha256 || !HASH.test(a.sha256))) fail('Runtime artifact hashes differ');
    if (!Array.isArray(evidence.runs)) fail('Runtime evidence runs are required');
    const coveredGames = new Set();
    const seenRuns = new Set();
    for (const run of evidence.runs) {
        if (!record(run) || !GAME_IDS.includes(run.gameId) || typeof run.executor !== 'string' || !run.executor.trim()) fail('Invalid runtime run identity');
        const identity = run.gameId + '/' + run.executor;
        if (seenRuns.has(identity)) fail('Duplicate runtime run: ' + identity);
        seenRuns.add(identity);
        coveredGames.add(run.gameId);
        if (run.status !== 'passed' || typeof run.executorVersion !== 'string' || !run.executorVersion.trim() ||
            typeof run.clientVersion !== 'string' || !run.clientVersion.trim() || typeof run.os !== 'string' || !run.os.trim() ||
            typeof run.testedAt !== 'string' || !Number.isFinite(Date.parse(run.testedAt)) ||
            !manifest.games[run.gameId].placeIds.includes(run.placeId) || !record(run.checks) || requiredChecks.some(check => !run.checks[check])) fail('Incomplete runtime run: ' + identity);
        for (const check of requiredChecks) {
            const item = run.checks[check];
            if (!record(item) || item.result !== 'passed' || typeof item.observed !== 'string' || !item.observed.trim()) fail('Incomplete runtime check: ' + identity + '/' + check);
        }
    }
    if (targetGames.some(gameId => !coveredGames.has(gameId))) fail('Missing runtime game coverage');
}
