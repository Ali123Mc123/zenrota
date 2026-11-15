-- The casting sheet's rules, the same on the server and the client; the page mirrors them in create/rules.ts.
do
    IdentityRules = {}

    -- Letters: Latin (Latin-1, Extended A/B, Additional), Greek, Cyrillic, Hebrew, Arabic, kana, CJK, Hangul; then accents.
    local LETTERS = {
        { 0x41, 0x5A }, { 0x61, 0x7A }, { 0xC0, 0xD6 }, { 0xD8, 0xF6 }, { 0xF8, 0x24F }, { 0x1E00, 0x1EFF },
        { 0x386, 0x386 }, { 0x388, 0x3FF }, { 0x400, 0x481 }, { 0x48A, 0x52F }, { 0x5D0, 0x5EA },
        { 0x620, 0x64A }, { 0x671, 0x6D3 }, { 0x3041, 0x30FF }, { 0x4E00, 0x9FFF }, { 0xAC00, 0xD7A3 },
    }
    local MARKS = { 0x300, 0x36F }
    -- Space, apostrophe, hyphen and the typographic apostrophe; never two in a row, never first or last.
    local SEPARATORS = { [0x20] = true, [0x27] = true, [0x2D] = true, [0x2019] = true }
    local DAYS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    -- Linear on any input: the first and the last non-space, never a lazy match over a long space run.
    local function trim(text)
        local first = text:find('%S')
        if not first then return '' end
        local last = #text
        while text:find('^%s', last) do last = last - 1 end
        return text:sub(first, last)
    end

    local function kindOf(code)
        for i = 1, #LETTERS do
            if code >= LETTERS[i][1] and code <= LETTERS[i][2] then return 'letter' end
        end
        if code >= MARKS[1] and code <= MARKS[2] then return 'mark' end
        return SEPARATORS[code] and 'separator' or nil
    end

    -- Letters with single separators between them; a mark only after a letter or another mark.
    local function shaped(text)
        local prev
        for _, code in utf8.codes(text) do
            local kind = kindOf(code)
            local afterLetter = prev == 'letter' or prev == 'mark'
            if not kind or (kind ~= 'letter' and not afterLetter) then return false end
            prev = kind
        end
        return prev == 'letter' or prev == 'mark'
    end

    -- true when the text holds a blocked word, also with its spaces, apostrophes and hyphens taken out.
    function IdentityRules.blocked(text, words)
        local lower = text:lower()
        local compact = lower:gsub("[%s'%-]", '')
        for _, word in ipairs(type(words) == 'table' and words or {}) do
            if type(word) == 'string' and word ~= '' then
                local needle = word:lower()
                if lower:find(needle, 1, true) or compact:find(needle, 1, true) then return true end
            end
        end
        return false
    end

    -- A cleaned name (trimmed, single spaces, first ASCII letter upper-cased), or nil when it breaks a rule.
    function IdentityRules.name(text, cfg)
        if type(text) ~= 'string' then return nil end
        local clean = trim(text):gsub('%s+', ' ')
        local length = utf8.len(clean)
        if not length or length < (cfg.NameMin or 2) or length > (cfg.NameMax or 16) then return nil end
        if not shaped(clean) or IdentityRules.blocked(clean, cfg.BlockedWords) then return nil end
        return (clean:gsub('^%l', string.upper))
    end

    local function daysIn(year, month)
        if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then return 29 end
        return DAYS[month]
    end

    -- year, month, day of a real 'YYYY-MM-DD' date, or nil.
    function IdentityRules.date(text)
        if type(text) ~= 'string' then return nil end
        local y, m, d = text:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
        y, m, d = tonumber(y), tonumber(m), tonumber(d)
        if not y or m < 1 or m > 12 or d < 1 or d > daysIn(y, m) then return nil end
        return y, m, d
    end

    -- Whole years from a birth date to a day, or nil when either is not a real date.
    function IdentityRules.age(birth, today)
        local y, m, d = IdentityRules.date(birth)
        local ty, tm, td = IdentityRules.date(today)
        if not y or not ty then return nil end
        local age = ty - y
        if tm < m or (tm == m and td < d) then age = age - 1 end
        return age
    end

    -- The age bounds are checked only when today is known (the client may not know it).
    local function birthdate(value, cfg, today)
        if not IdentityRules.date(value) or value < '1900-01-01' then return nil, 'date_invalid' end
        if not IdentityRules.date(today) then return value end
        if value > today then return nil, 'date_invalid' end
        local age = IdentityRules.age(value, today)
        if age < (cfg.MinAge or 18) or age > (cfg.MaxAge or 90) then return nil, 'age' end
        return value
    end

    local function gender(value)
        return (value == 'm' or value == 'f') and value or nil
    end

    -- An ISO code from the list; any two capital letters when the list is empty.
    local function nationality(value, cfg)
        if type(value) ~= 'string' or not value:match('^%u%u$') then return nil end
        local list = type(cfg.Nationalities) == 'table' and cfg.Nationalities or {}
        if #list == 0 then return value end
        for _, code in ipairs(list) do
            if code == value then return value end
        end
        return nil
    end

    -- Whole centimetres within the bounds.
    local function height(value, cfg)
        local n = tonumber(value)
        if not n or n ~= n or n ~= math.floor(n) then return nil end
        if n < (cfg.HeightMin or 150) or n > (cfg.HeightMax or 210) then return nil end
        return math.floor(n)
    end

    -- Plain text with line breaks; '' when the bio field is off.
    local function bio(value, cfg)
        local max = tonumber(cfg.BioMax) or 0
        if max <= 0 or value == nil then return '' end
        if type(value) ~= 'string' then return nil end
        local clean = trim((value:gsub('\r\n?', '\n')))
        local length = utf8.len(clean)
        if not length or length > max or clean:gsub('\n', ''):find('%c') then return nil end
        return clean
    end

    -- Each field in order with its error code; a rule may return a more precise code.
    local CHECKS = {
        { field = 'firstname', code = 'name_invalid', run = function(value, cfg) return IdentityRules.name(value, cfg) end },
        { field = 'lastname', code = 'name_invalid', run = function(value, cfg) return IdentityRules.name(value, cfg) end },
        { field = 'birthdate', code = 'date_invalid', run = birthdate },
        { field = 'gender', code = 'gender', run = gender },
        { field = 'nationality', code = 'nationality', run = nationality },
        { field = 'height', code = 'height', run = height },
        { field = 'bio', code = 'bio', run = bio },
    }

    -- ok, field, code; on success the fourth value is the cleaned identity to store.
    function IdentityRules.check(identity, cfg, today)
        if type(identity) ~= 'table' then return false, nil, 'invalid' end
        cfg = type(cfg) == 'table' and cfg or {}
        local clean = {}
        for _, rule in ipairs(CHECKS) do
            local value, code = rule.run(identity[rule.field], cfg, today)
            if value == nil then return false, rule.field, code or rule.code end
            clean[rule.field] = value
        end
        if IdentityRules.blocked(clean.firstname .. ' ' .. clean.lastname, cfg.BlockedWords) then return false, 'lastname', 'name_invalid' end
        return true, nil, nil, clean
    end
