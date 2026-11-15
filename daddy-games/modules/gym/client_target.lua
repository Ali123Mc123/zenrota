-- =========================================================================
-- daddy-games :: gym :: client_target.lua
-- =========================================================================
-- KOK NEDEN (eski surumdeki hata):
--   ox_target, zone'lari oyuncunun KONUMUYLA degil, kameradan atilan isinin
--   CARPTIGI NOKTA ile test eder (ox_target/client/main.lua:180,203 ->
--   zone:contains(endCoords)). Eski kod ise kutuyu oyuncunun durdugu
--   koordinata, AYAK hizasina koyuyordu. Ustelik ox_lib box zone'da
--   size 2'ye bolunur ve dikey tolerans thickness/4 olarak kullanilir
--   (ox_lib/imports/zones/shared.lua:514,515,343) -> size.z = 1.6 yazinca
--   gercekte yalnizca +-0.40 m'lik bir bant olusuyordu.
--   Sonuc: alete bakinca isin aletin yuzeyine carpiyor, kutu ise 1 m geride
--   ve ayak hizasinda kaliyordu. Zone sprite'i (utils.lua:70, distance < 7)
--   yine de cizildigi icin "bir sey var ama tutmuyor" goruntusu olusuyordu.
--
-- COZUM (uc katmanli):
--   1) ASIL YOL: addModel -> salon proplarina DOGRUDAN entity hedefi.
--      Koordinat gerekmez, MLO/harita proplari dahil calisir.
--   2) YEDEK: duzeltilmis box zone. Kutu artik stand'in ILERISINDE ve
--      GOGUS hizasinda (z + 0.9), 2.0 m kup olarak kurulur.
--   3) DOGRULAMA: /gymdebug ve /gympos komutlari.
-- =========================================================================

GymTarget = {}
if not Config.Gym or Config.Gym.Enabled == false then return end

local stations       = {}   -- [stationId] = station verisi
local zoneIds        = {}   -- kayitli ox_target zone id'leri
local spawnedProps   = {}   -- bu client'in olusturdugu proplar
local occupancy      = {}   -- [stationId] = { name, exercise } | nil
local debugEnabled   = false
local registered     = false
local propsSpawned   = false   -- /gymdebug zone'lari yeniden kurar; proplar TEK KEZ spawnlanir

