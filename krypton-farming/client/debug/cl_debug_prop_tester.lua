-- DEBUG SANDBOX: Farm Tool Prop/Anim/Particle Testing
-- Temporary module for fast visual iteration. Safe to delete later.
if not Config.Debug then return end

local DebugProp = {
    active    = false,
    category  = nil,   -- 'water' | 'fert' | 'harvest' | 'milk' | 'egg'
    mode      = nil,   -- 'carry' | 'work'
    propEntity = nil,
    ptfxHandle = nil,
    animDict   = nil,  -- currently loaded dict (for cleanup)
    presetIdx  = 1,
    fxIdx      = 1,
}

-- Each preset: { prop, bone, offset, rotation, animDict, animClip, animFlags,
--                ptfxAsset?, ptfxEffect?, ptfxOffset?, ptfxRotation?, ptfxScale?, ptfxBone? }

-- Build base presets from CalibTargets (defined in cl_debug_prop_editor.lua)
-- Each preset key wraps the calibrated config in an array, extra test variants added below
local Presets = {}
for key, cfg in pairs(CalibTargets) do
    local entry = {}
    for k, v in pairs(cfg) do entry[k] = v end
    -- Carry modes use movement clipset in tester
    if key:find('_carry') then entry.useMovementClipset = true end
    Presets[key] = { entry }
end

-- Extra test variants (alternatives for visual comparison)
Presets.milk_work[#Presets.milk_work + 1] = {
    prop = 'prop_bucket_01b', bone = 28422,
    offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'amb@world_human_gardener_plant@male@idle_a', animClip = 'idle_a', animFlags = 1,
}
Presets.milk_work[#Presets.milk_work + 1] = {
    prop = 'prop_bucket_01b', bone = 28422,
    offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'mini@repair', animClip = 'fixing_a_ped', animFlags = 1,
}
Presets.egg_carry[#Presets.egg_carry + 1] = {
    prop = 'dd_egg_basket_empty', bone = 28422,
    offset = vector3(0.0, -0.10, -0.02), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'anim@heists@box_carry@', animClip = 'idle', animFlags = 49,
    useMovementClipset = true,
}
Presets.egg_carry[#Presets.egg_carry + 1] = {
    prop = 'hei_prop_heist_box', bone = 28422,
    offset = vector3(0.0, -0.10, -0.02), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'anim@heists@box_carry@', animClip = 'idle', animFlags = 49,
    useMovementClipset = true,
}
Presets.egg_work[#Presets.egg_work + 1] = {
    prop = 'prop_crate_01a', bone = 28422,
    offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'amb@world_human_gardener_plant@male@idle_a', animClip = 'idle_a', animFlags = 1,
}
Presets.egg_work[#Presets.egg_work + 1] = {
    prop = 'prop_crate_01a', bone = 28422,
    offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
    animDict = 'anim@gangops@facility@servers@bodysearch@', animClip = 'player_search', animFlags = 1,
}
Presets.feed_work[#Presets.feed_work + 1] = {
    prop = 'dd_feed_sack_full', bone = 57005,
    offset = vector3(0.0700, 0.1000, -0.2000), rotation = vector3(-169.8694, -21.2123, -33.9453),
    animDict = 'weapons@misc@jerrycan@', animClip = 'fire', animFlags = 49,
    ptfxAsset = 'core', ptfxEffect = 'ent_dst_dust',
    ptfxOffset = vector3(0.0, -0.15, -0.35), ptfxRotation = vector3(0.0, 0.0, 0.0), ptfxScale = 0.5,
}

local function GetPresetKey(category, mode)
    return category .. '_' .. mode
end

local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local t = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        if GetGameTimer() > t then return false end
    end
    return true
end

local function LoadModel(name)
    local hash = GetHashKey(name)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local t = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > t then return nil end
    end
    return hash
end

local function LoadPtfxAsset(asset)
    RequestNamedPtfxAsset(asset)
    local t = GetGameTimer() + 5000
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(10)
        if GetGameTimer() > t then return false end
    end
    return true
end

