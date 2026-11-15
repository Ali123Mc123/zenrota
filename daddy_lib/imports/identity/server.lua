-- Who a character is outside the game: license and Discord id, kept for offline lookups.
local identity = {}

local function identifiers(source)
    local discord = GetPlayerIdentifierByType(tostring(source), 'discord')
    return GetPlayerIdentifierByType(tostring(source), 'license'), discord and discord:gsub('^discord:', '') or nil
end

function identity.remember(source)
    local cid = DL.fw.citizenId(source)
    if not cid then return end
    local license, discord = identifiers(source)
    MySQL.insert([[INSERT INTO daddy_lib_identity (citizenid, license, discord, name, seen_at) VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE license = VALUES(license), discord = VALUES(discord), name = VALUES(name), seen_at = VALUES(seen_at)]],
        { cid, license, discord, DL.fw.playerName(source) or '', os.time() })
end

-- Records every character as it loads; call once from a product.
function identity.track()
    DL.fw.onLoaded(identity.remember)
    for _, id in ipairs(GetPlayers()) do identity.remember(tonumber(id)) end
end

-- Discord id of an online source or of any character seen before.
function identity.discord(target)
    if type(target) == 'number' then
        local _, discord = identifiers(target)
        return discord
    end
    return MySQL.scalar.await('SELECT discord FROM daddy_lib_identity WHERE citizenid = ?', { target })
end

-- Characters seen with a Discord id, newest first: { { citizenid, license, name, seen_at } }.
function identity.byDiscord(discordId)
    discordId = tostring(discordId or ''):match('^%d+$')
    if not discordId then return {} end
    return MySQL.query.await('SELECT citizenid, license, name, seen_at FROM daddy_lib_identity WHERE discord = ? ORDER BY seen_at DESC LIMIT 20', { discordId }) or {}
end

-- License of any character seen before.
function identity.license(citizenid)
    if type(citizenid) ~= 'string' or citizenid == '' then return nil end
    return MySQL.scalar.await('SELECT license FROM daddy_lib_identity WHERE citizenid = ?', { citizenid })
end

return identity
