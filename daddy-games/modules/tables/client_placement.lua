local isPlacing = false
local previewEntity = nil

local function getGroundZ(x, y, z)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local targetZ = (z and z > 0) and z or pCoords.z

    -- 1. ShapeTest dikey raycast (+2.0m -> -3.5m)
    local ray = StartShapeTestRay(x, y, targetZ + 2.0, x, y, targetZ - 3.5, 1 | 16 | 256, ped, 7)
    local _, hit, hitCoords = GetShapeTestResult(ray)
    if hit == 1 and hitCoords.z > (pCoords.z - 2.5) then
        return hitCoords.z
    end

    -- 2. Native ground Z kontrolü
    local found, gz = GetGroundZFor_3dCoord(x, y, targetZ + 1.0, false)
    if found and gz > (pCoords.z - 2.5) then
        return gz
    end

    -- 3. Oyuncunun bastığı zemin seviyesi
    return pCoords.z - 0.98
end

local function raycastFromCamera(distance)
    local camRot = GetGameplayCamRot(2)
    local camCoord = GetGameplayCamCoord()
    local rotZ = math.rad(camRot.z)
    local rotX = math.rad(camRot.x)
    local cosX = math.abs(math.cos(rotX))
    local dir = vector3(-math.sin(rotZ) * cosX, math.cos(rotZ) * cosX, math.sin(rotX))
    local target = camCoord + (dir * distance)

    local ray = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, target.x, target.y, target.z, -1, PlayerPedId(), 7)
    local _, hit, hitCoords = GetShapeTestResult(ray)
    if hit == 1 then
        return hitCoords
    end
    return target
end

local function rotationToDirection(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosX, math.cos(rotZ) * cosX, math.sin(rotX))
end

