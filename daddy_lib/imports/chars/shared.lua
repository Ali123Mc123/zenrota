-- Pure helpers for the characters bridge: gender, dates, slots and safe SQL names.
local shared = {}

local GENDER = { [0] = 'm', [1] = 'f', ['0'] = 'm', ['1'] = 'f', m = 'm', f = 'f', M = 'm', F = 'f' }

-- Where year, month and day sit in a date written in each order.
local ORDERS = { YMD = { 1, 2, 3 }, DMY = { 3, 2, 1 }, MDY = { 3, 1, 2 } }
local DAYS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

-- 'm' or 'f' from 0/1, '0'/'1' or 'm'/'f'; nil for anything else.
function shared.gender(value)
    return GENDER[value]
end

local function daysIn(year, month)
    if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then return 29 end
    return DAYS[month]
end

-- 'YYYY-MM-DD' from a date in the given order (a four-digit year first is always YMD), or nil when it cannot exist.
function shared.isoDate(text, order)
    if type(text) ~= 'string' then return nil end
    local a, b, c = text:match('^%s*(%d+)[-/.](%d+)[-/.](%d+)%s*$')
    if not a then return nil end
    local parts = { tonumber(a), tonumber(b), tonumber(c) }
    local at = #a == 4 and ORDERS.YMD or ORDERS[order or 'YMD'] or ORDERS.YMD
    local year, month, day = parts[at[1]], parts[at[2]], parts[at[3]]
    if year < 1000 or year > 9999 or month < 1 or month > 12 or day < 1 or day > daysIn(year, month) then return nil end
    return ('%04d-%02d-%02d'):format(year, month, day)
end

-- An ISO date written in another order with slashes, as esx_identity stores it.
function shared.formatDate(iso, order)
    local year, month, day = tostring(iso or ''):match('^(%d%d%d%d)-(%d%d)-(%d%d)$')
    if not year then return nil end
    if order == 'DMY' then return ('%s/%s/%s'):format(day, month, year) end
    if order == 'MDY' then return ('%s/%s/%s'):format(month, day, year) end
    return ('%s/%s/%s'):format(year, month, day)
end

-- Slot of a prefixed identifier: slotOf('char3:abc', 'char') is 3.
function shared.slotOf(identifier, prefix)
    if type(identifier) ~= 'string' or type(prefix) ~= 'string' then return nil end
    if identifier:sub(1, #prefix) ~= prefix then return nil end
    return tonumber(identifier:sub(#prefix + 1):match('^(%d+):'))
end

-- The lowest index none of the rows uses.
function shared.freeSlot(rows)
    local used = {}
    for _, row in ipairs(rows or {}) do
        if row.slot then used[row.slot] = true end
    end
    local slot = 1
    while used[slot] do slot = slot + 1 end
    return slot
end

local function point(x, y, z, w)
    if vector4 then return vector4(x, y, z, w) end
    return { x = x, y = y, z = z, w = w }
end

-- A vector4 from a vector or a { x, y, z } table with w, a or heading; nil without coordinates.
function shared.vec4(pos)
    local kind = type(pos)
    if kind == 'vector4' then return pos end
    if kind == 'vector3' then return point(pos.x, pos.y, pos.z, 0.0) end
    if kind ~= 'table' then return nil end
    local x, y, z = tonumber(pos.x or pos[1]), tonumber(pos.y or pos[2]), tonumber(pos.z or pos[3])
    if not (x and y and z) then return nil end
    return point(x, y, z, tonumber(pos.w or pos.a or pos.heading or pos[4]) or 0.0)
end

-- The first n characters of a UTF-8 text; a cut never splits a character.
function shared.cut(text, n)
    if type(text) ~= 'string' then return nil end
    local stop = utf8.offset(text, n + 1)
    return stop and text:sub(1, stop - 1) or text
end

-- A table or column name that is safe to put in backticks.
function shared.safeName(name)
    return type(name) == 'string' and #name <= 64 and name:match('^[%w_]+$') ~= nil
end

-- Escapes %, _ and backslash so text matches itself inside SQL LIKE.
function shared.likeEscape(text)
    return (tostring(text):gsub('[\\%%_]', '\\%0'))
end

return shared
