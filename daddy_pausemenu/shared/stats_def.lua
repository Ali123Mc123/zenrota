-- Stats both sides share: the GTA counters we track, the skill formulas (a port of Rockstar's stats_controller,
-- GTA Online rates) and the rows of the six tabs. No natives, so tests run it.
PMStats = {}

local floor, min, max = math.floor, math.min, math.max

-- The seven GTA skills in the design's row order (engine stats MP0_<name>).
PMStats.SKILLS = { 'STAMINA', 'SHOOTING_ABILITY', 'STRENGTH', 'STEALTH_ABILITY', 'FLYING_ABILITY', 'WHEELIE_ABILITY', 'LUNG_CAPACITY' }

local ALIAS = { SHOOTING = 'SHOOTING_ABILITY', STEALTH = 'STEALTH_ABILITY', FLYING = 'FLYING_ABILITY', DRIVING = 'WHEELIE_ABILITY', LUNG = 'LUNG_CAPACITY' }

-- GTA character stats read as MP0_<name>. kind: i int, f float, t time in ms (read as int).
-- sum: lifetime total of session deltas, the last number is the most one minute of play may add;
-- max: the best value ever, the last number is the most it may be.
PMStats.TRACK = {
    { 'DIST_RUNNING', 'f', 'sum', 900 },
    { 'DIST_WALKING', 'f', 'sum', 900 },
    { 'DIST_WALK_ST', 'f', 'sum', 600 },
    { 'DIST_SWIMMING', 'f', 'sum', 400 },
    { 'TIME_SWIMMING', 't', 'sum', 66000 },
    { 'TIME_UNDERWATER', 't', 'sum', 66000 },
    { 'TIME_IN_COVER', 't', 'sum', 66000 },
    { 'TIME_DRIVING_BICYCLE', 't', 'sum', 66000 },
    { 'TIME_DRIVING_PLANE', 't', 'sum', 66000 },
    { 'TIME_DRIVING_HELI', 't', 'sum', 66000 },
    { 'TOTAL_WHEELIE_TIME', 't', 'sum', 66000 },
    { 'DIST_CAR', 'f', 'sum', 9000 },
    { 'DIST_BIKE', 'f', 'sum', 9000 },
    { 'DIST_QUADBIKE', 'f', 'sum', 6000 },
    { 'DIST_BICYCLE', 'f', 'sum', 3000 },
    { 'DIST_BOAT', 'f', 'sum', 6000 },
    { 'DIST_HELI', 'f', 'sum', 9000 },
    { 'DIST_PLANE', 'f', 'sum', 15000 },
    { 'NUMBER_NEAR_MISS', 'i', 'sum', 120 },
    { 'PLANE_LANDINGS', 'i', 'sum', 6 },
    { 'NUMBER_CRASHES_CARS', 'i', 'sum', 60 },
    { 'NUMBER_CRASHES_BIKES', 'i', 'sum', 60 },
    { 'NUMBER_CRASHES_QUADBIKES', 'i', 'sum', 60 },
    { 'NUMBER_STOLEN_CARS', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_BIKES', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_QUADBIKES', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_BICYCLES', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_BOATS', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_HELIS', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_PLANES', 'i', 'sum', 10 },
    { 'NUMBER_STOLEN_COP_VEHICLE', 'i', 'sum', 10 },
    { 'TOTAL_CHASE_TIME', 't', 'sum', 66000 },
    { 'NO_TIMES_WANTED_LEVEL', 'i', 'sum', 10 },
    { 'KILLS_COP', 'i', 'sum', 40 },
    { 'KILLS_SWAT', 'i', 'sum', 40 },
    { 'SHOTS', 'i', 'sum', 1500 },
    { 'HITS', 'i', 'sum', 1500 },
    { 'HITS_PEDS_VEHICLES', 'i', 'sum', 1500 },
    { 'KILLS', 'i', 'sum', 40 },
    { 'HEADSHOTS', 'i', 'sum', 40 },
    { 'KILLS_STEALTH', 'i', 'sum', 20 },
    { 'KILLS_PLAYERS', 'i', 'sum', 30 },
    { 'UNARMED_HITS', 'i', 'sum', 150 },
    { 'DEATHS', 'i', 'sum', 10 },
    { 'LONGEST_SURVIVED_FREEFALL', 'f', 'max', 5000 },
}

