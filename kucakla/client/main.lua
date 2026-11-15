local isDead = false
local aktif = false
local tip = ""
local oyuncu = ""
local targetId = 0
local playerState = { kucak = false, rehin = false }

local animasyonlar = {
    ["kucak"] = {
        ["oyuncu1"] = {
            ["dic"] = "missfinale_c2mcs_1",
            ["anim"] = "fin_c2_mcs_1_camman",
            ["flag"] = 49,
        },
        ["oyuncu2"] = {
            ["dic"] = "nm",
            ["anim"] = "firemans_carry",
            ["flag"] = 33,
        }
    },
    ["rehin"] = {
        ["oyuncu1"] = {
            ["dic"] = "anim@gangops@hostage@",
            ["anim"] = "perp_idle",
            ["flag"] = 49,
        },
        ["oyuncu2"] = {
            ["dic"] = "anim@gangops@hostage@",
            ["anim"] = "victim_idle",
            ["flag"] = 49,
        }
    }
}

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

local function setHas(tip, value)
    local v = value and true or false
    if not tip then
        playerState.kucak = v
        playerState.rehin = v
        return
    end
    tip = tostring(tip):lower()
    if tip == "kucakla" then tip = "kucak" end
    if tip == "rehinal" then tip = "rehin" end
    if playerState[tip] ~= nil then
        playerState[tip] = v
    end
end

local function isHas(tip)
    if not tip then
        return playerState.kucak == true or playerState.rehin == true
    end
    tip = tostring(tip):lower()
    if tip == "kucakla" then tip = "kucak" end
    if tip == "rehinal" then tip = "rehin" end
    if playerState[tip] == nil then return false end
    return playerState[tip] == true
end

exports('isHas', isHas)

RegisterNetEvent('kd-kucakla:kucaklabeni')
AddEventHandler('kd-kucakla:kucaklabeni', function()
    TriggerEvent("kd-kucakla:kontrol", "kucak")
end)

local bussy = true
RegisterNetEvent('kd-kucakla:kontrol')
AddEventHandler('kd-kucakla:kontrol', function(xtip)
    if bussy then
        bussy = false
        local playerPed = PlayerPedId()
        if not IsEntityAttached(playerPed) then
            lib.notify({ description = 'İşlem Gerçekleştiriliyor!', type = 'inform' })
            if not aktif then Citizen.Wait(2500) end
            if targetId == 0 then
                local player = lib.getClosestPlayer(GetEntityCoords(playerPed), 3.0)
                if not player then
                    lib.notify({ description = 'Yakınlarda oyuncu yok!', type = 'error' })
                    bussy = true
                    return
                end
                targetId = GetPlayerServerId(player)
                local playerServerId = GetPlayerFromServerId(targetId)
                local targetPed = GetPlayerPed(playerServerId)
                if not IsEntityVisible(targetPed) then
                    lib.notify({ description = 'Yakınlarda oyuncu yok!', type = 'error' })
                    bussy = true
                    return
                end
            end
            if not aktif then
                oyuncu = "oyuncu1"
                tip = xtip
                setHas(tip, true)
                local anim = animasyonlar[tip]["oyuncu1"]
                if tip == "kucak" then
                    loadAnimDict(anim.dic)
                    TaskPlayAnim(playerPed, anim.dic, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
                    lib.notify({ description = '[X] ile Kucakladığın Oyuncuyu Bırakabilirsin', type = 'inform' })
                elseif tip == "rehin" then
                    local _, hash = GetCurrentPedWeapon(playerPed)
                    if GetWeapontypeGroup(hash) ~= 416676503 then
                        lib.notify({ description = 'Kişiyi rehin Almak için silahının olması lazım!', type = 'error' })
                        bussy = true
                        return
                    end
                    lib.notify({ description = 'Oyuncu Rehin Alınıyor!' })
                    loadAnimDict(anim.dic)
                    TaskPlayAnim(playerPed, anim.dic, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
                end
                TriggerServerEvent("kd-kucakla:server:oyuncu-2-anim", targetId, tip)
                aktif = true
            else
                lib.notify({ description = 'Oyuncu Bırakılıyor!' })
                if tip == "rehin" then
                    TriggerServerEvent("kd-kucakla:server:rehin-birak", targetId, "birak")
                    rehineBirak("oyuncu1")
                else
                    TriggerServerEvent("kd-kucakla:server:anim-iptal", targetId)
                    animIptal()
                end
            end
        end
        bussy = true
    end
end)

RegisterNetEvent('kd-kucakla:client:anim-iptal')
AddEventHandler('kd-kucakla:client:anim-iptal', function()
    animIptal()
end)

function animIptal()
    aktif = false
    local playerPed = PlayerPedId()
    local wasAttached = IsEntityAttached(playerPed)
    local currentPos = GetEntityCoords(playerPed)
    local currentHeading = GetEntityHeading(playerPed)

    if wasAttached then
        local interiorId = GetInteriorFromEntity(playerPed)
        if interiorId == 0 then
            local groundZ = 0.0
            local _, groundZFound = GetGroundZFor_3dCoord(currentPos.x, currentPos.y, currentPos.z, groundZ, false)
            if groundZFound and math.abs(groundZFound - currentPos.z) < 3.0 then
                currentPos = vector3(currentPos.x, currentPos.y, groundZFound + 0.5)
            end
        end

        local isDeadOrLaststand = false
        if GetResourceState('qbx_medical') == 'started' then
            local isDead = exports.qbx_medical:IsDead()
            local isLaststand = exports.qbx_medical:IsLaststand()
            if isDead or isLaststand then
                isDeadOrLaststand = true
            end
        end

        local anim = animasyonlar[tip][oyuncu]
        if anim then
            StopAnimTask(playerPed, anim.dic, anim.anim, 1.0)
        end

        DetachEntity(playerPed, false, false)
        ClearPedTasks(playerPed)
        ClearPedTasksImmediately(playerPed)
        SetEntityCollision(playerPed, true, true)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(playerPed, currentPos.x, currentPos.y, currentPos.z, false, false, false, false)
        SetEntityHeading(playerPed, currentHeading)
        SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)

        if isDeadOrLaststand then
            FreezeEntityPosition(playerPed, true)
            pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
            SetEntityInvincible(playerPed, true)
            pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, false)
            TriggerEvent('kn-kucakla:client:updateDeathPosition', currentPos, currentHeading)
            Citizen.Wait(100)
            if exports.qbx_medical:IsLaststand() then
                loadAnimDict("amb@world_human_bum_slumped@male@laying_on_left_side@base")
                TaskPlayAnim(playerPed, "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1,
                    1, 0, false, false, false)
            else
                loadAnimDict("dead")
                TaskPlayAnim(playerPed, "dead", "dead_a", 8.0, 8.0, -1, 1, 0, false, false, false)
            end
            Citizen.Wait(200)
            FreezeEntityPosition(playerPed, false)
            pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, false)
        else
            FreezeEntityPosition(playerPed, false)
            pcall(function() exports['FeloxAC']:canRagdoll(true) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, true)
            pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
            SetEntityInvincible(playerPed, false)
            Citizen.Wait(50)
            ClearPedTasks(playerPed)
            ClearPedTasksImmediately(playerPed)
            ResetPedMovementClipset(playerPed, 0.0)
            ResetPedStrafeClipset(playerPed)
            Citizen.Wait(100)
        end
    else
        ClearPedSecondaryTask(playerPed)
    end
    targetId = 0
    setHas(nil, false)
