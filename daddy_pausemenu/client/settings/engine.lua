-- Settings, writing. Values the page picks wait in `pending` until Apply. Engine A: the Apply click reaches the game
-- through a key binding whose handler runs as the console, so it may set profile_* and FiveM convars (research A, Z 3.2.2).
-- What it could not write goes to pma-voice or to the GTA settings driver (PM.Driver); the rest is reported as failed.
PM.Settings = PM.Settings or {}
local S = PM.Settings
local now = GetGameTimer

local pending, written = {}, {}
local armed, graceUntil, lastFlush = false, 0, 0

local function config() return Config.Settings or {} end

function S.IsPending(id) return pending[id] ~= nil end

-- Pending rows Engine A can write (profile and FiveM convars with a console line).
function S.NeedsFlush()
    local ranges = config().Ranges
    for id, value in pairs(pending) do
        if PMSettings.command(PMSettings.row(id), value, ranges) then return true end
    end
    return false
end

-- Engine A. Runs inside the key binding handler and must stay synchronous: a Wait would drop the console's rights.
-- Every gameplay left click lands here too, so it returns at once unless the Apply button is armed.
local function flush()
    if not armed and now() > graceUntil then return end
    if not next(pending) then return end
    lastFlush = now()
    local ranges = config().Ranges
    for id, value in pairs(pending) do
        local row = PMSettings.row(id)
        local line = PMSettings.command(row, value, ranges)
        -- Per convar: from F8 on a production client only a few convars are allowed (research A, verifier V3).
        if line and IsAceAllowed('command.' .. row.convar) then
            ExecuteCommand(line)
            if S.Read(row) == value then pending[id], written[#written + 1] = nil, id end
        end
    end
end

-- A value the page picked, checked against the catalog; forgotten when it equals what the game already has. Rows GTA
-- greys out or does not show on this PC take none. env: S.Env(), when the caller already has it.
function S.SetPending(id, value, env)
    local row = PMSettings.row(id)
    env = env or S.Env()
    if not row or not PMSettings.visible(row, env) or S.Locked(env)[id] then return nil end
    local v = PMSettings.clamp(row, value, env)
    if v == nil then return nil end
    pending[id] = S.Read(row) ~= v and v or nil
    return v
end

function S.Discard()
    pending, written = {}, {}
end

-- Pointer over Apply (or keyboard focus on it): the game gets input too while the page keeps focus, so the click fires
-- +pausemenu_apply. Only then: at any other moment kept input would let other resources' key bindings fire.
function S.Arm(on)
    on = on == true and PM.IsOpen() and PM.Screen() == 'settings' and config().PrivilegedWrite ~= false and S.NeedsFlush()
    if on == armed then return armed end
    armed = on
    if not on then
        graceUntil = now() + 300
        if PM.IsOpen() and PM.Input() == 'keep' then PM.SetInput('ui') end
        return false
    end
    if not PM.SetInput('keep') then
        armed = false
        return false
    end
    local session = PM.Session()
    CreateThread(function()
        local pid = PlayerId()
        while armed and PM.IsOpen() and PM.Session() == session do
            DisableAllControlActions(0)
            DisablePlayerFiring(pid, true)
            Wait(0)
        end
    end)
    return true
end

-- pma-voice: the range is cycled with its own unrestricted command, volumes go through its exports (0-100).
function S.WriteVoice(row, value)
    local res = S.VoiceResource()
    if not row or not res or value == nil then return false end
    if row.id == 'voice_proximity' then
        local current = S.Read(row)
        if current == nil then return false end
        local count = math.max(1, tonumber((config().Voice or {}).Modes) or 3)
        for _ = 1, (value - current) % count do ExecuteCommand('cycleproximity') end
        Wait(100)
        return S.Read(row) == value
    end
    local fn = row.id == 'radio_volume' and 'setRadioVolume' or 'setCallVolume'
    local ok = pcall(function() exports[res][fn](exports[res], value * 10) end)
    if ok then S.RememberVoice(row.id, value) end
    return ok and S.Read(row) == value
end

-- Rows GTA does not show on this PC or greys out, as the driver's last read found them ({ [id] = 'absent' | 'greyed' });
-- none without the driver (nothing reads them then). env: S.Env(), when the caller already has it.
function S.Locked(env)
    if not (env or S.Env()).driver or type(PM.Driver.Locked) ~= 'function' then return {} end
    local ok, locked = pcall(PM.Driver.Locked)
    return ok and type(locked) == 'table' and locked or {}
end

-- When the driver last read GTA's graphics values (a sync or a run), so the page can say how fresh they are.
local readAt

function S.ReadAgo()
    return readAt and math.max(0, now() - readAt) or nil
end

-- Driver results go to the page as one pm:settings:result; the driver keeps the graphics values it set itself.
local function report(result, sync)
    result = type(result) == 'table' and result or {}
    local values = {}
    for _, id in ipairs(result.done or {}) do
        local row = PMSettings.row(id)
        if row then values[id] = (result.values or {})[id] or S.Read(row) end
    end
    -- A row GTA did not take the value for: what it shows instead.
    for _, id in ipairs(result.failed or {}) do
        if (result.values or {})[id] ~= nil then values[id] = result.values[id] end
    end
    if sync and #(result.done or {}) > 0 then readAt = now() end
    if PM.IsOpen() then
        PM.Send('pm:settings:result', {
            done = result.done or {}, failed = result.failed or {}, values = values, errors = result.errors, sync = sync, locked = S.Locked(),
            readAgo = S.ReadAgo(),
        })
    end
end

-- Calls a PM.Driver entry point. It answers through `done` exactly once; a refusal answers before Run returns, and
-- then the caller gets that result here instead of a later message.
local function drive(fn, list, sync)
    local inside, settled = true, nil
    local ok, accepted = pcall(fn, list, function(result)
        if inside then settled = result else report(result, sync) end
    end)
    inside = false
    if ok and accepted ~= false and not settled then return nil end
    return settled or { failed = {}, error = 'generic' }
end

-- A driver batch row: the driver maps uid to the running build; kind and count help it on rows without a convar.
local function step(id, value)
    local row = PMSettings.row(id)
    local out = { id = id, screen = PMSettings.screen(row), uid = row.uid, target = value, convar = row.convar, kind = row.kind }
    if row.list then out.count = row.max - row.min + 1 end
    if not row.convar then out.current = S.Read(row) end
    return out
end

-- Apply, after the click's flush: what Engine A wrote, pma-voice rows, then one driver run for everything else.
function S.Apply()
    local env = S.Env()
    local result = { done = written, driver = {}, failed = {} }
    -- Still writable by Engine A after the click: its key binding is unbound or rebound, so the driver takes over.
    if env.privileged and S.NeedsFlush() and now() - lastFlush > 1500 then result.keymap = true end
    local todo = pending
    pending, written = {}, {}
    local plan = PMSettings.split(todo, env)
    for _, id in ipairs(plan.voice) do
        table.insert(S.WriteVoice(PMSettings.row(id), todo[id]) and result.done or result.failed, id)
    end
    for _, id in ipairs(plan.failed) do table.insert(result.failed, id) end
    if #plan.driver == 0 then return result end
    local batch = {}
    for _, item in ipairs(plan.driver) do batch[#batch + 1] = step(item.id, item.target) end
    -- drive() answers nil for a started run, so no `and/or` here.
    local settled = { error = 'unavailable' }
    if type(PM.Driver) == 'table' then settled = drive(PM.Driver.Run, batch, false) end
    if not settled then
        for _, item in ipairs(batch) do table.insert(result.driver, item.id) end
        return result
    end
    -- Refused at once (busy, disabled, closed...): every row of the batch failed.
    for _, item in ipairs(batch) do table.insert(result.failed, item.id) end
    result.busy = settled.error == 'busy' or settled.error == 'busy_frontend'
    return result
end

-- "Sync": the driver reads the graphics rows GTA never reports (research B 7.3) and the page hears the values.
function S.Sync()
    if type(PM.Driver) ~= 'table' or type(PM.Driver.Sync) ~= 'function' then return false end
    local rows, env = {}, S.Env()
    for _, row in ipairs(PMSettings.ROWS) do
        if row.cls == 'G' and not row.convar and not row.pid and not row.ro and PMSettings.visible(row, env) then
            rows[#rows + 1] = { id = row.id, screen = PMSettings.screen(row), uid = row.uid, kind = row.kind, count = row.list and (row.max - row.min + 1) or nil }
        end
    end
    local settled = drive(PM.Driver.Sync, rows, true)
    if settled then report(settled, true) end
    return settled == nil
end

-- GTA's own settings or key bindings screen; ours comes back on the settings screen when it closes.
-- FiveM's keys are the last category of GTA's key binding screen: one step up from the first wraps to it. Showing it
-- also makes FiveM name the server's keys for this session (values.lua).
local function toFiveM()
    local stop = GetGameTimer() + 3000
    while not (IsPauseMenuActive() and IsFrontendReadyForControl()) do
        if GetGameTimer() > stop then return end
        Wait(0)
    end
    Wait(300) -- GTA's menu drops input for a moment after it opens
    SetControlNormal(2, 188, 1.0) -- FRONTEND_CONTROL, INPUT_FRONTEND_UP
end

function S.Handoff(target)
    S.Arm(false)
    S.Discard()
    -- What GTA greys out may change there: the locks wait for the next read.
    if type(PM.Driver) == 'table' and PM.Driver.ForgetLocks then PM.Driver.ForgetLocks() end
    local keys = target == 'keys' or target == 'fivem'
    local menu = keys and 'FE_MENU_VERSION_LANDING_KEYMAPPING_MENU' or 'FE_MENU_VERSION_LANDING_MENU'
    local ok = PM.OpenFrontend(menu, false, 'settings')
    if ok and target == 'fivem' then CreateThread(toFiveM) end
    return ok
end

-- Restore defaults of a section: they become pending values (Apply writes them).
function S.Restore(section)
    local env = S.Env()
    local values = PMSettings.defaults(section, env)
    for id in pairs(S.Locked(env)) do values[id] = nil end
    for id, value in pairs(values) do S.SetPending(id, value, env) end
    return values
end

-- Key binding names live in the locales under keys.* (keys.apply, keys.apply_k).
local function keyName(verb) return DL.locale.t('keys.' .. verb) end

if config().PrivilegedWrite ~= false then
    RegisterCommand('+pausemenu_apply', flush, false)
    RegisterCommand('-pausemenu_apply', flush, false)
    RegisterKeyMapping('+pausemenu_apply', keyName('apply'), 'MOUSE_BUTTON', 'MOUSE_LEFT')
    RegisterCommand('+pausemenu_apply_k', flush, false)
    RegisterCommand('-pausemenu_apply_k', function() end, false)
    RegisterKeyMapping('+pausemenu_apply_k', keyName('apply_k'), 'keyboard', 'RETURN')
end
