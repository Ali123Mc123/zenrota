-- Power cut on the client: the lights out for whoever is inside the radius (others see the building as ever),
-- sparks at the breaker panel, the panel's state when a model made in states exists, the janitor's steps (cover,
-- breakers) and the torch, whose cone everyone near sees.
if not Config.Janitor or not Config.Janitor.Enabled then return end

local cfg = Config.Janitor
local t = DL.locale.t
local cuts, shown = {}, {} -- incident id -> view; place uid -> panel state
local dark, torch, watchTorch = false, nil, false -- watchTorch: a cut close enough that torches may be seen

local function exists(name) return IsModelInCdimage(joaat(name)) end

-- A city blackout (the weather script's, the whole server's or this player's) stays dark whatever a cut does.
local function cityDark() return GlobalState.blackOut == true or LocalPlayer.state.playerBlackOut == true end

local function sound(which, coords)
    local s = cfg.Sounds[which]
    if not s then return end
    if coords then PlaySoundFromCoord(-1, s[1], coords.x, coords.y, coords.z, s[2], false, 20, false) else PlaySoundFrontend(-1, s[1], s[2], true) end
end

-- Panel states ----------------------------------------------------------------------------------------------------

local function panelModel(model, state)
    local base = (model or ''):gsub('_closed$', ''):gsub('_open$', ''):gsub('_tripped$', '')
    if state and exists(base .. '_' .. state) then return base .. '_' .. state end
    return model
end

local function panelBase()
    for _, name in ipairs(cfg.Models.panel) do
        if exists(name) or exists(name .. '_closed') then return name end
    end
end

Campus.kind('janitor_power', function(record)
    if (record.model or '') == '' then record.presentation, record.model = 'prop', panelBase() end
    record.model = panelModel(record.model, shown[record.uid] or 'closed')
    return { options = {} }
end)

local function showPanel(place, state)
    shown[place] = state
    local uid = 'janitor_power:' .. place
    local def = Campus.world.anchors.get(uid)
    local model = def and panelModel(def.model, state)
    if not def or model == def.model then return end
    local copy = {}
    for k, v in pairs(def) do copy[k] = v end
    copy.model = model
    Campus.world.anchors.set(uid, copy)
end

-- Sparks ----------------------------------------------------------------------------------------------------------

local function sparks(c, ms)
    local fx = cfg.Effects.sparks
    RequestNamedPtfxAsset(fx[1])
    local limit = GetGameTimer() + 2000
    while not HasNamedPtfxAssetLoaded(fx[1]) and GetGameTimer() < limit do Wait(0) end
    UseParticleFxAsset(fx[1])
    local handle = StartParticleFxLoopedAtCoord(fx[2], c.x, c.y, c.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Wait(ms)
    StopParticleFxLooped(handle, false)
end

RegisterNetEvent('daddy_campuslife:janitor:sparks', function(id)
    local view = cuts[id]
    if not view or not view.coords then return end
    sound('sparks', view.coords)
    sparks(view.coords, 1500)
end)

-- Steps -----------------------------------------------------------------------------------------------------------

local function step(id)
    local view = cuts[id]
    return view and view.steps and view.steps[view.step]
end

local function openCover(id)
    local result = Campus.call('janitor:powerOpen', { id = id })
    if not result.ok then return Campus.fail(result) end
end

JanitorClient.kinds.power = {
    incidentOptions = function(id)
        return {
            { name = 'janitor_power_open', label = t('janitor.power_open'), icon = 'fa-solid fa-door-open',
                canInteract = function() return JanitorClient.working(id) and step(id) == 'open' end,
                onSelect = function() CreateThread(function() openCover(id) end) end },
            { name = 'janitor_power_breakers', label = t('janitor.power_breakers'), icon = 'fa-solid fa-bolt',
                canInteract = function() return JanitorClient.working(id) and step(id) == 'breakers' end,
                onSelect = function() CreateThread(function() JanitorClient.panel(id, cuts[id].coords, 'breaker') end) end },
        }
    end,

    -- A wrong breaker on the panel: a spark at once, before the server's answer.
    onFault = function(id)
        local view = cuts[id]
        if view and view.coords then CreateThread(function() sparks(view.coords, 600) end) end
    end,

    onView = function(view)
        local live = view.state == 'open' or view.state == 'claimed'
        cuts[view.id] = live and view or nil
        if not view.place then return end
        if live or view.state ~= 'done' then return showPanel(view.place, live and view.data and view.data.panel or 'closed') end
        -- Fixed: the cover stays open half a minute, then shuts (unless the panel has moved on meanwhile).
        showPanel(view.place, 'open')
        SetTimeout(30000, function() if shown[view.place] == 'open' then showPanel(view.place, 'closed') end end)
    end,
}

-- The torch -------------------------------------------------------------------------------------------------------

local function holdTorch(on)
    if on and not torch then
        local model = JanitorClient.model(cfg.Models.torch)
        local hand = cfg.Hands.torch
        torch = model and Campus.chores.hold({ model = model, bone = hand.bone, pos = hand.pos, rot = hand.rot }) or false
        LocalPlayer.state:set('janitorTorch', true, true)
    elseif not on and torch ~= nil then
        if torch then Campus.chores.unhold(torch) end
        torch = nil
        LocalPlayer.state:set('janitorTorch', nil, true)
    end
end

-- Lights out inside a cut, with the torch in hand for a janitor who took one; sparks now and then near the panel.
CreateThread(function()
    local nextSpark = 0
    while true do
        local wait, inside, near, watch = 1000, false, nil, false
        local here = GetEntityCoords(cache.ped)
        for _, view in pairs(cuts) do
            local c = view.coords
            if c then
                local d = #(here - vector3(c.x, c.y, c.z))
                local radius = view.data and view.data.radius or 25.0
                if d < radius then inside = true end
                if d < radius + 40.0 then watch = true end
                if d < 60.0 then near, wait = c, 500 end
            end
        end
        watchTorch = watch
        if inside ~= dark then
            dark = inside
            SetArtificialLightsStateAffectsVehicles(false)
            SetArtificialLightsState(dark or cityDark())
            if dark then sound('powerDown') end
        end
        holdTorch(dark and JanitorClient.tools.torch == true)
        if near and GetGameTimer() > nextSpark then
            nextSpark = GetGameTimer() + math.random(2500, 5000)
            CreateThread(function() sparks(near, 400) end)
        end
        Wait(wait)
    end
end)

-- Every torch near: a cone from the hand where the player looks. Players are looked at only near a cut (torches burn
-- only there): their distance first, the state bag only of those close.
CreateThread(function()
    local lit = {}
    CreateThread(function()
        while true do
            if not watchTorch then
                lit = {}
                Wait(1500)
            else
                local list, here = {}, GetEntityCoords(cache.ped)
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if #(here - GetEntityCoords(ped)) < 40.0 and Player(GetPlayerServerId(player)).state.janitorTorch then list[#list + 1] = ped end
                end
                lit = list
                Wait(500)
            end
        end
    end)
    local k = cfg.Torch
    while true do
        if #lit == 0 then
            Wait(500)
        else
            for _, ped in ipairs(lit) do
                local at = GetPedBoneCoords(ped, cfg.Hands.torch.bone, 0.15, 0.0, 0.0)
                local dir = GetEntityForwardVector(ped)
                DrawSpotLight(at.x, at.y, at.z, dir.x, dir.y, dir.z - 0.2, 255, 244, 224, k.Distance, k.Brightness, 0.0, k.Radius, k.Falloff)
            end
            Wait(0)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if dark then SetArtificialLightsState(cityDark()) end
    if torch ~= nil then LocalPlayer.state:set('janitorTorch', nil, true) end
end)
