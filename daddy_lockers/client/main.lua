-- Lockers on the client: a target on every locker, the keypad and the storage view, the alarm and breaking in.
-- What the options show is only a hint; the server decides every action.
local t = DL.locale.t
Lockers = { spots = {}, rentals = {}, canRent = false, canSearch = false, current = nil }

local function call(name, data)
    return Nui.result(lib.callback.await('daddy_lockers:' .. name, false, data or {}))
end
Lockers.call = call

-- A failed answer as a notice: each code has its text under lockers.<code>; its numbers fill the text.
function Lockers.fail(result)
    local key = 'lockers.' .. (result and result.error or 'unavailable')
    if t(key) == key then key = 'lockers.unavailable' end
    Nui.notify(key, 'error', result and (result.seconds or result.price or result.max or result.user))
end

local function cid() return DL.fw.citizenId() end
function Lockers.rental(uid) return Lockers.rentals[uid] end
function Lockers.mine(uid) local r = Lockers.rentals[uid] return r ~= nil and r.ownerCid == cid() end

function Lockers.holdsKey(uid)
    local rental, me = Lockers.rentals[uid], cid()
    if not rental then return false end
    if rental.ownerCid == me then return true end
    for _, holder in ipairs(rental.keys or {}) do
        if holder == me then return true end
    end
    return false
end

-- Keypad and storage -------------------------------------------------------------------------------------

function Lockers.keypad(mode, spot, terms)
    if Nui.isOpen() then return end
    Lockers.current = { uid = spot.uid, mode = mode }
    local rental = Lockers.rentals[spot.uid]
    Nui.open('lockers.keypad', { mode = mode, uid = spot.uid, label = spot.label, code = spot.code, pinLength = spot.pinLength,
        plate = rental and rental.plate or 'classic', owner = rental and rental.owner, title = rental and rental.title, terms = terms,
        notes = rental ~= nil and (rental.unread or 0) > 0, paint = spot.paint })
end

function Lockers.showStorage(result)
    if not result.ok then return Lockers.fail(result) end
    Lockers.current = { uid = result.uid, mode = 'storage' }
    Nui.open('lockers.keypad', result)
end

-- Answers a lock forcing ticket once: the ticket is spent whatever the server says.
local function finishPick(current, success)
    local ticket = current.ticket
    current.ticket = nil
    ClearPedTasks(cache.ped)
    return call('lockpickFinish', { uid = current.uid, ticket = ticket, success = success })
end

Nui.onClose('lockers.keypad', function()
    local current = Lockers.current
    if current and current.mode == 'storage' then call('close') end
    if current and current.mode == 'lockpick' and current.ticket then CreateThread(function() finishPick(current, false) end) end
    Lockers.current = nil
end)

RegisterNUICallback('lockers:pin', function(data, cb)
    local current = Lockers.current
    if not current or type(data) ~= 'table' then return cb({ ok = false, error = 'validation' }) end
    if current.mode == 'open' then
        local result = call('open', { uid = current.uid, pin = data.pin })
        if result.ok then current.mode = 'storage' end
        cb(result)
        -- A wrong PIN and a lockout stay on the door; anything else closes it.
        if not result.ok and result.error ~= 'wrong_pin' and result.error ~= 'pin_locked' then
            Nui.close()
            Lockers.fail(result)
        end
        return
    end
    local result = call(current.mode == 'rent' and 'rent' or 'changePin', { uid = current.uid, pin = data.pin })
    cb(result)
    if not result.ok then
        Nui.close()
        return Lockers.fail(result)
    end
    -- The slip is stamped and the handle lifts before the door is left.
    SetTimeout(1400, function() if Lockers.current == current then Nui.close() end end)
    if current.mode == 'rent' then
        Nui.notify('lockers.rented', 'success', os.date('%d.%m.%Y %H:%M', result.expiresAt))
        if (result.discount or 0) > 0 then Nui.notify('lockers.discount', 'inform', result.discount) end
    else
        Nui.notify('lockers.pin_changed', 'success')
    end
end)

RegisterNUICallback('lockers:deposit', function(data, cb)
    data = type(data) == 'table' and data or {}
    cb(call('deposit', { uid = Lockers.current and Lockers.current.uid, slot = data.slot, name = data.name, count = data.count }))
end)

