-- Star Skill Tree locks other scripts ask about, said the same on both sides. A lock is a skill key
-- ('skill:repair_kit') or a level rule ({ lesson = 'muzik', level = 6 }, { all = { ... } }, { any = { ... } });
-- a list of them means any one opens it.
SkillGate = {}

local nodes, courses = {}, {}
for _, course in ipairs((Config.Academics and Config.Academics.SkillTree) or {}) do
    courses[course.key] = course
    for _, node in ipairs(course.skills or {}) do
        if node.unlockKey then nodes[node.unlockKey] = { course = course, node = node } end
    end
end

function SkillGate.config() return (Config.Integrations and Config.Integrations.Skills) or {} end

-- A milestone's other lessons: req is one { lesson, level } or a list of them.
function SkillGate.reqsOf(node)
    local req = node and node.req
    if type(req) ~= 'table' then return {} end
    return req.lesson and { req } or req
end

-- A skill key's lesson and milestone ({ course, node }), or nil.
function SkillGate.node(key) return nodes[key] end

-- A skill key as the level rule behind it.
local function ruleOf(key)
    if type(key) ~= 'string' then return key end
    local entry = nodes[key]
    if not entry then return nil end
    local all = { { lesson = entry.course.key, level = entry.node.level } }
    for _, req in ipairs(SkillGate.reqsOf(entry.node)) do all[#all + 1] = req end
    return { all = all }
end

local function isList(keys) return type(keys) == 'table' and keys[1] ~= nil and not keys.lesson and not keys.all and not keys.any end

-- Does this state bag { levels, skills } hold the key or rule?
local function meets(state, key)
    if type(key) == 'string' then return state.skills ~= nil and state.skills[key] == true end
    if type(key) ~= 'table' then return true end
    local list = key.all or key.any
    if list then
        for _, child in ipairs(list) do
            local ok = meets(state, child)
            if key.any and ok then return true end
            if key.all and not ok then return false end
        end
        return key.all ~= nil or #list == 0
    end
    if key.lesson then return ((state.levels or {})[key.lesson] or 1) >= (key.level or 1) end
    return true
end

-- Locks: an enrolled student needs it, everyone else passes. -> allowed, the key to name when not.
function SkillGate.allowedAny(state, keys)
    if keys == nil or keys == '' then return true end
    if not state or state.student ~= true then return true end
    if not isList(keys) then return meets(state, keys), keys end
    for _, key in ipairs(keys) do
        if meets(state, key) then return true, key end
    end
    return false, keys[1]
end
SkillGate.allowed = SkillGate.allowedAny

-- Rights: only an enrolled student who has it.
function SkillGate.grants(state, keys)
    if keys == nil or not state or state.student ~= true then return false end
    return (SkillGate.allowedAny(state, keys))
end

-- Certificate locks: an enrolled student needs the College certificate, everyone else passes.
function SkillGate.hasCertificate(state, key)
    if type(key) ~= 'string' or key == '' then return true end
    if not state or state.student ~= true then return true end
    return state.certs ~= nil and state.certs[key] == true
end

-- "Needs Music lvl 6 + Dance lvl 6 (Star Skill Tree)".
function SkillGate.message(key)
    local rule, parts = ruleOf(key), {}
    local function walk(r)
        if type(r) ~= 'table' then return end
        if r.lesson then
            local course = courses[r.lesson]
            parts[#parts + 1] = DL.locale.t('skillgate.leaf', course and course.name or r.lesson, r.level or 1)
        end
        for _, child in ipairs(r.all or (r.any and { r.any[1] }) or {}) do walk(ruleOf(child)) end
    end
    walk(rule)
    return DL.locale.t('skillgate.locked', #parts > 0 and table.concat(parts, ' + ') or tostring(key))
end
