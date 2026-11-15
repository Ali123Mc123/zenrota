-- Test bots on the client: an admin adds NPC players to the game they are in (/gamesbot [count], /gamesbot clear)
-- and their client spawns and moves those peds. Games.pedOf(id) finds a player's or a bot's ped for everyone, so
-- props, markers and darts follow bots like players.
local cfg = Config.Bots
local t = DL.locale.t
local mine = {} -- [id] = ped of a bot this client owns

function Games.pedOf(id)
    local bot = (GlobalState['daddy_campusgames:bots'] or {})[id]
    if bot then
        local entity = bot.net and NetworkDoesNetworkIdExist(bot.net) and NetworkGetEntityFromNetworkId(bot.net) or 0
        return entity ~= 0 and DoesEntityExist(entity) and entity or nil
    end
    local player = GetPlayerFromServerId(id)
    return player ~= -1 and GetPlayerPed(player) or nil
end

-- The ped of one of my bots (nil for anyone else), and all of them.
function Games.myBot(id) return mine[id] end
function Games.myBots() return mine end

-- A bot sits: on the floor (the picnic sit) or on a chair (the scenario); x, y, z is the ground spot.
function Games.botSit(ped, how, x, y, z, h)
    if how == 'table' then
        local chair = Config.Bottle.Chairs[1]
        for _, c in ipairs(Config.Bottle.Chairs) do
            if IsModelInCdimage(joaat(c.model)) then chair = c break end
        end
        return TaskStartScenarioAtPosition(ped, Config.Bottle.SitScenario, x, y, z + chair.seat, h, 0, true, true)
    end
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    SetEntityHeading(ped, h)
    local sit = Config.Bottle.Sit[IsPedMale(ped) and 'male' or 'female']
    if lib.requestAnimDict(sit.dict, 3000) then TaskPlayAnim(ped, sit.dict, sit.anim, 8.0, 4.0, -1, 1, 0.0, false, false, false) end
end

local function spawn(bot)
    local hash = joaat(cfg.Models[(bot.id % #cfg.Models) + 1])
    if not pcall(lib.requestModel, hash, 5000) then return end
    pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, hash, bot.x, bot.y, bot.z, bot.h or 0.0, true, true)
    SetModelAsNoLongerNeeded(hash)
    if not DoesEntityExist(ped) then return end
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedKeepTask(ped, true)
    SetEntityInvincible(ped, true)
    local net = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdCanMigrate(net, false)
    mine[bot.id] = ped
    if bot.sit then Games.botSit(ped, bot.sit, bot.x, bot.y, bot.z, bot.h or 0.0) end
    Games.call('bots:net', { id = bot.id, net = net })
end

local function remove(id)
    local ped = mine[id]
    mine[id] = nil
    if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
end

RegisterNetEvent('daddy_campusgames:bots:gone', remove)

-- The server walks a bot somewhere (the seeker after a hider).
RegisterNetEvent('daddy_campusgames:bots:go', function(id, x, y, z, speed)
    local ped = mine[id]
    if ped and DoesEntityExist(ped) then TaskGoStraightToCoord(ped, x, y, z, speed or 1.0, -1, 0.0, 0.5) end
end)

if cfg.Enabled and cfg.Command ~= '' then
    RegisterCommand(cfg.Command, function(_, args)
        CreateThread(function()
            if args[1] == 'clear' then
                Games.call('bots:clear')
                return Nui.notify('games.bot_cleared', 'success')
            end
            local result = Games.call('bots:add', { count = tonumber(args[1]) or 1 })
            if not result.ok then return Games.fail(result) end
            for _, bot in ipairs(result.bots or {}) do spawn(bot) end
            Nui.notify('games.bot_added', 'success', #(result.bots or {}))
        end)
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. cfg.Command, t('games.command_bots'), { { name = 'count | clear', help = t('games.command_bots_arg') } })
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for id in pairs(mine) do remove(id) end
end)
