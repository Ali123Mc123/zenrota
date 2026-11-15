-- esx_property: owners live in its memory, saved to properties.json every few minutes. Its shell entry is client-local,
-- so homes spawn at the door; after login it puts a character back inside by itself (users.last_property).
local function label(property)
    return (property.setName and property.setName ~= '') and property.setName or property.Name
end

-- The live list; the file can be minutes old, so it is only the fallback.
local function properties()
    local ok, list = pcall(function() return exports.esx_property:GetProperties() end)
    if ok and type(list) == 'table' then return list end
    return DL.util.decodeJson(LoadResourceFile('esx_property', 'properties.json'))
end

return {
    resource = 'esx_property',

    server = {
        homes = function(citizenid)
            local out = {}
            for index, property in ipairs(properties()) do
                if type(property) == 'table' and property.Owner == citizenid and property.Entrance then
                    out[#out + 1] = { id = index, kind = 'house', label = label(property), coords = property.Entrance, inside = false }
                end
            end
            return out
        end,
    },

    client = {
        enter = function() return false end,
    },
}
