-- Settings rules the client and the tests share: which engine writes a row, value checks, the console line Engine A runs,
-- what Apply hands to the GTA settings driver, Restore defaults, and the rows the page gets. No natives.
PMSettings = PMSettings or {}

-- Convars no engine ever writes: a crash (monitor), a reset of every setting, menu internals, unknown prefs.
PMSettings.NEVER = {
    profile_vidMonitor = true, profile_0xf50f1958 = true, profile_controlsContext = true, profile_currentLanguage = true,
    profile_0x01f41314 = true, profile_0x433be7cb = true, profile_0xa91b9521 = true, profile_0xe813dce9 = true,
}

local WRITABLE = { A = true, B = true, F = true, P = true }
local byId, tabById

local function index()
    if byId then return end
    byId, tabById = {}, {}
    for _, row in ipairs(PMSettings.ROWS or {}) do byId[row.id] = row end
    -- Rows the layout adds (shared/settings_layout.lua), such as the graphics preset.
    for _, row in ipairs(PMSettings.EXTRA or {}) do byId[row.id] = byId[row.id] or row end
    for _, tab in ipairs(PMSettings.TABS or {}) do tabById[tab.id] = tab end
end

function PMSettings.row(id)
    index()
    return type(id) == 'string' and byId[id] or nil
end

function PMSettings.tab(id)
    index()
    return tabById[id]
end

-- A section of the settings screen (a GTA tab it shows) by id.
function PMSettings.section(id)
    local tab = type(id) == 'string' and PMSettings.tab(id) or nil
    return tab and not (PMSettings.DROP_TAB or {})[tab.id] and tab or nil
end

-- The GTA settings screen that holds a row (driver target), nil for tabs GTA has no screen id for.
function PMSettings.screen(row)
    local tab = PMSettings.tab(row.tab)
    return tab and tab.screen or nil
end

-- A row's range: one measured in game (Config.Settings.Ranges, by convar or id) wins; nil while unknown.
function PMSettings.range(row, ranges)
    local custom = type(ranges) == 'table' and (ranges[row.convar or ''] or ranges[row.id]) or nil
    local lo, hi = type(custom) == 'table' and tonumber(custom[1]), type(custom) == 'table' and tonumber(custom[2])
    if lo and hi and lo <= hi then return math.floor(lo), math.floor(hi) end
    if row.min and row.max then return row.min, row.max end
end

-- Shown in this game at all: hidden by config or by the layout's default list (Config.Settings.Show brings a row or a
-- GTA key section back), the Rockstar Editor tab, pma-voice rows, rows only Engine A reaches.
function PMSettings.visible(row, env)
    if type(env.hide) == 'table' and env.hide[row.id] then return false end
    local show = type(env.show) == 'table' and env.show or {}
    if PMSettings.HIDE_DEFAULT and PMSettings.HIDE_DEFAULT[row.id] and not show[row.id] then return false end
    if row.cls == 'K' and row.section and PMSettings.HIDE_KEY_SECTIONS and PMSettings.HIDE_KEY_SECTIONS[row.section]
        and not show[row.section] and not show[row.id] then return false end
    if row.tab == 'editor' and not env.editor then return false end
    if row.cls == 'P' then return env.voice == true end
    if row.cls == 'F' or row.aonly then return env.privileged == true end
    return true
end

-- How a row gets written: A privileged convar flush (driver as fallback), B GTA settings driver, F FiveM convar,
-- P pma-voice, K key binding hand-off, O interface prefs (page only), R a preset the page expands into other rows,
-- handoff = read-only, changed in GTA's menu.
function PMSettings.engine(row, env)
    local cls = row.cls
    if row.kind == 'header' or not cls then return nil end
    if cls == 'O' or cls == 'K' or cls == 'P' then return cls end
    if cls == 'R' then
        -- A preset is live only while one of its rows can be written on this PC.
        for _, id in ipairs(PMSettings.PRESET_ROWS or {}) do
            local target = PMSettings.row(id)
            local engine = target and PMSettings.engine(target, env)
            if engine == 'A' or engine == 'B' or engine == 'F' then return 'R' end
        end
        return 'handoff'
    end
    if row.ro or row.never or (row.convar and PMSettings.NEVER[row.convar]) then return 'handoff' end
    if not PMSettings.range(row, env.ranges) then return 'handoff' end
    if cls == 'F' then return env.privileged and 'F' or 'handoff' end
    if cls == 'N' then
        if env.privileged then return 'A' end
        if env.driver and PMSettings.screen(row) and not row.aonly then return 'B' end
        return 'handoff'
    end
    if cls == 'G' or cls == 'V' then return env.driver and 'B' or 'handoff' end
    return 'handoff'
