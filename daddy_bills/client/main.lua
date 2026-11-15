local isOpen = false
local tablet

local function hold()
    local cfg = Config.Tablet
    if not cfg then return end
    local ped = PlayerPedId()
    lib.requestAnimDict(cfg.dict)
    lib.requestModel(cfg.prop)
    pcall(function() exports['FeloxAC']:CreateObject(joaat(cfg.prop)) end) --[[FeloxAC:auto]]
    tablet = CreateObject(joaat(cfg.prop), 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(tablet, ped, GetPedBoneIndex(ped, cfg.bone), cfg.offset.x, cfg.offset.y, cfg.offset.z, cfg.rotation.x, cfg.rotation.y, cfg.rotation.z, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(joaat(cfg.prop))
    TaskPlayAnim(ped, cfg.dict, cfg.anim, 3.0, 3.0, -1, 49, 0, false, false, false)
end

local function putAway()
    if tablet and DoesEntityExist(tablet) then DeleteEntity(tablet) end
    tablet = nil
    if Config.Tablet then StopAnimTask(PlayerPedId(), Config.Tablet.dict, Config.Tablet.anim, 1.0) end
end

local function close()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    putAway()
end

local function open(screen)
    if isOpen then return close() end
    if IsEntityDead(PlayerPedId()) or IsPedCuffed(PlayerPedId()) then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', lang = Config.Locale, screen = screen })
    hold()
end

if Config.Command then
    RegisterCommand(Config.Command, function() open() end, false)
    if Config.Key then RegisterKeyMapping(Config.Command, L('tablet'), 'keyboard', Config.Key) end
end
if Config.ListCommand then
    RegisterCommand(Config.ListCommand, function() open('inbox') end, false)
end
exports('open', open)

if Config.AdminCommand then
    RegisterCommand(Config.AdminCommand, function()
        if isOpen then return close() end
        if not lib.callback.await('daddy_bills:isAdmin', false) then return lib.notify({ type = 'error', description = L('no_access') }) end
        open('admin')
    end, false)
end
AddEventHandler('daddy_bills:open', open)

RegisterNuiCallback('close', function(_, cb)
    close()
    cb({})
end)

local function forward(name, isWrite)
    RegisterNuiCallback(name, function(body, cb)
        local result = lib.callback.await('daddy_bills:call', false, name, body)
        if not isWrite and type(result) == 'table' and result.ok == false then return cb() end
        cb(result)
    end)
end

for _, name in ipairs({ 'profile', 'inbox', 'sent', 'bill', 'nearby', 'recurring', 'adminStats', 'adminBills', 'adminDebtors', 'adminDisputes', 'adminPlayers', 'bossStats', 'bossStaff', 'bossCustomers', 'bossBills', 'bossDisputes', 'bossSettings', 'templates' }) do forward(name, false) end
for _, name in ipairs({ 'create', 'pay', 'cancel', 'remind', 'dispute', 'disputeAnswer', 'show', 'autopay', 'recurringStop', 'adminAction', 'bossAction', 'bossRemindAll', 'bossSave', 'templateSave', 'templateDelete' }) do forward(name, true) end

-- a receipt without metadata: the last paid bills to pick from
RegisterNetEvent('daddy_bills:receipts', function(list)
    if type(list) ~= 'table' then return end
    local options = {}
    for _, entry in ipairs(list) do
        options[#options + 1] = {
            title = ('%s · %s'):format(entry.number, entry.issuer), description = ('%s · %s%d'):format(entry.label, Config.Currency, entry.total), icon = 'receipt',
            onSelect = function() TriggerServerEvent('daddy_bills:receipt', entry.id) end,
        }
    end
    if #options == 0 then return lib.notify({ type = 'inform', description = L('no_receipts') }) end
    lib.registerContext({ id = 'daddy_bills_receipts', title = L('receipts'), options = options })
    lib.showContext('daddy_bills_receipts')
end)

-- someone shows us a bill: opened read only, without the tablet in the hand
RegisterNetEvent('daddy_bills:shown', function(bill)
    if type(bill) ~= 'table' or isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'shown', lang = Config.Locale, bill = bill })
end)

-- a bill came in or changed while the tablet is open
RegisterNetEvent('daddy_bills:refresh', function()
    if isOpen then SendNUIMessage({ action = 'refresh' }) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isOpen then SetNuiFocus(false, false) end
    putAway()
end)
