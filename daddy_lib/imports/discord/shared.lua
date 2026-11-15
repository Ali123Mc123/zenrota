-- Pure Discord helpers: avatar URLs, error codes and interaction payloads. No natives, so tests run it as is.
local shared = {}

local CDN = 'https://cdn.discordapp.com'
local KINDS = { [2] = 'command', [3] = 'component' }

local function extension(hash)
    return hash:sub(1, 2) == 'a_' and 'gif' or 'png'
end

-- (id >> 22) % 6 worked digit by digit on the string, so 32-bit integers are enough.
local function defaultIndex(user)
    local tag = tonumber(user.discriminator)
    if tag and tag > 0 then return tag % 5 end
    local rest, index = 0, 0
    for digit in tostring(user.id):gmatch('%d') do
        local value = rest * 10 + tonumber(digit)
        index, rest = (index * 10 + value // 4194304) % 6, value % 4194304
    end
    return index
end

-- Guild avatar first, then the account avatar, then Discord's default picture.
function shared.avatarUrl(user, member, guildId, size)
    if type(user) ~= 'table' or not user.id then return nil end
    size = math.floor(tonumber(size) or 128)
    if type(member) == 'table' and type(member.avatar) == 'string' and guildId then
        return ('%s/guilds/%s/users/%s/avatars/%s.%s?size=%d'):format(CDN, guildId, user.id, member.avatar, extension(member.avatar), size)
    end
    if type(user.avatar) == 'string' then
        return ('%s/avatars/%s/%s.%s?size=%d'):format(CDN, user.id, user.avatar, extension(user.avatar), size)
    end
    return ('%s/embed/avatars/%d.png'):format(CDN, defaultIndex(user))
end

-- An HTTP answer as a lib code: nil on success, else not_in_guild, forbidden or unavailable.
function shared.classify(status, data)
    status = tonumber(status) or 0
    if status >= 200 and status < 300 then return nil end
    local code = type(data) == 'table' and data.code or nil
    if status == 404 then return code == 10004 and 'forbidden' or 'not_in_guild' end
    if status == 401 or status == 403 then return 'forbidden' end
    return 'unavailable'
end

-- 'multichar:del:42:a' -> 'multichar', 'del', { '42', 'a' }.
function shared.customId(s)
    if type(s) ~= 'string' then return nil end
    local parts = {}
    for part in (s .. ':'):gmatch('([^:]*):') do parts[#parts + 1] = part end
    return parts[1], parts[2], { table.unpack(parts, 3) }
end

local function person(user, member, guildId)
    if type(user) ~= 'table' then return nil end
    return { id = user.id, username = user.username, globalName = user.global_name, avatarUrl = shared.avatarUrl(user, member, guildId) }
end

-- Subcommand names go to path, leaf options to options[name].
local function flatten(list, path, options)
    for _, option in ipairs(type(list) == 'table' and list or {}) do
        if option.type == 1 or option.type == 2 then
            path[#path + 1] = option.name
            flatten(option.options, path, options)
        else
            options[option.name] = option.value
        end
    end
end

-- A raw INTERACTION_CREATE payload as the ctx products receive; the token stays with the lib.
function shared.parseInteraction(d)
    local data = type(d.data) == 'table' and d.data or {}
    local member = type(d.member) == 'table' and d.member or nil
    local ctx = {
        kind = KINDS[d.type], id = d.id, command = data.name, path = {}, options = {},
        resolved = { users = {} }, customId = data.custom_id, values = data.values,
        user = person(member and member.user or d.user, member, d.guild_id), roles = member and member.roles or {},
        guildId = d.guild_id, channelId = d.channel_id or (d.channel or {}).id, messageId = (d.message or {}).id, locale = d.locale,
    }
    flatten(data.options, ctx.path, ctx.options)
    local resolved = type(data.resolved) == 'table' and data.resolved or {}
    for id, user in pairs(resolved.users or {}) do
        ctx.resolved.users[id] = person(user, (resolved.members or {})[id], d.guild_id)
    end
    if ctx.customId then
        local _, action, args = shared.customId(ctx.customId)
        ctx.action, ctx.args = action, args
    end
    return ctx
end

-- True when the interaction's member holds any of the role ids.
function shared.allowed(ctx, roleIds)
    local held = {}
    for _, id in ipairs(type(ctx) == 'table' and ctx.roles or {}) do held[tostring(id)] = true end
    for _, id in ipairs(type(roleIds) == 'table' and roleIds or { roleIds }) do
        if held[tostring(id)] then return true end
    end
    return false
end

return shared