local function CleanupDebugState()
    if DebugProp.ptfxHandle and DebugProp.ptfxHandle ~= 0 then
        StopParticleFxLooped(DebugProp.ptfxHandle, false)
        DebugProp.ptfxHandle = nil
    end

    local ped = PlayerPedId()

    -- Reset movement clipset (used by carry presets)
    ResetPedMovementClipset(ped, 0)

    if DebugProp.propEntity and DoesEntityExist(DebugProp.propEntity) then
        DetachEntity(DebugProp.propEntity, true, true)
        DeleteEntity(DebugProp.propEntity)
    end
    DebugProp.propEntity = nil

    -- Also clean up production carry prop (in case user holds vehicle equip while debugging)
    if CleanupCarryProp then CleanupCarryProp() end

    DebugProp.active   = false
    DebugProp.category = nil
    DebugProp.mode     = nil
    DebugProp.animDict = nil
end

local function ApplyPreset(category, mode, presetIndex)
    CleanupDebugState()
    Wait(100)

    local key = GetPresetKey(category, mode)
    local list = Presets[key]
    if not list or #list == 0 then
        Krypton.Notify('No presets for ' .. key, 'error')
        return
    end

    local idx = ((presetIndex - 1) % #list) + 1
    local preset = list[idx]

    local propModel = preset.prop
    local hash = LoadModel(propModel)
    if not hash then
        if propModel == 'prop_tool_shovel006' then
            hash = LoadModel('prop_tool_shovel5')
            propModel = 'prop_tool_shovel5'
        end
        if not hash then
            Krypton.Notify('Failed to load prop: ' .. preset.prop, 'error')
            return
        end
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local obj = CreateObject(hash, pos.x, pos.y, pos.z + 2.0, false, false, false)
    if not obj or obj == 0 then
        Krypton.Notify('Failed to create prop', 'error')
        return
    end

    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)

    local off = preset.offset or vector3(0.0, 0.0, 0.0)
    local rot = preset.rotation or vector3(0.0, 0.0, 0.0)
    local bone = preset.bone or 57005

    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, bone),
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        true, true, false, true, 1, true)

    DebugProp.propEntity = obj

    local flags = preset.animFlags or 49
    if preset.useMovementClipset then
        -- Use TaskPlayAnim on the movement clipset dict (same as StartCalibration which is proven to work)
        if LoadAnimDict(preset.animDict) then
            TaskPlayAnim(ped, preset.animDict, preset.animClip, 8.0, -8.0, -1, flags, 0, false, false, false)
            DebugProp.animDict = preset.animDict
        end
    elseif LoadAnimDict(preset.animDict) then
        TaskPlayAnim(ped, preset.animDict, preset.animClip, 8.0, -8.0, -1, flags, 0, false, false, false)
        DebugProp.animDict = preset.animDict
    end

    if preset.ptfxAsset and preset.ptfxEffect then
        if LoadPtfxAsset(preset.ptfxAsset) then
            UseParticleFxAssetNextCall(preset.ptfxAsset)

            local fxOff = preset.ptfxOffset or vector3(0.0, 0.0, 0.0)
            local fxRot = preset.ptfxRotation or vector3(0.0, 0.0, 0.0)
            local fxScale = preset.ptfxScale or 1.0
            local fxBone = preset.ptfxBone

            local handle
            if fxBone then
                handle = StartParticleFxLoopedOnPedBone(preset.ptfxEffect,
                    ped, fxOff.x, fxOff.y, fxOff.z,
                    fxRot.x, fxRot.y, fxRot.z,
                    GetPedBoneIndex(ped, fxBone), fxScale, false, false, false)
            else
                handle = StartParticleFxLoopedOnEntity(preset.ptfxEffect,
                    obj, fxOff.x, fxOff.y, fxOff.z,
                    fxRot.x, fxRot.y, fxRot.z,
                    fxScale, false, false, false)
            end
            DebugProp.ptfxHandle = handle
        end
    end

    DebugProp.active    = true
    DebugProp.category  = category
    DebugProp.mode      = mode
    DebugProp.presetIdx = idx
    DebugProp.fxIdx     = 1

    local fxName = preset.ptfxEffect or 'none'
    Krypton.Notify(
        string.format('[%s/%s] Preset %d/%d | Anim: %s/%s | FX: %s',
            category, mode, idx, #list,
            preset.animDict, preset.animClip, fxName),
        'info', 6000
    )

    print(string.format('^3[FarmDebug] %s/%s preset %d/%d | prop=%s bone=%d | anim=%s/%s | fx=%s^7',
        category, mode, idx, #list,
        propModel, bone, preset.animDict, preset.animClip, fxName))
