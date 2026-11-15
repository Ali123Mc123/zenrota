-- Characters on the client: loading screen, the framework's spawn events and its own spawn screen.
local shared = DL.require('chars/shared')
local adapter = (DL.require('fw/chars/' .. DL.fw.id) or DL.require('fw/chars/standalone')).client

local chars = { id = DL.fw.id }

-- Stops spawnmanager (and the framework) from spawning the player on their own.
function chars.boot()
    pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
    if adapter.boot then adapter.boot() end
end

-- Call it only once the product's own screen is ready behind a fade.
function chars.closeLoadingScreen()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    if adapter.closeLoadingScreen then adapter.closeLoadingScreen() end
end

-- The framework's post-spawn events; call once, after the ped is placed and dressed.
function chars.spawned(coords, isNew)
    adapter.spawned(coords, isNew == true)
    local at = shared.vec4(coords)
    TriggerEvent('playerSpawned', at and { x = at.x, y = at.y, z = at.z, heading = at.w } or {})
end

-- true: the framework's spawn screen took over and fires the load events, so do not call spawned.
function chars.handoff(citizenid, isNew)
    return adapter.handoff(citizenid, isNew == true) == true
end

-- Advisory only (ESX keeps cuffs on the client).
function chars.cuffed()
    return IsPedCuffed(PlayerPedId()) == true
end

function chars.conflicts()
    return adapter.conflicts and adapter.conflicts() or {}
end

return chars
