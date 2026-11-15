local currentStatusList = {}
local casings = {}
local currentCasing = nil
local bloodDrops = {}
local currentBloodDrop = nil
local fingerprints = {}
local currentFingerprint = 0
local shotAmount = 0

local statusList = {
    fight = locale('evidence.red_hands'),
    widepupils = locale('evidence.wide_pupils'),
    redeyes = locale('evidence.red_eyes'),
    weedsmell = locale('evidence.weed_smell'),
    gunpowder = locale('evidence.gunpowder'),
    chemicals = locale('evidence.chemicals'),
    heavybreath = locale('evidence.heavy_breathing'),
    sweat = locale('evidence.sweat'),
    handbleed = locale('evidence.handbleed'),
    confused = locale('evidence.confused'),
    alcohol = locale('evidence.alcohol'),
    heavyalcohol = locale('evidence.heavy_alcohol'),
    agitated = locale('evidence.agitated'),
}

local ignoredWeapons = {
    [`weapon_unarmed`] = true,
    [`weapon_snowball`] = true,
    [`weapon_stungun`] = true,
    [`weapon_tasergun`] = true,
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true,
}

local function dropBulletCasing(weapon, ped)
    local randX = math.random() + math.random(-1, 1)
    local randY = math.random() + math.random(-1, 1)
    local coords = GetOffsetFromEntityInWorldCoords(ped, randX, randY, 0)
    local serial = exports.ox_inventory:getCurrentWeapon().metadata.serial
    TriggerServerEvent('evidence:server:CreateCasing', weapon, serial, coords)
    Wait(300)
end

local function dnaHash(s)
    local h = string.gsub(s, '.', function(c)
        return string.format('%02x', string.byte(c))
    end)
    return h
end

RegisterNetEvent('evidence:client:SetStatus', function(statusId, time)
    if time > 0 and statusList[statusId] then
        if not currentStatusList?[statusId] or currentStatusList[statusId].time < 20 then
            currentStatusList[statusId] = {
                text = statusList[statusId],
                time = time
            }
            exports.qbx_core:Notify(currentStatusList[statusId].text, 'error')
        end
    elseif statusList[statusId] then
        currentStatusList[statusId] = nil
    end
    TriggerServerEvent('evidence:server:UpdateStatus', currentStatusList)
end)

RegisterNetEvent('evidence:client:AddBlooddrop', function(bloodId, citizenid, bloodtype, coords)
    bloodDrops[bloodId] = {
        citizenid = citizenid,
        bloodtype = bloodtype,
        coords = vec3(coords.x, coords.y, coords.z - 0.9)
    }
end)

RegisterNetEvent('evidence:client:RemoveBlooddrop', function(bloodId)
    bloodDrops[bloodId] = nil
    currentBloodDrop = 0
end)

RegisterNetEvent('evidence:client:AddFingerPrint', function(fingerId, fingerprint, coords)
    fingerprints[fingerId] = {
        fingerprint = fingerprint,
        coords = vec3(coords.x, coords.y, coords.z - 0.9)
    }
end)

RegisterNetEvent('evidence:client:RemoveFingerprint', function(fingerId)
    fingerprints[fingerId] = nil
    currentFingerprint = 0
end)

RegisterNetEvent('evidence:client:ClearBlooddropsInArea', function()
    local pos = GetEntityCoords(cache.ped)
    local bloodDropList = {}
    if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            label = locale('progressbar.blood_clear'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false
            }
        })
    then
        if bloodDrops and next(bloodDrops) then
            for bloodId in pairs(bloodDrops) do
                if #(pos - bloodDrops[bloodId].coords) < 10.0 then
                    bloodDropList[#bloodDropList + 1] = bloodId
                end
            end
            TriggerServerEvent('evidence:server:ClearBlooddrops', bloodDropList)
            exports.qbx_core:Notify(locale('success.blood_clear'), 'success')
        end
    else
        exports.qbx_core:Notify(locale('error.blood_not_cleared'), 'error')
    end
end)

RegisterNetEvent('evidence:client:AddCasing', function(casingId, weapon, coords, serie)
    casings[casingId] = {
        type = weapon,
        serie = serie and serie or locale('evidence.serial_not_visible'),
        coords = vec3(coords.x, coords.y, coords.z - 0.9)
    }
end)

RegisterNetEvent('evidence:client:RemoveCasing', function(casingId)
    casings[casingId] = nil
    currentCasing = 0
end)

