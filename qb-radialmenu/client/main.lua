QBCore = exports['qb-core']:GetCoreObject()
PlayerData = QBCore.Functions.GetPlayerData()
local inRadialMenu = false
local jobIndex = nil
local DynamicMenuItems = {}
local FinalMenuItems = {}
local doorStates = {}
local lastVehicle = nil
local lastMenuClose = 0
local MENU_COOLDOWN = 250 -- ms: menü kapandıktan sonra bu süre geçmeden tekrar açılamaz

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function SetupJobMenu()
    local JobMenu = {
        id = 'jobinteractions',
        title = 'Meslek İşlemleri',
        icon = 'briefcase',
        items = {}
    }

    local jobName = PlayerData.job.name
    local jobType = PlayerData.job.type or "none"

    if Config.JobInteractions[jobType] then
        JobMenu.items = deepcopy(Config.JobInteractions[jobType])
    elseif Config.JobInteractions[jobName] then
        JobMenu.items = deepcopy(Config.JobInteractions[jobName])
    end

    if #JobMenu.items > 0 then
        local menuID = jobIndex ~= nil and jobIndex or (#DynamicMenuItems + 1)
        DynamicMenuItems[menuID] = JobMenu
        jobIndex = menuID
    elseif jobIndex then
        DynamicMenuItems[jobIndex] = nil
        jobIndex = nil
    end
end

local function SetupVehicleMenu()
    local Player = PlayerPedId()
    if IsPedInAnyVehicle(Player) then
        local vehMenu = {
            id = 'openmenu',
            title = 'Araç Kontrol',
            icon = 'car',
            type = 'client',
            event = 'bl_vehiclemenu:client:open',
            shouldClose = true
        }
        DynamicMenuItems[#DynamicMenuItems + 1] = vehMenu
    end
end

local function SetupRadialMenu()
    FinalMenuItems = deepcopy(Config.MenuItems)
    DynamicMenuItems = {}

    if not (PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"]) then
        SetupJobMenu()
        SetupVehicleMenu()
        for _, v in pairs(DynamicMenuItems) do
            FinalMenuItems[#FinalMenuItems + 1] = v
        end
    else
        local isLeo = PlayerData.job.type == "leo" or PlayerData.job.name == "police"
        if isLeo then
            FinalMenuItems = {
                { id = 'officerdown', title = 'Memur Yaralandı', icon = 'ambulance', type = 'client', event = 'qb-dispatch:client:officerdown', shouldClose = true },
                { id = 'emsdown',     title = 'EMS Yaralandı',   icon = 'ambulance', type = 'client', event = 'qb-dispatch:client:emsdown',     shouldClose = true }
            }
        else
            FinalMenuItems = {
                { id = 'ambacapa', title = "Ambulans Çağır", icon = 'ambulance', type = 'client', event = 'qb-ambulancejob:CivAlert', shouldClose = true }
            }
        end
    end
end

local function setRadialState(bool, sendMessage, delay)
    if bool then
        SetupRadialMenu()
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
        lastMenuClose = GetGameTimer() -- kapanma zamanını kaydet
    end

    if sendMessage then
        SendNUIMessage({
            action = "ui",
            radial = bool,
            items = FinalMenuItems
        })
    end
    inRadialMenu = bool
end

lib.addKeybind({
    name = 'radialmenu',
    description = locale("general.command_description"),
    defaultKey = 'F3',
    defaultMapper = 'keyboard',
    onPressed = function(self)
        local now = GetGameTimer()
        if not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() and not inRadialMenu and (now - lastMenuClose) > MENU_COOLDOWN then
            setRadialState(true, true)
            SetCursorLocation(0.5, 0.5)
        end
    end
})

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() PlayerData = QBCore.Functions.GetPlayerData() end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() PlayerData = {} end)
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val) PlayerData = val end)

RegisterNUICallback('closeRadial', function(data, cb)
    setRadialState(false, false, data.delay)
    cb('ok')
end)

local function selectOption(t, t2)
    for _, v in pairs(t) do
        if v.items then
            local found, action, val = selectOption(v.items, t2)
            if found then return true, action, val end
        else
            if v.id == t2.id and ((v.event and v.event == t2.event) or v.action) then
                return true, v.action, v
            end
        end
    end
    return false
end

RegisterNUICallback('selectItem', function(inData, cb)
    local itemData = inData.itemData
    local found, action, data = selectOption(FinalMenuItems, itemData)
    if data and found then
        -- if data.shouldClose then
        setRadialState(false, true)
        -- end

        if action then
            action(data)
        elseif data.type == 'client' then
            TriggerEvent(data.event, data)
        elseif data.type == 'server' then
            TriggerServerEvent(data.event, data)
        elseif data.type == 'command' then
            ExecuteCommand(data.event)
        end
    end
    cb('ok')
end)


exports('AddOption', function(data, id)
    local menuID = id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = data
    return menuID
end)

exports('RemoveOption', function(id) DynamicMenuItems[id] = nil end)

RegisterNetEvent('qb-radialmenu:arac-cek', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = lib.getClosestVehicle(coords, 3.0, false)

    if not vehicle then
        lib.notify({
            title = 'Uyarı',
            description = 'Yakında çekilecek araç bulunamadı!',
            type = 'error'
        })
        return
    end

    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
            title = 'Uyarı',
            description = 'Araç içindeyken bu işlemi yapamazsın!',
            type = 'error'
        })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if lib.progressBar({
            duration = 8000,
            label = 'Araç çekiliyor...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
            },
        }) then
        TriggerServerEvent('qb-radialmenu:server:deleteVehicle', netId, plate)
        lib.notify({
            title = 'Başarılı',
            description = 'Araç başarıyla çekildi!',
            type = 'success'
        })
    else
        lib.notify({
            title = 'İptal Edildi',
            description = 'Araç çekme işlemi iptal edildi.',
            type = 'warning'
        })
    end
