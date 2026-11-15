Utils = {}

local isServer = IsDuplicityVersion()

-- L('key') or L('key', arg) for %s placeholders; a missing key falls back to English.
function L(key, ...)
    local str = (Locales[Config.Language] or {})[key] or (Locales['en'] or {})[key]
    if not str then return key end
    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, str, ...)
        if ok then return formatted end
    end
    return str
end

-- Model hash -> ambulance config, built once instead of per-file
Utils.AmbulanceHashes = {}

for i = 1, #Config.Ambulance.vehicles do
    local entry = Config.Ambulance.vehicles[i]
    Utils.AmbulanceHashes[joaat(entry.model)] = entry
end

if isServer then
    function Utils.IsAmbulanceJob(source)
        local job = Bridge.GetJob(source)
        if not job or not Bridge.IsJobAllowed(job.name) then return false end
        if Config.RequireOnDuty and not job.onDuty then return false end
        return true
    end

    function Utils.Notify(source, titleKey, messageKey, nType, ...)
        TriggerClientEvent('ox_lib:notify', source, {
            title = L(titleKey),
            description = L(messageKey, ...),
            type = nType or 'inform',
        })
    end

    -- Which denial message applies: wrong job entirely, or right job but off duty
    function Utils.JobDenyReason(source)
        local job = Bridge.GetJob(source)
        if not job or not Bridge.IsJobAllowed(job.name) then return 'not_ems' end
        return 'not_on_duty'
    end

    return
end

local testMode = false

function Utils.Notify(titleKey, messageKey, nType, ...)
    lib.notify({
        title = L(titleKey),
        description = L(messageKey, ...),
        type = nType or 'inform',
    })
end

-- Bounded: a dictionary that never loads must not hang the caller (some run inside the sync loop).
function Utils.LoadAnim(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local deadline = GetGameTimer() + 2000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > deadline then return false end
        Wait(0)
    end
    return true
end

function Utils.RequestControl(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if NetworkHasControlOfEntity(entity) then return true end

    local timeout = GetGameTimer() + 2000
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end
    return NetworkHasControlOfEntity(entity)
end

function Utils.GetAmbulanceConfig(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil end
    -- ox_target asks about whatever it aims at; reading the model of a non-vehicle (map object) throws in the native.
    if GetEntityType(entity) ~= 2 then return nil end
    local ok, model = pcall(GetEntityModel, entity)
    return ok and Utils.AmbulanceHashes[model] or nil
end

function Utils.IsAmbulance(entity)
    return Utils.GetAmbulanceConfig(entity) ~= nil
end

function Utils.GetClosestAmbulance(maxDistance)
    local coords = GetEntityCoords(cache.ped)
    local distance = maxDistance or Config.Ambulance.interactDistance

    for modelHash, config in pairs(Utils.AmbulanceHashes) do
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, distance, modelHash, 70)
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            return vehicle, config
        end
    end

    return nil, nil
end

-- Point behind the ambulance where the rear doors are
function Utils.GetAmbulanceRearCoords(ambulance, detection)
    return GetEntityCoords(ambulance) + GetEntityForwardVector(ambulance) * -detection
end

function Utils.HasAmbulanceJob()
    local job = Bridge.GetJob()
    if not job or not Bridge.IsJobAllowed(job.name) then return false end
    if Config.RequireOnDuty and not job.onDuty then return false end
    return true
end

function Utils.CanUseEmsInteract()
    if testMode and Config.TestBypassJob then return true end
    return Utils.HasAmbulanceJob()
end

function Utils.JobDeniedNotify(titleKey)
    local job = Bridge.GetJob()
    local wrongJob = not job or not Bridge.IsJobAllowed(job.name)

    Utils.Notify(titleKey or 'title_stretcher', wrongJob and 'not_ems' or 'not_on_duty', 'error')
end

function Utils.IsSelfDowned()
    return Bridge.IsSelfDowned()
end

function Utils.PlayDownedAnim()
    return Bridge.PlayDownedAnim()
end

function Utils.IsTestNpc(ped)
    return ped ~= nil and ped ~= 0 and Entity(ped).state.stretcherTestNpc == true
end

function Utils.SetTestMode(state)
    testMode = state == true
end

