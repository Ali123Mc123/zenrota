-- Lighting controller, neon effects and wheel stance.

local function hex(c)
    return type(c) == 'table' and ('#%02x%02x%02x'):format(c[1] or 255, c[2] or 255, c[3] or 255) or '#ffffff'
end

RegisterNetEvent('daddy_mechanic:lightsMenu', function()
    local vehicle = cache.vehicle
    if not vehicle then return end
    local _, r, g, b = GetVehicleXenonLightsCustomColor(vehicle)
    local nr, ng, nb = GetVehicleNeonLightsColour(vehicle)
    local effects = {}
    for _, e in ipairs(Config.Lights.Effects) do effects[#effects + 1] = { value = e, label = Core.t('ui.effect_' .. e) } end
    local input = lib.inputDialog(Core.t('items.' .. Config.Lights.Item), {
        { type = 'color', label = Core.t('keys.customXenonColor'), default = hex({ r, g, b }) },
        { type = 'color', label = Core.t('keys.neonColor'), default = hex({ nr, ng, nb }) },
        { type = 'select', label = Core.t('ui.effect'), options = effects, default = ((Entity(vehicle).state.dmech or {}).lights or {}).effect or 'static' },
    })
    if not input then return end
    local ok, why = lib.callback.await('daddy_mechanic:setLights', false, { xenon = input[1], neon = input[2], effect = input[3] })
    if not ok then Bridge.notify(nil, why or Core.t('msg.failed'), 'error') end
end)

local fancy = {}

local previews = {}
local STOCK = { height = 0.0, camber = { 0.0, 0.0, 0.0, 0.0 }, track = { 1.0, 1.0, 1.0, 1.0 } }

local function neonState(vehicle)
    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    local sides = {}
    for side = 0, 3 do sides[side] = IsVehicleNeonLightEnabled(vehicle, side) end
    return { colour = { r, g, b }, sides = sides }
end

local function watch(vehicle, data)
    data = data or {}
    local before = fancy[vehicle]
    local lights = data.lights and data.lights.effect ~= 'static' and data.lights or nil
    if before and before.neon and not lights then
        for side = 0, 3 do SetVehicleNeonLightEnabled(vehicle, side, before.neon.sides[side]) end
        local c = data.lights and data.lights.neon or before.neon.colour
        SetVehicleNeonLightsColour(vehicle, c[1], c[2], c[3])
    end
    local stance = Catalog.stanceOf(data.stance)
    if lights or stance or previews[vehicle] ~= nil then
        local neon = lights and ((before and before.neon) or neonState(vehicle)) or nil
        fancy[vehicle] = { lights = lights, stance = stance, offsets = before and before.offsets, neon = neon }
        return
    end
    fancy[vehicle] = nil
    for i, x in pairs(before and before.offsets or {}) do
        SetVehicleWheelXOffset(vehicle, i, x)
        SetVehicleWheelYRotation(vehicle, i, 0.0)
    end
    if before and before.offsets then SetVehicleSuspensionHeight(vehicle, 0.0) end
end

local function carOf(bagName)
    local vehicle = GetEntityFromStateBagName(bagName)
    for _ = 1, 20 do
        if vehicle ~= 0 then return vehicle end
        Wait(100)
        vehicle = GetEntityFromStateBagName(bagName)
    end
    return 0
end

Stance = {}

function Stance.of(vehicle)
    return Catalog.stanceOf((Entity(vehicle).state.dmech or {}).stance) or false
end

function Stance.preview(vehicle, stance)
    if not DoesEntityExist(vehicle) then return end
    previews[vehicle] = stance
    watch(vehicle, Entity(vehicle).state.dmech)
end

AddStateBagChangeHandler('dmech', nil, function(bagName, _, data)
    local vehicle = carOf(bagName)
    if vehicle ~= 0 then watch(vehicle, data) end
end)

-- The custom xenon colour is never synced by the game, so every client puts it on from the car's bag.
AddStateBagChangeHandler('dmech:xenon', nil, function(bagName, _, colour)
    local vehicle = carOf(bagName)
    if vehicle == 0 then return end
    if type(colour) == 'table' then SetVehicleXenonLightsCustomColor(vehicle, colour[1], colour[2], colour[3])
    else ClearVehicleXenonLightsCustomColor(vehicle) end
end)

local function offsets(vehicle)
    local out = {}
    for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do out[i] = GetVehicleWheelXOffset(vehicle, i) end
    return out
end

CreateThread(function()
    local tick, hue = 0, 0
    while true do
        if next(fancy) then
            tick = tick + 1
            local me = GetEntityCoords(cache.ped)
            for vehicle, f in pairs(fancy) do
                if not DoesEntityExist(vehicle) then
                    fancy[vehicle], previews[vehicle] = nil, nil
                elseif #(GetEntityCoords(vehicle) - me) < 60.0 then
                    local st = previews[vehicle]
                    if st == nil then st = f.stance elseif st == false then st = STOCK end
                    if st then
                        f.offsets = f.offsets or offsets(vehicle)
                        for i, x in pairs(f.offsets) do
                            local at = (i < 2 and 1 or 3) + (x < 0 and 0 or 1)
                            SetVehicleWheelXOffset(vehicle, i, x * st.track[at])
                            SetVehicleWheelYRotation(vehicle, i, (x < 0 and -1 or 1) * st.camber[at])
                        end
                        SetVehicleSuspensionHeight(vehicle, -st.height)
                    end
                    if f.lights and tick % 9 == 0 then
                        if f.lights.effect == 'flash' then
                            local on = (tick // 9) % 2 == 0
                            for side = 0, 3 do
                                if f.neon and f.neon.sides[side] then SetVehicleNeonLightEnabled(vehicle, side, on) end
                            end
                        elseif f.lights.effect == 'rainbow' then
                            hue = (hue + 12) % 360
                            local r, g, b = 0, 0, 0
                            local h = hue / 60
                            local x = math.floor(255 * (1 - math.abs(h % 2 - 1)))
                            if h < 1 then r, g = 255, x elseif h < 2 then r, g = x, 255 elseif h < 3 then g, b = 255, x
                            elseif h < 4 then g, b = x, 255 elseif h < 5 then r, b = x, 255 else r, b = 255, x end
                            SetVehicleNeonLightsColour(vehicle, r, g, b)
                        end
                    end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
