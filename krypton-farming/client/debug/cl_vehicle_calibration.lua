-- DaddyRP: debug only, players never see these commands
if not Config.Debug then return end
-- /farmvehprop          → editörü başlat / kapat (toggle)
-- /farmvehprop next     → sonraki prop (mevcut yerinde kalır, döngüsel)
-- /farmvehprop save     → mevcut prop config satırını F8/console'a yazdır
-- /farmvehprop exit     → editörü kapat + tüm editor proplarını sil
-- Numpad 8/2/4/6 (numlock-off = ok tuşları) → X/Y pozisyon
-- Numpad 7/9 → Z+/Z-
-- Numpad 1/3/0/./+/- → Rotasyon
-- LSHIFT = 10x hız | LCONTROL = 0.1x hız
if Config.Debug then

local function VehFmtVec(v)
    return string.format('vector3(%.4f, %.4f, %.4f)', v.x or 0.0, v.y or 0.0, v.z or 0.0)
end

-- Key durum tabloları (aynı pattern cl_prop_calibration.lua ile aynı)
local VehKeyPending = {}
local VehKeyHeld    = {}

local function RegisterVehCalibKey(name, label, defaultKey)
    RegisterCommand('+vehprop_' .. name, function()
        VehKeyPending[name] = true
        VehKeyHeld[name]    = true
    end, false)
    RegisterCommand('-vehprop_' .. name, function()
        VehKeyHeld[name] = false
    end, false)
    RegisterKeyMapping('+vehprop_' .. name, 'VehProp: ' .. label, 'keyboard', defaultKey)
end

-- Pozisyon  (NUMPAD8/2/4/6 = numlock-off durumunda ok tuşları)
RegisterVehCalibKey('x_pos', 'X+ (ileri)',    'NUMPAD8')
RegisterVehCalibKey('x_neg', 'X- (geri)',     'NUMPAD2')
RegisterVehCalibKey('y_pos', 'Y+ (sol)',      'NUMPAD4')
RegisterVehCalibKey('y_neg', 'Y- (sag)',      'NUMPAD6')
RegisterVehCalibKey('z_pos', 'Z+ (yukari)',   'NUMPAD7')
RegisterVehCalibKey('z_neg', 'Z- (asagi)',    'NUMPAD9')
RegisterVehCalibKey('rx_pos', 'RotX+',        'NUMPAD1')
RegisterVehCalibKey('rx_neg', 'RotX-',        'NUMPAD3')
RegisterVehCalibKey('ry_pos', 'RotY+',        'NUMPAD0')
RegisterVehCalibKey('ry_neg', 'RotY-',        'DECIMAL')
RegisterVehCalibKey('rz_pos', 'RotZ+ (Yaw)',  'ADD')
RegisterVehCalibKey('rz_neg', 'RotZ- (Yaw)',  'SUBTRACT')
RegisterVehCalibKey('fast', '10x Hiz (SHIFT)',   'LSHIFT')
RegisterVehCalibKey('slow', '0.1x Hiz (CTRL)',   'LCONTROL')

local function ConsumeVehKey(name)
    if VehKeyPending[name] then
        VehKeyPending[name] = false
        return true
    end
    return false
end

local VehCalib = {
    active       = false,
    vehicle      = nil,
    jobType      = nil,
    propList     = {},    -- [i] = { label, config = ref to PROP_CONFIGS, entity = nil }
    currentIdx   = 1,
    activeEntity = nil,   -- şu an düzenlenen editor prop entity'si
    offset       = vector3(0, 0, 0),
    rotation     = vector3(0, 0, 0),
}

