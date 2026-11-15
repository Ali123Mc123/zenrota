local playerState        = LocalPlayer.state
local config             = require 'configs.client'
local prisonBreakcfg     = require 'configs.prisonbreak'
local prisonBreakModules = require 'modules.client.prisonbreak'
local utils              = require 'modules.client.utils'
local resources          = require 'bridge.compat.resources'
local jobsModule         = require 'modules.client.jobs'

local inJail             = false

local mainBlip
local PrisonZone
local CheckOutZone
local CheckOutPed
local CheckOutPedBlip
local isExiting          = false

local prisonModules      = {}

-- Set Jail Time --
function prisonModules.setJailTime(jailTime)
    if playerState.jailTime == jailTime then
        return true
    end

    playerState:set('jailTime', jailTime, true)

    while playerState.jailTime ~= jailTime do
        Wait(1)
    end

    return (playerState.jailTime == jailTime)
end

function prisonModules.isInJail()
    return inJail or (playerState.jailTime and tonumber(playerState.jailTime) > 0)
end

-- Create Checkout Location --
function prisonModules.createCheckoutLocation()
    if resources.xt_prisonjobs then return end

    prisonModules.removeCheckoutLocation()

    local checkoutInfo = config.CheckOut

    if not DoesEntityExist(CheckOutPed) then
        local pedModel = checkoutInfo.model or 's_m_m_security_01'
        local pedScenario = checkoutInfo.scenario or 'WORLD_HUMAN_STAND_IMPATIENT'
        local pedCoords = vector4(checkoutInfo.coords.x, checkoutInfo.coords.y, checkoutInfo.coords.z,
            checkoutInfo.coords.w)
        CheckOutPed = utils.createPed(pedModel, pedCoords, pedScenario)
        -- CheckOutPedBlip = utils.createBlip('Gardiyan', checkoutInfo.coords, 0, 0.3, 1) -- gardiyan blipi haritadan kaldirildi
    end

    if resources.qb_target then
        CheckOutZone = exports['qb-target']:AddBoxZone("CheckOutZone", checkoutInfo.coords, checkoutInfo.size[1],
            checkoutInfo.size[2], {
                name = "CheckOutZone",
                heading = checkoutInfo.rotation,
                debugPoly = config.DebugPoly,
                minZ = checkoutInfo.minZ,
                maxZ = checkoutInfo.maxZ,
            }, {
                options = {
                    {
                        type = "client",
                        event = "checkTime",
                        icon = "fas fa-hourglass-start",
                        label = locale('input.check_time'),
                        action = function()
                            local timeLeft = lib.callback.await('xt-prison:server:checkJailTime', false)
                            if timeLeft <= 0 then
                                prisonModules.exitPrison(true)
                            end
                        end
                    },
                },
                distance = 2.5
            })

        exports['qb-target']:AddTargetEntity(CheckOutPed, {
            options = {
                {
                    label = locale('input.check_time'),
                    icon = 'fas fa-hourglass-start',
                    action = function()
                        local timeLeft = lib.callback.await('xt-prison:server:checkJailTime', false)
                        if timeLeft <= 0 then
                            prisonModules.exitPrison(true)
                        end
                    end
                }
            },
            distance = 2.5
        })
    else
        CheckOutZone = exports.ox_target:addLocalEntity(CheckOutPed, {
            {
                label = locale('input.check_time'),
                icon = 'fas fa-hourglass-start',
                onSelect = function()
                    local timeLeft = lib.callback.await('xt-prison:server:checkJailTime', false)
                    if timeLeft <= 0 then
                        prisonModules.exitPrison(true)
                    end
                end
            }
        })
    end
end