-- Records the client measures itself (m/s and ms); 'session' = no longer than the session so far.
PMStats.OWN = { TOP_SPEED = 150, LONGEST_LIFE = 'session', LONGEST_WANTED = 'session' }

local SUM, RECORD = {}, {}
for _, d in ipairs(PMStats.TRACK) do
    if d[3] == 'sum' then SUM[d[1]] = d else RECORD[d[1]] = d[4] end
end
for name, cap in pairs(PMStats.OWN) do RECORD[name] = cap end

-- Names other resources may not use for their own counters (skills, records, cash and live values).
local RESERVED = { BANK = true, VEHICLES = true, SESSION = true, PLAY_TIME = true, LONGEST_SESSION = true }
for _, name in ipairs(PMStats.SKILLS) do RESERVED[name] = true end
for name in pairs(RECORD) do RESERVED[name] = true end

-- GTA Online progression (stats_controller func_60): metres run per stamina point and so on.
PMStats.RATES = { stamRun = 175, stamMul = 0.25, strHits = 20, lungSec = 30, drvNearMiss = 50, flyMin = 10, flyLanding = 1, shoHits = 80, stlWalk = 45, stlKill = 0.75 }

-- Bar tiers: the raw value that fills each of the ten segments (floats: 1000 h in ms overflows 32-bit integers).
local H, MIN = 3600000.0, 60000.0
local HOURS = { H, 5 * H, 10 * H, 25 * H, 50 * H, 100 * H, 200 * H, 350 * H, 500 * H, 1000 * H }
local CHASE = { MIN, 5 * MIN, 10 * MIN, 20 * MIN, 30 * MIN, 45 * MIN, H, 2 * H, 3 * H, 5 * H }
local LIFE = { 10 * MIN, 30 * MIN, H, 2 * H, 3 * H, 4 * H, 6 * H, 8 * H, 12 * H, 24 * H }
local FEW = { 1, 3, 5, 10, 20, 35, 50, 75, 100, 150 }
local SOME = { 1, 5, 10, 25, 50, 100, 250, 500, 750, 1000 }
local MANY = { 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000 }
local SHOTS = { 100, 500, 1000, 2500, 5000, 10000, 25000, 50000, 100000, 250000 }
local FOOT = { 1e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, 2.5e5, 5e5, 1e6, 2.5e6 }
local SWIM = { 100, 250, 500, 1e3, 2.5e3, 5e3, 1e4, 2.5e4, 5e4, 1e5 }
local DRIVE = { 1e4, 5e4, 1e5, 2.5e5, 5e5, 1e6, 2.5e6, 5e6, 1e7, 2.5e7 }
local MONEY = { 1e3, 1e4, 5e4, 1e5, 2.5e5, 5e5, 1e6, 2.5e6, 5e6, 1e7 }
local ONCE = { 500, 1e3, 5e3, 1e4, 2.5e4, 5e4, 1e5, 2.5e5, 5e5, 1e6 }
local OWNED = { 1, 2, 3, 4, 5, 7, 10, 15, 20, 30 }

