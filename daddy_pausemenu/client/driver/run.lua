-- Settings driver (Engine B), public side: PM.Driver for the settings module, the overlay state for the page and
-- the session lifecycle (bypass, input variant, cleanup, what it learned). Flag: Config.Settings.FrontendDriver.
local RESOURCE = GetCurrentResourceName()
local D = PMDrv
local now = GetGameTimer

local KVP = {
    learn = RESOURCE .. ':driver:learn', cal = RESOURCE .. ':driver:cal', gfx = RESOURCE .. ':driver:gfx', res = RESOURCE .. ':driver:res',
    lock = RESOURCE .. ':driver:lock',
}
-- Codes that fail one row and let the run go on; any other error stops the whole session.
local ROW_ERRORS = { unknown_current = true, verify_failed = true, not_found = true, seed_failed = true }
local MODES = { focus = true, nofocus = true, scaleform = true }
local VARIANTS = { 'component', 'component1000', 'restart' }
-- Gameplay controls held off while the page has no focus (the keyboard reaches the game then).
local GAMEPLAY = { 21, 22, 24, 25, 30, 31, 32, 33, 34, 35, 37, 44, 45, 140, 141, 142, 257, 263, 264 }

local busy = false
PM.Driver = {}

local function call(fn, ...)
    if not fn then return end
    local ok, err = pcall(fn, ...)
    if not ok then print(('^1[%s] driver: %s^7'):format(RESOURCE, err)) end
end

local function readKvp(key)
    local ok, value = pcall(json.decode, GetResourceKvpString(key) or '')
    return ok and type(value) == 'table' and value or {}
end

-- What the engine learned on this game build (input variant, direct landing, seed self-test, row orders) and the
-- graphics values our runs set or read.
local function ensureLoaded()
    if D.learn then return end
    local build = GetGameBuildNumber()
    D.learn = readKvp(KVP.learn)
    if D.learn.build ~= build then D.learn = { build = build } end
    D.cal = readKvp(KVP.cal)
    if D.cal.build ~= build or D.cal.sig ~= D.signature() or type(D.cal.screens) ~= 'table' then
        D.cal = { build = build, sig = D.signature(), screens = {} }
    end
    D.gfx = readKvp(KVP.gfx)
    -- Before the step rows were tracked, MSAA and Post FX kept the target, not what GTA made of it: drop those once.
    if (D.learn.gfxv or 0) < 2 then
        D.gfx.gfx_msaa, D.gfx.gfx_post_fx, D.gfx.gfx_reflection_msaa = nil, nil, nil
        D.learn.gfxv = 2
    end
    D.res = readKvp(KVP.res)
    D.lock = readKvp(KVP.lock)
    if D.lock.build ~= build then D.lock = { build = build } end
end

function D.saveLearn() SetResourceKvp(KVP.learn, json.encode(D.learn)) end

function D.saveOrder(screen, seq)
    D.cal.screens[tostring(screen)] = seq
    SetResourceKvp(KVP.cal, json.encode(D.cal))
end

function D.cached(id)
    local v = D.gfx[id]
    return type(v) == 'number' and math.tointeger(v) or nil
end

local function saveValues()
    SetResourceKvp(KVP.gfx, json.encode(D.gfx))
    SetResourceKvp(KVP.res, json.encode(D.res))
    SetResourceKvp(KVP.lock, json.encode(D.lock))
end

-- Rows of a screen GTA does not show on this PC or greys out, from a read of that screen (every row it lists, not only
-- the ones asked for): { [uid as string] = 'absent' | 'greyed' }, kept for the page (PM.Driver.Locked).
local function recordLocks(screen, rows)
    for _, uid in ipairs(D.ROWS[screen] or {}) do
        if type(uid) == 'table' then uid = uid[1] end
        if type(uid) == 'number' then D.lock[tostring(uid)] = D.lockOf(rows, uid) end
    end
end

-- Overlay snapshot for the page (pm:driver:state). item false clears the row label, nil keeps it.
function D.state(phase, item)
    local s = D.S
    if not s then return end
    if phase then s.phase = phase end
    if item ~= nil then s.id, s.label = item and item.id or nil, item and item.label or nil end
    PM.Send('pm:driver:state', {
        running = true, kind = s.kind, step = s.step, total = s.total, phase = s.phase, id = s.id, label = s.label,
        prompt = s.prompt, ms = s.promptMs, cancelling = s.cancel or nil,
    })
end

-- Progress counts a row once, when it was set (graphics rows settle only after Apply) or settled.
local function count(s, id)
    if s.counted[id] then return end
    s.counted[id] = true
    s.step = s.step + 1
    D.state()
end