end)

RegisterNetEvent('qb-radialmenu:aracevir', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed, false) then
        lib.notify({
            title = 'Hata',
            description = 'Araç içindeyken bu işlemi yapamazsın!',
            type = 'error'
        })
        return
    end

    local vehicle = lib.getClosestVehicle(coords, 5.0, false)

    if not vehicle then
        lib.notify({
            title = 'Uyarı',
            description = 'Yakında çevrilecek araç bulunamadı!',
            type = 'error'
        })
        return
    end

    if lib.progressBar({
            duration = 5000,
            label = 'Araç çevriliyor...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                scenario = 'CODE_HUMAN_MEDIC_TEND_TO_DEAD'
            },
        }) then
        local vehicleCoords = GetEntityCoords(vehicle)
        SetEntityCoords(vehicle, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0, true, true, true, false)
        SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
        SetVehicleOnGroundProperly(vehicle)
        lib.notify({
            title = 'Başarılı',
            description = 'Araç başarıyla çevrildi!',
            type = 'success'
        })
    else
        lib.notify({
            title = 'İptal Edildi',
            description = 'İşlem iptal edildi.',
            type = 'warning'
        })
    end
end)


local boatAnchorStatus = {}

RegisterNetEvent('qb-radialmenu:capaat', function()
    local ped = PlayerPedId()
    local boat = GetVehiclePedIsIn(ped, false)

    if boat == 0 then
        lib.notify({
            title = 'Hata',
            description = 'Bir teknede değilsiniz!',
            type = 'error'
        })
        return
    end

    if GetPedInVehicleSeat(boat, -1) ~= ped then
        lib.notify({
            title = 'Hata',
            description = 'Çapayı sadece teknenin kaptanı kontrol edebilir!',
            type = 'error'
        })
        return
    end

    local entity = GetEntityModel(boat)
    if not IsThisModelABoat(entity) then
        lib.notify({
            title = 'Hata',
            description = 'Bu araç bir tekne değil!',
            type = 'error'
        })
        return
    end

    boatAnchorStatus[boat] = not boatAnchorStatus[boat]

    if boatAnchorStatus[boat] then
        SetBoatAnchor(boat, true)
        FreezeEntityPosition(boat, true)
        lib.notify({
            title = 'Başarılı',
            description = 'Çapa atıldı.',
            type = 'success'
        })
    else
        SetBoatAnchor(boat, false)
        FreezeEntityPosition(boat, false)
        lib.notify({
            title = 'Başarılı',
            description = 'Çapa kaldırıldı.',
            type = 'success'
        })
    end
end)
