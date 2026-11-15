-- Client: notices and the "open the showroom" hint.

-- Notices: the page's own (page), or your notification script.
do
    local KINDS = { info = 'inform', success = 'success', error = 'error' }

    local NOTIFY = {
        page = function(text, tone) SendNUIMessage({ action = 'dealer:notice', text = text, tone = tone }) end,
        ox_lib = function(text, tone) lib.notify({ description = text, type = KINDS[tone] or 'inform' }) end,
        qb = function(text, tone) TriggerEvent('QBCore:Notify', text, tone == 'info' and 'primary' or tone) end,
        esx = function(text) TriggerEvent('esx:showNotification', text) end,
    }

    -- notify(text, 'info' | 'success' | 'error')
    function Bridge.notify(text, tone)
        local fn = NOTIFY[(Config.Bridge or {}).Notify] or NOTIFY.page
        fn(text, tone or 'info')
    end
end

-- The hint while standing at a dealership or a display car: the page's own key hint, or ox_lib's text UI. target is
-- { label, sub?, verb? } (a dealership is one); nil hides it.
function Bridge.hint(target)
    local verb = target and target.verb or 'ui.open'
    if (Config.Bridge or {}).Interact == 'textui' then
        if target then lib.showTextUI(('[E] %s %s'):format(Core.t(verb), target.sub and ('· ' .. target.label .. ' ' .. target.sub) or ''))
        else lib.hideTextUI() end
        return
    end
    SendNUIMessage({ action = 'dealer:prompt', show = target ~= nil, label = target and target.label or '', sub = target and target.sub or '', verb = verb })
end
