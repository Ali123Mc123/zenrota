local onlinePlayers, showIds, forceDraw = {}, false, false
local unarmedHash = `WEAPON_UNARMED`

local function GetPedSeatIndex(vehicle, ped)
    for seat = -1, 16 do
        if GetPedInVehicleSeat(vehicle, seat) == ped then
            return seat
        end
    end
    return nil
end

lib.addKeybind({
    name = 'show_player_ids',
    description = "Oyuncu ID'lerini Göster",
    defaultKey = 'PRIOR', -- PAGEUP
    onPressed = function()
        showIds = true
    end,
    onReleased = function()
        showIds = false
    end
})

Citizen.CreateThread(function()
    TriggerServerEvent("tgiann-showid:add-id")

    while true do
        if not lib then
            showIds = IsControlPressed(0, TGIANN.key)
        end
        local isActuallyShowing = showIds or forceDraw

        if isActuallyShowing then
            local playerPed = PlayerPedId()
            local currentWeapon = GetSelectedPedWeapon(playerPed)
            local currentVehicle = GetVehiclePedIsIn(playerPed, false)

            local canDraw = (currentWeapon == unarmedHash) or (currentVehicle ~= 0)
            if canDraw then
                local nearbyPlayers = GetNeareastPlayers()

                for i = 1, #nearbyPlayers do
                    local v = nearbyPlayers[i]
                    local offsetX = 0
                    local offsetY = 0
                    local height = 0.9

                    if v.vehicle and v.vehicle ~= 0 then
                        local seatIndex = GetPedSeatIndex(v.vehicle, v.ped)
                        if seatIndex then
                            if seatIndex % 2 == 0 then offsetX = 0.3 else offsetX = -0.3 end
                            if seatIndex >= 1 then offsetY = -0.5 end
                        end
                    end

                    local p1 = GetOffsetFromEntityInWorldCoords(v.ped, offsetX, offsetY, height)
                    local p2 = GetOffsetFromEntityInWorldCoords(v.ped, offsetX, offsetY, height + 0.2)

                    Draw3DText(p1.x, p1.y, p1.z, v.playerId, 1.2)
                    Draw3DText(p2.x, p2.y, p2.z, v.topText, 0.8)
                end
                Citizen.Wait(0)
            else
                Citizen.Wait(500)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('tgiann-showid:client:add-id')
AddEventHandler('tgiann-showid:client:add-id', function(identifier, playerSource)
    if playerSource then
        onlinePlayers[tostring(playerSource)] = identifier
    else
        onlinePlayers = identifier
    end
end)

RegisterNetEvent('tgiann-showid:client:remove-id', function(playerSource)
    if playerSource then
        onlinePlayers[tostring(playerSource)] = nil
    end
end)

RegisterCommand(TGIANN.commandName, function()
    if not forceDraw then
        forceDraw = true
        Citizen.SetTimeout(5000, function()
            forceDraw = false
        end)
    end
end)

function Draw3DText(x, y, z, text, newScale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local dist = #(GetGameplayCamCoords() - vector3(x, y, z))
        local scale = newScale * (1 / dist) * (1 / GetGameplayCamFov()) * 100
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function GetNeareastPlayers()
    local players_clean = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleIndexes = {}

    local players = GetActivePlayers()
    for i = 1, #players, 1 do
        local ped = GetPlayerPed(players[i])
        local targetCoords = GetEntityCoords(ped)

        if #(playerCoords - targetCoords) <= TGIANN.drawDistance then
            local playerServerId = tostring(GetPlayerServerId(players[i]))
            local identifier = onlinePlayers[playerServerId]

            if identifier and IsEntityVisible(ped) then
                local vehicleIndex = 0
                local vehicle = GetVehiclePedIsIn(ped, false)

                if vehicle ~= 0 then
                    if not vehicleIndexes[vehicle] then
                        vehicleIndexes[vehicle] = 0
                    end
                    vehicleIndex = vehicleIndexes[vehicle]
                    vehicleIndexes[vehicle] = vehicleIndexes[vehicle] + 1
                end

                table.insert(players_clean, {
                    topText = identifier:upper(),
                    playerId = playerServerId,
                    coords = targetCoords,
                    vehicleIndex = vehicleIndex,
                    vehicle = vehicle,
                    ped = ped
                })
            end
        end
    end

    return players_clean
end
