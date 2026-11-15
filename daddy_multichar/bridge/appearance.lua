-- Stored clothing in one shape: { model = hash, skin = table, format = 'illenium'|'skinchanger'|'qb' }, the clothing
-- scripts Bridge knows and the default looks. Pure tables and maths; the functions that touch the game only run when called.
do
    local appearance = {}

    -- Add a clothing script here when you add its adapter section in this file.
    local SCRIPTS = {
        { id = 'illenium', resource = 'illenium-appearance' },
        { id = 'fivem', resource = 'fivem-appearance' },
        { id = 'qbclothing', resource = 'qb-clothing' },
        { id = 'skinchanger', resource = 'skinchanger' },
    }

    local FREEMODE = { m = 'mp_m_freemode_01', f = 'mp_f_freemode_01' }
    local PROPS = { 0, 1, 2, 6, 7 }

    -- illenium's names, in native index order.
    local FACE_FEATURES = { 'noseWidth', 'nosePeakHigh', 'nosePeakSize', 'noseBoneHigh', 'nosePeakLowering', 'noseBoneTwist',
        'eyeBrownHigh', 'eyeBrownForward', 'cheeksBoneHigh', 'cheeksBoneWidth', 'cheeksWidth', 'eyesOpening', 'lipsThickness',
        'jawBoneWidth', 'jawBoneBackSize', 'chinBoneLowering', 'chinBoneLenght', 'chinBoneSize', 'chinHole', 'neckThickness' }
    local HEAD_OVERLAYS = { 'blemishes', 'beard', 'eyebrows', 'ageing', 'makeUp', 'blush', 'complexion', 'sunDamage', 'lipstick',
        'moleAndFreckles', 'chestHair', 'bodyBlemishes' }

    appearance.FREEMODE, appearance.PROPS = FREEMODE, PROPS
    appearance.FACE_FEATURES, appearance.HEAD_OVERLAYS = FACE_FEATURES, HEAD_OVERLAYS

    local function num(value, fallback)
        return tonumber(value) or fallback or 0
    end

    -- joaat in the game; tests stub it.
    local function hash(name)
        return (joaat or GetHashKey)(name)
    end

    local function copy(value)
        if type(value) ~= 'table' then return value end
        local out = {}
        for key, item in pairs(value) do out[key] = copy(item) end
        return out
    end
    appearance.copy = copy

    -- Clothing script from Config.Bridge.Appearance (or the multichar:appearance convar), or the first one running; 'native' when none.
    function appearance.detect()
        local forced = Bridge.setting('Appearance', 'appearance')
        if forced ~= 'auto' then return forced end
        for _, script in ipairs(SCRIPTS) do
            if GetResourceState(script.resource) == 'started' then return script.id end
        end
        return 'native'
    end

    function appearance.resourceOf(id)
        for _, script in ipairs(SCRIPTS) do
            if script.id == id then return script.resource end
        end
        return nil
    end

    -- The format of a stored skin table, or nil.
    function appearance.format(skin)
        if type(skin) ~= 'table' then return nil end
        if skin.components or skin.model then return 'illenium' end
        if skin.sex ~= nil or skin.tshirt_1 ~= nil or skin.torso_1 ~= nil then return 'skinchanger' end
        if type(skin.pants) == 'table' and skin.pants.item ~= nil then return 'qb' end
        return nil
    end

    -- Model hash of a row, a skin or a data table: names and hash strings both work; skinchanger picks by sex.
    function appearance.modelOf(row, gender)
        row = type(row) == 'table' and row or {}
        local skin = type(row.skin) == 'table' and row.skin or row
        local model = row.model
        if model == nil or model == '' then model = skin.model end
        if model ~= nil and model ~= '' then return tonumber(model) or hash(tostring(model)) end
        local sex = tonumber(skin.sex)
        if sex == nil then sex = gender == 'f' and 1 or 0 end
        return hash(sex == 1 and FREEMODE.f or FREEMODE.m)
    end

    -- A stored skin as data, or nil when it holds no real outfit (a bare { sex = 0 } for example).
    function appearance.data(skin, model)
        local format = appearance.format(skin)
        if not format or (format == 'skinchanger' and skin.torso_1 == nil and skin.tshirt_1 == nil) then return nil end
        return { model = appearance.modelOf({ model = model, skin = skin }), skin = skin, format = format }
    end

    -- Every head overlay, filled with empty ones; illenium expects all twelve.
    local function overlays(set)
        local out = {}
        for _, name in ipairs(HEAD_OVERLAYS) do
            local overlay = set[name] or {}
            out[name] = { style = overlay.style or 0, opacity = overlay.opacity or 0.0, color = overlay.color or 0, secondColor = 0 }
        end
        return out
    end

    -- Plain clothes with hair, so a new ped is never bald or bare.
    local function plain(model, hair, blend)
        local components, props = {}, {}
        for id = 0, 11 do components[id + 1] = { component_id = id, drawable = id == 2 and hair or 0, texture = 0 } end
        for i, id in ipairs(PROPS) do props[i] = { prop_id = id, drawable = -1, texture = -1 } end
        return { model = model, headBlend = blend, components = components, props = props, eyeColor = 0, tattoos = {},
            hair = { style = hair, texture = 0, color = 0, highlight = 0 }, headOverlays = overlays({ eyebrows = { style = 0, opacity = 1.0 } }) }
    end

    appearance.DEFAULTS = {
        m = plain(FREEMODE.m, 4, { shapeFirst = 0, shapeSecond = 0, shapeThird = 0, skinFirst = 0, skinSecond = 0, skinThird = 0, shapeMix = 0.0, skinMix = 0.0, thirdMix = 0.0 }),
        f = plain(FREEMODE.f, 4, { shapeFirst = 45, shapeSecond = 21, shapeThird = 0, skinFirst = 20, skinSecond = 15, skinThird = 0, shapeMix = 0.3, skinMix = 0.1, thirdMix = 0.0 }),
    }

    -- a new woman wears a top (the top's 0 shows her bare in the creator): Upper body › Tops › 66
    appearance.DEFAULTS.f.components[12].drawable = 66

    function appearance.defaults(gender)
        return copy(appearance.DEFAULTS[gender == 'f' and 'f' or 'm'])
    end

    -- skinchanger keys: { drawable, texture } per component and prop id, then face and overlay names in native order.
    local SC_COMPONENTS = { [1] = { 'mask_1', 'mask_2' }, [2] = { 'hair_1', 'hair_2' }, [3] = { 'arms', 'arms_2' }, [4] = { 'pants_1', 'pants_2' },
        [5] = { 'bags_1', 'bags_2' }, [6] = { 'shoes_1', 'shoes_2' }, [7] = { 'chain_1', 'chain_2' }, [8] = { 'tshirt_1', 'tshirt_2' },
        [9] = { 'bproof_1', 'bproof_2' }, [10] = { 'decals_1', 'decals_2' }, [11] = { 'torso_1', 'torso_2' } }
    local SC_PROPS = { [0] = { 'helmet_1', 'helmet_2' }, [1] = { 'glasses_1', 'glasses_2' }, [2] = { 'ears_1', 'ears_2' },
        [6] = { 'watches_1', 'watches_2' }, [7] = { 'bracelets_1', 'bracelets_2' } }
    local SC_FACE = { 'nose_1', 'nose_2', 'nose_3', 'nose_4', 'nose_5', 'nose_6', 'eyebrows_5', 'eyebrows_6', 'cheeks_1', 'cheeks_2',
        'cheeks_3', 'eye_squint', 'lip_thickness', 'jaw_1', 'jaw_2', 'chin_1', 'chin_2', 'chin_3', 'chin_4', 'neck_thickness' }
    local SC_OVERLAYS = { 'blemishes', 'beard', 'eyebrows', 'age', 'makeup', 'blush', 'complexion', 'sun', 'lipstick', 'moles', 'chest' }

    -- A skinchanger skin in illenium's shape, for the native dresser.
    function appearance.fromSkinchanger(skin)
        skin = type(skin) == 'table' and skin or {}
        local out = { components = {}, props = {}, faceFeatures = {}, headOverlays = {}, eyeColor = num(skin.eye_color) }
        for id = 0, 11 do
            local keys = SC_COMPONENTS[id]
            out.components[id + 1] = { component_id = id, drawable = keys and num(skin[keys[1]]) or 0, texture = keys and num(skin[keys[2]]) or 0 }
        end
        for i, id in ipairs(PROPS) do
            out.props[i] = { prop_id = id, drawable = num(skin[SC_PROPS[id][1]], -1), texture = num(skin[SC_PROPS[id][2]]) }
        end
        for i, key in ipairs(SC_FACE) do out.faceFeatures[FACE_FEATURES[i]] = num(skin[key]) / 10 end
        for i, key in ipairs(SC_OVERLAYS) do
            out.headOverlays[HEAD_OVERLAYS[i]] = { style = num(skin[key .. '_1']), opacity = num(skin[key .. '_2']) / 10,
                color = tonumber(skin[key .. '_3']), secondColor = num(skin[key .. '_4']), colorType = 1 }
        end
        out.hair = { style = num(skin.hair_1), texture = num(skin.hair_2), color = num(skin.hair_color_1), highlight = num(skin.hair_color_2) }
        local mom, dad, third = num(skin.mom), num(skin.dad), num(skin.grandparents)
        out.headBlend = { shapeFirst = mom, shapeSecond = dad, shapeThird = third, skinFirst = mom, skinSecond = dad, skinThird = third,
            shapeMix = num(skin.face_md_weight) / 100, skinMix = num(skin.skin_md_weight) / 100, thirdMix = num(skin.face_g_weight) / 100 }
        return out
    end

    -- qb-clothing keys: { item, texture } entries per component and prop id, then face and overlay names.
    local QB_COMPONENTS = { [1] = 'mask', [2] = 'hair', [3] = 'arms', [4] = 'pants', [5] = 'bag', [6] = 'shoes', [7] = 'accessory',
        [8] = 't-shirt', [9] = 'vest', [10] = 'decals', [11] = 'torso2' }
    local QB_PROPS = { [0] = 'hat', [1] = 'glass', [2] = 'ear', [6] = 'watch', [7] = 'bracelet' }
    local QB_FACE = { 'nose_0', 'nose_1', 'nose_2', 'nose_3', 'nose_4', 'nose_5', 'eyebrown_high', 'eyebrown_forward', 'cheek_1', 'cheek_2',
        'cheek_3', 'eye_opening', 'lips_thickness', 'jaw_bone_width', 'jaw_bone_back_lenght', 'chimp_bone_lowering', 'chimp_bone_lenght',
        'chimp_bone_width', 'chimp_hole', 'neck_thikness' }
    local QB_OVERLAYS = { [1] = 'beard', [2] = 'eyebrows', [3] = 'ageing', [4] = 'makeup', [5] = 'blush', [8] = 'lipstick' }

    local function item(skin, key)
        local entry = type(skin[key]) == 'table' and skin[key] or {}
        return num(entry.item), num(entry.texture)
    end

    -- A qb-clothing skin in illenium's shape, for the native dresser.
    function appearance.fromQb(skin)
        skin = type(skin) == 'table' and skin or {}
        local out = { components = {}, props = {}, faceFeatures = {}, headOverlays = {} }
        for id = 0, 11 do
            local drawable, texture = 0, 0
            if QB_COMPONENTS[id] then drawable, texture = item(skin, QB_COMPONENTS[id]) end
            out.components[id + 1] = { component_id = id, drawable = drawable, texture = id == 2 and 0 or texture }
        end
        for i, id in ipairs(PROPS) do
            local drawable, texture = item(skin, QB_PROPS[id])
            out.props[i] = { prop_id = id, drawable = drawable > 0 and drawable or -1, texture = texture }
        end
        for i, key in ipairs(QB_FACE) do out.faceFeatures[FACE_FEATURES[i]] = item(skin, key) / 10 end
        for index, key in pairs(QB_OVERLAYS) do
            local style, color = item(skin, key)
            out.headOverlays[HEAD_OVERLAYS[index + 1]] = { style = style, opacity = 1.0, color = color, secondColor = 0, colorType = 1 }
        end
        local moles, strength = item(skin, 'moles')
        if moles > 0 then out.headOverlays.moleAndFreckles = { style = moles, opacity = strength / 10 } end
        local hair, color = item(skin, 'hair')
        out.hair = { style = hair, texture = 0, color = color, highlight = color }
        local face, faceSkin = item(skin, 'face')
        local face2, face2Skin = face, faceSkin
        if type(skin.face2) == 'table' then face2, face2Skin = item(skin, 'face2') end
        local mix = type(skin.facemix) == 'table' and skin.facemix or {}
        out.headBlend = { shapeFirst = face, shapeSecond = face2, shapeThird = 0, skinFirst = faceSkin, skinSecond = face2Skin, skinThird = 0,
            shapeMix = num(mix.shapeMix), skinMix = num(mix.skinMix), thirdMix = 0 }
        local eye = item(skin, 'eye_color')
        if eye > 0 then out.eyeColor = eye end
        return out
    end

    -- Any stored format in illenium's shape, or nil.
    function appearance.normalize(data)
        local skin = type(data) == 'table' and data.skin or nil
        local format = type(data) == 'table' and data.format or appearance.format(skin)
        if format == 'skinchanger' then return appearance.fromSkinchanger(skin) end
        if format == 'qb' then return appearance.fromQb(skin) end
        return type(skin) == 'table' and skin or nil
    end

    -- A community clothing script: { resource, apply, applyPlayer, creator, fetch }, each an export name.
    function appearance.hookOf(def)
        if type(def) ~= 'table' or type(def.resource) ~= 'string' or def.resource == '' then return nil end
        return { resource = def.resource, apply = def.apply, applyPlayer = def.applyPlayer, creator = def.creator, fetch = def.fetch }
    end

    -- Calls a hook export: ok, results; ok is false when the script is not running, has no such export or fails.
    function appearance.callHook(hook, name, ...)
        local export = hook and hook[name]
        if type(export) ~= 'string' or GetResourceState(hook.resource) ~= 'started' then return false end
        local target = exports[hook.resource]
        local ok, a, b = pcall(target[export], target, ...)
        if not ok then Bridge.warn('appearance hook %s:%s failed: %s', hook.resource, export, a) end
        return ok, a, b
    end

    Bridge.skin = appearance
end

-- The bridge's own dresser: plain natives, so it works on any ped (local preview peds too) and any stored format.
do
    Bridge.appearances.native = function(ctx)
        local shared = ctx.shared
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
end

-- illenium-appearance exports (fivem-appearance shares them). Its editor does not save, so the bridge saves on submit.
do
    local SECTIONS = {
        ped = true, headBlend = true, faceFeatures = true, headOverlays = true, components = true, props = true, tattoos = true,
        componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true,
            bodyArmor = true, shirts = true, decals = true, jackets = true },
        propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true },
        enableExit = false, enableSave = true, shopType = 'creator', hasTracker = false, automaticFade = false,
    }

    Bridge.appearances.illenium = function(ctx)
        local resource, shared = ctx.resource, ctx.shared
        local adapter = {}

        local function call(name, ...)
            local target = exports[resource]
            local ok, result = pcall(target[name], target, ...)
            return ok, result
        end

        -- illenium keeps one tattoo list for every ped it dresses; an explicit empty list stops it leaking between peds.
        local function prepared(skin, model)
            local out = shared.copy(skin)
            out.model = out.model or model
            out.tattoos = out.tattoos or {}
            return out
        end

        -- Works on local preview peds as well as the player.
        function adapter.apply(ped, skin)
            return (call('setPedAppearance', ped, prepared(skin)))
        end

        function adapter.applyPlayer(data)
            return (call('setPlayerAppearance', prepared(data.skin, data.model)))
        end

        -- Not InitializeCharacter: that moves the player to another routing bucket.
        function adapter.creator(gender, session)
            call('setPlayerModel', shared.FREEMODE[gender])
            call('setPedAppearance', PlayerPedId(), shared.defaults(gender))
            if IsScreenFadedOut() then DoScreenFadeIn(500) end -- the editor waits for a faded-in screen
            local config = shared.copy(SECTIONS)
            for key, value in pairs(session.opts.sections or {}) do config[key] = value end
            return (call('startPlayerCustomization', function(appearance) session.finish(appearance or false) end, config))
        end

        -- Same call as illenium's own InitializeCharacter makes after its editor.
        adapter.save = ctx.save or function(appearance)
            TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
        end

        return adapter
    end
