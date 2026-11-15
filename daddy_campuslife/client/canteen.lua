-- The canteen shop and the vending machines.
local t = DL.locale.t
local VIEW = 'campus.canteen'

local function openCanteen(record)
    local result = Campus.call('canteen:open', { uid = record.uid })
    if not result.ok then return Campus.fail(result) end
    Nui.open(VIEW, result)
end

-- Config.Canteen.Enabled = false (DaddyRP): no clerk ped and no canteen screen; the vending machines below still work.
if Config.Canteen.Enabled ~= false then
    Campus.kind('canteen', function(record)
        return { options = { {
            name = 'campus_canteen', label = t('canteen.target'), icon = 'fa-solid fa-basket-shopping', canInteract = Campus.free,
            onSelect = function() CreateThread(function() openCanteen(record) end) end,
        } } }
    end)

    RegisterNUICallback('canteen:refresh', function(_, cb) cb(Campus.call('canteen:refresh')) end)
    RegisterNUICallback('canteen:checkout', function(data, cb) cb(Campus.call('canteen:checkout', type(data) == 'table' and data or {})) end)

    RegisterNetEvent('daddy_campuslife:canteen:stock', function(changes)
        if Nui.isOpen(VIEW) then Nui.send('canteen:stock', changes) end
    end)

    Nui.onClose(VIEW, function() TriggerServerEvent('daddy_campuslife:canteen:close') end)
end

-- Vending ----------------------------------------------------------------------------------------------

local buying = false

local function buy(record, entry, max)
    local input = lib.inputDialog(entry.label, { { type = 'number', label = t('vending.amount'), description = t('vending.unit_price', entry.price),
        default = 1, min = 1, max = max, required = true } })
    local count = input and math.floor(tonumber(input[1]) or 0)
    if not count or count < 1 then return end
    buying = true
    local done = lib.progressBar({ duration = Config.Vending.ProgressMs, label = t('vending.buying'), canCancel = true,
        disable = { move = true, car = true, combat = true }, anim = { dict = 'mini@sprunk', clip = 'plyr_buy_drink_pt1' } })
    if done then
        local result = Campus.call('vending:buy', { uid = record.uid, item = entry.item, count = count })
        if result.ok then Nui.notify('vending.bought', 'success', result.count, result.label, result.price)
        else Campus.fail(result) end
    end
    buying = false
end

local function openMachine(record)
    local result = Campus.call('vending:catalog', { uid = record.uid })
    if not result.ok then return Campus.fail(result) end
    if #result.items == 0 then return Nui.notify('vending.empty', 'inform') end
    local options = {}
    for _, entry in ipairs(result.items) do
        options[#options + 1] = { title = entry.label, description = t('vending.price', entry.price), image = entry.image, icon = 'cart-shopping',
            onSelect = function() CreateThread(function() buy(record, entry, result.max) end) end }
    end
    lib.registerContext({ id = 'campus_vending', title = result.label, options = options })
    lib.showContext('campus_vending')
end

Campus.kind('vending_machine', function(record)
    return { options = { {
        name = 'campus_vending', label = t('vending.target'), icon = 'fa-solid fa-cookie-bite',
        canInteract = function() return not buying and Campus.free() end,
        onSelect = function() CreateThread(function() openMachine(record) end) end,
    } } }
end)
