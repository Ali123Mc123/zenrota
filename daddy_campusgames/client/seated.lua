-- Seated games on the client (Taboo, Who Am I): each place's rug or table with its chairs (and the game's own props
-- on it), sitting down on the free seat nearest to you, G up and back down, X out, and before the game starts E for
-- the sign-up sheet. A game adds its line and keys:
--   Seated.game(kind, { label, icon, view, seats, line = fn() -> text, frame = fn(), props = fn(record, top) -> list })
local Seats = GameRules.seats
local cfg = Config.Seating
local t = DL.locale.t
Seated = { me = nil } -- me = { id, uid, kind, venue, shape, seat, max, up }
local games, props = {}, {}

local function first(list)
    for _, item in ipairs(list or {}) do
        if IsModelInCdimage(joaat(type(item) == 'table' and item.model or item)) then return item end
    end
end

local function chairModel() return first(Config.Bottle.Chairs) or Config.Bottle.Chairs[1] end

local function maxOf(record)
    local game = games[record.kind]
    local most = game.seats[Seats.shape(record.settings)]
    return math.max(2, math.min(math.floor(tonumber((record.settings or {}).seats) or most), most))
end

-- The props of a place ---------------------------------------------------------------------------------------------

local function spawnProp(model, x, y, z, heading, pitch)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 3000) then return nil end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = CreateObjectNoOffset(hash, x, y, z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    SetEntityRotation(entity, pitch or 0.0, 0.0, heading % 360, 2, false)
    FreezeEntityPosition(entity, true)
    return entity
end

-- The chairs round a table, and what the game puts on it (top = the table top's height above the ground).
local function furnish(record)
    local c, shape, n = record.coords, Seats.shape(record.settings), maxOf(record)
    local set, desk = { entities = {} }, cfg.Tables[shape] and first(cfg.Tables[shape])
    if desk then
        local chair = chairModel()
        for i = 1, n do
            local x, y, h = Seats.pose(shape, i, n, c)
            set.entities[#set.entities + 1] = spawnProp(chair.model, x, y, c.z, h + 180.0 + chair.heading)
        end
    end
    local game = games[record.kind]
    for _, p in ipairs(game.props and game.props(record, desk and desk.top or 0.0) or {}) do
        set.entities[#set.entities + 1] = spawnProp(p.model, p.x, p.y, p.z, p.h or c.w or 0.0, p.pitch)
        if p.key then set[p.key] = set.entities[#set.entities] end
    end
    return set
end

local function clear(uid)
    local set = props[uid]
    props[uid] = nil
    for _, entity in pairs(set and set.entities or {}) do
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    end
end

-- A place's prop the game named (key), when it is near.
function Seated.prop(uid, key) return props[uid] and props[uid][key] end

CreateThread(function()
    while true do
        local me, near = GetEntityCoords(cache.ped), {}
        for kind in pairs(games) do
            for _, record in ipairs(Games.places(kind)) do
                local c = record.coords
                if record.active ~= false and #(me - vector3(c.x, c.y, c.z)) < Config.StreamDistance then
                    local key = ('%s:%s:%s'):format(record.revision or 0, Seats.shape(record.settings), maxOf(record))
                    near[record.uid] = true
                    if not props[record.uid] or props[record.uid].key ~= key then
                        clear(record.uid)
                        props[record.uid] = furnish(record)
                        props[record.uid].key = key
                    end
                end
            end
        end
        for uid in pairs(props) do
            if not near[uid] then clear(uid) end
        end
        -- nothing to keep near: look again less often
        Wait(next(props) and 1000 or 2500)
    end
end)

-- Sitting --------------------------------------------------------------------------------------------------------------

local function pose()
    local me = Seated.me
    return Seats.pose(me.shape, me.seat, me.max, me.venue)
end

local function sitDown()
    local me = Seated.me
    if not me then return end
    local x, y, h = pose()
    if me.shape == 'floor' then return Games.botSit(cache.ped, 'floor', x, y, me.venue.z, h) end
    local chair = chairModel()
    local r = math.rad(h)
    TaskStartScenarioAtPosition(cache.ped, Config.Bottle.SitScenario, x + math.sin(r) * chair.back, y - math.cos(r) * chair.back,
        me.venue.z + chair.seat, h, 0, true, true)
end

-- Out of the game; tell is false when the server already took me out.
function Seated.leave(tell)
    if not Seated.me then return end
    local game = games[Seated.me.kind]
    Seated.me = nil
    lib.hideTextUI()
    if Nui.isOpen('games.lobby') or (game.view and Nui.isOpen(game.view)) then Nui.close() end -- never the result sheet
    ClearPedTasks(cache.ped)
    if tell then CreateThread(function() Games.call('seated:stand') end) end
end

local function up()
    Seated.me.up = true
    ClearPedTasks(cache.ped)
end

local function back()
    local x, y = pose()
    if #(GetEntityCoords(cache.ped).xy - vector2(x, y)) > cfg.SitReach then return Nui.notify('seat.go_back', 'error') end
    Seated.me.up = false
    sitDown()
end

-- My line on screen and the keys: E the sheet before the start, the game's own keys after; G up and down; X out.
local function loop()
    local shown, joined = nil, false
    while Seated.me do
        local me = Seated.me
        if Games.lobby then joined = true elseif joined then Seated.leave(false) break end
        local lobby = Games.lobby and Games.lobby.state == 'lobby'
        local game = games[me.kind]
        local line = lobby and t('seat.lobby_key') or game.line and game.line() or nil
        local keys = t(me.up and 'seat.keys_up' or 'seat.keys_seated')
        local text = line and (line .. ' · ' .. keys) or keys
        if shown ~= text then lib.showTextUI(text) shown = text end
        if not Nui.isOpen() then
            if lobby and IsControlJustPressed(0, 38) then CreateThread(Games.openLobby) end
            if not lobby and game.frame then game.frame() end
            if IsControlJustPressed(0, 47) then if me.up then back() else up() end end
            if IsControlJustPressed(0, 73) then Seated.leave(true) end
        end
        if not me.up and IsPedRagdoll(cache.ped) then me.up = true end -- knocked over: up, the seat stays
        local v = me.venue
        local far = #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z))
        if far > (me.up and cfg.UpRange or Seats.reach(me.shape, me.max) + 4.0) then
            Nui.notify('seat.too_far', 'error')
            Seated.leave(true)
        elseif me.up then
            local x, y = pose()
            DrawMarker(2, x, y, v.z + 0.7, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, 240, 200, 60, 200, true, true, 2, false, nil, nil, false)
        end
        Wait(0)
    end
    lib.hideTextUI()
end

-- A seated game: its place kind, seats per shape (its config), its line, keys and table props.
function Seated.game(kind, def)
    def.seats = def.seats or { floor = 10, table = 6, long = 8 }
    games[kind] = def
    Games.kind(kind, function(record)
        local shape = Seats.shape(record.settings)
        local look = shape == 'floor' and (record.settings or {}).rug ~= false and first(cfg.Rugs) or cfg.Tables[shape] and first(cfg.Tables[shape])
        local model = look and (type(look) == 'table' and look.model or look) or nil
        local c = record.coords
        return {
            presentation = model and 'prop' or 'point', model = model, distance = Seats.reach(shape, maxOf(record)) + 1.5,
            targetSphere = shape == 'floor' and { radius = Seats.reach(shape, maxOf(record)) + 0.3, height = 0.25 } or nil,
            options = { {
                name = 'seated_sit', label = t('seat.sit', t(def.label)), icon = def.icon,
                canInteract = function() return Games.free() and not Games.lobby and not Seated.me end,
                onSelect = function() CreateThread(function()
                    local result = Games.call('seated:sit', { venue = record.uid })
                    if not result.ok then return Games.fail(result) end
                    local seat
                    for _, s in ipairs(result.seats or {}) do
                        if s.id == cache.serverId then seat = s.seat end
                    end
                    Seated.me = { id = result.id, uid = record.uid, kind = kind, shape = shape, seat = seat or 1, max = maxOf(record), up = false,
                        venue = { uid = record.uid, x = c.x, y = c.y, z = c.z, w = c.w, h = c.w } }
                    sitDown()
                    CreateThread(loop)
                end) end,
            } },
        }
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for uid in pairs(props) do clear(uid) end
    if Seated.me then ClearPedTasks(cache.ped) end
    lib.hideTextUI()
end)
