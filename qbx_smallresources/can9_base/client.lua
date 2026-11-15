local weaponDamageModifiers = {
    ["WEAPON_UNARMED"] = 0.2,
    ["WEAPON_CROWBAR"] = 0.2,
    ["WEAPON_RAMMED_BY_CAR"] = 0.0, -- Araç toslama/çarpma hasarını sıfırlar
    ["WEAPON_RUN_OVER_BY_CAR"] = 0.0, -- Araç üzerinden geçme/ezme hasarını sıfırlar
    ["WEAPON_POOLCUE"] = 0.22,
    ["WEAPON_SCREWD"] = 0.5,
    ["WEAPON_BLACKKNIFE"] = 0.5,
    ["WEAPON_BLUEKNIFE"] = 0.5,
    ["WEAPON_GRAYKNIFE"] = 0.5,
    ["WEAPON_GREENKNIFE"] = 0.5,
    ["WEAPON_ORANGEKNIFE"] = 0.5,
    ["WEAPON_PINKKNIFE"] = 0.5,
    ["WEAPON_PURPLEKNIFE"] = 0.5,
    ["WEAPON_REDKNIFE"] = 0.5,
    ["WEAPON_3DGLOCK"] = 0.5,
    ["WEAPON_T247"] = 0.6,
    ["WEAPON_357SNUB"] = 0.9,
    ["WEAPON_GHOSTG30"] = 0.95,
    ["WEAPON_COMBATPISTOL"] = 0.95,
    ["WEAPON_SWMP9"] = 0.75,
    ["WEAPON_SCORPIONX9"] = 0.5,
    ["WEAPON_FN509HUNT"] = 1.6,
    ["WEAPON_NIGHTSTICK"] = 0.3,
    ["WEAPON_STUNGUN"] = 0.1,
    ["WEAPON_TASERGUN"] = 0.1,
    ["WEAPON_OPPSLUGGER"] = 0.33,
    ["WEAPON_PAINTBALL"] = 1.3,
    ["WEAPON_SWITCHBLADE"] = 1.0,
    ["WEAPON_MX18_CLASSYBLUE"] = 1.15,
    ["WEAPON_DN22_FUSION"] = 0.9,
    ["WEAPON_REVOLVER_WHITY"] = 0.44,
    ["WEAPON_NIGHTGALE9"] = 1.0, -- 1.3 = 6 | 1.0 = 8
    ["WEAPON_JNP_COMBAT_PISTOL"] = 1.1,
    ["WEAPON_SW357"] = 0.8,
    ["WEAPON_ST84_SKULLNSWORD"] = 0.71,
    ["WEAPON_DRACO_YELLOW_DRIP"] = 0.45,
    ["WEAPON_SHOTGUN_CHROMIUM"] = 0.5,
    ["WEAPON_PY_GP"] = 0.74,
    ["WEAPON_GRD6_BLACKSPIRE_PD"] = 0.89, -- 12 hit (0.5714 = 18 hit)
    ["WEAPON_BASEBALL_SLAYER"] = 0.27, -- full cana 5 hit, hit basi ~21.4 (0.25 = 6 hit, 5 hitte 1 can; 0.3 = 4 hitte 1 can)
}

local function getCigarWeaponDamageModifier()
    local cigarAddiction = 0
    if GetResourceState('can9work-addiction') == 'started' then
        cigarAddiction = exports['can9work-addiction']:GetPlayerAddiction('cigar') or 0
    end

    local swordMod = 0.71
    if cigarAddiction >= 100 then
        swordMod = 0.94
    elseif cigarAddiction >= 50 then
        swordMod = 0.82
    end

    local unarmedMod = (cigarAddiction >= 25) and 0.6 or 0.2

    return swordMod, unarmedMod
end

local activeUnarmedMod = 0.2

