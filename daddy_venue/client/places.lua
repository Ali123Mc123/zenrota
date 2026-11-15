-- Entrances of the places that are still free. A point only wakes up by distance, nothing runs on a timer.

local points, blips = {}, {}

local function clear()
    for _, point in ipairs(points) do point.remove() end
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
    points, blips = {}, {}
end

local function offer(entry)
    local parts = {}
    if entry.buy > 0 then parts[#parts + 1] = L('place_buy') end
    if entry.week > 0 or entry.month > 0 then parts[#parts + 1] = L('place_rent') end
    return table.concat(parts, ' / ')
end

local function build(list)
    clear()
    if type(list) ~= 'table' then return end
    for _, entry in ipairs(list) do
        points[#points + 1] = Venue.Interact.add({
            coords = vec3(entry.x, entry.y, entry.z + 1.0), label = ('%s · %s'):format(entry.label, offer(entry)), icon = 'fa-store', distance = 1.8,
            marker = function()
                DrawMarker(1, entry.x, entry.y, entry.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 61, 220, 151, 120, false, false, 2, false, nil, nil, false)
            end,
            onSelect = function() TriggerServerEvent('daddy_venue:placeOpen', entry.id) end,
        })
        if Config.Blips then
            local blip = AddBlipForCoord(entry.x, entry.y, entry.z)
            SetBlipSprite(blip, 40)
            SetBlipColour(blip, 2)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(entry.label)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
    end
end

RegisterNetEvent('daddy_venue:places', build)

CreateThread(function()
    build(lib.callback.await('daddy_venue:placesState', false))
end)

-- DaddyRP: the businesses on the map, at the door of their place, with their own name and icon (server picks the icon)
local venueBlips = {}

local function buildVenues(list)
    for _, blip in ipairs(venueBlips) do RemoveBlip(blip) end
    venueBlips = {}
    if type(list) ~= 'table' then return end
    for _, entry in ipairs(list) do
        local blip = AddBlipForCoord(entry.x, entry.y, entry.z)
        SetBlipSprite(blip, entry.sprite or 93)
        SetBlipColour(blip, entry.color or 46)
        SetBlipScale(blip, entry.scale or 0.75)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(entry.label)
        EndTextCommandSetBlipName(blip)
        venueBlips[#venueBlips + 1] = blip
    end
end

RegisterNetEvent('daddy_venue:venueBlips', buildVenues)

CreateThread(function()
    buildVenues(lib.callback.await('daddy_venue:venueBlipsState', false))
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    clear()
    buildVenues(nil)
end)

RegisterNetEvent('daddy_venue:transferAsk', function(business, from, price)
    local text = price > 0 and L('transfer_paid', from, business, Config.Currency .. price) or L('transfer_free', from, business)
    local answer = lib.alertDialog({ header = L('transfer_header'), content = text, centered = true, cancel = true })
    TriggerServerEvent('daddy_venue:transferAnswer', answer == 'confirm')
end)
