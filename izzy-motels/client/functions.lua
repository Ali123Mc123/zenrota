function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if scale < 0.5 then
        scale = 0.5
    end

    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function CreateBlip(coords, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.BlipConfig.sprite)
    SetBlipColour(blip, Config.BlipConfig.color)
    SetBlipScale(blip, Config.BlipConfig.size)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

function HandleBuyMotelZone(coords)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.2 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, "E - " .. MotelText(currentZone, 'OpenBuyMenu'))
            if IsControlJustReleased(0, 38) then
                OpenBuyMotelMenu()
            end
        end
    end
end

function HandleActionZone(coords)
    -- if currentZone == nil then return end

    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, "E - İşlem Menüsü")
            if IsControlJustReleased(0, 38) then
                if currentRoom ~= nil then
                    OpenActionMenu()
                else
                    ExitMotelRoom()
                end
            end
        end
    end
end

function HandleStashZone(coords)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, "E - Depo")
            if IsControlJustReleased(0, 38) then
                OpenStash()
            end
        end
    end
end

function HandleClothingZone(coords)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, "E - Gardırop")
            if IsControlJustReleased(0, 38) then
                OpenClothing()
            end
        end
    end
end

function OpenStash()
    local response = lib.callback.await('izzy-motels:server:doIOwnedThisRoom', false, currentZone, currentRoom)

    if response then
        if currentRoom == nil then
            return Framework:Notify(Config.Local.NeedToBeInRoom, "error")
        end

        if currentZone == nil then
            return Framework:Notify(Config.Local.NeedToBeInZoone, "error")
        end

        Framework:OpenStash(currentRoom, currentZone)
    else
        Framework:Notify(Config.Local.NoPermission, "error")
    end
end

function OpenClothing()
    local response = lib.callback.await('izzy-motels:server:doIOwnedThisRoom', false, currentZone, currentRoom)

    if response then
        Framework:OpenClothing()
    else
        Framework:Notify(Config.Local.NoPermission, "error")
    end
end

function HandleMotelRoomsZone(coords)
    if currentZone == nil then return end
    if menuOpened then return end

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)

    if distance < 18.0 then
        DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 255, 0, 100, false, true, 2, true, nil, nil, false)
        if distance < 1.5 then
            Draw3DText(coords.x, coords.y, coords.z + 0.4, "E - Odalarım")
            if IsControlJustReleased(0, 38) then
                OpenMotelsMenu()
            end
        end
    end
end

function OpenBuyMotelMenu()
    if currentZone == nil then return end
    
    if cachedMugshot == nil then
        cachedMugshot = GetMugShotBase64(PlayerPedId(), false)
    end

    SendNUIMessage({
        action = "openBuyMotelMenu",
        mugshot = cachedMugshot,
        personalInfo = lib.callback.await('izzy-motels:server:getPersonalInfo', false),
        motelData = lib.callback.await('izzy-motels:server:getFreeRooms', false, currentZone),
        costPerDay = MotelCost(currentZone),
        labels = MotelLabels(currentZone),
        maxRooms = Config.Motels[currentZone].maxRooms,
    })
    SetNuiFocus(true, true)

    menuOpened = true
end

function OpenMotelsMenu()
    if currentZone == nil then return end
    
    if cachedMugshot == nil then
        cachedMugshot = GetMugShotBase64(PlayerPedId(), false)
    end

    SendNUIMessage({
        action = "openMyMotelsMenu",
        mugshot = cachedMugshot,
        personalInfo = lib.callback.await('izzy-motels:server:getPersonalInfo', false),
        myRooms = lib.callback.await('izzy-motels:server:myMotels', false, currentZone),
        costPerDay = MotelCost(currentZone),
        labels = MotelLabels(currentZone),
        configMotels = Config.Motels
    })
    SetNuiFocus(true, true)

    menuOpened = true
end

function lastCheck()
    local lastMotel = lib.callback.await('izzy-motels:server:getLast', false)
    if lastMotel then
        ExitMotelRoom(true)
        Citizen.Wait(1000)
        currentZone = lastMotel["motel"]
        
        EnterMotelRoom(lastMotel["room"])
    end
end


if not Config.DisableLastCheck then
    AddEventHandler('esx:playerLoaded', lastCheck)
    AddEventHandler('QBCore:Client:OnPlayerLoaded', lastCheck)
end

