-- DaddyRP: debug only, players never see these commands
if not Config.Debug then return end
-- PROP CALIBRATION: Player Hand-Held Prop Offset/Rotation Live Tuner (v3)
-- Purpose:  Attach farm tool props to player hand bones and live-adjust
--           offset/rotation via numpad keys while the animation plays.
--           Results are printed as ready-to-use Lua config to F8 console.
--
-- Usage:    /farmwater1 debug   → enter calibration for water carry
--           /farmwater2 debug   → enter calibration for water work
--           /farmfert1 debug    → enter calibration for fert carry
--           /farmfert2 debug    → enter calibration for fert work
--           /farmharvest1 debug → enter calibration for harvest carry
--           /farmharvest2 debug → enter calibration for harvest work
--           /farmmilk1 debug    → enter calibration for milk carry
--           /farmmilk2 debug    → enter calibration for milk work
--           /farmegg1 debug     → enter calibration for egg carry
--           /farmegg2 debug     → enter calibration for egg work
--           /farmfeed1 debug    → enter calibration for feed carry
--           /farmfeed2 debug    → enter calibration for feed work
--           (numpad to adjust, /farmcalibsave to export, /farmcaliboff to exit)
--
-- Removal:  Delete this file + remove its line from fxmanifest.lua.

if not Config.Debug then return end

local HAS_OX_LIB = lib ~= nil

local DEFAULT_STEP     = 0.01
local FAST_STEP_MULT   = 10.0
local ROT_MULT         = 100.0  -- step * ROT_MULT = degrees per tap

CalibTargets = {
    water_carry = {
        prop = 'prop_wateringcan', bone = 57005,
        offset = vector3(0.4300, -0.0300, -0.0500), rotation = vector3(470.0000, 170.0000, 100.0000),
        animDict = 'move_weapon@jerrycan@generic', animClip = 'idle', animFlags = 49,
    },
    -- Reference: it-drugs/cl_planting.lua
    water_work = {
        prop = 'prop_wateringcan', bone = 28422,
        offset = vector3(0.4, 0.1, 0.0), rotation = vector3(90.0, 180.0, 0.0),
        animDict = 'weapon@w_sp_jerrycan', animClip = 'fire', animFlags = 49,
        ptfxAsset = 'core', ptfxEffect = 'ent_sht_water',
        ptfxOffset = vector3(0.35, 0.0, 0.25), ptfxRotation = vector3(0.0, 0.0, 0.0), ptfxScale = 2.0,
    },
    fert_carry = {
        prop = 'dd_feed2_sack_full', bone = 57005,
        offset = vector3(0.3300, -0.0200, 0.0500), rotation = vector3(470.0000, 170.0000, 100.0000),
        animDict = 'move_weapon@jerrycan@generic', animClip = 'idle', animFlags = 49,
    },
    -- Reference: rpemotes-reborn fuel emote (jerrycan pour)
    fert_work = {
        prop = 'dd_feed2_sack_open', bone = 57005,
        offset = vector3(0.1800, 0.1300, -0.2400), rotation = vector3(-165.8694, -11.2123, -32.9453),
        animDict = 'weapons@misc@jerrycan@', animClip = 'fire', animFlags = 49,
        ptfxAsset = 'core', ptfxEffect = 'ent_dst_dust',
        ptfxOffset = vector3(0.0, -0.15, -0.35), ptfxRotation = vector3(0.0, 0.0, 0.0), ptfxScale = 0.5,
    },
    -- Reference: rpemotes-reborn dig (carry uses same prop/bone, offset to be calibrated)
    harvest_carry = {
        prop = 'prop_tool_shovel2', bone = 28422,
        offset = vector3(0.7000, 0.9500, -0.0010), rotation = vector3(-53.0000, -88.0000, -181.0000),
        animDict = 'move_weapon@jerrycan@generic', animClip = 'idle', animFlags = 49,
    },
    -- Reference: rpemotes-reborn random@burial/a_burial
    harvest_work = {
        prop = 'prop_tool_shovel2', bone = 28422,
        offset = vector3(0.0000, -0.1000, -0.950), rotation = vector3(-2.0, 0.0, 0.0),
        animDict = 'random@burial', animClip = 'a_burial', animFlags = 49,
    },
    -- ANIMAL: Milk carry — bucket held by side
    milk_carry = {
        prop = 'ba_prop_battle_ice_bucket', bone = 57005,
        offset   = vector3(0.3500, -0.0300, -0.0200),  rotation = vector3(-11.0000, -90.0000, -11.0000),
        animDict = 'move_weapon@jerrycan@generic', animClip = 'idle', animFlags = 49,
    },
    -- ANIMAL: Milk work — milking near cow
    milk_work = {
        prop = 'ba_prop_battle_ice_bucket', bone = 28422,
        offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
        animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', animClip = 'machinic_loop_mechandplayer', animFlags = 1,
    },
    -- ANIMAL: Egg carry — basket held while walking (two-handed box carry)
    egg_carry = {
        prop = 'dd_egg_basket_empty', bone = 57005,
        offset = vector3(0.40, 0.0, -0.10), rotation = vector3(0.0, 0.0, 0.0),
        animDict = 'anim@heists@box_carry@', animClip = 'idle', animFlags = 49,
    },
    -- ANIMAL: Egg work — collecting eggs
    egg_work = {
        prop = 'dd_egg_basket_empty', bone = 28422,
        offset = vector3(0.0, 0.0, 0.0), rotation = vector3(0.0, 0.0, 0.0),
        animDict = 'pickup_object', animClip = 'pickup_low', animFlags = 0,
    },
    -- LIVESTOCK: Feed carry — feed sack held while walking to animal
    feed_carry = {
        prop = 'dd_feed_sack_full', bone = 57005,
        offset   = vector3(0.3600, 0.0200, -0.0500), rotation = vector3(5.0000, -83.0000, -3.0000),
        animDict = 'move_weapon@jerrycan@generic', animClip = 'idle', animFlags = 49,
    },
    -- LIVESTOCK: Feed work — pouring feed sack (same anim+particle as fertilize)
    feed_work = {
        prop = 'dd_feed_sack_full', bone = 57005,
        offset = vector3(0.0700, 0.1000, -0.2000), rotation = vector3(-169.8694, -21.2123, -33.9453),
        animDict = 'weapons@misc@jerrycan@', animClip = 'fire', animFlags = 49,
        ptfxAsset = 'scr_bike_business', ptfxEffect = 'scr_bike_coc_cocaine_scoop_pour',
        ptfxOffset = vector3(0.1000, 0.0000, 0.2500), ptfxRotation = vector3(0.0000, 0.0000, 0.0000), ptfxScale = 1.50,
    },
}

