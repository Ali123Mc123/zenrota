local ox_lib = exports.ox_lib

-- Bunlar dosya YUKLENIRKEN bir kez hesaplaniyordu (oyuncu daha spawn olmadan),
-- ve asagidaki mesafe testleri sonsuza dek o eski noktadan olcuyordu; yani
-- culling oyuncunun konumuna gore hic calismiyordu. Canli konumu oku.
local function playerCoords()
    return GetEntityCoords(cache.ped or PlayerPedId())
end

-- Secilen zaman dongusu (timecycle) hatirlanir; baska bir script (or. garaj
-- showroom'u) global timecycle'i temizlerse exports.FPSBoost:reapply() ile geri gelir.
local currentTC
local function setTC(tc, strength, extra)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    currentTC = tc and { tc = tc, strength = strength, extra = extra } or nil
    if not tc then return end
    SetTimecycleModifier(tc)
    if strength then SetTimecycleModifierStrength(strength) end
    if extra then SetExtraTimecycleModifier(extra) end
end

exports('reapply', function()
    if currentTC then setTC(currentTC.tc, currentTC.strength, currentTC.extra) end
end)

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = {handle = iter, destructor = disposeFunc}
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end

local function GetWorldObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function GetWorldPeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function GetWorldVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function modifyWorldObjects(alpha, distance)
    for obj in GetWorldObjects() do
        if not IsEntityOnScreen(obj) and #(playerCoords() - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        Wait(0)
    end
end

local function modifyWorldPeds(alpha, distance)
    for obj in GetWorldPeds() do
        if not IsEntityOnScreen(obj) and #(playerCoords() - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        SetPedAoBlobRendering(obj, false)
        Wait(0)
    end
end

local function modifyWorldVehicles(alpha, distance)
    for obj in GetWorldVehicles() do
        if not IsEntityOnScreen(obj) and #(playerCoords() - GetEntityCoords(obj)) > distance then
            SetEntityAlpha(obj, 0)
            if not IsEntityAMissionEntity(obj) then
                SetEntityAsNoLongerNeeded(obj)
            end
        else
            if GetEntityAlpha(obj) ~= alpha then
                SetEntityAlpha(obj, alpha)
            end
        end
        Wait(0)
    end
end

local function applyFPSBoost(level)
    if level == "ultra_low" then
        setTC("ReduceDrawDistanceMission")
        modifyWorldObjects(210,90)
        modifyWorldPeds(245, 60)
        modifyWorldVehicles(255, 120)
        DisableOcclusionThisFrame()
        SetDisableDecalRenderingThisFrame()
        RopeDrawShadowEnabled(false)
        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)
        SetFlashLightFadeDistance(0.0)
        SetLightsCutoffDistanceTweak(0.0)
        DistantCopCarSirens(false)
        SetArtificialLightsState(true)
        RemoveParticleFxInRange(playerCoords(), 10.0)
        OverrideLodscaleThisFrame(0.4)
        fpsBoostActive = true
    elseif level == "medium" then
        setTC("yell_tunnel_nodirect", 0.5)
        modifyWorldObjects(210,130)
        modifyWorldPeds(250, 100)
        modifyWorldVehicles(255, 160)
        SetArtificialLightsState(false)
        SetReducePedModelBudget(false)
        SetReduceVehicleModelBudget(false)
        SetParticleFxNonLoopedAlpha(0.5)
        OverrideLodscaleThisFrame(0.6)
        DistantCopCarSirens(false)
        fpsBoostActive = true
        fpsBoostnopedandobj = false
    elseif level == "high" then
        setTC(nil)
        modifyWorldObjects(245,200)
        modifyWorldPeds(255, 150)
        modifyWorldVehicles(255, 250)
        SetArtificialLightsState(false)
        SetParticleFxNonLoopedAlpha(1.0)
        OverrideLodscaleThisFrame(0.8)
        DistantCopCarSirens(false)
        fpsBoostActive = false
        fpsBoostnopedandobj = false
    end
end

