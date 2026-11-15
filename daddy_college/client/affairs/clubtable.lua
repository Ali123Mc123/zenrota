-- Club tables on the client: a folding stand table. Closed it stands bare with a "closed today" card; while an officer
-- is at it, it wears a cloth in the club's colour with a roll-up banner, a brochure holder and a sign-up clipboard.
-- Students look the club over, take a brochure or sign up; the officer opens and closes it, reads the applications
-- and hands a brochure to the student in front. The server says which tables are open and checks every action.
if not Core.ModuleEnabled('affairs') then return end

local cfg = Config.Affairs.Club.Table or {}
local t = DL.locale.t
local tables, mine, myRole = {}, nil, nil -- uid -> spot; the stand this player is at, and as what (officer, member)

ClubTable = {}

local function exists(name) return type(name) == 'string' and IsModelInCdimage(joaat(name)) end
local function first(names)
    for _, name in ipairs(type(names) == 'table' and names or { names }) do
        if exists(name) then return name end
    end
end

-- A point of the table's own frame (x right, y back, z up, w turn) in the world.
local function at(spot, place)
    local c, r = spot.coords, math.rad(spot.coords.w or 0.0)
    local cs, sn = math.cos(r), math.sin(r)
    return { x = c.x + place.x * cs - place.y * sn, y = c.y + place.x * sn + place.y * cs, z = c.z + place.z, w = ((c.w or 0.0) + (place.w or 0.0)) % 360 }
end

-- The cloth colour (a name in ClothColors) nearest to the club's own colour.
local function colourOf(color)
    local names = {}
    for name in pairs(cfg.ClothColors or {}) do names[#names + 1] = name end
    table.sort(names)
    if type(color) ~= 'string' or not color:match('^#%x%x%x%x%x%x$') then return names[1] end
    local function rgb(hex) return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16) end
    local r, g, b = rgb(color)
    local best, near = names[1], math.huge
    for _, name in ipairs(names) do
        local r2, g2, b2 = rgb(cfg.ClothColors[name])
        local d = (r - r2) ^ 2 + (g - g2) ^ 2 + (b - b2) ^ 2
        if d < near then best, near = name, d end
    end
    return best
end

local function call(name, data) return Core.NormalizeResult(lib.callback.await('daddy_college:affairs:' .. name, false, data)) end

-- Options ----------------------------------------------------------------------------------------------------

-- start: nil (the cover) or 'join' (opened at the coupon); focus: unused, kept for older callers.
function ClubTable.openBrochure(club, uid, start, focus)
    local result = call('clubProfile', { clubName = club })
    if not result.ok then return Core.HandleResult(result, 'affairs') end
    result.table, result.start, result.focus = uid, start, focus
    result.open = uid ~= nil and (GlobalState['daddy_college:clubTables'] or {})[uid] ~= nil
    Core.Nui.Open('clubtable.brochure', result)
end

-- The officer's ledger: the stand's live counts, the applications to stamp and the interested students to call.
function ClubTable.openLedger(club, uid)
    local profile = call('clubProfile', { clubName = club })
    if not profile.ok then return Core.HandleResult(profile, 'affairs') end
    local live = call('clubStandLive', {})
    Core.Nui.Open('clubtable.ledger', { club = club, table = uid, color = profile.color, clubId = profile.clubId, logo = profile.logo, live = live.ok and live.live or nil })
end

local function standAt(spot, on)
    local result = call(on and 'clubTableOn' or 'clubTableOff', { uid = spot.uid })
    if not result.ok then return Core.HandleResult(result, 'affairs') end
    mine, myRole = on and spot.uid or nil, on and result.role or nil
    if not on then return Core.NotifyL('clubs.table_off', 'inform') end
    local key = result.role == 'member' and 'clubs.stand_role_member'
        or result.shared and 'clubs.stand_set' or 'clubs.table_on'
    Core.NotifyL(key, 'inform', result.club or '')
end

local brochureMove
local function takeFlyer(spot)
    local result = call('clubFlyer', { uid = spot.uid })
    if not result.ok then return Core.HandleResult(result, 'affairs') end
    brochureMove('pickup_object', 'pickup_low', 1200)
    Core.NotifyL('clubs.flyer_taken', 'success')
