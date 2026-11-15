local Config = Config

local Lang = Locales and Locales[Config.Language] or Locales and Locales['en'] or {}

ClientState = {
    isUiOpen = false,
    isJobActive = false,
    adminOpen = false,
    currentJob = nil,
    harvestSpots = {},
    currentZone = nil,
    npcPed = nil,
    activeNpcIndex = 1,
    heldEquipment = nil,
    debugEnabled = Config.Debug,
    skills = {},
    skillPoints = 0,
}

function GetItemLabel(itemKey)
    if not itemKey then return '' end
    local localeKey = 'crop_' .. itemKey
    local translated = T(localeKey)
    if translated ~= localeKey then
        return translated
    end
    local cfg = Config.Items and Config.Items[itemKey]
    return cfg and cfg.label or itemKey
end

function Krypton.Notify(message, type, duration, title)
    duration = duration or 5000
    type = type or 'info'
    if type == 'success' then type = 'success'
    elseif type == 'error' then type = 'error'
    else type = 'info' end

    local fw = Krypton.Framework and Krypton.Framework.Object
    local defaultTitle = (Config.NPC[1] and Config.NPC[1].blip and Config.NPC[1].blip.label) or 'Krypton Farming'

    if Config.NotifySystem == 'ox_lib' then
        exports.ox_lib:notify({ title = title or defaultTitle, description = message, type = type, duration = duration, position = 'top-right' })
    elseif Krypton.FrameworkType == 'qb' and fw and fw.Functions and fw.Functions.Notify then
        fw.Functions.Notify(message, type == 'info' and 'primary' or type, duration)
    elseif Krypton.FrameworkType == 'esx' and fw and fw.ShowNotification then
        fw.ShowNotification(message)
    elseif Krypton.FrameworkType == 'qbx' then
        exports.ox_lib:notify({ title = title or defaultTitle, description = message, type = type, duration = duration, position = 'top-right' })
    end

    DebugPrint('Notification:', message, type)
end

RegisterNetEvent('krypton-farming:client:notify', function(message, type, duration, title)
    Krypton.Notify(message, type, duration, title)
end)

function Krypton.ProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if Config.ProgressBar == 'ox_lib' then
        if lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = disableControls,
            anim = animation and {
                dict = animation.animDict,
                clip = animation.anim
            },
            prop = prop
        }) then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
    elseif Config.ProgressBar == 'framework' then
        if Krypton.Framework and Krypton.Framework.ProgressBar then
            Krypton.Framework.ProgressBar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        elseif onFinish then 
            Wait(duration)
            onFinish()
        end
    else
        -- Default custom progress logic could go here, fallback to wait for now
        if onFinish then 
            Wait(duration)
            onFinish()
        end
    end
end

function Krypton.ShowTextUI(message, position)
    position = position or 'right-center'
    if Config.TextUI == 'ox_lib' then
        lib.showTextUI(message, { position = position })
    else
        if Krypton.Framework and Krypton.Framework.ShowTextUI then
            Krypton.Framework.ShowTextUI(message, position)
        else
            -- Internal Web UI Target Fallback
            SendNUIMessage({
                action = 'showHarvestPrompt',
                icon = 'fas fa-hand',
                harvestAction = 'harvest',
                promptText = message,
            })
        end
    end
end

function Krypton.HideTextUI()
    if Config.TextUI == 'ox_lib' then
        lib.hideTextUI()
    elseif Config.TextUI == 'okokTextUI' then
        exports['okokTextUI']:Close()
    elseif Config.TextUI == 'jg-textui' then
        exports['jg-textui']:HideText()
    elseif Config.TextUI == 'cd_drawtextui' then
        exports['cd_drawtextui']:HideUI()
    else
        if Krypton.Framework and Krypton.Framework.HideTextUI then
            Krypton.Framework.HideTextUI()
        else
            SendNUIMessage({ action = 'hideHarvestPrompt' })
        end
    end
end

function T(key, ...)
    local text = Lang[key] or key
    if ... then
        return string.format(text, ...)
    end
    return text
end

-- Levels: 1 = Error, 2 = Warning, 3 = Info/Verbose
function DebugPrint(...)
    if not Config.Debug then return end
    local level = Config.DebugLevel or 3
    if level >= 3 then
        print('^3[Krypton Farming Debug]^7', ...)
    end
end

function DebugError(...)
    if not Config.Debug then return end
    local level = Config.DebugLevel or 3
    if level >= 1 then
        print('^1[Krypton Farming ERROR]^7', ...)
    end
end

function DebugWarn(...)
    if not Config.Debug then return end
    local level = Config.DebugLevel or 3
    if level >= 2 then
        print('^3[Krypton Farming WARN]^7', ...)
    end
end

function GetLang()
    return Lang
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    if DespawnHarvestSpots then
        DespawnHarvestSpots()
    end
    
    if CleanupJobVehicle then
        CleanupJobVehicle()
    end
    
    if ClientState.npcPeds then
        for _, ped in pairs(ClientState.npcPeds) do
            if ped and DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
        ClientState.npcPeds = nil
    end

    if ClientState.npcPed and DoesEntityExist(ClientState.npcPed) then
        DeleteEntity(ClientState.npcPed)
        ClientState.npcPed = nil
    end
    
    DebugPrint('Resource stopped, cleanup performed')
end)

AddEventHandler('playerSpawned', function()
    Wait(2000)
    TriggerServerEvent('krypton-farming:server:checkReconnect')

    -- Pre-warm the NUI/Chromium engine so the first real panel open doesn't stutter.
    -- SendNUIMessage forces CEF to process its event loop; we also pre-send the locale
    -- table (the largest serialization cost) so it's already done before the player
    -- interacts with the NPC. The NUI ignores unknown actions gracefully.
    Wait(500)
    SendNUIMessage({ action = 'warmup', locales = GetLang() })
end)

DebugPrint('Client main module loaded')