-- Every row a tab, the records grid or the career list can show. src: values summed (GTA counters, our records,
-- skills, CASH_*, live BANK / VEHICLES / SESSION, counters other resources feed); ratio = { a, b } is a / b in percent.
-- type tells the page how to print the raw value; tiers or cap (ten even tiers) make it a 0..100 bar.
-- optional rows are fed by other resources (exports) and stay hidden until they have a value (Config.Stats.HideEmpty).
local MOTOR = { 'DIST_CAR', 'DIST_BIKE', 'DIST_QUADBIKE', 'DIST_BICYCLE', 'DIST_BOAT', 'DIST_HELI', 'DIST_PLANE' }
local STOLEN = { 'NUMBER_STOLEN_CARS', 'NUMBER_STOLEN_BIKES', 'NUMBER_STOLEN_QUADBIKES', 'NUMBER_STOLEN_BICYCLES', 'NUMBER_STOLEN_BOATS', 'NUMBER_STOLEN_HELIS', 'NUMBER_STOLEN_PLANES', 'NUMBER_STOLEN_COP_VEHICLE' }
PMStats.ROWS = {
    stamina = { src = { 'STAMINA' }, type = 'bar' },
    shooting = { src = { 'SHOOTING_ABILITY' }, type = 'bar' },
    strength = { src = { 'STRENGTH' }, type = 'bar' },
    stealth = { src = { 'STEALTH_ABILITY' }, type = 'bar' },
    flying = { src = { 'FLYING_ABILITY' }, type = 'bar' },
    driving = { src = { 'WHEELIE_ABILITY' }, type = 'bar' },
    lung = { src = { 'LUNG_CAPACITY' }, type = 'bar' },

    missions = { src = { 'MISSIONS' }, type = 'int', tiers = SOME, optional = true },
    reputation = { src = { 'REPUTATION' }, type = 'int', cap = 100, optional = true },
    rank = { src = { 'RANK' }, type = 'int', cap = 100, optional = true },
    shift = { src = { 'SHIFT_TIME' }, type = 'time', tiers = HOURS, optional = true },
    playtime = { src = { 'PLAY_TIME' }, type = 'time', tiers = HOURS },
    session = { src = { 'SESSION' }, type = 'time', tiers = LIFE },
    longest_session = { src = { 'LONGEST_SESSION' }, type = 'time', tiers = LIFE },
    on_foot = { src = { 'DIST_WALKING', 'DIST_RUNNING' }, type = 'distance', tiers = FOOT },
    swimming = { src = { 'DIST_SWIMMING' }, type = 'distance', tiers = SWIM },
    underwater = { src = { 'TIME_UNDERWATER' }, type = 'time', tiers = CHASE },
    freefall = { src = { 'LONGEST_SURVIVED_FREEFALL' }, type = 'distance', cap = 500 },

    robberies = { src = { 'ROBBERIES' }, type = 'int', tiers = FEW, optional = true },
    arrests = { src = { 'ARRESTS' }, type = 'int', tiers = FEW, optional = true },
    wanted = { src = { 'TOTAL_CHASE_TIME' }, type = 'time', tiers = CHASE },
    laundering = { src = { 'LAUNDERED' }, type = 'cash', tiers = MONEY, optional = true },
    stolen = { src = STOLEN, type = 'int', tiers = MANY },
    cop_kills = { src = { 'KILLS_COP', 'KILLS_SWAT' }, type = 'int', tiers = MANY },
    times_wanted = { src = { 'NO_TIMES_WANTED_LEVEL' }, type = 'int', tiers = SOME },
    longest_wanted = { src = { 'LONGEST_WANTED' }, type = 'time', tiers = CHASE },

    owned = { src = { 'VEHICLES' }, type = 'int', tiers = OWNED },
    races = { src = { 'RACES' }, type = 'int', tiers = SOME, optional = true },
    crashes = { src = { 'NUMBER_CRASHES_CARS', 'NUMBER_CRASHES_BIKES', 'NUMBER_CRASHES_QUADBIKES' }, type = 'int', tiers = MANY },
    driven = { src = MOTOR, type = 'distance', tiers = DRIVE },
    travelled = { src = { 'DIST_WALKING', 'DIST_RUNNING', 'DIST_SWIMMING', table.unpack(MOTOR) }, type = 'distance', tiers = DRIVE },
    top_speed = { src = { 'TOP_SPEED' }, type = 'speed', cap = 100 },
    near_misses = { src = { 'NUMBER_NEAR_MISS' }, type = 'int', tiers = MANY },
    flight_time = { src = { 'TIME_DRIVING_PLANE', 'TIME_DRIVING_HELI' }, type = 'time', tiers = HOURS },
    landings = { src = { 'PLANE_LANDINGS' }, type = 'int', tiers = SOME },

    income = { src = { 'CASH_EARNED' }, type = 'cash', tiers = MONEY },
    spending = { src = { 'CASH_SPENT' }, type = 'cash', tiers = MONEY },
    savings = { src = { 'BANK' }, type = 'cash', tiers = MONEY },
    tax = { src = { 'TAX' }, type = 'cash', tiers = MONEY, optional = true },
    best_income = { src = { 'CASH_MAX_EARN' }, type = 'cash', tiers = ONCE },
    worst_expense = { src = { 'CASH_MAX_SPEND' }, type = 'cash', tiers = ONCE },

    kills = { src = { 'KILLS' }, type = 'int', tiers = MANY },
    headshots = { src = { 'HEADSHOTS' }, type = 'int', tiers = MANY },
    survival = { src = { 'LONGEST_LIFE' }, type = 'time', tiers = LIFE },
    deaths = { src = { 'DEATHS' }, type = 'int', tiers = MANY },
    accuracy = { ratio = { 'HITS', 'SHOTS' }, type = 'percent', cap = 100 },
    shots = { src = { 'SHOTS' }, type = 'int', tiers = SHOTS },
    unarmed_hits = { src = { 'UNARMED_HITS' }, type = 'int', tiers = MANY },
    stealth_kills = { src = { 'KILLS_STEALTH' }, type = 'int', tiers = SOME },
    player_kills = { src = { 'KILLS_PLAYERS' }, type = 'int', tiers = SOME },
}

