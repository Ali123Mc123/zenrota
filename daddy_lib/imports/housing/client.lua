-- Puts the player inside a home from DL.housing.homes/find/resume, through the housing script's own entry.
local PROVIDERS = { qbx_properties = true, qb_apartments = true, qb_houses = true, ps_housing = true, esx_property = true }
local housing = {}
local adapters = {}

local function adapterOf(provider)
    if adapters[provider] == nil then adapters[provider] = PROVIDERS[provider] and DL.require('housing/' .. provider) or false end
    return adapters[provider] or nil
end

-- Call after chars.login and chars.spawned. True when the script placed the player; false means teleport to entry.coords.
function housing.enter(entry)
    if type(entry) ~= 'table' or entry.inside ~= true then return false end
    local adapter = adapterOf(entry.provider)
    if not adapter or GetResourceState(adapter.resource) ~= 'started' then return false end
    local ok, placed = pcall(adapter.client.enter, entry)
    return ok and placed == true
end

return housing
