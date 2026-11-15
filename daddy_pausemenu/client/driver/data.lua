-- Settings driver (Engine B), data and pure helpers (no natives, tested in Node): GTA's settings frontend as
-- pausemenu.xml lays it out on game build 3258. The engine checks all of it against the running game before use.
PMDrv = PMDrv or {}
local D = PMDrv

D.LANDING = 'FE_MENU_VERSION_LANDING_MENU'
D.LIST = 51 -- MENU_UNIQUE_ID_SETTINGS_LIST: the menu id rows report inside a category
-- The category column top to bottom (screen ids). 148 is Key Bindings (never entered); 146 needs ReplayEditor.
D.CATEGORIES = { 24, 140, 148, 22, 136, 23, 137, 138, 139, 146 }
D.TARGETS = { [24] = true, [140] = true, [22] = true, [136] = true, [23] = true, [137] = true, [138] = true, [139] = true, [146] = true }
D.GFX = { [137] = true, [138] = true } -- pending until Apply (GFX_Dirty); the other screens apply on every step
D.VIDEO = { [56] = true, [57] = true, [58] = true } -- screen type, resolution, refresh: device reset, confirm first
D.WARNS = { [56] = true, [57] = true, [58] = true, [61] = true } -- Apply may ask "keep these settings?"
-- Applied on their own before the rest of their screen: after Ignore Suggested Limits GTA drops the presses on the
-- sliders that follow until an Apply (in game, b3258).
D.APPLY_FIRST = { [96] = true }
-- Never driven: output monitor (crashes the game), DX version (read-only), controls context, language, gamma trigger.
-- Title hash of GTA's "Unapplied Changes" question (GFX_BACK_OUT_BODY), asked when leaving a list with a pending change.
D.BACK_OUT = 1993207683
-- Title hash of GTA's "Keep New Settings?" (GFX_WARNING_BODY), asked after Apply; it reverts when not answered.
D.KEEP_WARN = -475703709
-- Rows GTA steps one level per press from its own value, ignoring the value the menu sends (MSAA, reflection MSAA,
-- Post FX, grass: two in-game runs, a seeded set came out as old value + 1): the rows its C++ fills with one option,
-- the current value's text. Frame scaling (81) is filled the same way (its text is the render resolution).
D.STEP = { [80] = true, [72] = true, [86] = true, [75] = true, [76] = true, [85] = true, [87] = true, [81] = true }
D.BLOCKED = { [60] = 'forbidden', [67] = 'read_only', [48] = 'unsupported', [35] = 'unsupported', [15] = 'unsupported' }
-- Convars mirroring a graphics-screen pref: the closed loop for those rows (FiveM keeps the texture budget itself).
D.CONVARS = {
    [56] = 'profile_vidScreenType', [57] = 'profile_vidResolution', [58] = 'profile_vidRefresh', [61] = 'profile_vidAspect',
    [62] = 'profile_vidVsync', [63] = 'profile_vidStereo', [64] = 'vid_budgetScale', [66] = 'profile_vidPauseOnFocusLoss',
    [90] = 'profile_advGfxLongShadows', [91] = 'profile_advGfxUltraShadows', [92] = 'profile_advGfxHdFlight',
    [93] = 'profile_advGfxMaxLod', [94] = 'profile_advGfxShadowsDistMult',
}
-- Graphics rows by pref id: kind and option count (sliders: steps), used when a batch row leaves them out.
-- Lists GTA fills in code (resolution, refresh) have no count: they step straight, never wrapped.
local T, L, S = 'toggle', 'list', 'slider'
D.SHAPES = {
    [96] = { T, 2 }, [81] = { L, 10 }, [79] = { T, 2 }, [80] = { L, 4 }, [82] = { T, 2 }, [62] = { L, 3 }, [63] = { T, 2 },
    [66] = { T, 2 }, [77] = { S, 10 }, [78] = { S, 10 }, [89] = { S, 10 }, [64] = { S }, [68] = { L, 3 }, [69] = { L, 3 },
    [70] = { L, 4 }, [71] = { L, 4 }, [72] = { L, 4 }, [73] = { L, 3 }, [74] = { L, 3 }, [75] = { L, 4 }, [76] = { L, 4 },
    [86] = { L, 4 }, [88] = { S, 10 }, [87] = { T, 2 }, [83] = { L, 5 }, [84] = { L, 3 }, [85] = { L, 4 },
    [56] = { L, 3 }, [57] = { L }, [58] = { L }, [61] = { L, 9 }, [90] = { T, 2 }, [91] = { T, 2 }, [92] = { T, 2 },
    [93] = { S, 10 }, [94] = { S, 10 },
}
-- A row with a convar and a known option count per graphics screen: absolute sets are self-tested on it.
D.SEED_TEST = { [137] = { uid = 62, count = 3 }, [138] = { uid = 90, count = 2 } }
-- Trigger rows (restore defaults, scans, links): ACCEPT never lands on them.
D.TRIGGERS = {
    'RESTORE_DEFAULTS_GRAPHICS', 'RESTORE_DEFAULTS_ADVANCED_GFX', 'RESTORE_DEFAULTS_AUDIO', 'RESTORE_DEFAULTS_DISPLAY',
    'RESTORE_DEFAULTS_VOICE_CHAT', 'RESTORE_DEFAULTS_CONTROLS', 'RESTORE_DEFAULTS_MISC_CONTROLS', 'RESTORE_DEFAULTS_CAMERA',
    'RESTORE_DEFAULTS_FIRST_PERSON', 'UR_QUICKSCAN', 'UR_COMPLETESCAN', 'PREF_PCGAMEPAD', 'PREF_SAFEZONE_SIZE', 'LINK_FACEBOOK',
}
-- Rows per screen in menu order: a pref uid, false for a separator or header, 'T' for a trigger row; { uid, 'CTX' }
-- shows only while that pause menu context is active ('!CTX': while it is not).
D.ROWS = {
    [24] = { 48, 4, { 2, 'b2944' }, 3, 5, 0, 1, 6, 123, 124, 136, 127, 125, 128, 126, 47, 166, 167, 'T' },
    [140] = { 108, 112, 117, 118, 137, 119, 175, 109, 110, 111, 113, 114, 115, 116, 138, 139, 140, 141, 142, 143, { 7, 'LightEffectHardware' }, 'T' },
    [22] = { 8, { 38, 'InMP' }, { 9, '!InMP' }, 43, { 13, '!OnLandingPage' }, 169, 170, 'T', 'T', { 11, '!AUD_WIRELESSHEADSET' }, { 45, 'SS_SUPPORTED' }, { 46, 'SS_SUPPORTED' }, 171, 'T' },
    [136] = { 121, 17, 129, 122, 130, 131, 132, 133, 135, 134, 176, 'T' },
    [23] = { 29, 30, 31, 32, 33, { 150, 'InMP' }, { 151, 'InMP' }, { 152, 'b2699' }, 15, 34, 27, 28, 174, 35, 'T' },
    [137] = { 96, 67, false, 81, 60, false, 79, 80, { 82, 'GFX_SUPPORT_TXAA' }, 62, { 63, 'VID_STEREO' }, 66, false, 77, 78, 89, false, 64, 68, 69, 70, 71, 72, 73, 74, 75, 76, 86, 88, 87, 83, 84, 85, false, 'T' },
    [138] = { 56, 57, 58, 61, false, 90, 91, 92, 93, 94, 'T' },
    [139] = { 97, false, 98, 99, 100, 101, false, 102, 103, 104, 105, 106, 107, false, 'T' },
    [146] = { 146, 148, 149, 172, 173 },
}