-- The design's six tabs in order, and what they, the records grid and the career list show by default.
PMStats.TABS = { 'skills', 'career', 'crimes', 'vehicles', 'cash', 'combat' }
PMStats.DEFAULT = {
    skills = { 'stamina', 'shooting', 'strength', 'stealth', 'flying', 'driving', 'lung' },
    career = { 'missions', 'reputation', 'rank', 'shift', 'playtime', 'on_foot', 'swimming' },
    crimes = { 'robberies', 'arrests', 'wanted', 'laundering', 'stolen', 'cop_kills' },
    vehicles = { 'owned', 'races', 'crashes', 'driven', 'top_speed', 'near_misses' },
    cash = { 'income', 'spending', 'savings', 'tax', 'best_income', 'worst_expense' },
    combat = { 'kills', 'headshots', 'survival', 'deaths', 'accuracy', 'shots' },
}
PMStats.RECORDS = { 'playtime', 'longest_session', 'travelled', 'deaths' }
PMStats.CAREER = { 'session', 'playtime', 'deaths', 'on_foot' }

local function num(v)
    v = tonumber(v)
    if v and v == v and v ~= math.huge and v ~= -math.huge then return v end
end

-- 'stamina', 'DRIVING', 'MP0_WHEELIE_ABILITY' -> the GTA skill name, or nil.
function PMStats.skillName(name)
    if type(name) ~= 'string' then return nil end
    name = name:upper():gsub('^MP0_', '')
    name = ALIAS[name] or name
    for _, skill in ipairs(PMStats.SKILLS) do
        if skill == name then return name end
    end
    return nil
end

-- A counter name other resources may feed (IncrementStat / SetStat): A-Z, 0-9 and _, not a reserved one.
function PMStats.customKey(key)
    if type(key) ~= 'string' then return nil end
    key = key:upper()
    if #key > 48 or not key:match('^[A-Z][A-Z0-9_]*$') or RESERVED[key] or key:match('^CASH_') then return nil end
    return key
end

-- Progression rates with the config's positive numbers on top.
function PMStats.rates(override)
    local out = {}
    for k, v in pairs(PMStats.RATES) do out[k] = v end
    for k, v in pairs(type(override) == 'table' and override or {}) do
        if out[k] and num(v) and v > 0 then out[k] = v end
    end
    return out
end

-- Starting value per skill: one number for all, or { STAMINA = 20, ... }.
function PMStats.base(value)
    local out = {}
    for _, skill in ipairs(PMStats.SKILLS) do
        local v = type(value) == 'table' and num(value[skill]) or num(value) or 0
        out[skill] = max(0, min(100, v))
    end
    return out
end

local function mins(ms) return floor(ms / 60000) end
local function secs(ms) return floor(ms / 1000) end

