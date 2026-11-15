local currentState = nil

function OpenDeathscreen(timer, locale)
    SendNUIMessage({
        action = 'open',
        timer  = timer or 300,
        locale = locale or nil
    })
end

function CloseDeathscreen()
    currentState = nil
    SendNUIMessage({
        action = 'close'
    })
end

RegisterNUICallback('closeDeathscreen', function(_, cb)
    CloseDeathscreen()
    cb('ok')
end)

exports('OpenDeathscreen', OpenDeathscreen)
exports('CloseDeathscreen', CloseDeathscreen)
exports('IsDeathscreenActive', function() return currentState ~= nil end)
exports('GetDeathscreenState', function() return currentState end)

RegisterNetEvent('krypton-deathscreen:client:open', function(timer, locale)
    OpenDeathscreen(timer, locale)
end)

RegisterNetEvent('krypton-deathscreen:client:close', function()
    CloseDeathscreen()
end)

local isDeadLoopActive = false

local function StartDeathChecker()
    if isDeadLoopActive then return end
    isDeadLoopActive = true

    CreateThread(function()
        local lastSentHold = -1
        local descriptionUpdated = false
        local holdThreshold = tonumber(Config.Locales.dead.second) or 5

        while currentState == 'dead' do
            local sleep = 500
            local timer = exports.qbx_medical:GetDeathTime()

            if timer and timer > 0 then
                sleep = 0
                DisableControlAction(0, 38, true)
                descriptionUpdated = false
            else
                if not descriptionUpdated then
                    SendNUIMessage({
                        action = 'updateLocale',
                        locale = {
                            description = Config.Locales.dead.respawnDescription,
                            reportKey   = Config.Locales.dead.respawnKey
                        }
                    })
                    descriptionUpdated = true
                end

                local holdTime = exports.qbx_medical:GetRespawnHoldTimeDeprecated()
                if holdTime ~= lastSentHold then
                    if holdTime < holdThreshold then
                        SendNUIMessage({ action = 'holdProgress', remaining = holdTime })
                    else
                        SendNUIMessage({ action = 'holdRelease' })
                    end
                    lastSentHold = holdTime
                end
            end

            Wait(sleep)
        end

        isDeadLoopActive = false
    end)
end

AddEventHandler('qbx_medical:client:onPlayerLaststand', function()
    currentState = 'laststand'
    local timer = exports.qbx_medical:GetLaststandTime()
    OpenDeathscreen(timer, Config.Locales.laststand)
end)

AddEventHandler('qbx_medical:client:onPlayerDied', function()
    currentState = 'dead'
    local timer = exports.qbx_medical:GetDeathTime()
    local locale = {
        title       = Config.Locales.dead.title,
        description = Config.Locales.dead.waitingDescription,
        reportKey   = Config.Locales.dead.reportKey,
        second      = Config.Locales.dead.second
    }
    OpenDeathscreen(timer, locale)
    StartDeathChecker()
end)

RegisterNetEvent('qbx_medical:client:playerRevived', function()
    if currentState then
        CloseDeathscreen()
    end
end)

RegisterNetEvent('qbx_ambulancejob:client:checkedIn', function()
    if currentState then
        CloseDeathscreen()
    end
end)

local function CheckPlayerState()
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.citizenid then return end

    if exports.qbx_medical:IsDead() then
        currentState = 'dead'
        local timer = exports.qbx_medical:GetDeathTime()
        local isRespawn = not (timer and timer > 0)
        local desc = isRespawn and Config.Locales.dead.respawnDescription or Config.Locales.dead.waitingDescription
        local locale = {
            title       = Config.Locales.dead.title,
            description = desc,
            reportKey   = isRespawn and Config.Locales.dead.respawnKey or Config.Locales.dead.reportKey,
            second      = Config.Locales.dead.second
        }
        OpenDeathscreen(timer, locale)

        StartDeathChecker()
    elseif exports.qbx_medical:IsLaststand() then
        currentState = 'laststand'
        local timer = exports.qbx_medical:GetLaststandTime()
        OpenDeathscreen(timer, Config.Locales.laststand)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    CheckPlayerState()
end)

-- Script restart edilirse check
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        CheckPlayerState()
    end
end)
