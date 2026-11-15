-- Doors of the shell interiors: E at the entrance walks in, E at the exit marker walks out. The server moves the player into
-- the routing bucket of the place and tells us where to stand.
local doors = {}

local function clear()
    for _, door in ipairs(doors) do door.remove() end
    doors = {}
end

local function door(at, text, event, arg)
    doors[#doors + 1] = Venue.Interact.add({
        coords = vec3(at.x, at.y, at.z), label = text, icon = 'fa-door-open',
        marker = function()
            DrawMarker(1, at.x, at.y, at.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.4, 61, 220, 151, 110, false, false, 2, false, nil, nil, false)
        end,
        onSelect = function() TriggerServerEvent(event, arg) end,
    })
end

local function set(list)
    clear()
    for _, shell in ipairs(list or {}) do
        door(shell.entry, shell.label, 'daddy_venue:shellEnter', shell.id)
        door(shell.interior, L('shell_leave'), 'daddy_venue:shellLeave')
    end
end

RegisterNetEvent('daddy_venue:shells', set)

RegisterNetEvent('daddy_venue:shellMove', function(at)
    DoScreenFadeOut(300)
    while not IsScreenFadedOut() do Wait(0) end
    local ped = cache.ped
    RequestCollisionAtCoord(at.x, at.y, at.z)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(ped, at.x, at.y, at.z, false, false, false)
    if at.h then SetEntityHeading(ped, at.h) end
    local waited = 0
    while not HasCollisionLoadedAroundEntity(ped) and waited < 3000 do Wait(50) waited = waited + 50 end
    DoScreenFadeIn(400)
end)

CreateThread(function()
    set(lib.callback.await('daddy_venue:shells', false))
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then clear() end
end)