-- What play has earned each skill so far, before base and bonus (R* stats_controller, MP branch).
-- shoot: 'HITS' or 'HITS_PEDS_VEHICLES' (the one the probe shows moving).
function PMStats.activity(totals, rates, shoot)
    local r = rates or PMStats.RATES
    local function v(k) return num(totals[k]) or 0 end
    return {
        STAMINA = (v('DIST_RUNNING') / r.stamRun + mins(v('TIME_SWIMMING')) + mins(v('TIME_DRIVING_BICYCLE'))) * r.stamMul,
        SHOOTING_ABILITY = v(shoot == 'HITS_PEDS_VEHICLES' and shoot or 'HITS') / r.shoHits,
        STRENGTH = v('UNARMED_HITS') / r.strHits,
        STEALTH_ABILITY = v('DIST_WALK_ST') / r.stlWalk + v('KILLS_STEALTH') * r.stlKill,
        FLYING_ABILITY = (mins(v('TIME_DRIVING_PLANE')) + mins(v('TIME_DRIVING_HELI'))) / r.flyMin + v('PLANE_LANDINGS') * r.flyLanding,
        WHEELIE_ABILITY = floor(v('NUMBER_NEAR_MISS') / r.drvNearMiss),
        LUNG_CAPACITY = secs(v('TIME_UNDERWATER')) / r.lungSec,
    }
end

-- Skill values 0..100: floor(activity + base + bonus), as GTA does.
function PMStats.skills(totals, base, bonus, rates, shoot)
    local a, out = PMStats.activity(totals or {}, rates, shoot), {}
    base, bonus = base or {}, bonus or {}
    for _, skill in ipairs(PMStats.SKILLS) do
        out[skill] = max(0, min(100, floor(a[skill] + (base[skill] or 0) + (num(bonus[skill]) or 0) + 1e-9)))
    end
    return out
end

-- GTA posts a skill card each 20 points; values jump between pushes, so any crossing counts.
function PMStats.crossed(old, new, step)
    step = step or 20
    return floor(new / step) > floor(old / step)
end

-- Driving points from wheelies, as GTA: one per 15 s of wheelie time, at most perDay a day.
function PMStats.wheelie(state, gainedMs, day, perDay)
    if state.wday ~= day then state.wday, state.wms = day, 0 end
    local before = min(perDay, floor((state.wms or 0) / 15000))
    state.wms = (state.wms or 0) + max(0, num(gainedMs) or 0)
    return min(perDay, floor(state.wms / 15000)) - before
end

-- Driving points from client-reported events, at most perDay a day (kept beside the wheelie count in the skills state).
function PMStats.daily(state, points, day, perDay)
    if state.eday ~= day then state.eday, state.epts = day, 0 end
    local gain = max(0, min(floor(num(points) or 0), perDay - (state.epts or 0)))
    state.epts = (state.epts or 0) + gain
    return gain
end

-- A client's session deltas, cut to what `elapsed` seconds of play can add; unknown names and bad numbers go.
function PMStats.cleanDelta(delta, elapsed)
    local out, minutes = {}, max(num(elapsed) or 0, 5) / 60 * 1.25
    if type(delta) ~= 'table' then return out end
    for name, def in pairs(SUM) do
        local v = num(delta[name])
        if v and v > 0 then
            local cap = def[4] * minutes
            if def[2] == 'f' then out[name] = min(v, cap) else out[name] = floor(min(v, max(1, floor(cap)))) end
        end
    end
    return out
end

-- A client's records: known names only, above zero and not above their cap (or the session length).
function PMStats.cleanRecords(records, sessionMs)
    local out = {}
    if type(records) ~= 'table' then return out end
    for name, cap in pairs(RECORD) do
        if cap == 'session' then cap = (num(sessionMs) or 0) + 60000 end
        local v = num(records[name])
        if v and v > 0 and v <= cap then out[name] = v end
    end
    return out
end