local KeyPending = {}
local KeyHeld    = {}

local function RegisterCalibKey(name, label, defaultKey)
    RegisterCommand('+propcalib_' .. name, function()
        KeyPending[name] = true
        KeyHeld[name]    = true
    end, false)
    RegisterCommand('-propcalib_' .. name, function()
        KeyHeld[name] = false
    end, false)
    RegisterKeyMapping('+propcalib_' .. name, 'PropCalib: ' .. label, 'keyboard', defaultKey)
end

RegisterCalibKey('x_pos',  'X+ (Forward)',  'NUMPAD8')
RegisterCalibKey('x_neg',  'X- (Back)',     'NUMPAD2')
RegisterCalibKey('y_pos',  'Y+ (Left)',     'NUMPAD4')
RegisterCalibKey('y_neg',  'Y- (Right)',    'NUMPAD6')
RegisterCalibKey('z_pos',  'Z+ (Up)',       'NUMPAD7')
RegisterCalibKey('z_neg',  'Z- (Down)',     'NUMPAD9')
RegisterCalibKey('rx_pos', 'RotX+ (Pitch)', 'NUMPAD1')
RegisterCalibKey('rx_neg', 'RotX- (Pitch)', 'NUMPAD3')
RegisterCalibKey('ry_pos', 'RotY+ (Roll)',  'NUMPAD0')
RegisterCalibKey('ry_neg', 'RotY- (Roll)',  'DECIMAL')
RegisterCalibKey('rz_pos', 'RotZ+ (Yaw)',   'ADD')
RegisterCalibKey('rz_neg', 'RotZ- (Yaw)',   'SUBTRACT')
RegisterCalibKey('speed_fast', 'Fast Mode (SHIFT)', 'LSHIFT')
RegisterCalibKey('speed_slow', 'Slow Mode (CTRL)',  'LCONTROL')
RegisterCalibKey('toggle_mode', 'Toggle Prop/Particle Mode (TAB)', 'TAB')