end

RegisterNetEvent('kd-kucakla:client:oyuncu-2-anim')
AddEventHandler('kd-kucakla:client:oyuncu-2-anim', function(xtip, oyuncu1)
    if not aktif then
        local playerPed = PlayerPedId()
        local playerServerId = GetPlayerFromServerId(oyuncu1)
        local targetPed = GetPlayerPed(playerServerId)
        oyuncu = "oyuncu2"
        tip = xtip
        setHas(tip, true)
        local anim = animasyonlar[tip][oyuncu]
        if tip == "kucak" then
            loadAnimDict(anim.dic)
            AttachEntityToEntity(playerPed, targetPed, 0, 0.20, 0.15, 0.63, 0.5, 0.5, 5.0, false, false, false, false, 2,
                false)
            TaskPlayAnim(playerPed, anim.dic, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
        elseif tip == "rehin" then
            loadAnimDict(anim.dic)
            AttachEntityToEntity(playerPed, targetPed, 0, -0.24, 0.11, 0.0, 0.5, 0.5, 0.0, false, false, false, false, 2,
                false)
            TaskPlayAnim(playerPed, anim.dic, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
        end
        aktif = true
    end
end)

local lastNotifTime = GetGameTimer()
Citizen.CreateThread(function()
    while true do
        local time = 1000
        if aktif then
            time = 1
            local playerPed = PlayerPedId()
            local anim = animasyonlar[tip][oyuncu]
            if not IsEntityPlayingAnim(PlayerPedId(), anim.dic, anim.anim, 3) then
                TaskPlayAnim(playerPed, anim.dic, anim.anim, 8.0, -8.0, -1, anim.flag, 0, false, false, false)
            end

            DisablePlayerFiring(playerPed, true)
            SetPedCanPlayGestureAnims(playerPed, false)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 56, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 22, false)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 288, true)
            DisableControlAction(0, 289, true)
            DisableControlAction(0, 167, true)
            DisableControlAction(0, 73, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)

            if oyuncu == "oyuncu2" or tip == "rehin" then
                DisableControlAction(0, 23, true)
                DisableControlAction(0, 170, true)
                DisableControlAction(2, 199, true)
                DisableControlAction(0, 59, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 75, true)
                DisableControlAction(0, 301, true)
                DisableControlAction(27, 75, true)
            end

            DisableControlAction(0, 73, true)
            if oyuncu == "oyuncu1" and IsDisabledControlJustPressed(0, 73) then
                if tip == "rehin" then
                    TriggerServerEvent("kd-kucakla:server:rehin-birak", targetId, "birak")
                    rehineBirak("oyuncu1")
                else
                    TriggerServerEvent("kd-kucakla:server:anim-iptal", targetId)
                    animIptal()
                end
            end

            if oyuncu == "oyuncu1" and tip == "rehin" then
                if GetGameTimer() > lastNotifTime then
                    lastNotifTime = GetGameTimer() + 10000
                    lib.notify({ description = "[X] Serbest Bırak, [H] Öldür", type = 'error' })
                end
                if IsDisabledControlJustPressed(0, 74) then
                    local ammo = GetAmmoInPedWeapon(playerPed, GetSelectedPedWeapon(playerPed))
                    if ammo > 0 then
                        TriggerServerEvent("kd-kucakla:server:rehin-birak", targetId, "oldur")
                        rehineOldur("oyuncu1")
                    else
                        lib.notify({ description = "Silahında Mermi Yok!", type = 'error' })
                    end
                end
            end
        end
        Citizen.Wait(time)
    end
end)

