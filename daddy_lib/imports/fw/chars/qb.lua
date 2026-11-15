-- qb characters through QBCore.Player Login, Logout and ForceDeleteCharacter.
local players = DL.require('fw/chars/players')

local core
local function qb()
    core = core or exports['qb-core']:GetCoreObject()
    return core
end

local function player(source)
    return qb().Functions.GetPlayer(source)
end

local function citizenOf(source)
    local p = player(source)
    return p and p.PlayerData.citizenid
end

-- The item info qb-multicharacter writes on the id card and the driver licence.
local function infoFor(item, citizenid, charinfo)
    if item == 'id_card' then
        return { citizenid = citizenid, firstname = charinfo.firstname, lastname = charinfo.lastname, birthdate = charinfo.birthdate, gender = charinfo.gender, nationality = charinfo.nationality }
    end
    if item == 'driver_license' then
        return { firstname = charinfo.firstname, lastname = charinfo.lastname, birthdate = charinfo.birthdate, type = 'Class C Driver License' }
    end
end

local function starterItems(source, citizenid, charinfo)
    local list = {}
    for _, entry in pairs(qb().Shared.StarterItems or {}) do
        list[#list + 1] = { name = entry.item, amount = entry.amount, metadata = infoFor(entry.item, citizenid, charinfo) }
    end
    players.starter(source, list)
end

return {
    server = {
        caps = { nationality = true, height = true, bio = true, phone = true, gang = true },

        owners = function(source) return players.owners(source, { 'license' }) end,
        list = players.list,
        get = players.get,
        owner = players.owner,
        loaded = citizenOf,

        -- qb has no double-login guard of its own, so the loaded check matters here.
        create = function(source, slot, identity, opts)
            if player(source) then return nil, 'loaded' end
            local charinfo = players.charinfo(slot, identity)
            pcall(function() qb().Player.Login(source, false, { cid = slot, charinfo = charinfo }) end)
            local citizenid = citizenOf(source)
            if not citizenid then return nil, 'failed' end
            pcall(qb().Commands.Refresh, source)
            if opts.starterItems ~= false then starterItems(source, citizenid, charinfo) end
            return citizenid
        end,

        login = function(source, citizenid)
            if player(source) then return nil, 'loaded' end
            pcall(function() qb().Player.Login(source, citizenid) end)
            if citizenOf(source) ~= citizenid then return nil, 'failed' end
            pcall(qb().Commands.Refresh, source)
            return true
        end,

        logout = function(source)
            pcall(function() qb().Player.Logout(source) end)
            if players.waitFor(function() return player(source) == nil end, 3000) then return true end
            return nil, 'timeout'
        end,

        -- ForceDeleteCharacter runs an async transaction over qb's own player tables.
        delete = function(citizenid, extra)
            if not pcall(function() qb().Player.ForceDeleteCharacter(citizenid) end) then return nil, 'failed' end
            return players.finishDelete(citizenid, extra)
        end,

        status = function(source)
            local p = player(source)
            return players.status(p and p.PlayerData.metadata)
        end,

        vehicle = players.vehicle,

        conflicts = function()
            if GetResourceState('qb-multicharacter') ~= 'started' then return {} end
            return { { level = 'error', code = 'qb_multicharacter', text = 'qb-multicharacter is running and opens its own selection: stop it and remove it from server.cfg' } }
        end,
    },

    client = {
        -- qb-core answers the server event with the client one.
        spawned = function()
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            players.leaveHomes()
        end,

        -- qb-apartments opens qb-spawn itself; without it, qb-spawn is opened directly.
        handoff = function(citizenid)
            local data = { citizenid = citizenid }
            if GetResourceState('qb-apartments') == 'started' then
                TriggerEvent('apartments:client:setupSpawnUI', data)
                return true
            end
            if GetResourceState('qb-spawn') ~= 'started' then return false end
            TriggerEvent('qb-spawn:client:setupSpawns', data, false, nil)
            TriggerEvent('qb-spawn:client:openUI', true)
            return true
        end,
    },
}
