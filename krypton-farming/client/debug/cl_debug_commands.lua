-- DaddyRP: debug only, players never see these commands
if not Config.Debug then return end
RegisterCommand('farming_debug', function()
    ClientState.debugEnabled = not ClientState.debugEnabled
    DebugPrint('Debug visualization:', ClientState.debugEnabled and 'ENABLED' or 'DISABLED')
end, false)

RegisterCommand('notifytest', function(source, args)
    if not Config.Debug then return end
    
    local testType = tonumber(args[1])
    if not testType or testType < 1 or testType > 4 then
        Krypton.Notify('Usage: /notifytest [1-4] (1=success, 2=error, 3=warning, 4=info)', 'info')
        return
    end
    
    local notifications = {
        { title = 'Başarılı!', message = 'İş tamamlandı ve ödüller hesabınıza eklendi.', type = 'success' },
        { title = 'Hata!', message = 'İşlem başarısız oldu. Lütfen daha sonra tekrar deneyin.', type = 'error' },
        { title = 'Dikkat!', message = 'Bu alan yakında kapanacak. Lütfen hasat işlemini tamamlayın.', type = 'warning' },
        { title = 'Bilgi', message = 'GPS işaretçisi haritanızda belirlendi. Tarlaya gitmelisiniz.', type = 'info' }
    }
    
    local notif = notifications[testType]
    Krypton.Notify(notif.message, notif.type, 5000, notif.title)
end, false)

currDebugProps = {}

RegisterCommand('farmspawn', function(source, args)
    local modelName = args[1]
    if not modelName then
        Krypton.Notify('Kullanım: /farmspawn [model_adi]', 'error')
        return
    end

    local hash = GetHashKey(modelName)
    if not IsModelInCdimage(hash) then
        Krypton.Notify('Geçersiz model: ' .. modelName, 'error')
        return
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            Krypton.Notify('Model yüklenemedi: ' .. modelName, 'error')
            return
        end
    end

    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
    
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local obj = CreateObject(hash, coords.x, coords.y, coords.z - 1.0, false, false, false)
    SetEntityHeading(obj, GetEntityHeading(ped))
    PlaceObjectOnGroundProperly(obj)
    
    table.insert(currDebugProps, obj)
    Krypton.Notify('Prop oluşturuldu: ' .. modelName, 'success')
end, false)

RegisterCommand('farmdel', function()
    local count = 0
    for _, obj in pairs(currDebugProps) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
            count = count + 1
        end
    end
    currDebugProps = {}
    Krypton.Notify(count .. ' adet prop silindi.', 'success')
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if ClientState.npcPed then
            DeleteEntity(ClientState.npcPed)
        end
        SetNuiFocus(false, false)
        
        if currDebugProps then
            for _, obj in pairs(currDebugProps) do
                if DoesEntityExist(obj) then DeleteEntity(obj) end
            end
        end
    end
end)
