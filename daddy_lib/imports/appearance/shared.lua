-- Stored clothing in one shape: { model = hash, skin = table, format = 'illenium'|'skinchanger'|'qb' }.
-- Pure tables and maths; the functions that touch the game only run when called.
local appearance = {}

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

-- Clothing script from the daddy:appearance convar, or the first one running; 'native' when none.
function appearance.detect()
    local forced = GetConvar('daddy:appearance', 'auto')
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
    if not ok then print(('^3[%s] appearance hook %s:%s failed: %s^7'):format(DL.resource, hook.resource, export, a)) end
    return ok, a, b
end

return appearance