local function applyWeaponDamageModifiers()
    local dynamicSwordMod, dynamicUnarmedMod = getCigarWeaponDamageModifier()
    activeUnarmedMod = dynamicUnarmedMod
    for weaponName, damageModifier in pairs(weaponDamageModifiers) do
        local mod = damageModifier
        if weaponName == "WEAPON_ST84_SKULLNSWORD" then
            mod = dynamicSwordMod
        elseif weaponName == "WEAPON_UNARMED" then
            mod = dynamicUnarmedMod
        end
        pcall(function() exports['FeloxAC']:setDamageModifier(GetHashKey(weaponName), mod) end) --[[FeloxAC:auto]]
        SetWeaponDamageModifier(GetHashKey(weaponName), mod)
    end
    if dynamicUnarmedMod > 0.2 then
        pcall(function() exports['FeloxAC']:setPlayerDamageModifier('meleeDamage', dynamicUnarmedMod) end) --[[FeloxAC:auto]]
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), dynamicUnarmedMod)
    else
        pcall(function() exports['FeloxAC']:setPlayerDamageModifier('meleeDamage', 1.0) end) --[[FeloxAC:auto]]
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
    end
end

RegisterNetEvent('addiction:client:UpdateAddiction', function(drugType, amount)
    if drugType == 'cigar' then
        applyWeaponDamageModifiers()
    end
end)

RegisterNetEvent('addiction:client:LoadAddictions', function()
    applyWeaponDamageModifiers()
end)

local playerId = cache.playerId
local currentPed = cache.ped

-- Per-frame work of can9_base. It runs from qbx_hudcomponents' per-frame thread, so the whole resource keeps a
-- single Wait(0) loop: every extra thread is resumed by the scheduler each frame and shows in resmon on its own.
-- Only *ThisFrame natives and DisableControlAction (which last one frame) are here; persistent setters
-- (SetWeaponDamageModifier, SetPedCanLosePropsOnDamage, SetPedInfiniteAmmo...) are set once, on change.
-- The values the frame needs are worked out on change (ox_lib cache events), not polled every frame.
local armedGun = false      -- holding a gun or a thrown weapon (IsPedArmed flag 6)
local veh, vehBike, vehLand = nil, false, false
local nextDisarm = 0

local DisableControlAction = DisableControlAction
local SetWeaponDamageModifierThisFrame = SetWeaponDamageModifierThisFrame
local SetPlayerMeleeWeaponDamageModifier = SetPlayerMeleeWeaponDamageModifier
local IsPlayerTargettingAnything = IsPlayerTargettingAnything
local DisablePlayerVehicleRewards = DisablePlayerVehicleRewards
local IsEntityInAir = IsEntityInAir
local UNARMED = `WEAPON_UNARMED`

function Can9BaseFrame()
    pcall(function() exports['FeloxAC']:setDamageModifier(UNARMED, activeUnarmedMod) end) --[[FeloxAC:auto]]
    SetWeaponDamageModifierThisFrame(UNARMED, activeUnarmedMod)
    if activeUnarmedMod > 0.2 then
        pcall(function() exports['FeloxAC']:setPlayerDamageModifier('meleeDamage', activeUnarmedMod) end) --[[FeloxAC:auto]]
        SetPlayerMeleeWeaponDamageModifier(playerId, activeUnarmedMod)
    end

    -- no pistol whip / melee from cover; with a gun also while aiming (was qbx_ignore's own Wait(0) loop)
    DisableControlAction(0, 140, true)
    if armedGun or not IsPlayerTargettingAnything(playerId) then
        DisableControlAction(1, 140, true)
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)
    end

    if veh then
        DisablePlayerVehicleRewards(playerId)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 37, true)
        if vehBike then
            DisableControlAction(0, 346, true)
            DisableControlAction(0, 347, true)
        end
        if vehLand and IsEntityInAir(veh) then
            DisableControlAction(0, 59, true)
            DisableControlAction(0, 60, true)
        end
        if armedGun then
            local now = GetGameTimer()
            if now >= nextDisarm then
                nextDisarm = now + 250
                TriggerEvent('ox_inventory:disarm', true)
            end
        end
    end
end

lib.onCache('weapon', function(weapon)
    armedGun = weapon and IsPedArmed(cache.ped, 6) or false
end)

lib.onCache('vehicle', function(vehicle)
    veh = vehicle or nil
    if not vehicle then return end
    local model = GetEntityModel(vehicle)
    vehBike = IsThisModelABike(model)
    vehLand = not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model)
    SetUserRadioControlEnabled(false)
    SetVehRadioStation(vehicle, "OFF")
end)

