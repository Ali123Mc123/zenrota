-- Bridge: everything the dispatch asks of your framework and notification script.
-- Every file in bridge/ is open: change it to fit your server. The product only calls the names below.
--
--   Bridge.fw         framework: identifier, name, job (name, label, grade, boss, on duty), callsign, phone, bank
--                     account, weapon labels, death
--   Bridge.notify     a short notice (client)
--   Bridge.hasItem    whether a player carries an item: the phone citizen calls may need (server, inventory.lua)
--   Bridge.inMinigame whether the player plays a paintball match: no automatic alerts then (client, minigames.lua)
--   Bridge.setRadio   moves the radio to a call's channel (client, radio.lua)
--
-- Which script is used comes from Config.Bridge in config/cfg_main.lua ('auto' finds the one that runs).
-- Adding one: copy an entry in its file, rename it, change the calls, and add its resource there.
Bridge = {
    side = IsDuplicityVersion() and 'server' or 'client',
    resource = GetCurrentResourceName(),
}

function Bridge.started(resource)
    return type(resource) == 'string' and GetResourceState(resource) == 'started'
end

function Bridge.warn(text, ...)
    print(('^3[%s] ' .. text .. '^7'):format(Bridge.resource, ...))
end

-- The first entry of a list whose resource runs, or the one Config.Bridge names.
function Bridge.pick(setting, entries)
    local wanted = (Config.Bridge or {})[setting]
    if type(wanted) == 'string' and wanted ~= 'auto' then
        for _, entry in ipairs(entries) do
            if entry.id == wanted then return entry end
        end
        return nil
    end
    for _, entry in ipairs(entries) do
        if entry.resource and Bridge.started(entry.resource) then return entry end
    end
    return nil
end
