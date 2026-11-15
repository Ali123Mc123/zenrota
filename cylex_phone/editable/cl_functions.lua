local phonePropHashes = {
    [`cylex_phoneprop`] = true,
    [`prop_amb_phone_01`] = true,
    [`prop_phone_ing`] = true,
    [`prop_npc_phone`] = true,
    [`prop_v_m_phone`] = true,
}

local function cleanStuckPhoneFromHand()
    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    local objects = GetGamePool('CObject')
    for i = 1, #objects do
        local obj = objects[i]
        if DoesEntityExist(obj) and GetEntityAttachedTo(obj) == ped then
            local model = GetEntityModel(obj)
            if phonePropHashes[model] then
                SetEntityAsMissionEntity(obj, false, true)
                DetachEntity(obj, true, true)
                DeleteEntity(obj)
            end
        end
    end
end

RegisterNetEvent('cylex_phone:client:openPhone', function(bool)
    local target = bool ~= nil and bool or not PhoneClient.isOpen
    openPhone(target)
    if not target then
        SetTimeout(750, cleanStuckPhoneFromHand)
    end
end)

-- [[ Telefon kapalıyken elde prop yapışık kalırsa temizleyen kontrol ]]
CreateThread(function()
    while not CodeLoaded do Citizen.Wait(500) end
    while true do
        Citizen.Wait(1000)
        local inCall = LocalPlayer.state.callData and next(LocalPlayer.state.callData) ~= nil
        if PhoneClient and not PhoneClient.isOpen and not inCall then
            cleanStuckPhoneFromHand()
        end
    end
end)


CreateThread(function()
    -- [[  OPEN PHONE ]]
    while not CodeLoaded do 
        Citizen.Wait(500) 
    end
    RegisterCommand(Config.OpenCommand, function()
        if not Cylex.CanOpenPhone() then return end
        openPhone(not PhoneClient.isOpen)
    end)
    RegisterKeyMapping(Config.OpenCommand, language('main', 'keybind_settings_open_phone'), 'keyboard', Config.OpenKey)


    -- [[  ANSWER PHONE CALLS ]]
    RegisterCommand('a', function()
         if not Cylex.CanOpenPhone() then 
            return 
        end
        local data = LocalPlayer.state.callData
        if not data or next(data) == nil then 
            return 
        end
        TriggerServerEvent('cylex_phone:server:startConversation', data.targetNumber, "accept")
    end)
    RegisterKeyMapping('a', language('main', 'keybind_settings_answer'), 'keyboard', "")


    -- [[  REJECT PHONE CALLS ]]
    RegisterCommand('h', function()
        local data = LocalPlayer.state.callData
        if not data or next(data) == nil then 
            return
        end
        TriggerServerEvent('cylex_phone:server:startConversation', data.targetNumber, "reject")
    end)
    RegisterKeyMapping('h', language('main', 'keybind_settings_reject'), 'keyboard', "")


    -- [[  LOOK AROUND ]]
    RegisterCommand('+lookaround', function()
        if not PhoneClient.isOpen then return end
        lookAround = true
        SetNuiFocus(false, false)
    end)

    RegisterCommand('-lookaround', function()
        if not PhoneClient.isOpen then return end
        lookAround = false
        SetCursorLocation(0.5, 0.5)
        SetNuiFocus(true, true)
    end)
    RegisterKeyMapping('+lookaround', language('main', 'keybind_settings_look_around'), 'keyboard', "LMENU")
end)

-- RegisterCommand('confirmTest', function()
--     local confirm = exports['cylex_phone']:DoPhoneConfirmation('Sözleşme teklifi', 'Sözleşmeyi kabul ediyor musunuz?')
--     -- print('confirm', confirm)
-- end)

GiveVehicleKey = function(plate, model, hash)
    -- This is for garage app's vale.
    -- If you have custom vehicle key script, you can integrate it here.
    local model = GetDisplayNameFromVehicleModel(hash)
    if GetResourceState('qs-vehiclekeys') == 'started' then
        exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
    elseif GetResourceState('tgiann-hotwire') == 'started' then
        exports['tgiann-hotwire']:GiveKeyPlate(plate, true)
    else
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end

    -- Safety check: ensure vehicle properties are applied upon valet delivery
    CreateThread(function()
        Wait(500)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 25.0, 0, 71)
        if DoesEntityExist(vehicle) then
            local attempts = 0
            while not NetworkHasControlOfEntity(vehicle) and attempts < 10 do
                NetworkRequestControlOfEntity(vehicle)
                Wait(50)
                attempts = attempts + 1
            end

            local state = Entity(vehicle).state
            if state and (state.applyVehicleProps or state.needsPropsApplied or state.vehicleProps) then
                local propsToApply = state.applyVehicleProps or state.vehicleProps
                if propsToApply and type(propsToApply) == "table" then
                    if GetResourceState('daddy_mechanic') == 'started' then
                        exports.daddy_mechanic:setProps(vehicle, propsToApply)
                    elseif GetResourceState('jg-mechanic') == 'started' then
                        exports['jg-mechanic']:setVehicleProperties(vehicle, propsToApply)
                    elseif lib and lib.setVehicleProperties then
                        lib.setVehicleProperties(vehicle, propsToApply)
                    end
                    state:set("applyVehicleProps", nil, true)
                    state:set("needsPropsApplied", nil, true)
                end
            end
        end
    end)
end

OnToggleDuty = function()
    TriggerServerEvent('QBCore:ToggleDuty')
    TriggerServerEvent('BSCore:ToggleDuty')
    TriggerServerEvent('cylex_phone:server:ToggleDuty')
end

SetVehicleFUEL = function(vehicle, fuel)
    if GetResourceState('savana-fuel') == "started" then
        exports['savana-fuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState('LegacyFuel') == "started" then
        exports['LegacyFuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState('qb-fuel') == "started" then
        exports['qb-fuel']:SetFuel(vehicle, fuel)
    elseif GetResourceState('cdn-fuel') == "started" then
        exports['cdn-fuel']:SetFuel(vehicle, fuel)
    end
end

RegisterCommand('phone_debug', function()
    Config.Debug = not Config.Debug
    SendNUIMessage({
        action = 'set_debug',
        debug = Config.Debug,
    })
    if Config.Debug then
        _print("Debug mode enabled")
    else
        _print("Debug mode disabled")
    end
end)

exports('IsOpen', function()
    return PhoneClient and PhoneClient.isOpen
end)

exports('GetConfig', function()
    return Config
end)