local activeBadges = {}
local isCheckingPositions = false
local activeEntityProps = {}

local function cleanupPedProp(ped)
    if activeEntityProps[ped] and DoesEntityExist(activeEntityProps[ped]) then
        DeleteEntity(activeEntityProps[ped])
        activeEntityProps[ped] = nil
    end
end

-- Yardımcı: Animasyon Yükleme
local function loadAnimDict(dict)
    if not dict then return false end
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local timeout = 0
        while not HasAnimDictLoaded(dict) and timeout < 60 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    return HasAnimDictLoaded(dict)
end

-- Yardımcı: Model Yükleme
local function loadModel(model)
    local hash = (type(model) == 'number') and model or joaat(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 60 do
            Wait(10)
            timeout = timeout + 1
        end
    end
    return hash
end

-- Asset Önyükleme
CreateThread(function()
    for _, anim in pairs(Config.Dice.Animations) do
        if anim.dict then RequestAnimDict(anim.dict) end
        if anim.femaleDict then RequestAnimDict(anim.femaleDict) end
        if anim.fallbackDict then RequestAnimDict(anim.fallbackDict) end
        if anim.prop then
            local modelHash = (type(anim.prop) == 'number') and anim.prop or joaat(anim.prop)
            RequestModel(modelHash)
        end
    end
end)

-- Animasyon & Prop Oynatma
local function playActionAnimation(ped, actionType)
    local animConfig = Config.Dice.Animations[actionType]
    if not animConfig or not DoesEntityExist(ped) then return end

    CreateThread(function()
        cleanupPedProp(ped)
        ClearPedSecondaryTask(ped)

        local isFemale = (GetEntityModel(ped) == joaat('mp_f_freemode_01'))
        local animDict = animConfig.dict
        local animClip = animConfig.clip

        if isFemale and animConfig.femaleDict then
            animDict = animConfig.femaleDict
            animClip = animConfig.femaleClip or animClip
        end

        local loaded = loadAnimDict(animDict)
        if not loaded and animConfig.fallbackDict then
            animDict = animConfig.fallbackDict
            animClip = animConfig.fallbackClip or animClip
            loaded = loadAnimDict(animDict)
        end

        local propEntity = nil

        if animConfig.prop then
            local modelHash = loadModel(animConfig.prop)
            if HasModelLoaded(modelHash) then
                local coords = GetEntityCoords(ped)
                pcall(function() exports['FeloxAC']:CreateObject(modelHash) end) --[[FeloxAC:auto]]
                propEntity = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
                if DoesEntityExist(propEntity) then
                    activeEntityProps[ped] = propEntity
                    local boneIndex = GetPedBoneIndex(ped, animConfig.bone or 28422)
                    local offset = animConfig.offset or vector3(0.0, 0.0, 0.0)
                    local rot = animConfig.rotation or vector3(0.0, 0.0, 0.0)
                    AttachEntityToEntity(propEntity, ped, boneIndex, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
                    SetModelAsNoLongerNeeded(modelHash)
                end
            end
        end

        if loaded then
            TaskPlayAnim(ped, animDict, animClip, 8.0, -8.0, animConfig.duration or 2000, 49, 0, false, false, false)
        end

        Wait(animConfig.duration or 2000)

        cleanupPedProp(ped)
        StopAnimTask(ped, animDict, animClip, 1.5)
    end)
end

-- 3D Baş Üstü Takip Döngüsü
local function startPositionTracking()
    if isCheckingPositions then return end
    isCheckingPositions = true

    CreateThread(function()
        while next(activeBadges) ~= nil do
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            local updates = {}

            for badgeId, data in pairs(activeBadges) do
                local targetPed = GetPlayerPed(GetPlayerFromServerId(data.serverId))
                if DoesEntityExist(targetPed) then
                    local targetCoords = GetPedBoneCoords(targetPed, 12844, 0.0, 0.0, 0.0)
                    local headZ = targetCoords.z + 0.35
                    local dist = #(myCoords - targetCoords)

                    if dist <= Config.Dice.DisplayDistance then
                        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, headZ)
                        if onScreen then
                            local scale = math.max(0.65, 1.0 - (dist / (Config.Dice.DisplayDistance * 1.5)))
                            local alpha = math.max(0.2, 1.0 - (dist / Config.Dice.DisplayDistance))

                            table.insert(updates, {
                                id = badgeId,
                                visible = true,
                                x = screenX * 100,
                                y = screenY * 100,
                                scale = scale,
                                opacity = alpha
                            })
                        else
                            table.insert(updates, { id = badgeId, visible = false })
                        end
                    else
                        table.insert(updates, { id = badgeId, visible = false })
                    end
                else
                    table.insert(updates, { id = badgeId, visible = false })
                end
            end

            if #updates > 0 then
                SendNUIMessage({
                    action = 'updatePositions',
                    badges = updates
                })
            end

            Wait(0)
        end

        isCheckingPositions = false
    end)
end

-- Server'dan Gelen Aksiyon Olayı
RegisterNetEvent('daddy-games:client:playAction', function(data)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(data.source))
    if DoesEntityExist(targetPed) then
        playActionAnimation(targetPed, data.actionType)
    end

    local badgeId = 'badge_' .. data.source .. '_' .. GetGameTimer()
    activeBadges[badgeId] = {
        id = badgeId,
        serverId = data.source,
        expiresAt = GetGameTimer() + Config.Dice.DisplayDuration
    }

    local myCoords = GetEntityCoords(PlayerPedId())
    local targetCoords = DoesEntityExist(targetPed) and GetEntityCoords(targetPed) or myCoords
    local initialDist = #(myCoords - targetCoords)

    SendNUIMessage({
        action = 'showAction',
        id = badgeId,
        serverId = data.source,
        playerName = data.playerName,
        actionType = data.actionType,
        resultData = data.resultData,
        duration = Config.Dice.DisplayDuration,
        revealDelay = data.revealDelay,
        distance = initialDist,
        maxDistance = Config.Dice.DisplayDistance,
        enableSound = Config.Dice.EnableSound,
        soundVolume = Config.Dice.SoundVolume
    })

    startPositionTracking()

    SetTimeout(Config.Dice.DisplayDuration + 100, function()
        activeBadges[badgeId] = nil
    end)
end)

