local client = client
local spotlightActive = false
local spotlightThreadRunning = false
local activePreviewAnimation = nil
local previewAnimationGeneration = 0
local activeEmoteCommand = nil
local emoteResource = "cylex_animmenuv2"
local spotlightConfig = {
    r = 255,
    g = 255,
    b = 255,
    intensity = 9.0,
    distance = 0.65,
    angle = 0.0,
    height = 1.3
}

local function stopStudioLight()
    spotlightActive = false
end

local function stopPreviewAnimation(ped)
    if not activePreviewAnimation then return end
    StopAnimTask(
        ped or cache.ped or PlayerPedId(),
        activePreviewAnimation.dict,
        activePreviewAnimation.name,
        3.5
    )
    activePreviewAnimation = nil
end

local function cancelExternalEmote()
    if not activeEmoteCommand then return end
    if GetResourceState(emoteResource) == "started" then
        pcall(function()
            exports[emoteResource]:playEmote("c")
        end)
    end
    activeEmoteCommand = nil
end

-- editor extras: the ped turning on its own and other players hidden while the editor is open
local turntable, hidePlayers = false, false

local function stopEditorExtras()
    turntable, hidePlayers = false, false
end

RegisterNUICallback("appearance_get_locales", function(_, cb)
    local locale = Locales[LocaleName()] or Locales.en or {}
    cb(locale.UI or {})
end)

RegisterNUICallback("appearance_get_settings", function(_, cb)
    cb({ appearanceSettings = client.getAppearanceSettings() })
end)

RegisterNUICallback("appearance_get_data", function(_, cb)
    Wait(250)
    local appearanceData = client.getAppearance()
    -- Validate appearance data has required fields
    if not appearanceData or not appearanceData.model or appearanceData.model == "" then
        print("[illenium-appearance] appearance_get_data: Missing model, reading current ped")
        appearanceData = client.getPedAppearance(cache.ped)
        if not appearanceData.model or appearanceData.model == "" then
            appearanceData.model = "mp_m_freemode_01"
        end
    end
    if appearanceData.tattoos and not Config.RCoreTattoosCompatibility then
        client.setPedTattoos(cache.ped, appearanceData.tattoos)
    end
    local config = client.getConfig()
    -- with rcore_tattoos the tattoos are rcore's; openers such as the multichar creator may still ask for the tab
    if config and Config.RCoreTattoosCompatibility then config.tattoos = false end
    cb({ config = config, appearanceData = appearanceData, editor = Config.Editor })
end)

local SLOTS = { [1] = "berd", [2] = "hair", [3] = "uppr", [4] = "lowr", [5] = "hand", [6] = "feet", [7] = "teef",
    [8] = "accs", [9] = "task", [10] = "decl", [11] = "jbib" }
local PROP_SLOTS = { [0] = "p_head", [1] = "p_eyes", [2] = "p_ears", [6] = "p_lwrist", [7] = "p_rwrist" }

-- a clothing collection's picture folder: GTA's own clothing is base_m / base_f, a collection named for its gender
-- (mp_m_..., mp_f_...) keeps its name, any other gets the gender in front so the genders never share a folder
function client.pictureFolder(name, g)
    if not name or name == "" then return "base_" .. g end
    local lower = name:lower()
    if lower:find("^mp_[mf]_") then return lower end
    return ("mp_%s_%s"):format(g, lower)
end

-- each item's picture name: the clothing collection's folder and the item's number inside it
RegisterNUICallback("appearance_picture_keys", function(data, cb)
    local ped, id = cache.ped, tonumber(data and data.id)
    local model = GetEntityModel(ped)
    local female = model == `mp_f_freemode_01`
    if not id or not (female or model == `mp_m_freemode_01`) then return cb({}) end
    local prop = data.kind == "prop"
    local slot = prop and PROP_SLOTS[id] or SLOTS[id]
    if not slot then return cb({}) end
    local g = female and "f" or "m"
    local count = prop and GetNumberOfPedPropDrawableVariations(ped, id) or GetNumberOfPedDrawableVariations(ped, id)
    local keys = {}
    for drawable = 0, count - 1 do
        local name = prop and GetPedCollectionNameFromProp(ped, id, drawable) or GetPedCollectionNameFromDrawable(ped, id, drawable)
        local index = prop and GetPedCollectionLocalIndexFromProp(ped, id, drawable) or GetPedCollectionLocalIndexFromDrawable(ped, id, drawable)
        keys[drawable + 1] = { client.pictureFolder(name, g), index }
    end
    cb({ slot = slot, keys = keys })
end)