local Calib = {
    active       = false,
    targetKey    = nil,       -- 'water_carry', 'fert_work', etc.
    propEntity   = nil,
    ptfxHandle   = nil,
    animDict     = nil,
    editMode     = 'prop',    -- 'prop' | 'particle'
    offset       = vector3(0.0, 0.0, 0.0),
    rotation     = vector3(0.0, 0.0, 0.0),
    ptfxOffset   = vector3(0.0, 0.0, 0.0),
    ptfxRotation = vector3(0.0, 0.0, 0.0),
    ptfxScale    = 1.0,
    step         = DEFAULT_STEP,
    fastMode     = false,
    slowMode     = false,
    bone         = 57005,
    saved        = {},        -- [targetKey] = { offset, rotation, ptfxOffset, ptfxRotation, ptfxScale }
}

local function CalibNotify(msg, ntype)
    if Krypton and Krypton.Notify then
        Krypton.Notify(msg, ntype or 'info', 3000)
    end
    if HAS_OX_LIB then
        lib.notify({ title = 'Prop Calibration', description = msg, type = ntype or 'info', duration = 3000 })
    end
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

local function Round(val, dec)
    local mult = 10 ^ (dec or 4)
    return math.floor(val * mult + 0.5) / mult
end

local function CleanupCalib()
    if Calib.ptfxHandle and Calib.ptfxHandle ~= 0 then
        StopParticleFxLooped(Calib.ptfxHandle, false)
        Calib.ptfxHandle = nil
    end

    ClearPedTasks(PlayerPedId())

    if Calib.propEntity and DoesEntityExist(Calib.propEntity) then
        DetachEntity(Calib.propEntity, true, true)
        DeleteEntity(Calib.propEntity)
    end
    Calib.propEntity = nil
    Calib.animDict   = nil

    if HAS_OX_LIB then lib.hideTextUI() end
end

local function StopCalibration()
    CleanupCalib()
    Calib.active    = false
    Calib.targetKey = nil
    CalibNotify('Calibration kapatildi', 'info')
end

local function ReattachProp()
    if not Calib.propEntity or not DoesEntityExist(Calib.propEntity) then return end

    local ped = PlayerPedId()
    DetachEntity(Calib.propEntity, true, true)

    local off = Calib.offset
    local rot = Calib.rotation

    AttachEntityToEntity(Calib.propEntity, ped, GetPedBoneIndex(ped, Calib.bone),
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        true, true, false, true, 1, true)
end

local function RestartParticle()
    local target = CalibTargets[Calib.targetKey]
    if not target or not target.ptfxAsset or not target.ptfxEffect then return end

    if Calib.ptfxHandle and Calib.ptfxHandle ~= 0 then
        StopParticleFxLooped(Calib.ptfxHandle, false)
        Calib.ptfxHandle = nil
    end

    if LoadPtfxAsset(target.ptfxAsset) then
        UseParticleFxAssetNextCall(target.ptfxAsset)
        local ped = PlayerPedId()
        local fxOff = Calib.ptfxOffset
        local fxRot = Calib.ptfxRotation
        local fxScale = Calib.ptfxScale
        local fxBone = target.ptfxBone

        local handle
        if fxBone then
            handle = StartParticleFxLoopedOnPedBone(target.ptfxEffect,
                ped, fxOff.x, fxOff.y, fxOff.z,
                fxRot.x, fxRot.y, fxRot.z,
                GetPedBoneIndex(ped, fxBone), fxScale, false, false, false)
        else
            handle = StartParticleFxLoopedOnEntity(target.ptfxEffect,
                Calib.propEntity, fxOff.x, fxOff.y, fxOff.z,
                fxRot.x, fxRot.y, fxRot.z,
                fxScale, false, false, false)
        end
        Calib.ptfxHandle = handle
    end
end