RegisterNUICallback('lockers:withdraw', function(data, cb)
    data = type(data) == 'table' and data or {}
    cb(call('withdraw', { uid = Lockers.current and Lockers.current.uid, id = data.id, count = data.count }))
end)

-- Flows --------------------------------------------------------------------------------------------------

-- The door opens with the rental slip clipped on; the PIN set on the dial signs the rent.
local function rent(spot)
    local info = call('price', { uid = spot.uid })
    if not info.ok then return Lockers.fail(info) end
    Lockers.keypad('rent', spot, info)
end

local function quickOpen(spot)
    local result = call('quickOpen', { uid = spot.uid })
    if result.ok then return Lockers.showStorage(result) end
    if result.error == 'no_permission' then return Lockers.keypad('open', spot) end
    Lockers.fail(result)
end

local function search(spot)
    local result = call('search', { uid = spot.uid })
    if result.ok then Nui.notify('lockers.searched', 'inform') end
    Lockers.showStorage(result)
end

-- One ticket from the server for each try: the door opens in its forcing mode, and its outcome goes back with the
-- ticket. Walking away from it (Esc) counts as a failed try, as cancelling the old skill check did.
local function lockpick(spot)
    if Nui.isOpen() then return end
    local start = call('lockpickStart', { uid = spot.uid })
    if not start.ok then return Lockers.fail(start) end
    Lockers.current = { uid = spot.uid, mode = 'lockpick', ticket = start.ticket }
    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_PARKING_METER', 0, true)
    local rental = Lockers.rentals[spot.uid]
    Nui.open('lockers.keypad', { mode = 'lockpick', uid = spot.uid, label = spot.label, code = spot.code, stages = start.stages, paint = spot.paint,
        plate = rental and rental.plate or 'classic', owner = rental and rental.owner, title = rental and rental.title })
end

RegisterNUICallback('lockers:lockpicked', function(data, cb)
    local current = Lockers.current
    if not current or current.mode ~= 'lockpick' or not current.ticket then return cb({ ok = false }) end
    local result = finishPick(current, type(data) == 'table' and data.success == true)
    cb({ ok = result.ok })
    -- The handle lifts or the pick bends on the door first.
    SetTimeout(900, function()
        if Lockers.current ~= current then return end
        if not result.ok then
            Nui.close()
            return Lockers.fail(result)
        end
        Nui.notify('lockers.lockpick_done', 'success')
        -- Closed with no current first, so closing the forcing door does not end the session just opened.
        Lockers.current = nil
        Nui.close()
        Lockers.showStorage(result)
    end)
end)

-- Targets ------------------------------------------------------------------------------------------------

local targets = {}

local function free() return not Nui.isOpen() and not IsPedInAnyVehicle(cache.ped, false) and not IsEntityDead(cache.ped) end

local function options(spot)
    local uid = spot.uid
    local rented = function() return Lockers.rentals[uid] ~= nil end
    local reserved = function() return (GlobalState['daddy_lockers:reserved'] or {})[uid] ~= nil end
    local granted = function() return Lockers.rentals[uid] ~= nil and Lockers.rentals[uid].granted ~= nil end
    return {
        { label = t('lockers.target_rent'), icon = 'fa-solid fa-key', canInteract = function() return free() and not rented() and not reserved() and Lockers.canRent end,
            onSelect = function() CreateThread(function() rent(spot) end) end },
        { label = t('lockers.target_open'), icon = 'fa-solid fa-lock-open', canInteract = function() return free() and rented() and Lockers.holdsKey(uid) end,
            onSelect = function() CreateThread(function() quickOpen(spot) end) end },
        { label = t('lockers.target_pin'), icon = 'fa-solid fa-hashtag', canInteract = function() return free() and rented() and not granted() and not Lockers.holdsKey(uid) end,
            onSelect = function() Lockers.keypad('open', spot) end },
        { label = t('lockers.target_manage'), icon = 'fa-solid fa-sliders', canInteract = function() return free() and Lockers.mine(uid) end,
            onSelect = function() CreateThread(function() quickOpen(spot) end) end },
        { label = t('lockers.target_note'), icon = 'fa-solid fa-envelope', canInteract = function() return free() and Config.Notes.Enabled and rented() and not Lockers.mine(uid) end,
            onSelect = function() CreateThread(function() Lockers.leaveNote(spot) end) end },
        { label = t('lockers.target_lockpick'), icon = 'fa-solid fa-unlock-keyhole', canInteract = function() return free() and Config.Lockpick.Enabled and rented() and not Lockers.holdsKey(uid) end,
            onSelect = function() CreateThread(function() lockpick(spot) end) end },
        { label = t('lockers.target_search'), icon = 'fa-solid fa-magnifying-glass', canInteract = function() return free() and rented() and Lockers.canSearch end,
            onSelect = function() CreateThread(function() search(spot) end) end },
    }
