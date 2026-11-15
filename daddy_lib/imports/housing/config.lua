-- Runs another resource's config file in a sandbox once and returns the globals it set, or nil.
local cache = {}

return function(resource, path)
    local key = resource .. '/' .. path
    if cache[key] == nil then
        local env = setmetatable({}, { __index = _G })
        local source = LoadResourceFile(resource, path)
        local chunk = source and load(source, ('@@%s/%s'):format(resource, path), 't', env)
        cache[key] = chunk and pcall(chunk) and env or false
    end
    return cache[key] or nil
end