-- Settles one row once: ok, or failed with a code (driver.errors.<code> on the page).
local function mark(s, id, code)
    if s.marked[id] then return end
    s.marked[id] = true
    if code then
        s.failed[#s.failed + 1] = id
        s.errors[id] = code
    else
        s.done[#s.done + 1] = id
    end
    count(s, id)
end

local function hider(s)
    while s.alive do
        if s.opened then
            AllowPauseMenuWhenDeadThisFrame()
            if D.cfg('SuppressRender') then SuppressFrontendRenderingThisFrame() end
        end
        if s.mode == 'nofocus' then
            for i = 1, #GAMEPLAY do DisableControlAction(0, GAMEPLAY[i], true) end
        end
        Wait(0)
    end
end

-- Config.Settings.DriverFocusMode, or for 'auto' the variant that worked last first, then the others in order.
local function modes()
    local want = Config.Settings and Config.Settings.DriverFocusMode
    if MODES[want] then return { want } end
    local first = MODES[D.learn.focus] and D.learn.focus or nil
    local out = { first }
    for _, mode in ipairs({ 'focus', 'nofocus', 'scaleform' }) do
        if mode ~= first then out[#out + 1] = mode end
    end
    return out
end

-- One direct-landing variant per run until one is proven (T7); then it is used every time.
local function landingVariant()
    local learn = D.learn
    if not D.cfg('DirectLanding') or learn.landing == 'none' then return nil end
    if learn.landing then return learn.landing end
    learn.tried = learn.tried or {}
    for _, variant in ipairs(VARIANTS) do
        if not learn.tried[variant] then return variant end
    end
    learn.landing = 'none'
end

local function landingResult(variant, ok)
    local learn = D.learn
    learn.tried = learn.tried or {}
    learn.tried[variant] = true
    if ok then learn.landing = variant elseif learn.landing == variant then learn.landing = nil end
end

-- The first move toward the target category: GTA's menu opens on the same category every time (24, learned).
local function firstMove(target)
    local dir, n = D.path(D.categories(D.learn.replay), D.learn.startCat or 24, target)
    if dir and n > 0 then return dir end
    return 'DOWN'
end

-- Opens GTA's settings aimed at the first screen of the plan, finds an input variant that works and where we are.
local function start(target)
    local s = D.S
    PM.SetBypass(true, 'driver')
    D.state('open', false)
    local variant = landingVariant()
    local dir = firstMove(target)
    if not D.open(target, variant) then
        D.check()
        if not variant then D.fail('open_failed') end
        landingResult(variant, false)
        D.close()
        variant = nil
        if not D.open(target) then D.fail('open_failed') end
    end
    -- With the input variant learned on this build the first contact is a jump to the target category, no probe press:
    -- its event tells where the highlight is. The probe stays the fallback.
    local ok, mode, ev = false, nil, nil
    local index = D.indexOf(D.CATEGORIES, target)
    if not variant and MODES[D.learn.focus] and D.canJump() and index then
        D.setMode(D.learn.focus)
        local jumped = D.jump(index - 1)
        if jumped and D.isCategory(jumped.menuId) then
            ok, mode, ev = true, D.learn.focus, jumped
        else
            D.dbg('first contact: the jump gave', jumped and jumped.menuId, '- probing')
        end
    end
    if not ok then ok, mode, ev = pcall(D.probe, modes(), dir) end
    -- A direct landing that left the highlight on the header answers no press: that variant failed, plain LANDING next.
    if not ok then
        if not variant or type(mode) ~= 'table' or mode.driver ~= 'no_feedback' then error(mode, 0) end
        landingResult(variant, false)
        D.close()
        variant = nil
        if not D.open(target) then D.fail('open_failed') end
        mode, ev = D.probe(modes(), dir)
    end
    D.learn.focus = mode
    s.ev = ev
    -- Where the plain menu opened: the category the first move left.
    if not variant and D.isCategory(ev.last) and D.isCategory(ev.menuId) then D.learn.startCat = ev.last end
    if not D.isCategory(ev.menuId) then
        local where = D.listOf(ev.uid)
        -- Not a category and not a settings row: a CANCEL here could close GTA's menu, so stop instead.
        if ev.menuId ~= D.LIST and not where then D.fail('lost') end
        s.inList = where or -1
        if where == target then s.rows = D.visible(target, D.ctx) else D.leave() end
    end
    if variant then landingResult(variant, s.inList == target) end
    D.saveLearn()
end

-- Enters a screen's list and loads its row order: from a read (s.order set before), else walked once per build (or
-- again when fresh). first: the uid wanted first, so the move that enters is already a step toward it.
local function enterScreen(screen, fresh, first)
    local s = D.S
    if s.inList ~= screen then
        D.state('nav', false)
        D.gotoCategory(screen)
        local dir, n = D.path(s.order, s.order and s.order[1], first)
        D.enter(screen, (dir and n > 0) and dir or nil, s.slots and s.slots[first])
    end
    s.rows = s.rows or D.visible(screen, D.ctx)
    s.rewalked = false
    if s.order and not fresh then return end
    local cached = not fresh and D.cal.screens[tostring(screen)]
    if s.listIndex then
        s.order = D.selectable(s.rows)
    elseif cached then
        s.order = cached
    else
        D.state('learn', false)
        s.order = D.walk(screen)
    end
end

-- Puts the highlight on a batch row (catalog uid mapped through the calibration).
local function locate(s, item)
    local uid = D.resolve(s.order, D.selectable(s.rows), item.uid)
    if not uid or not D.findRow(uid) then D.fail('not_found') end
    return uid
end

-- A row error fails that row; anything else is thrown on and stops the session.
local function rowError(s, id, err)
    if type(err) == 'table' and ROW_ERRORS[err.driver] then return mark(s, id, err.driver) end
    error(err, 0)
end

-- Enters a screen's list without learning its row order (a scaleform read needs no walk).
local function enterList(screen)
    local s = D.S
    if s.inList ~= screen then
        D.state('nav', false)
        D.gotoCategory(screen)
        D.enter(screen)
    end
    s.rows = s.rows or D.visible(screen, D.ctx)
end

-- The rows GTA wrote into its menu movie for a screen ({ [uid] = row }, read.lua), nothing seeded yet, and whether
-- every row answered; nil and why ('noreader', 'mismatch' or 'error'). A reader that breaks gives nothing; the
-- driver's own stop codes go on. Only a complete read says which rows GTA does not show.
local function readRows(screen)
    D.state('read', false)
    local ok, rows, why, _, complete = pcall(D.readScaleform, screen)
    if not ok then
        if type(rows) == 'table' and rows.driver then error(rows, 0) end
        D.dbg('scaleform read failed:', rows)
        return nil, 'error'
    end
    D.dbg('scaleform read', screen, rows and (complete and 'ok' or 'incomplete') or why)
    if not rows then return nil, why end
    if complete then
        recordLocks(screen, rows)
        D.S.read[screen] = true
    end
    return rows, nil, complete
end

-- A screen's rows, read with the highlight on its category: GTA builds the list there before it is entered (the same
-- read in game), so a run that only reads never presses ACCEPT. A read of the category passed on the way is tried
-- again a few frames later, then inside the list. nil when no reader works.
local function readScreen(s, screen)
    if s.inList ~= screen then
        D.state('nav', false)
        D.gotoCategory(screen)
    end
    local rows, why, complete = readRows(screen)
    if rows or why == 'noreader' or s.inList == screen then return rows, complete end
    D.sleep(100)
    rows, why, complete = readRows(screen)
    if rows or why == 'noreader' then return rows, complete end
    enterList(screen)
    rows, why, complete = readRows(screen)
    return rows, complete
end

-- Locks of the graphics screens this session did not read, when some are recorded: a greyed row there may have come
-- free (its condition can sit on another screen), and the page refuses edits on locked rows. Only the category is
-- highlighted, nothing is entered; a failure here changes nothing the session did.
local function refreshLocks(s)
    for screen in pairs(D.GFX) do
        local any = false
        for _, uid in ipairs(D.ROWS[screen] or {}) do
            if type(uid) == 'table' then uid = uid[1] end
            if type(uid) == 'number' and D.lock[tostring(uid)] then any = true end
        end
        if any and not s.read[screen] then
            local ok, err = pcall(function()
                D.state('read', false)
                D.gotoCategory(screen)
                if not readRows(screen) then
                    D.sleep(100)
                    readRows(screen)
                end
            end)
            if not ok then D.dbg('lock refresh on', screen, 'stopped:', type(err) == 'table' and err.driver or err) end
        end
    end
end

-- A row's current value from a read; a row with a convar takes the convar (GTA fills display rows such as screen
-- type with their text only).
local function readValue(rows, item)
    if item.convar then
        local v = GetConvarInt(item.convar, -999)
        if v ~= -999 then return v end
    end
    return D.rowValue(rows, item.uid, item.kind, item.count)
