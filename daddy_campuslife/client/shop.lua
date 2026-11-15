-- Student shops on the client: a shelf's price labels, the bag in hand while the basket has something, and paying at
-- a self till. The basket lives on the server; this side only shows it.
if not Config.Shop or not Config.Shop.Enabled then return end

local t = DL.locale.t
local cfg = Config.Shop
local bag

local function play(anim)
    if not anim or not pcall(lib.requestAnimDict, anim.Dict, 2500) then return end
    TaskPlayAnim(cache.ped, anim.Dict, anim.Name, 3.0, 3.0, anim.Ms or 1200, 48, 0.0, false, false, false)
    SetTimeout(anim.Ms or 1200, function() RemoveAnimDict(anim.Dict) end)
end

-- The shopping bag in hand, seen by everyone, while the basket is not empty.
local function holdBag(on)
    if on == (bag ~= nil) then return end
    if not on then
        if DoesEntityExist(bag) then DeleteEntity(bag) end
        bag = nil
        return
    end
    local hash = joaat(cfg.Basket.Model)
    if not IsModelInCdimage(hash) or not pcall(lib.requestModel, hash, 3000) then return end
    local here, hand = GetEntityCoords(cache.ped), cfg.Basket.Hand
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    bag = CreateObject(hash, here.x, here.y, here.z + 0.2, true, true, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(bag, cache.ped, GetPedBoneIndex(cache.ped, hand.Bone), hand.Offset.x, hand.Offset.y, hand.Offset.z,
        hand.Rotation.x, hand.Rotation.y, hand.Rotation.z, true, true, false, true, 1, true)
end

RegisterNetEvent('daddy_campuslife:shop:basket', function(view)
    holdBag((view and view.count or 0) > 0)
    Nui.send('shop:basket', view)
end)

-- Shelves ------------------------------------------------------------------------------------------------

local function openShelf(record)
    local result = Campus.call('shop:shelf', { uid = record.uid })
    if not result.ok then return Campus.fail(result) end
    Nui.open('campus.shelf', result)
end

RegisterNUICallback('shop:pick', function(data, cb)
    local result = Campus.call('shop:pick', type(data) == 'table' and data or {})
    if result.ok then play(cfg.Anims.Pick) else Campus.fail(result) end
    cb(result)
end)

RegisterNUICallback('shop:drop', function(data, cb)
    cb(Campus.call('shop:drop', type(data) == 'table' and data or {}))
end)

-- Tills ----------------------------------------------------------------------------------------------------

local atTill -- the till uid this player works as cashier

local function openTill(record)
    local result = Campus.call('shop:basket')
    if not result.ok then return Campus.fail(result) end
    if (result.basket.count or 0) == 0 then return Nui.notify('shop.basket_none', 'inform') end
    Nui.open('campus.receipt', { till = record.uid, basket = result.basket })
end

local function openRegister(record)
    local result = Campus.call('shop:customers', { till = record.uid })
    if not result.ok then return Campus.fail(result) end
    Nui.open('campus.till', { till = record.uid, label = record.label, customers = result.customers, commission = result.commission,
        earned = result.earned, cap = result.cap })
end

local function takeTill(record, on)
    local result = Campus.call('shop:tillOn', { till = record.uid, on = on })
    if not result.ok then return Campus.fail(result) end
    atTill = on and record.uid or nil
    Nui.notify(on and 'shop.till_on' or 'shop.till_off', 'inform')
    if on then openRegister(record) end
end

Campus.kind('shop_till', function(record)
    return { options = {
        { name = 'campus_till', label = t('shop.till_target'), icon = 'fa-solid fa-cash-register', canInteract = function() return Campus.free() and atTill ~= record.uid end,
            onSelect = function() CreateThread(function() openTill(record) end) end },
        { name = 'campus_till_on', label = t('shop.till_take'), icon = 'fa-solid fa-user-tie', canInteract = function() return Campus.free() and atTill ~= record.uid end,
            onSelect = function() CreateThread(function() takeTill(record, true) end) end },
        { name = 'campus_till_screen', label = t('shop.till_screen'), icon = 'fa-solid fa-display', canInteract = function() return Campus.free() and atTill == record.uid end,
            onSelect = function() CreateThread(function() openRegister(record) end) end },
        { name = 'campus_till_off', label = t('shop.till_leave'), icon = 'fa-solid fa-person-walking-arrow-right', canInteract = function() return atTill == record.uid end,
            onSelect = function() CreateThread(function() takeTill(record, false) end) end },
    } }
end)

RegisterNUICallback('shop:pay', function(data, cb)
    local result = Campus.call('shop:pay', type(data) == 'table' and data or {})
    if result.ok then
        play(cfg.Anims.Pay)
        Nui.notify('shop.paid_self', 'success', result.total or 0)
    else
        Campus.fail(result)
    end
    cb(result)
end)

-- The cashier's screen: who is waiting, ringing a basket up.
RegisterNUICallback('shop:customers', function(data, cb) cb(Campus.call('shop:customers', type(data) == 'table' and data or {})) end)

RegisterNUICallback('shop:scan', function(data, cb)
    local result = Campus.call('shop:scan', type(data) == 'table' and data or {})
    if result.ok then play(cfg.Anims.Scan) else Campus.fail(result) end
    cb(result)
end)

RegisterNetEvent('daddy_campuslife:shop:till', function(data)
    if data and data.on == false and atTill == data.till then
        atTill = nil
        if Nui.isOpen('campus.till') then Nui.close() end
        Nui.notify('shop.till_off', 'inform')
    end
end)

-- A cashier rang this player's basket up: the receipt to confirm (closing it says no).
local request
RegisterNetEvent('daddy_campuslife:shop:request', function(data)
    request = data
    Nui.open('campus.receipt', { till = data.till, basket = data.basket, request = data.request, cashier = data.cashier })
end)

RegisterNUICallback('shop:confirm', function(data, cb)
    local result = Campus.call('shop:confirm', type(data) == 'table' and data or {})
    if result.ok and not result.declined then
        request = nil
        Nui.notify('shop.paid_self', 'success', result.total or 0)
    elseif not result.ok then
        Campus.fail(result)
    end
    cb(result)
end)

Nui.onClose('campus.receipt', function()
    if request then
        Campus.call('shop:confirm', { request = request.request, accept = false })
        request = nil
    end
end)

-- Restocking: a crate from the stock room, carried in both hands to a shelf of its category.
local crate -- { category, entity }

local function carry(category)
    local hash = joaat(cfg.Restock.CrateModel)
    if not pcall(lib.requestModel, hash, 3000) or not pcall(lib.requestAnimDict, 'anim@heists@box_carry@', 2500) then return end
    local here = GetEntityCoords(cache.ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local entity = CreateObject(hash, here.x, here.y, here.z + 0.2, true, true, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(entity, cache.ped, GetPedBoneIndex(cache.ped, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3.0, 3.0, -1, 49, 0.0, false, false, false)
    crate = { category = category, entity = entity }
    CreateThread(function()
        while crate and crate.entity == entity do
            DisableControlAction(0, 21, true) -- sprint
            DisableControlAction(0, 22, true) -- jump
            if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3.0, 3.0, -1, 49, 0.0, false, false, false)
            end
            Wait(0)
        end
    end)
end

local function letGo()
    if not crate then return end
    if DoesEntityExist(crate.entity) then DeleteEntity(crate.entity) end
    crate = nil
    StopAnimTask(cache.ped, 'anim@heists@box_carry@', 'idle', 2.0)
end

local function takeCrate(record)
    local options = {}
    for _, category in ipairs(Config.Canteen.Categories) do
        options[#options + 1] = { title = t('canteen.category_' .. category), icon = 'box', onSelect = function()
            CreateThread(function()
                local result = Campus.call('shop:crate', { uid = record.uid, category = category })
                if not result.ok then return Campus.fail(result) end
                carry(category)
                Nui.notify('shop.crate_taken', 'inform', t('canteen.category_' .. category))
            end)
        end }
    end
    lib.registerContext({ id = 'campus_shop_crate', title = t('shop.crate_title'), options = options })
    lib.showContext('campus_shop_crate')
end

local function stack(record)
    if not lib.progressBar({ duration = 2500, label = t('shop.stacking'), canCancel = true, disable = { move = true, combat = true },
        anim = { dict = 'pickup_object', clip = 'putdown_low' } }) then return end
    local result = Campus.call('shop:stack', { uid = record.uid })
    if not result.ok then return Campus.fail(result) end
    letGo()
    Nui.notify('shop.stacked', 'success', result.paid or 0)
end

Campus.kind('shop_stock', function(record)
    return { options = {
        { name = 'campus_crate', label = t('shop.crate_take'), icon = 'fa-solid fa-box', canInteract = function() return Campus.free() and not crate end,
            onSelect = function() takeCrate(record) end },
        { name = 'campus_crate_back', label = t('shop.crate_back'), icon = 'fa-solid fa-box-open', canInteract = function() return crate ~= nil end,
            onSelect = function() CreateThread(function() Campus.call('shop:dropCrate') letGo() end) end },
    } }
end)

-- A shelf: its labels, or stacking the crate in hand when it is of the shelf's category.
Campus.kind('shop_shelf', function(record)
    return { options = {
        { name = 'campus_shelf', label = t('shop.shelf_target'), icon = 'fa-solid fa-tags', canInteract = function() return Campus.free() and not crate end,
            onSelect = function() CreateThread(function() openShelf(record) end) end },
        { name = 'campus_stack', label = t('shop.stack'), icon = 'fa-solid fa-boxes-stacked',
            canInteract = function() return crate ~= nil and crate.category == record.settings.category end,
            onSelect = function() CreateThread(function() stack(record) end) end },
    } }
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then holdBag(false) letGo() end
end)