end

-- Season packs: which season the server is in and which scenes and weather it brings. Pure, so the tests run it as it is.
do
    SeasonRules = {}

    SeasonRules.NAMES = { winter = true, halloween = true, xmas = true }
    SeasonRules.WEATHER = { winter = 'SNOWLIGHT', halloween = 'HALLOWEEN', xmas = 'XMAS' }

    -- 'auto' reads the month (October halloween, December xmas, January and February winter), 'none' turns packs off.
    function SeasonRules.current(setting, month)
        if SeasonRules.NAMES[setting] then return setting end
        if setting ~= 'auto' then return nil end
        month = tonumber(month)
        if month == 10 then return 'halloween' end
        if month == 12 then return 'xmas' end
        if month == 1 or month == 2 then return 'winter' end
        return nil
    end

    -- A scene with no season tag is always in; a seasonal one only in its own season.
    function SeasonRules.fits(scene, season)
        local tag = type(scene) == 'table' and scene.season or nil
        return tag == nil or tag == season
    end

    -- The look jobs without their own get: the configured one, its weather taken over by the season.
    function SeasonRules.look(default, season)
        local out = {}
        for key, value in pairs(type(default) == 'table' and default or {}) do out[key] = value end
        out.weather = SeasonRules.WEATHER[season] or out.weather
        return out
    end
end