local function StartCalibration(targetKey)
    local target = CalibTargets[targetKey]
    if not target then
        CalibNotify('Bilinmeyen hedef: ' .. tostring(targetKey), 'error')
        return
    end

    CleanupCalib()
    Wait(50)

    local savedData = Calib.saved[targetKey]
    if savedData then
        Calib.offset       = vector3(savedData.offset.x, savedData.offset.y, savedData.offset.z)
        Calib.rotation     = vector3(savedData.rotation.x, savedData.rotation.y, savedData.rotation.z)
        Calib.ptfxOffset   = savedData.ptfxOffset or (target.ptfxOffset or vector3(0, 0, 0))
        Calib.ptfxRotation = savedData.ptfxRotation or (target.ptfxRotation or vector3(0, 0, 0))
        Calib.ptfxScale    = savedData.ptfxScale or (target.ptfxScale or 1.0)
    else
        Calib.offset       = vector3(target.offset.x, target.offset.y, target.offset.z)
        Calib.rotation     = vector3(target.rotation.x, target.rotation.y, target.rotation.z)
        Calib.ptfxOffset   = target.ptfxOffset or vector3(0, 0, 0)
        Calib.ptfxRotation = target.ptfxRotation or vector3(0, 0, 0)
        Calib.ptfxScale    = target.ptfxScale or 1.0
    end
    Calib.bone = target.bone or 57005
    Calib.editMode = 'prop'

    local propName = target.prop
    local hash = LoadModel(propName)
    if not hash then
        if propName == 'prop_tool_shovel006' then
            hash = LoadModel('prop_tool_shovel5')
            propName = 'prop_tool_shovel5'
        end
        if not hash then
            CalibNotify('Prop yuklenemedi: ' .. target.prop, 'error')
            return
        end
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local obj = CreateObject(hash, pos.x, pos.y, pos.z + 2.0, false, false, false)
    if not obj or obj == 0 then
        CalibNotify('Prop olusturulamadi', 'error')
        SetModelAsNoLongerNeeded(hash)
        return
    end

    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)
    SetModelAsNoLongerNeeded(hash)

    local off = Calib.offset
    local rot = Calib.rotation
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, Calib.bone),
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        true, true, false, true, 1, true)

    Calib.propEntity = obj

    if LoadAnimDict(target.animDict) then
        TaskPlayAnim(ped, target.animDict, target.animClip, 8.0, -8.0, -1, target.animFlags or 49, 0, false, false, false)
        Calib.animDict = target.animDict
    end

    if target.ptfxAsset and target.ptfxEffect then
        if LoadPtfxAsset(target.ptfxAsset) then
            UseParticleFxAssetNextCall(target.ptfxAsset)
            local fxOff = Calib.ptfxOffset
            local fxRot = Calib.ptfxRotation
            local fxScale = Calib.ptfxScale
            local fxBone = target.ptfxBone

            local handle
            if fxBone then
                handle = StartParticleFxLoopedOnPedBone(target.ptfxEffect,
                    ped, fxOff.x, fxOff.y, fxOff.z,
                    fxRot.x, fxRot.y, fxRot.z,
                    GetPedBoneIndex(ped, fxBone), fxScale, false, false, false)
            else
                handle = StartParticleFxLoopedOnEntity(target.ptfxEffect,
                    obj, fxOff.x, fxOff.y, fxOff.z,
                    fxRot.x, fxRot.y, fxRot.z,
                    fxScale, false, false, false)
            end
            Calib.ptfxHandle = handle
        end
    end

    Calib.active    = true
    Calib.targetKey = targetKey

    if HAS_OX_LIB then
        lib.showTextUI('[WRENCH] CALIBRATION: ' .. targetKey, { position = 'top-center', icon = 'wrench' })
    end

    CalibNotify('Calibration baslatildi: ' .. targetKey, 'success')
    print(string.format('^3[PropCalib] Started: %s | prop=%s bone=%d | anim=%s/%s^7',
        targetKey, propName, Calib.bone, target.animDict, target.animClip))
end

local function ConsumeKey(name)
    if KeyPending[name] then
        KeyPending[name] = false
        return true
    end
    return false
end

