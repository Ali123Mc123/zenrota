local jobConfig = require 'configs.jobs'
local jobPoints = {}
local jobBlips = {}
local isBusy = false
local playerState = LocalPlayer.state
local isTextUIShowing = false

local maxSentenceTime = 0
local completedLocations = {} -- [locationId] = true

local jobsModule = {}

-- Harita Bliplerini Yenileme / Güncelleme
local function refreshJobBlips()
    for locId, blipId in pairs(jobBlips) do
        if DoesBlipExist(blipId) then
            RemoveBlip(blipId)
        end
    end
    jobBlips = {}

    local currentJailTime = playerState.jailTime and tonumber(playerState.jailTime) or 0
    if currentJailTime <= 0 then return end

    local blipConfigs = {
        electrical = { sprite = 1, color = 5, scale = 0.55, label = 'Hapishane: Elektrik Panosu' },
        cleaning = { sprite = 1, color = 3, scale = 0.55, label = 'Hapishane: Avlu Temizliği' },
        kitchen = { sprite = 1, color = 2, scale = 0.55, label = 'Hapishane: Mutfak İşi' },
    }

    for jobType, jobData in pairs(jobConfig.Jobs) do
        local bCfg = blipConfigs[jobType] or { sprite = 1, color = 1, scale = 0.6, label = jobData.label }
        for _, loc in ipairs(jobData.locations) do
            if not completedLocations[loc.id] then
                local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
                SetBlipSprite(blip, bCfg.sprite)
                SetBlipScale(blip, bCfg.scale)
                SetBlipColour(blip, bCfg.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(bCfg.label)
                EndTextCommandSetBlipName(blip)

                jobBlips[loc.id] = blip
            end
        end
    end
end

-- Kolay ve Dengeli Mini-Oyun / Skillcheck (1-2 Kolay Aşama)
local function getRandomSkillCheck()
    local stagesCount = math.random(1, 2)
    local diffs = {}
    for i = 1, stagesCount do
        diffs[i] = 'easy'
    end

    local keySets = {
        { 'e', 'w' },
        { 'w', 's' },
        { 'a', 'd' }
    }
    local keys = keySets[math.random(1, #keySets)]

    return diffs, keys
end

-- HUD Guncelleme
function jobsModule.updateHUD(data)
    local currentJailTime = playerState.jailTime and tonumber(playerState.jailTime) or 0
    if currentJailTime <= 0 then
        SendNUIMessage({ action = 'hideHUD' })
        return
    end

    local stateMax = playerState.maxJailTime and tonumber(playerState.maxJailTime)
    if stateMax and stateMax > 0 then
        maxSentenceTime = stateMax
    elseif not maxSentenceTime or maxSentenceTime < currentJailTime then
        maxSentenceTime = currentJailTime
    end

    SendNUIMessage({
        action = 'updateHUD',
        data = {
            jailTime = (data and data.jailTime ~= nil) and data.jailTime or currentJailTime,
            maxJailTime = maxSentenceTime,
            tasksDone = data and data.tasksDone,
            reduction = data and data.reduction,
            electrical = data and data.electrical,
            cleaning = data and data.cleaning,
            kitchen = data and data.kitchen,
            taskCooldown = data and data.taskCooldown
        }
    })
end

-- Gorevi Gerceklestirme Fonksiyonu
function jobsModule.performJob(jobType, location)
    if isBusy then return end
    local jailTime = playerState.jailTime and tonumber(playerState.jailTime) or 0

    if jailTime <= 0 then
        lib.notify({
            title = 'Hapishane',
            description = 'Cezanız bitti, gardiyandan tahliye olabilirsiniz.',
            type = 'info'
        })
        return
    end

    if completedLocations[location.id] then
        lib.notify({
            title = 'Tamamlandı',
            description = 'Bu noktayı zaten yaptınız! Tekrar yapabilmek için diğer noktaları tamamlayın.',
            type = 'error'
        })
        return
    end

    local jobData = jobConfig.Jobs[jobType]
    if not jobData then return end

    isBusy = true

    if isTextUIShowing then
        lib.hideTextUI()
        isTextUIShowing = false
    end

    -- Kolay Mini-Oyun
    local diffs, keys = getRandomSkillCheck()
    local success = lib.skillCheck(diffs, keys)
    if not success then
        lib.notify({
            title = 'Başarısız',
            description = 'Görevi tamamlarken hata yaptınız!',
            type = 'error'
        })
        isBusy = false
        return
    end

    -- 15 Saniyelik Animasyon ve Prop Islemi
    local animData = jobData.anim or {}
    local propData = jobData.prop

    if animData.dict then
        lib.requestAnimDict(animData.dict, 3000)
    end
    if propData and propData.model then
        lib.requestModel(propData.model, 3000)
    end

    local progressConfig = {
        duration = jobData.duration or 15000, -- 15 Saniye
        label = ('%s yapılıyor...'):format(jobData.label),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            sprint = true
        },
        anim = {
            dict = animData.dict,
            clip = animData.clip,
            flag = animData.flag or 49
        },
        prop = propData
    }

    if lib.progressCircle(progressConfig) then
        local result = lib.callback.await('xt-prison:server:completeJob', false, jobType, location.id)

        if result and result.success then
            completedLocations = result.completed or {}

            -- Yapılan noktanın blipini haritadan kaldır
            if jobBlips[location.id] and DoesBlipExist(jobBlips[location.id]) then
                RemoveBlip(jobBlips[location.id])
                jobBlips[location.id] = nil
            end

            -- HUD'ı anlık verilerle guncelle
            jobsModule.updateHUD({
                jailTime = result.newJailTime,
                reduction = result.reduced,
                tasksDone = result.tasksDone,
                electrical = result.electrical,
                cleaning = result.cleaning,
                kitchen = result.kitchen,
                taskCooldown = result.taskCooldown
            })

            if result.categoryReset then
                refreshJobBlips()
                lib.notify({
                    title = 'Kategori Tamamlandı',
                    description = ('Tüm %s noktalarını bitirdiniz! Bu kategori bekleme süresine girdi, diğer işleri yapın.'):format(jobData.label),
                    type = 'info',
                    duration = 6000
                })
            end

            if result.newJailTime and result.newJailTime <= 0 then
                lib.notify({
                    title = 'Tebrikler!',
                    description = 'Tüm cezanızı tamamladınız! Çıkış yapmak için gardiyana gidin.',
                    type = 'success',
                    duration = 6000
                })
            else
                lib.notify({
                    title = 'Görev Tamamlandı',
                    description = ('1 ay ceza indirimi kazandınız! Kalan cezanız: %s ay'):format(result.newJailTime or 0),
                    type = 'success',
                    duration = 4000
                })
            end
        elseif result and result.cooldown then
            if result.type == 'task' then
                lib.notify({
                    title = 'Dinlenmelisiniz',
                    description = ('Yeni bir işe başlamadan önce %s saniye beklemelisiniz.'):format(result.remaining),
                    type = 'error'
                })
            else
                lib.notify({
                    title = 'Kategori Beklemede',
                    description = ('Bu iş türü şu an beklemede (%s saniye kaldı). Lütfen diğer işleri yapın!'):format(result.remaining),
                    type = 'error'
                })
            end
        elseif result and result.error then
            lib.notify({
                title = 'Uyarı',
                description = result.error,
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'İptal Edildi',
            description = 'İşlemi yarıda bıraktınız.',
            type = 'error'
        })
    end

    isBusy = false
end

-- Hedefleri (lib.points / Çift Ok Marker / Harita Blipleri / Sade TextUI) Oluştur
function jobsModule.initJobs(totalSentence)
    jobsModule.cleanupJobs()

    local currentJailTime = playerState.jailTime and tonumber(playerState.jailTime) or 0
    local stateMax = playerState.maxJailTime and tonumber(playerState.maxJailTime)

    if stateMax and stateMax > 0 then
        maxSentenceTime = stateMax
    elseif totalSentence and tonumber(totalSentence) > 0 then
        maxSentenceTime = tonumber(totalSentence)
    elseif maxSentenceTime == 0 or maxSentenceTime < currentJailTime then
        maxSentenceTime = currentJailTime
    end

    -- Sunucudan guncel gorev durumunu al
    CreateThread(function()
        local state = lib.callback.await('xt-prison:server:getJobState', false)
        if state then
            completedLocations = state.completed or {}
            refreshJobBlips()
            SendNUIMessage({
                action = 'showHUD',
                data = {
                    jailTime = currentJailTime,
                    maxJailTime = maxSentenceTime,
                    tasksDone = state.tasksDone or 0,
                    electrical = state.electrical,
                    cleaning = state.cleaning,
                    kitchen = state.kitchen,
                    taskCooldown = state.taskCooldown or 0
                }
            })
        end
    end)

    -- Marker ve Etkilesim Noktaları
    for jobType, jobData in pairs(jobConfig.Jobs) do
        for _, loc in ipairs(jobData.locations) do
            local point = lib.points.new({
                coords = loc.coords,
                distance = 15.0, -- Makul gorus mesafesi (15m)
            })

            local hasText = false

            function point:nearby()
                -- Eger bu nokta zaten bu dongude yapildiysa gosterme
                if completedLocations[loc.id] then return end

                -- Marker Rengi (Elektrik: Sarı | Temizlik: Mavi | Mutfak: Yeşil)
                local r, g, b = 255, 200, 0
                if jobType == 'cleaning' then
                    r, g, b = 0, 190, 255
                elseif jobType == 'kitchen' then
                    r, g, b = 74, 222, 128
                end

                -- ÇİFT OK MARKER (Dual Downward Floating Arrows)
                -- 1. Üst Ok (Biraz daha küçük)
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z + 0.52,
                    0.0, 0.0, 0.0,
                    0.0, 180.0, 0.0,
                    0.26, 0.26, 0.26,
                    r, g, b, 200,
                    true, false, 2, true, nil, nil, false
                )

                -- 2. Alt Ok (Biraz daha büyük)
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z + 0.26,
                    0.0, 0.0, 0.0,
                    0.0, 180.0, 0.0,
                    0.35, 0.35, 0.35,
                    r, g, b, 235,
                    true, false, 2, true, nil, nil, false
                )

                -- 1.8 metre yakındayken Sade TextUI göster ve [E] dinle
                if self.currentDistance <= 1.8 then
                    if not hasText and not isBusy then
                        lib.showTextUI(('[E] - %s'):format(jobData.label), {
                            position = "right-center",
                            icon = jobData.icon or 'hammer'
                        })
                        hasText = true
                        isTextUIShowing = true
                    end

                    if IsControlJustPressed(0, 38) and not isBusy then -- E tuşu
                        if hasText then
                            lib.hideTextUI()
                            hasText = false
                            isTextUIShowing = false
                        end
                        jobsModule.performJob(jobType, loc)
                    end
                elseif hasText and self.currentDistance > 1.8 then
                    lib.hideTextUI()
                    hasText = false
                    isTextUIShowing = false
                end
            end

            function point:onExit()
                if hasText then
                    lib.hideTextUI()
                    hasText = false
                    isTextUIShowing = false
                end
            end

            table.insert(jobPoints, point)
        end
    end
