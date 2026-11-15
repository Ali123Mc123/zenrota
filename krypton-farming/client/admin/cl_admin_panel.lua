local Config = Config
local cfg = Config.AdminPanel or {}

local AdminNUIOpen = false

function OpenAdminNUI()
    if AdminNUIOpen then return end
    -- Close NPC menu if it's open (prevents focus conflict)
    if ClientState.isUiOpen then
        SendNUIMessage({ action = 'close' })
        SetNuiFocus(false, false)
        ClientState.isUiOpen = false
        Wait(100)
    end
    AdminNUIOpen = true
    ClientState.adminOpen = true
    TriggerServerEvent('krypton-farming:admin:requestFarms')
    TriggerServerEvent('krypton-farming:admin:requestItems')
    TriggerServerEvent('krypton-farming:admin:requestStats')
    -- Wait for chat to fully close before capturing NUI focus
    CreateThread(function()
        Wait(100)
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end)
    SendNUIMessage({
        action = 'openAdminPanel',
        data = {
            locales = type(GetLang) == 'function' and GetLang() or {},
            config = {
                eventsEnabled = IsEventSystemEnabled(),
            }
        }
    })
end

function CloseAdminNUI()
    AdminNUIOpen = false
    ClientState.adminOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeAdminPanel' })
end

RegisterNUICallback('adminClose', function(_, cb)
    CloseAdminNUI()
    cb('ok')
end)

RegisterNUICallback('adminUpdateFarm', function(data, cb)
    if data and data.farmId and data.updates then
        TriggerServerEvent('krypton-farming:admin:updateFarm', data.farmId, data.updates)
    end
    cb('ok')
end)

RegisterNUICallback('adminDeleteFarm', function(data, cb)
    if data and data.farmId then
        TriggerServerEvent('krypton-farming:admin:deleteFarm', data.farmId)
    end
    cb('ok')
end)

RegisterNUICallback('adminUpdateSpot', function(data, cb)
    if data and data.spotId and data.updates then
        TriggerServerEvent('krypton-farming:admin:updateSpot', data.spotId, data.updates)
    end
    cb('ok')
end)

RegisterNUICallback('adminDeleteSpot', function(data, cb)
    if data and data.spotId then
        TriggerServerEvent('krypton-farming:admin:deleteSpot', data.spotId)
    end
    cb('ok')
end)

RegisterNUICallback('adminBulkUpdateSpots', function(data, cb)
    if data and data.farmId and data.updates then
        TriggerServerEvent('krypton-farming:admin:bulkUpdateSpots', data.farmId, data.updates)
    end
    cb('ok')
end)

RegisterNUICallback('adminAddEventZone', function(data, cb)
    if data and data.farmId and data.zone then
        TriggerServerEvent('krypton-farming:admin:addEventZone', data.farmId, data.zone)
    end
    cb('ok')
end)

RegisterNUICallback('adminDeleteEventZone', function(data, cb)
    if data and data.zoneId then
        TriggerServerEvent('krypton-farming:admin:deleteEventZone', data.zoneId)
    end
    cb('ok')
end)

RegisterNUICallback('adminRequestStats', function(_, cb)
    TriggerServerEvent('krypton-farming:admin:requestStats')
    cb('ok')
end)

RegisterNUICallback('adminStartCreator', function(_, cb)
    CloseAdminNUI()
    Wait(200)
    StartCreator()
    cb('ok')
end)

RegisterNUICallback('adminTeleportToFarm', function(data, cb)
    if data and data.x and data.y and data.z then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(PlayerPedId(), tonumber(data.x), tonumber(data.y), tonumber(data.z) + 1.0, false, false, false,
            false)
        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
    end
    cb('ok')
end)

RegisterNetEvent('krypton-farming:admin:farmsUpdated', function(farms)
    if AdminNUIOpen then
        SendNUIMessage({ action = 'adminFarmsData', data = { farms = farms } })
    end
end)

RegisterNetEvent('krypton-farming:admin:itemsList', function(items)
    if AdminNUIOpen then
        SendNUIMessage({ action = 'adminItemsData', data = { items = items } })
    end
end)

RegisterNetEvent('krypton-farming:admin:statsData', function(stats)
    if AdminNUIOpen then
        SendNUIMessage({ action = 'adminStatsData', data = { stats = stats } })
    end
end)

-- Admin command: registered server-side with ACE restriction, client opens UI via net event
RegisterNetEvent('krypton-farming:client:openAdminPanel', function(sub)
    sub = sub or 'panel'
    if sub == 'create' or sub == 'new' then
        StartCreator()
    elseif sub == 'cancel' then
        CancelCreator()
    else
        OpenAdminNUI()
    end
end)
