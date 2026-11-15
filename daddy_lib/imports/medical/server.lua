-- The medical resource: reviving, healing and whether a player is down. From the daddy:medical convar, or
-- whichever is running. With none, revive and heal return false and the product heals on the client itself.
local ORDER = {
    { id = 'qbx', resource = 'qbx_medical' },
    { id = 'qb', resource = 'qb-ambulancejob' },
    { id = 'esx', resource = 'esx_ambulancejob' },
}

local function detect()
    local forced = GetConvar('daddy:medical', 'auto')
    if forced ~= 'auto' then return forced end
    for _, entry in ipairs(ORDER) do
        if GetResourceState(entry.resource) == 'started' then return entry.id end
    end
    return 'none'
end

local function qbPlayer(source)
    local ok, player = pcall(function()
        if GetResourceState('qbx_core') == 'started' then return exports.qbx_core:GetPlayer(source) end
        return exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
    end)
    return ok and player or nil
end

local function qbDown(source)
    local player = qbPlayer(source)
    local meta = player and player.PlayerData.metadata or {}
    return meta.isdead == true or meta.inlaststand == true
end

local ADAPTERS = {
    -- qbx_medical refills hunger and thirst on revive; a treatment should not, so they are put back.
    qbx = {
        down = function(source)
            local state = Player(source).state['qbx_medical:deathState']
            return (state ~= nil and state ~= 1) or qbDown(source)
        end,
        revive = function(source)
            local player = qbPlayer(source)
            local meta = player and player.PlayerData.metadata or {}
            local hunger, thirst = meta.hunger, meta.thirst
            exports.qbx_medical:Revive(source)
            if player and hunger and thirst then
                SetTimeout(800, function()
                    local again = qbPlayer(source)
                    if not again then return end
                    again.Functions.SetMetaData('hunger', hunger)
                    again.Functions.SetMetaData('thirst', thirst)
                    TriggerClientEvent('hud:client:UpdateNeeds', source, hunger, thirst)
                end)
            end
        end,
        heal = function(source) exports.qbx_medical:Heal(source, 'checkup') end,
    },
    qb = {
        down = qbDown,
        revive = function(source) TriggerClientEvent('hospital:client:Revive', source) end,
        heal = function(source) TriggerClientEvent('hospital:client:HealInjuries', source, 'full') end,
    },
    esx = {
        down = function(source) return Player(source).state.isDead == true end,
        revive = function(source) TriggerClientEvent('esx_ambulancejob:revive', source) end,
        heal = function(source) TriggerClientEvent('esx_ambulancejob:heal', source, 'big', true) end,
    },
}

local id = detect()
local adapter = ADAPTERS[id]
local medical = { id = id }

local function call(fn, source)
    if not adapter then return false end
    local ok, err = pcall(fn, source)
    if not ok then print(('^3[%s] medical %s: %s^7'):format(DL.resource, id, err)) end
    return ok
end

-- Down (dead or in last stand); without a medical resource, by the ped's health.
function medical.down(source)
    if adapter then
        local ok, down = pcall(adapter.down, source)
        if ok then return down == true end
    end
    local ped = GetPlayerPed(source)
    return ped ~= 0 and GetEntityHealth(ped) <= 100
end

function medical.revive(source) return call(adapter and adapter.revive, source) end
function medical.heal(source) return call(adapter and adapter.heal, source) end

return medical
