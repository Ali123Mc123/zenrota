local NewsProps = {
    ['tv_cam'] = {
        model = `prop_v_cam_01`,
        label = 'Yayın Kamerası',
        freeze = true
    },
    ['film_cam'] = {
        model = `prop_film_cam_01`,
        label = 'Tripodlu Kamera',
        freeze = true
    },
    ['studio_light'] = {
        model = `prop_studio_light_01`,
        label = 'Stüdyo Işığı',
        freeze = true,
        isLight = true,
        lightRange = 15.0,
        lightIntensity = 2.5
    },
    ['work_light'] = {
        model = `prop_worklight_03b`,
        label = 'Projektör Işık',
        freeze = true,
        isLight = true,
        lightRange = 25.0,
        lightIntensity = 3.5
    },
    ['mike_stand'] = {
        model = `prop_mike_01`,
        label = 'Mikrofon Standı',
        freeze = true
    },
    ['director_chair'] = {
        model = `prop_direct_chair_01`,
        label = 'Yönetmen Koltuğu',
        freeze = true
    },
    ['press_table'] = {
        model = `prop_table_03`,
        label = 'Basın Masası',
        freeze = true
    },
    ['press_barrier'] = {
        model = `prop_barrier_work05`,
        label = 'Basın Bariyeri',
        freeze = true
    }
}

local function isNewsEmployee()
    local jobName = PlayerData.job and PlayerData.job.name
    return jobName == 'news' or jobName == 'weazel'
end

local function getClosestNewsObject(maxDistance)
    local list = GlobalState.newsObjects or {}
    if #list == 0 then return nil, nil end

    local playerCoords = GetEntityCoords(cache.ped)
    local closestDist, closestNetId, closestEntity

    for i = 1, #list do
        local netid = list[i]
        if NetworkDoesEntityExistWithNetworkId(netid) then
            local ent = NetworkGetEntityFromNetworkId(netid)
            if DoesEntityExist(ent) then
                local coords = GetEntityCoords(ent)
                local dist = #(playerCoords - coords)
                if dist <= (maxDistance or 5.0) and (not closestDist or dist < closestDist) then
                    closestDist = dist
                    closestNetId = netid
                    closestEntity = ent
                end
            end
        end
    end

    return closestNetId, closestEntity
end

RegisterNetEvent('can9work-radialmenu/client/spawnNewsProp', function(data)
    if not isNewsEmployee() then
        exports.qbx_core:Notify('Bu işlem sadece Weazel News çalışanlarına özeldir.', 'error')
        return
    end

    if cache.vehicle then
        exports.qbx_core:Notify('Araç içerisindeyken nesne yerleştiremezsiniz!', 'error')
        return
    end

    local propKey = type(data) == 'table' and (data.prop or data.id) or data
    local conf = NewsProps[propKey]
    if not conf then return end

    if lib.progressBar({
        duration = 2000,
        label = ('%s yerleştiriliyor...'):format(conf.label),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'anim@narcotics@trash',
            clip = 'drop_front'
        }
    }) then
        local forward = GetEntityForwardVector(cache.ped)
        local pedCoords = GetEntityCoords(cache.ped)
        local targetCoords = pedCoords + forward * 1.0

        local found, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, false)
        if not found then
            found, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z + 2.0, false)
        end
        if not found then
            found, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z, false)
        end
        local spawnZ = found and groundZ or (pedCoords.z - 0.98)
        local spawnCoords = vector3(targetCoords.x, targetCoords.y, spawnZ)
        local heading = GetEntityHeading(cache.ped)

        local netid = lib.callback.await('qb-radialmenu:server:spawnNewsObject', false, conf.model, spawnCoords, heading)
        if not netid then
            exports.qbx_core:Notify('Nesne oluşturulamadı!', 'error')
            return
        end

        local timeout = 0
        while not NetworkDoesEntityExistWithNetworkId(netid) and timeout < 30 do
            Wait(50)
            timeout = timeout + 1
        end

        local object = NetworkGetEntityFromNetworkId(netid)
        if DoesEntityExist(object) then
            PlaceObjectOnGroundProperly(object)
            FreezeEntityPosition(object, conf.freeze ~= false)
        end

        exports.qbx_core:Notify(('%s başarıyla yerleştirildi.'):format(conf.label), 'success')
    else
        exports.qbx_core:Notify('İşlem iptal edildi.', 'error')
    end
