-- No target resource: a key prompt near each target, a menu when it has several options.
local targets, shown, running = {}, nil, false
local KEY = 38

local function hide()
    if shown then lib.hideTextUI() end
    shown = nil
end

-- What the options get: the entity, the nearest player or the nearest object of the models.
local function subject(target) return target.entity or target.player or target.object end

local function usable(target)
    local out = {}
    for _, option in ipairs(target.options) do
        if not option.canInteract or option.canInteract(subject(target)) then out[#out + 1] = option end
    end
    return out
end

local function choose(key, options, entity)
    if #options == 1 then return options[1].onSelect(entity) end
    local menu = {}
    for i, option in ipairs(options) do
        menu[i] = { title = option.label, icon = option.icon, onSelect = function() option.onSelect(entity) end }
    end
    lib.registerContext({ id = DL.resource .. ':target:' .. key, title = DL.locale.lib('target.choose'), options = menu })
    lib.showContext(DL.resource .. ':target:' .. key)
end

-- Distance from the player to a target's edge.
local function reach(target, coords)
    if target.players then
        local best, bestPed = math.huge, nil
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if player ~= PlayerId() and DoesEntityExist(ped) then
                local dist = #(coords - GetEntityCoords(ped)) - 1.0
                if dist < best then best, bestPed = dist, ped end
            end
        end
        target.player = bestPed
        return best
    end
    if target.models then
        local best, found = math.huge, nil
        for _, hash in ipairs(target.models) do
            local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, target.distance + 1.0, hash, false, false, false)
            local dist = object ~= 0 and #(coords - GetEntityCoords(object)) - 1.0 or math.huge
            if dist < best then best, found = dist, object end
        end
        target.object = found
        return best
    end
    if target.entity then
        if not DoesEntityExist(target.entity) then return math.huge end
        return #(coords - GetEntityCoords(target.entity)) - 1.0
    end
    return #(coords - target.center) - target.radius
end

local function nearest(coords)
    local best, bestDist
    for key, target in pairs(targets) do
        local dist = reach(target, coords)
        if dist <= target.distance and (not bestDist or dist < bestDist) then best, bestDist = key, dist end
    end
    return best
end

local function loop()
    if running then return end
    running = true
    CreateThread(function()
        while next(targets) do
            local key = nearest(GetEntityCoords(PlayerPedId()))
            local options = key and usable(targets[key]) or {}
            if #options == 0 then
                hide()
                Wait(key and 250 or 750)
            else
                if shown ~= key then
                    shown = key
                    lib.showTextUI(('[E] %s'):format(#options == 1 and options[1].label or DL.locale.lib('target.interact')))
                end
                if IsControlJustReleased(0, KEY) then choose(key, options, subject(targets[key])) end
                Wait(0)
            end
        end
        hide()
        running = false
    end)
end

-- Every kind becomes a sphere: center and radius around the target.
local SHAPE = {
    box = function(d) return d.coords, math.max(d.size.x, d.size.y) * 0.5 end,
    sphere = function(d) return d.coords, d.radius end,
    poly = function(d)
        local center, radius = DL.geo.bounds(d.points)
        return vector3(center.x, center.y, (d.minZ + d.maxZ) * 0.5), radius
    end,
}

return {
    add = function(key, kind, d)
        local target = { options = d.options, distance = d.distance + 0.5, entity = d.entity, players = kind == 'players', models = d.models }
        if SHAPE[kind] then target.center, target.radius = SHAPE[kind](d) end
        targets[key] = target
        loop()
    end,

    remove = function(key)
        targets[key] = nil
        if shown == key then hide() end
    end,
}
