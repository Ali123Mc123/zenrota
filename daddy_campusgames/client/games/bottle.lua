-- Spin the bottle on the client: the rug or the table and chairs at every place near, the bottle lying on it, sitting
-- down, the spin every nearby client plays the same way, the arrow over the pointed player and the cards.
-- Keys while seated: E spins, picks or asks on your turn; X stands up.
local cfg = Config.Bottle
local Bottle = GameRules.bottle
local t = DL.locale.t
local here = { id = nil, uid = nil, venue = nil, seated = false, up = false, surface = 'floor', seats = {}, spin = nil, angle = 0.0, passes = 0 }
local props = {} -- [uid] = { key, look, bottle, chairs }

local function surfaceOf(record) return (record.settings or {}).surface == 'table' and 'table' or 'floor' end

local function seatsOf(record)
    local most = cfg.Seats[surfaceOf(record)]
    return math.max(2, math.min(math.floor(tonumber((record.settings or {}).seats) or most), most))
end

-- The first of a list of models (names or { model = ... }) the game has.
local function first(list)
    for _, item in ipairs(list) do
        if IsModelInCdimage(joaat(type(item) == 'table' and item.model or item)) then return item end
    end
end

-- The props of a place -------------------------------------------------------------------------------------------

local function spawnProp(model, x, y, z, pitch, heading)
    local hash = joaat(model)
    if not pcall(lib.requestModel, hash, 3000) then return nil end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = CreateObjectNoOffset(hash, x, y, z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    SetEntityRotation(entity, pitch, 0.0, heading, 2, false)
    FreezeEntityPosition(entity, true)
    return entity
end

-- The bottle's turn. It is drawn cfg.Scale times its size (a real bottle is too small to read from a seat): turning
-- an entity sets its size back, so the size goes on again after every turn.
local function setAngle(set, angle)
    local bottle = set and set.bottle
    if not bottle or not DoesEntityExist(bottle) then return end
    SetEntityRotation(bottle, set.look.pitch, 0.0, (angle + set.look.yaw) % 360, 2, false)
    local k = cfg.Scale or 1.0
    if k == 1.0 then return end
    local f, r, u, p = GetEntityMatrix(bottle)
    SetEntityMatrix(bottle, f.x * k, f.y * k, f.z * k, r.x * k, r.y * k, r.z * k, u.x * k, u.y * k, u.z * k, p.x, p.y, p.z)
end

-- The bottle on the rug or the table top, and at a table its chairs round it facing in.
local function furnish(record)
    local c, atTable = record.coords, surfaceOf(record) == 'table'
    local look, desk, chair = first(cfg.Bottles), atTable and first(cfg.Tables), atTable and first(cfg.Chairs)
    local set = { look = look, chairs = {} }
    if look then
        set.bottle = spawnProp(look.model, c.x, c.y, c.z + (desk and desk.top or 0.0) + (look.z or 0.0) * (cfg.Scale or 1.0), look.pitch, 0.0)
        if set.bottle then SetEntityCollision(set.bottle, false, false) end
        setAngle(set, here.uid == record.uid and here.angle or c.w or 0.0)
    end
    if chair then
        local n = seatsOf(record)
        for i = 1, n do
            local angle = Bottle.seatAngle(i, n, c.w)
            local x, y = Bottle.seat(c, cfg.Radius.table, angle)
            set.chairs[i] = spawnProp(chair.model, x, y, c.z, 0.0, (angle + chair.heading) % 360)
        end
    end
    return set
end

local function clear(uid)
    local set = props[uid]
    props[uid] = nil
    if not set then return end
    if set.bottle and DoesEntityExist(set.bottle) then DeleteEntity(set.bottle) end
    for _, entity in pairs(set.chairs) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
end

-- Places within the stream distance keep their props; an edited place is furnished again.
CreateThread(function()
    while true do
        local me, near = GetEntityCoords(cache.ped), {}
        for _, record in ipairs(Games.places('bottle_ring')) do
            local c = record.coords
            if record.active ~= false and #(me - vector3(c.x, c.y, c.z)) < Config.StreamDistance then
                local key = ('%s:%s:%s'):format(record.revision or 0, surfaceOf(record), seatsOf(record))
                near[record.uid] = true
                if not props[record.uid] or props[record.uid].key ~= key then
                    clear(record.uid)
                    props[record.uid] = furnish(record)
                    props[record.uid].key = key
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

-- Seats -------------------------------------------------------------------------------------------------------------

local function nameOf(id)
    for _, seat in ipairs(here.seats) do
        if seat.id == id then return seat.name end
    end
    return ''
end

local function mySeat()
    for _, seat in ipairs(here.seats) do
        if seat.id == cache.serverId then return seat end
    end
end

-- An upper-body move over the sit: mine, or (ped) one of my test bots'.
local function upper(anim, ms, ped)
    if lib.requestAnimDict(anim.dict, 2000) then TaskPlayAnim(ped or cache.ped, anim.dict, anim.clip, 4.0, 4.0, ms, 48, 0.0, false, false, false) end
end

-- On a chair at a table, or cross-legged on the floor, facing the bottle.
local function sitDown()
    local seat, v, ped = mySeat(), here.venue, cache.ped
    if not seat or not v then return end
    if here.surface == 'table' then
        local chair = first(cfg.Chairs) or cfg.Chairs[1]
        local x, y, heading = Bottle.seat(v, cfg.Radius.table + chair.back, seat.angle)
        return TaskStartScenarioAtPosition(ped, cfg.SitScenario, x, y, v.z + chair.seat, heading, 0, true, true)
    end
    local x, y, heading = Bottle.seat(v, cfg.Radius.floor, seat.angle)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(ped, x, y, v.z, false, false, false, false)
    SetEntityHeading(ped, heading)
    local sit = IsPedMale(ped) and cfg.Sit.male or cfg.Sit.female
    if lib.requestAnimDict(sit.dict, 3000) then TaskPlayAnim(ped, sit.dict, sit.anim, 4.0, 4.0, -1, 1, 0.0, false, false, false) end
end

-- Out of the game; tell is false when the server already took the player out.
local function standUp(tell)
    if not here.seated then return end
    here.seated, here.up = false, false
    lib.hideTextUI()
    if Nui.isOpen('games.card') then Nui.close() end
    ClearPedTasks(cache.ped)
    if tell then CreateThread(function() Games.call('bottle:stand') end) end
end

-- My seat on the ground: x, y and the heading that faces the bottle.
local function seatPoint()
    local seat, v = mySeat(), here.venue
    if seat and v then return Bottle.seat(v, cfg.Radius[here.surface], seat.angle) end
end

-- Up for a dare: the seat stays mine and the game goes on; back next to it, G sits me down again.
local function getUp()
    here.up = true
    ClearPedTasks(cache.ped)
end

local function backToSeat()
    local x, y = seatPoint()
    if not x or #(GetEntityCoords(cache.ped).xy - vector2(x, y)) > cfg.SitReach then
        Nui.notify('bottle.go_back', 'error')
        return false
    end
    here.up = false
    sitDown()
    return true
end

-- The sheets of my turn: truth, dare or pass; then (for the spinner) the question.
local function openChoose()
    Nui.open('games.card', { mode = 'choose', passes = math.max(0, cfg.Passes - here.passes) })
end

local function openAsk()
    local scene = Games.scenes[here.id]
    local deck = scene and scene.public and scene.public.scene and scene.public.scene.deck
    Nui.open('games.card', { mode = 'ask', pick = here.pick, name = nameOf(here.target), cards = deck ~= nil and deck ~= 'none', max = cfg.MaxText })
end

-- What E does now and the line that says so (with G and X after it).
local MY_MOVE = { spin = 'bottle.spin_key', choose = 'bottle.choose_key', ask = 'bottle.ask_key' }
local function prompt()
    local keys = t(here.up and 'bottle.keys_up' or 'bottle.keys_seated')
    local scene = Games.scenes[here.id]
    if not scene or here.spin or here.phase == 'spinning' then return keys end
    local turn = scene.turn
    if turn == cache.serverId and MY_MOVE[here.phase] then return t(MY_MOVE[here.phase]) .. ' · ' .. keys, here.phase end
    if not turn then return keys end
    return t('bottle.wait_' .. (here.phase or 'spin'), nameOf(turn)) .. ' · ' .. keys
end

local function act(action)
    if action == 'choose' then return openChoose() end
    if action == 'ask' then return openAsk() end
    if here.up and not backToSeat() then return end -- the bottle is spun from the seat
    local result = Games.call('bottle:spin')
    if not result.ok then Games.fail(result) end
end

-- E: my move; G: up for a dare and back down; X: out of the game. Too far from the ring is out too.
local function seatedLoop()
    local shown, joined = nil, false
    while here.seated do
        -- The server took me out (no sheet any more): stand up here too.
        if Games.lobby then joined = true elseif joined then standUp(false) break end
        local text, action = prompt()
        if shown ~= text then lib.showTextUI(text) shown = text end
        if not Nui.isOpen() then
            if action and IsControlJustPressed(0, 38) then CreateThread(function() act(action) end) end
            if IsControlJustPressed(0, 47) then if here.up then backToSeat() else getUp() end end
            if IsControlJustPressed(0, 73) then standUp(true) end
        end
        if not here.up and IsPedRagdoll(cache.ped) then here.up = true end -- knocked over: up, the seat stays
        local v = here.venue
        local far = v and #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z))
        if far and far > (here.up and cfg.UpRange or cfg.Radius[here.surface] + 4.0) then
            Nui.notify('bottle.too_far', 'error')
            standUp(true)
        elseif far and here.up then
            local x, y = seatPoint()
            if x then DrawMarker(2, x, y, v.z + 0.7, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, 240, 200, 60, 200, true, true, 2, false, nil, nil, false) end
        end
        Wait(0)
    end
    lib.hideTextUI()
end

-- The place's target: sit on the free seat nearest to you (the server starts the game at two).
Games.kind('bottle_ring', function(record)
    local atTable = surfaceOf(record) == 'table'
    local rug = not atTable and (record.settings or {}).rug ~= false and first(cfg.Rugs) -- a bottle from an item comes without the rug
    local look = atTable and first(cfg.Tables) or rug
    local model = look and (type(look) == 'table' and look.model or look) or nil
    local c = record.coords
    return {
        presentation = model and 'prop' or 'point', model = model, distance = cfg.Radius[surfaceOf(record)] + 1.5,
        targetSphere = not atTable and { radius = cfg.Radius.floor + 0.3, height = 0.25 } or nil,
        options = { {
            name = 'bottle_sit', label = t('bottle.sit'), icon = 'fa-solid fa-wine-bottle',
            canInteract = function() return Games.free() and not Games.lobby and not here.seated end,
            onSelect = function() CreateThread(function()
                local result = Games.call('bottle:sit', { venue = record.uid })
                if not result.ok then return Games.fail(result) end
                here.seated, here.seats, here.surface, here.uid = true, result.seats, surfaceOf(record), record.uid
                here.venue = { uid = record.uid, x = c.x, y = c.y, z = c.z, h = c.w }
                sitDown()
                if #result.seats < 2 then lib.notify({ description = t('bottle.waiting') }) end
                CreateThread(seatedLoop)
            end) end,
        } },
    }
end)

-- Scenes -----------------------------------------------------------------------------------------------------------

-- The pointed player: an arrow over their head for a few seconds.
local function arrow(id)
    local ped = Games.pedOf(id)
    if not ped then return end
    local untilMs = GetGameTimer() + 4000
    while GetGameTimer() < untilMs and DoesEntityExist(ped) do
        local p = GetEntityCoords(ped)
        DrawMarker(2, p.x, p.y, p.z + 1.25, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.18, 0.18, 0.18, 240, 238, 224, 220, true, true, 2, false, nil, nil, false)
        Wait(0)
    end
end

local function cardText(text)
    if type(text) ~= 'string' then return '' end
    local own = t(text)
    return own ~= text and own or text
end

-- What comes after a spin (whom it points at, their turn, a card) waits until this client's bottle stops.
local handle -- the scene handler below
local held = {}

local function spinLoop()
    if here.spinning then return end
    here.spinning = true
    while here.spin do
        local s, now = here.spin, GetGameTimer()
        here.angle = Bottle.angleAt(s.from, s.to, s.ms, now - s.start)
        setAngle(props[here.uid], here.angle)
        if now >= s.start + s.ms then
            here.spin, here.angle = nil, s.to % 360
            PlaySoundFrontend(-1, 'CLICK_BACK', 'WEB_NAVIGATION_SOUNDS_PHONE', true)
            local waiting = held
            held = {}
            for _, h in ipairs(waiting) do handle(h[1], h[2], h[3], h[4]) end
        end
        Wait(0)
    end
    here.spinning = false
end

-- A spin on this client's clock, from when the server started it (Games.localTime).
local function startSpin(s)
    here.spin = { from = s.from, to = s.to, ms = s.ms, start = Games.localTime(s.at) }
    CreateThread(spinLoop)
end

Games.onScene('bottle', function(op, args, message, scene)
    if here.spin and (op == 'pointed' or op == 'turn' or op == 'card') then
        held[#held + 1] = { op, args, message, scene }
        return
    end
    handle(op, args, message, scene)
end)

handle = function(op, args, _, scene)
    if op == 'start' or op == 'full' then
        local s = args.scene or {}
        here.id, here.uid, here.venue = scene.id, args.venue.uid, args.venue
        here.seats, here.surface, here.phase = s.seats or {}, s.surface or 'floor', s.phase
        here.target, here.asker, here.pick, here.angle = s.target, s.asker, s.pick, s.angle or 0.0
        here.passes = (s.passes or {})[cache.serverId] or 0
        setAngle(props[here.uid], here.angle)
        if s.spin then startSpin(s.spin) end
    elseif op == 'seats' then
        here.seats = args.seats
    elseif op == 'spin' then
        here.phase = 'spinning'
        if args.by == cache.serverId or Games.myBot(args.by) then upper(cfg.Anim.spin, 1200, Games.myBot(args.by)) end
        startSpin(args)
    elseif op == 'pointed' then
        here.target = args.id
        CreateThread(function() arrow(args.id) end)
        if args.id == cache.serverId or Games.myBot(args.id) then upper(cfg.Anim.pointed, 1500, Games.myBot(args.id)) end
        if here.seated then lib.notify({ description = args.id == cache.serverId and t('bottle.pointed_you') or t('bottle.pointed', args.name or '') }) end
    elseif op == 'turn' then
        here.phase, here.target, here.asker, here.pick = args.phase, args.target, args.asker, args.pick
        if Nui.isOpen('games.card') then Nui.close() end
        if args.id == cache.serverId and here.seated and not Nui.isOpen() then
            if args.phase == 'choose' then openChoose() elseif args.phase == 'ask' then openAsk() end
        end
    elseif op == 'card' then
        if Nui.isOpen('games.card') then Nui.close() end
        if args.pick == 'pass' then
            if args.id == cache.serverId then here.passes = args.passes or here.passes + 1 end
            if here.seated then lib.notify({ description = t('bottle.passed', nameOf(args.id)) }) end
            return
        end
        if here.seated then
            Games.overlay('games.card', { mode = 'show', pick = args.pick, text = cardText(args.text), name = nameOf(args.id),
                by = args.own and nameOf(args.by) or nil }, 12)
            if args.pick == 'dare' and args.id == cache.serverId then lib.notify({ description = t('bottle.up_hint') }) end
        end
    elseif op == 'end' then
        here.spin, held = nil, {}
        if Nui.isOpen('games.card') then Nui.close() end
        Games.hideOverlay('games.card')
        standUp(false)
        here.id, here.phase, here.target, here.asker, here.pick, here.passes = nil, nil, nil, nil, nil, 0
    end
end

RegisterNUICallback('bottle:choose', function(data, cb)
    local result = Games.call('bottle:choose', { pick = data.pick })
    if not result.ok then Games.fail(result) end
    if result.ok then Nui.close() end
    cb(result)
end)

RegisterNUICallback('bottle:ask', function(data, cb)
    local result = Games.call('bottle:ask', { text = data.text })
    if not result.ok then Games.fail(result) end
    if result.ok then Nui.close() end
    cb(result)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for uid in pairs(props) do clear(uid) end
    if here.seated then ClearPedTasks(cache.ped) end
    lib.hideTextUI()
end)