local function setUltraGraphics()
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    OverrideLodscaleThisFrame(2.0) 
    SetFlashLightFadeDistance(100.0) 
    SetLightsCutoffDistanceTweak(100.0) 
    CascadeShadowsSetCascadeBoundsScale(1.5) 
    CascadeShadowsSetDynamicDepthValue(1.0) 
    CascadeShadowsSetEntityTrackerScale(1.0)
    DistantCopCarSirens(false) 
    RopeDrawShadowEnabled(true)
    setTC('v_torture', nil, 'reflection_correct_ambient')
    fpsBoostActive = false
    fpsBoostnopedandobj = false
end


local function resetSettings()
    OverrideLodscaleThisFrame(1.0)
    DisableVehicleDistantlights(false)
    setTC(nil)
    SetArtificialLightsState(false)
    SetParticleFxNonLoopedAlpha(1.0)
    DistantCopCarSirens(false)
    fpsBoostActive = false
    fpsBoostnopedandobj = false
    for obj in GetWorldObjects() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        Wait(0)
    end
    for obj in GetWorldPeds() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        SetPedAoBlobRendering(obj, true)
        Wait(0)
    end
    for obj in GetWorldVehicles() do
        if GetEntityAlpha(obj) ~= 255 then
            SetEntityAlpha(obj, 255)
        end
        Wait(0)
    end
end

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
        repeat
            coroutine.yield(id)
            local next
            next, id = moveFunc(iter)
        until not next
        disposeFunc(iter)
    end)
end

function fpsmenu()
    lib.registerContext({
        id = 'fps_boost_menu',
        title = 'FPS Artırma Menüsü',
        options = {
            { title = 'Zaman Döngüleri', description = 'Çeşitli Zaman Döngüleri', icon = 'audio-description', onSelect = function() menutimecycle() end},
            { title = 'Ultra Düşük Artırma', description = 'Maksimum FPS Artırma', icon = 'rocket', onSelect = function() applyFPSBoost("ultra_low") lib.notify({ title = 'Ultra Düşük Artırma', description = 'FPS artırma uygulandı.', type = 'success' }) end },
            { title = 'Orta Artırma', description = 'Orta Seviye Artırma', icon = 'tachometer-alt', onSelect = function() applyFPSBoost("medium") lib.notify({ title = 'Orta Artırma', description = 'FPS artırma uygulandı.', type = 'success' }) end },
            { title = 'Yüksek Artırma', description = 'Düşük Seviye Artırma', icon = 'tachometer-alt', onSelect = function() applyFPSBoost("high") lib.notify({ title = 'Yüksek Artırma', description = 'FPS artırma uygulandı.', type = 'success' }) end },
            { title = 'Grafikler', description = 'En İyi Grafikler', icon = 'star', onSelect = function() setUltraGraphics() lib.notify({ title = 'Grafikler', description = 'Grafik kalitesi maksimuma ayarlandı.', type = 'success' }) end },
            { title = 'Sıfırla', description = 'Ayarları Sıfırla', icon = 'undo', onSelect = function() resetSettings() lib.notify({ title = 'Sıfırla', description = 'Ayarlar sıfırlandı.', type = 'success' }) end }
        }
    })
    lib.showContext('fps_boost_menu')
end

function menutimecycle()
    lib.registerContext({
        id = 'timecyclemenu',
        title = 'Zaman Döngüleri Menüsü',
        options = {
            {
                title = 'Tünel',
                description = 'FPS ARTIRMA',
                icon = 'star',
                onSelect = function()
                    setTC("yell_tunnel_nodirect")
                end,
            },
            {
                title = 'Sinema',
                description = 'FPS ARTIRMA',
                icon = 'face-smile',
                onSelect = function()
                    setTC("cinema")
                end,
            },
            {
                title = 'Yaşam',
                description = 'FPS ARTIRMA',
                icon = 'web-awesome',
                onSelect = function()
                    setTC("LifeInvaderLOD")
                end,
            },
            {
                title = 'Mesafe Azalt',
                description = 'FPS ARTIRMA',
                icon = 'circle',
                onSelect = function()
                    setTC("ReduceDrawDistanceMission")
                end,
            },
            {
                title = 'PowerPlay Karışım',
                description = 'GRAFİK',
                icon = 'circle',
                onSelect = function()
                    setTC("MP_Powerplay_blend")
                end,
            },
            {
                title = 'Tünel',
                description = 'Gelişmiş ışık',
                icon = 'circle',
                onSelect = function()
                    setTC("tunnel", nil, "reflection_correct_ambient")
                end,
            }
        }
    })

    lib.showContext('timecyclemenu')