CreateThread(function()
    armedGun = cache.weapon and IsPedArmed(cache.ped, 6) or false
    if cache.vehicle then
        local model = GetEntityModel(cache.vehicle)
        veh, vehBike = cache.vehicle, IsThisModelABike(model)
        vehLand = not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model)
    end
    SetPedCanLosePropsOnDamage(currentPed, false, 0)
    applyWeaponDamageModifiers()
end)

-- stealth (crouch-walk) and stealth kills off; a 200 ms check is enough for these
CreateThread(function()
    while true do
        local ped = currentPed
        if GetPedStealthMovement(ped) then
            SetPedStealthMovement(ped, false, 0)
        end
        if IsPedPerformingStealthKill(ped) then
            ClearPedTasksImmediately(ped)
        end
        Wait(200)
    end
end)

-- Ped ayarları (bir kerelik)
lib.onCache('ped', function(ped)
    currentPed = ped
    SetPedConfigFlag(ped, 35, false)
    SetPedHelmet(ped, false)
    SetPedSuffersCriticalHits(ped, false)
    SetPedCanLosePropsOnDamage(ped, false, 0)
    applyWeaponDamageModifiers()
end)

-- Ses ve ortam ayarları (statik, bir kerelik)
CreateThread(function()
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
    SetStaticEmitterEnabled("LOS_SANTOS_VANILLA_UNICORN_01_STAGE", false)
    SetStaticEmitterEnabled("LOS_SANTOS_VANILLA_UNICORN_02_MAIN_ROOM", false)
    SetStaticEmitterEnabled("LOS_SANTOS_VANILLA_UNICORN_03_BACK_ROOM", false)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
    SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
    SetScenarioTypeEnabled("WORLD_VEHICLE_STREETRACE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_SALTON_DIRT_BIKE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_SALTON", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_NEXT_TO_CAR", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_CAR", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_BIKE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MILITARY_PLANES_SMALL", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MILITARY_PLANES_BIG", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MECHANIC", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_EMPTY", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_BUSINESSMEN", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_BIKE_OFF_ROAD_RACE", false)
    StartAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
    SetAudioFlag("PoliceScannerDisabled", true)
    SetAudioFlag("DisableFlightMusic", true)
    SetPlayerCanUseCover(PlayerId(), true)
    SetRandomEventFlag(false)
    SetDeepOceanScaler(0.0)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Cayo Perico IPL Yükleyici
-- ─────────────────────────────────────────────────────────────────────────────
local cayoIpls = {
    -- Zemin ve Pist
    "h4_islandairstrip",
    "h4_islandairstrip_props",
    "h4_islandairstrip_propsb",
    "h4_islandairstrip_hangar_props",
    "h4_islandairstrip_doorsclosed",
    "h4_islandx_terrain_01",
    "h4_islandx_terrain_02",
    "h4_islandx_terrain_03",
    "h4_islandx_terrain_04",
    "h4_islandx_terrain_05",
    "h4_islandx_terrain_06",

    -- Malikane ve Çevresi
    "h4_islandx_mansion",
    "h4_islandx_mansion_props",
    "h4_islandx_mansion_vault",
    "h4_island_mansion_b",
    "h4_island_mansion_vault",
    "h4_island_padlock_props",
    "h4_islandx_mansion_office",
    "h4_islandx_mansion_lockup_01",
    "h4_islandx_mansion_lockup_02",
    "h4_islandx_mansion_lockup_03",

    -- İskeleler ve Ada Objeleri
    "h4_islandx_props",
    "h4_islandxdock",
    "h4_islandxdock_props",
    "h4_islandxdock_props_2",
    "h4_islandxtower",
    "h4_islandx_maindock",
    "h4_islandx_maindock_props",
    "h4_islandx_maindock_props_2",

    -- Sahil, Askeriye ve Kontrol Noktaları
    "h4_beach",
    "h4_beach_props",
    "h4_beach_bar_props",
    "h4_islandx_barrack_props",
    "h4_islandx_checkpoint",
    "h4_islandx_checkpoint_props",
    "h4_Islandx_Sea_Mines",
    "h4_islandx_ne_barracks",
    "h4_islandx_nw_barracks",
    "h4_islandx_lr_parts",

    -- Deniz ve Ekstralar
    "h4_islandx_disc_strandedshark",
    "h4_islandx_disc_strandedwhale",
    "h4_islandx_yacht_01",
    "h4_islandx_yacht_02",
    "h4_islandx_yacht_03",
}

CreateThread(function()
    for _, iplName in ipairs(cayoIpls) do
        RequestIpl(iplName)
    end
end)



-- ─────────────────────────────────────────────────────────────────────────────
-- /vec3 ve /vec4 - Konumu panoya kopyala (değişmedi)
-- ─────────────────────────────────────────────────────────────────────────────
RegisterCommand('vec3', function()
    local coords = GetEntityCoords(cache.ped)
    local text = ('vector3(%.4f, %.4f, %.4f)'):format(coords.x, coords.y, coords.z)
    lib.setClipboard(text)
    lib.notify({ title = 'Konum Kopyalandı', description = text, type = 'success', duration = 4000 })
end, false)

RegisterCommand('vec4', function()
    local coords  = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    local text    = ('vector4(%.4f, %.4f, %.4f, %.4f)'):format(coords.x, coords.y, coords.z, heading)
    lib.setClipboard(text)
    lib.notify({ title = 'Konum Kopyalandı', description = text, type = 'success', duration = 4000 })
end, false)


-- Blips

local blips = {
    -- {
    --     coords = vector3(-1446.4340, 4225.3105, 50.2195),
    --     sprite = 197,
    --     color = 0,
    --     scale = 0.7,
    --     label = "El-Dahab"
    -- },
    {
        coords = vector3(1196.7621, -3109.8567, 5.0280),
        sprite = 477,
        color = 0,
        scale = 0.7,
        label = "Tırcılık"
    },
    {
        coords = vector3(5347.2130, -5253.3510, 31.0000), -- Cayo kampüsü
        sprite = 498, -- Mezuniyet şapkası / Kolej simgesi
        color = 1,   -- Kırmızı
        scale = 0.85,
        label = "Kolej"
    },
}

CreateThread(function()
    for _, v in ipairs(blips) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, v.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.scale)
        SetBlipColour(blip, v.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- AFK / Idle kamerası: qbx_ignore DisableIdleCamera(true) + DisableVehiclePassengerIdleCamera(true) ile kalıcı
-- kapatıyor (config.disable.idleCamera = true), 20 sn'de bir InvalidateIdleCam döngüsüne gerek kalmadı.

local function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    return vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
end

RegisterCommand('lookprop', function()
    local ped = PlayerPedId()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)
    local direction = RotationToDirection(camRot)
    local destination = camCoords + (direction * 15.0)

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        camCoords.x, camCoords.y, camCoords.z,
        destination.x, destination.y, destination.z,
        -1, ped, 0
    )
    local _, hit, _, _, entity = GetShapeTestResult(rayHandle)

    if hit and entity ~= 0 then
        local model = GetEntityModel(entity)
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        lib.notify({
            title = 'Prop Bilgisi',
            description = string.format('Model Hash: %s\nEntity: %s\nF8 Konsoluna kod formatında yazdırıldı!', model, entity),
            type = 'info'
        })
        print(string.format("{ coords = vector4(%.4f, %.4f, %.4f, %.4f), model = %s },", coords.x, coords.y, coords.z, heading, model))
    else
        lib.notify({
            title = 'Prop Bulunamadı',
            description = 'Baktığınız doğrultuda bir nesne tespit edilemedi.',
            type = 'error'
        })
    end
end)