-- RegisterCommand('baran', function()

--     local lastMotel = lib.callback.await('izzy-motels:server:getLast', false)
--     if lastMotel then
--         ExitMotelRoom(true)
--         Citizen.Wait(1000)
--         currentZone = lastMotel["motel"]
        
--         EnterMotelRoom(lastMotel["room"])
--     end
-- end)

function EnterMotelRoom(roomId)
    if currentZone == nil then return end
    if menuOpened then return end
    local response = lib.callback.await('izzy-motels:server:enterRoom', false, currentZone, roomId)
    if response then
        currentRoom = roomId
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(PlayerPedId(), 93.42, -485.96, -109.01)
        TriggerServerEvent('izzy-motels:saveLast', curr) -- is it correct? I mean the curr

        if response.color == "yellow" then
            SetInteriorEntitySetColor(interiorID, "tint", 1)
        elseif response.color == "red" then
            SetInteriorEntitySetColor(interiorID, "tint", 4)
        elseif response.color == "gray" then
            SetInteriorEntitySetColor(interiorID, "tint", 12)
        elseif response.color == "green" then
            SetInteriorEntitySetColor(interiorID, "tint", 29)
        elseif response.color == "blue" then
            SetInteriorEntitySetColor(interiorID, "tint", 36)
        elseif response.color == "purple" then
            SetInteriorEntitySetColor(interiorID, "tint", 39)
        elseif response.color == "white" then
            SetInteriorEntitySetColor(interiorID, "tint", 57)
        elseif response.color == "black" then
            SetInteriorEntitySetColor(interiorID, "tint", 14)
        end
    end
end

function ExitMotelRoom(save)
    local response = lib.callback.await('izzy-motels:server:exitRoom', false, currentRoom, save)
    if currentZone ~= nil then 
        outCoords = Config.Motels[currentZone].outCoords
    else
        local lastMotel = lib.callback.await('izzy-motels:server:getLast', false)
        outCoords = lastMotel and lastMotel["motel"] and Config.Motels[lastMotel["motel"] or 1].outCoords or Config.Motels[1].outCoords
    end

    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(PlayerPedId(), outCoords.x, outCoords.y, outCoords.z)
    SetEntityHeading(PlayerPedId(), outCoords.w)

    currentRoom = nil
end

function TpOrOpenMenu()
    if currentRoom ~= nil then
        local response = lib.callback.await('izzy-motels:server:doIOwnedThisRoom', false, currentZone, currentRoom)

        if response then
            OpenActionMenu()
        else
            ExitMotelRoom()
        end
    else
        ExitMotelRoom()
    end
end

function OpenInviteMenu()
    if currentZone == nil then return end
    if currentRoom == nil then return end

    SendNUIMessage({
        action = "openInviteMenu",
        labels = MotelLabels(currentZone),
        players = lib.callback.await('izzy-motels:server:getPlayersNearby', false, currentZone),
    })

    SetNuiFocus(true, true)
    menuOpened = true
end

function OpenActionMenu()
    if currentRoom == nil then ExitMotelRoom() end

    SendNUIMessage({
        action = "openActionMenu",
        labels = MotelLabels(currentZone),
        players = lib.callback.await('izzy-motels:server:getPlayersNearby', false, currentZone),
    })

    SetNuiFocus(true, true)
    menuOpened = true
end

function CreateInviteJob(motelId, roomId)
    local canPressable = true
    local invitemesaj = string.format(Config.Local.InvitedToRoom, roomId)
    Framework:Notify(invitemesaj, "success")

    Framework:Notify(Config.Local.ToAcceptInvite, "success")

    Citizen.CreateThread(function()
        local timer = 0
        while timer < 30 do
            timer = timer + 1
            Citizen.Wait(1000)
        end

        canPressable = false
        Framework:Notify(Config.Local.InviteExpired, "error")
    end)

    Citizen.CreateThread(function()
        while canPressable do
            if IsControlJustReleased(0, 38) then
                canPressable = false
                currentZone = motelId
                EnterMotelRoom(roomId)
            end
            Citizen.Wait(0)
        end
    end)

    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)

    local outCoords = Config.Motels[motelId].outCoords

    outCoords = vector3(outCoords.x, outCoords.y, outCoords.z)

    local distance = #(playerCoords - outCoords)

    if distance > 15.0 then
        Framework:Notify(MotelText(motelId, 'TooFaarAway'), "error")
        canPressable = false
        return
    end
end