-- Client bridge: targets, prompts and stashes. Change it to fit your server.

local prompts = {}

local hinted
function Bridge.hint(h)
    local keys, parts = {}, {}
    for i, k in ipairs(h and h.keys or {}) do
        keys[i] = { k = k[1], text = Core.t(k[2]) }
        parts[i] = ('[%s] %s'):format(k[1], keys[i].text)
    end
    local text = h and ('%s%s  ·  %s'):format(h.label, h.sub and ('  ·  ' .. h.sub) or '', table.concat(parts, '  ·  ')) or nil
    if text == hinted then return end
    hinted = text
    if Config.Interact == 'textui' then
        if text then lib.showTextUI(text) else lib.hideTextUI() end
        return
    end
    SendNUIMessage({ action = 'mech:prompt', show = h ~= nil, label = h and h.label or '', sub = h and h.sub or '', keys = keys })
end

function Bridge.spot(id, coords, options)
    if Bridge.started('ox_target') then
        return exports.ox_target:addSphereZone({ coords = coords, radius = 1.2, options = (function()
            local out = {}
            for i, o in ipairs(options) do
                out[i] = { name = id .. ':' .. i, label = o.label, icon = o.icon, onSelect = o.onSelect, canInteract = o.canInteract }
            end
            return out
        end)() })
    end
    if Bridge.started('qb-target') then
        local list = {}
        for i, o in ipairs(options) do list[i] = { label = o.label, icon = o.icon, action = o.onSelect, canInteract = o.canInteract } end
        exports['qb-target']:AddCircleZone(id, coords, 1.2, { name = id, useZ = true }, { options = list, distance = 2.0 })
        return id
    end
    prompts[id] = lib.points.new({
        coords = coords,
        distance = 1.5,
        nearby = function()
            local o = options[1]
            if o.canInteract and not o.canInteract() then return end
            Bridge.hint({ label = o.label, keys = { { 'E', 'ui.hint_use' } } })
            if IsControlJustReleased(0, Config.Key) then o.onSelect() end
        end,
        onExit = function() Bridge.hint(nil) end,
    })
    return id
end

function Bridge.openStash(id)
    if Bridge.started('ox_inventory') then return exports.ox_inventory:openInventory('stash', id) end
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', id)
    TriggerEvent('inventory:client:SetCurrentStash', id)
end

function Bridge.down()
    if IsPedDeadOrDying(cache.ped, true) then return true end
    local ok, meta = pcall(function()
        if Bridge.started('qbx_core') then return exports.qbx_core:GetPlayerData().metadata end
        if Bridge.started('qb-core') then return exports['qb-core']:GetCoreObject().Functions.GetPlayerData().metadata end
    end)
    return ok and type(meta) == 'table' and (meta.isdead == true or meta.inlaststand == true) or false
end

function Bridge.count(item)
    if Bridge.started('ox_inventory') then return exports.ox_inventory:Search('count', item) or 0 end
    local ok, items = pcall(function()
        if Bridge.started('qb-core') then return exports['qb-core']:GetCoreObject().Functions.GetPlayerData().items end
        if Bridge.started('es_extended') then return exports.es_extended:getSharedObject().GetPlayerData().inventory end
    end)
    local n = 0
    for _, it in pairs(ok and items or {}) do
        if type(it) == 'table' and it.name == item then n = n + (tonumber(it.amount or it.count) or 0) end
    end
    return n
end

function Bridge.job()
    local ok, job = pcall(function()
        if Bridge.started('qbx_core') then return exports.qbx_core:GetPlayerData().job end
        if Bridge.started('qb-core') then return exports['qb-core']:GetCoreObject().Functions.GetPlayerData().job end
        if Bridge.started('es_extended') then
            local j = exports.es_extended:getSharedObject().GetPlayerData().job
            return j and { name = j.name, onduty = j.onDuty ~= false }
        end
    end)
    if not ok or not job then return nil end
    return { name = job.name, duty = job.onduty ~= false }
end
