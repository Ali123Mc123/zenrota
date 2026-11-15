local hashesComputed = false
local PED_TATTOOS = {}
local pedModelsByHash = {}
local rcoreFadeGeneration = 0

local function tofloat(num)
    return num + 0.0
end

local function isPedFreemodeModel(ped)
    local model = GetEntityModel(ped)
    return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

local function computePedModelsByHash()
    for i = 1, #Config.Peds.pedConfig do
        local peds = Config.Peds.pedConfig[i].peds
        for j = 1, #peds do
            pedModelsByHash[joaat(peds[j])] = peds[j]
        end
    end
end

---@param ped number entity id
---@return string
--- Get the model name from an entity's model hash
local function getPedModel(ped)
    if not hashesComputed then
        computePedModelsByHash()
        hashesComputed = true
    end
    return pedModelsByHash[GetEntityModel(ped)]
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedComponents(ped)
    local size = #constants.PED_COMPONENTS_IDS
    local components = table.create(size, 0)

    for i = 1, size do
        local componentId = constants.PED_COMPONENTS_IDS[i]
        components[i] = {
            component_id = componentId,
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
        }
    end

    return components
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedProps(ped)
    local size = #constants.PED_PROPS_IDS
    local props = table.create(size, 0)

    for i = 1, size do
        local propId = constants.PED_PROPS_IDS[i]
        props[i] = {
            prop_id = propId,
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end
    return props
end

local function round(number, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", number))
end

---@param ped number entity id
---@return table <number, number>
---```
---{ shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix }
---```
local function getPedHeadBlend(ped)
    -- GET_PED_HEAD_BLEND_DATA
    local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))

    shapeMix = tonumber(string.sub(shapeMix, 0, 4))
    if shapeMix > 1 then shapeMix = 1 end

    skinMix = tonumber(string.sub(skinMix, 0, 4))
    if skinMix > 1 then skinMix = 1 end

    if not thirdMix then
        thirdMix = 0
    end
    thirdMix = tonumber(string.sub(thirdMix, 0, 4))
    if thirdMix > 1 then thirdMix = 1 end


    return {
        shapeFirst = shapeFirst,
        shapeSecond = shapeSecond,
        shapeThird = shapeThird,
        skinFirst = skinFirst,
        skinSecond = skinSecond,
        skinThird = skinThird,
        shapeMix = shapeMix,
        skinMix = skinMix,
        thirdMix = thirdMix
    }
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedFaceFeatures(ped)
    local size = #constants.FACE_FEATURES
    local faceFeatures = table.create(0, size)

    for i = 1, size do
        local feature = constants.FACE_FEATURES[i]
        faceFeatures[feature] = round(GetPedFaceFeature(ped, i-1), 1)
    end

    return faceFeatures
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedHeadOverlays(ped)
    local size = #constants.HEAD_OVERLAYS
    local headOverlays = table.create(0, size)

    for i = 1, size do
        local overlay = constants.HEAD_OVERLAYS[i]
        local _, value, _, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, i - 1)

        if value ~= 255 then
            opacity = round(opacity, 1)
        else
            value = 0
            opacity = 0
        end

        headOverlays[overlay] = {
            style = value,
            opacity = opacity,
            color = firstColor,
            secondColor = secondColor
        }
    end

    return headOverlays
end

---@param ped number entity id
---@return table<string, number>
local function getPedHair(ped)
    return {
        style = GetPedDrawableVariation(ped, 2),
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped),
        texture = GetPedTextureVariation(ped, 2)
    }
end

local function getPedDecorationType()
    local pedModel = GetEntityModel(cache.ped)
    local decorationType

    if pedModel == `mp_m_freemode_01` then
        decorationType = "male"
    elseif pedModel == `mp_f_freemode_01` then
        decorationType = "female"
    else
        decorationType = IsPedMale(cache.ped) and "male" or "female"
    end

    return decorationType
end

local function getPedAppearance(ped)
    local eyeColor = GetPedEyeColor(ped)

    return {
        model = getPedModel(ped) or "mp_m_freemode_01",
        headBlend = getPedHeadBlend(ped),
        faceFeatures = getPedFaceFeatures(ped),
        headOverlays = getPedHeadOverlays(ped),
        components = getPedComponents(ped),
        props = getPedProps(ped),
        hair = getPedHair(ped),
        tattoos = client.getPedTattoos(),
        eyeColor = eyeColor < #constants.EYE_COLORS and eyeColor or 0
    }
end