-- The session state machine: which state may follow which, and where a player sits alone. Pure.
do
    States = {}

    States.LIST = { 'idle', 'intro', 'select', 'create', 'loading', 'appearance', 'cutscene', 'spawn_select', 'spawning', 'playing', 'relogging', 'editor' }

    -- A loaded character mid-flow may be sent back to the selection (forced relog, a load we did not expect).
    States.NEXT = {
        idle = { intro = true, select = true },
        intro = { select = true },
        select = { create = true, loading = true },
        create = { select = true, loading = true },
        loading = { select = true, appearance = true, cutscene = true, spawn_select = true, spawning = true },
        appearance = { cutscene = true, spawn_select = true, spawning = true, select = true },
        cutscene = { spawning = true, select = true },
        spawn_select = { spawning = true, select = true },
        spawning = { playing = true, select = true },
        playing = { relogging = true, select = true, editor = true },
        relogging = { select = true, playing = true },
        editor = { playing = true, select = true },
    }

    -- In these states the player is alone in routing bucket Config.Bucket.Base + server id.
    States.ISOLATED = {
        intro = true, select = true, create = true, loading = true, appearance = true,
        cutscene = true, spawn_select = true, editor = true,
    }

    -- States in which a character of ours is loaded.
    States.LOADED = { appearance = true, cutscene = true, spawn_select = true, spawning = true, playing = true, editor = true }

    function States.allowed(from, to)
        local next = States.NEXT[from]
        return next ~= nil and next[to] == true
    end

    -- True when a move between the two states crosses the private/public line.
    function States.crosses(from, to)
        return (States.ISOLATED[from] == true) ~= (States.ISOLATED[to] == true)
    end
end