end

RegisterCommand('farmwater1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('water_carry') return end
    ApplyPreset('water', 'carry', DebugProp.category == 'water' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmwater2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('water_work') return end
    ApplyPreset('water', 'work', DebugProp.category == 'water' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmfert1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('fert_carry') return end
    ApplyPreset('fert', 'carry', DebugProp.category == 'fert' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmfert2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('fert_work') return end
    ApplyPreset('fert', 'work', DebugProp.category == 'fert' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmharvest1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('harvest_carry') return end
    ApplyPreset('harvest', 'carry', DebugProp.category == 'harvest' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmharvest2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('harvest_work') return end
    ApplyPreset('harvest', 'work', DebugProp.category == 'harvest' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmmilk1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('milk_carry') return end
    ApplyPreset('milk', 'carry', DebugProp.category == 'milk' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmmilk2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('milk_work') return end
    ApplyPreset('milk', 'work', DebugProp.category == 'milk' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmegg1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('egg_carry') return end
    ApplyPreset('egg', 'carry', DebugProp.category == 'egg' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmegg2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('egg_work') return end
    ApplyPreset('egg', 'work', DebugProp.category == 'egg' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmfeed1', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('feed_carry') return end
    ApplyPreset('feed', 'carry', DebugProp.category == 'feed' and DebugProp.mode == 'carry' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmfeed2', function(_, args)
    if args[1] == 'debug' then StartPropCalibration('feed_work') return end
    ApplyPreset('feed', 'work', DebugProp.category == 'feed' and DebugProp.mode == 'work' and DebugProp.presetIdx or 1)
end, false)

RegisterCommand('farmtestoff', function()
    CleanupDebugState()
    Krypton.Notify('Farm debug test cleared', 'info')
    print('^3[FarmDebug] Cleaned up all debug state^7')
end, false)

RegisterCommand('farmnextanim', function()
    if not DebugProp.active then
        Krypton.Notify('No active test. Use /farmwater1 etc first.', 'error')
        return
    end
    local nextIdx = DebugProp.presetIdx + 1
    ApplyPreset(DebugProp.category, DebugProp.mode, nextIdx)
end, false)

RegisterCommand('farmnextfx', function()
    if not DebugProp.active then
        Krypton.Notify('No active test.', 'error')
        return
    end

    local key = GetPresetKey(DebugProp.category, DebugProp.mode)
    local list = Presets[key]
    if not list then return end
    local preset = list[DebugProp.presetIdx]
    if not preset or not preset.ptfxAsset then
        Krypton.Notify('Current preset has no particle.', 'error')
        return
    end

    local fxCandidates = {}
    for _, p in ipairs(list) do
        if p.ptfxAsset and p.ptfxEffect then
            fxCandidates[#fxCandidates + 1] = { asset = p.ptfxAsset, effect = p.ptfxEffect, offset = p.ptfxOffset, rotation = p.ptfxRotation, scale = p.ptfxScale, bone = p.ptfxBone }
        end
    end
    if #fxCandidates == 0 then
        Krypton.Notify('No FX candidates in this mode.', 'error')
        return
    end

    DebugProp.fxIdx = (DebugProp.fxIdx % #fxCandidates) + 1
    local fx = fxCandidates[DebugProp.fxIdx]

    if DebugProp.ptfxHandle and DebugProp.ptfxHandle ~= 0 then
        StopParticleFxLooped(DebugProp.ptfxHandle, false)
        DebugProp.ptfxHandle = nil
    end

    if LoadPtfxAsset(fx.asset) then
        UseParticleFxAssetNextCall(fx.asset)
        local fxOff = fx.offset or vector3(0.0, 0.0, 0.0)
        local fxRot = fx.rotation or vector3(0.0, 0.0, 0.0)
        local fxScale = fx.scale or 1.0

        local handle
        local ped = PlayerPedId()
        if fx.bone then
            handle = StartParticleFxLoopedOnPedBone(fx.effect,
                ped, fxOff.x, fxOff.y, fxOff.z,
                fxRot.x, fxRot.y, fxRot.z,
                GetPedBoneIndex(ped, fx.bone), fxScale, false, false, false)
        elseif DebugProp.propEntity and DoesEntityExist(DebugProp.propEntity) then
            handle = StartParticleFxLoopedOnEntity(fx.effect,
                DebugProp.propEntity, fxOff.x, fxOff.y, fxOff.z,
                fxRot.x, fxRot.y, fxRot.z,
                fxScale, false, false, false)
        end
        DebugProp.ptfxHandle = handle
    end

    Krypton.Notify(string.format('FX %d/%d: %s/%s', DebugProp.fxIdx, #fxCandidates, fx.asset, fx.effect), 'info', 4000)
    print(string.format('^3[FarmDebug] FX cycled to %d/%d: %s / %s^7', DebugProp.fxIdx, #fxCandidates, fx.asset, fx.effect))
end, false)

RegisterCommand('farmsavepreset', function()
    if not DebugProp.active then
        Krypton.Notify('No active test to save.', 'error')
        return
    end

    local key = GetPresetKey(DebugProp.category, DebugProp.mode)
    local list = Presets[key]
    local preset = list and list[DebugProp.presetIdx]
    if not preset then return end

    local lines = {
        '^2═══════════════════════════════════════^7',
        '^2[FarmDebug] CURRENT PRESET DUMP^7',
        '^2═══════════════════════════════════════^7',
        string.format("category  = '%s',", DebugProp.category),
        string.format("mode      = '%s',", DebugProp.mode),
        string.format("presetIdx = %d,", DebugProp.presetIdx),
        '-- Prop',
        string.format("prop     = '%s',", preset.prop),
        string.format("bone     = %d,", preset.bone or 57005),
        string.format("offset   = vector3(%.3f, %.3f, %.3f),", preset.offset.x, preset.offset.y, preset.offset.z),
        string.format("rotation = vector3(%.3f, %.3f, %.3f),", preset.rotation.x, preset.rotation.y, preset.rotation.z),
        '-- Animation',
        string.format("animDict  = '%s',", preset.animDict),
        string.format("animClip  = '%s',", preset.animClip),
        string.format("animFlags = %d,", preset.animFlags or 49),
    }

    if preset.ptfxAsset then
        lines[#lines + 1] = '-- Particle FX'
        lines[#lines + 1] = string.format("ptfxAsset    = '%s',", preset.ptfxAsset)
        lines[#lines + 1] = string.format("ptfxEffect   = '%s',", preset.ptfxEffect)
        local po = preset.ptfxOffset or vector3(0, 0, 0)
        local pr = preset.ptfxRotation or vector3(0, 0, 0)
        lines[#lines + 1] = string.format("ptfxOffset   = vector3(%.3f, %.3f, %.3f),", po.x, po.y, po.z)
        lines[#lines + 1] = string.format("ptfxRotation = vector3(%.3f, %.3f, %.3f),", pr.x, pr.y, pr.z)
        lines[#lines + 1] = string.format("ptfxScale    = %.2f,", preset.ptfxScale or 1.0)
        if preset.ptfxBone then
            lines[#lines + 1] = string.format("ptfxBone     = %d,", preset.ptfxBone)
        end
    else
        lines[#lines + 1] = '-- No particle FX'
    end

    lines[#lines + 1] = '^2═══════════════════════════════════════^7'

    for _, l in ipairs(lines) do
        print(l)
    end

    Krypton.Notify('Preset dumped to F8 console', 'success')
end, false)

RegisterCommand('farmreloadpreset', function()
    if not DebugProp.active then
        Krypton.Notify('No active test to reload.', 'error')
        return
    end
    ApplyPreset(DebugProp.category, DebugProp.mode, DebugProp.presetIdx)
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupDebugState()
    end
end)

print('^3[FarmDebug] Prop/Anim/FX sandbox loaded. Commands: /farmwater1 /farmwater2 /farmfert1 /farmfert2 /farmharvest1 /farmharvest2 /farmtestoff /farmnextanim /farmnextfx /farmsavepreset /farmreloadpreset^7')
