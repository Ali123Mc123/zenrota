-- Phone numbers: the main phone's table when one runs (lb-phone, cylex_phone), then the framework's own column or charinfo.
local has = DL.require('fw/schema')
local phone = {}

local function lbPhone()
    return GetResourceState('lb-phone') == 'started' and has('phone_phones', 'owner_id') and has('phone_phones', 'phone_number')
end

-- cylex_phone keeps each character's number itself (identifier = citizenid), apart from the framework's column.
local function cylexPhone()
    return GetResourceState('cylex_phone') == 'started' and has('cylex_phone_userdata', 'identifier') and has('cylex_phone_userdata', 'phoneNumber')
end

local function text(value)
    value = value ~= nil and tostring(value) or ''
    return value ~= '' and value or nil
end

-- { [character id] = number } from the main phone for a batch of characters.
function phone.lookup(ids)
    local out = {}
    if #ids == 0 then return out end
    if lbPhone() then
        local ok, rows = pcall(MySQL.query.await, 'SELECT owner_id, phone_number FROM phone_phones WHERE owner_id IN (?)', { ids })
        for _, row in ipairs(ok and rows or {}) do out[row.owner_id] = row.phone_number end
    elseif cylexPhone() then
        local ok, rows = pcall(MySQL.query.await, 'SELECT identifier, phoneNumber FROM cylex_phone_userdata WHERE identifier IN (?)', { ids })
        for _, row in ipairs(ok and rows or {}) do out[row.identifier] = row.phoneNumber end
    end
    return out
end

-- The first number in the chain: the main phone, the phone_number column, then charinfo.phone.
function phone.pick(numbers, id, column, fallback)
    return text(numbers[id]) or text(column) or text(fallback)
end

return phone