end

local function bounds(row, env)
    local lo, hi = PMSettings.range(row, env.ranges)
    if row.cls == 'P' and row.list then hi = math.max(0, (tonumber(env.voiceModes) or (hi + 1)) - 1) end
    return lo, hi
end

-- A value from the page as a whole number inside the row's range; nil when this row cannot be written from here.
function PMSettings.clamp(row, value, env)
    if not row or not WRITABLE[PMSettings.engine(row, env) or ''] then return nil end
    value = tonumber(value)
    if not value or value ~= value then return nil end
    local lo, hi = bounds(row, env)
    return math.floor(math.max(lo, math.min(hi, value)) + 0.5)
end

-- The console line Engine A runs: 'profile_sfxVolume 5' or 'cl_drawFPS true'. nil for anything it must not write.
function PMSettings.command(row, value, ranges)
    if not row or not row.convar or row.never or row.ro or PMSettings.NEVER[row.convar] then return nil end
    if row.cls ~= 'N' and row.cls ~= 'F' then return nil end
    local lo, hi = PMSettings.range(row, ranges)
    value = math.tointeger(tonumber(value) or 0.5)
    if not lo or not value or value < lo or value > hi then return nil end
    if row.bool then
        local on = value == 1
        if row.invert then on = not on end
        return ('%s %s'):format(row.convar, on and 'true' or 'false')
    end
    return ('%s %d'):format(row.convar, value)
end

-- A FiveM boolean convar's text as the row's 0 / 1 (camera shake shows "on" while the convar disables it).
function PMSettings.decode(row, raw)
    local on = raw == 'true' or raw == '1'
    if row.invert then on = not on end
    return on and 1 or 0
end