end

-- The player standing in front of the table, or nil.
local function inFront(spot)
    local front = at(spot, { x = 0.0, y = -1.2, z = 0.0 })
    local player = lib.getClosestPlayer(vector3(front.x, front.y, front.z), cfg.HandReach or 2.0, false)
    return player and GetPlayerServerId(player) or nil
end

-- A short animation with a brochure in the right hand (holding one out, taking one, picking one up).
function brochureMove(dict, name, ms)
    local ped = cache.ped
    if not pcall(lib.requestAnimDict, dict, 2500) then return end
    local model = joaat(cfg.HandProp or 'prop_cs_pamphlet_01')
    local prop
    if pcall(lib.requestModel, model, 2500) then
        local at = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        prop = CreateObject(model, at.x, at.y, at.z + 0.2, false, false, false)
        SetEntityCollision(prop, false, false)
        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.13, 0.03, -0.02, -60.0, 0.0, 0.0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(model)
    end
    TaskPlayAnim(ped, dict, name, 4.0, 4.0, ms, 48, 0.0, false, false, false)
    RemoveAnimDict(dict)
    SetTimeout(ms, function()
        if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    end)
end

-- Someone at the stand holds a brochure out to the player in front; it is theirs once they take it.
local function handFlyer(spot)
    local target = inFront(spot)
    if not target then return Core.NotifyL('clubs.hand_nobody', 'error') end
    local result = call('clubFlyerOffer', { uid = spot.uid, target = target })
    if not result.ok then return Core.HandleResult(result, 'affairs') end
    brochureMove('mp_common', 'givetake1_a', 2200)
    Core.NotifyL('clubs.hand_offered', 'inform', result.name or '')
end

local function clubOf(spot)
    local open = (GlobalState['daddy_college:clubTables'] or {})[spot.uid]
    return (spot.settings.club or '') ~= '' and spot.settings.club or open and open.club ~= 'test' and open.club or ''
end

-- What a table offers now: a free shared spot only "set up our stand"; an open stand or a club's own table the rest.
local function options(spot)
    local club, reach = clubOf(spot), cfg.Reach or 3.0
    local open = (GlobalState['daddy_college:clubTables'] or {})[spot.uid] ~= nil
    local shared = (spot.settings.club or '') == ''
    local run = function(fn) return function() CreateThread(fn) end end
    local onLabel = shared and (open and 'clubs.target_stand_join' or 'clubs.target_stand_setup') or (open and 'clubs.target_stand_join' or 'clubs.target_table_on')
    local stepIn = { name = 'club_table_on', label = t(onLabel), icon = 'fa-solid fa-user-tie', distance = reach,
        canInteract = function() return mine ~= spot.uid end, onSelect = run(function() standAt(spot, true) end) }
    if club == '' then return { stepIn } end
    return {
        { name = 'club_brochure', label = t('clubs.target_brochure'), icon = 'fa-solid fa-book-open', distance = reach,
            canInteract = function() return mine ~= spot.uid end,
            onSelect = run(function() ClubTable.openBrochure(club, spot.uid) end) },
        { name = 'club_requests', label = t('clubs.target_requests'), icon = 'fa-solid fa-inbox', distance = reach,
            canInteract = function() return mine == spot.uid and myRole == 'officer' end,
            onSelect = run(function() ClubTable.openLedger(club, spot.uid) end) },
        { name = 'club_hand', label = t('clubs.target_hand'), icon = 'fa-solid fa-hand-holding', distance = reach,
            canInteract = function() return mine == spot.uid end,
            onSelect = run(function() handFlyer(spot) end) },
        stepIn,
        { name = 'club_table_off', label = t('clubs.target_table_off'), icon = 'fa-solid fa-person-walking-arrow-right', distance = reach,
            canInteract = function() return mine == spot.uid end,
            onSelect = run(function() standAt(spot, false) end) },
    }
end

-- Props --------------------------------------------------------------------------------------------------------