-- ox_lib box zone olculeri SEZGISEL DEGILDIR, dikkat:
--   * size YATAYDA ikiye bolunur     -> yari-genislik = size.x / 2
--   * DIKEYDE ise dortte bir kullanilir -> yari-yukseklik = size.z / 4
--     (shared.lua:514 size/2, :515 thickness = size.z*2, :343 thickness/4)
-- Asagidaki degerler bu yuzden soyle sonuclanir:
--   yatay  : +-1.10 m  (stand'in 0.6 m ilerisinden)
--   dikey  : +-0.90 m  (merkez stand.z + 0.70)
-- Yani bant stand.z - 0.20 ile stand.z + 1.60 arasini kapsar: hem zemine
-- bakinca (minder/sinav) hem alete bakinca (bench/barfiks) isabet eder.
local TARGET_FORWARD = 0.60
local TARGET_HEIGHT  = 0.70
local TARGET_SIZE    = vec3(2.2, 2.2, 3.6)

-- =========================================================================
-- YARDIMCILAR
-- =========================================================================
local function safeRequestModel(model)
    if not model then return false end

    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return false end

    lib.requestModel(hash, 5000)
    return HasModelLoaded(hash)
end

---Bir vector4 stand noktasindan ox_target kutusunun merkezini turetir.
local function deriveTargetCoords(stand)
    local rad = math.rad(stand.w or 0.0)
    return vec3(
        stand.x - math.sin(rad) * TARGET_FORWARD,
        stand.y + math.cos(rad) * TARGET_FORWARD,
        stand.z + TARGET_HEIGHT
    )
end

---Harita/MLO proplari icin KARARLI istasyon kimligi.
---Koordinat 0.1 m'ye yuvarlanir; tum client'larda ayni sonucu verir.
local function entityStationId(entity, exType)
    local c = GetEntityCoords(entity)
    return ('m:%s:%d:%d:%d'):format(
        exType,
        math.floor(c.x * 10 + 0.5),
        math.floor(c.y * 10 + 0.5),
        math.floor(c.z * 10 + 0.5)
    )
end

---Koordinat bir gym bolgesinin icinde mi?
local function areaAt(coords)
    for key, area in pairs(Config.Gym.Areas) do
        if area.center and #(coords - area.center) <= (area.radius or 90.0) then
            return key, area
        end
    end
    return nil, nil
end

GymTarget.AreaAt = areaAt

---Bir istasyon su an dolu mu? Doluysa kimin kullandigini dondurur.
function GymTarget.GetOccupant(stationId)
    return occupancy[stationId]
end

function GymTarget.GetStation(stationId)
    return stations[stationId]
end

-- =========================================================================
-- ORTAK TARGET SECENEKLERI
-- =========================================================================
---ox_target Font Awesome sinifi bekler; bizim `icon` alanimiz Lucide adidir.
---Bu yuzden egzersizler ayrica `targetIcon` tasir.
local function faIcon(exData, fallback)
    return exData and exData.targetIcon or ('fa-solid fa-' .. (fallback or 'dumbbell'))
end

---Ortak "etkilesime girilebilir mi" kontrolu.
---Not: DOLULUK burada kontrol EDILMEZ. Secenegi gizlemek yerine gorunur
---birakip secildiginde "kullanimda" bildirimi vermek daha anlasilir; aksi
---halde oyuncu istasyonun dolu mu yoksa hic tanimli mi olmadigini anlamaz.
local function canUse()
    if GymWorkout and GymWorkout.IsBusy and GymWorkout.IsBusy() then return false end
    return true
end

---Hedef secildiginde calisir: doluluk kontrolu + antrenmani baslat.
local function selectStation(station)
    local occ = occupancy[station.id]
    if occ then
        lib.notify({
            title = 'İstasyon Dolu',
            description = ('Burada %s çalışıyor. Bitmesini bekle.'):format(occ.name or 'biri'),
            icon = 'ban',
            type = 'error',
        })
        return
    end

    TriggerEvent('daddy-games:gym:client:startSet', station)
end

---Entity tabanli hedef icin istasyon nesnesi uretir.
local function stationFromEntity(entity, exType)
    local exData = Config.Gym.Exercises[exType]
    local stationId = entityStationId(entity, exType)

    local offset = exData.offset or vector3(0.0, 0.0, 0.0)
    local standCoords = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
    local heading = (GetEntityHeading(entity) + (exData.headingOffset or 0.0)) % 360.0

    -- Zemine oturt. Bench gibi "alet uzerinde" egzersizlerde bu ATLANIR
    -- (snapToGround = false), aksi halde ped sehpadan yere duser.
    local z = standCoords.z
    if exData.snapToGround ~= false then
        local found, groundZ = GetGroundZFor_3dCoord(standCoords.x, standCoords.y, standCoords.z + 1.0, false)
        if found and math.abs(groundZ - standCoords.z) < 2.5 then z = groundZ end
    end

    local station = {
        id = stationId,
        exercise = exType,
        entity = entity,
        stand = vector4(standCoords.x, standCoords.y, z, heading),
        coords = vec3(standCoords.x, standCoords.y, z),
        label = exData.label,
        fromModel = true,
    }

    stations[stationId] = station
    return station
end

-- =========================================================================
-- 1) ENTITY TABANLI HEDEFLER (asil yol)
-- Salon proplarina dogrudan target eklenir; koordinat listesine bagimli degil.
-- =========================================================================
local function registerModelTargets()
    -- Ayni model birden fazla egzersizde gecebilir (or. yoga minderi ->
    -- hem sinav hem mekik). Her egzersiz icin ayri secenek eklenir.
    for exType, exData in pairs(Config.Gym.Exercises) do
        if exData.models and #exData.models > 0 and not exData.duelOnly then
            local options = {
                {
                    name = 'daddy_gym_model_' .. exType,
                    icon = faIcon(exData),
                    label = ('%s — Antrenman Yap'):format(exData.label),
                    distance = 2.4,
                    canInteract = function(entity)
                        if not entity or entity == 0 then return false end

                        local coords = GetEntityCoords(entity)
                        local areaKey, area = areaAt(coords)
                        if not areaKey or area.useModelTargets == false then return false end

                        return canUse()
                    end,
                    onSelect = function(data)
                        selectStation(stationFromEntity(data.entity, exType))
                    end,
                },
            }

            -- Duello destekleyen egzersizler icin ek secenek
            if exData.duelable then
                options[#options + 1] = {
                    name = 'daddy_gym_model_duel_' .. exType,
                    icon = 'fa-solid fa-user-group',
                    label = ('1v1 %s Kapışması'):format(exData.short or exData.label),
                    distance = 2.4,
                    canInteract = function(entity)
                        if not entity or entity == 0 then return false end
                        return areaAt(GetEntityCoords(entity)) ~= nil
                    end,
                    onSelect = function(data)
                        local station = stationFromEntity(data.entity, exType)
                        TriggerEvent('daddy-games:gym:client:openDuelPicker', exType, station.id)
                    end,
                }
            end

            exports.ox_target:addModel(exData.models, options)
        end
    end

    -- Bilek guresi masasi: yalnizca duello
    local arm = Config.Gym.Exercises.armwrestling
    if arm and arm.models then
        exports.ox_target:addModel(arm.models, {
            {
                name = 'daddy_gym_model_armwrestle',
                icon = 'fa-solid fa-handshake',
                label = '1v1 Bilek Güreşi',
                distance = 2.4,
                canInteract = function(entity)
                    if not entity or entity == 0 then return false end
                    local coords = GetEntityCoords(entity)
                    if not areaAt(coords) then return false end
                    return canUse()
                end,
                onSelect = function(data)
                    local station = stationFromEntity(data.entity, 'armwrestling')
                    TriggerEvent('daddy-games:gym:client:openDuelPicker', 'armwrestling', station.id)
                end,
            },
        })
    end
