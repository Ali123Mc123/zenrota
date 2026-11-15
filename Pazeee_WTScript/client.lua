local currentAnimIndex = 1
local currentAnimData = Config.Animations[1]
local radioProp = nil
local lastPropData = nil 
local isLoopRunning = false 
local isTalking = false 
local currentWeapon = nil 

local function loadAnimDict(dict)
    lib.requestAnimDict(dict, 10000)
end

local function applyAnim(animData, index)
    if animData then
        exports['pma-voice']:setRadioTalkAnim(animData.dict, animData.anim)
        currentAnimData = animData
        if index then
            currentAnimIndex = index
        end
        if Config.Debug then print("[RadioAnim] Terapkan:", animData.label) end
    end
end

local function loadSavedAnimation()
    local saved = nil
    
    -- 1. Önce sunucudaki karakter metadata'sını sor
    local ok, svAnim = pcall(function()
        return lib.callback.await('radioanim:server:getSavedAnim', false)
    end)
    
    if ok and svAnim and Config.Animations[svAnim] then
        saved = svAnim
    end

    -- 2. Eğer metadata yoksa client KVP deposundan al
    if not saved then
        local kvpAnim = GetResourceKvpInt('pazeee_radio_anim')
        if kvpAnim and kvpAnim > 0 and Config.Animations[kvpAnim] then
            saved = kvpAnim
        end
    end

    -- 3. Bulunan animasyonu veya varsayılanı uygula
    if saved and Config.Animations[saved] then
        applyAnim(Config.Animations[saved], saved)
    else
        applyAnim(Config.Animations[1], 1)
    end
end

CreateThread(function()
    Wait(2000) -- pma-voice exportlarının hazır olmasını bekle
    loadSavedAnimation()
end)

-- Karakter yüklendiğinde tercihi geri yükle
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    loadSavedAnimation()
end)

RegisterNetEvent('qbx_core:client:playerLoaded', function()
    Wait(1000)
    loadSavedAnimation()
end)

local function hasPropDataChanged(animData)
    if not lastPropData and animData.prop ~= "none" then
        return true
    end
    if lastPropData and animData.prop == "none" then
        return true
    end
    if lastPropData and animData.prop ~= "none" then
        return lastPropData.prop ~= animData.prop or
               lastPropData.bone ~= animData.bone or
               lastPropData.coords[1] ~= animData.coords[1] or
               lastPropData.coords[2] ~= animData.coords[2] or
               lastPropData.coords[3] ~= animData.coords[3]
    end
    return false
end

local function playAnim()
    if not currentAnimData then return end
    
    local ped = PlayerPedId()
    
    local dict = currentAnimData.dict
    local anim = currentAnimData.anim
    local flag = currentAnimData.flag or 49
    local prop_name = currentAnimData.prop
    local bone = currentAnimData.bone or 57005
    local coords = currentAnimData.coords or {0.0, 0.0, 0.0, 0.0, 0.0, 0.0}

    loadAnimDict(dict)

    if not IsEntityPlayingAnim(ped, dict, anim, 3) then
        TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, flag, 0, false, false, false)
    end

    local propDataChanged = hasPropDataChanged(currentAnimData)
    
    if propDataChanged then
        if radioProp and DoesEntityExist(radioProp) then
            SetEntityAsMissionEntity(radioProp, true, true)
            DeleteObject(radioProp)
        end
        radioProp = nil

        lastPropData = {
            prop = prop_name,
            bone = bone,
            coords = {coords[1], coords[2], coords[3]} 
        }

        if prop_name and prop_name ~= "none" then
            local boneIndex = GetPedBoneIndex(ped, bone)
            
            pcall(function() exports['FeloxAC']:CreateObject(GetHashKey(prop_name)) end) --[[FeloxAC:auto]]
            radioProp = CreateObject(GetHashKey(prop_name), 0, 0, 0, true, true, true) 
            if radioProp then
                SetEntityAsMissionEntity(radioProp, true, true)
                AttachEntityToEntity(
                    radioProp, ped, boneIndex,
                    coords[1], coords[2], coords[3],
                    coords[4], coords[5], coords[6],
                    true, true, false, true, 1, true
                )
                if Config.Debug then print("[RadioAnim] Prop dibuat:", radioProp) end
            end
        else
            if Config.Debug then print("[RadioAnim] Tidak ada prop untuk animasi ini") end
        end
    elseif radioProp and DoesEntityExist(radioProp) then
        local boneIndex = GetPedBoneIndex(ped, bone)
        AttachEntityToEntity(
            radioProp, ped, boneIndex,
            coords[1], coords[2], coords[3],
            coords[4], coords[5], coords[6],
            true, true, false, true, 1, true
        )
    end
end

local function stopAnim()
    local ped = PlayerPedId()
    
    if currentAnimData then
        StopAnimTask(ped, currentAnimData.dict, currentAnimData.anim, 1.0)
    end
    
    if radioProp and DoesEntityExist(radioProp) then
        SetEntityAsMissionEntity(radioProp, true, true)
        DeleteObject(radioProp)
    end
    
    radioProp = nil
    lastPropData = nil

    if Config.Debug then print("[RadioAnim] Dihentikan") end
end

RegisterNetEvent('radioanim:client:playAnim', function(animIndex)
    local animData = Config.Animations[animIndex]
    if animData then
        applyAnim(animData, animIndex)
    else
        stopAnim()
    end
end)

local menuOpen = false

-- The focus goes back first, so a failing step below can not leave the cursor on screen.
local function releaseMenu()
    menuOpen = false
    SetNuiFocus(false, false)
end

RegisterCommand('radioanim', function()
    local animLabels = {}
    for i, anim in ipairs(Config.Animations) do
        animLabels[i] = anim.label
    end
    SendNUIMessage({
        action = "OPEN_UI",
        animations = animLabels,
        currentAnim = currentAnimIndex
    })
    SetNuiFocus(true, true)
    menuOpen = true
end, false)

RegisterNUICallback('selectAnim', function(data, cb)
    releaseMenu()
    local index = tonumber(data.index)
    if index and Config.Animations[index] then
        cb('ok')
        currentAnimIndex = index
        SetResourceKvpInt('pazeee_radio_anim', index)
        TriggerServerEvent('radioanim:server:setAnim', index)
        applyAnim(Config.Animations[index], index)
    else
        cb('error')
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    releaseMenu()
    cb('ok')
end)

-- The character leaves with the menu open: the page closes and the focus goes back.
local function closeMenu()
    if not menuOpen then return end
    releaseMenu()
    SendNUIMessage({ action = "CLOSE_UI" })
end

RegisterNetEvent('QBCore:Client:OnPlayerUnload', closeMenu)
RegisterNetEvent('qbx_core:client:playerLoggedOut', closeMenu)

AddEventHandler('pma-voice:radioActive', function(isActive)
    if isActive then
        isTalking = true
        if currentAnimData then
            if not isLoopRunning then
                isLoopRunning = true
                CreateThread(function()
                    while isTalking do
                        playAnim()
                        Wait(300) 
                    end
                    stopAnim()
                    isLoopRunning = false
                end)
            end
        end
    else
        isTalking = false
        stopAnim()
        isLoopRunning = false
    end
end)

AddStateBagChangeHandler('radioActive', ('player:%s'):format(PlayerId()), function(_, _, value)
    if not value then 
        isTalking = false
        stopAnim()
        isLoopRunning = false
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if menuOpen then releaseMenu() end
        stopAnim()
    end
end)