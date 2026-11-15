-- AirDrop offers and answers go to the page. A contact card that comes with the phone away is asked about at once in a
-- plain dialog (Save or Decline), so the number is kept without taking the phone out; other offers wait for the page.
local RESOURCE = GetCurrentResourceName()
local asking -- the offer id the dialog is up for

local function ask(share)
    asking = share.id
    CreateThread(function()
        local text = share.own and DL.locale.t('apps.airdrop.offer_own', share.from)
            or DL.locale.t('apps.airdrop.offer_body', share.from, DL.locale.t('apps.airdrop.offer_card'))
        local card = share.card or {}
        local answer = lib.alertDialog({
            header = DL.locale.t('apps.airdrop.name'),
            content = ('%s\n\n**%s**  \n%s'):format(text, card.name or '', card.number or ''),
            centered = true,
            cancel = true,
            labels = { confirm = DL.locale.t('apps.airdrop.save_card'), cancel = DL.locale.t('apps.airdrop.decline') },
        })
        if asking ~= share.id then return end
        asking = nil
        local res = lib.callback.await(RESOURCE .. ':airdropAnswer', false, share.id, answer == 'confirm')
        if answer ~= 'confirm' then return end
        local ok = type(res) == 'table' and res.ok
        lib.notify({ description = DL.locale.t(ok and 'apps.airdrop.contact_saved' or 'errors.' .. tostring(type(res) == 'table' and res.error or 'server_error')), type = ok and 'success' or 'error' })
    end)
end

RegisterNetEvent(RESOURCE .. ':airdrop', function(data)
    if type(data) ~= 'table' then return end
    local share = data.share
    if data.kind == 'offer' and type(share) == 'table' and share.kind == 'card' and not PhoneUI.open and not asking then
        return ask(share)
    end
    -- The offer the dialog is up for went stale: the dialog goes with it.
    if data.kind == 'expired' and asking and data.id == asking then
        asking = nil
        lib.closeAlertDialog()
    end
    SendNUIMessage({ action = 'airdrop', data = data })
end)