end

-- Tum Noktalari, Blipleri ve HUD'i Temizle
function jobsModule.cleanupJobs()
    if isTextUIShowing then
        lib.hideTextUI()
        isTextUIShowing = false
    end

    SendNUIMessage({ action = 'hideHUD' })

    for _, point in ipairs(jobPoints) do
        point:remove()
    end
    jobPoints = {}

    for locId, blipId in pairs(jobBlips) do
        if DoesBlipExist(blipId) then
            RemoveBlip(blipId)
        end
    end
    jobBlips = {}

    completedLocations = {}
    isBusy = false
end

-- HUD Aç / Kapa (G tuşu ile Collapse / Expand)
function jobsModule.toggleHUD()
    SendNUIMessage({ action = 'toggleHUD' })
end

RegisterCommand('toggleprisonhud', function()
    if playerState.jailTime and tonumber(playerState.jailTime) > 0 then
        jobsModule.toggleHUD()
    end
end, false)
RegisterKeyMapping('toggleprisonhud', 'Hapishane Menüsünü Gizle/Aç', 'keyboard', 'g')

-- Statebag Degisimi Dinleyicisi (Anlık Senkronizasyon)
AddStateBagChangeHandler('jailTime', nil, function(bagName, _, value)
    local ply = GetPlayerFromStateBagName(bagName)
    if ply == PlayerId() then
        if value and tonumber(value) > 0 then
            jobsModule.updateHUD({ jailTime = tonumber(value) })
        else
            jobsModule.cleanupJobs()
        end
    end
end)

-- Script basladiginda aktif ceza varsa baslat
CreateThread(function()
    Wait(1500)
    if playerState.jailTime and tonumber(playerState.jailTime) > 0 then
        jobsModule.initJobs(playerState.jailTime)
    end
end)

return jobsModule