local function setPlayerModel(model)
    if type(model) == "string" then model = joaat(model) end

    if IsModelInCdimage(model) then
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) do
            Wait(0)
            timeout = timeout + 1
            if timeout > 10000 then
                print("[illenium-appearance] Model load failed after timeout, aborting")
                SetModelAsNoLongerNeeded(model)
                return cache.ped
            end
        end

        pcall(function() exports['FeloxAC']:hasChangedPedModel(model) end) --[[FeloxAC:auto]]
        SetPlayerModel(cache.playerId, model)
        Wait(150)

        SetModelAsNoLongerNeeded(model)

        if isPedFreemodeModel(cache.ped) then
            SetPedDefaultComponentVariation(cache.ped)
             -- Check if the model is male or female, then change the face mix based on this.
             if model == `mp_m_freemode_01` then
                SetPedHeadBlendData(cache.ped, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)
            elseif model == `mp_f_freemode_01` then
                SetPedHeadBlendData(cache.ped, 45, 21, 0, 20, 15, 0, 0.3, 0.1, 0, false)
            end
        end

        PED_TATTOOS = {}
        return cache.ped
    else
        print(("[illenium-appearance] Model %s is not in cdimage!"):format(model))
    end

    return cache.playerId
end

-- the photo studio's empty head is a head like the parents' (component 0, right after the game's 46), so a face number
-- pointing at it would blend in no face: that number gets one past the last head, what it meant before the studio head
local STUDIO_HEADS = { [`mp_m_freemode_01`] = "mp_m_illenium_studio", [`mp_f_freemode_01`] = "mp_f_illenium_studio" }

local function realHead(ped, index)
    local name = STUDIO_HEADS[GetEntityModel(ped)]
    if name and index and index == GetPedDrawableGlobalIndexFromCollection(ped, 0, name, 0) then
        return GetNumberOfPedDrawableVariations(ped, 0)
    end
    return index
end

-- skins are GTA's 46 parents' only (0-45): an added face (46 and up) has no skin texture, and a blend asking for one
-- shows no face at all. A skin past 45 (a face picked with the old editor) takes another parent's skin, else the first
local SKINS = 46
local function realSkins(h)
    local s = { h.skinFirst or 0, h.skinSecond or 0, h.skinThird or 0 }
    local good = 0
    for i = 1, 3 do if s[i] < SKINS then good = s[i] break end end
    for i = 1, 3 do if s[i] >= SKINS then s[i] = good end end
    return s[1], s[2], s[3]
end

local function setPedHeadBlend(ped, headBlend)
    if headBlend and isPedFreemodeModel(ped) then
        local h = headBlend
        local s1, s2, s3 = realSkins(h)
        SetPedHeadBlendData(ped, realHead(ped, h.shapeFirst), realHead(ped, h.shapeSecond), realHead(ped, h.shapeThird), s1, s2, s3, tofloat(h.shapeMix or 0), tofloat(h.skinMix or 0), tofloat(h.thirdMix or 0), false)
    end
end

local function setPedFaceFeatures(ped, faceFeatures)
    if faceFeatures then
        for k, v in pairs(constants.FACE_FEATURES) do
            SetPedFaceFeature(ped, k-1, tofloat(faceFeatures[v]))
        end
    end
end

local function setPedHeadOverlays(ped, headOverlays)
    if headOverlays then
        local disableOverlays = (Config and Config.DisableHeadOverlays) or {}
        for k, v in pairs(constants.HEAD_OVERLAYS) do
            if disableOverlays[v] then
                SetPedHeadOverlay(ped, k - 1, 0, 0.0)
            else
                local headOverlay = headOverlays[v]
                if headOverlay then
                    SetPedHeadOverlay(ped, k - 1, headOverlay.style, tofloat(headOverlay.opacity))

                    if headOverlay.color then
                        local colorType = 1
                        if v == "blush" or v == "lipstick" or v == "makeUp" then
                            colorType = 2
                        end

                        SetPedHeadOverlayColor(ped, k - 1, colorType, headOverlay.color, headOverlay.secondColor)
                    end
                end
            end
        end
    end
end

local function applyAutomaticFade(ped, style)
    local gender = getPedDecorationType()
    local hairDecoration = constants.HAIR_DECORATIONS[gender][style]

    if(hairDecoration) then
        AddPedDecorationFromHashes(ped, hairDecoration[1], hairDecoration[2])
    end
end

local function applyHairFade(ped, tattoos, style)
    if not DoesEntityExist(ped) then return end

    if Config.AutomaticFade then
        applyAutomaticFade(ped, style or GetPedDrawableVariation(ped, 2))
        return
    end

    local zoneHair = tattoos and tattoos["ZONE_HAIR"]
    if not zoneHair then return end

    local isMale = client.getPedDecorationType() == "male"
    for i = 1, #zoneHair do
        local tattoo = zoneHair[i]
        local tattooGender = isMale and tattoo.hashMale or tattoo.hashFemale
        if tattoo.collection and tattooGender then
            for _ = 1, (tattoo.opacity or 0.1) * 10 do
                AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(tattooGender))
            end
        end
    end