local function BuildVehPropList(jobType)
    local list = {}
    local jcfg = PROP_CONFIGS[jobType]
    if not jcfg then return list end

    if jcfg.fixed then
        for i, cfg in ipairs(jcfg.fixed) do
            list[#list+1] = { label = 'fixed[' .. i .. '] ' .. cfg.model, config = cfg, entity = nil }
        end
    end

    if jcfg.interactive then
        local keys = {}
        for k in pairs(jcfg.interactive) do keys[#keys+1] = k end
        table.sort(keys)
        for _, k in ipairs(keys) do
            local cfg = jcfg.interactive[k]
            list[#list+1] = { label = 'interactive.' .. k .. ' ' .. cfg.model, config = cfg, entity = nil }
        end
    end

    return list
end

local function VehCalibSpawnCurrent()
    if VehCalib.activeEntity and DoesEntityExist(VehCalib.activeEntity) then
        DeleteEntity(VehCalib.activeEntity)
        VehCalib.activeEntity = nil
    end

    local item = VehCalib.propList[VehCalib.currentIdx]
    if not item then return end
    local cfg = item.config

    VehCalib.offset   = vector3(cfg.offset.x,   cfg.offset.y,   cfg.offset.z)
    VehCalib.rotation = vector3(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)

    local hash = GetHashKey(cfg.model)
    if not IsModelValid(hash) then
        Krypton.Notify('[VehProp] Geçersiz model: ' .. cfg.model, 'error')
        return
    end
    RequestModel(hash)
    local t = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > t then
            Krypton.Notify('[VehProp] Model yüklenemedi: ' .. cfg.model, 'error')
            return
        end
    end

    local vehPos = GetEntityCoords(VehCalib.vehicle)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local obj = CreateObject(hash, vehPos.x, vehPos.y, vehPos.z + 3.0, false, false, false)
    SetModelAsNoLongerNeeded(hash)

    if not obj or obj == 0 then
        Krypton.Notify('[VehProp] Prop oluşturulamadı', 'error')
        return
    end

    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)
    SetEntityAlpha(obj, 210, false)  -- hafif şeffaf = editor prop olduğunu belirtir

    local boneName  = cfg.bone or 'bodyshell'
    local boneIndex = GetEntityBoneIndexByName(VehCalib.vehicle, boneName)
    local off = VehCalib.offset
    local rot = VehCalib.rotation

    AttachEntityToEntity(obj, VehCalib.vehicle, boneIndex,
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        false, true, false, false, 2, true)

    VehCalib.activeEntity = obj
    item.entity = obj  -- exit'te temizlemek için referansı sakla

    print(string.format('^3[VehProp] ^7Editing [%d/%d]: %s', VehCalib.currentIdx, #VehCalib.propList, item.label))
    print(string.format('^3[VehProp] ^7offset=%s  rotation=%s', VehFmtVec(off), VehFmtVec(rot)))
    Krypton.Notify('[VehProp] ' .. VehCalib.currentIdx .. '/' .. #VehCalib.propList .. ': ' .. item.label, 'info')
end

local function VehCalibReattach()
    if not VehCalib.activeEntity or not DoesEntityExist(VehCalib.activeEntity) then return end

    local item = VehCalib.propList[VehCalib.currentIdx]
    local cfg  = item and item.config
    if not cfg then return end

    cfg.offset   = VehCalib.offset
    cfg.rotation = VehCalib.rotation

    DetachEntity(VehCalib.activeEntity, false, false)

    local boneName  = cfg.bone or 'bodyshell'
    local boneIndex = GetEntityBoneIndexByName(VehCalib.vehicle, boneName)
    local off = VehCalib.offset
    local rot = VehCalib.rotation

    AttachEntityToEntity(VehCalib.activeEntity, VehCalib.vehicle, boneIndex,
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        false, true, false, false, 2, true)
end

local function VehCalibCleanupAll()
    for _, item in ipairs(VehCalib.propList) do
        if item.entity and DoesEntityExist(item.entity) then
            DeleteEntity(item.entity)
        end
        item.entity = nil
    end
    VehCalib.activeEntity = nil
end

local function VehCalibSave()
    local item = VehCalib.propList[VehCalib.currentIdx]
    if not item then return end

    item.config.offset   = VehCalib.offset
    item.config.rotation = VehCalib.rotation

    local cfg  = item.config
    local line = string.format("{ model = '%s', bone = '%s', offset = %s, rotation = %s },",
        cfg.model, cfg.bone or 'bodyshell',
        VehFmtVec(cfg.offset), VehFmtVec(cfg.rotation))

    print('^2[VehProp SAVE] ' .. item.label .. '^7')
    print('^2[VehProp SAVE] ^7' .. line)
    Krypton.Notify('[VehProp] Kaydedildi! F8\'e bakın.', 'success')
end

local function VehCalibStop()
    VehCalibCleanupAll()
    VehCalib.active   = false
    VehCalib.vehicle  = nil
    VehCalib.propList = {}
    Krypton.Notify('[VehProp] Editor kapatıldı.', 'info')
    print('^3[VehProp] Editor kapatildi.^7')
end

local function FindNearbyBodhi2(radius)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local searchRadius = radius or 8.0
    local wantedHash = GetHashKey(Config.NPC[1] and Config.NPC[1].vehicle and Config.NPC[1].vehicle.model or 'bodhi2')

    local inVeh = GetVehiclePedIsIn(ped, false)
    if inVeh and inVeh ~= 0 and DoesEntityExist(inVeh) and GetEntityModel(inVeh) == wantedHash then
        return inVeh
    end

    local closest = GetClosestVehicle(pedCoords.x, pedCoords.y, pedCoords.z, searchRadius, 0, 71)
    if closest and closest ~= 0 and DoesEntityExist(closest) and GetEntityModel(closest) == wantedHash then
        return closest
    end

    return nil
end

CreateThread(function()
    while true do
        if not VehCalib.active then
            Wait(300)
        else
            Wait(0)

            if not VehCalib.vehicle or not DoesEntityExist(VehCalib.vehicle) then
                VehCalibStop()
            end

            local step = 0.01
            if VehKeyHeld['fast'] then step = step * 10 end
            if VehKeyHeld['slow'] then step = step * 0.1 end
            local rStep = step * 100.0

            local ox, oy, oz = VehCalib.offset.x,   VehCalib.offset.y,   VehCalib.offset.z
            local rx, ry, rz = VehCalib.rotation.x, VehCalib.rotation.y, VehCalib.rotation.z
            local changed = false

            if ConsumeVehKey('x_pos') then ox = ox + step;  changed = true end
            if ConsumeVehKey('x_neg') then ox = ox - step;  changed = true end
            if ConsumeVehKey('y_pos') then oy = oy + step;  changed = true end
            if ConsumeVehKey('y_neg') then oy = oy - step;  changed = true end
            if ConsumeVehKey('z_pos') then oz = oz + step;  changed = true end
            if ConsumeVehKey('z_neg') then oz = oz - step;  changed = true end

            if ConsumeVehKey('rx_pos') then rx = rx + rStep; changed = true end
            if ConsumeVehKey('rx_neg') then rx = rx - rStep; changed = true end
            if ConsumeVehKey('ry_pos') then ry = ry + rStep; changed = true end
            if ConsumeVehKey('ry_neg') then ry = ry - rStep; changed = true end
            if ConsumeVehKey('rz_pos') then rz = rz + rStep; changed = true end
            if ConsumeVehKey('rz_neg') then rz = rz - rStep; changed = true end

            if changed then
                VehCalib.offset   = vector3(ox, oy, oz)
                VehCalib.rotation = vector3(rx, ry, rz)
                VehCalibReattach()
            end
        end
    end
end)

RegisterCommand('farmvehprop', function(_, args)
    local sub = (args[1] or ''):lower()

    -- next: mevcut prop yerinde durur (activeEntity nil'e çekilir, entity silinmez),
    --       sonraki index için yeni editor prop spawn edilir
    if sub == 'next' then
        if not VehCalib.active then
            Krypton.Notify('[VehProp] Editor aktif değil', 'error')
            return
        end
        local cur = VehCalib.propList[VehCalib.currentIdx]
        if cur then
            cur.config.offset   = VehCalib.offset
            cur.config.rotation = VehCalib.rotation
        end
        VehCalib.activeEntity = nil  -- orphan: yerinde kalsın, sadece kontrolü bırak
        VehCalib.currentIdx   = (VehCalib.currentIdx % #VehCalib.propList) + 1
        VehCalibSpawnCurrent()
        return
    end

    if sub == 'save' then
        if not VehCalib.active then
            Krypton.Notify('[VehProp] Editor aktif değil', 'error')
            return
        end
        VehCalibSave()
        return
    end

    if sub == 'exit' or sub == 'stop' then
        if VehCalib.active then VehCalibStop() end
        return
    end

    if VehCalib.active then
        VehCalibStop()
        return
    end

    local veh = VehicleState.entity
    if not veh or not DoesEntityExist(veh) then
        veh = FindNearbyBodhi2(10.0)
    end
    if not veh or not DoesEntityExist(veh) then
        Krypton.Notify('[VehProp] Önce iş aracını (bodhi2) spawn et!', 'error')
        return
    end

    local jobType = VehicleState.jobType or 'livestock'
    local pList   = BuildVehPropList(jobType)

    if #pList == 0 then
        Krypton.Notify('[VehProp] Bu iş tipi için prop yok: ' .. jobType, 'error')
        return
    end

    VehCalib.vehicle    = veh
    VehCalib.jobType    = jobType
    VehCalib.propList   = pList
    VehCalib.currentIdx = 1
    VehCalib.active     = true

    VehCalibSpawnCurrent()

    print(string.format('^3[VehProp] Editor başladı. %d prop | jobType=%s^7', #pList, jobType))
    print('^3[VehProp] ^7NUMPAD 8/2/4/6=pozisyon  7/9=Z  1/3/0/./+/-=rotasyon  SHIFT=10x  CTRL=0.1x')
    print('^3[VehProp] ^7/farmvehprop next=sonraki  /farmvehprop save=kaydet  /farmvehprop exit=kapat')
    Krypton.Notify('[VehProp] Editor başladı! ' .. #pList .. ' prop. NUMPAD=hareket', 'success')
end, false)

end -- if Config.Debug