-- What Apply still has to do after Engine A wrote what it could: pma-voice rows, a driver batch, and failures.
function PMSettings.split(pending, env)
    local plan, ids = { voice = {}, driver = {}, failed = {} }, {}
    for id in pairs(pending) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local row = PMSettings.row(id)
        local engine = row and PMSettings.engine(row, env)
        local screen = row and PMSettings.screen(row)
        if engine == 'P' then
            plan.voice[#plan.voice + 1] = id
        elseif (engine == 'A' or engine == 'B') and env.driver and screen and row.uid and not row.aonly then
            plan.driver[#plan.driver + 1] = { id = id, screen = screen, uid = row.uid, target = pending[id], convar = row.convar }
        else
            plan.failed[#plan.failed + 1] = id
        end
    end
    return plan
end

-- The preset rows' values for preset index i (1 Low .. 4 Ultra), checked against what this PC can write.
function PMSettings.preset(i, env)
    local values, out = PMSettings.PRESETS and PMSettings.PRESETS[i], {}
    if not values then return out end
    for n, id in ipairs(PMSettings.PRESET_ROWS) do
        local row = PMSettings.row(id)
        if row and PMSettings.visible(row, env) then out[id] = PMSettings.clamp(row, values[n], env) end
    end
    return out
end

-- Restore defaults of one section (a GTA tab): { id = value } for its writable rows with a known default
-- (Config.Settings.Defaults wins); the graphics rows take the High preset, as GTA keeps no defaults for them.
function PMSettings.defaults(sectionId, env)
    local out = {}
    local function add(row)
        if row.tab == sectionId and row.cls ~= 'O' and row.cls ~= 'R' and PMSettings.visible(row, env) then
            local custom = type(env.defaults) == 'table' and (env.defaults[row.convar or ''] or env.defaults[row.id]) or nil
            local value = custom
            if value == nil then value = row.default end
            if value ~= nil then out[row.id] = PMSettings.clamp(row, value, env) end
        end
    end
    for _, row in ipairs(PMSettings.ROWS or {}) do add(row) end
    for _, row in ipairs(PMSettings.EXTRA or {}) do add(row) end
    if PMSettings.GRAPHICS_DEFAULT then
        for id, value in pairs(PMSettings.preset(PMSettings.GRAPHICS_DEFAULT, env)) do
            if PMSettings.row(id).tab == sectionId and out[id] == nil then out[id] = value end
        end
    end
    return out
end

local COPY = { 'id', 'tab', 'kind', 'widget', 'cls', 'list', 'ctrl', 'section', 'default', 'restart', 'confirm', 'video', 'cond' }

-- One row as the page gets it, on the tab it shows on.
local function pageRow(row, env, tab)
    local out = {}
    for _, key in ipairs(COPY) do out[key] = row[key] end
    out.tab = tab
    out.engine = PMSettings.engine(row, env)
    out.gtaScreen = PMSettings.screen(row)
    -- GTA never reports this one: the page shows the value the driver applied last.
    out.unread = (row.cls == 'G' and not row.convar and not row.pid) or nil
    if row.kind ~= 'header' then out.min, out.max = bounds(row, env) end
    if row.list and out.max then out.count = out.max - out.min + 1 end
    if out.engine == 'handoff' then out.readOnly, out.widget = true, 'label' end
    return out
end

-- A tab's rows in GTA's order, with the layout's own rows where it puts them.
local function tabRows(tabId)
    local list = {}
    for _, row in ipairs(PMSettings.ROWS or {}) do
        if row.tab == tabId then list[#list + 1] = row end
    end
    for _, row in ipairs(PMSettings.EXTRA or {}) do
        if row.tab == tabId then
            local at = row.first and 1 or #list + 1
            for i, other in ipairs(list) do
                if other.id == row.after then at = i + 1 end
            end
            table.insert(list, at, row)
        end
    end
    return list
end

-- Sections and rows for the page (pm:settings:load): GTA's tabs in GTA's order, each tab's rows in GTA's order, a new
-- group at every header GTA shows (titled) and at its blank separators (untitled). Hidden rows and empty groups are
-- dropped, engine and read-only resolved; the FiveM group stays for the server's own keys (client/settings/nui.lua).
function PMSettings.view(env)
    local sections, rows = {}, {}
    local dropTab, breaks, untitled = PMSettings.DROP_TAB or {}, PMSettings.BREAKS or {}, PMSettings.UNTITLED or {}
    for _, tab in ipairs(PMSettings.TABS or {}) do
        if not dropTab[tab.id] then
            local groups, group = {}, { id = tab.id, rowIds = {} }
            local function close()
                if #group.rowIds > 0 or group.fivem then groups[#groups + 1] = group end
            end
            for _, row in ipairs(tabRows(tab.id)) do
                if row.kind == 'header' then
                    close()
                    group = { id = row.id, head = not untitled[row.id] and row.id or nil, rowIds = {}, fivem = row.id == PMSettings.FIVEM_GROUP or nil }
                elseif PMSettings.visible(row, env) then
                    if breaks[row.id] and #group.rowIds > 0 then
                        close()
                        group = { id = row.id, rowIds = {} }
                    end
                    local out = pageRow(row, env, tab.id)
                    out.home, out.group = tab.id, group.id
                    rows[#rows + 1] = out
                    group.rowIds[#group.rowIds + 1] = row.id
                end
            end
            close()
            local shown = 0
            for _, g in ipairs(groups) do shown = shown + #g.rowIds end
            if shown > 0 then sections[#sections + 1] = { id = tab.id, icon = tab.icon, screen = tab.screen, groups = groups } end
        end
    end
    return sections, rows
end
