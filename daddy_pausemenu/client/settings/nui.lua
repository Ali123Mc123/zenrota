-- Settings screen callbacks (pm:settings:*): load, pending values, Apply arming and Apply, the graphics sync, discard,
-- Restore defaults and the hand-off to GTA's own settings or key bindings screen. Nothing here reaches the server: game
-- settings stay on this PC.
PM.Settings = PM.Settings or {}
local S = PM.Settings

local function fail(code) return { ok = false, error = code } end

-- The server's keys join the Key Bindings section as rows of its FiveM group.
local function addFiveMKeys(sections, rows, keys)
    local group
    for _, section in ipairs(sections) do
        for _, g in ipairs(section.groups) do
            if g.fivem then group = g end
        end
    end
    if not group then return end
    for _, item in ipairs(S.FiveMKeys()) do
        rows[#rows + 1] = {
            id = item.id, tab = 'keys', kind = 'trigger', widget = 'keys', cls = 'K', engine = 'K', home = 'keys', group = group.id,
            fivem = { cmd = item.cmd, resource = item.resource, label = item.label },
        }
        table.insert(group.rowIds, item.id)
        keys[item.id] = item.key
    end
end

PM.Callback('pm:settings:load', function()
    local env = S.Env()
    local sections, rows = PMSettings.view(env)
    local values, keys = S.Snapshot(rows)
    addFiveMKeys(sections, rows, keys)
    S.DebugKeycodes()
    return {
        ok = true,
        data = {
            sections = sections, rows = rows, values = values, keys = keys, texts = S.Texts(), locked = S.Locked(env),
            flags = { privileged = env.privileged, driver = env.driver, voice = env.voice, pad = env.pad },
            presets = { rows = PMSettings.PRESET_ROWS, values = PMSettings.PRESETS },
            readAgo = S.ReadAgo(),
            uiDefaults = PMShared.defaultPrefs(Config.Theme),
        },
    }
end)

PM.Callback('pm:settings:pending', function(data)
    if type(data.id) ~= 'string' then return fail('validation') end
    local value = S.SetPending(data.id, data.value)
    if value == nil then return fail('readonly') end
    return { ok = true, data = { value = value } }
end)

PM.Callback('pm:settings:arm', function(data)
    return { ok = true, data = { armed = S.Arm(data.on == true) } }
end)

PM.Callback('pm:settings:apply', function()
    if not PM.IsOpen() then return fail('validation') end
    S.Arm(false)
    return { ok = true, data = S.Apply() }
end)

PM.Callback('pm:settings:sync', function()
    if not PM.IsOpen() then return fail('validation') end
    S.Arm(false)
    return { ok = true, data = { started = S.Sync() } }
end)

PM.Callback('pm:settings:discard', function()
    S.Arm(false)
    S.Discard()
    return { ok = true }
end)

PM.Callback('pm:settings:restore', function(data)
    if not PMSettings.section(data.section) then return fail('validation') end
    return { ok = true, data = { values = S.Restore(data.section) } }
end)

PM.Callback('pm:settings:handoff', function(data)
    if data.target ~= 'settings' and data.target ~= 'keys' and data.target ~= 'fivem' then return fail('validation') end
    if not PM.IsOpen() then return fail('validation') end
    if type(PM.Driver) == 'table' and PM.Driver.Busy() then return fail('busy') end
    return { ok = S.Handoff(data.target) }
end)

-- Kept input must never outlive the settings screen, and unapplied values die with the menu.
PM.RegisterScreen('settings', { leave = function() S.Arm(false) end })
PM.OnClose(function()
    S.Arm(false)
    S.Discard()
end)