local function HandleInput()
    -- Mode toggle
    if ConsumeKey('toggle_mode') then
        local target = CalibTargets[Calib.targetKey]
        if target and target.ptfxAsset then
            Calib.editMode = Calib.editMode == 'prop' and 'particle' or 'prop'
            CalibNotify('Edit Mode: ' .. (Calib.editMode == 'prop' and 'PROP' or 'PARTICLE'), 'info')
        else
            CalibNotify('Bu target particle yok, prop-only mode.', 'warning')
        end
    end

    if ConsumeKey('speed_fast') then
        Calib.fastMode = not Calib.fastMode
        if Calib.fastMode then Calib.slowMode = false end
        CalibNotify(Calib.fastMode and 'HIZLI MOD AKTIF (x10)' or 'Normal mod', 'info')
    end
    if ConsumeKey('speed_slow') then
        Calib.slowMode = not Calib.slowMode
        if Calib.slowMode then Calib.fastMode = false end
        CalibNotify(Calib.slowMode and 'YAVAS MOD AKTIF (x0.1)' or 'Normal mod', 'info')
    end

    local step = Calib.step
    if Calib.fastMode then step = step * FAST_STEP_MULT
    elseif Calib.slowMode then step = step * 0.1 end

    local changed = false

    if Calib.editMode == 'prop' then
        local ox, oy, oz = Calib.offset.x, Calib.offset.y, Calib.offset.z
        local rx, ry, rz = Calib.rotation.x, Calib.rotation.y, Calib.rotation.z

        if ConsumeKey('x_pos') then ox = ox + step; changed = true end
        if ConsumeKey('x_neg') then ox = ox - step; changed = true end
        if ConsumeKey('y_pos') then oy = oy + step; changed = true end
        if ConsumeKey('y_neg') then oy = oy - step; changed = true end
        if ConsumeKey('z_pos') then oz = oz + step; changed = true end
        if ConsumeKey('z_neg') then oz = oz - step; changed = true end

        local rStep = step * ROT_MULT
        if ConsumeKey('rx_pos') then rx = rx + rStep; changed = true end
        if ConsumeKey('rx_neg') then rx = rx - rStep; changed = true end
        if ConsumeKey('ry_pos') then ry = ry + rStep; changed = true end
        if ConsumeKey('ry_neg') then ry = ry - rStep; changed = true end
        if ConsumeKey('rz_pos') then rz = rz + rStep; changed = true end
        if ConsumeKey('rz_neg') then rz = rz - rStep; changed = true end

        if changed then
            Calib.offset   = vector3(ox, oy, oz)
            Calib.rotation = vector3(rx, ry, rz)
            ReattachProp()
        end
    else
        local px, py, pz = Calib.ptfxOffset.x, Calib.ptfxOffset.y, Calib.ptfxOffset.z
        local prx, pry, prz = Calib.ptfxRotation.x, Calib.ptfxRotation.y, Calib.ptfxRotation.z

        if ConsumeKey('x_pos') then px = px + step; changed = true end
        if ConsumeKey('x_neg') then px = px - step; changed = true end
        if ConsumeKey('y_pos') then py = py + step; changed = true end
        if ConsumeKey('y_neg') then py = py - step; changed = true end
        if ConsumeKey('z_pos') then pz = pz + step; changed = true end
        if ConsumeKey('z_neg') then pz = pz - step; changed = true end

        local rStep = step * ROT_MULT
        if ConsumeKey('rx_pos') then prx = prx + rStep; changed = true end
        if ConsumeKey('rx_neg') then prx = prx - rStep; changed = true end
        if ConsumeKey('ry_pos') then pry = pry + rStep; changed = true end
        if ConsumeKey('ry_neg') then pry = pry - rStep; changed = true end
        if ConsumeKey('rz_pos') then
            -- RZ+ on particle = increase scale
            Calib.ptfxScale = Calib.ptfxScale + (step * 10)
            changed = true
        end
        if ConsumeKey('rz_neg') then
            -- RZ- on particle = decrease scale
            Calib.ptfxScale = math.max(0.1, Calib.ptfxScale - (step * 10))
            changed = true
        end

        if changed then
            Calib.ptfxOffset   = vector3(px, py, pz)
            Calib.ptfxRotation = vector3(prx, pry, prz)
            RestartParticle()
        end
    end
end

