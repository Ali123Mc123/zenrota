-- /finans: the player's financed cars on the page (no hall), paid by instalment or all at once.
Panel = { active = false }

-- A page screen without the hall: the page takes the input until it closes.
function Panel.open(action, data)
    if Hall.active or Panel.active or not Page.await(5000) then return false end
    Panel.active = true
    Page.send(action, data)
    Page.focus(true)
    return true
end

function Panel.close()
    if not Panel.active then return end
    Panel.active = false
    Page.focus(false)
    Page.send('dealer:close')
end

RegisterCommand(Config.Commands.Finance, function()
    local res = lib.callback.await('daddy_dealerships:finance', false)
    if res then Panel.open('dealer:finance', res) end
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.Finance, Core.t('ui.my_finance'))

Page.on('dealer:finance:pay', function(data)
    return lib.callback.await('daddy_dealerships:finance:pay', false, tostring(data.plate or ''), data.all == true)
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() and Panel.active then
        Panel.active = false
        Page.focus(false)
    end
end)