end

RegisterCommand('fps', function()
    fpsmenu()
end)

RegisterNetEvent('fpsboost:openMenu')
AddEventHandler('fpsboost:openMenu', function()
    fpsmenu()
end)

Citizen.CreateThread(function()
    while true do
        if fpsBoostActive then
            local ped = cache.ped
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            ClearPedBloodDamage(ped)
            ClearPedWetness(ped)
            ClearPedEnvDirt(ped)
            ResetPedVisibleDamage(ped)
            ClearOverrideWeather()
            DisableVehicleDistantlights(false)
            SetRainLevel(0.0)
            SetWindSpeed(0.0)
            DistantCopCarSirens(false)
            Citizen.Wait(300)
        else
            Citizen.Wait(1500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if fpsBoostnopedandobj then
            local ped = cache.ped
            ClearAllBrokenGlass()
            ClearAllHelpMessages()
            LeaderboardsReadClearAll()
            ClearBrief()
            ClearGpsFlags()
            ClearPrints()
            ClearSmallPrints()
            ClearReplayStats()
            LeaderboardsClearCacheData()
            ClearFocus()
            ClearHdArea()
            ClearPedBloodDamage(ped)
            ClearPedWetness(ped)
            ClearPedEnvDirt(ped)
            ResetPedVisibleDamage(ped)
            ClearOverrideWeather()
            DisableVehicleDistantlights(false)
            SetRainLevel(0.0)
            SetWindSpeed(0.0)
            Citizen.Wait(300)
        else
            Citizen.Wait(1500)
        end
    end
end)


--                            NOT USED

/*Citizen.CreateThread(function()
    while true do
        if Config.clearpedandobj then
            if fpsBoostActive then
                local playerCoords = GetEntityCoords(PlayerPedId())
                for ped in EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(playerCoords - pedCoords)
                    if distance > 100.0 then
                        SetEntityAlpha(ped, 0)
                        SetEntityAsNoLongerNeeded(ped)
                    elseif distance > 50.0 then
                        if not IsEntityOnScreen(ped) then
                            SetEntityAlpha(ped, 0)
                            SetEntityAsNoLongerNeeded(ped)
                        else
                            SetEntityAlpha(ped, 210)
                        end
                        SetPedAoBlobRendering(ped, false)
                    end
                    Citizen.Wait(1)
                end
                for obj in EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) do
                    local objCoords = GetEntityCoords(obj)
                    local distance = #(playerCoords - objCoords)
                    if distance > 100.0 then
                        SetEntityAlpha(obj, 0)
                        SetEntityAsNoLongerNeeded(obj)
                        SetModelAsNoLongerNeeded(GetEntityModel(obj))
                    elseif distance > 50.0 then
                        if not IsEntityOnScreen(obj) then
                            SetEntityAlpha(obj, 0)
                            SetEntityAsNoLongerNeeded(obj)
                            SetModelAsNoLongerNeeded(GetEntityModel(obj))
                        else
                            SetEntityAlpha(obj, 170)
                        end
                    end
                    Citizen.Wait(1)
                end
                DisableOcclusionThisFrame()
                SetDisableDecalRenderingThisFrame()
                RemoveParticleFxInRange(playerCoords, 10.0)
                OverrideLodscaleThisFrame(0.1)
                SetStreamedTextureDictAsNoLongerNeeded("all")
                SetArtificialLightsState(true)
            end
        end
        Citizen.Wait(8)
    end
end)*/