end

-- What a read says about a batch's rows: a row GTA does not show (complete reads only) or greys out fails at once, a
-- row already on its target is done without a press, the rest get their exact current value (item.from, nil when
-- unknown). Returns the rows left to set.
local function fromRead(s, group, rows, complete)
    local todo = {}
    for _, item in ipairs(group.items) do
        local lock, value = D.lockOf(rows, item.uid), readValue(rows, item)
        if lock == 'absent' and not complete then lock = nil end
        if lock == 'absent' then mark(s, item.id, 'not_found')
        elseif lock == 'greyed' then mark(s, item.id, 'locked')
        elseif value ~= nil and value == item.target then
            if not item.convar then D.gfx[item.id] = value end
            mark(s, item.id)
        else
            item.from = value
            todo[#todo + 1] = item
        end
    end
    return todo
end

-- One session in its own thread. done(result) runs exactly once:
-- { done = ids, failed = ids, errors = { [id] = code }, values = { [id] = value }, error = code|nil }.
local function session(kind, items, total, body, done)
    local s = {
        kind = kind, total = total, step = 0, phase = 'open', alive = true, marked = {}, counted = {}, done = {}, failed = {},
        errors = {}, values = {}, changed = {}, read = {}, deadline = now() + D.cfg('RunTimeoutMs'), expect = 0, lastAt = 0,
    }
    D.S, busy = s, true
    D.readReset()
    D.state('open', false)
    CreateThread(function() hider(s) end)
    CreateThread(function()
        s.thread = coroutine.running() -- read.lua raises this session's stops in this thread only
        local ok, err = pcall(body, s)
        local code
        if not ok then
            code = type(err) == 'table' and err.driver or 'generic'
            if type(err) ~= 'table' then print(('^1[%s] driver: %s^7'):format(RESOURCE, err)) end
            D.dbg('session stopped:', code)
        end
        s.cleaning, s.deadline = true, now() + 10000
        D.state('close', false)
        -- Any frontend up now is ours (none was when the session started), even one that never got ready.
        if s.opened or IsPauseMenuActive() then
            -- Unapplied graphics changes are stepped back first; with our menu gone the player would watch, so not then.
            if s.opened and PM.IsOpen() and s.inList and D.GFX[s.inList] then pcall(D.clean) end
            pcall(D.close)
        end
        PM.SetBypass(false, 'driver')
        s.alive = false
        if PM.IsOpen() then
            PM.SetInput('ui')
            if PM.Screen() ~= 'settings' then PM.Show('settings') end
        end
        for _, item in ipairs(items) do mark(s, item.id, code or 'generic') end
        saveValues()
        D.saveLearn()
        D.S, busy = nil, false
        PM.Send('pm:driver:state', { running = false, kind = kind, step = s.step, total = s.total })
        call(done, { done = s.done, failed = s.failed, errors = s.errors, values = s.values, error = code })
    end)
end

-- Answers at once without a session: every row fails with code (or with its own code from the batch check).
local function refuse(list, code, done)
    local failed, errors = {}, {}
    for _, raw in ipairs(type(list) == 'table' and list or {}) do
        if type(raw) == 'table' and type(raw.id) == 'string' and not errors[raw.id] then
            failed[#failed + 1] = raw.id
            errors[raw.id] = raw.code or code
        end
    end
    call(done, { done = {}, failed = failed, errors = errors, values = {}, error = code })
    return false
end

-- Why a session cannot start now (nil when it can). dev: an F8 experiment, allowed with the driver flag off.
local function blocked(dev)
    if not dev and not (Config.Settings and Config.Settings.FrontendDriver) then return 'disabled' end
    if busy then return 'busy' end
    if not PM.IsOpen() then return 'closed' end
    if IsPauseMenuActive() then return 'busy_frontend' end
    if IsPlayerSwitchInProgress() or IsScreenFadedOut() or IsCutsceneActive() then return 'unavailable' end
end

-- Without a reader, the graphics rows GTA does not report are read through the Dirty oracle, while nothing is pending
-- (it tells one row only): every row then has a known value to set from and, on cancel, to step back to. Returns the
-- rows that failed there.
local function readOracle(s, items)
    local skip = {}
    for _, item in ipairs(items) do
        if not item.convar and not D.dirty() then
            D.state('read', item)
            local ok, err = pcall(function() item.from = D.readRow(item, locate(s, item)) end)
            if not ok then
                skip[item] = true
                rowError(s, item.id, err)
            end
        end
    end
    return skip
end

-- Rows outside the graphics screens apply the moment their pref changes (b3258 SetValueBasedOnPreference): they are
-- written straight through the reader movie (DXR_P, live in game, no console rights needed) and checked on their
-- profile_ convar, which FiveM mirrors from the pref every frame. Graphics prefs never go this way: written from outside
-- their list they left GTA's menu where the next ENTER applied other values (seen in game). Returns the rows left for
-- the menu path.
local function writeDirect(s, items)
    if not D.cfg('DirectWrite') or not D.inject() or not D.canWrite() then return items end
    local writes, byUid, rest = {}, {}, {}
    for _, item in ipairs(items) do
        if item.convar and not D.NO_DIRECT[item.uid] and not D.BLOCKED[item.uid] and GetConvarInt(item.convar, -999) ~= -999 then
            writes[#writes + 1] = { item.uid, item.target }
            byUid[item.uid] = item
        else
            rest[#rest + 1] = item
        end
    end
    if #writes == 0 then return items end
    D.state('set', false)
    local left = {}
    for _, uid in ipairs(D.writePrefs(writes)) do left[uid] = byUid[uid] end
    local stop = now() + 600
    while next(left) and now() <= stop do
        for uid, item in pairs(left) do
            if GetConvarInt(item.convar, -999) == item.target then
                mark(s, item.id)
                left[uid] = nil
            end
        end
        if next(left) then
            Wait(0)
            D.check()
        end
    end
    for _, w in ipairs(writes) do
        local item = byUid[w[1]]
        if not s.marked[item.id] then
            D.dbg('direct write', item.id, 'not confirmed - through the menu')
            rest[#rest + 1] = item
        end
    end
    return rest
end

-- One screen of a run. Graphics: read first (exact values, also for the rows GTA steps itself; rows already on their
-- target are done without entering), set, Apply, then read again: what GTA shows after Apply is what it applied.
local function runGroup(s, group)
    local gfx, items, rows, complete, skip = D.GFX[group.screen], group.items, nil, false, {}
    if gfx then
        s.gfxTouched = true
        rows, complete = readScreen(s, group.screen)
        if rows then
            items = fromRead(s, group, rows, complete)
            if #items == 0 then return D.dbg('run: every row already holds its value on', group.screen) end
            if complete then
                s.order = D.readOrder(rows) -- the walk the highlight takes, without a calibration walk
                D.saveOrder(group.screen, s.order)
            end
            s.slots = D.readSlots(rows) -- where each row is, for jumps
        end
    else
        items = writeDirect(s, items)
        if #items == 0 then return end
    end
    enterScreen(group.screen, false, items[1].uid)
    if gfx then
        if D.dirty() then D.fail('dirty') end
        if not rows then skip = readOracle(s, items) end
    end
    local pending, warns = {}, false
    for _, item in ipairs(items) do
        if not skip[item] then
            D.state('set', item)
            local ok, err = pcall(function() D.setItem(item, locate(s, item)) end)
            if not ok then
                rowError(s, item.id, err)
            elseif gfx then
                pending[#pending + 1] = item
                count(s, item.id)
                warns = warns or D.WARNS[item.uid] == true
            else
                mark(s, item.id)
            end
        end
    end
    if #pending == 0 then return end
    -- A display mode row moved but failed its check still goes through this Apply: GTA's "keep?" goes to the player.
    for uid, ch in pairs(s.changed) do
        if ch.screen == group.screen and D.WARNS[uid] then warns = true end
    end
    D.state('apply', false)
    -- Saved before Apply: GTA may restart the game on its prompt and nothing after it would run.
    local before = {}
    for _, item in ipairs(pending) do before[item.id], D.gfx[item.id] = D.gfx[item.id], item.target end
    saveValues()
    local result = D.apply(warns)
    -- What GTA shows after Apply. Rows with a convar were checked against it while set; on a declined Apply the
    -- menu still shows the pending value, so the value from before stays.
    local after = rows and result ~= 'reverted' and readRows(group.screen)
    for _, item in ipairs(pending) do
        local shown = after and not item.convar and D.rowValue(after, item.uid, item.kind, item.count) or nil
        -- An ordinary row showing exactly its old value may be a list GTA does not redraw: not a proof either way.
        if shown ~= nil and shown == item.from and not D.STEP[item.uid] then
            D.dbg('run:', item.id, 'still shows', shown, 'after Apply (inconclusive)')
            shown = nil
        end
        if result == 'reverted' then
            D.gfx[item.id] = before[item.id]
            mark(s, item.id, 'declined')
        elseif shown ~= nil and shown ~= item.target then
            D.dbg('run:', item.id, 'shows', shown, 'after Apply, not', item.target)
            D.gfx[item.id], s.values[item.id] = shown, shown
            mark(s, item.id, 'verify_failed')
        else
            D.gfx[item.id] = item.target
            if item.uid == 57 and result == 'applied' then
                local w, h = GetActualScreenResolution()
                D.res[tostring(item.target)] = ('%dx%d'):format(w, h)
            end
            mark(s, item.id)
        end
    end
    saveValues()
end

-- Changes rows in GTA's own settings screens. batch = { { id, screen, uid, target, kind?, count?, convar?, current?,
-- label? } }; video rows ask the player first. Returns false (done already called) when it cannot start.
function PM.Driver.Run(batch, done)
    ensureLoaded()
    local why = blocked()
    if why then return refuse(batch, why, done) end
    local items, refused = D.sanitize(batch, true)
    if #items == 0 then
        if #refused > 0 then return refuse(refused, nil, done) end
        return refuse(batch, 'validation', done)
    end
    session('apply', items, #items + #refused, function(s)
        for _, r in ipairs(refused) do mark(s, r.id, r.code) end
        local rest, video = {}, {}
        for _, item in ipairs(items) do
            local list = item.video and video or rest
            list[#list + 1] = item
        end
        if #video > 0 then
            D.state('confirm', false)
            local yes = D.ask('video', D.cfg('ConfirmMs'))
            for _, item in ipairs(video) do
                if yes then rest[#rest + 1] = item else mark(s, item.id, 'declined') end
            end
        end
        if #rest == 0 then return end
        local plan = D.plan(rest)
        start(plan[1].screen)
        for _, group in ipairs(plan) do runGroup(s, group) end
        -- What GTA greys out changes only with graphics values: a run without any needs no other screen read.
        if s.gfxTouched then refreshLocks(s) end
        saveValues()
    end, done)
    return true
end

-- "Sync": reads graphics rows GTA does not expose through the Dirty oracle (research B 7.3).
-- rows = { { id, screen = 137|138, uid, kind, count? } } without a convar; result.values = { [id] = value }.
-- Sync with a readable GFX_Dirty (research B 7.3): each row is read on the spot.
local function syncDirty(s, group)
    enterScreen(group.screen)
    if D.dirty() then D.fail('dirty') end
    for _, item in ipairs(group.items) do
        D.state('read', item)
        local ok, value = pcall(function()
            local uid = locate(s, item)
            s.changed[uid] = { item = item, screen = group.screen } -- a row left mid-read is cleaned like an unknown one
            return D.readRow(item, uid)
        end)
        if not ok then rowError(s, item.id, value)
        elseif value then s.values[item.id], D.gfx[item.id] = value, value; mark(s, item.id)
        else mark(s, item.id, 'unreadable') end
    end
end

-- Puts candidate values on rows (absolute seeded sets), then leaves the list: no "apply?" question means all matched.
local function tryValues(s, screen, pairs_)
    enterScreen(screen)
    for _, p in ipairs(pairs_) do
        D.state('read', p.item)
        D.seedSet(p.item, locate(s, p.item), p.value)
    end
    local same = D.leaveProbe()
    if s.reopen then
        -- A change may still be pending inside GTA's menu: closing it drops the change, then a fresh menu.
        s.reopen = nil
        D.close()
        s.inList, s.ev = nil, nil
        start(screen)
    end
    return same -- true same, false differs, nil could not tell
end

-- One candidate, asked again once when the first leave could not tell.
local function tryValue(s, screen, item, value)
    for _ = 1, 2 do
        local same = tryValues(s, screen, { { item = item, value = value } })
        if same ~= nil then return same end
    end
    return false
end

-- Sync through the leave question (b3258): rows GTA steps itself (MSAA, Post FX, grass) and sliders cannot be told
-- apart this way and keep their tracked value. First every cached value at once (the usual case: one leave),
-- then row by row, cached value first, until the question stays away.
local function syncProbe(s, group)
    local lists = {}
    for _, item in ipairs(group.items) do
        if D.STEP[item.uid] or item.kind == 'slider' then
            -- Kept as tracked: the value our last Apply left (GTA reports none).
            local c = D.cached(item.id)
            if c ~= nil then s.values[item.id] = c; mark(s, item.id) else mark(s, item.id, 'unreadable') end
        else lists[#lists + 1] = item end
    end
    if #lists == 0 then return end
    enterScreen(group.screen)
    if not D.seedReady(group.screen) then
        for _, item in ipairs(lists) do mark(s, item.id, 'seed_failed') end
        return
    end
    local all, every = {}, true
    for _, item in ipairs(lists) do
        local c = D.cached(item.id)
        if c == nil then every = false break end
        all[#all + 1] = { item = item, value = c }
    end
    if every and tryValues(s, group.screen, all) == true then
        D.dbg('sync: every cached value confirmed')
        for _, p in ipairs(all) do s.values[p.item.id] = p.value; mark(s, p.item.id) end
        return
    end
    for _, item in ipairs(lists) do
        local n, first, found = item.count or 2, D.cached(item.id), nil
        local tries = (first and first < n) and { first } or {}
        for v = 0, n - 1 do if v ~= first then tries[#tries + 1] = v end end
        local ok, err = pcall(function()
            for _, v in ipairs(tries) do
                if tryValue(s, group.screen, item, v) then found = v break end
            end
        end)
        if not ok then rowError(s, item.id, err)
        elseif found then
            D.dbg('sync:', item.id, '=', found)
            s.values[item.id], D.gfx[item.id] = found, found
            mark(s, item.id)
        else mark(s, item.id, 'unreadable') end
        saveValues()
    end
end

-- First strategy: the values GTA wrote into its menu movie (every row, the step rows and sliders too). A row GTA does
-- not show here fails at once (TXAA without support); a greyed out one still has its value.
local function syncFrom(s, group, rows, complete)
    local n = 0
    for _, item in ipairs(group.items) do
        local value = D.rowValue(rows, item.uid, item.kind, item.count)
        if complete and D.lockOf(rows, item.uid) == 'absent' then
            mark(s, item.id, 'not_found')
        elseif value ~= nil then
            s.values[item.id], D.gfx[item.id] = value, value
            mark(s, item.id)
            n = n + 1
        else
            mark(s, item.id, 'unreadable')
        end
    end
    D.dbg('sync: scaleform read', n, 'of', #group.items, 'rows on', group.screen)
end

function PM.Driver.Sync(rows, done)
    ensureLoaded()
    local why = blocked()
    if why then return refuse(rows, why, done) end
    local items, refused = D.sanitize(rows, false)
    local list = {}
    for _, item in ipairs(items) do
        if D.GFX[item.screen] and not item.convar then list[#list + 1] = item
        else refused[#refused + 1] = { id = item.id, code = 'unsupported' } end
    end
    if #list == 0 then
        if #refused > 0 then return refuse(refused, nil, done) end
        return refuse(rows, 'validation', done)
    end
    session('sync', list, #list + #refused, function(s)
        s.deadline = now() + D.cfg('SyncTimeoutMs')
        for _, r in ipairs(refused) do mark(s, r.id, r.code) end
        local plan = D.plan(list)
        start(plan[1].screen)
        for _, group in ipairs(plan) do
            local rows, complete = readScreen(s, group.screen)
            if rows then
                syncFrom(s, group, rows, complete)
            elseif D.dirtyKnown() then
                syncDirty(s, group)
            else
                syncProbe(s, group)
            end
            saveValues()
        end
        refreshLocks(s)
        saveValues()
    end, done)
    return true
end

function PM.Driver.Calibrate(screens, done)
    ensureLoaded()
    local why = blocked()
    if why then return refuse({}, why, done) end
    local list = {}
    for _, screen in ipairs(type(screens) == 'table' and screens or { 137, 138 }) do
        screen = math.tointeger(tonumber(screen) or 0)
        if screen and D.TARGETS[screen] then list[#list + 1] = { id = tostring(screen), screen = screen, uid = 0 } end
    end
    if #list == 0 then return refuse({}, 'validation', done) end
    session('calibrate', list, #list, function(s)
        local plan = D.plan(list)
        start(plan[1].screen)
        for _, group in ipairs(plan) do
            D.state('learn', group.items[1])
            enterScreen(group.screen, true)
            s.values[tostring(group.screen)] = s.order
            mark(s, tostring(group.screen))
        end
    end, done)
    return true
end

-- Developer commands, only with Config.Debug or the client convar daddy_pausemenu_dev 1 (never on a live server).
local DEV = Config.Debug == true or GetConvarInt('daddy_pausemenu_dev', 0) == 1

-- F8 'pausemenu_gfxset <row id> <value>': corrects the tracked value of a graphics row (after a change made in GTA's
-- own menu with no reader, the step rows MSAA, Post FX and grass otherwise land off by that difference).
if DEV then RegisterCommand('pausemenu_gfxset', function(_, args)
    local id, value = args[1], math.tointeger(tonumber(args[2] or ''))
    if not id or not value or not PMSettings.row(id) then return print('usage: pausemenu_gfxset gfx_grass_quality 2') end
    ensureLoaded()
    D.gfx[id] = value
    saveValues()
    print(('[%s] %s tracked as %d'):format(RESOURCE, id, value))
end, false) end

-- F8 'pausemenu_gfxread': the scaleform read experiment (research gfxread/4-build.md). Opens GTA's settings hidden
-- behind our menu, runs every read variant on the Graphics category, its list and the Advanced Graphics list and
-- prints one '[pmread]' line each, then a summary and the reader Sync will use. Only the highlight moves: no value
-- changes, no ACCEPT on a row, no X.
if DEV then RegisterCommand('pausemenu_gfxread', function()
    ensureLoaded()
    if busy then return print('[pmread] busy: another driver session is running') end
    CreateThread(function()
        if not PM.IsOpen() then
            PM.Open('settings', true)
            local stop = now() + 3000
            while not PM.IsOpen() and now() < stop do Wait(50) end
            Wait(800)
        end
        local why = blocked(true)
        if why then return print('[pmread] cannot start: ' .. why) end
        print(('[pmread] start build=%d learned=%s reader_movie=%s'):format(GetGameBuildNumber(), tostring(D.learn.sfread),
            (D.readerState())))
        local phases, summed = {}, false
        local steps = { { id = 'cat137' }, { id = 'list137' }, { id = 'list138' } }
        session('calibrate', steps, #steps, function(s)
            s.deadline = now() + 120000
            D.readReset()
            start(137)
            if s.inList ~= 137 then
                D.gotoCategory(137)
                phases.cat137 = D.readPhase('cat137', 137, true)
                D.enter(137)
            end
            mark(s, 'cat137')
            -- The highlight leaves the first row, so a failure answering 0 never looks like the control's slot
            -- (two rows down: the third would be the output monitor row, never touched).
            for _ = 1, 2 do D.step(D.IN.DOWN) end
            phases.list137 = D.readPhase('list137', 137, false)
            mark(s, 'list137')
            D.gotoCategory(138)
            D.enter(138)
            for _ = 1, 2 do D.step(D.IN.DOWN) end
            phases.list138 = D.readPhase('list138', 138, true)
            mark(s, 'list138')
            summed = true
            D.readSummary(phases)
        end, function(result)
            if not summed and phases.list137 then pcall(D.readSummary, phases) end
            print(('[pmread] end error=%s'):format(tostring(result.error)))
        end)
    end)
end, false) end

-- F8 'pausemenu_jumptest': can the highlight jump straight to a category or a row (D.jump, GTA's mouse path) instead of
-- walking there? Opens GTA's settings hidden behind our menu and prints one '[pmjump]' line per check:
--   cat     a jump to Graphics from the category the first move reached (expect menu 137 uid 6)
--   row     jumps inside the Graphics list to MSAA, Post FX and FXAA by their slot (expect 51/80, 51/86, 51/79)
--   press   one RIGHT then one LEFT on a jumped-to row: the value must move on that row only and come back
--   walk    a DOWN after a jump must continue from the jumped-to row (MSAA -> VSync)
-- Every value it moves is moved back; it never presses X (Apply), and closing GTA's menu drops anything left pending.
if DEV then RegisterCommand('pausemenu_jumptest', function()
    ensureLoaded()
    if busy then return print('[pmjump] busy: another driver session is running') end
    CreateThread(function()
        if not PM.IsOpen() then
            PM.Open('settings', true)
            local stop = now() + 3000
            while not PM.IsOpen() and now() < stop do Wait(50) end
            Wait(800)
        end
        local why = blocked(true)
        if why then return print('[pmjump] cannot start: ' .. why) end
        local result, steps, s0 = {}, { { id = 'cat' }, { id = 'row' }, { id = 'press' }, { id = 'walk' } }, nil
        local function line(text, ...) print(('[pmjump] ' .. text):format(...)) end
        local function evText(ev) return ev and ('%s/%s'):format(tostring(ev.menuId), tostring(ev.uid)) or 'none' end
        -- One row of the open list as GTA holds it now: its value (with the option text of a self-stepped row) and its
        -- state (2 once changed).
        local function rowNow(rows, uid)
            local slot = rows[uid] and rows[uid].slot
            local c = slot and D.feCall('DXR_V', { slot }, 300, 'str')
            local now_ = c and c.ready == true and type(c.str) == 'string' and D.parseRows(c.str .. '|')
            local r = now_ and now_[uid]
            if not r then return 'unread', '?' end
            return ('%d%s'):format(r.value, r.opts and #r.opts == 1 and (':' .. r.opts[1]) or ''), tostring(r.state)
        end
        local function jumpTo(label, index, want)
            if s0 and s0.ev and s0.ev.menuId == want[1] and s0.ev.uid == want[2] then
                line('%s index=%d already there', label, index)
                return true
            end
            local t0 = now()
            local ev = D.jump(index)
            local ms = now() - t0
            local sel0, sel1 = D.feInt('GET_COLUMN_SELECTION', 0), D.feInt('GET_COLUMN_SELECTION', 1)
            local ok = ev ~= nil and ev.menuId == want[1] and ev.uid == want[2]
            line('%s index=%d event=%s want=%d/%d ok=%s ms=%d sel0=%s sel1=%s', label, index, evText(ev), want[1], want[2],
                tostring(ok), ms, tostring(sel0), tostring(sel1))
            return ok
        end
        session('calibrate', steps, #steps, function(s)
            s0 = s
            s.deadline = now() + 90000
            start(137)
            line('start at %s (first move %s)', evText(s.ev), firstMove(137))
            -- cat: from wherever the first move left the highlight; the DPADDOWN form if the DPADUP one says nothing.
            result.cat = tostring(jumpTo('cat', 6, { 137, 6 }))
            if result.cat == 'false' and s.ev and s.ev.menuId ~= 137 then
                D.jump(6, 9)
                line('cat dpaddown event=%s', evText(s.ev))
            end
            mark(s, 'cat')
            if not (s.ev and s.ev.menuId == 137) then D.gotoCategory(137) end
            local rows = readRows(137)
            if not rows then
                line('no read of 137: row checks skipped')
                return
            end
            D.enter(137)
            line('in list at %s', evText(s.ev))
            local okRows = true
            for _, uid in ipairs({ 80, 86, 79, 85 }) do
                okRows = jumpTo('row', rows[uid].slot, { 51, uid }) and okRows
            end
            result.row = tostring(okRows)
            mark(s, 'row')
            -- press: a normal row (FXAA) and a row GTA steps itself (MSAA); the other one must not move.
            local okPress = true
            for _, pair in ipairs({ { 79, 80 }, { 80, 79 } }) do
                local uid, other = pair[1], pair[2]
                if jumpTo('press-jump', rows[uid].slot, { 51, uid }) then
                    local before, stateBefore = rowNow(rows, uid)
                    local otherBefore = rowNow(rows, other)
                    D.press(D.IN.RIGHT)
                    D.sleep(150)
                    local moved, stateMoved = rowNow(rows, uid)
                    local otherMoved = rowNow(rows, other)
                    D.press(D.IN.LEFT)
                    D.sleep(150)
                    local back, stateBack = rowNow(rows, uid)
                    local ok = moved ~= before and otherMoved == otherBefore and back == before
                    okPress = okPress and ok
                    line('press uid=%d before=%s(%s) right=%s(%s) left=%s(%s) other=%d %s->%s ok=%s', uid, before, stateBefore,
                        moved, stateMoved, back, stateBack, other, otherBefore, otherMoved, tostring(ok))
                else
                    okPress = false
                end
            end
            result.press = tostring(okPress)
            mark(s, 'press')
            -- walk: keyboard steps go on from the jumped-to row.
            if jumpTo('walk-jump', rows[80].slot, { 51, 80 }) then
                local ev = D.step(D.IN.DOWN)
                result.walk = tostring(ev ~= nil and ev.uid == 62)
                line('walk down event=%s want=51/62 ok=%s', evText(ev), result.walk)
            else
                result.walk = 'false'
            end
            mark(s, 'walk')
        end, function(res)
            print(('[pmjump] summary cat=%s row=%s press=%s walk=%s error=%s'):format(tostring(result.cat), tostring(result.row),
                tostring(result.press), tostring(result.walk), tostring(res.error)))
        end)
    end)
end, false) end

-- F8 'pausemenu_prefwrite': can a pref outside the graphics screens be written without its row (DXR_P from the reader
-- movie, research next/2-direct-write.md)? Writes the measurement system to the other unit and back, and prints whether
-- FiveM mirrored it into profile_measurementSystem (live). Graphics prefs are never written this way (writeDirect).
if DEV then RegisterCommand('pausemenu_prefwrite', function()
    ensureLoaded()
    if busy then return print('[pmwrite] busy: another driver session is running') end
    CreateThread(function()
        if not PM.IsOpen() then
            PM.Open('settings', true)
            local stop = now() + 3000
            while not PM.IsOpen() and now() < stop do Wait(50) end
            Wait(800)
        end
        local why = blocked(true)
        if why then return print('[pmwrite] cannot start: ' .. why) end
        local R = {}
        session('calibrate', { { id = 'prefwrite' } }, 1, function(s)
            s.deadline = now() + 30000
            start(137)
            if not D.inject() then return print('[pmwrite] reader movie did not load') end
            R.writers = D.canWrite()
            if not R.writers then return end
            local m0 = GetConvarInt('profile_measurementSystem', -1)
            if m0 ~= 0 and m0 ~= 1 then return print('[pmwrite] measurement system unreadable') end
            local ran = D.writePrefs({ { 174, 1 - m0 } })
            D.quiet(5)
            local m1 = GetConvarInt('profile_measurementSystem', -1)
            D.writePrefs({ { 174, m0 } })
            D.quiet(5)
            R.live = m1 == 1 - m0
            print(('[pmwrite] pref174 ran=%s before=%d after=%d back=%d'):format(tostring(#ran == 1), m0, m1,
                GetConvarInt('profile_measurementSystem', -1)))
        end, function(result)
            print(('[pmwrite] summary writers=%s live=%s error=%s'):format(tostring(R.writers), tostring(R.live), tostring(result.error)))
        end)
    end)
end, false) end

function PM.Driver.Busy() return busy end

-- Stops after the current press: unapplied graphics changes are stepped back, GTA's menu closes.
function PM.Driver.Cancel()
    local s = D.S
    if not s or s.cleaning then return end
    s.cancel, s.answer = true, false
    D.state()
end

-- Graphics values our runs set or read, by row id (GTA cannot report them; they may be stale).
function PM.Driver.Cached()
    ensureLoaded()
    local out = {}
    for id, v in pairs(D.gfx) do out[id] = v end
    return out
end

-- Rows GTA does not show on this PC ('absent') or greys out ('greyed'), by row id, as the last read of their screen
-- found them (PMSettings rows with that pref uid).
function PM.Driver.Locked()
    ensureLoaded()
    local out = {}
    for _, row in ipairs(PMSettings and PMSettings.ROWS or {}) do
        local lock = row.uid and D.lock[tostring(row.uid)]
        if lock and (row.cls == 'G' or row.cls == 'V' or row.convar) then out[row.id] = lock end
    end
    for _, row in ipairs(PMSettings and PMSettings.EXTRA or {}) do
        local lock = row.uid and D.lock[tostring(row.uid)]
        if lock then out[row.id] = lock end
    end
    return out
end

-- GTA's own settings screen may change what is greyed out: the locks wait for the next read of their screen.
function PM.Driver.ForgetLocks()
    ensureLoaded()
    D.lock = { build = D.lock.build }
    saveValues()
end

-- Resolution list index -> 'WxH' seen after applying it (GTA fills that list in code; labels cannot be read).
function PM.Driver.Resolutions()
    ensureLoaded()
    local out = {}
    for index, size in pairs(D.res) do out[index] = size end
    return out
end

-- What the engine knows on this build (diagnostics for the settings screen or a support ticket).
function PM.Driver.Status()
    ensureLoaded()
    local screens = {}
    for screen in pairs(D.cal.screens) do screens[#screens + 1] = screen end
    return {
        enabled = (Config.Settings and Config.Settings.FrontendDriver) == true, busy = busy, build = D.learn.build,
        focus = D.learn.focus, landing = D.learn.landing, seed = D.learn.seed, calibrated = screens, reader = D.learn.sfread,
        readerMovie = (D.readerState()),
    }
end

PM.Callback('pm:driver:confirm', function(data)
    local s = D.S
    if not s or not s.prompt or type(data.keep) ~= 'boolean' then return { ok = false, error = 'validation' } end
    s.answer = data.keep
    return { ok = true }
end)

PM.Callback('pm:driver:cancel', function()
    PM.Driver.Cancel()
    return { ok = true }
end)

-- Our menu closing (focus revoked, logout) ends a session at once; GTA's menu must not stay up behind nothing.
PM.OnClose(function()
    local s = D.S
    if s then s.abort, s.answer = s.abort or 'closed', false end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE or not D.S then return end
    if D.S.opened or IsPauseMenuActive() then SetFrontendActive(false) end
    PM.SetBypass(false, 'driver')
end)