-- turntable: false, or how many degrees a second the character turns (Settings › Turn speed)
RegisterNUICallback("appearance_turntable", function(data, cb)
    cb(1)
    turntable = data and data.on and math.min(180.0, math.max(5.0, tonumber(data.speed) or 36.0)) or false
end)

-- the editor's soft clicks (Settings › Sounds): the game's own menu sounds
local SOUNDS = {
    pick = { "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    tab = { "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    confirm = { "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET" },
}

RegisterNUICallback("appearance_sound", function(data, cb)
    cb(1)
    local sound = SOUNDS[data and data.name]
    if sound then PlaySoundFrontend(-1, sound[1], sound[2], true) end
end)

RegisterNUICallback("appearance_hide_players", function(data, cb)
    cb(1)
    hidePlayers = data and data.on and true or false
end)

-- one loop for both extras, idle while they are off
CreateThread(function()
    while true do
        if turntable or hidePlayers then
            if turntable then SetEntityHeading(cache.ped, GetEntityHeading(cache.ped) + turntable * GetFrameTime()) end
            if hidePlayers then
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped ~= cache.ped then SetEntityLocallyInvisible(ped) end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- while the editor is open the character stands perfectly still: the freemode idle stopped on its first frame (no
-- breathing, no weight shifting) and no head turning toward the camera; a pose or an emote from the studio bar takes
-- over while it plays
local STILL = { m = { "move_m@generic", "idle" }, f = { "move_f@multiplayer", "idle" } }
CreateThread(function()
    local held -- the pose being held, to let go of when the editor closes or a pose starts
    while true do
        local ped = cache.ped
        if client.isCustomizing() and not activePreviewAnimation and not activeEmoteCommand then
            local pose = GetEntityModel(ped) == `mp_f_freemode_01` and STILL.f or STILL.m
            if not HasAnimDictLoaded(pose[1]) then RequestAnimDict(pose[1]) end
            SetPedCanHeadIk(ped, false)
            if HasAnimDictLoaded(pose[1]) then
                if not IsEntityPlayingAnim(ped, pose[1], pose[2], 3) then
                    TaskPlayAnim(ped, pose[1], pose[2], 1000.0, 1000.0, -1, 1, 0.0, false, false, false)
                end
                SetEntityAnimCurrentTime(ped, pose[1], pose[2], 0.0)
                SetEntityAnimSpeed(ped, pose[1], pose[2], 0.0)
                held = pose
            end
            Wait(0)
        else
            if held then
                StopAnimTask(ped, held[1], held[2], 1.0)
                SetPedCanHeadIk(ped, true)
                held = nil
            end
            Wait(250)
        end
    end
end)

RegisterNUICallback("appearance_set_camera", function(camera, cb)
    cb(1)
    client.cancelOrbit()
    client.setCamera(camera)
end)

RegisterNUICallback("appearance_start_orbit", function(data, cb)
    cb(1)
    client.startOrbitCamera(data)
end)

RegisterNUICallback("appearance_update_orbit", function(data, cb)
    cb(1)
    client.updateOrbitData(data)
end)

RegisterNUICallback("appearance_exit_orbit", function(_, cb)
    cb(1)
    client.exitOrbitCamera()
end)

RegisterNUICallback("appearance_turn_around", function(_, cb)
    cb(1)
    client.pedTurn(cache.ped, 180.0)
end)

RegisterNUICallback("appearance_rotate_camera", function(direction, cb)
    cb(1)
    client.cancelOrbit()
    client.rotateCamera(direction)
end)

RegisterNUICallback("appearance_change_model", function(model, cb)
    local playerPed = client.setPlayerModel(model)

    -- Verify ped exists and model applied correctly
    local verifyAttempts = 0
    while (not DoesEntityExist(cache.ped) or GetEntityModel(cache.ped) == 0) and verifyAttempts < 10 do
        Wait(100)
        verifyAttempts = verifyAttempts + 1
    end

    SetEntityHeading(cache.ped, client.getHeading())
    SetEntityInvincible(playerPed, true)
    TaskStandStill(playerPed, -1)

    cb({
        appearanceSettings = client.getAppearanceSettings(),
        appearanceData = client.getPedAppearance(playerPed)
    })
end)

RegisterNUICallback("appearance_change_component", function(component, cb)
    client.setPedComponent(cache.ped, component)
    cb(client.getComponentSettings(cache.ped, component.component_id))
end)

RegisterNUICallback("appearance_change_prop", function(prop, cb)
    client.setPedProp(cache.ped, prop)
    cb(client.getPropSettings(cache.ped, prop.prop_id))
end)

-- ---- preloading (Settings › Preload) --------------------------------------------------------------------------------
-- The editor asks for one piece at a time: the game streams (and FiveM downloads) it through the ped's preload slot,
-- without the character ever wearing it, so the player can keep editing while it runs.

-- how many colours each listed drawable has, per slot: { { kind, ref, drawables = {..} }, .. } -> { {n, n, ..}, .. }
RegisterNUICallback("appearance_preload_counts", function(data, cb)
    local ped = cache.ped
    local out = {}
    for i, slot in ipairs(type(data) == "table" and data.slots or {}) do
        local counts = {}
        local ref = tonumber(slot.ref) or 0
        for j, drawable in ipairs(slot.drawables or {}) do
            local d = tonumber(drawable) or 0
            local n = slot.kind == "prop" and GetNumberOfPedPropTextureVariations(ped, ref, d)
                or GetNumberOfPedTextureVariations(ped, ref, d)
            counts[j] = math.max(1, n or 1)
        end
        out[i] = counts
    end
    cb(out)
end)

RegisterNUICallback("appearance_preload_item", function(data, cb)
    local ped = cache.ped
    local id, d, t = tonumber(data.id) or 0, tonumber(data.drawable) or 0, tonumber(data.texture) or 0
    local wait = math.min(math.max(tonumber(data.timeout) or 5000, 500), 15000)
    local start = GetGameTimer()
    local ok
    if data.kind == "prop" then
        SetPedPreloadPropData(ped, id, d, t)
        while not HasPedPreloadPropDataFinished(ped) and GetGameTimer() - start < wait do Wait(0) end
        ok = HasPedPreloadPropDataFinished(ped)
        ReleasePedPreloadPropData(ped)
    else
        SetPedPreloadVariationData(ped, id, d, t)
        while not HasPedPreloadVariationDataFinished(ped) and GetGameTimer() - start < wait do Wait(0) end
        ok = HasPedPreloadVariationDataFinished(ped)
        ReleasePedPreloadVariationData(ped)
    end
    cb({ ok = ok and true or false, ms = GetGameTimer() - start })
end)

RegisterNUICallback("appearance_change_head_blend", function(headBlend, cb)
    cb(1)
    client.setPedHeadBlend(cache.ped, headBlend)
end)

RegisterNUICallback("appearance_change_face_feature", function(faceFeatures, cb)
    cb(1)
    client.setPedFaceFeatures(cache.ped, faceFeatures)
end)

RegisterNUICallback("appearance_change_head_overlay", function(headOverlays, cb)
    cb(1)
    client.setPedHeadOverlays(cache.ped, headOverlays)
end)

RegisterNUICallback("appearance_change_hair", function(hair, cb)
    client.setPedHair(cache.ped, hair)
    cb(client.getHairSettings(cache.ped))
end)

-- Fade (ZONE_HAIR tattoo) — config.tattoos bağımsız, her shop'ta çalışır
-- setPedTattoos kullanılır (PED_TATTOOS güncellenir) — saç değişince fade korunur
RegisterNUICallback("appearance_change_fade", function(data, cb)
    cb(1)
    client.setPedTattoos(cache.ped, data)
end)

RegisterNUICallback("appearance_change_eye_color", function(eyeColor, cb)
    cb(1)
    client.setPedEyeColor(cache.ped, eyeColor)
end)

RegisterNUICallback("appearance_apply_tattoo", function(data, cb)
    local paid = not data.tattoo or not Config.ChargePerTattoo or lib.callback.await("illenium-appearance:server:payForTattoo", false, data.tattoo)
    if paid then
        -- setPedTattoos keeps PED_TATTOOS in step, so a hair change does not bring back an old set
        client.setPedTattoos(cache.ped, data.updatedTattoos or data)
    end
    cb(paid)
end)

RegisterNUICallback("appearance_preview_tattoo", function(previewTattoo, cb)
    cb(1)
    client.setPreviewTattoo(cache.ped, previewTattoo.data, previewTattoo.tattoo)
end)

-- the editor sends the whole set it shows (removing one, undo, reset, holding B)
RegisterNUICallback("appearance_delete_tattoo", function(data, cb)
    cb(1)
    client.setPedTattoos(cache.ped, data)
end)

RegisterNUICallback("appearance_wear_clothes", function(dataWearClothes, cb)
    cb(1)
    client.wearClothes(dataWearClothes.data, dataWearClothes.key)
end)

RegisterNUICallback("appearance_remove_clothes", function(clothes, cb)
    cb(1)
    client.removeClothes(clothes)
end)

RegisterNUICallback("appearance_save", function(appearance, cb)
    cb(1)
    stopStudioLight()
    stopEditorExtras()
    previewAnimationGeneration = previewAnimationGeneration + 1
    stopPreviewAnimation(cache.ped)
    cancelExternalEmote()
    ClearPedTasks(cache.ped)
    -- Validate appearance before saving
    if type(appearance) ~= "table" or not appearance.model or appearance.model == "" then
        print("[illenium-appearance] NUI sent invalid appearance data, getting current ped appearance")
        appearance = client.getPedAppearance(cache.ped)
        if not appearance.model or appearance.model == "" then
            appearance.model = "mp_m_freemode_01"
        end
    end
    -- Validate components exist
    if not appearance.components or #appearance.components == 0 then
        appearance.components = client.getPedComponents(cache.ped)
    end
    if not appearance.props or #appearance.props == 0 then
        appearance.props = client.getPedProps(cache.ped)
    end
    client.wearClothes(appearance, "head")
    client.wearClothes(appearance, "body")
    client.wearClothes(appearance, "bottom")
    client.exitPlayerCustomization(appearance)
end)

RegisterNUICallback("appearance_exit", function(_, cb)
    cb(1)
    stopStudioLight()
    stopEditorExtras()
    previewAnimationGeneration = previewAnimationGeneration + 1
    stopPreviewAnimation(cache.ped)
    cancelExternalEmote()
    ClearPedTasks(cache.ped)
    client.exitPlayerCustomization()
end)

-- A / D in the editor: turn the character a little; pedTurn would also flip the preset cameras to its back
RegisterNUICallback("rotate_left", function(_, cb)
    cb(1)
    SetEntityHeading(cache.ped, GetEntityHeading(cache.ped) + 10.0)
end)

RegisterNUICallback("rotate_right", function(_, cb)
    cb(1)
    SetEntityHeading(cache.ped, GetEntityHeading(cache.ped) - 10.0)
end)

RegisterNUICallback("get_theme_configuration", function(_, cb)
    cb(Config.Theme)
end)

RegisterNUICallback("appearance_toggle_light", function(data, cb)
    cb(1)
    spotlightActive = data and data.state and true or false
    if type(data) == "table" then
        for key, value in pairs(data) do
            if key ~= "state" then spotlightConfig[key] = value end
        end
    end

    if spotlightActive and not spotlightThreadRunning then
        spotlightThreadRunning = true
        Citizen.CreateThread(function()
            while spotlightActive do
                local ped = cache.ped or PlayerPedId()
                if ped and ped ~= 0 and DoesEntityExist(ped) then
                    local r = math.floor(tonumber(spotlightConfig.r) or 255)
                    local g = math.floor(tonumber(spotlightConfig.g) or 255)
                    local b = math.floor(tonumber(spotlightConfig.b) or 255)
                    local intensity = math.max(0.0, math.min(20.0, tonumber(spotlightConfig.intensity) or 9.0))
                    local distance = math.max(0.15, math.min(2.0, tonumber(spotlightConfig.distance) or 0.65))
                    local height = math.max(0.6, math.min(2.5, tonumber(spotlightConfig.height) or 1.3))
                    local angle = math.rad(tonumber(spotlightConfig.angle) or 0.0)

                    local pedCoords = GetEntityCoords(ped)
                    local forward = GetEntityForwardVector(ped)
                    local headBone = GetPedBoneIndex(ped, 31086)
                    local headCoords
                    if headBone and headBone ~= -1 then
                        headCoords = GetWorldPositionOfEntityBone(ped, headBone)
                    else
                        headCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 0.75)
                    end
                    local target = headCoords + (forward * 0.08)
                    local cosAngle = math.cos(angle)
                    local sinAngle = math.sin(angle)
                    local direction = vector3(
                        forward.x * cosAngle - forward.y * sinAngle,
                        forward.x * sinAngle + forward.y * cosAngle,
                        0.0
                    )
                    local lightPosition = target + (direction * distance) + vector3(0.0, 0.0, height)
                    local toPed = target - lightPosition
                    local length = #(toPed) + 0.0001
                    local nx, ny, nz = toPed.x / length, toPed.y / length, toPed.z / length

                    DrawSpotLight(
                        lightPosition.x, lightPosition.y, lightPosition.z,
                        nx, ny, nz,
                        r, g, b,
                        height + distance + 5.0,
                        intensity,
                        1.0,
                        35.0,
                        10.0
                    )
                    DrawSpotLightWithShadow(
                        lightPosition.x, lightPosition.y, lightPosition.z,
                        nx, ny, nz,
                        r, g, b,
                        height + distance + 5.0,
                        intensity,
                        1.0,
                        35.0,
                        10.0,
                        0
                    )
                    DrawLightWithRange(
                        pedCoords.x, pedCoords.y, pedCoords.z + 0.72,
                        r, g, b,
                        2.4,
                        math.max(0.6, intensity * 0.18)
                    )
                end
                Citizen.Wait(0)
            end
            spotlightThreadRunning = false
        end)
    end
end)

RegisterNUICallback("appearance_update_light", function(data, cb)
    cb(1)
    if type(data) ~= "table" then return end
    for key, value in pairs(data) do
        if key ~= "state" then spotlightConfig[key] = value end
    end
end)

RegisterNUICallback("appearance_play_animation", function(data, cb)
    previewAnimationGeneration = previewAnimationGeneration + 1
    local generation = previewAnimationGeneration
    cb(1)
    Citizen.CreateThread(function()
        local ped = cache.ped or PlayerPedId()
        if type(data) ~= "table" or data.dict == "reset" then
            stopPreviewAnimation(ped)
            cancelExternalEmote()
            return
        end

        if type(data.dict) ~= "string" or type(data.name) ~= "string" then return end

        cancelExternalEmote()
        stopPreviewAnimation(ped)
        RequestAnimDict(data.dict)
        local timeout = 0
        while not HasAnimDictLoaded(data.dict) and timeout < 50 and generation == previewAnimationGeneration do
            Wait(10)
            timeout = timeout + 1
        end
        if generation ~= previewAnimationGeneration or not HasAnimDictLoaded(data.dict) then return end

        local flag = math.floor(tonumber(data.flag) or 49)
        TaskPlayAnim(ped, data.dict, data.name, 3.5, -3.5, -1, flag, 0, false, false, false)
        activePreviewAnimation = {
            dict = data.dict,
            name = data.name
        }
    end)
end)

RegisterNUICallback("appearance_play_emote_command", function(data, cb)
    local command = type(data) == "table" and tostring(data.command or "") or ""
    command = command:lower():gsub("^%s+", ""):gsub("%s+$", "")
    command = command:gsub("^/?e%s+", "")

    if #command == 0 or #command > 48 or not command:match("^[%w_%-]+$") then
        cb({ success = false, reason = "invalid_command" })
        return
    end

    if GetResourceState(emoteResource) ~= "started" then
        cb({ success = false, reason = "emote_resource_unavailable" })
        return
    end

    local lookupOk, emoteData = pcall(function()
        return exports[emoteResource]:getEmoteData(command)
    end)
    if not lookupOk or not emoteData then
        cb({ success = false, reason = "animation_not_found" })
        return
    end

    local isSameActive = activeEmoteCommand == command
    if isSameActive then
        local playing = true
        local stateOk, state = pcall(function()
            return exports[emoteResource]:isEmotePlaying()
        end)
        if stateOk then playing = state and true or false end

        if playing then
            cancelExternalEmote()
            cb({ success = true, active = false, command = command })
            return
        end
    end

    previewAnimationGeneration = previewAnimationGeneration + 1
    stopPreviewAnimation(cache.ped)
    cancelExternalEmote()

    local ok, result = pcall(function()
        return exports[emoteResource]:playEmote(command)
    end)
    if not ok or result == false then
        cb({ success = false, reason = "animation_not_found", cleared = true })
        return
    end

    activeEmoteCommand = command
    cb({ success = true, active = true, command = command })
end)

local function wardrobeResponse(result)
    if type(result) ~= "table" then
        return { success = false, reason = "server_error" }
    end
    return result
end

RegisterNUICallback("appearance_get_outfits", function(_, cb)
    cb(lib.callback.await("illenium-appearance:server:getOutfits", false) or {})
end)

RegisterNUICallback("appearance_save_outfit", function(data, cb)
    local model = client.getPedModel(cache.ped)
    local components = client.getPedComponents(cache.ped)
    local props = client.getPedProps(cache.ped)
    cb(wardrobeResponse(lib.callback.await(
        "illenium-appearance:server:wardrobeSave",
        false,
        data and data.name,
        model,
        components,
        props
    )))
end)

RegisterNUICallback("appearance_update_outfit", function(data, cb)
    local model = client.getPedModel(cache.ped)
    local components = client.getPedComponents(cache.ped)
    local props = client.getPedProps(cache.ped)
    cb(wardrobeResponse(lib.callback.await(
        "illenium-appearance:server:wardrobeUpdate",
        false,
        data and data.id,
        model,
        components,
        props
    )))
end)

RegisterNUICallback("appearance_delete_outfit", function(data, cb)
    cb(wardrobeResponse(lib.callback.await(
        "illenium-appearance:server:wardrobeDelete",
        false,
        data and data.id
    )))
end)

RegisterNUICallback("appearance_generate_outfit_code", function(data, cb)
    local result = wardrobeResponse(lib.callback.await(
        "illenium-appearance:server:wardrobeGenerateCode",
        false,
        data and data.id
    ))
    if result.success and result.code then
        lib.setClipboard(result.code)
    end
    cb(result)
end)

RegisterNUICallback("appearance_import_outfit_code", function(data, cb)
    cb(wardrobeResponse(lib.callback.await(
        "illenium-appearance:server:wardrobeImportCode",
        false,
        data and data.name,
        data and data.code
    )))
end)

local function isValidPreviewOutfit(outfit, expectedID)
    if type(outfit) ~= "table"
        or type(outfit.model) ~= "string"
        or outfit.model == ""
        or #outfit.model > 64
        or type(outfit.components) ~= "table"
        or type(outfit.props) ~= "table"
    then
        return false
    end

    if expectedID and tonumber(outfit.id) ~= expectedID then return false end

    for i = 1, #outfit.components do
        local component = outfit.components[i]
        if type(component) ~= "table"
            or tonumber(component.component_id) == nil
            or tonumber(component.drawable) == nil
            or tonumber(component.texture) == nil
        then
            return false
        end
    end

    for i = 1, #outfit.props do
        local prop = outfit.props[i]
        if type(prop) ~= "table"
            or tonumber(prop.prop_id) == nil
            or tonumber(prop.drawable) == nil
            or tonumber(prop.texture) == nil
        then
            return false
        end
    end

    return true
end

RegisterNUICallback("appearance_wear_outfit", function(data, cb)
    local outfitID = data and tonumber(data.id)
    local selected = data and data.outfit
    local outfits

    if not isValidPreviewOutfit(selected, outfitID) then
        selected = nil
        outfits = lib.callback.await("illenium-appearance:server:getOutfits", false) or {}
        for i = 1, #outfits do
            if tonumber(outfits[i].id) == outfitID then
                selected = outfits[i]
                break
            end
        end
    end

    if not selected then
        cb({ success = false, reason = "not_found" })
        return
    end

    local currentModel = client.getPedModel(cache.ped)
    if currentModel ~= selected.model then
        local baseAppearance = lib.callback.await(
            "illenium-appearance:server:getAppearance",
            false,
            selected.model
        )

        if baseAppearance then
            client.setPlayerAppearance(baseAppearance)
        else
            client.setPlayerModel(selected.model)
            SetPedDefaultComponentVariation(cache.ped)
        end
        Wait(100)
    end

    client.setPedComponents(cache.ped, selected.components)
    client.setPedProps(cache.ped, selected.props)
    SetEntityHeading(cache.ped, client.getHeading())
    pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, true)
    TaskStandStill(cache.ped, -1)

    cb({
        success = true,
        outfits = outfits,
        appearanceData = client.getPedAppearance(cache.ped),
        appearanceSettings = client.getAppearanceSettings()
    })
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        stopStudioLight()
        stopEditorExtras()
        previewAnimationGeneration = previewAnimationGeneration + 1
        stopPreviewAnimation(cache.ped)
        cancelExternalEmote()
    end
end)
