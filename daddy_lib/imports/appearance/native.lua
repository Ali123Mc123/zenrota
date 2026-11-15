-- The lib's own dresser: plain natives, so it works on any ped (local preview peds too) and any stored format.
return function(shared)
    local native = {}
    local MAKEUP = { makeUp = true, blush = true, lipstick = true }

    local function int(value) return math.floor(tonumber(value) or 0) end
    local function float(value) return (tonumber(value) or 0) + 0.0 end

    local function isFreemode(ped)
        local model = GetEntityModel(ped)
        return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
    end

    -- Streams a model in; false when it does not exist or takes over five seconds.
    function native.loadModel(model)
        if not model or not IsModelInCdimage(model) then return false end
        RequestModel(model)
        local deadline = GetGameTimer() + 5000
        while not HasModelLoaded(model) do
            if GetGameTimer() > deadline then return false end
            Wait(0)
        end
        return true
    end

    local function headBlend(ped, b)
        SetPedHeadBlendData(ped, int(b.shapeFirst), int(b.shapeSecond), int(b.shapeThird), int(b.skinFirst), int(b.skinSecond),
            int(b.skinThird), float(b.shapeMix), float(b.skinMix), float(b.thirdMix), false)
    end

    local function face(ped, features, overlays)
        for i, name in ipairs(shared.FACE_FEATURES) do
            if features and features[name] then SetPedFaceFeature(ped, i - 1, float(features[name])) end
        end
        for i, name in ipairs(shared.HEAD_OVERLAYS) do
            local overlay = overlays and overlays[name]
            if overlay then
                SetPedHeadOverlay(ped, i - 1, int(overlay.style), float(overlay.opacity))
                if overlay.color then SetPedHeadOverlayColor(ped, i - 1, overlay.colorType or (MAKEUP[name] and 2 or 1), int(overlay.color), int(overlay.secondColor)) end
            end
        end
    end

    local function clothes(ped, skin, freemode)
        for _, c in pairs(skin.components or {}) do
            local id = int(c.component_id)
            if not (freemode and (id == 0 or id == 2)) then SetPedComponentVariation(ped, id, int(c.drawable), int(c.texture), 0) end
        end
        for _, p in pairs(skin.props or {}) do
            if int(p.drawable) < 0 then ClearPedProp(ped, int(p.prop_id))
            else SetPedPropIndex(ped, int(p.prop_id), int(p.drawable), int(p.texture), true) end
        end
    end

    -- illenium tattoos: { [zone] = { { collection, hashMale, hashFemale } } }.
    local function tattoos(ped, list)
        ClearPedDecorations(ped)
        local male = GetEntityModel(ped) == `mp_m_freemode_01`
        for _, zone in pairs(list) do
            for _, tattoo in pairs(type(zone) == 'table' and zone or {}) do
                local name = male and tattoo.hashMale or tattoo.hashFemale
                if tattoo.collection and name then AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(name)) end
            end
        end
    end

    function native.apply(ped, data)
        local skin = shared.normalize(data)
        if not skin or not DoesEntityExist(ped) then return false end
        local freemode = isFreemode(ped)
        if freemode and skin.headBlend then headBlend(ped, skin.headBlend) end
        face(ped, skin.faceFeatures, skin.headOverlays)
        clothes(ped, skin, freemode)
        if skin.hair then
            SetPedComponentVariation(ped, 2, int(skin.hair.style), int(skin.hair.texture), 0)
            SetPedHairColor(ped, int(skin.hair.color), int(skin.hair.highlight))
        end
        if skin.eyeColor then SetPedEyeColor(ped, int(skin.eyeColor)) end
        if freemode and type(skin.tattoos) == 'table' then tattoos(ped, skin.tattoos) end
        return true
    end

    -- Swaps the player's model only when it differs, then dresses the new ped.
    function native.applyPlayer(data)
        local model = data and data.model
        if not native.loadModel(model) then return false end
        if GetEntityModel(PlayerPedId()) ~= model then
            pcall(function() exports['FeloxAC']:hasChangedPedModel(model) end) --[[FeloxAC:auto]]
            SetPlayerModel(PlayerId(), model)
            SetPedDefaultComponentVariation(PlayerPedId())
        end
        SetModelAsNoLongerNeeded(model)
        return native.apply(PlayerPedId(), data)
    end

    return native
end
