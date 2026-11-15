-- Kiosk points, map blips and the delivery route. Nothing here runs on a timer: points wake
-- up by distance (ox_lib) or by the target system, the rest is event driven.

local points, blips = {}, {}
local route = { blip = nil, point = nil }

local function clear()
    for _, point in ipairs(points) do point.remove() end
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
    points, blips = {}, {}
end

local function build(list)
    clear()
    if type(list) ~= 'table' then return end
    for _, entry in ipairs(list) do
        local coords = vec3(entry.x, entry.y, entry.z)
        points[#points + 1] = Venue.Interact.add({
            coords = coords, label = ('%s · %s'):format(entry.name, L('order_here')), icon = 'fa-utensils', distance = Config.KioskRange,
            onSelect = function() TriggerEvent('daddy_venue:openKiosk') end,
        })
        if Config.Blips then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 93)
            SetBlipColour(blip, 2)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(entry.name)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
    end
end

local function clearRoute()
    if route.blip then RemoveBlip(route.blip) end
    if route.point then route.point:remove() end
    route.blip, route.point = nil, nil
end

-- the courier walks or drives there and the server decides if they really arrived
local function setRoute(data)
    clearRoute()
    if type(data) ~= 'table' or not data.x then return end
    local coords = vec3(data.x, data.y, data.z)
    route.blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(route.blip, 1)
    SetBlipColour(route.blip, 5)
    SetBlipRoute(route.blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(L('delivery'))
    EndTextCommandSetBlipName(route.blip)
    route.point = lib.points.new({
        coords = coords, distance = Config.DeliveryArrive,
        onEnter = function() TriggerServerEvent('daddy_venue:deliver') end,
    })
end

RegisterNetEvent('daddy_venue:points', build)
RegisterNetEvent('daddy_venue:route', setRoute)

local function load()
    local state = lib.callback.await('daddy_venue:points', false)
    if type(state) ~= 'table' then return end
    build(state.points)
    setRoute(state.route)
end

CreateThread(load)

-- DaddyRP: with multichar the resource starts before a character is chosen, so the delivery route of the courier
-- comes once the character is loaded; logging out drops the route of the old one
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() CreateThread(load) end)
RegisterNetEvent('esx:playerLoaded', function() CreateThread(load) end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', clearRoute)
RegisterNetEvent('esx:onPlayerLogout', clearRoute)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    clear()
    clearRoute()
end)
