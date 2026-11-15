-- daddy_lib loader. Add '@daddy_lib/init.lua' to your shared_scripts.
local LIB = 'daddy_lib'
local SIDE = IsDuplicityVersion() and 'server' or 'client'

local MODULES = {
    util = true, locale = true, ratelimit = true, migrate = true,
    fw = true, inv = true, focus = true, pad = true, product = true,
    geo = true, perm = true, target = true, place = true, dui = true, mugshot = true,
    identity = true, discord = true, freecam = true, medical = true,
    chars = true, appearance = true, housing = true, weather = true,
    timeline = true, clock = true, net = true, fault = true, media = true,
}

if GetCurrentResourceName() == LIB then return end

assert(GetResourceState(LIB) == 'started', ('%s needs daddy_lib started first'):format(GetCurrentResourceName()))

local function run(path)
    local src = LoadResourceFile(LIB, path)
    if not src then return nil end
    return assert(load(src, ('@@%s/%s'):format(LIB, path)))()
end

DL = {
    VERSION = GetResourceMetadata(LIB, 'version', 0),
    resource = GetCurrentResourceName(),
}

-- Loads an internal file, e.g. DL.require('fw/qbx').
function DL.require(path)
    return run(('imports/%s.lua'):format(path))
end

-- Modules load on first use. The side table is the module; shared fills the gaps.
setmetatable(DL, {
    __index = function(self, name)
        if not MODULES[name] then return nil end
        local shared = run(('imports/%s/shared.lua'):format(name))
        local mod = run(('imports/%s/%s.lua'):format(name, SIDE)) or shared or {}
        for key, value in pairs(mod ~= shared and shared or {}) do
            if mod[key] == nil then mod[key] = value end
        end
        rawset(self, name, mod)
        return mod
    end,
})
