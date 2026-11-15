-- Access rules: a list where any match grants access.
--   { { type = 'job', name = 'police', grade = 2 }, { type = 'gang', name = 'ballas' }, { type = 'ace', name = 'group.vip' },
--     { type = 'citizenid', value = 'ABC123' }, { type = 'item', name = 'pass' }, { type = 'everyone' },
--     { type = 'role', product = 'college', name = 'teacher' },  -- asks that product's HasRole export
--     { type = 'discord', name = '<roleId>' } }                  -- a Discord guild role, checked last
local perm = {}

local CHECKS = {
    everyone = function() return true end,

    job = function(source, rule)
        local job = DL.fw.job(source)
        return job ~= nil and job.name == rule.name and (tonumber(job.grade) or 0) >= (tonumber(rule.grade) or 0)
    end,

    gang = function(source, rule)
        local gang = DL.fw.gang(source)
        return gang ~= nil and gang.name == rule.name and (tonumber(gang.grade) or 0) >= (tonumber(rule.grade) or 0)
    end,

    duty = function(source, rule)
        local job = DL.fw.job(source)
        return job ~= nil and job.name == rule.name and DL.fw.onDuty(source) == true
    end,

    ace = function(source, rule)
        return IsPlayerAceAllowed(tostring(source), rule.name)
    end,

    citizenid = function(source, rule)
        return DL.fw.citizenId(source) == rule.value
    end,

    item = function(source, rule)
        return DL.inv.has(source, rule.name)
    end,

    role = function(source, rule)
        local resource = DL.product.resource(rule.product)
        if not resource then return false end
        local ok, has = pcall(function() return exports[resource]:HasRole(source, rule.name) end)
        return ok and has == true
    end,

    discord = function(source, rule)
        local id = DL.identity.discord(source)
        local member = id and DL.discord.member(id)
        return type(member) == 'table' and DL.util.contains(member.roles, tostring(rule.name))
    end,
}

-- Admins of this product: ACE daddy.admin.<product> (daddy.admin covers all) or framework admin.
function perm.admin(source, product)
    return IsPlayerAceAllowed(tostring(source), ('daddy.admin.%s'):format(product)) or DL.fw.isAdmin(source)
end

-- Discord rules run last, so no HTTP call happens when a cheaper rule already grants.
function perm.check(source, rules)
    local later = {}
    for _, rule in ipairs(type(rules) == 'table' and rules or {}) do
        local check = CHECKS[rule.type]
        if rule.type == 'discord' then later[#later + 1] = rule
        elseif check and check(source, rule) then return true end
    end
    for _, rule in ipairs(later) do
        if CHECKS.discord(source, rule) then return true end
    end
    return false
end

-- 'job:police:2, duty:police, gang:ballas, ace:group.vip, cid:ABC123, item:pass, role:college:teacher, discord:123, everyone' <-> rules.
local SHORT = { cid = 'citizenid' }

function perm.parse(text)
    local rules = {}
    for entry in tostring(text or ''):gmatch('[^,%s]+') do
        local kind, a, b = entry:match('^(%w+):?([^:]*):?(.*)$')
        kind = SHORT[kind] or kind
        if kind == 'everyone' then rules[#rules + 1] = { type = 'everyone' }
        elseif (kind == 'job' or kind == 'gang') and a ~= '' then rules[#rules + 1] = { type = kind, name = a, grade = tonumber(b) }
        elseif kind == 'citizenid' and a ~= '' then rules[#rules + 1] = { type = 'citizenid', value = a }
        elseif (kind == 'ace' or kind == 'item' or kind == 'duty') and a ~= '' then rules[#rules + 1] = { type = kind, name = a }
        elseif kind == 'role' and a ~= '' and b ~= '' then rules[#rules + 1] = { type = 'role', product = a, name = b }
        elseif kind == 'discord' and a:match('^%d+$') then rules[#rules + 1] = { type = 'discord', name = a }
        end
    end
    return rules
end

function perm.format(rules)
    local out = {}
    for _, rule in ipairs(type(rules) == 'table' and rules or {}) do
        if rule.type == 'everyone' then out[#out + 1] = 'everyone'
        elseif rule.type == 'job' or rule.type == 'gang' then out[#out + 1] = rule.grade and ('%s:%s:%s'):format(rule.type, rule.name, rule.grade) or rule.type .. ':' .. rule.name
        elseif rule.type == 'citizenid' then out[#out + 1] = 'cid:' .. rule.value
        elseif rule.type == 'role' then out[#out + 1] = ('role:%s:%s'):format(rule.product, rule.name)
        elseif rule.name then out[#out + 1] = rule.type .. ':' .. rule.name
        end
    end
    return table.concat(out, ', ')
end

return perm