end

local function rebuild()
    local seen = {}
    for _, spot in ipairs(Lockers.list or {}) do
        local key = 'locker:' .. spot.uid
        seen[key] = true
        if not targets[key] then
            DL.target.addSphere(key, { coords = vector3(spot.coords.x, spot.coords.y, spot.coords.z), radius = 0.6, distance = Config.Interact.Distance, options = options(spot) })
            targets[key] = true
        end
    end
    for key in pairs(targets) do
        if not seen[key] then
            DL.target.remove(key)
            targets[key] = nil
        end
    end
end

function Lockers.reload()
    local data = lib.callback.await('daddy_lockers:spots', false)
    if type(data) ~= 'table' then return end
    for key in pairs(targets) do DL.target.remove(key) end
    targets = {}
    Lockers.list, Lockers.spots = data.spots or {}, {}
    for _, spot in ipairs(Lockers.list) do Lockers.spots[spot.uid] = spot end
    Lockers.rentals = data.rentals or {}
    Lockers.canRent, Lockers.canSearch = data.canRent == true, data.canSearch == true
    rebuild()
    TriggerEvent('daddy_lockers:changed')
end

RegisterNetEvent('daddy_lockers:sync', function(uid, rental)
    Lockers.rentals[uid] = rental
    TriggerEvent('daddy_lockers:changed', uid)
end)

-- Spread over two seconds so a whole server does not ask at once; several notices make one reload.
local reloading = false
RegisterNetEvent('daddy_lockers:spotsChanged', function()
    if reloading then return end
    reloading = true
    SetTimeout(math.random(0, 2000), function()
        reloading = false
        Lockers.reload()
    end)
end)

CreateThread(function()
    DL.fw.awaitLogin()
    Lockers.reload()
end)

DL.fw.onLoaded(function() CreateThread(Lockers.reload) end)

-- The alarm --------------------------------------------------------------------------------------------
-- Louder close by, never silent while it rings and the player is near.

local alarmSession = 0

RegisterNetEvent('daddy_lockers:alarm', function(coords, radius, volume, seconds)
    alarmSession = alarmSession + 1
    local session = alarmSession
    local at = vector3(coords.x, coords.y, coords.z)
    CreateThread(function()
        local ends = GetGameTimer() + seconds * 1000
        Nui.send('lockers:alarmStart')
        while GetGameTimer() < ends and session == alarmSession do
            local distance = #(GetEntityCoords(cache.ped) - at)
            Nui.send('lockers:alarmVolume', { volume = distance <= radius and math.max(0.3, (1.0 - distance / radius)) * volume or 0.0 })
            Wait(100)
        end
        if session == alarmSession then Nui.send('lockers:alarmStop') end
    end)
end)

-- The lost-and-found at Student Affairs ------------------------------------------------------------------

local function offerClaim()
    local college = DL.product.resource('college')
    if not college then return end
    pcall(function()
        exports[college]:RegisterAffairsAction('unclaimed', { text = t('lockers.affairs_unclaimed'), icon = 'fa-solid fa-box-archive', order = 70, event = 'daddy_lockers:claimUnclaimed' })
    end)
end

AddEventHandler('daddy_lockers:claimUnclaimed', function()
    CreateThread(function()
        local result = call('claimUnclaimed')
        if not result.ok then return Lockers.fail(result) end
        Nui.notify(result.partial and 'lockers.unclaimed_partial' or 'lockers.unclaimed_done', result.partial and 'warning' or 'success')
    end)
end)

-- Offered again whenever College starts, as it forgets options of other products then.
AddEventHandler('onClientResourceStart', function(resource)
    local college = (GlobalState['daddy_lib:products'] or {}).college
    if resource == college or resource == GetCurrentResourceName() then SetTimeout(1500, offerClaim) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for key in pairs(targets) do DL.target.remove(key) end
end)
