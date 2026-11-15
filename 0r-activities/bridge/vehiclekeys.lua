VehicleKeyBridge = {}

local function plateOf(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    if type(plate) ~= 'string' then return nil end
    plate = plate:gsub('%s+$', '')
    return plate ~= '' and plate or nil
end

-- DaddyRP: aktivite araclarini (dalis teknesi vb.) isaretle. Anahtar sadece aracı
-- cikaran oyuncuya veriliyordu; sira baskasina gecince ya da teknenin dumenine
-- baska biri oturunca wais-vehiclekey motoru kapatip araci surulemez yapiyordu
-- (tik tik tik, calismiyor). Isaretli araca kim surucu koltuguna oturursa ona da
-- anahtar verilir. Decor ag uzerinden diger oyunculara da yayilir.
local ACTIVITY_DECOR = '0r_act_vehicle'
if not DecorIsRegisteredAsType(ACTIVITY_DECOR, 2) then DecorRegister(ACTIVITY_DECOR, 2) end
local localActivityVehicles = {}

function VehicleKeyBridge.Mark(vehicle)
    if type(vehicle) ~= 'number' or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    localActivityVehicles[vehicle] = true
    if not DecorExistOn(vehicle, ACTIVITY_DECOR) then DecorSetBool(vehicle, ACTIVITY_DECOR, true) end
end

local function isActivityVehicle(vehicle)
    if localActivityVehicles[vehicle] then return true end
    return DecorExistOn(vehicle, ACTIVITY_DECOR) and DecorGetBool(vehicle, ACTIVITY_DECOR)
end

function VehicleKeyBridge.Give(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    VehicleKeyBridge.Mark(vehicle)
    local plate = plateOf(vehicle)
    if not plate then return false end
    -- DaddyRP: wais-vehiclekey (listede yok, qb olaylarini dinler)
    if GetResourceState('wais-vehiclekey') == 'started' then
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        return true
    end
    local provider = ActivityIntegration.VehicleKeyProvider()
    if provider == 'qbx_vehiclekeys' or provider == 'qb-vehiclekeys' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        return true
    end
    if provider == 'qs-vehiclekeys' then
        return pcall(function() exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true) end)
    end
    if provider == 'Renewed-Vehiclekeys' then
        return pcall(function() exports['Renewed-Vehiclekeys']:addKey(plate) end)
    end
    if provider == 'MrNewbVehicleKeys' then
        return pcall(function() exports.MrNewbVehicleKeys:GiveKeysByPlate(plate) end)
    end
    if provider == 'wasabi_carlock' then
        return pcall(function() exports.wasabi_carlock:GiveKey(plate) end)
    end
    if provider == 'mk_vehiclekeys' then
        return pcall(function() exports['mk_vehiclekeys']:AddKey(vehicle) end)
    end
    if provider == 'mVehicle' then
        return pcall(function() exports.mVehicle:AddTemporalVehicleClient(vehicle) end)
    end
    if provider == 't1ger_keys' then
        return pcall(function() exports['t1ger_keys']:GiveTemporaryKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), '') end)
    end
    if provider == 'F_RealCarKeysSystem' then
        TriggerServerEvent('F_RealCarKeysSystem:generateVehicleKeys', plate)
        return true
    end
    if provider == 'jaksams_VehiclesKeys' then
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
        return true
    end
    if provider == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', plate)
        return true
    end
    if provider == 'okokGarage' then
        TriggerServerEvent('okokGarage:GiveKeys', plate)
        return true
    end
    return false
end

function VehicleKeyBridge.Remove(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local plate = plateOf(vehicle)
    if not plate then return false end
    -- DaddyRP: wais-vehiclekey
    if GetResourceState('wais-vehiclekey') == 'started' then
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
        return true
    end
    local provider = ActivityIntegration.VehicleKeyProvider()
    if provider == 'qbx_vehiclekeys' or provider == 'qb-vehiclekeys' then
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
        return true
    end
    if provider == 'qs-vehiclekeys' then
        return pcall(function() exports['qs-vehiclekeys']:RemoveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))) end)
    end
    if provider == 'Renewed-Vehiclekeys' then
        return pcall(function() exports['Renewed-Vehiclekeys']:removeKey(plate) end)
    end
    if provider == 'MrNewbVehicleKeys' then
        return pcall(function() exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate) end)
    end
    if provider == 'wasabi_carlock' then
        return pcall(function() exports.wasabi_carlock:RemoveKey(plate) end)
    end
    if provider == 'mk_vehiclekeys' then
        return pcall(function() exports['mk_vehiclekeys']:RemoveKey(vehicle) end)
    end
    if provider == 'F_RealCarKeysSystem' then
        TriggerServerEvent('F_RealCarKeysSystem:removeVehicleKeysByPlate', plate)
        return true
    end
    if provider == 'jaksams_VehiclesKeys' then
        TriggerServerEvent('vehicles_keys:selfRemoveKeys', plate)
        return true
    end
    if provider == 'okokGarage' then
        TriggerServerEvent('okokGarage:RemoveKeys', plate)
        return true
    end
    return false
end

-- DaddyRP: aktivite aracinin surucu koltuguna oturan (ya da binmeye calisan) herkese
-- anahtar ver; surucu koltugunda motoru tekrar calistirilabilir yap ve inince motor
-- kapanmasin (denizin ortasinda inip binince tekne stop etmesin).
local keyedPlates = {}

local function ensureKeys(vehicle)
    local plate = plateOf(vehicle)
    if not plate or keyedPlates[vehicle] == plate then return end
    keyedPlates[vehicle] = plate
    VehicleKeyBridge.Give(vehicle)
end

local function wakeVehicle(vehicle)
    -- Anahtarsiz bir surucu oturduysa wais motoru autostart kapali sekilde
    -- kapatip araci surulemez birakir; anahtar sahibi geri oturunca wais bunu
    -- geri almaz. Birkac deneme: surucu olunca ag sahipligi bize gecer.
    CreateThread(function()
        for _ = 1, 10 do
            if not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end
            SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
            SetVehicleUndriveable(vehicle, false)
            if GetVehicleEngineHealth(vehicle) > 0.0 then
                SetVehicleEngineOn(vehicle, true, false, true)
            end
            if IsThisModelABoat(GetEntityModel(vehicle)) and IsBoatAnchored and IsBoatAnchored(vehicle) then
                SetBoatAnchor(vehicle, false)
            end
            if NetworkHasControlOfEntity(vehicle) and IsVehicleEngineOn(vehicle) then return end
            Wait(200)
        end
    end)
end

CreateThread(function()
    local lastDriven = 0
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        local entering = GetVehiclePedIsTryingToEnter(ped)
        if entering ~= 0 and isActivityVehicle(entering) then
            sleep = 100
            ensureKeys(entering)
        end

        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and isActivityVehicle(vehicle) then
            sleep = 250
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                ensureKeys(vehicle)
                if lastDriven ~= vehicle then
                    lastDriven = vehicle
                    wakeVehicle(vehicle)
                end
            elseif lastDriven == vehicle then
                lastDriven = 0
            end
        elseif lastDriven ~= 0 then
            -- Suruculukten indik: tekne motoru acik kalsin.
            if DoesEntityExist(lastDriven) then SetVehicleKeepEngineOnWhenAbandoned(lastDriven, true) end
            lastDriven = 0
        end

        for veh in pairs(keyedPlates) do
            if not DoesEntityExist(veh) then keyedPlates[veh] = nil end
        end
        for veh in pairs(localActivityVehicles) do
            if not DoesEntityExist(veh) then localActivityVehicles[veh] = nil end
        end
        Wait(sleep)
    end
end)
