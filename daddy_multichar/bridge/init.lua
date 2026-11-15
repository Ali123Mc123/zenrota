-- Bridge: everything Multichar asks of your framework, clothing script, housing, inventory, weather sync and Discord.
-- Every file in bridge/ is open source: change it to fit your server. The product only calls the names below.
--
--   Bridge.fw          framework: citizenId, playerName, job, sourceOf, searchCharacters, vehiclesOf, onLoaded ...
--   Bridge.chars       characters: owners, list, get, create, login, logout, delete, status, vehicle, conflicts
--   Bridge.appearance  clothing: apply, applyPlayer, openCreator, fetch, get, has, save, serve ...
--   Bridge.skin        stored skin formats (illenium, skinchanger, qb-clothing) and default looks
--   Bridge.housing     homes for the spawn selector: homes, find, resume, enter, onLogin
--   Bridge.weather     pause, set and resume the weather sync for a scene
--   Bridge.inv         starter items: ready, add, has
--   Bridge.medical     down(source): dead or in last stand
--   Bridge.discord     guild members, users, roles
--   Bridge.perm        access rules (ace, job, gang, discord ...) and admin checks
--
-- Which script is used comes from Config.Bridge in config/cfg_main.lua ('auto' finds the one that runs).
--
-- Adding a framework:
--   1. In bridge/framework.lua, copy the qb section (its do ... end block) and rename it. Its last line registers it:
--      Bridge.frameworks['<name>'] = { server = { ... }, client = { ... } }
--   2. Change the functions that differ (each one has a one-line comment saying what it must return).
--   3. Keep the new section above the detection section at the end of the file.
--   4. Set Config.Bridge.Framework = '<name>', or add { id = '<name>', resource = '<core resource>' } to
--      AUTO in the detection section.
-- A clothing script is the same in bridge/appearance.lua (Bridge.appearances), a housing script in
-- bridge/housing.lua (Bridge.homes).
Bridge = {
    frameworks = {},  -- framework adapters by id
    appearances = {}, -- clothing adapters by id
    homes = {},       -- housing adapters by id
    side = IsDuplicityVersion() and 'server' or 'client',
    resource = GetCurrentResourceName(),
}

local builders = {}

-- A module built on first use (Bridge.fw, Bridge.chars ...), so every adapter file has loaded by then.
function Bridge.define(name, build)
    builders[name] = build
end

setmetatable(Bridge, {
    __index = function(self, name)
        local build = builders[name]
        if not build then return nil end
        local module = build()
        rawset(self, name, module)
        return module
    end,
})

-- A convar of this product (multichar:<name>), or the older daddy:<name> one, or the default.
function Bridge.convar(name, default)
    local value = GetConvar('multichar:' .. name, '')
    if value ~= '' then return value end
    return GetConvar('daddy:' .. name, default)
end

-- Config.Bridge[key]; 'auto' lets the convar decide, and 'auto' there means detect.
function Bridge.setting(key, convar)
    local value = (Config.Bridge or {})[key]
    if type(value) == 'string' and value ~= '' and value ~= 'auto' then return value end
    return Bridge.convar(convar, 'auto')
end

function Bridge.started(resource)
    return type(resource) == 'string' and GetResourceState(resource) == 'started'
end

function Bridge.warn(text, ...)
    print(('^3[%s] ' .. text .. '^7'):format(Bridge.resource, ...))
end
