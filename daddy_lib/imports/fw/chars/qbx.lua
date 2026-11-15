-- qbx characters through qbx_core's Login, Logout and DeleteCharacter exports, never its menu callbacks.
local players = DL.require('fw/chars/players')
local config = DL.require('fw/chars/config')

local function player(source)
    return exports.qbx_core:GetPlayer(source)
end

local function citizenOf(source)
    local p = player(source)
    return p and p.PlayerData.citizenid
end

-- qbx_core's own starterItems, given once the inventory has loaded.
local function starterItems(source)
    local shared = config.read('qbx_core', 'config/shared.lua')
    players.starter(source, shared and shared.starterItems or {})
end

return {
    server = {
        caps = { nationality = true, height = true, bio = true, phone = true, gang = true },

        owners = function(source) return players.owners(source, { 'license2', 'license' }) end,
        list = players.list,
        get = players.get,
        owner = players.owner,
        loaded = citizenOf,

        -- Login with new data skips qbx's slot limit; the lib already picked the index.
        create = function(source, slot, identity, opts)
            if player(source) then return nil, 'loaded' end
            local data = { cid = slot, charinfo = players.charinfo(slot, identity) }
            pcall(function() exports.qbx_core:Login(source, false, data) end)
            local citizenid = citizenOf(source)
            if not citizenid then return nil, 'failed' end
            if opts.starterItems ~= false then starterItems(source) end
            return citizenid
        end,

        -- Login drops a player who is already loaded or not the owner; the wrapper checked both.
        login = function(source, citizenid)
            if player(source) then return nil, 'loaded' end
            pcall(function() exports.qbx_core:Login(source, citizenid) end)
            if citizenOf(source) == citizenid then return true end
            return nil, 'failed'
        end,

        -- Logout saves, waits 200 ms and only then clears the player.
        logout = function(source)
            pcall(function() exports.qbx_core:Logout(source) end)
            if players.waitFor(function() return player(source) == nil end, 3000) then return true end
            return nil, 'timeout'
        end,

        -- The DeleteCharacter export is ForceDelete: a thread over qbx's characterDataTables.
        delete = function(citizenid, extra)
            if not pcall(function() exports.qbx_core:DeleteCharacter(citizenid) end) then return nil, 'failed' end
            return players.finishDelete(citizenid, extra)
        end,

        status = function(source)
            local p = player(source)
            return players.status(p and p.PlayerData.metadata)
        end,

        vehicle = players.vehicle,

        conflicts = function()
            local out = {}
            local client = config.read('qbx_core', 'config/client.lua') or {}
            local characters = client.characters or {}
            if characters.useExternalCharacters ~= true then
                out[#out + 1] = { level = 'error', code = 'qbx_external_characters', text = 'qbx_core still runs its own character menu: set characters.useExternalCharacters = true in qbx_core/config/client.lua' }
            end
            if characters.startingApartment == true and GetResourceState('qbx_properties') == 'started' then
                out[#out + 1] = { level = 'error', code = 'qbx_starting_apartment', text = 'qbx_properties opens its apartment picker on every login: set characters.startingApartment = false in qbx_core/config/client.lua' }
            end
            return out
        end,
    },

    client = {
        -- qbx's server event only sets isLoggedIn, so the client event is fired here too.
        spawned = function()
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            players.leaveHomes()
        end,

        -- qbx_spawn needs the player logged in and fires both load events itself.
        handoff = function()
            if GetResourceState('qbx_spawn') ~= 'started' then return false end
            TriggerEvent('qb-spawn:client:setupSpawns')
            return true
        end,
    },
}
