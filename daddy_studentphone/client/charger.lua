-- Chargers (Config.Battery.Chargers): plug the phone in at a vending machine or a set spot; it charges while you stay.
local cfg = Config.Battery
if not cfg.Enabled then return end
local event = GetCurrentResourceName()

-- The charger the phone is in (the server says so with :docked / :undocked). While it is set a light loop watches the
-- distance and unplugs the moment the player walks off, so the phone stops charging then and not a minute later.
local dock = nil

local function isDock(at) return dock ~= nil and #(dock - at) < 0.1 end

local function plugAnim()
    if IsPedInAnyVehicle(PlayerPedId(), false) or not pcall(lib.requestAnimDict, 'mp_common', 1500) then return end
    TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', 6.0, 6.0, 900, 48, 0.0, false, false, false)
    RemoveAnimDict('mp_common')
end

local function plug(at)
    if isDock(at) then return end
    plugAnim()
    TriggerServerEvent(event .. ':plug', at)
end

local function unplug(why)
    if not dock then return end
    dock = nil
    if why == 'manual' then plugAnim() end
    TriggerServerEvent(event .. ':unplug', why)
end

local watching = 0
local function watch()
    watching = watching + 1
    local mine = watching
    CreateThread(function()
        local reach = cfg.Chargers.Reach + 0.25
        while dock and watching == mine do
            if #(GetEntityCoords(PlayerPedId()) - dock) > reach then unplug('away') break end
            Wait(400)
        end
    end)
end

RegisterNetEvent(event .. ':docked', function(at, level)
    dock = at
    watch()
    lib.notify({ id = 'studentphone_charge', type = 'success', icon = 'bolt', iconColor = '#34c759',
        title = DL.locale.t('notify.charge.plugged_title'), description = DL.locale.t('notify.charge.plugged', level) })
end)

RegisterNetEvent(event .. ':undocked', function(why, level)
    dock = nil
    lib.notify({ id = 'studentphone_charge', type = 'inform', icon = 'plug-circle-xmark', iconColor = '#8e8e93',
        title = DL.locale.t('notify.charge.unplugged_title'),
        description = DL.locale.t(why == 'away' and 'notify.charge.unplugged_away' or 'notify.charge.unplugged', level or 0) })
end)

CreateThread(function()
    if GetResourceState('ox_target') ~= 'started' then return end
    local reach = cfg.Chargers.Reach
    local function options(name, spot)
        return {
            { name = name, icon = 'fa-solid fa-plug', label = DL.locale.t('notify.charge.plug'), distance = reach,
              canInteract = function(entity) return not isDock(spot(entity)) end,
              onSelect = function(data) plug(spot(data.entity)) end },
            { name = name .. '_out', icon = 'fa-solid fa-plug-circle-xmark', label = DL.locale.t('notify.charge.unplug'), distance = reach,
              canInteract = function(entity) return isDock(spot(entity)) end,
              onSelect = function() unplug('manual') end },
        }
    end
    if #cfg.Chargers.Models > 0 then
        exports.ox_target:addModel(cfg.Chargers.Models, options('studentphone_charge', function(entity) return GetEntityCoords(entity) end))
    end
    for i, at in ipairs(cfg.Chargers.Points) do
        exports.ox_target:addSphereZone({ coords = at, radius = 0.6, options = options('studentphone_charge_' .. i, function() return at end) })
    end
end)

-- Charger props on the map (Config.Battery.Chargers.Spawn): local objects, so the Models target above covers them.
local spawned = {}
CreateThread(function()
    local ch = cfg.Chargers
    for _, spot in ipairs(ch.Spawn or {}) do
        local name = ch.SpawnModels[spot.Kind]
        local model = name and joaat(name)
        if model and IsModelInCdimage(model) and pcall(lib.requestModel, model, 5000) then
            local c = spot.Coords
            local rad = math.rad(c.w)
            local ahead = spot.Kind == 'wall' and ch.WallAhead or ch.StandAhead
            local x, y = c.x - math.sin(rad) * ahead, c.y + math.cos(rad) * ahead
            local feet = c.z - 1.0
            pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
            local obj = CreateObject(model, x, y, feet, false, false, false)
            SetEntityHeading(obj, (c.w + 180.0) % 360.0)
            if spot.Kind == 'wall' then
                SetEntityCoordsNoOffset(obj, x, y, feet + ch.WallHeight, false, false, false)
            else
                PlaceObjectOnGroundProperly(obj)
            end
            FreezeEntityPosition(obj, true)
            SetModelAsNoLongerNeeded(model)
            spawned[#spawned + 1] = obj
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= event then return end
    for _, obj in ipairs(spawned) do if DoesEntityExist(obj) then DeleteEntity(obj) end end
end)

-- A short look at the power bank in the right hand while it is plugged in (same axes as the phone prop).
local function holdPowerbank()
    local hold = cfg.Powerbank.Hold
    if not hold or IsPedInAnyVehicle(PlayerPedId(), false) then return end
    local model = joaat(hold.Model)
    if not IsModelInCdimage(model) or not pcall(lib.requestModel, model, 2000) then return end
    if not pcall(lib.requestAnimDict, hold.Dict, 2000) then return end
    local ped = PlayerPedId()
    local prop = CreateObject(model, GetEntityCoords(ped), false, false, false)
    SetModelAsNoLongerNeeded(model)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, hold.Dict, hold.Clip, 4.0, 4.0, -1, 49, 0.0, false, false, false)
    Wait(hold.Ms)
    StopAnimTask(ped, hold.Dict, hold.Clip, 2.0)
    RemoveAnimDict(hold.Dict)
    DeleteEntity(prop)
end

RegisterNetEvent(event .. ':charge', function(kind, minutes)
    lib.notify({ type = 'success', description = DL.locale.t('notify.charge.' .. kind, minutes) })
    if kind == 'powerbank' then holdPowerbank() end
end)
