-- Framework from the daddy:framework convar, or whichever is running.
local ORDER = {
    { id = 'qbx', resource = 'qbx_core' },
    { id = 'qb', resource = 'qb-core' },
    { id = 'esx', resource = 'es_extended' },
    { id = 'nd', resource = 'ND_Core' },
}

return function()
    local forced = GetConvar('daddy:framework', 'auto')
    if forced ~= 'auto' then return forced end
    for _, fw in ipairs(ORDER) do
        if GetResourceState(fw.resource) == 'started' then return fw.id end
    end
    return 'standalone'
end
