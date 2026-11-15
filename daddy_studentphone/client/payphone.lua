-- Payphones (Config.Payphone): the street phone boxes take a coin and call a number with the caller's number hidden.
-- With ox_target the boxes get "Use payphone"; the call itself runs as any student-line call (the call screen at the
-- screen edge, the keys to hang up).
local cfg = Config.Payphone
if not cfg.Enabled then return end

local function use()
    local input = lib.inputDialog(DL.locale.t('apps.phone.payphone'), {
        { type = 'input', label = DL.locale.t('apps.phone.payphone_number'), placeholder = '7__-____', required = true, max = 20 },
    })
    local number = input and input[1]
    if not number or number == '' then return end
    TriggerServerEvent(GetCurrentResourceName() .. ':payphone', number)
end

CreateThread(function()
    if GetResourceState('ox_target') ~= 'started' then return end
    exports.ox_target:addModel(cfg.Models, {
        { name = 'studentphone_payphone', icon = 'fa-solid fa-phone', label = DL.locale.t('apps.phone.payphone_use', cfg.Price), distance = 1.6, onSelect = use },
    })
end)

RegisterNetEvent(GetCurrentResourceName() .. ':payphoneFail', function(code)
    lib.notify({ type = 'error', description = DL.locale.t('errors.' .. tostring(code)) })
end)
