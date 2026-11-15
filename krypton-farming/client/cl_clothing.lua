-- Auto-detects active clothing system (qb-clothing, illenium-appearance,
-- fivem-appearance, rcore_clothing, esx_skin) and provides a unified API.
-- Based on community_bridge approach.

Krypton.Clothing = {}

local function DetectClothing()
    local checks = {
        { resource = 'rcore_clothing',        name = 'rcore_clothing'        },
        { resource = '17mov_CharacterSystem', name = '17mov_CharacterSystem' },
        { resource = 'illenium-appearance',   name = 'illenium-appearance'   },
        { resource = 'fivem-appearance',      name = 'fivem-appearance'      },
        { resource = 'qb-clothing',           name = 'qb-clothing'           },
        { resource = 'esx_skin',              name = 'esx_skin'              },
    }
    for _, v in ipairs(checks) do
        if GetResourceState(v.resource) ~= 'missing' then return v.name end
    end
    return 'default'
end

Krypton.ClothingSystem = DetectClothing()
DebugPrint('[Clothing] Active system:', Krypton.ClothingSystem)

local COMP_IDS = {
    mask_1 = 1, arms = 3, pants_1 = 4, bags_1 = 5, shoes_1 = 6,
    chain_1 = 7, tshirt_1 = 8, bproof_1 = 9, decals_1 = 10, torso_1 = 11,
}
local PROP_IDS = { hat_1 = 0, glass_1 = 1, ear_1 = 2, watch_1 = 6, bracelet_1 = 7 }

function Krypton.Clothing.GetAppearance(ped)
    ped = ped or PlayerPedId()
    local data = { components = {}, props = {} }
    for i = 0, 11 do
        data.components[#data.components + 1] = {
            component_id = i,
            drawable     = GetPedDrawableVariation(ped, i),
            texture      = GetPedTextureVariation(ped, i),
        }
    end
    for i = 0, 13 do
        data.props[#data.props + 1] = {
            prop_id  = i,
            drawable = GetPedPropIndex(ped, i),
            texture  = GetPedPropTextureIndex(ped, i),
        }
    end
    return data
end

function Krypton.Clothing.SetAppearance(ped, data)
    ped = ped or PlayerPedId()
    if not data then return end
    for _, v in ipairs(data.components or {}) do
        SetPedComponentVariation(ped, v.component_id, v.drawable, v.texture, 0)
    end
    for _, v in ipairs(data.props or {}) do
        if v.drawable >= 0 then
            SetPedPropIndex(ped, v.prop_id, v.drawable, v.texture, true)
        else
            ClearPedProp(ped, v.prop_id)
        end
    end
end

function Krypton.Clothing.WorkClothesToAppearance(kryptClothes)
    local components, props, grouped = {}, {}, {}
    for key, value in pairs(kryptClothes) do
        if key == 'arms' then
            grouped['arms'] = { d = value, t = 0 }
        else
            local base, num = string.match(key, '^(.+)_(%d)$')
            if base then
                grouped[base] = grouped[base] or {}
                if num == '1' then grouped[base].d = value
                elseif num == '2' then grouped[base].t = value end
            end
        end
    end
    for base, data in pairs(grouped) do
        local key = (base == 'arms') and 'arms' or (base .. '_1')
        local d, t = data.d or 0, data.t or 0
        if PROP_IDS[key] then
            props[#props + 1] = { prop_id = PROP_IDS[key], drawable = d, texture = t }
        elseif COMP_IDS[key] then
            components[#components + 1] = { component_id = COMP_IDS[key], drawable = d, texture = t }
        end
    end
    return { components = components, props = props }
end

-- isWork = true  → clothes is Config.WorkClothes[gender] format (krypton config)
-- isWork = false → clothes is bridge format { components, props }
RegisterNetEvent('krypton-farming:client:setClothes', function(clothes, isWork)
    if not clothes then return end
    local ped = PlayerPedId()

    if isWork then
        local appearance = Krypton.Clothing.WorkClothesToAppearance(clothes)
        Krypton.Clothing.SetAppearance(ped, appearance)
        DebugPrint('[Clothing] Work clothes applied via', Krypton.ClothingSystem)
        Krypton.Notify(T('clothes_work'), 'success')
    else
        Krypton.Clothing.SetAppearance(ped, clothes)
        DebugPrint('[Clothing] Civilian clothes restored via', Krypton.ClothingSystem)
        Krypton.Notify(T('clothes_civilian'), 'success')
    end
end)

RegisterNetEvent('krypton-farming:client:saveAndChangeToWork', function()
    local appearance = Krypton.Clothing.GetAppearance(PlayerPedId())
    TriggerServerEvent('krypton-farming:server:clothesBackupReady', appearance)
    DebugPrint('[Clothing] Appearance snapshot sent to server for backup')
end)

RegisterNetEvent('krypton-farming:client:saveClothes', function()
    local appearance = Krypton.Clothing.GetAppearance(PlayerPedId())
    TriggerServerEvent('krypton-farming:server:saveClothesBackup', appearance)
    DebugPrint('[Clothing] Appearance snapshot saved (legacy path)')
end)

DebugPrint('Clothing module loaded')