local function DrawLine2D(x, y, text, r, g, b)
    SetTextFont(0)
    SetTextProportional(true)
    SetTextScale(0.0, 0.30)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextDropShadow()
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

local function DrawHUD()
    local target = CalibTargets[Calib.targetKey]
    if not target then return end

    local off = Calib.offset
    local rot = Calib.rotation
    local poff = Calib.ptfxOffset
    local prot = Calib.ptfxRotation
    local x, y, lineH = 0.01, 0.30, 0.022

    local speedLabel = ''
    if Calib.fastMode then speedLabel = ' ~r~[HIZLI x10]'
    elseif Calib.slowMode then speedLabel = ' ~b~[YAVAS x0.1]' end

    local modeLabel = Calib.editMode == 'prop' and '~g~[PROP]' or '~p~[PARTICLE]'
    local hasParticle = target.ptfxAsset and true or false

    local lines = {
        { t = '~y~=== PROP CALIBRATION ===',                                       r = 255, g = 255, b = 50  },
        { t = '~w~Target: ~g~' .. Calib.targetKey .. '  ~w~Mode: ' .. modeLabel .. (hasParticle and ' ~w~(TAB)' or ''), r = 255, g = 255, b = 255 },
        { t = '~w~Prop: ~g~' .. target.prop .. '  ~w~Bone: ~g~' .. Calib.bone,    r = 255, g = 255, b = 255 },
        { t = '~w~Anim: ~g~' .. target.animDict .. ' / ' .. target.animClip,       r = 255, g = 255, b = 255 },
        { t = ' ',                                                                  r = 255, g = 255, b = 255 },
    }

    if Calib.editMode == 'prop' then
        lines[#lines + 1] = { t = '~w~Prop Offset  X: ~b~' .. Round(off.x) .. '  ~w~Y: ~b~' .. Round(off.y) .. '  ~w~Z: ~b~' .. Round(off.z), r = 255, g = 255, b = 255 }
        lines[#lines + 1] = { t = '~w~Prop Rot     X: ~b~' .. Round(rot.x) .. '  ~w~Y: ~b~' .. Round(rot.y) .. '  ~w~Z: ~b~' .. Round(rot.z), r = 255, g = 255, b = 255 }
    else
        lines[#lines + 1] = { t = '~w~Ptfx Offset  X: ~p~' .. Round(poff.x) .. '  ~w~Y: ~p~' .. Round(poff.y) .. '  ~w~Z: ~p~' .. Round(poff.z), r = 255, g = 255, b = 255 }
        lines[#lines + 1] = { t = '~w~Ptfx Rot     X: ~p~' .. Round(prot.x) .. '  ~w~Y: ~p~' .. Round(prot.y) .. '  ~w~Scale: ~p~' .. Round(Calib.ptfxScale, 2), r = 255, g = 255, b = 255 }
    end

    lines[#lines + 1] = { t = '~w~Step: ~y~' .. Calib.step .. speedLabel, r = 255, g = 255, b = 255 }
    lines[#lines + 1] = { t = ' ', r = 255, g = 255, b = 255 }
    lines[#lines + 1] = { t = '~y~--- NUMPAD CONTROLS ---', r = 255, g = 200, b = 50 }

    if Calib.editMode == 'prop' then
        lines[#lines + 1] = { t = '~w~8/2 = X  |  4/6 = Y  |  7/9 = Z', r = 200, g = 200, b = 200 }
        lines[#lines + 1] = { t = '~w~1/3 = RotX  |  0/. = RotY  |  +/- = RotZ', r = 200, g = 200, b = 200 }
    else
        lines[#lines + 1] = { t = '~w~8/2 = X  |  4/6 = Y  |  7/9 = Z', r = 200, g = 200, b = 200 }
        lines[#lines + 1] = { t = '~w~1/3 = RotX  |  0/. = RotY  |  +/- = SCALE', r = 200, g = 200, b = 200 }
    end

    lines[#lines + 1] = { t = '~w~SHIFT = Hizli  |  CTRL = Yavas  |  TAB = Mode', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = ' ', r = 255, g = 255, b = 255 }
    lines[#lines + 1] = { t = '~y~--- COMMANDS ---', r = 255, g = 200, b = 50 }
    lines[#lines + 1] = { t = '~w~/farmcalibsave = Kaydet (F8)', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = '~w~/farmcalibsaveall = Tum sonuclari yaz', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = '~w~/farmcalibreset = Offset sifirla', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = '~w~/farmcalibstep 0.01 = Step ayarla', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = '~w~/farmcaliboff = Kapat', r = 200, g = 200, b = 200 }
    lines[#lines + 1] = { t = '~w~Mod degistir: /farmwater1 debug, /farmfert2 debug ...', r = 200, g = 200, b = 200 }

    for i, line in ipairs(lines) do
        DrawLine2D(x, y + (i - 1) * lineH, line.t, line.r, line.g, line.b)
    end
end

CreateThread(function()
    while true do
        if Calib.active then
            -- Re-loop animation if it ended
            local ped = PlayerPedId()
            local target = CalibTargets[Calib.targetKey]
            if target and Calib.animDict and not IsEntityPlayingAnim(ped, Calib.animDict, target.animClip, 3) then
                if LoadAnimDict(Calib.animDict) then
                    TaskPlayAnim(ped, Calib.animDict, target.animClip, 8.0, -8.0, -1, target.animFlags or 49, 0, false, false, false)
                end
            end

            -- Disable numpad camera controls
            for i = 80, 85 do
                DisableControlAction(0, i, true)
            end

            HandleInput()
            DrawHUD()
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

local function SaveCurrent()
    if not Calib.active or not Calib.targetKey then
        CalibNotify('Aktif calibration yok.', 'error')
        return
    end

    local target = CalibTargets[Calib.targetKey]
    local off = Calib.offset
    local rot = Calib.rotation

    Calib.saved[Calib.targetKey] = {
        offset       = vector3(off.x, off.y, off.z),
        rotation     = vector3(rot.x, rot.y, rot.z),
        ptfxOffset   = vector3(Calib.ptfxOffset.x, Calib.ptfxOffset.y, Calib.ptfxOffset.z),
        ptfxRotation = vector3(Calib.ptfxRotation.x, Calib.ptfxRotation.y, Calib.ptfxRotation.z),
        ptfxScale    = Calib.ptfxScale,
    }

    local lines = {
        '^2═══════════════════════════════════════^7',
        '^2[PropCalib] SAVED: ' .. Calib.targetKey .. '^7',
        '^2═══════════════════════════════════════^7',
        string.format("    -- %s", Calib.targetKey),
        string.format("    prop     = '%s',", target.prop),
        string.format("    bone     = %d,  -- %s",
            Calib.bone, Calib.bone == 57005 and 'SKEL_R_Hand' or tostring(Calib.bone)),
        string.format("    offset   = vector3(%.4f, %.4f, %.4f),", off.x, off.y, off.z),
        string.format("    rotation = vector3(%.4f, %.4f, %.4f),", rot.x, rot.y, rot.z),
        string.format("    animDict = '%s',", target.animDict),
        string.format("    animClip = '%s',", target.animClip),
    }

    if target.ptfxAsset then
        local po = Calib.ptfxOffset
        local pr = Calib.ptfxRotation
        lines[#lines + 1] = string.format("    ptfxAsset    = '%s',", target.ptfxAsset)
        lines[#lines + 1] = string.format("    ptfxEffect   = '%s',", target.ptfxEffect)
        lines[#lines + 1] = string.format("    ptfxOffset   = vector3(%.4f, %.4f, %.4f),", po.x, po.y, po.z)
        lines[#lines + 1] = string.format("    ptfxRotation = vector3(%.4f, %.4f, %.4f),", pr.x, pr.y, pr.z)
        lines[#lines + 1] = string.format("    ptfxScale    = %.2f,", Calib.ptfxScale)
        if target.ptfxBone then
            lines[#lines + 1] = string.format("    ptfxBone     = %d,", target.ptfxBone)
        end
    end

    lines[#lines + 1] = '^2═══════════════════════════════════════^7'

    for _, l in ipairs(lines) do print(l) end
    CalibNotify(Calib.targetKey .. ' kaydedildi! F8 kontrol et.', 'success')
end

local function SaveAll()
    local count = 0
    for _ in pairs(Calib.saved) do count = count + 1 end

    if count == 0 then
        CalibNotify('Henuz kaydedilmis sonuc yok. /farmcalibsave kullan.', 'warning')
        return
    end

    print('^2═══════════════════════════════════════════════════^7')
    print('^2[PropCalib] ALL SAVED RESULTS^7')
    print('^2═══════════════════════════════════════════════════^7')

    local order = { 'water_carry', 'water_work', 'fert_carry', 'fert_work', 'harvest_carry', 'harvest_work', 'milk_carry', 'milk_work', 'egg_carry', 'egg_work', 'feed_carry', 'feed_work' }
    for _, key in ipairs(order) do
        local data = Calib.saved[key]
        if data then
            local target = CalibTargets[key]
            print(string.format("-- %s", key))
            print(string.format("{"))
            print(string.format("    prop = '%s', bone = %d,", target.prop, target.bone or 57005))
            print(string.format("    offset   = vector3(%.4f, %.4f, %.4f),", data.offset.x, data.offset.y, data.offset.z))
            print(string.format("    rotation = vector3(%.4f, %.4f, %.4f),", data.rotation.x, data.rotation.y, data.rotation.z))
            print(string.format("    animDict = '%s', animClip = '%s', animFlags = %d,",
                target.animDict, target.animClip, target.animFlags or 49))

            if target.ptfxAsset then
                local po = data.ptfxOffset or target.ptfxOffset or vector3(0, 0, 0)
                local pr = data.ptfxRotation or target.ptfxRotation or vector3(0, 0, 0)
                local ps = data.ptfxScale or target.ptfxScale or 1.0
                print(string.format("    ptfxAsset = '%s', ptfxEffect = '%s',", target.ptfxAsset, target.ptfxEffect))
                print(string.format("    ptfxOffset = vector3(%.4f, %.4f, %.4f), ptfxRotation = vector3(%.4f, %.4f, %.4f),",
                    po.x, po.y, po.z, pr.x, pr.y, pr.z))
                print(string.format("    ptfxScale = %.2f,", ps))
                if target.ptfxBone then
                    print(string.format("    ptfxBone = %d,", target.ptfxBone))
                end
            end

            print(string.format("},"))
            print('')
        end
    end

    print('^2═══════════════════════════════════════════════════^7')
    CalibNotify(count .. ' sonuc F8 konsoluna yazildi!', 'success')
end

function StartPropCalibration(targetKey)
    StartCalibration(targetKey)
end

function IsPropCalibrationActive()
    return Calib.active
end

RegisterCommand('farmcalibsave', function()
    SaveCurrent()
end, false)

RegisterCommand('farmcalibsaveall', function()
    SaveAll()
end, false)

RegisterCommand('farmcaliboff', function()
    StopCalibration()
end, false)

RegisterCommand('farmcalibreset', function()
    if not Calib.active or not Calib.targetKey then return end
    local target = CalibTargets[Calib.targetKey]
    Calib.offset       = vector3(target.offset.x, target.offset.y, target.offset.z)
    Calib.rotation     = vector3(target.rotation.x, target.rotation.y, target.rotation.z)
    Calib.ptfxOffset   = target.ptfxOffset or vector3(0, 0, 0)
    Calib.ptfxRotation = target.ptfxRotation or vector3(0, 0, 0)
    Calib.ptfxScale    = target.ptfxScale or 1.0
    ReattachProp()
    RestartParticle()
    CalibNotify('Tum degerler varsayilana sifirlandi.', 'info')
end, false)

RegisterCommand('farmcalibstep', function(_, args)
    local val = tonumber(args[1])
    if not val or val <= 0 then
        CalibNotify('Kullanim: /farmcalibstep <sayi>  ornek: 0.01', 'warning')
        return
    end
    Calib.step = val
    CalibNotify('Step: ' .. val, 'info')
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CleanupCalib()
end)

print('^3[PropCalib] Hand-held prop calibration v3 loaded.^7')
print('^3[PropCalib] Usage: /farmwater1 debug, /farmwater2 debug, /farmfert1 debug, etc.^7')
print('^3[PropCalib] Commands: /farmcalibsave /farmcalibsaveall /farmcaliboff /farmcalibreset /farmcalibstep^7')
