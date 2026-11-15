local presets = { 10000, 50000, 250000, 1000000, 5000000 }
local accounts = { 'cash', 'bank', 'crypto' }

RegisterNetEvent('ollie_money:client:notify', function(message, kind)
    lib.notify({
        title = 'Para',
        description = message,
        type = kind or 'inform',
        position = 'top',
        duration = 4000,
    })
end)

local function sendSelf(amount, account)
    TriggerServerEvent('ollie_money:print', amount, account or 'bank')
end

local function sendTarget(targetId, amount, account)
    TriggerServerEvent('ollie_money:printTo', targetId, amount, account or 'bank')
end

RegisterNetEvent('ollie_money:client:openPanel', function()
    local options = {}
    for i = 1, #presets do
        local amount = presets[i]
        options[#options + 1] = {
            title = ('$%s'):format(amount),
            description = 'Kendi hesabina bank',
            icon = 'money-bill-wave',
            onSelect = function() sendSelf(amount, 'bank') end,
        }
        options[#options + 1] = {
            title = ('$%s cash'):format(amount),
            description = 'Kendi hesabina nakit',
            icon = 'wallet',
            onSelect = function() sendSelf(amount, 'cash') end,
        }
    end

    lib.registerContext({ id = 'ollie_money_panel', title = 'Para Bas', options = options })
    lib.showContext('ollie_money_panel')
end)

RegisterCommand('parapanel', function()
    TriggerEvent('ollie_money:client:openPanel')
end, false)

RegisterKeyMapping('parapanel', 'Para panelini ac', 'keyboard', 'F7')

RegisterCommand('parahepclient', function(_, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2]) or 100000
    local account = args[3] or 'bank'
    if targetId then sendTarget(targetId, amount, account) end
end, false)

CreateThread(function()
    Wait(1000)
    if GetResourceState('ox_lib') ~= 'started' then return end
    lib.notify({
        title = 'ollie_money',
        description = 'Yuklendi. /para <miktar> <cash|bank|crypto> | F7 panel',
        type = 'inform',
        duration = 8000,
    })
end)