-- Driving events: clean landings and top-speed runs, at a plausible rate (one landing per 20 s, one run per 30 s).
function PMStats.cleanEvents(events, elapsed)
    events, elapsed = type(events) == 'table' and events or {}, max(num(elapsed) or 0, 0)
    local function n(v, most)
        v = num(v)
        return v and v > 0 and min(floor(v), most) or 0
    end
    return { land = n(events.land, floor(elapsed / 20) + 1), speed = n(events.speed, floor(elapsed / 30) + 1) }
end

local function ascending(list)
    if type(list) ~= 'table' or #list == 0 then return false end
    local prev = 0
    for _, v in ipairs(list) do
        if not num(v) or v <= prev then return false end
        prev = v
    end
    return true
end

-- The bar's tiers for a row: Config.Stats.Caps[key] (a cap, or ascending tiers) wins over the catalog's.
function PMStats.tiers(def, override)
    if ascending(override) then return override end
    local cap = num(override)
    if not (cap and cap > 0) then
        if ascending(def.tiers) then return def.tiers end
        cap = def.cap or 100
    end
    local out = {}
    for i = 1, 10 do out[i] = cap * i / 10 end
    return out
end

-- 0..100 for the bar and the raw value of the next tier (nil at the top). Skills are already 0..100.
function PMStats.bar(raw, def, override)
    raw = num(raw) or 0
    if def.type == 'bar' then return max(0, min(100, floor(raw))), nil end
    local tiers = PMStats.tiers(def, override)
    local step, prev = 100 / #tiers, 0
    for i, top in ipairs(tiers) do
        if raw < top then return floor((i - 1) * step + step * max(0, raw - prev) / (top - prev)), top end
        prev = top
    end
    return 100, nil
end

-- The design's ranks: under 25 novice, under 50 apprentice, under 75 skilled, then expert.
function PMStats.rank(value)
    return value < 25 and 0 or value < 50 and 1 or value < 75 and 2 or 3
end

-- A row's raw value from the values map, or nil when none of its sources has one yet.
function PMStats.raw(def, values)
    if def.ratio then
        local a, b = num(values[def.ratio[1]]), num(values[def.ratio[2]])
        if not a and not b then return nil end
        return (b or 0) > 0 and min(100, (a or 0) / b * 100) or 0
    end
    local sum, seen = 0, false
    for _, key in ipairs(def.src) do
        local v = num(values[key])
        if v then sum, seen = sum + v, true end
    end
    return seen and sum or nil
end

local function keys(list, default)
    local out, seen = {}, {}
    for _, key in ipairs(type(list) == 'table' and list or default) do
        if type(key) == 'string' and PMStats.ROWS[key] and not seen[key] then
            seen[key] = true
            out[#out + 1] = key
        end
    end
    return out
end

-- The page's data: { tabs = { { id, rows = { { key, value, raw, type, rank, next } } } }, records, career }.
function PMStats.build(values, cfg)
    values, cfg = values or {}, type(cfg) == 'table' and cfg or {}
    local tabs, caps = type(cfg.Tabs) == 'table' and cfg.Tabs or {}, type(cfg.Caps) == 'table' and cfg.Caps or {}
    local hide = cfg.HideEmpty ~= false
    local out = { tabs = {}, records = {}, career = {} }
    for _, id in ipairs(PMStats.TABS) do
        local rows = {}
        for _, key in ipairs(keys(tabs[id], PMStats.DEFAULT[id])) do
            local def = PMStats.ROWS[key]
            local raw = PMStats.raw(def, values)
            if raw ~= nil or not (def.optional and hide) then
                local value, nxt = PMStats.bar(raw, def, caps[key])
                rows[#rows + 1] = { key = key, value = value, raw = raw or 0, type = def.type, rank = PMStats.rank(value), next = nxt }
            end
        end
        out.tabs[#out.tabs + 1] = { id = id, rows = rows }
    end
    for _, part in ipairs({ { 'records', cfg.Records, PMStats.RECORDS }, { 'career', cfg.Career, PMStats.CAREER } }) do
        for _, key in ipairs(keys(part[2], part[3])) do
            local def = PMStats.ROWS[key]
            out[part[1]][#out[part[1]] + 1] = { key = key, value = PMStats.raw(def, values) or 0, type = def.type }
        end
    end
    return out
end