end

-- fivem-appearance: illenium's exports without a save event, so the product's '<resource>:appearance:save' stores it.
do
    Bridge.appearances.fivem = function(ctx)
        ctx.save = function(appearance)
            lib.callback.await(Bridge.resource .. ':appearance:save', false, appearance)
        end
        return Bridge.appearances.illenium(ctx)
    end
end

-- qb-clothing: dresses any ped through its loader event; its first-character menu saves by itself.
do
    local RESOURCE = 'qb-clothing'

    Bridge.appearances.qbclothing = function()
        local adapter = {}

        -- qb-clothing reads every key it knows, so a skin without them falls back to the native dresser.
        function adapter.apply(ped, skin)
            if type(skin.face) ~= 'table' or type(skin.pants) ~= 'table' then return false end
            TriggerEvent('qb-clothing:client:loadPlayerClothing', skin, ped)
            return true
        end

        -- Its loader swaps the model in a thread of its own; wait for the swap.
        function adapter.applyPlayer(data)
            local model = math.tointeger(tonumber(data.model))
            if not model then return false end
            TriggerEvent('qb-clothes:loadSkin', nil, model, json.encode(data.skin))
            local deadline = GetGameTimer() + 5000
            while (GetEntityModel(PlayerPedId()) & 0xFFFFFFFF) ~= (model & 0xFFFFFFFF) do
                if GetGameTimer() > deadline then return false end
                Wait(50)
            end
            Wait(100)
            return true
        end

        -- The menu is open while IsCreatingCharacter is true; polled only for that time.
        function adapter.creator(_, session)
            TriggerEvent('qb-clothes:client:CreateFirstCharacter')
            CreateThread(function()
                local opened, deadline = false, GetGameTimer() + 10000
                while session.open do
                    local ok, creating = pcall(function() return exports[RESOURCE]:IsCreatingCharacter() end)
                    if not ok then return session.finish(false) end
                    if creating then opened = true
                    elseif opened then return session.finish(true)
                    elseif GetGameTimer() > deadline then return session.finish(false) end
                    Wait(250)
                end
            end)
            return true
        end

        return adapter
    end
