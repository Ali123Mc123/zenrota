-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

RegisterNetEvent('wais:hunting:client:notify', function(title, message, type, duration)
    Config.Notification(title, message, type, duration)
end)

-----------------------------------------------------------------------------------------
-- CALLBACK'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

function DetectTarget()
    if GetResourceState("ox_target"):find("start") then
        target = "ox"
    elseif GetResourceState("qb-target"):find("start") then
        target = "qb"
    else
        target = "none"
    end
end

local savedJobCenterOptions = nil

local function setupExtraJobCenters(options)
    if not Config.ExtraJobCenters then return end

    for _, center in ipairs(Config.ExtraJobCenters) do
        -- Blip (Haritada her zaman görünür)
        if center.blips and center.blips.show and not center._blip then
            local blip = AddBlipForCoord(center.blips.coords.x, center.blips.coords.y, center.blips.coords.z)
            SetBlipSprite(blip, center.blips.sprite or 141)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, center.blips.scale or 0.83)
            SetBlipColour(blip, center.blips.color or 5)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(center.blips.label or "Avcılık")
            EndTextCommandSetBlipName(blip)
            center._blip = blip
        end

        -- Ped (Oyuncu yaklaştığında 60m içinde spawn olur, uzaklaştığında silinir)
        if not center._point then
            local pedCfg = center.ped
            center._point = lib.points.new({
                coords = vec3(pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z),
                distance = 60.0,
                onEnter = function(self)
                    loadModel(pedCfg.model)
                    local modelHash = type(pedCfg.model) == "string" and joaat(pedCfg.model) or pedCfg.model
                    pcall(function() exports['FeloxAC']:CreatePed(modelHash) end) --[[FeloxAC:auto]]
                    local ped = CreatePed(0, modelHash, pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z - 1.0, pedCfg.coords.w, false, true)
                    SetEntityHeading(ped, pedCfg.coords.w)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedCanRagdoll(ped, false)
                    SetPedDiesWhenInjured(ped, false)
                    SetPedCanPlayAmbientAnims(ped, true)
                    SetPedCanPlayAmbientBaseAnims(ped, true)
                    SetModelAsNoLongerNeeded(modelHash)
                    self.ped = ped

                    AddTargetEntity(ped, options, true, pedCfg.distance or 3.0)
                end,
                onExit = function(self)
                    if self.ped and DoesEntityExist(self.ped) then
                        DeleteEntity(self.ped)
                        self.ped = nil
                    end
                end
            })
        end
    end
end

-- DaddyRP: the hunting menu asks the server's College gate first; the notice says why it stays shut.
local function gateMenu(options)
    for i = 1, #(options or {}) do
        local opt = options[i]
        if opt.label == Lang('open_menu') and not opt.collegeGated and opt.action then
            local open = opt.action
            opt.action = function(...)
                local res = lib.callback.await('wais-hunting:server:collegeGate', false)
                if res and res.ok == false then
                    return Config.Notification(Lang('hunting'), res.msg, 'error', 7000)
                end
                return open(...)
            end
            opt.collegeGated = true
        end
    end
end

function AddTargetEntity(entity, options, localEntity, distance)
    while target == nil do Wait(0) end
    if target == "none" then return end
    gateMenu(options)
    local ref = nil
    Config.Debug(("Adding target to entity using %s target - Entity: %s, isLocal?: %s"):format(target, entity, localEntity))

    if not savedJobCenterOptions and options and #options > 0 then
        for i = 1, #options do
            if options[i].label == Lang('open_menu') then
                savedJobCenterOptions = options
                setupExtraJobCenters(options)
                break
            end
        end
    end

    if target == "ox" then
        local newOptions = {}
        for i = 1, #options, 1 do
            newOptions[i] = {
                name = options[i].name,
                icon = options[i].icon,
                label = options[i].label,
                onSelect = options[i].action,
                distance = distance or 3.0
            }
        end

        ref = not localEntity and exports.ox_target:addEntity(entity, newOptions) or exports.ox_target:addLocalEntity(entity, newOptions)
    elseif target == "qb" then
        ref = exports['qb-target']:AddTargetEntity(entity, {
            options = options,
            distance = distance or 3.0,
        })
    end

    if ref ~= nil then Targets[#Targets + 1] = ref end
    return ref
end

function loadDict(dict)
    local p = promise:new()
    if HasAnimDictLoaded(dict) then
        p:resolve(true)
    else
        local timeout = 10 * 1000
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            timeout = timeout - 10
            if timeout <= 0 then
                p:resolve(false)
                break
            end
            Wait(250)
        end

        p:resolve(true)
    end

    return Citizen.Await(p)
end

function loadModel(model)
    local p = promise:new()
    local model = type(model) == "string" and joaat(model) or model

    if HasModelLoaded(model) then
        p:resolve(true)
    else
        local timeout = 2 * 1000
        RequestModel(model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            timeout = timeout - 250
            if timeout <= 0 then
                p:resolve(false)
                break
            end
            Wait(250)
        end

        p:resolve(true)
    end

    return Citizen.Await(p)
end

function progressBar()
    return lib.progressBar({
        duration = Config.Skinning.duration,
        label = Lang("skinning_animal"),
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = Config.Skinning.anim.dict,
            clip = Config.Skinning.anim.clip,
            flag = Config.Skinning.anim.flag,
        },
        disable = {
            car = true,
            move = true,
            combat = true,
        }
    })
end

function getFreeOutCoord()
    local playerCoords = GetEntityCoords(cache.ped or PlayerPedId())
    local sortedCoords = {}

    for _, v in pairs(Config.Vehicle.outcoords) do
        local dist = #(playerCoords - vec3(v.x, v.y, v.z))
        sortedCoords[#sortedCoords + 1] = { coord = v, dist = dist }
    end

    table.sort(sortedCoords, function(a, b)
        return a.dist < b.dist
    end)

    for _, item in ipairs(sortedCoords) do
        local v = item.coord
        local vehicle, vehCoords = lib.getClosestVehicle(vec3(v.x, v.y, v.z), Config.Vehicle.controlDistance, true)
        if vehicle == nil or vehicle <= 0 then
            return vec4(v.x, v.y, v.z, v.w)
        end
    end

    Config.Notification(Lang('hunting'), Lang('hunting_garage_no_space'), "error", nil)
    return nil
end

function getInventoryItems()
    --[[
        If you're using custom or diffrent inventory system, you can override this function.
        Put your exports or etc.
    ]]
    return Config.Framework.Framework == "esx" and wFramework.PlayerData.inventory or wFramework.PlayerData.items
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if Config.ExtraJobCenters then
        for _, center in ipairs(Config.ExtraJobCenters) do
            if center._point then
                if center._point.ped and DoesEntityExist(center._point.ped) then
                    DeleteEntity(center._point.ped)
                end
                center._point:remove()
                center._point = nil
            end
            if center._blip and DoesBlipExist(center._blip) then
                RemoveBlip(center._blip)
                center._blip = nil
            end
        end
    end
end)

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------