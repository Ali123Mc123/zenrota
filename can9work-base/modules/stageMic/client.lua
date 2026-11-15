local currentActiveStage = nil
local insideStage = nil
local spawnedProps = {}
local createdZones = {}
local lastToggleTime = 0

local function getStageById(stageId)
    if not Settings or not Settings.StageMic or not Settings.StageMic.Locations then return nil end
    for _, loc in ipairs(Settings.StageMic.Locations) do
        if loc.id == stageId then
            return loc
        end
    end
    return nil
end

-- 1. TextUI Gösterim Yardımcısı
local function updateStageTextUI()
    if not lib or not lib.showTextUI then return end

    if not insideStage then
        lib.hideTextUI()
        return
    end

    if currentActiveStage == insideStage then
        lib.showTextUI('[E] Mikrofonu Kapat  |  🔴 CANLI YAYIN', {
            position = 'top-center',
            icon = 'microphone-lines',
            style = {
                borderRadius = 8,
                backgroundColor = '#b71540',
                color = '#ffffff',
                fontWeight = 'bold'
            }
        })
    else
        lib.showTextUI('[E] Mikrofonu Aç', {
            position = 'top-center',
            icon = 'microphone-lines'
        })
    end
end

-- 2. Sahne / Kürsü TextUI Alanlarını (lib.zones) Başlatma
local function setupStageZones()
    if not Settings or not Settings.StageMic or not Settings.StageMic.Locations then return end

    for _, stage in ipairs(Settings.StageMic.Locations) do
        -- Opsiyonel prop spawn etme
        if stage.spawnProp and stage.prop then
            lib.requestModel(stage.prop)
            pcall(function() exports['FeloxAC']:CreateObject(joaat(stage.prop)) end) --[[FeloxAC:auto]]
            local obj = CreateObject(joaat(stage.prop), stage.coords.x, stage.coords.y, stage.coords.z, false, false, false)
            if DoesEntityExist(obj) then
                SetEntityHeading(obj, stage.propHeading or 0.0)
                FreezeEntityPosition(obj, true)
                SetEntityInvincible(obj, true)
                spawnedProps[#spawnedProps + 1] = obj
            end
            SetModelAsNoLongerNeeded(stage.prop)
        end

        -- lib.zones.sphere ile yaklaşınca TextUI tetikleme
        local zone = lib.zones.sphere({
            coords = vec3(stage.coords.x, stage.coords.y, stage.coords.z),
            radius = stage.radius or 1.5,
            debug = Settings.StageMic.Debug or false,
            onEnter = function()
                insideStage = stage.id
                updateStageTextUI()
            end,
            onExit = function()
                if insideStage == stage.id then
                    insideStage = nil
                end

                if currentActiveStage == stage.id then
                    TriggerServerEvent('can9work-base:server:stageMic:release', stage.id)
                else
                    lib.hideTextUI()
                end
            end,
            inside = function()
                -- [E] tuşu (INPUT_PICKUP = 38)
                if IsControlJustPressed(0, 38) then
                    local now = GetGameTimer()
                    if now - lastToggleTime > 600 then
                        lastToggleTime = now
                        TriggerServerEvent('can9work-base:server:stageMic:toggle', stage.id)
                    end
                end
            end
        })

        createdZones[#createdZones + 1] = zone
    end
end

-- 3. Mikrofon Açıldığında (Aktif)
RegisterNetEvent('can9work-base:client:stageMic:activated', function(stageId, voiceRange)
    currentActiveStage = stageId
    local range = voiceRange or 50.0

    -- tgiann-megaphone mikrofon ses motorunu aktifleştir (Tam megafon/anfi ses efekti)
    if GetResourceState('tgiann-megaphone') == 'started' then
        pcall(function()
            exports['tgiann-megaphone']:SetPlayerMicrophoneState(range, true, false)
        end)
    else
        if GetResourceState('pma-voice') == 'started' then
            exports['pma-voice']:overrideProximityRange(range, true)
        end
        LocalPlayer.state:set('submix', 'tmicrophone', true)
    end

    updateStageTextUI()
end)

-- 4. Mikrofon Kapandığında (Deaktif)
RegisterNetEvent('can9work-base:client:stageMic:deactivated', function(stageId)
    if currentActiveStage == stageId or not stageId then
        currentActiveStage = nil

        -- tgiann-megaphone mikrofon ses motorunu kapat
        if GetResourceState('tgiann-megaphone') == 'started' then
            pcall(function()
                exports['tgiann-megaphone']:SetPlayerMicrophoneState(0, false, false)
            end)
        else
            if GetResourceState('pma-voice') == 'started' then
                exports['pma-voice']:clearProximityOverride()
            end
            LocalPlayer.state:set('submix', nil, true)
        end

        updateStageTextUI()
    end
end)

-- 5. Başlangıç Yükleyicisi
CreateThread(function()
    Wait(1000)
    setupStageZones()
end)

-- 6. Resource Durdurulduğunda Temizlik
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if currentActiveStage then
            if GetResourceState('tgiann-megaphone') == 'started' then
                pcall(function()
                    exports['tgiann-megaphone']:SetPlayerMicrophoneState(0, false, false)
                end)
            else
                if GetResourceState('pma-voice') == 'started' then
                    exports['pma-voice']:clearProximityOverride()
                end
                LocalPlayer.state:set('submix', nil, true)
            end
        end

        if lib and lib.hideTextUI then
            lib.hideTextUI()
        end

        for _, zone in ipairs(createdZones) do
            if zone and zone.remove then
                zone:remove()
            end
        end

        for _, prop in ipairs(spawnedProps) do
            if DoesEntityExist(prop) then
                DeleteEntity(prop)
            end
        end
    end
end)
