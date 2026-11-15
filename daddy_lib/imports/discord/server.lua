-- Discord: webhook posts per product; members, roles and the bot go through the lib's one shared service.
-- Convars (use set, never setr): daddy:webhook:<product>:<channel>, daddy:discord_token, daddy:discord_guild, daddy:discord_bot.
local discord = {}
local queue, sending = {}, false
local SPACING_MS = 1200

local function webhook(channel)
    local url = GetConvar(('daddy:webhook:%s:%s'):format(DL.product.id or DL.resource, channel), '')
    return url ~= '' and url or nil
end

function discord.enabled(channel)
    return webhook(channel) ~= nil
end

-- message: { content?, embeds? }. Posts go out one at a time to stay under Discord's limits.
function discord.post(channel, message)
    local url = webhook(channel)
    if not url then return false end
    queue[#queue + 1] = { url = url, body = json.encode(message) }
    if sending then return true end
    sending = true
    CreateThread(function()
        while #queue > 0 do
            local item = table.remove(queue, 1)
            PerformHttpRequest(item.url, function() end, 'POST', item.body, { ['Content-Type'] = 'application/json' })
            Wait(SPACING_MS)
        end
        sending = false
    end)
    return true
end

-- True when the bot token and guild convars are set.
function discord.configured()
    return exports.daddy_lib:discordConfigured()
end

-- Guild member { id, roles, nick, name, avatarUrl, booster, ... }, or nil and off|not_linked|not_in_guild|forbidden|unavailable.
function discord.member(discordId, fresh)
    local member, code = exports.daddy_lib:discordMember(discordId, fresh)
    return member or nil, code
end

-- Any Discord account { id, username, globalName, avatarUrl }, also outside the guild.
function discord.user(discordId)
    local user, code = exports.daddy_lib:discordUser(discordId)
    return user or nil, code
end

-- Roles saved at the last good answer, for Discord outages: { roles, nick, booster, inGuild, fetchedAt } or nil.
function discord.lastKnown(discordId)
    return exports.daddy_lib:discordLastKnown(discordId) or nil
end

-- Role ids of a guild member; nil without a bot or when Discord does not answer.
function discord.roles(discordId)
    local member = discord.member(discordId)
    return member and member.roles or nil
end

function discord.hasRole(discordId, roleId)
    return DL.util.contains(discord.roles(discordId), tostring(roleId))
end

-- Gives a role; true, or false and a code.
function discord.addRole(discordId, roleId, reason)
    return exports.daddy_lib:discordAddRole(discordId, roleId, reason)
end

-- Takes a role from a guild member; true, or false and a code.
function discord.removeRole(discordId, roleId, reason)
    local ok, code = exports.daddy_lib:discordRemoveRole(discordId, roleId, reason)
    return ok == true, code
end

-- Guild structure for products that keep their own roles and channels; each returns the data, or nil and a code
-- (off, forbidden, bad_role, bad_channel, unavailable).
function discord.botUser()
    local user, code = exports.daddy_lib:discordBotUser()
    return user or nil, code
end

function discord.guildRoles()
    local list, code = exports.daddy_lib:discordGuildRoles()
    return list or nil, code
end

function discord.guildChannels()
    local list, code = exports.daddy_lib:discordGuildChannels()
    return list or nil, code
end

-- body as Discord takes it: { name, color, hoist, mentionable, permissions = '0' }.
function discord.createRole(body, reason)
    local role, code = exports.daddy_lib:discordCreateRole(body, reason)
    return role or nil, code
end

-- body as Discord takes it: { name, type, parent_id, permission_overwrites }.
function discord.createChannel(body, reason)
    local channel, code = exports.daddy_lib:discordCreateChannel(body, reason)
    return channel or nil, code
end

-- Only body.permission_overwrites is sent.
function discord.editChannel(channelId, body, reason)
    local channel, code = exports.daddy_lib:discordEditChannel(channelId, body, reason)
    return channel or nil, code
end

-- { {ok, text} } for the token, guild, the given role and channel ids, and the bot.
function discord.doctor(opts)
    return exports.daddy_lib:discordDoctor(opts or {})
end

-- Forgets the cached member, so the next lookup asks Discord.
function discord.flush(discordId)
    return exports.daddy_lib:discordFlush(discordId)
end

-- Slash commands and buttons through the lib's bot; the handler export gets ctx and returns a reply.
discord.bot = {}

function discord.bot.commands(handlerExport, defs)
    return exports.daddy_lib:registerBotCommands(DL.product.id, handlerExport, defs, DL.locale.language())
end

function discord.bot.components(handlerExport)
    return exports.daddy_lib:registerBotComponents(DL.product.id, handlerExport, DL.locale.language())
end

-- Posts to a channel; returns the message id, or nil and a code.
function discord.bot.send(channelId, message)
    local id, err = exports.daddy_lib:botSend(channelId, message)
    return id or nil, err
end

function discord.bot.edit(channelId, messageId, message)
    return exports.daddy_lib:botEdit(channelId, messageId, message)
end

-- A further message on an interaction, within 15 minutes; ephemeral unless message.ephemeral is false.
function discord.bot.followUp(ctx, message)
    return exports.daddy_lib:botFollowUp(type(ctx) == 'table' and ctx.id or nil, message)
end

function discord.bot.status()
    return exports.daddy_lib:botStatus()
end

-- The loader merges shared.lua (avatarUrl, allowed, ...) into this module.
function discord.bot.allowed(ctx, roleIds)
    return discord.allowed(ctx, roleIds)
end

return discord