RegisterNetEvent('evidence:client:ClearCasingsInArea', function()
    local pos = GetEntityCoords(cache.ped)
    local casingList = {}

    if lib.progressCircle({
            duration = 5000,
            position = 'bottom',
            label = locale('progressbar.bullet_casing'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = false,
                car = false,
                combat = true,
                mouse = false,
            }
        })
    then
        if casings and next(casings) then
            for casingId in pairs(casings) do
                if #(pos - casings[casingId].coords) < 10.0 then
                    casingList[#casingList + 1] = casingId
                end
            end
            TriggerServerEvent('evidence:server:ClearCasings', casingList)
            exports.qbx_core:Notify(locale('success.bullet_casing_removed'), 'success')
        end
    else
        exports.qbx_core:Notify(locale('error.bullet_casing_not_removed'), 'error')
    end
end)

local function updateStatus()
    if not LocalPlayer.state.isLoggedIn then return end
    if currentStatusList and next(currentStatusList) then
        local changed = false
        for k, v in pairs(currentStatusList) do
            if v.time > 0 then
                v.time -= 10
                changed = true
            else
                currentStatusList[k] = nil
                changed = true
            end
        end
        if changed then
            TriggerServerEvent('evidence:server:UpdateStatus', currentStatusList)
        end
    end
    if shotAmount > 0 then
        shotAmount = 0
    end
end

local isWashing = false

local function isInWater()
    local ped = PlayerPedId()
    -- IsEntityInWater ve IsPedSwimming en güvenilir yöntemlerdir
    return IsEntityInWater(ped) or IsPedSwimming(ped)
end

local function checkWaterStatus()
    local hasGunpowder = (currentStatusList and currentStatusList['gunpowder'])

    if not LocalPlayer.state.isLoggedIn or not hasGunpowder or isWashing then
        return 5000
    end

    if IsPedSwimming(cache.ped) then
        isWashing = true
        CreateThread(function()
            local progress = 0
            local failCount = 0

            while isWashing and progress < 100 do
                Wait(1500)

                if isInWater() then
                    failCount = 0
                    progress = progress + 10

                    if progress <= 100 then
                        exports.qbx_core:Notify("Barut izleri temizleniyor: %" .. progress, 'inform', 1000)
                    end
                else
                    failCount = failCount + 1
                    if failCount >= 3 then
                        exports.qbx_core:Notify("Suda durmadığın için barut izleri temizlenemedi.", 'error')
                        isWashing = false
                        break
                    end
                end
            end

            if progress >= 100 and isWashing then
                currentStatusList['gunpowder'] = nil
                TriggerServerEvent('evidence:server:UpdateStatus', currentStatusList)
                exports.qbx_core:Notify("Sudaki hareketlerin barut izlerini tamamen temizledi.", 'inform')
                isWashing = false
            end
        end)

        return 2000
    else
        return 5000
    end
end

CreateThread(function()
    while true do
        Wait(15000)
        updateStatus()
    end
end)

CreateThread(function()
    while true do
        local sleep = checkWaterStatus()
        Wait(sleep)
    end
end)

local function onPlayerShooting()
    shotAmount += 1
    if shotAmount > 5 and not currentStatusList?.gunpowder then
        if math.random(1, 10) <= 7 then
            TriggerEvent('evidence:client:SetStatus', 'gunpowder', 720)
        end
    end
    -- dropBulletCasing(cache.weapon, cache.ped)
end

local isShootingThreadActive = false

lib.onCache('weapon', function(weapon)
    if weapon then
        if not isShootingThreadActive then
            isShootingThreadActive = true
            CreateThread(function()
                while isShootingThreadActive do
                    Wait(1)
                    if IsPedShooting(cache.ped) and not ignoredWeapons[cache.weapon] then
                        onPlayerShooting()
                    end
                end
            end)
        end
    else
        isShootingThreadActive = false
    end
end)

---@param coords vector3
---@return string
local function getStreetLabel(coords)
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 then
        streetLabel = streetLabel .. ' | ' .. street2
    end
    local sanitized = streetLabel:gsub("%'", "")
    return sanitized
end

local function getPlayerDistanceFromCoords(coords)
    local pos = GetEntityCoords(cache.ped)
    return #(pos - coords)
end

---@param metadata table
local function enrichCasingMetadata(metadata)
    local weapon = exports.qbx_core:GetWeapons()[casings[currentCasing].type]
    if not weapon then return end

    local weaponData = exports.ox_inventory:Items(string.upper(weapon.name))
    if not weaponData?.ammoname then return end

    local ammo = exports.ox_inventory:Items(weaponData.ammoname)
    if ammo?.label then
        metadata.ammolabel = ammo.label
    end
end

---@class DrawEvidenceIfInRangeArgs
---@field evidenceId integer
---@field coords vector3
---@field text string
---@field metadata table
---@field serverEventOnPickup string

---@param args DrawEvidenceIfInRangeArgs
local function drawEvidenceIfInRange(args)
    if getPlayerDistanceFromCoords(args.coords) >= 1.5 then return end

    qbx.drawText3d({ text = args.text, coords = args.coords })

    if IsControlJustReleased(0, 47) then
        if args.metadata.type == locale('info.casing') then
            enrichCasingMetadata(args.metadata)
        end

        TriggerServerEvent(args.serverEventOnPickup, args.evidenceId, args.metadata)
    end
end

--- draw 3D text on the ground to show evidence, if they press pickup button, set metadata and add it to their inventory.
-- CreateThread(function()
--     while true do
--         Wait(0)

--         if currentCasing and currentCasing ~= 0 then
--             drawEvidenceIfInRange({
--                 evidenceId = currentCasing,
--                 coords = casings[currentCasing].coords,
--                 text = locale('info.bullet_casing', casings[currentCasing].type),
--                 metadata = {
--                     type = locale('info.casing'),
--                     street = getStreetLabel(casings[currentCasing].coords),
--                     ammotype = casings[currentCasing].type,
--                     serie = casings[currentCasing].serie
--                 },
--                 serverEventOnPickup = 'evidence:server:AddCasingToInventory'
--             })
--         end

--         if currentBloodDrop and currentBloodDrop ~= 0 then
--             drawEvidenceIfInRange({
--                 evidenceId = currentBloodDrop,
--                 coords = bloodDrops[currentBloodDrop].coords,
--                 text = locale('info.blood_text', dnaHash(bloodDrops[currentBloodDrop].citizenid)),
--                 metadata = {
--                     type = locale('info.blood'),
--                     street = getStreetLabel(bloodDrops[currentBloodDrop].coords),
--                     dnalabel = dnaHash(bloodDrops[currentBloodDrop].citizenid),
--                     bloodtype = bloodDrops[currentBloodDrop].bloodtype
--                 },
--                 serverEventOnPickup = 'evidence:server:AddBlooddropToInventory'
--             })
--         end

--         if currentFingerprint and currentFingerprint ~= 0 then
--             drawEvidenceIfInRange({
--                 evidenceId = currentFingerprint,
--                 coords = fingerprints[currentFingerprint].coords,
--                 text = locale('info.fingerprint_text'),
--                 metadata = {
--                     type = locale('info.fingerprint'),
--                     street = getStreetLabel(fingerprints[currentFingerprint].coords),
--                     fingerprint = fingerprints[currentFingerprint].fingerprint
--                 },
--                 serverEventOnPickup = 'evidence:server:AddFingerprintToInventory'
--             })
--         end
--     end
-- end)

---@param evidence table<number, {coords: vector3}>
---@return number? evidenceId
local function getCloseEvidence(evidence)
    local pos = GetEntityCoords(cache.ped, true)
    for evidenceId, v in pairs(evidence) do
        local dist = #(pos - v.coords)
        if dist < 1.5 then
            return evidenceId
        end
    end
end

local isEvidenceThreadActive = false

lib.onCache('weapon', function(weapon)
    if weapon == `WEAPON_FLASHLIGHT` and LocalPlayer.state.isLoggedIn and QBX.PlayerData.job.type == 'leo' and QBX.PlayerData.job.onduty then
        if not isEvidenceThreadActive then
            isEvidenceThreadActive = true
            CreateThread(function()
                while isEvidenceThreadActive and cache.weapon == `WEAPON_FLASHLIGHT` do
                    local closeEvidenceSleep = 1000
                    if IsPlayerFreeAiming(cache.playerId) then
                        closeEvidenceSleep = 10
                        currentCasing = getCloseEvidence(casings) or currentCasing
                        currentBloodDrop = getCloseEvidence(bloodDrops) or currentBloodDrop
                        currentFingerprint = getCloseEvidence(fingerprints) or currentFingerprint
                    end
                    Wait(closeEvidenceSleep)
                end
                isEvidenceThreadActive = false
            end)
        end
    else
        isEvidenceThreadActive = false
    end
end)