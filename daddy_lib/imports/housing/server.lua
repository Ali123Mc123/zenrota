-- Homes for the spawn selector, from the scripts in the daddy:housing convar (auto, a comma list or none).
-- Entry: { key = '<provider>:<id>', provider, id, kind, label, coords = vector4, inside, meta }; inside = enter() places the player.
local PROVIDERS = { 'qbx_properties', 'qb_apartments', 'qb_houses', 'ps_housing', 'esx_property' }

local function wanted()
    local value = GetConvar('daddy:housing', 'auto')
    if value == 'auto' then return PROVIDERS end
    local list = {}
    for id in value:gmatch('[^,%s]+') do
        if DL.util.contains(PROVIDERS, id) then list[#list + 1] = id end
    end
    return list
end

local loaded = {}
local housing = { ids = {} }
for _, id in ipairs(wanted()) do
    local adapter = DL.require('housing/' .. id)
    loaded[#loaded + 1] = { id = id, adapter = adapter }
    if GetResourceState(adapter.resource) == 'started' then housing.ids[#housing.ids + 1] = id end
end

-- Adapters whose script runs right now.
local function active()
    local list = {}
    for _, entry in ipairs(loaded) do
        if GetResourceState(entry.adapter.resource) == 'started' then list[#list + 1] = entry end
    end
    return list
end

local function call(provider, name, ...)
    local fn = provider.adapter.server[name]
    if not fn then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then print(('^3[%s] housing %s.%s failed: %s^7'):format(DL.resource, provider.id, name, result)) end
    return ok and result or nil
end

-- JSON text, vector or { x, y, z, w|h|heading } as a vector4; nil without a position.
local function vec(value)
    if type(value) == 'string' then value = DL.util.decodeJson(value) end
    local kind = type(value)
    if kind == 'vector3' or kind == 'vector4' then return vector4(value.x, value.y, value.z, kind == 'vector4' and value.w or 0.0) end
    if kind ~= 'table' then return nil end
    local x, y, z = tonumber(value.x or value[1]), tonumber(value.y or value[2]), tonumber(value.z or value[3])
    if not (x and y and z) then return nil end
    return vector4(x, y, z, tonumber(value.w or value.h or value.heading or value[4]) or 0.0)
end

local function entry(provider, home)
    local coords = type(home) == 'table' and home.id ~= nil and vec(home.coords)
    if not coords then return nil end
    return { key = ('%s:%s'):format(provider.id, home.id), provider = provider.id, id = home.id, kind = home.kind or 'house',
        label = tostring(home.label or home.id), coords = coords, inside = home.inside == true, meta = home.meta }
end

function housing.homes(citizenid)
    local out = {}
    if type(citizenid) ~= 'string' or citizenid == '' then return out end
    for _, provider in ipairs(active()) do
        for _, home in ipairs(call(provider, 'homes', citizenid) or {}) do out[#out + 1] = entry(provider, home) end
    end
    return out
end

-- Checks a key a client picked against the character's own homes.
function housing.find(citizenid, key)
    if type(key) ~= 'string' then return nil end
    for _, home in ipairs(housing.homes(citizenid)) do
        if home.key == key then return home end
    end
    return nil
end

-- The home a character logged out inside, from its framework metadata (raw = { charinfo, metadata }).
function housing.resume(citizenid, raw)
    if type(citizenid) ~= 'string' or type(raw) ~= 'table' then return nil end
    for _, provider in ipairs(active()) do
        local home = entry(provider, call(provider, 'resume', citizenid, raw))
        if home then return home end
    end
    return nil
end

-- After a character loads: scripts that need data pushed to the client (qb-houses).
function housing.onLogin(source)
    for _, provider in ipairs(active()) do call(provider, 'onLogin', source) end
end

return housing
