-- Faults (DL.fault, since 1.20.0): a caught error is stored by the lib under a short code the player can read out; a
-- refusal with no text and an item nothing handles are stored once. `daddy faults` lists them.
--   local ok, result = DL.fault.call('lessons.save', source, data, handler, source, data)  -- false, code when it threw
local fault = {}

-- Long strings and deep tables are cut, so an upload or a picture never lands in the log.
local function clean(value, depth)
    local kind = type(value)
    if kind == 'number' or kind == 'boolean' then return value end
    if kind == 'string' then return #value > 200 and ('<%d chars>'):format(#value) or value end
    if kind ~= 'table' then return tostring(value) end
    if depth > 3 then return '<table>' end
    local out = {}
    for key, item in pairs(value) do
        key = tostring(key)
        local secret = key:lower():find('pass') or key:lower():find('pin') or key:lower():find('secret') or key:lower():find('token')
        out[key] = secret and '<hidden>' or clean(item, depth + 1)
    end
    return out
end

local function send(kind, place, source, detail, input)
    source = tonumber(source)
    local player = source ~= nil and source > 0
    local ok, code = pcall(function()
        return exports.daddy_lib:fault({
            kind = kind, product = DL.product.id or DL.resource, place = place, source = source,
            citizenid = player and DL.fw.citizenId(source) or nil, player = player and GetPlayerName(source) or nil,
            detail = detail ~= nil and tostring(detail) or nil, input = input ~= nil and json.encode(clean(input, 1)) or nil,
        })
    end)
    if not ok then print(('^1[%s] %s %s: %s^7'):format(DL.resource, kind, place, tostring(detail))) end
    return ok and code or 'K-0000'
end

-- Test mode (ConfigSv.Test in daddy_lib/config_sv.lua): players are also told the raw reason of a refusal that has no text.
function fault.testing()
    return GetConvar('daddy:test', '0') == '1'
end

-- A notice outside the product's own UI: ox_lib's when it runs, else the game's feed.
function fault.tell(source, text, kind)
    source = tonumber(source)
    if not source or source <= 0 or not text then return end
    if GetResourceState('ox_lib') == 'started' then
        return TriggerClientEvent('ox_lib:notify', source, { description = text, type = kind or 'error', duration = 10000 })
    end
    TriggerClientEvent('daddy_lib:notice', source, text)
end

-- Stores an error a product caught; returns its code. place: 'module.callback'.
function fault.report(place, source, err, input)
    return send('error', place, source, err, input)
end

-- Runs fn(...): true and its results, or false and the code of the stored error (with the stack).
function fault.call(place, source, input, fn, ...)
    local result = table.pack(xpcall(fn, debug.traceback, ...))
    if result[1] then return true, table.unpack(result, 2, result.n) end
    return false, fault.report(place, source, result[2], input)
end

-- The player's text for a stored error: 'Something went wrong (code K-4F2A)'.
function fault.text(code)
    return DL.locale.lib('fault.code', code)
end

-- A refusal the UI has no text for; key: 'errors.permit_expired'.
function fault.missing(source, key, input)
    send('text', key, source, nil, input)
end

-- An item that points at this resource and has no handler: the player is told and keeps it.
function fault.item(source, item)
    local definition = DL.inv.definition(item)
    fault.tell(source, DL.locale.lib('fault.item', type(definition) == 'table' and definition.label or item), 'warning')
    send('item', item, source)
end

return fault
