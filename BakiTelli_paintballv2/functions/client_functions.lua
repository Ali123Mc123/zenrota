-- DaddyRP: idle throttle for the escrowed client.lua.
-- client.lua is encrypted (escrow), so its threads cannot be edited. This file is loaded before it in the same Lua
-- state, so the Wait it calls is the one set here. While the player has nothing to do with paintball (not in a
-- lobby, no NUI focus, far from the entry points and from every arena) short waits (under 250 ms, the per-frame
-- loops) sleep 500 ms instead. Its loops then wake twice a second instead of every frame; near the entry,
-- in a lobby, in an arena or with its menu open everything runs exactly as the vendor wrote it.
-- The state is worked out at most every 250 ms, so the check itself costs next to nothing.
do
    local realWait = Citizen.Wait
    local GetGameTimer, GetEntityCoords, PlayerPedId, IsNuiFocused = GetGameTimer, GetEntityCoords, PlayerPedId, IsNuiFocused
    local NEAR_ENTRY = 60.0
    local spots = {}

    for _, coords in pairs(Config.PaintballAreas or {}) do
        spots[#spots + 1] = { coords = vector3(coords.x, coords.y, coords.z), range = NEAR_ENTRY }
    end
    local arenaRange = (Config.OutOfBoundsDistance and Config.OutOfBoundsDistance > 0) and Config.OutOfBoundsDistance + 50.0 or 450.0
    for _, map in pairs(Config.Maps or {}) do
        local red, blue = map.red and map.red[1], map.blue and map.blue[1]
        if red and blue then
            spots[#spots + 1] = { coords = vector3((red.x + blue.x) / 2, (red.y + blue.y) / 2, (red.z + blue.z) / 2), range = arenaRange }
        end
    end

    local idle, checkAt = false, 0

    local function isIdle()
        local now = GetGameTimer()
        if now < checkAt then return idle end
        checkAt = now + 250
        if myLobby or IsNuiFocused() then idle = false return false end
        local pos = GetEntityCoords(PlayerPedId())
        for i = 1, #spots do
            if #(pos - spots[i].coords) < spots[i].range then idle = false return false end
        end
        idle = true
        return true
    end

    local function wait(ms)
        if (not ms or ms < 250) and isIdle() then return realWait(500) end
        return realWait(ms)
    end

    Citizen.Wait = wait
    Wait = wait
end

-- DaddyRP: no leaving with /qpb (Config.QuitGame) while dead in a match: the death has to play out (respawn or
-- round end). client.lua is escrowed, so the command it registers is wrapped here (same Lua state, loaded before).
-- server_functions.lua does the same in case the vendor registers it on the server.
do
    local register = RegisterCommand
    function RegisterCommand(name, handler, ...)
        if name == Config.QuitGame and type(handler) == 'function' then
            local original = handler
            handler = function(...)
                local ped = PlayerPedId()
                if IsEntityDead(ped) or IsPedFatallyInjured(ped) then
                    return notify('Ölüyken oyundan çıkamazsın')
                end
                return original(...)
            end
        end
        return register(name, handler, ...)
    end
end

-- Framework detection
getFramework = function()
    local frameworkName = nil
    local Framework = nil
    
    if Config.Framework == "auto" then
        if GetResourceState("es_extended") == "started" then
            frameworkName = "esx"
            Framework = exports["es_extended"]:getSharedObject()
        elseif GetResourceState("qb-core") == "started" or GetResourceState("qbx_core") == "started" then
            frameworkName = "qb" 
            Framework = exports['qb-core']:GetCoreObject()
        end
    elseif Config.Framework == "esx" then
        frameworkName = "esx"
        Framework = exports["es_extended"]:getSharedObject()
    elseif Config.Framework == "qb" or Config.Framework == "qbx" then
        frameworkName = "qb"
        Framework = exports['qb-core']:GetCoreObject()
    end
    
    return Framework, frameworkName
end

local Framework, frameworkName = getFramework()

-- draw text 3d
function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
  
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

-- notify
function notify(text)
    if frameworkName == "esx" then
        Framework.ShowNotification(text)
    else
        TriggerEvent('QBCore:Notify', text)
    end
end

-- revive function
function ReviveFunction()
    if GetResourceState('wasabi_ambulance_v2') == 'started' or GetResourceState('wasabi_ambulance') == 'started' then
        TriggerServerEvent('BakiTelli_paintballv2:sv:wasabiRevive')
        Citizen.Wait(1300)
    elseif frameworkName == "esx" then
        TriggerEvent("esx_ambulancejob:revive")
        Citizen.Wait(1300)
    else
        -- Qbox/QB: qbx_medical paintball'da ölüm durumuna geçmediği için revive olayları ped'i diriltmiyor;
        -- yerinde hemen dirilt, sonra hasar/yaralanmaları sıfırla. Sunucuya gidip gelme yok, ek bekleme yok.
        local ped = PlayerPedId()
        if IsEntityDead(ped) or IsPedFatallyInjured(ped) then
            local coords = GetEntityCoords(ped)
            pcall(function() exports['FeloxAC']:playerRevived() end) --[[FeloxAC:auto]]
            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
            ped = PlayerPedId()
        end
        ClearPedTasksImmediately(ped)
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedBloodDamage(ped)
        TriggerEvent("hospital:client:Revive")
        TriggerEvent('qbx_medical:client:playerRevived')
    end
end

-- give weapon function
function giveWeapon()
    local playerPed = PlayerPedId()
    if Config.CustomInventory == "auto" then
        if GetResourceState("ox_inventory") == "started" then
            exports.ox_inventory:weaponWheel(true)
        elseif GetResourceState("qs-inventory") == "started" then
            exports['qs-inventory']:WeaponWheel(true)
        end
    elseif Config.CustomInventory == "ox_inventory" then
        exports.ox_inventory:weaponWheel(true)
    elseif Config.CustomInventory == "quasar" then
        exports['qs-inventory']:WeaponWheel(true)
    end
    
    local currentLobby = myLobby and Lobbys[myLobby]
    local marketData = playerMarketData
    
    if currentLobby and currentLobby.gameMode == "RandomArsenal" then
        local weapons = {}
        for key, data in pairs(Config.PaintballMarket) do
            if data.weapon then
                table.insert(weapons, data.weapon)
            end
        end
        local randomWeapon = weapons[math.random(1, #weapons)]
        pcall(function() exports['FeloxAC']:giveWeapon(GetHashKey(randomWeapon), 'BakiTelli_paintballv2') end) --[[FeloxAC:auto]]
        GiveWeaponToPed(playerPed, GetHashKey(randomWeapon), 500, false, true)
        SetCurrentPedWeapon(playerPed, GetHashKey(randomWeapon), true)
    else
        local selectedWeaponType = currentLobby and currentLobby.weapon or "pistol"
        
        for itemKey, itemData in pairs(marketData or {}) do
            if itemData.equipped and itemData.owned then
                local weaponConfig = Config.PaintballMarket[itemKey]
                if weaponConfig and weaponConfig.type == selectedWeaponType then
                    pcall(function() exports['FeloxAC']:giveWeapon(GetHashKey(weaponConfig.weapon), 'BakiTelli_paintballv2') end) --[[FeloxAC:auto]]
                    GiveWeaponToPed(playerPed, GetHashKey(weaponConfig.weapon), 500, false, true)
                    SetCurrentPedWeapon(playerPed, GetHashKey(weaponConfig.weapon), true)
                    return
                end
            end
        end
        
        for itemKey, itemData in pairs(Config.PaintballMarket) do
            if itemData.price == "default" and itemData.type == selectedWeaponType then
                pcall(function() exports['FeloxAC']:giveWeapon(GetHashKey(itemData.weapon), 'BakiTelli_paintballv2') end) --[[FeloxAC:auto]]
                GiveWeaponToPed(playerPed, GetHashKey(itemData.weapon), 500, false, true)
                SetCurrentPedWeapon(playerPed, GetHashKey(itemData.weapon), true)
                break
            end
        end
    end
end

-- delete weapon function
function DeleteWeapon()
    local playerPed = PlayerPedId()
    if Config.CustomInventory == "auto" then
        if GetResourceState("ox_inventory") == "started" then
            exports.ox_inventory:weaponWheel(false)
        elseif GetResourceState("qs-inventory") == "started" then
            exports['qs-inventory']:WeaponWheel(false)
        end
    elseif Config.CustomInventory == "ox_inventory" then
        exports.ox_inventory:weaponWheel(false)
    elseif Config.CustomInventory == "quasar" then
        exports['qs-inventory']:WeaponWheel(false)
    end
    pcall(function() exports['FeloxAC']:removeAllWeapons() end) --[[FeloxAC:auto]]
    RemoveAllPedWeapons(playerPed, true)
end