-- Remove Checkout Location --
function prisonModules.removeCheckoutLocation()
    if resources.xt_prisonjobs then return end

    if resources.qb_target then
        exports['qb-target']:RemoveZone("CheckOutZone")
        if DoesEntityExist(CheckOutPed) then
            exports['qb-target']:RemoveTargetEntity(CheckOutPed)
        end
    else
        if CheckOutZone then
            exports.ox_target:removeZone(CheckOutZone)
            CheckOutZone = nil
        end
        if DoesEntityExist(CheckOutPed) then
            exports.ox_target:removeLocalEntity(CheckOutPed, locale('input.check_time'))
        end
    end

    if DoesEntityExist(CheckOutPed) then
        DeletePed(CheckOutPed)
        CheckOutPed = nil
    end

    if CheckOutPedBlip and DoesBlipExist(CheckOutPedBlip) then
        RemoveBlip(CheckOutPedBlip)
        CheckOutPedBlip = nil
    end
end

-- Create Prison Zone for Prison Break Distance Checks --
function prisonModules.createPrisonZone()
    PrisonZone = lib.points.new({
        coords = prisonBreakcfg.Center,
        distance = prisonBreakcfg.Radius,
    })

    function PrisonZone:onExit()
        if inJail then
            inJail = false
            local alarm = lib.callback.await('xt-prison:server:setPrisonAlarms', false, true)
            if alarm then
                lib.notify({ title = locale('notify.escaped'), type = ' error' })
                TriggerServerEvent('xt-prison:server:triggerBreakout')
                config.Dispatch(prisonBreakcfg.Center)
            end
        end
    end

    if not resources.xt_prisonjobs then
        mainBlip = utils.createBlip('Hapishane', prisonBreakcfg.Center, 60, 0.7, 3)
    end
end

-- Removes All Prison Zones, Blips, etc --
function prisonModules.prisonCleanup()
    TriggerServerEvent('xt-prison:server:saveJailTime')
    PrisonZone:remove()
    prisonModules.removeCheckoutLocation()
    prisonBreakModules.removeBlip()
    prisonBreakModules.removeHackZones()
    jobsModule.cleanupJobs()

    if DoesBlipExist(mainBlip) then
        RemoveBlip(mainBlip)
    end
end

-- Sets Player's Coords --
function prisonModules.setPlayerCoords(coords)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z - 0.9, 0, 0, 0, false)
    SetEntityHeading(cache.ped, coords.w)
    local dist = #(vec3(coords.x, coords.y, coords.z - 0.9) - GetEntityCoords(cache.ped))
    return (dist <= 5)
end

