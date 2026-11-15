-- Kişi bazlı ses seviyesi override motoru (pma-voice / Mumble uyumlu).
-- Mumble native 3D spatial attenuation motorunu bozmadan, sadece hedef oyuncunun
-- ses kazanç çarpanını (gain multiplier) ayarlar. Sürekli 200ms'lik API spam'i ve
-- yapay mesafe sönümlenmesi kaldırılarak ses kırılmaları ve robotlaşma önlenmiştir.

local pmaVoice = exports['pma-voice']
local customVolumes = {}   -- [serverId] = { volume = 0.05-1.0, name = string }
local appliedVolumes = {}  -- [serverId] = currentAppliedGain (-1.0 or number)

local function isPlayerMuted(serverId)
    local ok, muted = pcall(function()
        return pmaVoice:isPlayerMuted(serverId)
    end)
    return ok and muted and true or false
end

-- Aynı radyo/telefon kanalındayken pma-voice'ın kendi override'ı geçerli kalsın.
local function hasSharedRemoteVoice(serverId)
    local theirState = Player(serverId).state
    local myRadio = LocalPlayer.state.radioChannel
    local theirRadio = theirState.radioChannel
    if myRadio and myRadio ~= 0 and myRadio == theirRadio then
        return true
    end

    local myCall = LocalPlayer.state.callChannel
    local theirCall = theirState.callChannel
    if myCall and myCall ~= 0 and myCall == theirCall then
        return true
    end

    return false
end

local function clampVolume(volume)
    if volume < Config.MinVolume then return Config.MinVolume end
    if volume > Config.MaxVolume then return Config.MaxVolume end
    return volume
end

local function playerNameOf(serverId)
    local playerIdx = GetPlayerFromServerId(serverId)
    if playerIdx == -1 then return nil end
    return GetPlayerName(playerIdx)
end

-- %50 (0.5) = 1.0x (Normal)
-- %100 (1.0) = 2.0x (İki kat yüksek)
-- %5 (0.05) = 0.1x (Fısıltı / Kısık)
local function calculateMumbleGain(volume)
    if math.abs(volume - Config.DefaultVolume) < 0.005 then
        return -1.0 -- Varsayılan ses: override yok (-1.0)
    end
    -- Doğrusal kazanç çarpanı (Gain: 0.1x ile 2.0x arası)
    local gain = (volume / Config.DefaultVolume)
    return math.max(0.05, math.min(2.0, gain))
end

local function applyVolume(serverId, gain)
    if appliedVolumes[serverId] == gain then
        return -- Zaten aynı değer uygulanmış, Mumble tamponunu gereksiz sıfırlama!
    end
    appliedVolumes[serverId] = gain
    pcall(MumbleSetVolumeOverrideByServerId, serverId, gain)
end

local function releaseVolume(serverId)
    if appliedVolumes[serverId] == nil or appliedVolumes[serverId] == -1.0 then
        return
    end
    appliedVolumes[serverId] = -1.0
    pcall(MumbleSetVolumeOverrideByServerId, serverId, -1.0)
end

local DEFAULT_VOICE_DISTANCE = 2.5

local function getDistanceTo(serverId)
    local playerIdx = GetPlayerFromServerId(serverId)
    if playerIdx == -1 then return nil end

    local targetPed = GetPlayerPed(playerIdx)
    if targetPed == 0 or not DoesEntityExist(targetPed) then return nil end

    return #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed))
end

local function getVoiceRange(serverId)
    local proximity = Player(serverId).state.proximity
    local talkerDistance = proximity and tonumber(proximity.distance)
    if not talkerDistance or talkerDistance <= 0.0 then
        talkerDistance = DEFAULT_VOICE_DISTANCE
    end
    -- pma-voice içerisinde tanımlı olan birebir net konuşma menzili (Fısıltı: 1.5m, Normal: 2.5m, Bağırma: 4.5m)
    return talkerDistance
end

local function syncPlayerVolume(serverId, entry)
    if isPlayerMuted(serverId) or hasSharedRemoteVoice(serverId) then
        releaseVolume(serverId)
        return
    end

    local name = playerNameOf(serverId)
    if name == nil or name ~= entry.name then
        customVolumes[serverId] = nil
        releaseVolume(serverId)
        return
    end

    local distance = getDistanceTo(serverId)
    local voiceRange = getVoiceRange(serverId)

    -- Sadece pma-voice'ın kendi net mesafesi (voiceRange) içindeyse özel ses kazancı uygulanır.
    -- Bu mesafeyi 1 cm bile aştığında override anında serbest bırakılır (-1.0),
    -- böylece pma-voice'ın orijinal menzil sınırı %100 birebir korunur.
    if distance and distance <= voiceRange then
        local targetGain = calculateMumbleGain(entry.volume)
        applyVolume(serverId, targetGain)
    else
        releaseVolume(serverId)
    end
end

-- client/main.lua UI listesini doldururken kullanır.
function GetCustomVolume(serverId)
    local entry = customVolumes[serverId]
    if entry == nil then
        return Config.DefaultVolume
    end
    return entry.volume
end

-- NUI'dan gelen setVolume çağrısı bunu tetikler.
function SetCustomVolume(serverId, volume)
    volume = clampVolume(volume)

    if math.abs(volume - Config.DefaultVolume) < 0.005 then
        if customVolumes[serverId] ~= nil then
            customVolumes[serverId] = nil
            releaseVolume(serverId)
        end
        return
    end

    local name = playerNameOf(serverId)
    if name == nil then return end

    customVolumes[serverId] = { volume = volume, name = name }
    syncPlayerVolume(serverId, customVolumes[serverId])
end

-- Periyodik kontrol: Sadece telsiz/telefon durumu değiştiğinde veya oyuncu ayrıldığında senkronize eder.
CreateThread(function()
    while true do
        Wait(Config.ReapplyInterval)
        for serverId, entry in pairs(customVolumes) do
            syncPlayerVolume(serverId, entry)
        end
    end
end)

-- Oyuncu ayrıldığında temizlik
RegisterNetEvent('onPlayerDropped', function(serverId)
    serverId = tonumber(serverId)
    if not serverId or customVolumes[serverId] == nil then return end
    customVolumes[serverId] = nil
    releaseVolume(serverId)
    appliedVolumes[serverId] = nil
end)

-- Kaynak durdurulduğunda temizlik
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for serverId in pairs(customVolumes) do
        releaseVolume(serverId)
    end
    customVolumes = {}
    appliedVolumes = {}
end)

-- Mumble Ses Motorunu Sıfırlama
function RestartVoiceEngine()
    for serverId in pairs(customVolumes) do
        releaseVolume(serverId)
    end
    appliedVolumes = {}

    pcall(function()
        MumbleSetActive(false)
        NetworkSetVoiceActive(false)
        MumbleClearVoiceTarget(1)
        MumbleClearVoiceTarget(2)
        MumbleClearVoiceTargetChannels(1)
        MumbleClearVoiceTargetChannels(2)
        MumbleClearVoiceChannel()
        MumbleSetVoiceChannel(-1)
    end)

    Wait(400)

    pcall(function()
        MumbleSetActive(true)
        NetworkSetVoiceActive(true)
    end)

    local currentMode = LocalPlayer.state.proximity and LocalPlayer.state.proximity.index or 2
    TriggerEvent('pma-voice:setTalkingMode', currentMode)

    Wait(300)

    for serverId, entry in pairs(customVolumes) do
        syncPlayerVolume(serverId, entry)
    end
end