local function indexOf(list, value)
    for i = 1, #(list or {}) do
        if list[i] == value then return i end
    end
end
D.indexOf = indexOf

-- The rows the game builds for a screen (separators kept as false); active(ctx) answers the context checks.
function D.visible(screen, active)
    local out = {}
    for _, row in ipairs(D.ROWS[screen] or {}) do
        if type(row) == 'table' then
            local name = row[2]
            local negate = name:sub(1, 1) == '!'
            if negate then name = name:sub(2) end
            if (active(name) == true) ~= negate then out[#out + 1] = row[1] end
        else
            out[#out + 1] = row
        end
    end
    return out
end

-- Rows the highlight can stop on: everything but separators.
function D.selectable(rows)
    local out = {}
    for _, row in ipairs(rows) do
        if row ~= false then out[#out + 1] = row end
    end
    return out
end

-- Categories in the column (Rockstar Editor only with its context).
function D.categories(replay)
    local out = {}
    for _, id in ipairs(D.CATEGORIES) do
        if id ~= 146 or replay then out[#out + 1] = id end
    end
    return out
end

function D.isCategory(menuId)
    return indexOf(D.CATEGORIES, menuId) ~= nil
end

-- Shortest way round a wrapping list: 'DOWN' or 'UP' and the number of presses; nil when either end is unknown.
function D.path(order, from, to)
    local i, j = indexOf(order, from), indexOf(order, to)
    if not i or not j then return nil end
    local n = #order
    local down = (j - i) % n
    if down <= n - down then return 'DOWN', down end
    return 'UP', n - down
end

-- Presses that move a value from cur to target: lists wrap (shorter way round), sliders and unknown-length lists do not.
function D.relative(kind, count, cur, target)
    local d = target - cur
    if kind ~= 'slider' and count and count > 1 then
        d = d % count
        if d > count - d then d = d - count end
    end
    if d >= 0 then return 'RIGHT', d end
    return 'LEFT', -d
end

-- Absolute set: the row is reseeded one step away from the target, then one press lands on it.
function D.seed(target)
    if target <= 0 then return 1, 'LEFT' end
    return target - 1, 'RIGHT'
end

-- Maps the catalog's pref id onto the uid the running game reports: as is, by row position (same row count), or by
-- one shift shared by the whole list (a pref inserted or removed before them in a newer build).
function D.resolve(order, expected, uid)
    if indexOf(order, uid) then return uid end
    local pos = indexOf(expected, uid)
    if not pos or not order or #order == 0 then return nil end
    local total, real = 0, 0
    for _, e in ipairs(expected) do
        if type(e) == 'number' then
            total = total + 1
            if indexOf(order, e) then real = real + 1 end
        end
    end
    local best, bestHits = nil, 0
    for d = -6, 12 do
        if d ~= 0 then
            local hits = 0
            for _, e in ipairs(expected) do
                if type(e) == 'number' and indexOf(order, e + d) then hits = hits + 1 end
            end
            if hits > bestHits or (hits == bestHits and best and math.abs(d) < math.abs(best)) then best, bestHits = d, hits end
        end
    end
    -- The walk reports the catalog's own ids (no shift fits better): a missing one is a row GTA greys out (DoF below
    -- Post FX Very High), never a neighbour (it used to land on tessellation).
    if real > 0 and real >= bestHits then return nil end
    if #order == #expected and type(order[pos]) == 'number' then return order[pos] end
    if best and bestHits >= math.max(2, math.ceil(total * 0.8)) and indexOf(order, uid + best) then return uid + best end
    return nil
end

-- Puts a walked list in menu order: it starts at the expected first row when the game reported that row.
function D.rotate(seq, first)
    local i = indexOf(seq, first)
    if not i or i == 1 then return seq end
    local out = {}
    for k = 0, #seq - 1 do out[#out + 1] = seq[(i - 1 + k) % #seq + 1] end
    return out
end

-- A short fingerprint of the layout above: a calibration learned against other data is thrown away.
function D.signature()
    local parts = {}
    for _, screen in ipairs(D.CATEGORIES) do
        for _, row in ipairs(D.ROWS[screen] or {}) do
            parts[#parts + 1] = type(row) == 'table' and (row[1] .. row[2]) or tostring(row)
        end
        parts[#parts + 1] = '|'
    end
    local h = 5381
    for c in table.concat(parts, ','):gmatch('.') do h = (h * 33 + c:byte()) % 16777213 end -- stays inside 32-bit integers
    return h
end

local KINDS = { toggle = true, list = true, slider = true }

local function int(v, lo, hi)
    v = tonumber(v)
    if not v or v ~= math.floor(v) or v < lo or v > hi then return nil end
    return math.tointeger(v)
end

-- Checks a batch from the settings module: { id, screen, uid, target, kind?, count?, convar?, current?, label? }.
-- Returns the usable items and { id, code } for the refused ones.
function D.sanitize(batch, needTarget)
    local items, refused, seen = {}, {}, {}
    if type(batch) ~= 'table' then return items, refused end
    for _, raw in ipairs(batch) do
        local id = type(raw) == 'table' and raw.id
        if type(id) == 'string' and id ~= '' and #id <= 64 and not seen[id] then
            seen[id] = true
            local screen, uid = int(raw.screen, 0, 999), int(raw.uid, 0, 999)
            local target = int(raw.target, 0, 255)
            local known = KINDS[raw.kind] and {} or (D.SHAPES[uid] or {})
            local count = raw.count ~= nil and int(raw.count, 1, 255) or known[2]
            local kind = KINDS[raw.kind] and raw.kind or known[1] or (count == 2 and 'toggle' or 'list')
            local code
            if not (screen and D.TARGETS[screen] and uid) or (needTarget and not target) then code = 'validation'
            elseif D.BLOCKED[uid] then code = D.BLOCKED[uid]
            elseif target and count and kind ~= 'slider' and target >= count then code = 'validation' end
            if code then
                refused[#refused + 1] = { id = id, code = code }
            else
                local convar = type(raw.convar) == 'string' and raw.convar:match('^[%w_]+$') or nil
                items[#items + 1] = {
                    id = id, screen = screen, uid = uid, target = target or 0, kind = kind, count = count,
                    convar = convar or D.CONVARS[uid], current = int(raw.current, 0, 255),
                    label = type(raw.label) == 'string' and raw.label:sub(1, 64) or nil, video = D.VIDEO[uid] == true,
                }
            end
        end
    end
    return items, refused
end

-- Scaleform read (research gfxread 1-3): GTA's C++ builds a settings list with SET_DATA_SLOT and the menu movie keeps
-- each row as the call's arguments: slot, menu id, uid, type, value (option index or slider step), state (0 not
-- selectable, 1 selectable, 2 changed), label, then options (lists) or step count and colour (sliders).
-- Graphics rows a read must show inside their range before it is trusted (learned).
D.READ_CHECK = { 68, 69, 70, 71, 73, 74, 79, 80, 86 }

local function split(text, sep)
    local out = {}
    for part in (text .. sep):gmatch('(.-)' .. sep:gsub('%p', '%%%0')) do out[#out + 1] = part end
    return out
end

local function slider(kind) return kind == 2 or kind == 4 or (kind >= 20 and kind < 30) end

-- Rows GTA's C++ fills with one option, the current value's own text (a scaleform read shows it in the game's
-- language): the option text ids of their full list, in order (pausemenu.xml MenuDisplayOptions), to turn it back
-- into an index. They are the rows GTA steps itself (D.STEP).
local MSAA = { 'MO_OFF', 'MO_GFX_X2', 'MO_GFX_X4', 'MO_GFX_X8' }
local QUALITY = { 'MO_GFX_NORM', 'MO_CS_HIGH', 'MO_GFX_VHIGH', 'MO_GFX_ULTRA' }
D.OPTION_KEYS = {
    [80] = MSAA, [72] = MSAA, [86] = QUALITY, [75] = QUALITY,
    [76] = { 'GFX_SHARP', 'GFX_SOFT', 'GFX_SOFTER', 'GFX_SOFTEST' },
    [85] = { 'MO_OFF', 'MO_GFX_NORM', 'MO_CS_HIGH', 'MO_GFX_VHIGH' },
    [87] = { 'MO_OFF', 'MO_ON' },
}

local labelCache = {}
local function norm(text) return type(text) == 'string' and text:lower():gsub('^%s+', ''):gsub('%s+$', '') or nil end

-- The index of a shown option text in a row's option list (GTA's own texts, any language); nil when not found.
function D.labelIndex(uid, text)
    local keys, want = D.OPTION_KEYS[uid], norm(text)
    if not keys or not want or want == '' then return nil end
    for i, key in ipairs(keys) do
        if labelCache[key] == nil then
            local ok, label = pcall(GetLabelText, key)
            labelCache[key] = ok and type(label) == 'string' and label ~= 'NULL' and norm(label) or false
        end
        if labelCache[key] == want then return i - 1 end
    end
    return nil
end

-- Six whole numbers from fields[at]: one row head, or nil. whole: fields hold this row only, so the label and
-- options after the head belong to it.
local function head(fields, at, whole)
    local n = {}
    for i = at, at + 5 do
        local v = tonumber(fields[i])
        if not v or v ~= math.floor(v) then return nil end
        n[#n + 1] = math.tointeger(v)
    end
    if n[1] < 0 or n[4] < 0 or n[4] > 99 or n[6] < -1 or n[6] > 2 then return nil end
    local row = { slot = n[1], menu = n[2], uid = n[3], type = n[4], value = n[5], state = n[6] }
    local steps = slider(row.type) and math.tointeger(tonumber(fields[at + 7] or ''))
    if steps and steps >= 1 and steps <= 100 then row.steps = steps end
    if whole and not slider(row.type) then
        row.label, row.opts = fields[at + 6], {}
        for i = at + 7, #fields do row.opts[#row.opts + 1] = fields[i] end
    end
    return row
end

-- Parses a dump of the list's rows: Array.join('|') of the row arrays (fields joined by ','), or a flat
-- Array.toString where rows run together (each found by its slot and a settings menu id). { [uid] = row }, count.
function D.parseRows(text)
    if type(text) ~= 'string' or text == '' then return nil end
    local rows, count = {}, 0
    local function add(row)
        if not row then return false end
        if not rows[row.uid] then count = count + 1 end
        rows[row.uid] = rows[row.uid] or row
        return true
    end
    if text:find('|', 1, true) then
        for _, chunk in ipairs(split(text, '|')) do add(head(split(chunk, ','), 1, true)) end
    else
        local f, i, last = split(text, ','), 1, -1
        while i <= #f - 5 do
            local slot = tonumber(f[i])
            if slot and slot > last and slot <= last + 3 and (tonumber(f[i + 1]) or 0) >= 1000 and add(head(f, i)) then
                last, i = slot, i + 6
            else
                i = i + 1
            end
        end
    end
    if count == 0 then return nil end
    return rows, count
end

-- Frame scaling (81) shows the render resolution ('1920x1080'): its width over the screen's gives the option, in
-- GTA's order Off, 1/2, 2/3, 3/4, 5/6, 5/4, 3/2, 7/4, 2/1, 5/2. D.screenWidth is set by the engine (a native).
D.SCALES = { 1, 1 / 2, 2 / 3, 3 / 4, 5 / 6, 5 / 4, 3 / 2, 7 / 4, 2, 5 / 2 }

function D.scaleIndex(text, screenWidth)
    local w = type(text) == 'string' and tonumber(text:match('^%s*(%d+)%s*[xX]%s*%d+'))
    if not w or not screenWidth or screenWidth <= 0 then return nil end
    local ratio = w / screenWidth
    for i, scale in ipairs(D.SCALES) do
        if math.abs(ratio - scale) < 0.02 then return i - 1 end
    end
    return nil
end

-- Rows GTA's C++ also fills with one option, the current value's text, that a read cannot turn back into an index
-- (screen type, resolution, refresh rate, aspect ratio, output monitor, DX version): their value field is always 0.
D.FILLED = { [56] = true, [57] = true, [58] = true, [61] = true, [60] = true, [67] = true }

-- The value a read gives a row: an option index inside its list, or a slider step; nil when absent or out of range.
function D.rowValue(rows, uid, kind, count)
    local row = rows and rows[uid]
    if not row or math.type(row.value) ~= 'integer' or row.value < 0 then return nil end
    -- A row GTA filled with one option shows its value as that option's text, never as the index (always 0); with the
    -- text cut off by the 63 characters GTA returns, or a filled row whose text means nothing here, there is no value.
    local opts = row.opts and #row.opts or 0
    if D.STEP[uid] or D.FILLED[uid] or (opts == 1 and kind ~= 'slider') then
        if opts == 1 and uid == 81 then return D.scaleIndex(row.opts[1], D.screenWidth and D.screenWidth()) end
        if opts == 1 then return D.labelIndex(uid, row.opts[1]) end
        if opts < 2 then return nil end
    end
    local shape = D.SHAPES[uid] or {}
    kind, count = kind or shape[1], count or shape[2]
    if kind == 'slider' then count = row.steps or count end
    if count and row.value > (kind == 'slider' and count or count - 1) then return nil end
    return row.value
end

-- A read of the graphics list is trusted when enough well-known rows hold a value in range.
function D.plausible(rows)
    local hits = 0
    for _, uid in ipairs(D.READ_CHECK) do
        if D.rowValue(rows, uid) ~= nil then hits = hits + 1 end
    end
    return hits >= 5, hits
end

-- A read is of this screen's list (not of the category the highlight passed on its way): at least half of the rows
-- the screen always shows are in it.
function D.belongs(rows, screen)
    local total, hits = 0, 0
    for _, row in ipairs(D.ROWS[screen] or {}) do
        if type(row) == 'number' then
            total = total + 1
            if rows and rows[row] then hits = hits + 1 end
        end
    end
    return total > 0 and hits * 2 >= total
end

-- Rows the highlight stops on, in menu order, from a read: separators (type 6) and rows GTA greys out (state 0, the
-- highlight skips them in game) left out. The same order the calibration walk learns, without walking.
function D.readOrder(rows)
    local list = {}
    for uid, row in pairs(rows or {}) do
        if row.type ~= 6 and row.state ~= 0 and row.menu ~= 0 then list[#list + 1] = { slot = row.slot, uid = uid } end
    end
    table.sort(list, function(a, b) return a.slot < b.slot end)
    local out = {}
    for i, r in ipairs(list) do out[i] = r.uid end
    return out
end

-- Each row the highlight stops on and its slot (the index a jump takes, D.jump), from a read: { [uid] = slot }.
function D.readSlots(rows)
    local out = {}
    for uid, row in pairs(rows or {}) do
        if row.type ~= 6 and row.state ~= 0 and row.menu ~= 0 then out[uid] = row.slot end
    end
    return out
end

-- Why a row cannot be changed on this PC right now, from a read: 'absent' (GTA does not show it, as TXAA without
-- support) or 'greyed' (shown but not selectable, as depth of field below Post FX Very High); nil when it can.
function D.lockOf(rows, uid)
    local row = rows and rows[uid]
    if not row then return 'absent' end
    if row.state == 0 then return 'greyed' end
    return nil
end

-- Groups items by screen in category order, each group in row order, so the highlight only moves forward. An
-- APPLY_FIRST row with other rows of its screen gets a group (and an Apply) of its own before them.
local function applyFirst(screen, list, out)
    local first, rest = {}, {}
    for _, item in ipairs(list) do
        local into = D.APPLY_FIRST[item.uid] and first or rest
        into[#into + 1] = item
    end
    if #first == 0 or #rest == 0 then
        out[#out + 1] = { screen = screen, items = list }
        return
    end
    out[#out + 1] = { screen = screen, items = first }
    out[#out + 1] = { screen = screen, items = rest }
end

function D.plan(items)
    local by, out = {}, {}
    for _, item in ipairs(items) do
        by[item.screen] = by[item.screen] or {}
        table.insert(by[item.screen], item)
    end
    for _, screen in ipairs(D.CATEGORIES) do
        local list = by[screen]
        if list then
            local rows = D.visible(screen, function() return true end)
            table.sort(list, function(a, b)
                return (indexOf(rows, a.uid) or 999) < (indexOf(rows, b.uid) or 999)
            end)
            applyFirst(screen, list, out)
        end
    end
    return out
end