-- Entering Prison --
function prisonModules.enterPrison(setTime)
    local setServerJailTime = lib.callback.await('xt-prison:server:setJailStatus', false, setTime)
    if not setServerJailTime then
        return false
    end

    if config.RemoveJob then
        local removed = lib.callback.await('xt-prison:server:removeJob', false)
        if not removed then
            return false
        end
    end

    local setJailTime = prisonModules.setJailTime(setTime)
    if setJailTime then
        TriggerServerEvent('xt-prison:server:removeItems')
        local isLifer = lib.callback.await('xt-prison:server:liferCheck', false)

        DoScreenFadeOut(2000)
        while not IsScreenFadedOut() do Wait(25) end

        local RandomSpawn = config.Spawns[math.random(1, #config.Spawns)]
        lib.waitFor(function()
            if prisonModules.setPlayerCoords(RandomSpawn.coords) then
                FreezeEntityPosition(cache.ped, true)
                while not HasCollisionLoadedAroundEntity(cache.ped) do
                    Wait(0)
                end

                if HasCollisionLoadedAroundEntity(cache.ped) then
                    if config.EnablePrisonOutfits then
                        prisonModules.applyPrisonUniform()
                    end
                    inJail = true
                    return true
                end
            end
        end, 'Hapishane yüklenemedi, tekrar dene', 10000)

        FreezeEntityPosition(cache.ped, false)

        TriggerServerEvent("InteractSound_SV:PlayOnSource", "jail", 0.5)

        config.Emote(RandomSpawn.emote)
        prisonModules.createCheckoutLocation()

        DoScreenFadeIn(2000)
        while not IsScreenFadedIn() do Wait(25) end

        if config.EnterPrisonAlert.enable and not isLifer then
            CreateThread(function()
                local alertInfo = config.EnterPrisonAlert
                lib.alertDialog({
                    header = alertInfo.header,
                    content = (locale('input.prison_sentence')):format(setTime, alertInfo.content),
                    centered = true,
                    labels = { confirm = 'Kapat' }
                })
            end)
        elseif config.EnterPrisonAlert.enable and isLifer then
            lib.notify({ title = locale('notify.lifer'), type = 'error' })
        end

        if not isLifer then
            prisonModules.timeReductionLoop()
            jobsModule.initJobs(setTime)
        end

        if resources.xt_prisonjobs then
            exports['xt-prisonjobs']:InitPrisonJob()
        end

        isExiting = false
        return true
    end

    return false
end

-- Exiting Prison --
function prisonModules.exitPrison(isUnjailed)
    if isExiting then return end
    if playerState.jailTime > 0 and not isUnjailed then
        lib.notify({ title = (locale('notify.time_left')):format(playerState.jailTime), type = 'error' })
        return false
    elseif playerState.jailTime <= 0 or isUnjailed then
        isExiting = true
        local setJailTime = prisonModules.setJailTime(0)
        if setJailTime then
            inJail = false
            jobsModule.cleanupJobs()
            prisonModules.prisonCleanup()

            DoScreenFadeOut(2000)
            while not IsScreenFadedOut() do Wait(25) end

            if config.EnablePrisonOutfits then
                config.ResetClothing()
            end

            prisonModules.setPlayerCoords(config.Freedom)

            Wait(500)
            DoScreenFadeIn(2000)
            while not IsScreenFadedIn() do Wait(25) end

            TriggerServerEvent('xt-prison:server:returnItems')

            if resources.xt_prisonjobs then
                exports['xt-prisonjobs']:CleanupPrisonJob()
            end

            isExiting = false
            return true
        end
    end

    isExiting = false
    return false
end

-- Reduce Jail Time Loop --
function prisonModules.timeReductionLoop()
    CreateThread(function()
        while inJail do
            if playerState.jailTime > 0 then
                local newTime = (playerState.jailTime - 1)
                prisonModules.setJailTime(newTime)
                jobsModule.updateHUD({ jailTime = newTime })
            elseif playerState.jailTime <= 0 then
                lib.notify({
                    title = locale('notify.checkout'),
                    icon = 'fas fa-unlock',
                    type = 'success'
                })
                jobsModule.cleanupJobs()
                break
            end
            Wait(60000)
        end
    end)
end

function prisonModules.applyPrisonUniform()
    local outifitInfo = IsPedModel(cache.ped, 'mp_m_freemode_01') and config.PrisonOufits.male or
        config.PrisonOufits.female
    SetPedComponentVariation(cache.ped, 1, outifitInfo.mask.item, outifitInfo.mask.texture)               -- Mask
    SetPedComponentVariation(cache.ped, 3, outifitInfo.arms.item, outifitInfo.arms.texture)               -- Arms
    SetPedComponentVariation(cache.ped, 4, outifitInfo.pants.item, outifitInfo.pants.texture)             -- Pants
    SetPedComponentVariation(cache.ped, 6, outifitInfo.shoes.item, outifitInfo.shoes.texture)             -- Shoes
    SetPedComponentVariation(cache.ped, 7, outifitInfo.accessories.item, outifitInfo.accessories.texture) -- Accessory
    SetPedComponentVariation(cache.ped, 8, outifitInfo.shirt.item, outifitInfo.shirt.texture)             -- Shirt
    SetPedComponentVariation(cache.ped, 11, outifitInfo.jacket.item, outifitInfo.jacket.texture)          -- Jacket
    if outifitInfo.bag then SetPedComponentVariation(cache.ped, 5, outifitInfo.bag.item, outifitInfo.bag.texture) end                   -- Bag
    if outifitInfo.bodyArmor then SetPedComponentVariation(cache.ped, 9, outifitInfo.bodyArmor.item, outifitInfo.bodyArmor.texture) end -- Body Armor
    if outifitInfo.decals then SetPedComponentVariation(cache.ped, 10, outifitInfo.decals.item, outifitInfo.decals.texture) end        -- Decals
end

return prisonModules
