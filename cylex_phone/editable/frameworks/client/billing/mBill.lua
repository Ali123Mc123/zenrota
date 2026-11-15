if Config.Billing ~= 'mBill' then return end

local function setBillData(data)
    SendNUIMessage({
        action = 'setAppData',
        key = 'bank',
        key2 = 'billing',
        type = 'set',
        value = data,
    })
    -- CreateThread(function()
    --     Wait(1000)
        refreshBankMoney()
    -- end)
end

local function formatBill(data)
    local tbl = {}
    for k, v in pairs(data) do
        table.insert(tbl, {
            id = v.id,
            user = v.author,
            amount = v.amount,
            description = v.description,
            time = v.time,
        })
    end
    return tbl
end

local function payBill(id)
    local result = Cylex.TriggerCallback('mBanking:server:payBill', id)
    if not result then 
        Cylex.Notify(language('bank', 'billing_pay_error'), 'error')
        return false 
    end
    local bills = Cylex.TriggerCallback('cylex_phone:server:bank:getBills')
    Cylex.Notify(language('bank', 'billing_pay_successful'), 'success')
    setBillData(formatBill(bills))
end

RegisterNUICallback('bank:getBills', function()
    local data = Cylex.TriggerCallback('cylex_phone:server:bank:getBills')
    setBillData(formatBill(data))
    cb(true)
end)

RegisterNUICallback('bank:payBill', function(data, cb)
    payBill(data.data.id)
    cb(true)
end)

RegisterNUICallback('bank:payAllBills', function(data, cb)
    local result = Cylex.TriggerCallback('cylex_phone:server:bank:getBills')
    for k, v in pairs(result) do
        payBill(v.id)
    end
    cb(true)
end)