end

-- =========================================================================
-- 2) KONUM TABANLI HEDEFLER (yedek) + PROP SPAWN
-- =========================================================================
local function spawnStationProp(stationGroup, stand)
    local model = stationGroup.propModel
    if not safeRequestModel(model) then
        print(('^3[daddy-games:gym] Prop yuklenemedi: %s^7'):format(tostring(model)))
        return nil
    end

    local zOffset = stationGroup.propZOffset or 0.0
    pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
    local prop = CreateObject(joaat(model), stand.x, stand.y, stand.z + zOffset, false, false, false)
    if not prop or prop == 0 then return nil end

    SetEntityHeading(prop, stand.w or 0.0)

    if stationGroup.placeOnGround then
        PlaceObjectOnGroundProperly(prop)
    end

    FreezeEntityPosition(prop, true)
    SetEntityInvincible(prop, true)
    SetModelAsNoLongerNeeded(joaat(model))

    spawnedProps[#spawnedProps + 1] = prop
    return prop
end

local function registerZoneTargets()
    for areaKey, area in pairs(Config.Gym.Areas) do
        if area.stations then
            for exType, stationGroup in pairs(area.stations) do
                local exData = Config.Gym.Exercises[exType]

                if exData and stationGroup.locations then
                    for idx, entry in ipairs(stationGroup.locations) do
                        -- Hem { stand = vector4 } hem duz vector4 kabul edilir
                        local stand = entry.stand or entry
                        local stationId = ('z:%s:%s:%d'):format(areaKey, exType, idx)

                        local prop
                        if stationGroup.spawnProp and not propsSpawned then
                            prop = spawnStationProp(stationGroup, stand)
                        elseif stationGroup.spawnProp then
                            -- Yeniden kayitta mevcut prop referansini koru
                            local existing = stations[stationId]
                            prop = existing and existing.entity or nil
                        end

                        local targetCfg = entry.target or {}
                        local targetCoords = targetCfg.coords or deriveTargetCoords(stand)

                        local station = {
                            id = stationId,
                            exercise = exType,
                            area = areaKey,
                            entity = prop,
                            stand = stand,
                            coords = vec3(stand.x, stand.y, stand.z),
                            label = entry.label or stationGroup.label or exData.label,
                            fromModel = false,
                        }
                        stations[stationId] = station

                        local options = {
                            {
                                name = 'daddy_gym_zone_' .. stationId,
                                icon = faIcon(exData),
                                label = ('%s — Antrenman Yap'):format(station.label),
                                distance = targetCfg.distance or 2.4,
                                canInteract = function() return canUse() end,
                                onSelect = function() selectStation(station) end,
                            },
                        }

                        if exData.duelable then
                            options[#options + 1] = {
                                name = 'daddy_gym_zone_duel_' .. stationId,
                                icon = 'fa-solid fa-user-group',
                                label = ('1v1 %s Kapışması'):format(exData.short or exData.label),
                                distance = targetCfg.distance or 2.4,
                                onSelect = function()
                                    TriggerEvent('daddy-games:gym:client:openDuelPicker', exType, stationId)
                                end,
                            }
                        end

                        local id = exports.ox_target:addBoxZone({
                            coords = targetCoords,
                            size = targetCfg.size or TARGET_SIZE,
                            rotation = targetCfg.rotation or stand.w or 0.0,
                            debug = debugEnabled,
                            options = options,
                        })

                        if id then
                            zoneIds[#zoneIds + 1] = id
                            station.zoneId = id
                        end
                    end
                end
            end
        end
    end
end

-- =========================================================================
-- KAYIT
-- ox_target hazir olana kadar beklenir; aksi halde exports cagrisi patlar.
-- =========================================================================
local function registerAll()
    if registered then return end

    local waited = 0
    while GetResourceState('ox_target') ~= 'started' and waited < 20000 do
        Wait(250)
        waited = waited + 250
    end

    if GetResourceState('ox_target') ~= 'started' then
        print('^1[daddy-games:gym] ox_target baslatilmadi, hedefler kaydedilemedi.^7')
        return
    end

    registered = true
    debugEnabled = Config.Gym.Debug == true

    registerModelTargets()
    registerZoneTargets()
    propsSpawned = true

    TriggerServerEvent('daddy-games:gym:clientReady')
end

CreateThread(registerAll)

-- =========================================================================
-- DOLULUK SENKRONU
-- Sunucu her rezervasyon degisiminde haber verir; secenek etiketleri ve
-- canInteract bu tabloya bakar.
-- =========================================================================
RegisterNetEvent('daddy-games:gym:occupancy', function(stationId, data)
    occupancy[stationId] = data or nil
end)

RegisterNetEvent('daddy-games:gym:occupancyFull', function(snapshot)
    occupancy = snapshot or {}
end)

AddEventHandler('playerSpawned', function()
    if registered then TriggerServerEvent('daddy-games:gym:clientReady') end
end)

-- =========================================================================
-- TEMIZLIK
-- =========================================================================
local function cleanup()
    for i = 1, #spawnedProps do
        if DoesEntityExist(spawnedProps[i]) then DeleteEntity(spawnedProps[i]) end
    end
    spawnedProps = {}

    for i = 1, #zoneIds do
        pcall(function() exports.ox_target:removeZone(zoneIds[i]) end)
    end
    zoneIds = {}

    for exType, exData in pairs(Config.Gym.Exercises) do
        if exData.models and #exData.models > 0 then
            pcall(function()
                exports.ox_target:removeModel(exData.models, {
                    'daddy_gym_model_' .. exType,
                    'daddy_gym_model_duel_' .. exType,
                    'daddy_gym_model_armwrestle',
                })
            end)
        end
    end
end

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    cleanup()
end)

-- =========================================================================
-- DEBUG & KONUM ARACLARI
-- =========================================================================
local function removeZonesOnly()
    for i = 1, #zoneIds do
        pcall(function() exports.ox_target:removeZone(zoneIds[i]) end)
    end
    zoneIds = {}
end

---Debug ciziminde: MAVI = stand (ped'in isinlanacagi yer)
---                 YESIL = target (ox_target kutusunun merkezi)
local function debugDrawThread()
    CreateThread(function()
        while debugEnabled do
            local pCoords = GetEntityCoords(cache.ped or PlayerPedId())

            for _, station in pairs(stations) do
                if station.stand and #(pCoords - station.coords) < 40.0 then
                    local stand = station.stand
                    DrawMarker(28, stand.x, stand.y, stand.z + 0.05, 0, 0, 0, 0, 0, 0,
                        0.18, 0.18, 0.18, 40, 130, 255, 140, false, false, 0, true, nil, nil, false)

                    local t = deriveTargetCoords(stand)
                    DrawMarker(28, t.x, t.y, t.z, 0, 0, 0, 0, 0, 0,
                        0.14, 0.14, 0.14, 60, 220, 120, 140, false, false, 0, true, nil, nil, false)
                end
            end

            Wait(0)
        end
    end)
end

RegisterCommand('gymdebug', function()
    debugEnabled = not debugEnabled

    -- Doluluk haritasini sunucudan tazele (yerel tablo kaymis olabilir)
    local snapshot = lib.callback.await('daddy-games:gym:getOccupancy', false)
    if snapshot then occupancy = snapshot end

    removeZonesOnly()
    registerZoneTargets()

    if debugEnabled then debugDrawThread() end

    lib.notify({
        title = 'Gym Debug',
        description = debugEnabled
            and 'AÇIK — mavi: stand noktası, yeşil: target kutusu merkezi.'
            or 'KAPALI',
        type = debugEnabled and 'success' or 'inform',
    })
end, false)

RegisterCommand('gympos', function()
    local ped = cache.ped or PlayerPedId()
    local c = GetEntityCoords(ped)
    local h = GetEntityHeading(ped)

    local line = ('{ stand = vector4(%.4f, %.4f, %.4f, %.4f) },'):format(c.x, c.y, c.z, h)

    print('^2[gym] ' .. line .. '^7')
    lib.setClipboard(line)

    lib.notify({
        title = 'Konum Kopyalandı',
        description = line,
        type = 'success',
        duration = 9000,
    })
end, false)

---En yakin istasyonu ve durumunu listeler (sorun giderme).
RegisterCommand('gymnear', function()
    local pCoords = GetEntityCoords(cache.ped or PlayerPedId())
    local found = 0

    for id, station in pairs(stations) do
        local dist = #(pCoords - station.coords)
        if dist < 15.0 then
            found = found + 1
            local occ = occupancy[id]
            print(('^5[gym] %-42s %s  %.1fm  %s^7'):format(
                id, station.exercise, dist, occ and ('DOLU: ' .. (occ.name or '?')) or 'boş'))
        end
    end

    if found == 0 then
        print('^3[gym] 15 m icinde kayitli istasyon yok. /gymdebug ile isaretleri gorebilirsin.^7')
    end

    lib.notify({ title = 'Gym', description = ('%d istasyon konsola yazıldı (F8).'):format(found), type = 'inform' })
end, false)

-- =========================================================================
-- ZEMIN ISTASYONLARI (minder gerekmeyen egzersizler)
-- Salonda yoga minderi yoksa sinav/mekik hic yapilamaz olurdu. Bu komutlar
-- oyuncunun bulundugu noktayi istasyona cevirir.
--
-- Kimlik 1.5 m'lik bir izgaraya yuvarlanir: yan yana duran iki oyuncu AYNI
-- istasyona dusar ve rezervasyon sistemi ic ice gecmelerini engeller.
-- =========================================================================
local FLOOR_GRID = 1.5

local function floorStation(exType)
    local ped = cache.ped or PlayerPedId()
    local c = GetEntityCoords(ped)

    local areaKey = areaAt(c)
    if not areaKey then
        lib.notify({
            title = 'Antrenman',
            description = 'Bunu yalnızca spor salonunda yapabilirsin.',
            type = 'error',
        })
        return nil
    end

    local exData = Config.Gym.Exercises[exType]
    if not exData or not exData.allowOnGround then return nil end

    local gx = math.floor(c.x / FLOOR_GRID + 0.5)
    local gy = math.floor(c.y / FLOOR_GRID + 0.5)
    local gz = math.floor(c.z / FLOOR_GRID + 0.5)
    local stationId = ('f:%s:%d:%d:%d'):format(exType, gx, gy, gz)

    local occ = occupancy[stationId]
    if occ then
        lib.notify({
            title = 'Yer Dolu',
            description = ('Burada %s çalışıyor. Biraz kenara çekil.'):format(occ.name or 'biri'),
            type = 'error',
        })
        return nil
    end

    local z = c.z
    local found, groundZ = GetGroundZFor_3dCoord(c.x, c.y, c.z + 1.0, false)
    if found and math.abs(groundZ - c.z) < 2.0 then z = groundZ end

    local station = {
        id = stationId,
        exercise = exType,
        entity = nil,
        stand = vector4(c.x, c.y, z, GetEntityHeading(ped)),
        coords = vec3(c.x, c.y, z),
        label = exData.label,
        fromModel = false,
        onFloor = true,
    }

    stations[stationId] = station
    return station
end

RegisterCommand('sinav', function()
    local station = floorStation('pushup')
    if station then selectStation(station) end
end, false)

RegisterCommand('mekik', function()
    local station = floorStation('situp')
    if station then selectStation(station) end
end, false)
