-- What everyone near a station sees and hears of its game, from the scene alone (10-cpr-deney.md section 7). The lab:
-- the liquid's colour (a new colour fades in under a fizz) and level (rising at the pour rate while a bottle pours,
-- then set to the server's amount), the reaction to each step and the end. The first aid station: the CPR trainer
-- and its light, lit every fifth compression. The stream, the flame and the rod belong to the interactions (lab.lua).
local PC = Core.PracticalClient
if not PC then return end

local cfg = PC.cfg
PC.looks = PC.looks or {}

-- Lab -----------------------------------------------------------------------------------------------------------

local lab = cfg.Kinds.lab_bench
local LIQ = lab.Layout.liquid or {}

-- A point in an entity's own box: x, y from the middle of its footprint, z: 'top', 'bottom' or metres over the bottom.
local function inBox(entity, z, up)
    local min, max = PC.box(GetEntityModel(entity))
    local h = z == 'top' and max.z or min.z + (type(z) == 'number' and z or 0.0)
    return GetOffsetFromEntityInWorldCoords(entity, (min.x + max.x) / 2, (min.y + max.y) / 2, h + (up or 0.0))
end

local function beaker(view) return view.objects.beaker end
local function mouth(view) local b = beaker(view) return b and inBox(b, 'top') end

-- The liquid at a share of its height (0-1): its bottom stays on the beaker's floor, scaled up from there (section
-- 7.2: only on a local, frozen object without collision; set again after anything moves it).
local function level(view, entity, share)
    local b = beaker(view)
    if not b or not entity or not DoesEntityExist(entity) then return end
    local at = inBox(b, 'bottom', LIQ.lift or 0.005)
    local min, max = PC.box(GetEntityModel(entity))
    local h = math.rad(GetEntityHeading(b))
    local s = math.max(0.04, math.min(1.0, share))
    local cx, cy = PracticalFrame.turn(GetEntityHeading(b), (min.x + max.x) / 2, (min.y + max.y) / 2)
    SetEntityMatrix(entity, -math.sin(h), math.cos(h), 0.0, math.cos(h), math.sin(h), 0.0, 0.0, 0.0, s,
        at.x - cx, at.y - cy, at.z - min.z * s)
end

local function shareOf(ml) return (ml or 0) / (LIQ.full or 200) end

-- The liquid's colour model, made at the level shown (alpha: where it starts).
local function pourIn(view, name, colour, alpha)
    local liquid = cfg.Liquids[colour] or cfg.Liquids.clear
    local model = liquid and PC.model(liquid.model)
    local b = beaker(view)
    if not model or not b then return nil end
    local entity = PC.object(view, name, model, GetEntityCoords(b), GetEntityHeading(b), true)
    if not entity then return nil end
    SetEntityAlpha(entity, alpha or 255, false)
    level(view, entity, shareOf(view.shownMl))
    return entity
end

-- A new colour fades in over FadeMs while the old one fades out (the fizz covers the moment).
local function recolour(view, colour)
    if view.liquidColour == colour then return end
    view.liquidColour = colour
    local old = view.objects.liquid
    view.objects.liquid = nil
    if old then
        PC.remove(view, 'liquidOld')
        view.objects.liquidOld = old
    end
    local entity = pourIn(view, 'liquid', colour, old and 0 or 255)
    if not old then return end
    local ms, start = lab.FadeMs or 300, GetGameTimer()
    CreateThread(function()
        while view.built and GetGameTimer() - start < ms do
            local k = (GetGameTimer() - start) / ms
            if entity and DoesEntityExist(entity) then SetEntityAlpha(entity, math.floor(255 * k), false) end
            if DoesEntityExist(old) then SetEntityAlpha(old, math.floor(255 * (1 - k)), false) end
            Wait(0)
        end
        if entity and DoesEntityExist(entity) then ResetEntityAlpha(entity) end
        if view.objects.liquidOld == old then PC.remove(view, 'liquidOld') end
    end)
end

