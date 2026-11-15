-- Client: a short notice. 'page' shows it on the dispatch's own plate; the others hand it to that script.
local KINDS = { info = 'inform', success = 'success', error = 'error' }
local SCRIPTS = {
    { id = 'ox_lib', fn = function(text, tone) lib.notify({ description = text, type = KINDS[tone] or 'inform' }) end },
    { id = 'qb', fn = function(text, tone) TriggerEvent('QBCore:Notify', text, tone == 'info' and 'primary' or tone) end },
    { id = 'esx', fn = function(text) TriggerEvent('esx:showNotification', text) end },
}

-- notify(text, 'info' | 'success' | 'error')
function Bridge.notify(text, tone)
    local wanted = Config.Bridge.Notify
    for _, s in ipairs(SCRIPTS) do
        if s.id == wanted then return s.fn(text, tone) end
    end
    Page.send('notice', { text = text, tone = tone or 'info' })
end