end

local function setTattoos(ped, tattoos, style)
    local isMale = client.getPedDecorationType() == "male"
    ClearPedDecorations(ped)
    if Config.AutomaticFade then
        tattoos["ZONE_HAIR"] = {}
        PED_TATTOOS["ZONE_HAIR"] = {}
        applyAutomaticFade(ped, style or GetPedDrawableVariation(ped, 2))
    end
    for k in pairs(tattoos) do
        for i = 1, #tattoos[k] do
            local tattoo = tattoos[k][i]
            local tattooGender = isMale and tattoo.hashMale or tattoo.hashFemale
            for _ = 1, (tattoo.opacity or 0.1) * 10 do
                AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(tattooGender))
            end
        end
    end
    if Config.RCoreTattoosCompatibility then
        TriggerEvent("rcore_tattoos:applyOwnedTattoos")
        -- Keep the fade visible until rcore finishes its asynchronous refresh.
        -- The rcore_tattoos:setPedTattoos handler below applies it once more after
        -- rcore's final ClearPedDecorations call.
        applyHairFade(ped, tattoos, style)
    end
end

local function setPedHair(ped, hair, tattoos)
    if hair then
        SetPedComponentVariation(ped, 2, hair.style, hair.texture, 0)
        SetPedHairColor(ped, hair.color, hair.highlight)
        if isPedFreemodeModel(ped) then
            setTattoos(ped, tattoos or PED_TATTOOS, hair.style)
        end
    end
end

local function setPedEyeColor(ped, eyeColor)
    if eyeColor then
        SetPedEyeColor(ped, eyeColor)
    end
end

local function setPedComponent(ped, component)
    if component then
        if isPedFreemodeModel(ped) and (component.component_id == 0 or component.component_id == 2) then
            return
        end

        SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
    end
end

local function setPedComponents(ped, components)
    if components then
        for _, v in pairs(components) do
            setPedComponent(ped, v)
        end
    end
end

local function setPedProp(ped, prop)
    if prop then
        if prop.drawable == -1 then
            ClearPedProp(ped, prop.prop_id)
        else
            SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
        end
    end
end

local function setPedProps(ped, props)
    if props then
        for _, v in pairs(props) do
            setPedProp(ped, v)
        end
    end
end

local function setPedTattoos(ped, tattoos)
    PED_TATTOOS = tattoos
    setTattoos(ped, tattoos)
end

local function getPedTattoos()
    return PED_TATTOOS
end

local function addPedTattoo(ped, tattoos)
    setTattoos(ped, tattoos)
end

local function removePedTattoo(ped, tattoos)
    setTattoos(ped, tattoos)
end

local function setPreviewTattoo(ped, tattoos, tattoo)
    local isMale = client.getPedDecorationType() == "male"
    local tattooGender = isMale and tattoo.hashMale or tattoo.hashFemale

    ClearPedDecorations(ped)
    for _ = 1, (tattoo.opacity or 0.1) * 10 do
        AddPedDecorationFromHashes(ped, joaat(tattoo.collection), tattooGender)
    end
    for k in pairs(tattoos) do
        for i = 1, #tattoos[k] do
            local aTattoo = tattoos[k][i]
            if aTattoo.name ~= tattoo.name then
                local aTattooGender = isMale and aTattoo.hashMale or aTattoo.hashFemale
                for _ = 1, (aTattoo.opacity or 0.1) * 10 do
                    AddPedDecorationFromHashes(ped, joaat(aTattoo.collection), joaat(aTattooGender))
                end
            end
        end
    end
    if Config.AutomaticFade then
        applyAutomaticFade(ped, GetPedDrawableVariation(ped, 2))
    end
end

