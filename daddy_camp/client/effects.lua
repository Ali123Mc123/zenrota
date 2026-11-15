-- Flames, glow and light of the pieces in the world (fire, stove, lights set down) and the food cooking on them.
local defs = Config.Pieces
Effects = { on = {}, props = {}, shown = {} } -- on: pieces giving flames or light; shown: the lights drawn now

local function offset(entity, v)
    return GetOffsetFromEntityInWorldCoords(entity, v.x, v.y, v.z)
end

-- What a piece gives in this state: particle effect, light, the point the effect comes from and (when apart) the light's.
local function lookOf(p)
    local def = defs[p.key]
    if p.key == 'fire_pit' and (p.state == 'burning' or p.state == 'embers') then
        local light = Config.Fire.Light
        local embers = p.state == 'embers'
        return Config.Fire.Effects[p.state], { color = light.color, range = light.range * (embers and 0.6 or 1.0), intensity = light.intensity * (embers and 0.4 or 1.0) },
            vec3(0.0, 0.0, Config.Fire.FlameHeight or 0.0), def.socket + vec3(0.0, 0.0, 0.35)
    end
    if p.key == 'stove' and p.state == 'on' then return Config.Stove.Effect, Config.Stove.Light, def.socket end
    if def.kind == 'light' and (p.state == 'on' or p.state == 'lit') then return def.effect, def.light, def.socket end
end
Effects.lookOf = lookOf

-- Starts a looped particle effect on an entity; returns its handle.
function Effects.particle(effect, entity, at, scale)
    if not effect then return nil end
    lib.requestNamedPtfxAsset(effect[1], 5000)
    UseParticleFxAssetNextCall(effect[1])
    return StartParticleFxLoopedOnEntity(effect[2], entity, at.x, at.y, at.z, 0.0, 0.0, 0.0, (scale or 1.0) * effect[3], false, false, false)
end

-- One frame of a light at an entity's socket; a spot shines along the holder's (or the prop's) forward.
function Effects.draw(light, entity, socket, forward)
    local at = offset(entity, socket)
    local c = light.color
    if light.spot then
        local dir = forward or GetEntityForwardVector(entity)
        DrawSpotLight(at.x, at.y, at.z, dir.x, dir.y, dir.z - 0.15, c[1], c[2], c[3], light.range, light.intensity, 0.0, light.radius or 15.0, 1.0)
    else
        DrawLightWithRange(at.x, at.y, at.z, c[1], c[2], c[3], light.range, light.intensity)
    end
end

local function cookProp(p, entity)
    local job = p.data and p.data.cook
    local look = job and job.prop and Config.CookProps[job.prop]
    if not look then return end
    local def = defs[p.key]
    local base = def.kind == 'fire' and vec3(0.0, 0.0, 0.0) or def.socket or (def.sockets and vec3(0.0, 0.0, def.sockets[1].z)) or vec3(0.0, 0.0, 0.0)
    local model = Client.model({ models = { default = job.done and look.done or look.raw }, fallback = look.fallback }, 'default')
    if not Client.load(model) then return end
    local at = offset(entity, base + look.offset.xyz)
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    local prop = CreateObjectNoOffset(model, at.x, at.y, at.z, false, false, false)
    SetEntityHeading(prop, GetEntityHeading(entity) + look.offset.w)
    FreezeEntityPosition(prop, true)
    SetEntityCollision(prop, false, false)
    SetModelAsNoLongerNeeded(model)
    Effects.props[p.id] = prop
end

function Effects.start(p, entity)
    local effect, light, socket, lightAt = lookOf(p)
    if effect or light then Effects.on[p.id] = { entity = entity, effect = effect, light = light, socket = socket, lightAt = lightAt or socket } end
    cookProp(p, entity)
end

function Effects.stop(id)
    local on = Effects.on[id]
    if on and on.fx then StopParticleFxLooped(on.fx, false) end
    if Effects.props[id] and DoesEntityExist(Effects.props[id]) then DeleteEntity(Effects.props[id]) end
    Effects.on[id], Effects.props[id] = nil, nil
end

-- Twice a second: flames start and stop by distance, and only the nearest few lights are kept to draw.
CreateThread(function()
    local flames, cfg = Config.Stream.Flames, Config.Stream
    while true do
        local me, near = GetEntityCoords(PlayerPedId()), {}
        for _, on in pairs(Effects.on) do
            if DoesEntityExist(on.entity) then
                local d = #(GetEntityCoords(on.entity) - me)
                if on.effect and not on.fx and d < flames then
                    on.fx = Effects.particle(on.effect, on.entity, on.socket)
                elseif on.fx and d > flames + 5.0 then
                    StopParticleFxLooped(on.fx, false)
                    on.fx = nil
                end
                if on.light and d < flames then near[#near + 1] = { on = on, d = d } end
            end
        end
        table.sort(near, function(a, b) return a.d < b.d end)
        local shown = {}
        for i = 1, math.min(#near, cfg.Lights) do shown[i] = near[i].on end
        Effects.shown = shown
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        local shown = Effects.shown
        for _, on in ipairs(shown) do
            if DoesEntityExist(on.entity) then Effects.draw(on.light, on.entity, on.lightAt) end
        end
        Wait(#shown > 0 and 0 or 500)
    end
end)
