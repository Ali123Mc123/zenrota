local reverseCamera

local function getRgbColors()
    local colors = {
        hair = {},
        makeUp = {}
    }

    for i = 0, GetNumHairColors() - 1 do
        colors.hair[i + 1] = { GetPedHairRgbColor(i) }
    end

    for i = 0, GetNumMakeupColors() - 1 do
        colors.makeUp[i + 1] = { GetPedMakeupRgbColor(i) }
    end

    return colors
end

local playerAppearance

local function getAppearance()
    if not playerAppearance then
        playerAppearance = client.getPedAppearance(cache.ped)
    end

    return playerAppearance
end
client.getAppearance = getAppearance

local function addToBlacklist(item, drawable, drawableId, blacklistSettings)
    if drawable == drawableId and item.textures then
        for i = 1, #item.textures do
            blacklistSettings.textures[#blacklistSettings.textures + 1] = item.textures[i]
        end
    end
    if not item.textures or #item.textures == 0 then
        blacklistSettings.drawables[#blacklistSettings.drawables + 1] = drawable
    end
end

local function listContains(items, item)
    for i = 1, #items do
        if items[i] == item then
            return true
        end
    end
    return false
end

local function listContainsAny(items, containedItems)
    for i = 1, #items do
        if listContains(containedItems, items[i]) then
            return true
        end
    end
    return false
end

local function allowedForPlayer(item, allowedAces)
    return (item.jobs and listContains(item.jobs, client.job.name)) or
        (item.gangs and listContains(item.gangs, client.gang.name)) or
        (item.aces and listContainsAny(item.aces, allowedAces) or (item.citizenids and listContains(item.citizenids, client.citizenid)))
end

-- GetPlayerAces was awaited inside every per-category filter, which produced
-- ~170 blocking round-trips per second while the menu was open. The server
-- already caches the result for 300s (server/permissions.lua), so a short
-- client-side memo collapses the storm without changing semantics.
local acesCache, acesCacheAt = nil, 0
local ACES_TTL_MS = 60000

local function getAllowedAces()
    local now = GetGameTimer()
    if acesCache and (now - acesCacheAt) < ACES_TTL_MS then
        return acesCache
    end
    acesCache = lib.callback.await("illenium-appearance:server:GetPlayerAces", false) or {}
    acesCacheAt = now
    return acesCache
end

local function filterPedModelsForPlayer(pedConfigs)
    local playerPeds = {}
    local allowedAces = getAllowedAces()

    for i = 1, #pedConfigs do
        local config = pedConfigs[i]
        if (not config.jobs and not config.gangs and not config.aces and not config.citizenids) or allowedForPlayer(config, allowedAces) then
            for j = 1, #config.peds do
                playerPeds[#playerPeds + 1] = config.peds[j]
            end
        end
    end
    return playerPeds
end

local function filterTattoosByGender(tattoos)
    local filtered = {}
    local gender = client.getPedDecorationType()
    for k, v in pairs(tattoos) do
        filtered[k] = {}
        for i = 1, #v do
            local tattoo = v[i]
            if tattoo["hash" .. gender:gsub("^%l", string.upper)] ~= "" then
                filtered[k][#filtered[k] + 1] = tattoo
            end
        end
    end
    return filtered
end

local function filterBlacklistSettings(items, drawableId)
    local blacklistSettings = {
        drawables = {},
        textures = {}
    }

    local allowedAces = getAllowedAces()

    for i = 1, #items do
        local item = items[i]
        if not allowedForPlayer(item, allowedAces) and item.drawables then
            for j = 0, #item.drawables do
                addToBlacklist(item, item.drawables[j], drawableId, blacklistSettings)
            end
        end
    end

    return blacklistSettings
end

local function componentBlacklistMap(gender, componentId)
    local genderSettings = Config.Blacklist[gender].components
    if componentId == 1 then
        return genderSettings.masks
    elseif componentId == 3 then
        return genderSettings.upperBody
    elseif componentId == 4 then
        return genderSettings.lowerBody
    elseif componentId == 5 then
        return genderSettings.bags
    elseif componentId == 6 then
        return genderSettings.shoes
    elseif componentId == 7 then
        return genderSettings.scarfAndChains
    elseif componentId == 8 then
        return genderSettings.shirts
    elseif componentId == 9 then
        return genderSettings.bodyArmor
    elseif componentId == 10 then
        return genderSettings.decals
    elseif componentId == 11 then
        return genderSettings.jackets
    end

    return {}
end

local function propBlacklistMap(gender, propId)
    local genderSettings = Config.Blacklist[gender].props

    if propId == 0 then
        return genderSettings.hats
    elseif propId == 1 then
        return genderSettings.glasses
    elseif propId == 2 then
        return genderSettings.ear
    elseif propId == 6 then
        return genderSettings.watches
    elseif propId == 7 then
        return genderSettings.bracelets
    end

    return {}
end

local function getComponentSettings(ped, componentId)
    local drawableId = GetPedDrawableVariation(ped, componentId)
    local gender = client.getPedDecorationType()

    local blacklistSettings = {
        drawables = {},
        textures = {}
    }

    if client.isPedFreemodeModel(ped) then
        blacklistSettings = filterBlacklistSettings(componentBlacklistMap(gender, componentId), drawableId)
    end

    return {
        component_id = componentId,
        drawable = {
            min = 0,
            max = GetNumberOfPedDrawableVariations(ped, componentId) - 1
        },
        texture = {
            min = 0,
            max = GetNumberOfPedTextureVariations(ped, componentId, drawableId) - 1
        },
        blacklist = blacklistSettings
    }
end
client.getComponentSettings = getComponentSettings

local function getPropSettings(ped, propId)
    local drawableId = GetPedPropIndex(ped, propId)
    local gender = client.getPedDecorationType()

    local blacklistSettings = {
        drawables = {},
        textures = {}
    }

    if client.isPedFreemodeModel(ped) then
        blacklistSettings = filterBlacklistSettings(propBlacklistMap(gender, propId), drawableId)
    end

    local settings = {
        prop_id = propId,
        drawable = {
            min = -1,
            max = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
        },
        texture = {
            min = -1,
            max = GetNumberOfPedPropTextureVariations(ped, propId, drawableId) - 1
        },
        blacklist = blacklistSettings
    }
    return settings
end
client.getPropSettings = getPropSettings

local function getHairSettings(ped)
    local colors = getRgbColors()
    local gender = client.getPedDecorationType()
    local blacklistSettings = {
        drawables = {},
        textures = {}
    }

    if client.isPedFreemodeModel(ped) then
        blacklistSettings = filterBlacklistSettings(Config.Blacklist[gender].hair, GetPedDrawableVariation(ped, 2))
    end

    local settings = {
        style = {
            min = 0,
            max = GetNumberOfPedDrawableVariations(ped, 2) - 1
        },
        color = {
            items = colors.hair
        },
        highlight = {
            items = colors.hair
        },
        texture = {
            min = 0,
            max = GetNumberOfPedTextureVariations(ped, 2, GetPedDrawableVariation(ped, 2)) - 1
        },
        blacklist = blacklistSettings
    }

    return settings
end
client.getHairSettings = getHairSettings

local function getAppearanceSettings()
    local ped = {
        model = {
            items = filterPedModelsForPlayer(Config.Peds.pedConfig)
        }
    }

    local tattoos = {
        items = filterTattoosByGender(Config.Tattoos),
        opacity = {
            min = 0.1,
            max = 1,
            factor = 0.1,
        }
    }

    local components = {}
    for i = 1, #constants.PED_COMPONENTS_IDS do
        components[i] = getComponentSettings(cache.ped, constants.PED_COMPONENTS_IDS[i])
    end

    local props = {}
    for i = 1, #constants.PED_PROPS_IDS do
        props[i] = getPropSettings(cache.ped, constants.PED_PROPS_IDS[i])
    end

    -- every head the game has (GTA's 46 parents, 0-45, then the added faces), counted on the ped itself; the photo
    -- studio's empty head is one of them and is no face, so the editor leaves its number out (studioHead)
    local heads, studioHead = 46 + 52, -1
    if client.isPedFreemodeModel(cache.ped) then
        heads = GetNumberOfPedDrawableVariations(cache.ped, 0)
        local name = GetEntityModel(cache.ped) == `mp_f_freemode_01` and "mp_f_illenium_studio" or "mp_m_illenium_studio"
        studioHead = GetPedDrawableGlobalIndexFromCollection(cache.ped, 0, name, 0)
    end
    local headBlend = {
        shapeFirst = {
            min = 0,
            max = heads - 1
        },
        shapeSecond = {
            min = 0,
            max = heads - 1
        },
        shapeThird = {
            min = 0,
            max = heads - 1
        },
        skinFirst = {
            min = 0,
            max = 45
        },
        skinSecond = {
            min = 0,
            max = 45
        },
        skinThird = {
            min = 0,
            max = 45
        },
        shapeMix = {
            min = 0,
            max = 1,
            factor = 0.1,
        },
        skinMix = {
            min = 0,
            max = 1,
            factor = 0.1,
        },
        thirdMix = {
            min = 0,
            max = 1,
            factor = 0.1,
        }
    }

    local size = #constants.FACE_FEATURES
    local faceFeatures = table.create(0, size)
    for i = 1, size do
        local feature = constants.FACE_FEATURES[i]
        faceFeatures[feature] = { min = -1, max = 1, factor = 0.1 }
    end

    local colors = getRgbColors()

    local colorMap = {
        beard = colors.hair,
        eyebrows = colors.hair,
        chestHair = colors.hair,
        makeUp = colors.makeUp,
        blush = colors.makeUp,
        lipstick = colors.makeUp,
    }

    size = #constants.HEAD_OVERLAYS
    local headOverlays = table.create(0, size)

    for i = 1, size do
        local overlay = constants.HEAD_OVERLAYS[i]
        local settings = {
            style = {
                min = 0,
                max = GetPedHeadOverlayNum(i - 1) - 1
            },
            opacity = {
                min = 0,
                max = 1,
                factor = 0.1,
            }
        }

        if colorMap[overlay] then
            settings.color = {
                items = colorMap[overlay]
            }
        end

        headOverlays[overlay] = settings
    end

    local eyeColor = {
        min = 0,
        max = 30
    }

    return {
        ped = ped,
        components = components,
        props = props,
        headBlend = headBlend,
        studioHead = studioHead,
        faceFeatures = faceFeatures,
        headOverlays = headOverlays,
        hair = getHairSettings(cache.ped),
        eyeColor = eyeColor,
        tattoos = tattoos
    }
end
client.getAppearanceSettings = getAppearanceSettings

local config
function client.getConfig() return config end

local function getCustomizationFov()
    if config and config.cameraFov then
        return config.cameraFov
    end

    if config
        and config.components
        and not config.headOverlays
        and not config.headBlend
        and not config.tattoos
        and not config.ped then
        return 25.0
    end
    return 49.0
end

local function getCameraDistanceScale()
    local fov = getCustomizationFov()
    return math.tan(math.rad(49.0 * 0.5)) / math.tan(math.rad(fov * 0.5))
end

local isCameraInterpolating
local currentCamera
local cameraHandle
local camGeneration = 0
local isOrbitActive = false

local orbit = {
    angleH = 0.0,
    angleV = 0.0,
    distance = 2.2,
    focusZ = 0.2,
    targetAngleH = 0.0,
    targetAngleV = 0.0,
    targetDistance = 2.2,
    targetFocusZ = 0.2
}

local ORBIT_BONES = {
    31086, -- SKEL_Head
    24818, -- SKEL_Spine3
    58271, -- SKEL_L_Thigh
    14201  -- SKEL_L_Foot
}

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function resetOrbitState()
    orbit.angleH = 0.0
    orbit.angleV = 0.0
    orbit.distance = 2.2
    orbit.focusZ = 0.2
    orbit.targetAngleH = 0.0
    orbit.targetAngleV = 0.0
    orbit.targetDistance = 2.2
    orbit.targetFocusZ = 0.2
end

local function cancelOrbit()
    camGeneration = camGeneration + 1
    isCameraInterpolating = false
    isOrbitActive = false
    resetOrbitState()
end
client.cancelOrbit = cancelOrbit

local function setCamera(key)
    if key == "current" and not currentCamera then return end
    if not isCameraInterpolating then
        if key ~= "current" then
            currentCamera = key
        end

        local coords, point = table.unpack(constants.CAMERAS[currentCamera])
        local reverseFactor = reverseCamera and -1 or 1
        local distanceScale = getCameraDistanceScale()

        if cameraHandle then
            local camCoords = GetOffsetFromEntityInWorldCoords(cache.ped, coords.x * reverseFactor,
                coords.y * distanceScale * reverseFactor, coords.z * reverseFactor)
            local camPoint = GetOffsetFromEntityInWorldCoords(cache.ped, point.x, point.y, point.z)
            local tmpCamera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z,
                0.0, 0.0, 0.0, getCustomizationFov(), false, 0)
            pcall(function() exports['FeloxAC']:createCam(tmpCamera) end) --[[FeloxAC:auto]]

            PointCamAtCoord(tmpCamera, camPoint.x, camPoint.y, camPoint.z)
            SetCamActiveWithInterp(tmpCamera, cameraHandle, 1000, 1, 1)

            isCameraInterpolating = true
            local generation = camGeneration
            local oldHandle = cameraHandle
            cameraHandle = tmpCamera

            CreateThread(function()
                repeat
                    Wait(100)
                until generation ~= camGeneration or (not IsCamInterpolating(tmpCamera) and IsCamActive(tmpCamera))

                if oldHandle and DoesCamExist(oldHandle) then
                    pcall(function() exports['FeloxAC']:destroyCam(oldHandle) end) --[[FeloxAC:auto]]
                    DestroyCam(oldHandle, false)
                end

                if generation == camGeneration then
                    isCameraInterpolating = false
                end
            end)
        else
            local camCoords = GetOffsetFromEntityInWorldCoords(cache.ped, coords.x, coords.y * distanceScale, coords.z)
            local camPoint = GetOffsetFromEntityInWorldCoords(cache.ped, point.x, point.y, point.z)
            cameraHandle = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z, 0.0,
                0.0, 0.0, getCustomizationFov(), false, 0)
            pcall(function() exports['FeloxAC']:createCam(cameraHandle) end) --[[FeloxAC:auto]]

            PointCamAtCoord(cameraHandle, camPoint.x, camPoint.y, camPoint.z)
            SetCamActive(cameraHandle, true)
        end
    end
end
client.setCamera = setCamera

local function getClosestBoneFocusZ(cursorY)
    local ped = cache.ped
    if not ped or not DoesEntityExist(ped) then return 0.2 end

    local pedCoords = GetEntityCoords(ped)
    local bestDistance = math.huge
    local bestFocusZ = 0.2

    for i = 1, #ORBIT_BONES do
        local boneCoords = GetPedBoneCoords(ped, ORBIT_BONES[i], 0.0, 0.0, 0.0)
        local onScreen, _, screenY = World3dToScreen2d(boneCoords.x, boneCoords.y, boneCoords.z)
        if onScreen then
            local distance = math.abs(screenY - cursorY)
            if distance < bestDistance then
                bestDistance = distance
                bestFocusZ = boneCoords.z - pedCoords.z
            end
        end
    end

    return bestFocusZ
end

local function getOrbitCoordinates(angleH, angleV, distance, focusZ)
    local ped = cache.ped
    distance = distance * getCameraDistanceScale()
    local horizontal = math.rad(angleH)
    local vertical = math.rad(angleV)
    local cosVertical = math.cos(vertical)
    local offsetX = distance * cosVertical * math.sin(horizontal)
    local offsetY = distance * cosVertical * math.cos(horizontal)
    local offsetZ = distance * math.sin(vertical)
    local pedCoords = GetEntityCoords(ped)
    local heading = math.rad(GetEntityHeading(ped))
    local rotatedX = offsetX * math.cos(heading) - offsetY * math.sin(heading)
    local rotatedY = offsetX * math.sin(heading) + offsetY * math.cos(heading)

    return pedCoords.x + rotatedX,
        pedCoords.y + rotatedY,
        pedCoords.z + offsetZ + focusZ,
        pedCoords.x,
        pedCoords.y,
        pedCoords.z + focusZ
end

local function startOrbitCamera(data)
    data = data or {}
    local focusZ = getClosestBoneFocusZ(tonumber(data.cursorY) or 0.5)

    if isOrbitActive then
        orbit.targetFocusZ = focusZ
        return
    end

    camGeneration = camGeneration + 1
    local generation = camGeneration
    isCameraInterpolating = false
    isOrbitActive = true
    orbit.focusZ = focusZ
    orbit.targetFocusZ = focusZ
    -- start where the preset camera already is, so zooming from the face camera does not jump out first
    if tonumber(data.distance) then
        orbit.distance = clamp(tonumber(data.distance), 0.5, 4.0)
        orbit.targetDistance = orbit.distance
    end
    if tonumber(data.angleV) then
        orbit.angleV = clamp(tonumber(data.angleV), -10.0, 50.0)
        orbit.targetAngleV = orbit.angleV
    end

    local x, y, z, lookX, lookY, lookZ = getOrbitCoordinates(
        orbit.angleH,
        orbit.angleV,
        orbit.distance,
        orbit.focusZ
    )
    local orbitCamera = CreateCameraWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        x, y, z,
        0.0, 0.0, 0.0,
        getCustomizationFov(),
        false,
        0
    )
    pcall(function() exports['FeloxAC']:createCam(orbitCamera) end) --[[FeloxAC:auto]]
    PointCamAtCoord(orbitCamera, lookX, lookY, lookZ)

    if cameraHandle and DoesCamExist(cameraHandle) then
        local oldHandle = cameraHandle
        cameraHandle = orbitCamera
        SetCamActiveWithInterp(orbitCamera, oldHandle, 500, 1, 1)
        CreateThread(function()
            Wait(550)
            if oldHandle and DoesCamExist(oldHandle) then
                pcall(function() exports['FeloxAC']:destroyCam(oldHandle) end) --[[FeloxAC:auto]]
                DestroyCam(oldHandle, false)
            end
        end)
    else
        cameraHandle = orbitCamera
        SetCamActive(orbitCamera, true)
    end

    CreateThread(function()
        while isOrbitActive and generation == camGeneration do
            Wait(0)
            orbit.angleH = orbit.angleH + (orbit.targetAngleH - orbit.angleH) * 0.15
            orbit.angleV = orbit.angleV + (orbit.targetAngleV - orbit.angleV) * 0.15
            orbit.distance = orbit.distance + (orbit.targetDistance - orbit.distance) * 0.15
            orbit.focusZ = orbit.focusZ + (orbit.targetFocusZ - orbit.focusZ) * 0.08

            if cameraHandle and DoesCamExist(cameraHandle) then
                local camX, camY, camZ, targetX, targetY, targetZ = getOrbitCoordinates(
                    orbit.angleH,
                    orbit.angleV,
                    orbit.distance,
                    orbit.focusZ
                )
                SetCamCoord(cameraHandle, camX, camY, camZ)
                PointCamAtCoord(cameraHandle, targetX, targetY, targetZ)
            end

            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
        end
    end)
end
client.startOrbitCamera = startOrbitCamera

local function updateOrbitData(data)
    if not isOrbitActive or type(data) ~= "table" then return end

    if data.angleH ~= nil then
        orbit.targetAngleH = tonumber(data.angleH) or orbit.targetAngleH
    end
    if data.angleV ~= nil then
        orbit.targetAngleV = clamp(tonumber(data.angleV) or orbit.targetAngleV, -10.0, 50.0)
    end
    if data.distance ~= nil then
        orbit.targetDistance = clamp(tonumber(data.distance) or orbit.targetDistance, 0.5, 4.0)
    end
    if data.updateFocus and data.cursorY ~= nil then
        orbit.targetFocusZ = getClosestBoneFocusZ(tonumber(data.cursorY) or 0.5)
    end
end
client.updateOrbitData = updateOrbitData

local function exitOrbitCamera()
    cancelOrbit()
    setCamera("current")
end
client.exitOrbitCamera = exitOrbitCamera

function client.rotateCamera(direction)
    if not isCameraInterpolating then
        local coords, point = table.unpack(constants.CAMERAS[currentCamera])
        local offset = constants.OFFSETS[currentCamera]
        local sideFactor = direction == "left" and 1 or -1
        local reverseFactor = reverseCamera and -1 or 1
        local distanceScale = getCameraDistanceScale()

        local camCoords = GetOffsetFromEntityInWorldCoords(
            cache.ped,
            (coords.x + offset.x) * distanceScale * sideFactor * reverseFactor,
            (coords.y + offset.y) * distanceScale * reverseFactor,
            coords.z
        )

        local camPoint = GetOffsetFromEntityInWorldCoords(cache.ped, point.x, point.y, point.z)
        local tmpCamera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z, 0.0,
            0.0, 0.0, getCustomizationFov(), false, 0)
        pcall(function() exports['FeloxAC']:createCam(tmpCamera) end) --[[FeloxAC:auto]]

        PointCamAtCoord(tmpCamera, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(tmpCamera, cameraHandle, 1000, 1, 1)

        isCameraInterpolating = true
        local generation = camGeneration
        local oldHandle = cameraHandle
        cameraHandle = tmpCamera

        CreateThread(function()
            repeat
                Wait(100)
            until generation ~= camGeneration or (not IsCamInterpolating(tmpCamera) and IsCamActive(tmpCamera))

            if oldHandle and DoesCamExist(oldHandle) then
                pcall(function() exports['FeloxAC']:destroyCam(oldHandle) end) --[[FeloxAC:auto]]
                DestroyCam(oldHandle, false)
            end

            if generation == camGeneration then
                isCameraInterpolating = false
            end
        end)
    end
end

local playerCoords
-- turns the character at once: walking round would break the still pose the editor holds it in (game/nui.lua)
local function pedTurn(ped, angle)
    reverseCamera = not reverseCamera
    SetEntityHeading(ped, GetEntityHeading(ped) - angle)
end
client.pedTurn = pedTurn

local function wearClothes(data, typeClothes)
    local dataClothes = constants.DATA_CLOTHES[typeClothes]
    local animationsOn = dataClothes.animations.on
    local components = dataClothes.components[client.getPedDecorationType()]
    local appliedComponents = data.components
    local props = dataClothes.props[client.getPedDecorationType()]
    local appliedProps = data.props

    lib.requestAnimDict(animationsOn.dict, 10000)

    for i = 1, #components do
        local componentId = components[i][1]
        for j = 1, #appliedComponents do
            local applied = appliedComponents[j]
            if applied.component_id == componentId then
                SetPedComponentVariation(cache.ped, componentId, applied.drawable, applied.texture, 2)
            end
        end
    end

    for i = 1, #props do
        local propId = props[i][1]
        for j = 1, #appliedProps do
            local applied = appliedProps[j]
            if applied.prop_id == propId then
                SetPedPropIndex(cache.ped, propId, applied.drawable, applied.texture, true)
            end
        end
    end

    TaskPlayAnim(cache.ped, animationsOn.dict, animationsOn.anim, 3.0, 3.0, animationsOn.duration, animationsOn.move, 0,
        false, false, false)
end
client.wearClothes = wearClothes

local function removeClothes(typeClothes)
    local dataClothes = constants.DATA_CLOTHES[typeClothes]
    local animationsOff = dataClothes.animations.off
    local components = dataClothes.components[client.getPedDecorationType()]
    local props = dataClothes.props[client.getPedDecorationType()]

    lib.requestAnimDict(animationsOff.dict, 10000)

    for i = 1, #components do
        local component = components[i]
        SetPedComponentVariation(cache.ped, component[1], component[2], 0, 2)
    end

    for i = 1, #props do
        ClearPedProp(cache.ped, props[i][1])
    end

    TaskPlayAnim(cache.ped, animationsOff.dict, animationsOff.anim, 3.0, 3.0, animationsOff.duration, animationsOff.move,
        0, false, false, false)
end
client.removeClothes = removeClothes

local playerHeading
function client.getHeading() return playerHeading end

local callback
function client.isCustomizing() return callback ~= nil end

function client.startPlayerCustomization(cb, conf)
    repeat Wait(0) until IsScreenFadedIn() and not IsPlayerTeleportActive() and not IsPlayerSwitchInProgress()

    playerAppearance = client.getPedAppearance(cache.ped)
    playerCoords = GetEntityCoords(cache.ped, true)
    playerHeading = GetEntityHeading(cache.ped)

    BackupPlayerStats()
    -- the game's parent portraits, shown by the editor through nui-img
    RequestStreamedTextureDict("char_creator_portraits", false)

    callback = cb
    config = conf
    reverseCamera = false
    isCameraInterpolating = false

    setCamera("default")
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    RenderScriptCams(true, false, 0, true, true)
    pcall(function() exports['FeloxAC']:isInvincible(Config.InvincibleDuringCustomization) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, Config.InvincibleDuringCustomization)
    SetPedCanPlayAmbientAnims(cache.ped, false)
    SetPedCanPlayAmbientBaseAnims(cache.ped, false)
    TaskStandStill(cache.ped, -1)

    if Config.HideRadar then DisplayRadar(false) end

    SendNuiMessage(json.encode({
        type = "appearance_display",
        payload = {
            asynchronous = Config.AsynchronousLoading
        }
    }))
end

function client.exitPlayerCustomization(appearance)
    cancelOrbit()
    RenderScriptCams(false, false, 0, true, true)
    if cameraHandle and DoesCamExist(cameraHandle) then
        pcall(function() exports['FeloxAC']:destroyCam(cameraHandle) end) --[[FeloxAC:auto]]
        DestroyCam(cameraHandle, false)
    end
    SetNuiFocus(false, false)
    SetStreamedTextureDictAsNoLongerNeeded("char_creator_portraits")

    if Config.HideRadar then DisplayRadar(true) end

    SetPedCanPlayAmbientAnims(cache.ped, true)
    SetPedCanPlayAmbientBaseAnims(cache.ped, true)
    ClearPedTasksImmediately(cache.ped)
    pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
    SetEntityInvincible(cache.ped, false)

    SendNuiMessage(json.encode({
        type = "appearance_hide",
        payload = {}
    }))

    if not appearance then
        local backup = getAppearance()
        -- Validate backup appearance is valid before restoring
        if backup and backup.model and backup.model ~= "" then
            client.setPlayerAppearance(backup)
        else
            -- Backup is invalid (possibly from broken initial state)
            -- At minimum ensure player has a visible freemode model
            print("[illenium-appearance] Invalid backup appearance during cancel, ensuring visible ped")
            local currentModel = GetEntityModel(cache.ped)
            if currentModel ~= `mp_m_freemode_01` and currentModel ~= `mp_f_freemode_01` then
                client.setPlayerModel("mp_m_freemode_01")
                SetPedDefaultComponentVariation(cache.ped)
            end
        end
    else
        client.setPedTattoos(cache.ped, appearance.tattoos)
    end

    RestorePlayerStats()

    if callback then
        callback(appearance)
    end

    callback = nil
    config = nil
    playerAppearance = nil
    playerCoords = nil
    cameraHandle = nil
    currentCamera = nil
    reverseCamera = nil
    isCameraInterpolating = nil
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        cancelOrbit()
        if cameraHandle and DoesCamExist(cameraHandle) then
            pcall(function() exports['FeloxAC']:destroyCam(cameraHandle) end) --[[FeloxAC:auto]]
            DestroyCam(cameraHandle, false)
        end
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end)

exports("startPlayerCustomization", client.startPlayerCustomization)
