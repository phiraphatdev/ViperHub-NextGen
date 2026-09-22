--!strict
-- Purpose: read actual smoke-test state; Input: shared runtime session; Output: compact result; Dependencies: smoke harness.
local env: any = getfenv()
local session = env.shared and env.shared.ViperHubNextGen
if type(session) ~= "table" then
    return { present = false }
end
return {
    present = true,
    state = session.context.state,
    alive = session.context.alive,
    gameId = session.context.gameId,
    cleanupCount = session.context.cleanup.count(),
    diagnostics = session.diagnostics(),
    windowPresent = session.window ~= nil,
}