RegisterNetEvent('kd-kucakla:client:rehin-birak')
AddEventHandler('kd-kucakla:client:rehin-birak', function(rehintip)
    if rehintip == "birak" then
        rehineBirak("oyuncu2")
    else
        rehineOldur("oyuncu2")
    end
end)

function rehineBirak(oyuncu)
    aktif = false
    local playerPed = PlayerPedId()
    local wasAttached = IsEntityAttached(playerPed)
    local currentPos = GetEntityCoords(playerPed)
    local currentHeading = GetEntityHeading(playerPed)

    if wasAttached then
        local interiorId = GetInteriorFromEntity(playerPed)
        if interiorId == 0 then
            local groundZ = 0.0
            local _, groundZFound = GetGroundZFor_3dCoord(currentPos.x, currentPos.y, currentPos.z, groundZ, false)
            if groundZFound and math.abs(groundZFound - currentPos.z) < 3.0 then
                currentPos = vector3(currentPos.x, currentPos.y, groundZFound + 0.5)
            end
        end

        local isDeadOrLaststand = false
        if GetResourceState('qbx_medical') == 'started' then
            local isDead = exports.qbx_medical:IsDead()
            local isLaststand = exports.qbx_medical:IsLaststand()
            if isDead or isLaststand then
                isDeadOrLaststand = true
            end
        end

        local anim = animasyonlar[tip][oyuncu]
        if anim then
            StopAnimTask(playerPed, anim.dic, anim.anim, 1.0)
        end

        DetachEntity(playerPed, false, false)
        ClearPedTasks(playerPed)
        ClearPedTasksImmediately(playerPed)
        SetEntityCollision(playerPed, true, true)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(playerPed, currentPos.x, currentPos.y, currentPos.z, false, false, false, false)
        SetEntityHeading(playerPed, currentHeading)
        SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)

        if isDeadOrLaststand then
            FreezeEntityPosition(playerPed, true)
            pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
            SetEntityInvincible(playerPed, true)
            pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, false)
            TriggerEvent('kn-kucakla:client:updateDeathPosition', currentPos, currentHeading)
            Citizen.Wait(100)
            if exports.qbx_medical:IsLaststand() then
                loadAnimDict("amb@world_human_bum_slumped@male@laying_on_left_side@base")
                TaskPlayAnim(playerPed, "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1,
                    1, 0, false, false, false)
            else
                loadAnimDict("dead")
                TaskPlayAnim(playerPed, "dead", "dead_a", 8.0, 8.0, -1, 1, 0, false, false, false)
            end
            Citizen.Wait(200)
            FreezeEntityPosition(playerPed, false)
            pcall(function() exports['FeloxAC']:canRagdoll(false) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, false)
        else
            FreezeEntityPosition(playerPed, false)
            pcall(function() exports['FeloxAC']:canRagdoll(true) end) --[[FeloxAC:auto]]
            SetPedCanRagdoll(playerPed, true)
            pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
            SetEntityInvincible(playerPed, false)
            Citizen.Wait(50)
            ClearPedTasks(playerPed)
            ClearPedTasksImmediately(playerPed)
            ResetPedMovementClipset(playerPed, 0.0)
            ResetPedStrafeClipset(playerPed)
            Citizen.Wait(100)
        end
    else
        ClearPedSecondaryTask(playerPed)
    end
    targetId = 0
    setHas("rehin", false)
end

function rehineOldur(oyuncu)
    aktif = false
    local playerPed = PlayerPedId()
    if IsEntityAttached(playerPed) then
        DetachEntity(playerPed, true, false)
        ClearPedTasksImmediately(playerPed)
    else
        ClearPedSecondaryTask(playerPed)
    end
    targetId = 0
    setHas("rehin", false)
    if oyuncu == "oyuncu1" then
        loadAnimDict("anim@gangops@hostage@")
        TaskPlayAnim(playerPed, "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
        SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
    else
        loadAnimDict("anim@gangops@hostage@")
        TaskPlayAnim(playerPed, "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(1000)
        pcall(function() exports['FeloxAC']:healthRefilled() end) --[[FeloxAC:auto]]
        SetEntityHealth(playerPed, 0)
    end
end