local function setPedAppearance(ped, appearance)
    if appearance then
        -- Cache tattoos before hair triggers rcore's asynchronous tattoo refresh.
        -- Otherwise a fast rcore response can observe the empty cache left by a
        -- model change and the saved ZONE_HAIR fade will not be restored.
        PED_TATTOOS = appearance.tattoos or {}

        setPedComponents(ped, appearance.components)
        setPedProps(ped, appearance.props)

        if appearance.headBlend and isPedFreemodeModel(ped) then setPedHeadBlend(ped, appearance.headBlend) end
        if appearance.faceFeatures then setPedFaceFeatures(ped, appearance.faceFeatures) end
        if appearance.headOverlays then setPedHeadOverlays(ped, appearance.headOverlays) end
        if appearance.hair then setPedHair(ped, appearance.hair, appearance.tattoos) end
        if appearance.eyeColor then setPedEyeColor(ped, appearance.eyeColor) end
        if not Config.RCoreTattoosCompatibility and appearance.tattoos then
            setPedTattoos(ped, appearance.tattoos)
        end
    end
end

local function setPlayerAppearance(appearance)
    if appearance then
        setPlayerModel(appearance.model)
        setPedAppearance(cache.ped, appearance)
    end
end

local function applyHairFadeExport()
    local ped = cache.ped
    if not DoesEntityExist(ped) then return end
    local appearance = getPedAppearance(ped)
    local tattoos = (appearance and appearance.tattoos) or PED_TATTOOS
    applyHairFade(ped, tattoos, GetPedDrawableVariation(ped, 2))
end

exports("applyHairFade", applyHairFadeExport)
exports("getPedModel", getPedModel)
exports("getPedComponents", getPedComponents)
exports("getPedProps", getPedProps)
exports("getPedHeadBlend", getPedHeadBlend)
exports("getPedFaceFeatures", getPedFaceFeatures)
exports("getPedHeadOverlays", getPedHeadOverlays)
exports("getPedHair", getPedHair)
exports("getPedAppearance", getPedAppearance)

exports("setPlayerModel", setPlayerModel)
exports("setPedHeadBlend", setPedHeadBlend)
exports("setPedFaceFeatures", setPedFaceFeatures)
exports("setPedHeadOverlays", setPedHeadOverlays)
exports("setPedHair", setPedHair)
exports("setPedEyeColor", setPedEyeColor)
exports("setPedComponent", setPedComponent)
exports("setPedComponents", setPedComponents)
exports("setPedProp", setPedProp)
exports("setPedProps", setPedProps)
exports("setPlayerAppearance", setPlayerAppearance)
exports("setPedAppearance", setPedAppearance)
exports("setPedTattoos", setPedTattoos)
exports("getPedTattoos", getPedTattoos)

client = {
    getPedAppearance = getPedAppearance,
    setPlayerModel = setPlayerModel,
    setPedHeadBlend = setPedHeadBlend,
    setPedFaceFeatures = setPedFaceFeatures,
    setPedHair = setPedHair,
    setPedHeadOverlays = setPedHeadOverlays,
    setPedEyeColor = setPedEyeColor,
    setPedComponent = setPedComponent,
    setPedProp = setPedProp,
    setPlayerAppearance = setPlayerAppearance,
    setPedAppearance = setPedAppearance,
    getPedDecorationType = getPedDecorationType,
    isPedFreemodeModel = isPedFreemodeModel,
    setPreviewTattoo = setPreviewTattoo,
    setPedTattoos = setPedTattoos,
    getPedTattoos = getPedTattoos,
    addPedTattoo = addPedTattoo,
    removePedTattoo = removePedTattoo,
    getPedModel = getPedModel,
    setPedComponents = setPedComponents,
    setPedProps = setPedProps,
    getPedComponents = getPedComponents,
    getPedProps = getPedProps
}

RegisterNetEvent("rcore_tattoos:setPedTattoos", function(ped, tattoos, disableClearCurrentTattoos)
    rcoreFadeGeneration = rcoreFadeGeneration + 1
    local generation = rcoreFadeGeneration

    CreateThread(function()
        -- rcore's public handler is synchronous. Yielding one frame guarantees
        -- that its ClearPedDecorations/add loop has completed without relying on
        -- a timing-sensitive fixed delay. Multiple events in the same frame are
        -- collapsed so the fade opacity is not stacked more than once.
        Wait(0)
        if generation ~= rcoreFadeGeneration then return end

        local playerPed = cache.ped
        if not DoesEntityExist(playerPed) then return end

        applyHairFade(playerPed, PED_TATTOOS, GetPedDrawableVariation(playerPed, 2))
    end)
end)