local function prop(defs, uid, spot, model, place, extra)
    if not model or not place then return end
    local def = { uid = uid, presentation = 'prop', model = model, revision = spot.revision, coords = at(spot, place), streamDistance = 60.0 }
    for k, v in pairs(extra or {}) do def[k] = v end
    defs[#defs + 1] = def
end

-- A small target round a piece on the table (the brochure holder, the clipboard).
local function spotOn(label, icon, fn)
    return { distance = cfg.Reach or 3.0, targetSphere = { radius = 0.3, height = 0.1 },
        options = { { name = 'club_' .. icon, label = label, icon = 'fa-solid fa-' .. icon, onSelect = function() CreateThread(fn) end } } }
end

local function show()
    local open = GlobalState['daddy_college:clubTables'] or {}
    local m, defs = cfg.Models or {}, {}
    for uid in pairs(tables) do tables[uid] = nil end
    for _, spot in ipairs(Core.World.entities({ kind = 'club_table' })) do
        tables[spot.uid] = spot
        local s, key, club = spot.settings or {}, 'clubtable:' .. spot.uid, clubOf(spot)
        local bare = (spot.model or '') ~= '' and spot.model or first(m.table) or 'prop_table_03'
        local stand = bare == first(m.table) and exists(bare) and bare:find('club_table', 1, true) ~= nil
        local places = stand and (cfg.Places or {}) or (cfg.OldPlaces or cfg.Places or {})
        local state = open[spot.uid]
        local colour = state and colourOf(state.color)
        local dressed = stand and colour and m.cloth and first(m.cloth:format(colour))
        local cloth = dressed and StandLogos and StandLogos.hooks(spot.uid, 'cloth', colour) or {} -- the logo disc on the cloth
        defs[#defs + 1] = { uid = key, label = spot.label, coords = spot.coords, presentation = 'prop', model = dressed or bare,
            revision = ('%s:%s'):format(spot.revision or 0, dressed or 'bare'), distance = cfg.Reach or 3.0, options = options(spot),
            onSpawn = cloth.onSpawn, onDespawn = cloth.onDespawn }
        for i = 1, math.min(tonumber(s.chairs) or 0, #(places.chairs or {})) do prop(defs, key .. ':chair' .. i, spot, first(m.chair), places.chairs[i]) end
        if s.canopy == 'parasol' or s.canopy == 'gazebo' then prop(defs, key .. ':shade', spot, first(m[s.canopy]), places[s.canopy]) end
        if s.board == 'cork' or s.board == 'whiteboard' then prop(defs, key .. ':board', spot, first(m[s.board]), places.board) end
        if state then
            if (s.board or 'banner') == 'banner' and m.banner then
                prop(defs, key .. ':banner', spot, first(m.banner:format(colour)), places.banner, StandLogos and StandLogos.hooks(spot.uid, 'banner', colour))
            end
            if not dressed then prop(defs, key .. ':name', spot, first(m.nameplate), places.nameplate) end
            local flyers = cfg.FlyerItem and spotOn(t('clubs.target_flyer'), 'file-lines', function() takeFlyer(spot) end) or nil
            prop(defs, key .. ':flyers', spot, first(m.flyers), places.flyers, flyers)
            prop(defs, key .. ':signup', spot, first(m.signup), places.signup,
                spotOn(t('clubs.target_signup'), 'pen', function() ClubTable.openBrochure(club, spot.uid, 'join') end))
        elseif (s.club or '') ~= '' then
            prop(defs, key .. ':closed', spot, first(m.closed), places.closed)
        end
    end
    if StandLogos then StandLogos.sync(open) end -- before the props: their spawn hooks find the stands
    Core.World.anchors.sync('clubtables', defs)
    ClubTable.blips(open)
end

-- Open stands on the map, named after their club, while they stand.
local blips = {}
function ClubTable.blips(open)
    local b = cfg.Blip
    for uid, blip in pairs(blips) do
        if not open[uid] then RemoveBlip(blip) blips[uid] = nil end
    end
    if not b or b.Enabled == false then return end
    for uid, state in pairs(open) do
        local spot = tables[uid]
        if spot and not blips[uid] and state.club ~= 'test' then
            local blip = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)
            SetBlipSprite(blip, b.Sprite or 409)
            SetBlipColour(blip, b.Colour or 27)
            SetBlipScale(blip, b.Scale or 0.7)
            SetBlipAsShortRange(blip, b.ShortRange == true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(t('clubs.blip', state.club))
            EndTextCommandSetBlipName(blip)
            blips[uid] = blip
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in pairs(blips) do RemoveBlip(blip) end
end)

Core.World.subscribe(show)
AddStateBagChangeHandler('daddy_college:clubTables', 'global', function() SetTimeout(0, show) end)

-- A student who walks up to an open table is told once what it is (per table, per session).
local hinted = {}
CreateThread(function()
    while true do
        local open, wait = GlobalState['daddy_college:clubTables'] or {}, 2000
        if next(open) then
            local here = GetEntityCoords(cache.ped)
            for uid, state in pairs(open) do
                local spot = tables[uid]
                if spot and not hinted[uid] and mine ~= uid and #(here - vector3(spot.coords.x, spot.coords.y, spot.coords.z)) <= 4.0 then
                    hinted[uid] = true
                    Core.NotifyL('clubs.hint', 'inform', state.club)
                end
            end
            wait = 1000
        end
        Wait(wait)
    end
end)

-- The brochure's calls: applying, and the officer's requests, answers and interviews (the server checks each).
local BROCHURE = { apply = 'clubRequest', cancel = 'clubCancelRequest', requests = 'clubRequestsList', respond = 'clubRespondRequest', interview = 'clubInterview',
    interest = 'clubInterest', interestList = 'clubInterestList', interestSet = 'clubInterestSet', standLive = 'clubStandLive', reportLogo = 'clubReportLogo' }
for name, action in pairs(BROCHURE) do
    Core.Nui.SafeCallback('clubs:' .. name, function(data)
        local result = call(action, data)
        if not result.ok then Core.HandleResult(result, 'affairs') end
        return result
    end)
end

-- The brochure and the ledger turn into each other (the officer's two sides of the stand).
Core.Nui.SafeCallback('clubs:ledger', function(data)
    CreateThread(function() ClubTable.openLedger(data.club, data.table) end)
    return { ok = true }
end)
Core.Nui.SafeCallback('clubs:brochureBack', function(data)
    CreateThread(function() ClubTable.openBrochure(data.club, data.table) end)
    return { ok = true }
end)

-- Events -------------------------------------------------------------------------------------------------------

RegisterNetEvent('daddy_college:clubs:applied', function(data)
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    Core.NotifyL('clubs.applied', 'inform', data.name or '')
end)

RegisterNetEvent('daddy_college:clubs:tableLeft', function(uid)
    if mine == uid then mine, myRole = nil, nil end
    Core.NotifyL('clubs.table_off', 'inform')
end)

-- A brochure held out to this player: [E] takes it (it goes to the inventory), [X] or waiting says no.
local offerOpen = false
RegisterNetEvent('daddy_college:clubs:flyerOffer', function(data)
    if offerOpen then return end
    offerOpen = true
    CreateThread(function()
        Core.Prompt('clubFlyer', { title = t('clubs.hand_offer', data.name or '', data.club or ''), keys = {
            { keys = { 'E' }, label = t('clubs.hand_take') }, { keys = { 'X' }, label = t('clubs.hand_no') } } })
        local accept, deadline = false, GetGameTimer() + (tonumber(data.seconds) or 15) * 1000
        while GetGameTimer() < deadline do
            if IsControlJustPressed(0, 38) then accept = true break end
            if IsControlJustPressed(0, 73) then break end
            Wait(0)
        end
        Core.Prompt('clubFlyer')
        offerOpen = false
        local result = call('clubFlyerAnswer', { accept = accept })
        if not accept then return end
        if not result.ok then return Core.HandleResult(result, 'affairs') end
        brochureMove('mp_common', 'givetake1_b', 2000)
        Core.NotifyL('clubs.hand_got', 'success', data.club or '')
    end)
end)

RegisterNetEvent('daddy_college:clubs:flyerTaken', function(name)
    Core.NotifyL('clubs.hand_done', 'success', name or '')
end)

RegisterNetEvent('daddy_college:clubs:brochure', function(club)
    CreateThread(function() ClubTable.openBrochure(club, nil) end)
end)

RegisterNetEvent('daddy_college:clubs:interview', function(data)
    Core.NotifyL('clubs.interview', 'inform', data.club or '', data.when or '', data.place or t('clubs.here'))
end)
