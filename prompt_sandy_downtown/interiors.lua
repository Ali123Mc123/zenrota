-- Downtown interior swap.
-- Every slot has up to three placements of the same interior (vanilla GTA
-- archetype, our mirrored archetype with private collision, optional custom
-- interior from another resource). All are script IPLs, but GTA still streams
-- the collision of the non-requested ones, so each unwanted interior is
-- explicitly despawned: load it -> DisableInterior frees its collision ->
-- remove the placement. Run once at startup -- you spawn far from downtown,
-- so nothing is pinned and collision frees cleanly -- and again whenever a
-- custom resource starts/stops. No polling.

local PREFIX = '^5[Downtown Interiors]^7'
local state  = {} -- name -> 'custom' | 'mirror' | 'vanilla'

local function log(msg)
    if Config.Debug then print(('%s %s'):format(PREFIX, msg)) end
end

local function wantCustom(slot)
    if not slot.customIpl then return false end
    if slot.forceUseCustom ~= nil then return slot.forceUseCustom end
    return GetResourceState(slot.customResource) == 'started'
end

local function pick(slot)
    if wantCustom(slot) then return 'custom' end
    return slot.defaultInterior == 'vanilla' and 'vanilla' or 'mirror'
end

-- placement ymaps + archetype of each variant
local function variant(slot, which)
    if which == 'vanilla' then return slot.ipls, slot.gtaType end
    if which == 'mirror'  then return { slot.mirrorIpl }, slot.mirrorType end
    return { slot.customIpl }, slot.customType
end

-- RequestIpl the placement, then wait for the interior to actually resolve
-- (these interiors aren't reliably loaded until requested -- that's why a cold
-- lookup returns 0).
local function loadAndFind(slot, ipls, mloType)
    for _, ipl in ipairs(ipls) do RequestIpl(ipl) end
    local id = 0
    for _ = 1, 20 do
        id = GetInteriorAtCoordsWithType(slot.coords.x, slot.coords.y, slot.coords.z, mloType)
        if id ~= 0 then break end
        Wait(50)
    end
    return id
end

-- load + despawn one variant (visual + collision)
local function despawn(slot, which)
    local ipls, mloType = variant(slot, which)
    if which == 'custom' then
        for _, ipl in ipairs(ipls) do RemoveIpl(ipl) end
        return
    end
    local id = loadAndFind(slot, ipls, mloType)
    if id ~= 0 then
        UnpinInterior(id)
        DisableInterior(id, true)
        RefreshInterior(id)
        log(('   despawned %s %s interior=%d disabled=%s'):format(which, mloType, id, tostring(IsInteriorDisabled(id))))
    else
        log(('   WARNING: %s %s interior not found, nothing to despawn'):format(which, mloType))
    end
    for _, ipl in ipairs(ipls) do RemoveIpl(ipl) end
end

local function spawn(slot, which)
    local ipls, mloType = variant(slot, which)
    if which == 'custom' then
        for _, ipl in ipairs(ipls) do RequestIpl(ipl) end
        log(('   spawned custom %s active=%s'):format(ipls[1], tostring(IsIplActive(ipls[1]))))
        return
    end
    local id = loadAndFind(slot, ipls, mloType)
    if id ~= 0 and IsInteriorDisabled(id) then
        DisableInterior(id, false)
        RefreshInterior(id)
    end
    log(('   %s %s interior=%d shown'):format(which, mloType, id))
end

local function applySlot(name, slot)
    local want = pick(slot)
    log(('%s -> %s'):format(name, want:upper()))
    for _, which in ipairs({ 'vanilla', 'mirror', 'custom' }) do
        if which ~= want and (which ~= 'custom' or slot.customIpl) then
            despawn(slot, which)
        end
    end
    spawn(slot, want)
    state[name] = want
end

-- startup pass, once the player is in the world
CreateThread(function()
    if not Config.Enabled then log('Config.Enabled = false, auto swap skipped'); return end
    while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
    Wait(1500) -- let the world settle
    log('startup: applying swap for all slots')
    for name, slot in pairs(Config.Slots) do applySlot(name, slot) end
    log('startup: complete')
end)

-- react to a custom resource starting/stopping (handles it loading BEFORE or
-- AFTER this map, and stop/restart). onClientResourceStart/Stop fire for every
-- resource, so we filter to the ones we care about.
local function onResChange(res)
    if not Config.Enabled then return end
    for name, slot in pairs(Config.Slots) do
        if slot.customResource and res == slot.customResource then
            CreateThread(function()
                Wait(1000) -- let the resource's assets register/unregister
                log(('resource %s changed (%s) -> re-applying %s'):format(res, GetResourceState(res), name))
                applySlot(name, slot)
            end)
        end
    end
end
AddEventHandler('onClientResourceStart', onResChange)
AddEventHandler('onClientResourceStop', onResChange)
