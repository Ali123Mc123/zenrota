-- Another resource's config file (one that returns a table), run in a sandbox.
local config = {}

-- The table the file returns, or nil when it is missing or fails.
function config.read(resource, path)
    local source = LoadResourceFile(resource, path)
    if not source then return nil end
    local chunk = load(source, ('@@%s/%s'):format(resource, path), 't', setmetatable({}, { __index = _G }))
    if not chunk then return nil end
    local ok, out = pcall(chunk)
    return ok and type(out) == 'table' and out or nil
end

return config