function StartTablePlacement(tableTypeKey, customModel)
    if isPlacing then return end

    local typeData = Config.Tables.Types[tableTypeKey]
    if not typeData and not customModel then
        lib.notify({ type = 'error', title = 'Hata', description = 'Geçersiz masa türü.' })
        return
    end

    local modelName = customModel or (typeData and typeData.model) or 'prop_table_tennis'
    local modelHash = GetHashKey(modelName)

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 6000
    while not HasModelLoaded(modelHash) do
        Wait(10)
        if GetGameTimer() > timeout then
            lib.notify({ type = 'error', title = 'Model Yüklenemedi', description = modelName .. ' modeli yüklenemedi!' })
            return
        end
    end

    isPlacing = true

    local ped = PlayerPedId()

    -- Karakteri Sabitle
    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, true)
    pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
    SetPedCanRagdoll(ped, false)

    local pCoords = GetEntityCoords(ped)
    local pHeading = GetEntityHeading(ped)

    -- Başlangıç Konumu: Karakterin 2.5 metre önü ve tam zemin yüksekliği
    local forward = GetEntityForwardVector(ped)
    local startGroundZ = getGroundZ(pCoords.x + (forward.x * 2.5), pCoords.y + (forward.y * 2.5), pCoords.z)
    local currentPos = vector3(pCoords.x + (forward.x * 2.5), pCoords.y + (forward.y * 2.5), startGroundZ)
    local currentHeading = math.floor(pHeading + 0.5)

    local modeRaycast = false
    local zOffsetManual = 0.0

    pcall(function() exports['FeloxAC']:CreateObject(modelHash) end) --[[FeloxAC:auto]]
    previewEntity = CreateObject(modelHash, currentPos.x, currentPos.y, currentPos.z, false, false, false)
    SetEntityAlpha(previewEntity, 195, false)
    SetEntityCollision(previewEntity, false, false)
    SetEntityCoordsNoOffset(previewEntity, currentPos.x, currentPos.y, currentPos.z, false, false, false)
    FreezeEntityPosition(previewEntity, true)

    local function updateTextUI()
        local title = typeData and typeData.label or modelName
        local text = ('**%s**  •  `%.0f°`\n[W/A/S/D] Taşı  •  [Q/E/Scroll] Çevir  •  [Z/C] Z-Ayar  •  [G] Zemin  •  [ENTER] Kaydet  •  [ESC] İptal'):format(
            title, currentHeading
        )
        lib.showTextUI(text, {
            position = 'top-center',
            icon = 'gamepad',
            style = {
                borderRadius = 8,
                backgroundColor = 'rgba(15, 23, 42, 0.92)',
                color = '#f8fafc',
                border = '1px solid rgba(255, 255, 255, 0.1)',
                padding = '6px 14px',
                fontSize = '12px'
            }
        })
    end

    updateTextUI()

    CreateThread(function()
        local lastUiUpdate = 0

        while isPlacing do
            Wait(0)
            -- Kontrolleri Devre Dışı Bırak
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 182, true)

            -- Kalıcı Yavaş / Hassas İnce Ayar Hızı
            local isShift = IsControlPressed(0, 21)
            local stepMove = isShift and 0.005 or 0.02
            local stepRot = isShift and 0.5 or 2.0
            local stepZ = isShift and 0.002 or 0.01

            -- Mod Değiştirme (F veya CAPSLOCK)
            if IsControlJustPressed(0, 23) or IsControlJustPressed(0, 137) then
                modeRaycast = not modeRaycast
                lib.notify({
                    title = 'Yerleştirme Modu',
                    description = modeRaycast and 'Lazer / Kamera Takip Modu aktif.' or 'Serbest WASD Hareket Modu aktif.',
                    type = 'inform'
                })
                updateTextUI()
            end

            local camRot = GetGameplayCamRot(2)
            local camDir = rotationToDirection(camRot)
            local camForward = vector3(camDir.x, camDir.y, 0.0)
            local camForwardLen = #camForward
            if camForwardLen > 0.001 then camForward = camForward / camForwardLen end
            local camRight = vector3(camForward.y, -camForward.x, 0.0)

            -- Konumlandırma
            if modeRaycast then
                local hitCoords = raycastFromCamera(10.0)
                local groundZ = getGroundZ(hitCoords.x, hitCoords.y, hitCoords.z)
                currentPos = vector3(hitCoords.x, hitCoords.y, groundZ + zOffsetManual)
            else
                if IsControlPressed(0, 32) then currentPos = currentPos + (camForward * stepMove) end
                if IsControlPressed(0, 33) then currentPos = currentPos - (camForward * stepMove) end
                if IsControlPressed(0, 34) then currentPos = currentPos - (camRight * stepMove) end
                if IsControlPressed(0, 35) then currentPos = currentPos + (camRight * stepMove) end
            end

            -- Açı Döndürme
            local headingChanged = false
            if IsControlPressed(0, 44) or IsControlJustPressed(0, 14) then
                currentHeading = (currentHeading - stepRot) % 360.0
                headingChanged = true
            end
            if IsControlPressed(0, 38) or IsControlJustPressed(0, 15) then
                currentHeading = (currentHeading + stepRot) % 360.0
                headingChanged = true
            end

            -- Hızlı 90 Derece Döndürme (R)
            if IsControlJustPressed(0, 45) then
                currentHeading = (currentHeading + 90.0) % 360.0
                headingChanged = true
                lib.notify({ title = 'Dönüş', description = ('Açı: %.1f°'):format(currentHeading), type = 'inform' })
            end

            -- Yükseklik Ayarı (Z / C)
            if IsControlPressed(0, 48) or IsControlPressed(0, 10) then
                currentPos = vector3(currentPos.x, currentPos.y, currentPos.z + stepZ)
                zOffsetManual = zOffsetManual + stepZ
            end
            if IsControlPressed(0, 26) or IsControlPressed(0, 11) then
                currentPos = vector3(currentPos.x, currentPos.y, currentPos.z - stepZ)
                zOffsetManual = zOffsetManual - stepZ
            end

            -- Zemine Sıfırla (G)
            if IsControlJustPressed(0, 47) then
                local gz = getGroundZ(currentPos.x, currentPos.y, currentPos.z)
                currentPos = vector3(currentPos.x, currentPos.y, gz)
                zOffsetManual = 0.0
                lib.notify({ title = 'Zemin', description = 'Masa tam zemin hizasına oturtuldu.', type = 'inform' })
            end

            -- Karakter Önüne Sıfırla (H)
            if IsControlJustPressed(0, 74) then
                local pedCoord = GetEntityCoords(ped)
                local pedFwd = GetEntityForwardVector(ped)
                local resetGroundZ = getGroundZ(pedCoord.x + (pedFwd.x * 2.5), pedCoord.y + (pedFwd.y * 2.5), pedCoord.z)
                currentPos = vector3(pedCoord.x + (pedFwd.x * 2.5), pedCoord.y + (pedFwd.y * 2.5), resetGroundZ)
                currentHeading = math.floor(GetEntityHeading(ped) + 0.5)
                zOffsetManual = 0.0
                headingChanged = true
                lib.notify({ title = 'Sıfırlandı', description = 'Masa karakterin önüne getirildi.', type = 'inform' })
            end

            -- Canlı Preview Güncellemesi
            if DoesEntityExist(previewEntity) then
                SetEntityCoordsNoOffset(previewEntity, currentPos.x, currentPos.y, currentPos.z, false, false, false)
                SetEntityHeading(previewEntity, currentHeading)
            end

            -- 3D Zemin Halkası
            DrawMarker(
                1, currentPos.x, currentPos.y, currentPos.z - 0.02,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                2.0, 2.0, 0.05,
                59, 130, 246, 120,
                false, false, 2, false, nil, nil, false
            )

            local now = GetGameTimer()
            if headingChanged or (now - lastUiUpdate > 600) then
                lastUiUpdate = now
                updateTextUI()
            end

            -- ONAYLA & SABİTLE (ENTER / Sol Tık)
            if IsControlJustPressed(0, 18) or IsControlJustPressed(0, 201) or IsDisabledControlJustPressed(0, 24) then
                isPlacing = false
                lib.hideTextUI()

                if DoesEntityExist(previewEntity) then DeleteEntity(previewEntity) end
                previewEntity = nil

                FreezeEntityPosition(ped, false)
                pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
                SetEntityInvincible(ped, false)
                pcall(function() exports['FeloxAC']:canRagdoll(true) end) --[[FeloxAC:auto]]
                SetPedCanRagdoll(ped, true)

                local finalPos = vector3(
                    math.floor(currentPos.x * 100 + 0.5) / 100,
                    math.floor(currentPos.y * 100 + 0.5) / 100,
                    math.floor(currentPos.z * 100 + 0.5) / 100
                )
                local finalHeading = math.floor(currentHeading * 100 + 0.5) / 100

                TriggerServerEvent('daddy-games:server:addTable', {
                    type = tableTypeKey,
                    model = modelName,
                    pos = finalPos,
                    heading = finalHeading,
                })

                local snippet = ('{ pos = vector3(%.2f, %.2f, %.2f), heading = %.2f, model = "%s" },'):format(
                    finalPos.x, finalPos.y, finalPos.z, finalHeading, modelName
                )
                lib.setClipboard(snippet)

                print(('^2[daddy-games]^7 Yeni masa kaydedildi! Lua Formatı:\n%s'):format(snippet))
                return
            end

            -- İPTAL ET (ESC / Backspace / Sağ Tık)
            if IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 25) then
                isPlacing = false
                lib.hideTextUI()

                if DoesEntityExist(previewEntity) then DeleteEntity(previewEntity) end
                previewEntity = nil

                FreezeEntityPosition(ped, false)
                pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
                SetEntityInvincible(ped, false)
                pcall(function() exports['FeloxAC']:canRagdoll(true) end) --[[FeloxAC:auto]]
                SetPedCanRagdoll(ped, true)

                lib.notify({ title = 'İptal Edildi', description = 'Masa yerleştirme işlemi iptal edildi.', type = 'inform' })
                return
            end
        end
    end)
end
