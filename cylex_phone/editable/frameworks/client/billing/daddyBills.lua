if Config.Billing ~= 'daddyBills' then return end

-- DaddyRP: bills of daddy_bills in the bank app (the server side is frameworks/server/billing/daddyBills.lua)
local function setBillData(data)
    SendNUIMessage({
        action = 'setAppData',
        key = 'bank',
        key2 = 'billing',
        type = 'set',
        value = data,
    })
    if refreshBankMoney then refreshBankMoney() end
end

local function formatBill(data)
    local tbl = {}
    for _, v in pairs(data or {}) do
        tbl[#tbl + 1] = { id = v.id, user = v.author, amount = v.amount, description = v.description, time = v.time }
    end
    return tbl
end

local function payBill(id)
    local result = Cylex.TriggerCallback('cylex_phone:server:bank:payBill', id)
    if not result then
        Cylex.Notify(language('bank', 'billing_pay_error'), 'error')
        return false
    end
    Cylex.Notify(language('bank', 'billing_pay_successful'), 'success')
    return true
end

local function refresh()
    setBillData(formatBill(Cylex.TriggerCallback('cylex_phone:server:bank:getBills')))
end

RegisterNUICallback('bank:getBills', function(_, cb)
    refresh()
    cb(true)
end)

RegisterNUICallback('bank:payBill', function(data, cb)
    payBill(data.data.id)
    refresh()
    cb(true)
end)

RegisterNUICallback('bank:payAllBills', function(_, cb)
    for _, v in pairs(Cylex.TriggerCallback('cylex_phone:server:bank:getBills') or {}) do
        if not payBill(v.id) then break end
    end
    refresh()
    cb(true)
end)