-- Kaynak Durduğunda Temizlik
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for ped, prop in pairs(activeEntityProps) do
        if DoesEntityExist(prop) then DeleteEntity(prop) end
    end
    SendNUIMessage({ action = 'cleanup' })
end)

-- =========================================================================
-- 🎮 KOMUTLAR & MENÜ
-- =========================================================================
for _, cmd in ipairs(Config.Dice.Commands.dice) do
    RegisterCommand(cmd, function(_, args)
        TriggerServerEvent('daddy-games:server:rollDice', args[1], args[2])
    end, false)
end

for _, cmd in ipairs(Config.Dice.Commands.coin) do
    RegisterCommand(cmd, function()
        TriggerServerEvent('daddy-games:server:flipCoin')
    end, false)
end

for _, cmd in ipairs(Config.Dice.Commands.rps) do
    RegisterCommand(cmd, function(_, args)
        TriggerServerEvent('daddy-games:server:playRPS', args[1])
    end, false)
end

for _, cmd in ipairs(Config.Dice.Commands.card) do
    RegisterCommand(cmd, function()
        TriggerServerEvent('daddy-games:server:drawCard')
    end, false)
end

for _, cmd in ipairs(Config.Dice.Commands.number) do
    RegisterCommand(cmd, function(_, args)
        TriggerServerEvent('daddy-games:server:randomNumber', args[1], args[2])
    end, false)
end

-- 🍀 Şans Oyunları Menüsü
local function openLuckMenu()
    lib.registerContext({
        id = 'daddy_games_luck_menu',
        title = '🎲 Şans & Oyun Menüsü',
        options = {
            {
                title = 'Zar At (Standart 2x D6)',
                description = '2 adet standart 6 yüzlü zar atar.',
                icon = 'dice',
                iconColor = '#f87171',
                onSelect = function()
                    TriggerServerEvent('daddy-games:server:rollDice', 2, 6)
                end
            },
            {
                title = 'Özel Zar At',
                description = 'Zar sayısını ve yüz adedini (D20, D100 vb.) siz belirleyin.',
                icon = 'dice-d20',
                iconColor = '#fb923c',
                onSelect = function()
                    local input = lib.inputDialog('Özel Zar Ayarı', {
                        { type = 'number', label = 'Zar Sayısı (1 - 6)', default = 2, min = 1, max = 6 },
                        { type = 'number', label = 'Zar Yüzü (D4, D6, D20, D100)', default = 6, min = 2, max = 100 }
                    })
                    if input then
                        TriggerServerEvent('daddy-games:server:rollDice', input[1], input[2])
                    end
                end
            },
            {
                title = 'Yazı - Tura',
                description = 'Bozuk para fırlatır ve sonucu gösterir.',
                icon = 'coins',
                iconColor = '#facc15',
                onSelect = function()
                    TriggerServerEvent('daddy-games:server:flipCoin')
                end
            },
            {
                title = 'Taş - Kağıt - Makas',
                description = 'Rastgele veya seçtiğiniz hamleyi yapar.',
                icon = 'hand-scissors',
                iconColor = '#4ade80',
                onSelect = function()
                    local input = lib.inputDialog('Taş Kağıt Makas', {
                        {
                            type = 'select',
                            label = 'Seçiminiz (Boş bırakırsanız rastgele seçilir)',
                            options = {
                                { value = 'random', label = '🎲 Rastgele Seç' },
                                { value = 'tas', label = '✊ Taş' },
                                { value = 'kagit', label = '✋ Kağıt' },
                                { value = 'makas', label = '✌️ Makas' },
                            }
                        }
                    })
                    if input then
                        TriggerServerEvent('daddy-games:server:playRPS', input[1] ~= 'random' and input[1] or nil)
                    end
                end
            },
            {
                title = 'İskambil Kartı Çek',
                description = '52\'lik standart desteden rastgele bir kart çeker.',
                icon = 'cards',
                iconColor = '#60a5fa',
                onSelect = function()
                    TriggerServerEvent('daddy-games:server:drawCard')
                end
            },
            {
                title = 'Rastgele Sayı Tut',
                description = 'Belirlenen aralıkta rastgele bir sayı belirler.',
                icon = 'arrow-down-1-9',
                iconColor = '#a78bfa',
                onSelect = function()
                    local input = lib.inputDialog('Sayı Aralığı', {
                        { type = 'number', label = 'Minimum Değer', default = 1 },
                        { type = 'number', label = 'Maksimum Değer', default = 100 }
                    })
                    if input and input[1] and input[2] then
                        TriggerServerEvent('daddy-games:server:randomNumber', input[1], input[2])
                    end
                end
            }
        }
    })

    lib.showContext('daddy_games_luck_menu')
end

for _, cmd in ipairs(Config.Dice.Commands.menu) do
    RegisterCommand(cmd, function()
        openLuckMenu()
    end, false)
end