-- The level shown eases to ml (the server's amount) or follows a pour while it runs.
local function setMl(view, ml)
    view.shownMl = ml
    local entity = view.objects.liquid
    if entity then level(view, entity, shareOf(ml)) end
    if view.objects.liquidOld then level(view, view.objects.liquidOld, shareOf(ml)) end
end

local function easeTo(view, ml)
    local from, start = view.shownMl or 0, GetGameTimer()
    view.easing = (view.easing or 0) + 1
    local mine = view.easing
    CreateThread(function()
        while view.built and view.easing == mine and GetGameTimer() - start < 300 do
            setMl(view, from + (ml - from) * (GetGameTimer() - start) / 300)
            Wait(0)
        end
        if view.built and view.easing == mine then setMl(view, ml) end
    end)
end

-- While a bottle pours (pourOn until its pour): the level rises at the pour rate, as on the player's worksheet.
local function rising(view, ml)
    view.easing = (view.easing or 0) + 1
    local mine, start = view.easing, GetGameTimer()
    CreateThread(function()
        while view.built and view.easing == mine do
            setMl(view, ml + (GetGameTimer() - start) / 1000 * (lab.PourMlPerSecond or 40))
            Wait(100)
        end
    end)
end

-- A burst over the beaker: the effect by its name in the kind's Fx, at the mouth or in the liquid.
local function burst(view, name, at)
    local def = lab.Fx[name]
    if def and at then PC.fx(view, def, at, name) end
end

-- The foam over the liquid: grows, holds, goes (Foam.model; nothing without it).
local function foam(view)
    local f, at = lab.Foam, mouth(view)
    local model = f and PC.model(f.model)
    if not model or not at then return end
    local entity = PC.object(view, 'foam', model, at - vector3(0.0, 0.0, 0.03), GetEntityHeading(beaker(view)))
    if not entity then return end
    local start, ms = GetGameTimer(), f.ms or 2000
    CreateThread(function()
        while view.built and DoesEntityExist(entity) and GetGameTimer() - start < ms do
            local k = (GetGameTimer() - start) / ms
            local s = math.max(0.05, math.sin(k * math.pi))
            local p, h = GetEntityCoords(entity), math.rad(GetEntityHeading(entity))
            SetEntityMatrix(entity, -math.sin(h) * s, math.cos(h) * s, 0.0, math.cos(h) * s, math.sin(h) * s, 0.0, 0.0, 0.0, s, p.x, p.y, p.z)
            Wait(0)
        end
        if view.objects.foam == entity then PC.remove(view, 'foam') end
    end)
end

-- What a step looked like: right and on the amount fizzes under foam, right but off steams, wrong bursts.
local function react(view, event)
    local top = mouth(view)
    if event.right == false then
        burst(view, 'wrong', top)
        PC.sound('bad', top)
    elseif event.hit then
        burst(view, 'fizz', view.objects.liquid and GetEntityCoords(view.objects.liquid) or top)
        foam(view)
        PC.sound('good', top)
    else
        burst(view, 'steam', top)
        PC.sound('good', top)
    end
end

PC.looks.lab_mix = function(view, scene, event)
    if not beaker(view) then return end
    -- built again (here or after a while away): start from the scene as it stands
    if view.lookAt ~= view.builtAt or view.shownMl == nil then
        view.lookAt, view.liquidColour, view.shownMl, view.easing = view.builtAt, nil, scene.ml or 0, (view.easing or 0) + 1
    end
    local failed = scene.state == 'done' and scene.result ~= 'pass'
    if (scene.ml or 0) > 0 or view.shownMl > 0 then recolour(view, failed and 'murky' or scene.colour or 'clear') end
    if event.op == 'pourOn' then
        rising(view, scene.ml or 0)
        if not view.objects.liquid then recolour(view, scene.colour or 'clear') end
    elseif event.op == 'pour' then
        easeTo(view, scene.ml or 0)
        react(view, event)
    elseif event.op == 'heat' or event.op == 'stir' then
        react(view, event)
    elseif event.op == 'end' then
        local top = mouth(view)
        if failed then
            burst(view, 'ruined', top)
            PC.sound('bad', top)
        else
            burst(view, 'passed', top)
            PC.sound('good', top)
        end
    elseif not event.op then
        setMl(view, scene.ml or 0)
    end
end

-- First aid -----------------------------------------------------------------------------------------------------

local aid = cfg.Kinds.first_aid_station
local T = aid.Trainer

local function trainerLed(view)
    local entity = view.objects.trainer
    return entity and DoesEntityExist(entity) and inBox(entity, 'top', T.led and T.led.z or 0.03) or nil
end

-- The trainer's light while its station plays: the colour of the last five compressions, seen within T.seen.
local function glow(view)
    if view.glowing then return end
    view.glowing = true
    CreateThread(function()
        while view.built and not view.gone and view.scene and view.scene.state == 'active' do
            local at, c = trainerLed(view), T.colours[view.scene.rhythm or '']
            if at and c and #(GetEntityCoords(cache.ped) - at) <= (T.seen or 25.0) then
                DrawLightWithRange(at.x, at.y, at.z, c[1], c[2], c[3], 0.35, 6.0)
                Wait(0)
            else
                Wait(250)
            end
        end
        view.glowing = false
    end)
end

PC.looks.cpr = function(view, scene, event)
    if T and not view.objects.trainer then
        local model = PC.model(T.model, T.fallback)
        if model then PC.object(view, 'trainer', model, PC.on(view, T.on), PC.heading(view)) end
    end
    if scene.rhythm then glow(view) end
    local at = trainerLed(view)
    if event.op == 'rhythm' then
        PC.sound(event.tone == 'good' and 'good' or 'bad', at)
    elseif event.op == 'end' then
        PC.sound(scene.result == 'pass' and 'good' or 'bad', at)
    end
end