RegisterCommand('gethospitalbeds', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local objects = GetGamePool('CObject')
    local found = 0
    print("\n--- HOSPITAL BEDS ---")
    for _, object in ipairs(objects) do
        local model = GetEntityModel(object)
        if model == -7035577 or model == 4287931719 then
            local objCoords = GetEntityCoords(object)
            local heading = GetEntityHeading(object)
            local dist = #(coords - objCoords)
            if dist < 50.0 then
                found = found + 1
                print(string.format("{ coords = vec4(%.2f, %.2f, %.2f, %.2f), model = -7035577 },", objCoords.x, objCoords.y, objCoords.z, heading))
            end
        end
    end
    print("--- END OF LIST (Found " .. found .. ") ---\n")
    lib.notify({
        title = 'Yatak Bilgileri',
        description = string.format('%d adet yatak koordinatı F8 konsoluna yazdırıldı!', found),
        type = 'success'
    })
end)

-- Flashbang / Körken Araca Binme Engeli
-- The loop only lives while the player is blinded (it used to wake every 500 ms for the whole session).
local blindUntil = 0

local function blindLoop()
    CreateThread(function()
        while GetGameTimer() < blindUntil do
            DisableControlAction(0, 23, true) -- INPUT_ENTER
            DisableControlAction(0, 75, true) -- INPUT_VEH_EXIT
            if IsDisabledControlJustPressed(0, 23) then
                lib.notify({
                    title = 'Eylem Engellendi',
                    description = 'Kör olduğunuz için şu anda araca binemezsiniz!',
                    type = 'error'
                })
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent("prp-policeutils:client:flashExplode", function(grenadeCoords, unused, weaponName)
    local playerCoords = GetEntityCoords(cache.ped)
    if #(playerCoords - grenadeCoords) < 4.5 then
        local running = GetGameTimer() < blindUntil
        blindUntil = GetGameTimer() + 25000 -- Süreyi 25 saniyeye çıkararak garantiye alıyoruz
        if not running then blindLoop() end
    end
end)

RegisterNetEvent("prp-policeutils:client:clearFlash", function()
    blindUntil = 0
end)

-- DaddyRP TEMP: /modelbak, the model of what the crosshair looks at (map/interior props too), to find the
-- euro_gunshop_v1 sign. Prints to F8 and shows it on screen. Remove once the sign is gone.
do
    local names = { 'base_prop_gunshop','base_prop_gunshop3','base_prop_gunshop4','conker_gunshoop','conker_gunshoop10','conker_gunshoop11','conker_gunshoop2','conker_gunshoop3','conker_gunshoop4','conker_gunshoop5','conker_gunshoop6','conker_gunshoop7','conker_gunshoop8','conker_gunshoop9','conker_gunshop_light','conker_gunshop_light3','conker_gunshop_light4','conker_tv','conker_tv2','conker_tv3','conker_tv4','conker_tv5','conker_tv6','conker_tv7','conker_tv8','conker_tv9','katana','mahmoud_beam','mahmoud_door03','mahmoud_door04','mahmoud_door09','mahmoud_door10','mahmoud_guun_table','mahmoud_guun_table3','mahmoud_guun_table4','mahmoud_mirror3','mahmoud_poost','mahmoud_poost3','mahmoud_prooop','mahmoud_prooop3','mahmoud_secdoor','mahmoud_wall_dekor','mahmoud_wall_dekor3','mirror_conker','mirror_conker1','mirror_conker2','room2_prop','shooting_room','table_sniper','trophy_table_mahmoud' }
    local byHash = {}
    for _, n in ipairs(names) do byHash[joaat(n)] = n end
    RegisterCommand('modelbak', function()
        local cam, rot = GetGameplayCamCoord(), GetGameplayCamRot(2)
        local x, z = math.rad(rot.x), math.rad(rot.z)
        local dir = vector3(-math.sin(z) * math.abs(math.cos(x)), math.cos(z) * math.abs(math.cos(x)), math.sin(x))
        local to = cam + dir * 15.0
        local ray = StartExpensiveSynchronousShapeTestLosProbe(cam.x, cam.y, cam.z, to.x, to.y, to.z, -1, cache.ped, 0)
        local _, hit, at = GetShapeTestResult(ray)
        if hit == 0 then return lib.notify({ description = 'modelbak: bir şeye nişan al' }) end
        -- GetEntityModel crashes on building/interior handles from a shape test, so look the shop's models up by name
        local found = {}
        for _, n in ipairs(names) do
            local object = GetClosestObjectOfType(at.x, at.y, at.z, 10.0, joaat(n), false, false, false)
            if object ~= 0 then
                local c = GetEntityCoords(object)
                found[#found + 1] = { name = n, d = #(c - at), c = c }
            end
        end
        table.sort(found, function(l, r) return l.d < r.d end)
        local parts = {}
        for i = 1, math.min(#found, 8) do parts[i] = ('%s (%.1f m)'):format(found[i].name, found[i].d) end
        local text = ('modelbak @ %.2f %.2f %.2f: %s'):format(at.x, at.y, at.z, #parts > 0 and table.concat(parts, ', ') or 'yakında dükkan modeli yok')
        print(text)
        lib.notify({ description = text, duration = 15000 })
    end, false)
end
