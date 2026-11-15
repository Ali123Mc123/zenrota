-- Health scan, the player's own view and the latest faults as ox_lib menus (Config.Health); each line also goes to
-- the F8 console, so it can be copied.
local cfg = Config.Health
if not cfg then return end

local t = DL.locale.t
local LOOK = { ok = { 'circle-check', '#2f9e44', '^2' }, warn = { 'triangle-exclamation', '#f08c00', '^3' }, bad = { 'circle-xmark', '#e03131', '^1' } }
local RANK = { bad = 1, warn = 2, ok = 3 }

local function ask(name, data)
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:health:' .. name, false, data or {}))
    if result.ok then return result.data end
    Core.HandleResult(result, 'health')
end

-- Bad lines first; returns the menu rows and how many lines are bad and warn.
local function rows(lines, heading)
    table.sort(lines, function(a, b)
        if RANK[a.state] ~= RANK[b.state] then return (RANK[a.state] or 2) < (RANK[b.state] or 2) end
        return a.text < b.text
    end)
    local out, bad, warn = {}, 0, 0
    for i, entry in ipairs(lines) do
        local look = LOOK[entry.state] or LOOK.warn
        bad, warn = bad + (entry.state == 'bad' and 1 or 0), warn + (entry.state == 'warn' and 1 or 0)
        out[i] = { title = entry.text, icon = look[1], iconColor = look[2], readOnly = true }
        print(('[college] %s%s %s^7'):format(look[3], heading, entry.text))
    end
    return out, bad, warn
end

local function check()
    local data = ask('check')
    if not data then return end
    local main = {}
    for i, section in ipairs(data.sections) do
        local options, bad, warn = rows(section.lines, section.title .. ':')
        local id = 'college_health_' .. section.key
        local look = LOOK[bad > 0 and 'bad' or warn > 0 and 'warn' or 'ok']
        lib.registerContext({ id = id, title = section.title, menu = 'college_health', options = options })
        main[i] = { title = section.title, description = t('health.summary', #options - bad - warn, warn, bad), icon = look[1], iconColor = look[2], menu = id, arrow = true }
    end
    lib.registerContext({ id = 'college_health', title = t('health.title_check'), options = main })
    lib.showContext('college_health')
end

local function me(args)
    local data = ask('me', { target = tonumber(args[1]) })
    if not data then return end
    lib.registerContext({ id = 'college_me', title = t('health.title_me'), options = (rows(data.lines, '')) })
    lib.showContext('college_me')
end

-- A fault's row: the menu shows where and who, a click copies the whole error.
local function faults(args)
    local data = ask('faults', { query = args[1] })
    if not data then return end
    local options = {}
    for i, row in ipairs(data.rows) do
        local detail = tostring(row.detail or '-')
        local look = LOOK[row.kind == 'error' and 'bad' or 'warn']
        options[i] = {
            title = ('%s  %s  %s'):format(row.code, row.product, row.place), description = detail:match('^[^\n]*'):sub(1, 140),
            icon = look[1], iconColor = look[2],
            metadata = { { label = t('health.fault_player'), value = ('%s (%s)'):format(row.player or '-', row.citizenid or '-') },
                { label = t('health.fault_hits'), value = row.hits }, { label = t('health.fault_input'), value = tostring(row.input or '-'):sub(1, 300) } },
            onSelect = function()
                print(('[college] %s %s %s\n%s\ninput: %s'):format(row.code, row.product, row.place, detail, tostring(row.input or '-')))
                lib.setClipboard(('%s %s %s\n%s'):format(row.code, row.product, row.place, detail))
                Core.NotifyL('health.fault_copied', 'success', row.code)
            end,
        }
    end
    if #options == 0 then return Core.NotifyL('health.faults_empty', 'inform') end
    lib.registerContext({ id = 'college_faults', title = t('health.title_faults'), options = options })
    lib.showContext('college_faults')
end

for name, fn in pairs({ check = check, me = me, faults = faults }) do
    local command = cfg.Commands and cfg.Commands[name]
    if (command or '') ~= '' then Core.Command(command, fn) end
end