end

-- skinchanger with esx_skin. skinchanger only dresses the player ped, so previews use the native dresser.
do
    Bridge.appearances.skinchanger = function()
        local adapter = {}

        -- Starts an event that answers through a callback; false after ms without an answer.
        local function await(start, ms)
            local p, settled = promise.new(), false
            local function settle(value)
                if settled then return end
                settled = true
                p:resolve(value)
            end
            start(function() settle(true) end)
            SetTimeout(ms, function() settle(false) end)
            return Citizen.Await(p)
        end

        function adapter.applyPlayer(data)
            return await(function(done) TriggerEvent('skinchanger:loadSkin', data.skin, done) end, 10000)
        end

        -- loadSkin records the sex esx_skin saves (the default model alone does not); a frame lets it finish before the menu reads it.
        function adapter.creator(gender, session)
            if GetResourceState('esx_skin') ~= 'started' then return false end
            local skin = { sex = gender == 'f' and 1 or 0 }
            if not await(function(done) TriggerEvent('skinchanger:loadSkin', skin, done) end, 10000) then return false end
            Wait(0)
            TriggerEvent('esx_skin:openSaveableMenu', function() session.finish(true) end, function() session.finish(false) end)
            return true
        end

        return adapter
    end
end

-- Builds Bridge.appearance from the clothing script in use. Client: dresses preview peds and the player and runs the
-- script's creator. Server: stored clothing (playerskins on qb/qbx, users.skin on esx) for previews, saved for fivem-appearance.
do
    local skin = Bridge.skin

    -- Shared: the clothing script now; it may start after this resource, so it is looked up again on use.
    local function shared(appearance)
        appearance.id = skin.detect()
        appearance.resourceOf = skin.resourceOf
        appearance.modelOf = skin.modelOf
        appearance.defaults = skin.defaults
        return appearance
    end

    -- Client --------------------------------------------------------------------------------------------------

    local BY_FORMAT = { illenium = { 'illenium', 'fivem' }, qb = { 'qbclothing' } }
    local FORMAT_OF = { illenium = 'illenium', fivem = 'illenium', qbclothing = 'qb', skinchanger = 'skinchanger' }

    local function client()
        local appearance = shared({})
        local script = appearance.id
        local native = Bridge.appearances.native({ shared = skin })
        local adapters, hook, current = {}, nil, nil

        -- One adapter per script id, built on first use; unknown ids use the native dresser.
        local function adapterOf(id)
            if adapters[id] == nil then
                local make = id ~= 'native' and Bridge.appearances[id]
                adapters[id] = make and make({ resource = skin.resourceOf(id), shared = skin, native = native }) or native
            end
            return adapters[id]
        end

        local function running(id)
            return Bridge.started(skin.resourceOf(id))
        end

        -- A community script, asked before the built-in adapters: { resource, apply, applyPlayer, creator, fetch } export names.
        function appearance.useHook(def)
            hook = skin.hookOf(def)
            if hook then appearance.id = hook.resource end
            return hook ~= nil
        end

        -- Dresses any ped, local preview peds included, by the format the skin was stored in.
        function appearance.apply(ped, data)
            if type(data) ~= 'table' or not DoesEntityExist(ped) then return false end
            local ok, done = skin.callHook(hook, 'apply', ped, data)
            if ok and done then return true end
            if type(data.skin) ~= 'table' then return false end
            for _, id in ipairs(BY_FORMAT[data.format or skin.format(data.skin)] or {}) do
                local adapter = adapterOf(id)
                if running(id) and adapter.apply and adapter.apply(ped, data.skin) then return true end
            end
            return native.apply(ped, data)
        end

        -- Dresses the player through the running script when it stored this format, otherwise with natives.
        function appearance.applyPlayer(data)
            if type(data) ~= 'table' then return false end
            local ok, done = skin.callHook(hook, 'applyPlayer', data)
            if ok and done then return true end
            if type(data.skin) ~= 'table' then return false end
            local adapter = adapterOf(script)
            local format = data.format or skin.format(data.skin)
            if FORMAT_OF[script] == format and running(script) and adapter.applyPlayer(data) then return true end
            return native.applyPlayer(data)
        end

        function appearance.defaultPed(gender)
            gender = gender == 'f' and 'f' or 'm'
            return { model = joaat(skin.FREEMODE[gender]), skin = skin.defaults(gender), format = 'illenium' }
        end

        -- Asks the server up to three times, five seconds apart, whether the clothing reached the database.
        local function confirmSaved(session)
            for try = 1, 3 do
                Wait(try == 1 and 500 or 5000)
                if session.cancelled then return false end
                if lib.callback.await(Bridge.resource .. ':appearance:saved', false) == true then return true end
            end
            return false
        end

        -- finish(result) ends the creator once: an appearance to save, true when the script saved, false when cancelled.
        local function newSession(opts)
            local session = { open = true, opts = type(opts) == 'table' and opts or {}, done = promise.new() }
            function session.finish(result)
                if not session.open then return end
                session.open = false
                session.done:resolve(result)
            end
            return session
        end

        -- Blocks until the new character's clothing is saved: true, or false with 'unsaved' | 'cancelled' | 'unsupported'.
        function appearance.openCreator(gender, opts)
            appearance.cancel()
            gender = gender == 'f' and 'f' or 'm'
            local session = newSession(opts)
            local adapter = adapterOf(script)
            current = session
            if hook and hook.creator and Bridge.started(hook.resource) then
                CreateThread(function()
                    local ok, saved = skin.callHook(hook, 'creator', gender, session.opts)
                    session.finish(ok and saved ~= false)
                end)
            elseif not (running(script) and adapter.creator and adapter.creator(gender, session)) then
                current = nil
                return false, 'unsupported'
            end
            local result = Citizen.Await(session.done)
            if type(result) == 'table' and adapter.save and not session.cancelled then adapter.save(result) end
            local saved = result ~= false and not session.cancelled and confirmSaved(session)
            if current == session then current = nil end
            if saved then return true end
            return false, (session.cancelled or result == false) and 'cancelled' or 'unsaved'
        end

        -- Releases a waiting openCreator; none of the supported scripts can close its menu from outside.
        function appearance.cancel()
            local session = current
            current = nil
            if not session then return end
            session.cancelled = true
            session.finish(false)
        end

        -- Relog hygiene: the clothing script forgets the last character's tattoos and outfit cache.
        function appearance.reset()
            local fw = Bridge.fw.id
            if fw == 'qb' or fw == 'qbx' then TriggerEvent('qb-multicharacter:client:chooseChar')
            elseif fw == 'esx' then TriggerEvent('esx_skin:resetFirstSpawn') end
        end

        -- A clothing script that stops mid-creator never answers; release the wait.
        AddEventHandler('onResourceStop', function(resource)
            if current and (resource == skin.resourceOf(script) or (hook and resource == hook.resource)) then appearance.cancel() end
        end)

        return appearance
    end

    -- Server --------------------------------------------------------------------------------------------------

    local MAX_BYTES, BATCH = 65536, 50

    local function qbLike()
        return Bridge.fw.id == 'qb' or Bridge.fw.id == 'qbx'
    end

    -- One batch of rows as { citizenid, model, skin }.
    local function rows(ids)
        local marks = ('?,'):rep(#ids):sub(1, -2)
        if qbLike() and Bridge.has('playerskins') then
            return MySQL.query.await(('SELECT citizenid, model, skin FROM playerskins WHERE active = 1 AND citizenid IN (%s)'):format(marks), ids) or {}
        end
        if Bridge.fw.id == 'esx' and Bridge.has('users', 'skin') then
            return MySQL.query.await(('SELECT identifier AS citizenid, skin FROM users WHERE identifier IN (%s)'):format(marks), ids) or {}
        end
        return {}
    end

    -- The format is read per row: illenium on ESX keeps its own format in users.skin.
    local function decode(row)
        if type(row.skin) ~= 'string' or #row.skin > MAX_BYTES then return nil end
        local ok, value = pcall(json.decode, row.skin)
        return ok and skin.data(value, row.model) or nil
    end

    local function server()
        local appearance = shared({})
        local allowed = { [joaat(skin.FREEMODE.m)] = true, [joaat(skin.FREEMODE.f)] = true }
        local hook, served

        function appearance.current()
            if not hook then appearance.id = skin.detect() end
            return appearance.id
        end

        -- A community script: { resource, apply, applyPlayer, creator, fetch } export names; its fetch replaces the tables.
        function appearance.useHook(def)
            hook = skin.hookOf(def)
            if hook then appearance.id = hook.resource end
            return hook ~= nil
        end

        -- Clothing of many characters: { [citizenid] = data }. Skins over 64 KB are skipped.
        function appearance.fetch(citizenids)
            local ids, seen, out = {}, {}, {}
            for _, cid in ipairs(type(citizenids) == 'table' and citizenids or {}) do
                if type(cid) == 'string' and cid ~= '' and not seen[cid] then
                    seen[cid] = true
                    ids[#ids + 1] = cid
                end
            end
            if #ids == 0 then return out end
            local ok, result = skin.callHook(hook, 'fetch', ids)
            if ok and type(result) == 'table' then return result end
            for first = 1, #ids, BATCH do
                for _, row in ipairs(rows(table.move(ids, first, math.min(first + BATCH - 1, #ids), 1, {}))) do
                    out[row.citizenid] = decode(row)
                end
            end
            return out
        end

        function appearance.get(citizenid)
            return appearance.fetch({ citizenid })[citizenid]
        end

        function appearance.has(citizenid)
            return appearance.get(citizenid) ~= nil
        end

        -- For fivem-appearance, which has no save of its own. Freemode models (or serve's extra models) only.
        function appearance.save(citizenid, data)
            local value = type(data) == 'table' and data.skin
            if type(citizenid) ~= 'string' or citizenid == '' or skin.format(value) ~= 'illenium' then return false end
            if not allowed[skin.modelOf({ skin = value })] then return false end
            local encoded = json.encode(value)
            if #encoded > MAX_BYTES then return false end
            if qbLike() and Bridge.has('playerskins') then
                return MySQL.transaction.await({
                    { query = 'UPDATE playerskins SET active = 0 WHERE citizenid = ?', values = { citizenid } },
                    { query = 'INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, 1)', values = { citizenid, tostring(value.model), encoded } },
                }) == true
            end
            if Bridge.fw.id == 'esx' and Bridge.has('users', 'skin') then
                return (MySQL.update.await('UPDATE users SET skin = ? WHERE identifier = ?', { encoded, citizenid }) or 0) > 0
            end
            return false
        end

        -- Registers '<resource>:appearance:saved' and ':save' once. opts = { models = { names }, canSave = fn(source) }.
        function appearance.serve(opts)
            if served then return end
            served, opts = true, type(opts) == 'table' and opts or {}
            for _, model in ipairs(opts.models or {}) do allowed[type(model) == 'number' and model or joaat(model)] = true end
            local limiter = Core.ratelimit.new({ saved = { capacity = 6, refill = 0.5 }, save = { capacity = 3, refill = 0.2 } })

            -- The character always comes from the session, never from the client.
            lib.callback.register(Bridge.resource .. ':appearance:saved', function(source)
                if not limiter.take(source, 'saved') then return false end
                local cid = Bridge.fw.citizenId(source)
                return cid ~= nil and appearance.has(cid)
            end)

            lib.callback.register(Bridge.resource .. ':appearance:save', function(source, value)
                if appearance.current() ~= 'fivem' or not limiter.take(source, 'save') then return false end
                if opts.canSave and not opts.canSave(source) then return false end
                local cid = Bridge.fw.citizenId(source)
                return cid ~= nil and appearance.save(cid, { skin = value })
            end)

            AddEventHandler('playerDropped', function() limiter.forget(source) end)
        end

        return appearance
    end

    Bridge.define('appearance', function()
        if Bridge.side == 'client' then return client() end
        return server()
    end)
end