-- Pure slot, whitelist, gift code and Tebex rules: no natives, so the tests run them as they are.
do
    SlotRules = {}
    Codes = Codes or {}
    TebexRules = {}

    local GRACE_STATES = { forbidden = true, unavailable = true }
    local GRANT_SOURCES = { tebex = true, admin = true, code = true }
    local REASONS = { expiry = true, refund = true, chargeback = true }
    local ACTIONS = { purchase = true, revoke = true, claim = true }
    local ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'
    local CODE_MIN, CODE_MAX, CODE_LEN = 8, 20, 12

    -- A positive whole count, 0 for anything else.
    local function count(value)
        local n = tonumber(value)
        if not n or n ~= n or n <= 0 then return 0 end
        return math.floor(math.min(n, 1000))
    end

    local function roleSet(roles)
        local set = {}
        for _, id in ipairs(type(roles) == 'table' and roles or {}) do
            if tostring(id) ~= '' then set[tostring(id)] = true end
        end
        return set
    end

    local function heldAny(roles, wanted)
        for id in pairs(roleSet(roles)) do
            if wanted[id] then return true end
        end
        return false
    end

    -- Last-known roles count while Discord is down, for graceHours after they were read.
    local function withinGrace(input)
        local at, now = tonumber(input.lastAt), tonumber(input.now) or 0
        return type(input.lastRoles) == 'table' and at ~= nil and now - at < (tonumber(input.graceHours) or 0) * 3600
    end

    -- The roles that count now and whether they are the stale last-known ones.
    local function currentRoles(input)
        local state = input.discordState or 'off'
        if state == 'ok' then return input.roles or {}, false end
        if GRACE_STATES[state] and withinGrace(input) then return input.lastRoles, true end
        return {}, false
    end

    -- One part per matching tier (stack), or the best one (highest).
    local function discordParts(tiers, roles, mode)
        local held, parts, best = roleSet(roles), {}, nil
        for _, tier in ipairs(type(tiers) == 'table' and tiers or {}) do
            local slots = count(tier.slots)
            if slots > 0 and tier.role ~= nil and held[tostring(tier.role)] then
                local part = { kind = 'discord', slots = slots, label = tier.label }
                if mode ~= 'highest' then parts[#parts + 1] = part
                elseif not best or slots > best.slots then best = part end
            end
        end
        if best then parts[1] = best end
        return parts
    end

    local function activeGrant(grant, now)
        if type(grant) ~= 'table' or grant.status ~= 'active' or not GRANT_SOURCES[grant.source] then return false end
        local ends = tonumber(grant.expiresAt)
        return grant.expiresAt == nil or (ends ~= nil and ends > now)
    end

    -- Playtime tiers with whole hours and slots, in config order.
    local function playtimeTiers(tiers)
        local out = {}
        for _, tier in ipairs(type(tiers) == 'table' and tiers or {}) do
            local hours, slots = count(tier.hours), count(tier.slots)
            if hours > 0 and slots > 0 then out[#out + 1] = { hours = hours, slots = slots, label = tier.label } end
        end
        return out
    end

    -- Every tier the account's hours reached adds its slots.
    local function playtimeParts(tiers, have)
        local parts = {}
        for _, tier in ipairs(playtimeTiers(tiers)) do
            if have >= tier.hours then parts[#parts + 1] = { kind = 'playtime', slots = tier.slots, label = tier.label, hours = tier.hours } end
        end
        return parts
    end

    -- Seconds of playtime as hours with one decimal, rounded down.
    function SlotRules.hours(seconds)
        local n = tonumber(seconds) or 0
        if n ~= n or n <= 0 then return 0 end
        return math.floor(n / 360) / 10
    end

    -- input: { base, max, mode, tiers, roles, discordState, lastRoles, lastAt, graceHours, grants, playtimeTiers, playtime, now } -> Breakdown.
    function SlotRules.compute(input)
        input = type(input) == 'table' and input or {}
        local now, max, base = tonumber(input.now) or 0, count(input.max), count(input.base)
        local parts, sum = {}, base
        if base > 0 then parts[1] = { kind = 'base', slots = base } end
        local roles, stale = currentRoles(input)
        for _, part in ipairs(discordParts(input.tiers, roles, input.mode)) do
            parts[#parts + 1], sum = part, sum + part.slots
        end
        for _, grant in ipairs(type(input.grants) == 'table' and input.grants or {}) do
            local slots = count(grant.slots)
            if slots > 0 and activeGrant(grant, now) then
                parts[#parts + 1], sum = { kind = grant.source, slots = slots, expiresAt = tonumber(grant.expiresAt) }, sum + slots
            end
        end
        local have = SlotRules.hours(input.playtime)
        for _, part in ipairs(playtimeParts(input.playtimeTiers, have)) do
            parts[#parts + 1], sum = part, sum + part.slots
        end
        return {
            total = math.min(max, sum), used = 0, max = max, capped = sum > max, parts = parts, playtime = have,
            discord = { state = input.discordState or 'off', stale = stale },
        }
    end

    -- Oldest first; adopted characters (createdAt 0) by their framework index.
    local function older(a, b)
        local ca, cb = tonumber(a.createdAt) or 0, tonumber(b.createdAt) or 0
        if ca ~= cb then return ca < cb end
        local ia, ib = tonumber(a.index) or 0, tonumber(b.index) or 0
        if ia ~= ib then return ia < ib end
        return tostring(a.cid) < tostring(b.cid)
    end

    -- chars: { cid, index, createdAt, deceased?, archived? } -> sorted list with .locked, and the slots used.
    function SlotRules.assign(chars, total, keepsDeceased)
        local list, used, allowance = {}, 0, tonumber(total) or 0
        for i, char in ipairs(type(chars) == 'table' and chars or {}) do list[i] = char end
        table.sort(list, older)
        for _, char in ipairs(list) do
            local counts = not char.archived and (not char.deceased or keepsDeceased == true)
            if counts then used = used + 1 end
            char.locked = counts and used > allowance or false
        end
        return list, used
    end

    local function link(url)
        return type(url) == 'string' and url:match('^https?://[%w%-%.]+') and url or nil
    end

    -- How a locked slot can be opened; role ids never leave the server. t localises labels; have = account hours.
    function SlotRules.hints(cfg, t, have)
        cfg = type(cfg) == 'table' and cfg or {}
        local slots, discord = cfg.Slots or {}, cfg.Discord or {}
        local say = function(key, ...) return type(t) == 'function' and t(key, ...) or nil end
        local invite, out = link(discord.Invite), {}
        for _, tier in ipairs((slots.Discord or {}).Tiers or {}) do
            if count(tier.slots) > 0 and tier.role ~= nil and tostring(tier.role) ~= '' then
                out[#out + 1] = { kind = 'discord', label = tier.label and tostring(tier.label) or say('slots.hint_discord'), slots = count(tier.slots), url = invite }
            end
        end
        have = tonumber(have) or 0
        for _, tier in ipairs(playtimeTiers(slots.Playtime)) do
            if have < tier.hours then
                out[#out + 1] = { kind = 'playtime', label = tier.label and tostring(tier.label) or say('slots.hint_playtime', tier.hours),
                    hours = tier.hours, have = have, slots = tier.slots }
            end
        end
        local store = link(slots.StoreUrl)
        if store then out[#out + 1] = { kind = 'store', label = say('slots.hint_store'), url = store } end
        out[#out + 1] = { kind = 'code', label = say('slots.hint_code') }
        return out
    end

    -- input: { allowed, state, roles, lastRoles, lastAt, graceHours, whenDown, now } -> allowed, reason, stale.
    -- reason: ok | not_linked | not_in_guild | no_role | down | closed (no whitelist roles configured).
    function SlotRules.whitelist(input)
        input = type(input) == 'table' and input or {}
        local wanted = roleSet(input.allowed)
        if next(wanted) == nil then return false, 'closed', false end
        local state = input.state or 'unavailable'
        if state == 'ok' then
            local held = heldAny(input.roles, wanted)
            return held, held and 'ok' or 'no_role', false
        end
        if state == 'not_linked' or state == 'not_in_guild' then return false, state, false end
        if withinGrace(input) and heldAny(input.lastRoles, wanted) then return true, 'ok', true end
        return input.whenDown == 'allow', 'down', false
    end

    -- A code of len characters (12 by default) from the alphabet without 0 O 1 I L; rng(n) returns 1..n.
    function Codes.generate(rng, len)
        rng = rng or math.random
        local out = {}
        for i = 1, math.max(CODE_MIN, math.min(CODE_MAX, math.floor(tonumber(len) or CODE_LEN))) do
            local at = rng(#ALPHABET)
            out[i] = ALPHABET:sub(at, at)
        end
        return table.concat(out)
    end

    -- 'ABCDEFGHJKMN' -> 'ABCD-EFGH-JKMN'.
    function Codes.format(code)
        local grouped = tostring(code or ''):gsub('(%w%w%w%w)', '%1-')
        return (grouped:gsub('%-$', ''))
    end

    -- Upper case without dashes or spaces; nil on a bad length or a character outside the alphabet.
    function Codes.normalize(input)
        if type(input) ~= 'string' or #input > 64 then return nil end
        local code = input:upper():gsub('[^%w]', '')
        if #code < CODE_MIN or #code > CODE_MAX or code:find('[^' .. ALPHABET .. ']') then return nil end
        return code
    end

    -- Logs show only the start of a code or transaction.
    function Codes.mask(code)
        return tostring(code or ''):sub(1, 4) .. '...'
    end

    -- A Tebex transaction id, lower case: letters, digits and dashes, at most 64.
    function TebexRules.tid(text)
        if type(text) ~= 'string' then return nil end
        local tid = text:match('^%s*(.-)%s*$'):lower()
        if #tid == 0 or #tid > 64 or not tid:match('^[%w%-]+$') then return nil end
        return tid
    end

    -- Tebex {id}: the Cfx.re account number, with or without 'fivem:'.
    local function fivemOf(text)
        text = tostring(text or '')
        local id = text:match('^fivem:(%d+)$') or text:match('^(%d+)$')
        return id and #id <= 20 and id or nil
    end

    local function packageOf(packages, key)
        local def = type(packages) == 'table' and (packages[key] or packages[tonumber(key) or false]) or nil
        if type(def) ~= 'table' then return nil end
        local slots, days = count(def.slots), def.days ~= nil and count(def.days) or nil
        if slots < 1 or slots > 255 or days == 0 or (days and days > 3650) then return nil end
        return slots, days
    end

    local function parsePurchase(tid, args, packages)
        local key = args[3] ~= nil and tostring(args[3]) or ''
        if key == '' then return nil, 'usage' end
        local slots, days = packageOf(packages, key)
        if not slots then return nil, 'bad_package' end
        return { action = 'purchase', tid = tid, pkg = key, slots = slots, days = days, fivem = fivemOf(args[4]) }
    end

    local function parseRevoke(tid, args)
        local reason = type(args[3]) == 'string' and args[3]:lower() or nil
        if not reason then return nil, 'usage' end
        if not REASONS[reason] then return nil, 'bad_reason' end
        return { action = 'revoke', tid = tid, reason = reason }
    end

    local function parseClaim(tid, args)
        local target = type(args[3]) == 'string' and args[3] or nil
        if not target then return nil, 'usage' end
        if #target > 64 then return nil, 'bad_target' end
        return { action = 'claim', tid = tid, target = target }
    end

    -- args after 'tebex': purchase <tid> <package> [fivemId] | revoke <tid> <expiry|refund|chargeback> | claim <tid> <target>.
    -- -> command table, or nil and usage | bad_action | bad_tid | bad_package | bad_reason | bad_target.
    function TebexRules.parse(args, packages)
        args = type(args) == 'table' and args or {}
        packages = packages or (Config and Config.Tebex and Config.Tebex.Packages) or {}
        local action = type(args[1]) == 'string' and args[1]:lower() or nil
        if not action then return nil, 'usage' end
        if not ACTIONS[action] then return nil, 'bad_action' end
        if args[2] == nil then return nil, 'usage' end
        local tid = TebexRules.tid(args[2])
        if not tid then return nil, 'bad_tid' end
        if action == 'purchase' then return parsePurchase(tid, args, packages) end
        if action == 'revoke' then return parseRevoke(tid, args) end
        return parseClaim(tid, args)
    end
end

-- Pure crew rules: sizes, formation slots and where each member stands. No natives, so the tests run it as it is.
do
    PartyRules = {}

    PartyRules.MODES = { solo = true, partner = true, crew = true }

    -- People a crew may hold, the leader included: a partner pair is two, a crew 2..8.
    function PartyRules.max(mode, cfgMax)
        if mode == 'partner' then return 2 end
        local n = math.floor(tonumber(cfgMax) or 4)
        return math.max(2, math.min(8, n))
    end

    -- The lowest formation slot (1..max-1) nobody holds; slot 0 is the first leader.
    function PartyRules.freeSlot(used, max)
        for slot = 1, math.max(1, (tonumber(max) or 2) - 1) do
            if not used[slot] then return slot end
        end
        return nil
    end

    -- The offset { x, y } of a slot in a formation; slots past the list wrap around, slot 0 stands on the point.
    function PartyRules.offset(formations, form, slot)
        local list = type(formations) == 'table' and formations[form]
        slot = tonumber(slot) or 0
        if slot < 1 or type(list) ~= 'table' or #list == 0 then return { x = 0.0, y = 0.0 } end
        local at = list[(slot - 1) % #list + 1]
        return { x = tonumber(at.x) or 0.0, y = tonumber(at.y) or 0.0 }
    end

    -- A point moved by a local offset: x right, y forward, turned by the point's heading (degrees, GTA style).
    function PartyRules.place(point, offset)
        local h = math.rad(tonumber(point.w) or 0.0)
        local x, y = tonumber(offset.x) or 0.0, tonumber(offset.y) or 0.0
        local px = point.x + x * math.cos(h) - y * math.sin(h)
        local py = point.y + x * math.sin(h) + y * math.cos(h)
        return { x = px, y = py, z = point.z, w = point.w }
    end

    -- Debug crew (Config.Debug only): made-up people with a random freemode look, so one tester sees a full crew.
    -- Pure: the defaults function and the random source come in, so the tests run it as it is.
    PartyFakes = {}

    PartyFakes.JOBS = { 'Police', 'Mechanic', 'Taxi', 'EMS', 'Lawyer', 'Unemployed' }

    -- Clothing ranges every freemode ped has: component id -> highest drawable.
    local RANGES = { [2] = 15, [4] = 10, [6] = 10, [8] = 15, [11] = 15 }

    local function pick(rng, low, high)
        return rng(low, high)
    end

    -- A look from the defaults of a gender with random hair, clothes and face blend.
    function PartyFakes.look(gender, rng, defaults)
        local skin = defaults(gender)
        for _, comp in ipairs(type(skin.components) == 'table' and skin.components or {}) do
            local high = RANGES[comp.component_id]
            if high then comp.drawable = pick(rng, 0, high) end
        end
        if type(skin.hair) == 'table' then
            skin.hair.style = skin.components and skin.components[3] and skin.components[3].drawable or skin.hair.style
            skin.hair.color = pick(rng, 0, 20)
        end
        if type(skin.headBlend) == 'table' then
            skin.headBlend.shapeFirst, skin.headBlend.skinFirst = pick(rng, 0, 45), pick(rng, 0, 45)
        end
        local model = gender == 'f' and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        skin.model = model
        return { model = model, skin = skin, format = 'illenium', gender = gender }
    end

    -- Test person number n: a negative id, a name from the label format, a job from the list and a look.
    function PartyFakes.person(n, rng, defaults, nameFormat)
        local gender = pick(rng, 0, 1) == 1 and 'f' or 'm'
        local job = PartyFakes.JOBS[pick(rng, 1, #PartyFakes.JOBS)]
        local name = (type(nameFormat) == 'string' and nameFormat or 'Test Actor %s'):format(n)
        return { id = -n, name = name, job = job, look = PartyFakes.look(gender, rng, defaults) }
    end

    -- How many test people a /mccrew argument asks for (0..3), or nil.
    function PartyFakes.count(arg)
        local n = tonumber(arg)
        if not n or n ~= math.floor(n) or n < 0 or n > 3 then return nil end
        return math.floor(n)
    end
end

-- Where a character may appear and which spawn is forced: pure rules, no natives (tests run them in fengari).
do
    SpawnRules = {}

    -- The group a spawn kind is listed under in the selector.
    local GROUPS = { last = 'last', forced = 'last', config = 'public', job = 'job', gang = 'job', home = 'home', provider = 'other', first = 'public' }

    local function number(value)
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then return nil end
        return value
    end

    local function parts(value)
        local kind = type(value)
        if kind == 'table' then
            return number(value.x or value[1]), number(value.y or value[2]), number(value.z or value[3]),
                number(value.w or value.h or value.heading or value[4]) or 0.0
        end
        if kind == 'vector4' then return value.x, value.y, value.z, value.w end
        if kind == 'vector3' then return value.x, value.y, value.z, 0.0 end
    end

    -- { x, y, z, w } from a vector or a table, or nil outside the map; the world origin counts as no position.
    function SpawnRules.coords(value)
        local x, y, z, w = parts(value)
        if not (x and y and z) then return nil end
        if math.abs(x) > 10000 or math.abs(y) > 10000 or z < -200 or z > 2500 then return nil end
        if math.abs(x) < 1 and math.abs(y) < 1 then return nil end
        return { x = x, y = y, z = z, w = w % 360 }
    end

    -- Trimmed text without control characters, at most n characters (48 by default); nil when empty.
    function SpawnRules.label(value, n)
        if type(value) ~= 'string' and type(value) ~= 'number' then return nil end
        local text = (tostring(value):gsub('%c', ' ')):match('^%s*(.-)%s*$')
        if not utf8.len(text) then text = (text:gsub('[\128-\255]', '')) end
        if text == '' then return nil end
        local stop = utf8.offset(text, (n or 48) + 1)
        return stop and text:sub(1, stop - 1) or text
    end

    -- 'job' when a job or duty rule limits a point, 'gang' for a gang rule, otherwise 'config'.
    function SpawnRules.kindOf(rules)
        local text = tostring(rules or '')
        if text:find('%f[%w]job:') or text:find('%f[%w]duty:') then return 'job' end
        if text:find('%f[%w]gang:') then return 'gang' end
        return 'config'
    end

    -- An editor point without its rules: id slug, label and coordinates, or nil.
    function SpawnRules.point(raw)
        if type(raw) ~= 'table' or type(raw.id) ~= 'string' then return nil end
        local id = raw.id:lower()
        if #id < 2 or #id > 32 or not id:match('^[a-z0-9_]+$') then return nil end
        local label, coords = SpawnRules.label(raw.label), SpawnRules.coords(raw.coords)
        if not (label and coords) then return nil end
        local icon = type(raw.icon) == 'string' and #raw.icon <= 24 and raw.icon:match('^[%w_%-]+$') or nil
        return { id = id, label = label, coords = coords, icon = icon, enabled = raw.enabled ~= false }
    end

    -- One entry of another script's spawn list: { id, label, coords }, or nil.
    function SpawnRules.entry(raw)
        if type(raw) ~= 'table' then return nil end
        local id = (type(raw.id) == 'string' or type(raw.id) == 'number') and tostring(raw.id) or nil
        local label, coords = SpawnRules.label(raw.label), SpawnRules.coords(raw.coords)
        if not (id and #id <= 64 and label and coords) then return nil end
        return { id = id, label = label, coords = coords }
    end

    local function adder(list, seen)
        return function(option)
            if not option.coords or seen[option.id] then return end
            seen[option.id] = true
            option.group = GROUPS[option.kind] or 'other'
            list[#list + 1] = option
        end
    end

    -- Options in selector order from { last, points, allow(rules), college, homes, providers, fallback }; ids are made here only.
    function SpawnRules.options(input)
        local list = {}
        local add = adder(list, {})
        local last = input.last
        if last then add({ id = 'last', kind = 'last', label = last.label, coords = SpawnRules.coords(last.coords), enter = last.enter }) end
        for _, point in ipairs(input.points or {}) do
            if not input.allow or input.allow(point.rules) then
                add({ id = point.id, kind = SpawnRules.kindOf(point.rules), label = SpawnRules.label(point.label), coords = SpawnRules.coords(point.coords) })
            end
        end
        local college = input.college
        if college then add({ id = 'college', kind = 'job', label = college.label, coords = college.coords }) end
        for _, home in ipairs(input.homes or {}) do
            add({ id = 'home:' .. tostring(home.key), kind = 'home', label = SpawnRules.label(home.label), coords = SpawnRules.coords(home.coords), enter = home.enter })
        end
        for i, entry in ipairs(input.providers or {}) do
            add({ id = 'prov:' .. i, kind = 'provider', label = SpawnRules.label(entry.label), coords = SpawnRules.coords(entry.coords), enter = entry.enter })
        end
        local fallback = input.fallback
        if #list == 0 and fallback then add({ id = 'cfg:default', kind = 'config', label = fallback.label, coords = SpawnRules.coords(fallback.coords) }) end
        return list
    end

    -- The College point ({ Label, Coords, Jobs }) for a character with this job: { label, coords }, or nil.
    function SpawnRules.college(cfg, job, fallbackLabel)
        if type(cfg) ~= 'table' or type(job) ~= 'string' or type(cfg.Jobs) ~= 'table' then return nil end
        local coords = SpawnRules.coords(cfg.Coords)
        if not coords then return nil end
        for _, name in ipairs(cfg.Jobs) do
            if name == job then return { label = SpawnRules.label(cfg.Label) or fallbackLabel, coords = coords } end
        end
        return nil
    end

    -- The option the client picked, or nil for anything not offered.
    function SpawnRules.pick(options, id)
        if type(id) ~= 'string' or #id > 160 then return nil end
        for _, option in ipairs(options or {}) do
            if option.id == id then return option end
        end
        return nil
    end

    -- What the selector shows of each option: no rules, no home entries.
    function SpawnRules.public(options)
        local out = {}
        for i, option in ipairs(options or {}) do
            local c = option.coords
            out[i] = { id = option.id, kind = option.kind, group = option.group, label = option.label or '', coords = { x = c.x, y = c.y, z = c.z, w = c.w } }
        end
        return out
    end

    -- True when a combat lock (a locks row) holds this character and has not run out: it spawns where it left.
    function SpawnRules.forced(lock, cid, now)
        return type(lock) == 'table' and (tonumber(lock.expires_at) or 0) > now and lock.cid == cid
    end

    -- The cutscene a new character watches: a known id, one of them for 'random', or nil ('none', unknown).
    function SpawnRules.cutscene(choice, ids, rng)
        if choice == 'random' then return #ids > 0 and ids[rng(#ids)] or nil end
        for _, id in ipairs(ids) do
            if id == choice then return id end
        end
        return nil
    end

    -- Whether a playing character may go back to the selection: pure, no natives (tests run it in fengari).
    RelogRules = {}

    -- 'ok', or the first reason as an error code (state dead restrained vehicle combat cooldown); cfg is Config.Relog.
    function RelogRules.check(input)
        local cfg, now = input.cfg or {}, input.now or 0
        if cfg.Enabled == false or input.state ~= 'playing' then return 'state' end
        if cfg.BlockDead ~= false and input.dead then return 'dead' end
        if cfg.BlockCuffed ~= false and input.cuffed then return 'restrained' end
        if cfg.BlockVehicle ~= false and input.vehicle then return 'vehicle' end
        if input.incident or (input.lastCombat and now - input.lastCombat < (tonumber(input.combatSeconds) or 0)) then return 'combat' end
        if input.lastRelog and now - input.lastRelog < (tonumber(cfg.Cooldown) or 0) then return 'cooldown' end
        return 'ok'
    end
end