end)

RegisterNetEvent('can9work-radialmenu/client/deleteNewsObject', function()
    if not isNewsEmployee() then
        exports.qbx_core:Notify('Bu işlem sadece Weazel News çalışanlarına özeldir.', 'error')
        return
    end

    local netid, ent = getClosestNewsObject(5.0)
    if not netid then
        exports.qbx_core:Notify('Yakında kaldırılabilecek bir basın ekipmanı bulunamadı.', 'error')
        return
    end

    if lib.progressBar({
        duration = 1800,
        label = 'Ekipman kaldırılıyor...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@',
            clip = 'plant_floor'
        }
    }) then
        TriggerServerEvent('qb-radialmenu:server:despawnNewsObject', netid)
        exports.qbx_core:Notify('Ekipman başarıyla kaldırıldı.', 'success')
    else
        exports.qbx_core:Notify('İşlem iptal edildi.', 'error')
    end
end)

-- ox_target ile doğrudan nesneye bakarak kaldırma entegrasyonu
CreateThread(function()
    local targetModels = {}
    for _, v in pairs(NewsProps) do
        targetModels[#targetModels + 1] = v.model
    end

    exports.ox_target:addModel(targetModels, {
        {
            name = 'weazel_remove_prop',
            icon = 'fas fa-trash',
            label = 'Ekipmanı Kaldır',
            groups = { ['news'] = 0, ['weazel'] = 0 },
            canInteract = function(entity, distance)
                if distance > 3.0 then return false end
                local netid = NetworkGetNetworkIdFromEntity(entity)
                local list = GlobalState.newsObjects or {}
                for i = 1, #list do
                    if list[i] == netid then return true end
                end
                return false
            end,
            onSelect = function(data)
                local netid = NetworkGetNetworkIdFromEntity(data.entity)
                if lib.progressBar({
                    duration = 1800,
                    label = 'Ekipman toplanıyor...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                        mouse = false
                    },
                    anim = {
                        dict = 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@',
                        clip = 'plant_floor'
                    }
                }) then
                    TriggerServerEvent('qb-radialmenu:server:despawnNewsObject', netid)
                    exports.qbx_core:Notify('Ekipman başarıyla toplandı.', 'success')
                end
            end
        }
    })
end)

-- Stüdyo ve projektör ışıkları için dinamik aydınlatma döngüsü
CreateThread(function()
    while true do
        local waitTime = 1000
        local list = GlobalState.newsObjects
        if list and #list > 0 then
            local pCoords = GetEntityCoords(cache.ped)
            local activeLights = {}

            for i = 1, #list do
                local netid = list[i]
                if NetworkDoesEntityExistWithNetworkId(netid) then
                    local ent = NetworkGetEntityFromNetworkId(netid)
                    if DoesEntityExist(ent) then
                        local model = GetEntityModel(ent)
                        if model == `prop_studio_light_01` or model == `prop_worklight_03b` then
                            local coords = GetEntityCoords(ent)
                            local dist = #(pCoords - coords)
                            if dist < 45.0 then
                                activeLights[#activeLights + 1] = {
                                    coords = coords,
                                    range = (model == `prop_worklight_03b`) and 25.0 or 15.0,
                                    intensity = (model == `prop_worklight_03b`) and 3.5 or 2.5
                                }
                            end
                        end
                    end
                end
            end

            if #activeLights > 0 then
                waitTime = 0
                for _, l in ipairs(activeLights) do
                    DrawLightWithRange(l.coords.x, l.coords.y, l.coords.z + 1.2, 255, 250, 240, l.range, l.intensity)
                end
            end
        end
        Wait(waitTime)
    end
end)
