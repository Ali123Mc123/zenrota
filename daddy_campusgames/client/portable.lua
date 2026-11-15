-- Games from items on the client: a used party item sets its game up on the ground a step in front of the player
-- (the light facing the way they look). Places set up by others show like any placed one (Games.places).
local cfg = Config.Items
local t = DL.locale.t

-- The ground `ahead` metres in front of the player, and their heading.
local function spot(ahead)
    local c, h = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)
    local r = math.rad(h)
    local x, y = c.x - math.sin(r) * ahead, c.y + math.cos(r) * ahead
    local found, z = GetGroundZFor_3dCoord(x, y, c.z + 1.0, false)
    return x, y, found and z or c.z - 0.98, h
end

RegisterNetEvent('daddy_campusgames:portable:setup', function(game)
    local setup = cfg.Setup[game]
    if not setup then return end
    if not Games.free() then return Nui.notify('games.not_now', 'error') end
    local x, y, z, h = spot(setup.ahead or 0.0)
    local result = Games.call('portable:place', { game = game, x = x, y = y, z = z, h = (h + (setup.turn or 0.0)) % 360 })
    if not result.ok then return Games.fail(result) end
    lib.notify({ description = t('games.party_set', t('games.game_' .. game)), type = 'success' })
end)
