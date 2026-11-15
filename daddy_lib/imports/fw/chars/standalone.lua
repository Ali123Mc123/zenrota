-- No character framework: owners by license so products can key their own rows, nothing else.
local function owners(source)
    local license = GetPlayerIdentifierByType(tostring(source), 'license')
    return license and { license } or {}
end

return {
    server = {
        supported = false,
        caps = { nationality = false, height = false, bio = false, phone = false, gang = false },
        owners = owners,
        list = function() return {} end,
        get = function() return nil end,
        owner = function() return nil end,
        loaded = function() return nil end,
        status = function() return {} end,
        vehicle = function() return nil end,

        conflicts = function()
            return { { level = 'warn', code = 'unsupported', text = 'No supported framework runs, so there are no characters to list or create' } }
        end,
    },

    client = {
        spawned = function() end,
        handoff = function() return false end,
    },
}
