-- Settings driver (Engine B), engine: drives GTA's own settings frontend (LANDING menu) behind our opaque overlay
-- with injected frontend controls, its layout-changed events and a few scaleform calls (research B 7/11, Z 3.2.3).
-- Every wait has a deadline; every press goes through press() and its guards. D.S is the running session.
local D = PMDrv
local now = GetGameTimer

local IN = { DOWN = 187, UP = 188, LEFT = 189, RIGHT = 190, ACCEPT = 201, CANCEL = 202, X = 203 }
local DPAD = { [187] = 9, [188] = 8, [189] = 10, [190] = 11 } -- scaleform GamePadConstants
local REFUSED = { [199] = true, [200] = true, [204] = true } -- pause keys, and Y (starts GTA's benchmark)
local DIRS = { UP = IN.UP, DOWN = IN.DOWN, LEFT = IN.LEFT, RIGHT = IN.RIGHT }
local PAD = 2 -- FRONTEND_CONTROL
D.IN = IN

local DEFAULTS = {
    PressGapMs = 100, TurnGapMs = 260, EventTimeoutMs = 450, OpenTimeoutMs = 4000, SettleMs = 150, EnterSettleMs = 150,
    FastTurn = true, VerifySets = true, DirectWrite = true,
    ApplyTimeoutMs = 10000, DirtyWaitMs = 600, WarnWaitMs = 900, WarnSettleMs = 350, SyncTimeoutMs = 360000, KeepPromptMs = 12000, ConfirmMs = 30000, RunTimeoutMs = 150000,
    -- WarnShowMs: how long Apply waits for a question when GTA's Dirty flag is unreadable (in game it shows 30-50 ms after X).
    WarnShowMs = 250, AutoKeep = true, Jump = true,
    DirectLanding = false, SuppressRender = false, UseSeed = true, SeedPress = 'control', Debug = false,
}

-- Config.Settings.Driver.<key>, with the built-in default when the integrator has not merged the section yet.
function D.cfg(key)
    local section = Config.Settings and Config.Settings.Driver
    local value = section and section[key]
    if value == nil then return DEFAULTS[key] end
    return value
end

-- Driver steps print with Config.Settings.Driver.Debug or the menu's debug mode.
function D.dbg(...)
    if D.cfg('Debug') or (PM.IsDebug and PM.IsDebug()) then print('^5[daddy_pausemenu:driver]^7', ...) end
end

function D.fail(code) error({ driver = code }, 0) end
local fail = D.fail

local function u32(v) return (v or 0) & 0xFFFFFFFF end

local landingHash, triggers
local function landing()
    landingHash = landingHash or GetHashKey(D.LANDING)
    return landingHash
end

local function isTrigger(uid)
    if not triggers then
        triggers = {}
        for _, name in ipairs(D.TRIGGERS) do triggers[u32(GetHashKey(name))] = true end
    end
    return uid ~= nil and triggers[u32(uid)] == true
end

function D.ctx(name) return PauseMenuIsContextActive(name) == true end
function D.screenWidth() return (GetActualScreenResolution()) end
-- GFX_Dirty is a code context: on b3258 a script reads it as always off. Once it is ever seen on, it is trusted.
function D.dirty()
    local on = PauseMenuIsContextActive('GFX_Dirty') == true
    if on and D.learn and not D.learn.dirtySeen then D.learn.dirtySeen = true end
    return on
end
function D.dirtyKnown() return D.learn ~= nil and D.learn.dirtySeen == true end
function D.onLanding() return IsPauseMenuActive() and u32(GetCurrentFrontendMenuVersion()) == u32(landing()) end

-- Stops the run on timeout, cancel, our menu closing or anything else taking the frontend over.
function D.check()
    local s = D.S
    if now() > s.deadline then fail('timeout') end
    if s.opened and not D.onLanding() then fail('closed') end
    if s.cleaning then return end
    if s.abort then fail(s.abort) end
    if s.cancel then fail('cancelled') end
end

function D.sleep(ms)
    local stop = now() + ms
    repeat
        Wait(0)
        D.check()
    until now() >= stop
end
local sleep = D.sleep

-- Scaleform call on the frontend content movie (strings go as literal strings).
function D.fe(method, ...)
    if not BeginScaleformMovieMethodOnFrontend(method) then return false end
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        if type(v) == 'boolean' then ScaleformMovieMethodAddParamBool(v)
        elseif type(v) == 'string' then ScaleformMovieMethodAddParamTextureNameString(v)
        elseif math.type(v) == 'float' then ScaleformMovieMethodAddParamFloat(v)
        else ScaleformMovieMethodAddParamInt(v) end
    end
    EndScaleformMovieMethod()
    return true
end

function D.feInt(method, ...)
    if not BeginScaleformMovieMethodOnFrontend(method) then return nil end
    for i = 1, select('#', ...) do ScaleformMovieMethodAddParamInt((select(i, ...))) end
    local handle = EndScaleformMovieMethodReturnValue()
    local stop = now() + 500
    while not IsScaleformMovieMethodReturnValueReady(handle) do
        if now() > stop then return nil end
        Wait(0)
    end
    return GetScaleformMovieMethodReturnValueInt(handle)
end

local function selection(column) return D.feInt('GET_COLUMN_SELECTION', column) end

-- A layout event outside the window our own press opened came from someone else (pad, mouse, keyboard, a script).
local function poll()
    if not HasMenuLayoutChangedEventOccurred() then return nil end
    local last, menuId, uid = GetMenuLayoutChangedEventDetails()
    -- Key Bindings sits in the category column but reports the key map screen (131) with its own id (148).
    if menuId == 131 and uid == 148 then menuId = 148 end
    local s = D.S
    D.dbg('layout event last', last, 'menu', menuId, 'uid', uid)
    if now() > s.expect then
        D.dbg('foreign layout event', menuId, uid)
        s.abort = s.abort or 'foreign'
    end
    s.atTop = false
    return { last = last, menuId = menuId, uid = uid }
end
D.poll = poll

-- keepTop: the events GTA fires as the menu builds; any other one means the highlight left the header.
local function drain(keepTop)
    D.S.expect = now() + 250
    for _ = 1, 4 do
        if HasMenuLayoutChangedEventOccurred() then
            GetMenuLayoutChangedEventDetails()
            if not keepTop then D.S.atTop = false end
        end
        Wait(0)
    end
end

-- The only way input reaches GTA's menu. Never the pause keys or Y; ACCEPT only with a permit from accept().
local function press(ctrl, slow)
    local s = D.S
    local permit = s.permit
    if REFUSED[ctrl] or (ctrl == IN.ACCEPT and not permit) then fail('guard') end
    s.permit = nil
    -- A turn (another control than the last) waits out GTA's input throttle, which drops a different action inside it.
    -- With FastTurn the throttle is cleared instead (restartInteractState, as GTA's own mouse code does), except after
    -- ACCEPT or CANCEL, while the column they opened or closed takes the focus.
    local turn = s.lastCtrl ~= ctrl
    local fast = turn and not slow and D.cfg('FastTurn') and s.lastCtrl ~= IN.ACCEPT and s.lastCtrl ~= IN.CANCEL
    local gap = (slow and D.cfg('TurnGapMs') * 2) or (turn and not fast and D.cfg('TurnGapMs')) or D.cfg('PressGapMs')
    local left = s.lastAt + gap - now()
    if left > 0 then sleep(left) end
    local stop = now() + 3000
    while not IsWarningMessageActive() and (IsPauseMenuRestarting() or not IsFrontendReadyForControl()) do
        if now() > stop then fail('not_ready') end
        Wait(0)
        D.check()
    end
    -- GTA's countdown may have closed the prompt during the gap: that ACCEPT would land on a settings row.
    if permit == 'keep' and not IsWarningMessageActive() then return end
    if fast then D.fe('restartInteractState') end
    if s.mode == 'scaleform' and DPAD[ctrl] then
        D.fe('SET_INPUT_EVENT', DPAD[ctrl])
    else
        SetControlNormal(PAD, ctrl, 1.0) -- SET_CONTROL_VALUE_NEXT_FRAME: latched next frame, released the one after
    end
    s.expect = now() + D.cfg('EventTimeoutMs') * 2 + 250
    Wait(0)
    Wait(0)
    s.lastCtrl, s.lastAt = ctrl, now()
end
D.press = press

-- ACCEPT on a verified category row (never a trigger), once at the top before any list, or on GTA's
-- "keep these settings?" prompt after the player said yes in our overlay.
local function accept(why, screen)
    local s, ev = D.S, D.S.ev
    local ok = (why == 'category' and not s.inList and ev ~= nil and ev.menuId == screen and D.TARGETS[screen] and not isTrigger(ev.uid))
        or (why == 'top' and s.atTop and not s.topUsed and not s.inList)
        or (why == 'keep' and s.keep == true and IsWarningMessageActive())
    if not ok then fail('guard') end
    if why == 'top' then s.topUsed = true end
    s.permit = why
    press(IN.ACCEPT)
end
D.accept = accept

local function waitEvent(ms)
    local stop = now() + (ms or D.cfg('EventTimeoutMs'))
    repeat
        local ev = poll()
        if ev then
            D.check()
            return ev
        end
        Wait(0)
        D.check()
    until now() > stop
end

-- The uid a highlighted slot reports: the row's pref, or for a trigger row (Restore Defaults) its slot, as GTA does.
function D.slotUid(rows, sel)
    local row = rows and rows[sel + 1]
    if type(row) == 'number' then return row end
    if row == 'T' then return sel end
    return -1
end

-- No row events from the list (code-built screens may not report them): the highlighted slot stands in.
local function synth(before)
    local s = D.S
    Wait(0)
    sleep(60)
    local sel = selection(1)
    if not sel or (before and sel == before.sel) then return nil end
    return { menuId = D.LIST, uid = D.slotUid(s.rows, sel), sel = sel }
end

-- One highlight move with feedback; a press the menu dropped (its throttle after a turn) is retried once, slowly.
local function step(ctrl)
    local s = D.S
    local before = s.ev
    local function moved(late)
        if s.listIndex then return synth(before) end
        return waitEvent(late and 250 or nil)
    end
    press(ctrl)
    local ev = moved() or (not s.listIndex and moved(true)) or nil
    if not ev then
        press(ctrl, true)
        ev = moved()
    end
    if ev then s.ev = ev end
    return ev
end
D.step = step

-- Puts the highlight of the focused column on index the way GTA's own mouse click does (PAUSE_MENU_SP_CONTENT
-- FILTER_M_EVENT): restartInteractState clears the menu's input throttle, then MENU_INTERACTION(DPADUP, true, index)
-- calls SET_HIGHLIGHT on the column and reports LAYOUT_CHANGED to the game. Returns the layout event, or nil.
function D.jump(index, input)
    local s = D.S
    s.expect = now() + D.cfg('EventTimeoutMs') * 2 + 250
    D.fe('restartInteractState')
    D.fe('MENU_INTERACTION', input or DPAD[IN.UP], true, index)
    local ev = waitEvent()
    if ev then s.ev = ev else s.jumpFails = (s.jumpFails or 0) + 1 end
    s.lastCtrl, s.lastAt = nil, now()
    return ev
end

-- Jumps are used while they answer: two that reported nothing in a session (a game build without the mouse path, or
-- rows without events) and the highlight walks for the rest of it.
function D.canJump()
    local s = D.S
    return D.cfg('Jump') and not s.listIndex and (s.jumpFails or 0) < 2
end

local function waitReady(ms)
    local s = D.S
    local stop = now() + ms
    while now() < stop and not s.cancel and not s.abort do
        AllowPauseMenuWhenDeadThisFrame()
        if D.onLanding() and not IsPauseMenuRestarting() and IsFrontendReadyForControl() and GetPauseMenuState() == 15 then return true end
        Wait(0)
    end
    return false
end

-- Opens LANDING under the bypass. variant tries a direct landing on the target screen (T7): 'component' and
-- 'component1000' pass it to ActivateFrontendMenu, 'restart' restarts the ready menu on it. false when it never got ready.
function D.open(screen, variant)
    local s = D.S
    if IsPauseMenuActive() then
        SetFrontendActive(false)
        local stop = now() + 2000
        while IsPauseMenuActive() do
            if now() > stop then return false end
            Wait(0)
        end
    end
    local component = (variant == 'component' and screen) or (variant == 'component1000' and screen + 1000) or -1
    AllowPauseMenuWhenDeadThisFrame()
    ActivateFrontendMenu(landing(), false, component)
    if not waitReady(D.cfg('OpenTimeoutMs')) then
        D.dbg('open: not ready', 'variant', variant, 'active', IsPauseMenuActive(), 'state', GetPauseMenuState())
        return false
    end
    D.dbg('open: ready', 'variant', variant, 'version', GetCurrentFrontendMenuVersion(), 'build', GetGameBuildNumber())
    if variant == 'restart' then
        RestartFrontendMenu(landing(), screen)
        Wait(100)
        if not waitReady(D.cfg('OpenTimeoutMs')) then return false end
    end
    -- Only a plain LANDING open is known to start on the header; a direct landing may already be in a list. A new menu
    -- has no reader movie in it yet (s.dxr, read.lua).
    s.opened, s.atTop, s.topUsed, s.inList, s.dxr = true, variant == nil, false, nil, nil
    sleep(D.cfg('SettleMs'))
    D.fe('LOCK_MOUSE_SUPPORT', false, false) -- the real cursor must not hover or click the hidden menu
    drain(true)
    return true
end

-- Closes GTA's menu. A warning still showing is answered with CANCEL (discard), never ACCEPT.
function D.close()
    local s = D.S
    local start, nextTry, tries = now(), 0, 0
    while IsPauseMenuActive() and now() < start + 4000 do
        if IsWarningMessageActive() then
            SetControlNormal(PAD, IN.CANCEL, 1.0)
            Wait(150)
        end
        if now() >= nextTry then
            tries = tries + 1
            -- A menu left half built by an error ignores the close: restarted first, it closes (PM.ForceCloseFrontend).
            if tries >= 3 and PM.ForceCloseFrontend then PM.ForceCloseFrontend() else SetFrontendActive(false) end
            nextTry = now() + 500
        end
        Wait(0)
    end
    if IsPauseMenuActive() then
        if PM.ForceCloseFrontend then PM.ForceCloseFrontend() else SetFrontendActive(false) end
    end
    s.opened, s.inList = false, nil
end

-- Input variant: 'focus' keeps our page focused (the keyboard cannot reach the hidden menu), 'nofocus' drops it,
-- 'scaleform' keeps focus and sends the arrow steps straight to the menu movie.
function D.setMode(mode)
    local s = D.S
    s.mode = mode
    PM.SetInput(mode == 'nofocus' and 'game' or 'ui')
    if s.opened then D.fe('LOCK_MOUSE_SUPPORT', false, false) end
end

-- First contact: the first variant whose presses move GTA's highlight wins. Returns it and where we are. dir: the
-- first move, toward the target category (the probe is already a step of the way).
function D.probe(modes, dir)
    local s = D.S
    local ctrl = DIRS[dir] or IN.DOWN
    for _, mode in ipairs(modes) do
        D.setMode(mode)
        drain()
        s.topUsed = false -- a variant whose presses never arrived did not use its ACCEPT either
        local ev = step(ctrl)
        if not ev and s.atTop and not s.topUsed then
            accept('top') -- focus still on the header: one ACCEPT shifts it into the category column
            sleep(250)
            ev = step(ctrl)
        end
        if ev then
            D.dbg('input variant', mode, 'works; first event menu', ev.menuId, 'uid', ev.uid)
            return mode, ev
        end
        D.dbg('no feedback with input variant', mode)
    end
    fail('no_feedback')
end

-- The list a row uid belongs to (calibrated order first, then the data); nil when unknown.
function D.listOf(uid)
    for _, screen in ipairs(D.CATEGORIES) do
        local order = D.cal.screens[tostring(screen)]
        if D.indexOf(order, uid) then return screen end
    end
    for _, screen in ipairs(D.CATEGORIES) do
        if D.indexOf(D.visible(screen, D.ctx), uid) then return screen end
    end
end

-- Back from a list to the category column; never with unapplied changes (GTA would ask to apply them).
function D.leave()
    local s = D.S
    if D.dirty() then D.clean() end
    if D.dirty() then fail('dirty') end
    press(IN.CANCEL)
    local ev = waitEvent()
    s.inList, s.listIndex, s.rows, s.order, s.slots = nil, false, nil, nil, nil
    if ev then s.ev = ev end
    if not (s.ev and D.isCategory(s.ev.menuId)) then
        local e = step(IN.DOWN) -- LayoutChangedOnBack did not report: a harmless move tells where we are
        if not e or not D.isCategory(e.menuId) then fail('lost') end
    end
end

-- Highlights a category, the shorter way round the column, checking each move.
function D.gotoCategory(screen)
    local s = D.S
    if s.inList then D.leave() end
    D.dbg('goto category', screen, 'from', s.ev and s.ev.menuId, 'uid', s.ev and s.ev.uid, 'mode', s.mode)
    -- One jump (GTA's mouse path, ~70 ms in game) when it works; walking otherwise, or from wherever it landed.
    if D.canJump() and s.ev and s.ev.menuId ~= screen and D.indexOf(D.CATEGORIES, screen) then
        local ev = D.jump(D.indexOf(D.CATEGORIES, screen) - 1)
        if ev and ev.menuId == screen then return end
        D.dbg('category jump to', screen, 'gave', ev and ev.menuId, '- walking')
    end
    local dir
    for _ = 1, #D.CATEGORIES * 2 do
        if s.ev and s.ev.menuId == screen then return end
        -- The Rockstar Editor tab shows even when its context reads off: once seen, the full column is the order (and
        -- the next sessions plan with it from their first move).
        if s.ev and s.ev.menuId == 146 then
            s.replaySeen = true
            if D.learn then D.learn.replay = true end
        end
        local cats = D.categories(s.replaySeen or (D.learn and D.learn.replay) or D.ctx('ReplayEditor'))
        -- Unknown spot: keep going the same way rather than bouncing back and forth.
        dir = D.path(cats, s.ev and s.ev.menuId, screen) or dir or 'DOWN'
        local ev = step(DIRS[dir])
        if not ev then fail('no_feedback') end
        if not D.isCategory(ev.menuId) then fail('lost') end
    end
    fail('not_found')
end

-- Enters the highlighted category. The first move inside proves the list is open (its event is a row's): a jump to the
-- slot wanted first once the list has the focus, else a step (toward dir, where the highlight stays; without dir it
-- comes back to the first row). (The turn gap after ACCEPT already waits longer than GTA needs to open the list.)
function D.enter(screen, dir, slot)
    local s = D.S
    accept('category', screen)
    -- Slot 0 is where the list opens: a jump there reports nothing.
    if slot and slot > 0 and D.canJump() then
        sleep(D.cfg('EnterSettleMs'))
        local ev = D.jump(slot)
        if ev and D.isCategory(ev.menuId) then fail('enter_failed') end
        if ev and ev.menuId == D.LIST then
            s.inList, s.rows = screen, D.visible(screen, D.ctx)
            D.fe('LOCK_MOUSE_SUPPORT', false, false)
            return
        end
        D.dbg('enter: jump to slot', slot, 'gave', ev and ev.menuId, '- stepping')
    end
    local sel0 = selection(1)
    local a = step(DIRS[dir] or IN.DOWN)
    if a and D.isCategory(a.menuId) then fail('enter_failed') end
    s.inList, s.rows = screen, D.visible(screen, D.ctx)
    if not a then
        -- The column moved but reported nothing: follow the highlighted slot instead of events.
        local sel = selection(1)
        if not sel or sel == sel0 then fail('no_feedback') end
        s.listIndex = true
        s.ev = { menuId = D.LIST, uid = D.slotUid(s.rows, sel), sel = sel }
        D.dbg('row events missing, following the highlighted slot on', screen)
    end
    if not dir and not step(IN.UP) then fail('no_feedback') end
    D.fe('LOCK_MOUSE_SUPPORT', false, false)
end

-- Walks the whole list once (calibration, T5): the uids the game reports, in menu order, cached per build.
function D.walk(screen)
    local s = D.S
    local start, seq = s.ev.uid, { s.ev.uid }
    for _ = 1, 90 do
        local ev = step(IN.DOWN)
        if not ev then fail('no_feedback') end
        if ev.uid == start then
            local expected = D.selectable(s.rows)
            seq = D.rotate(seq, expected[1])
            D.saveOrder(screen, seq)
            return seq
        end
        seq[#seq + 1] = ev.uid
    end
    fail('walk_failed')
end

-- Puts the highlight on a row by uid: one jump to its slot when a read gave the slots (~40 ms in game), else along the
-- learned order; a stale order is learned again once.
function D.findRow(uid)
    local s = D.S
    if s.ev and s.ev.uid == uid then return true end
    local slot = D.canJump() and s.slots and s.slots[uid]
    if slot then
        local ev = D.jump(slot)
        if ev and ev.uid == uid then return true end
        D.dbg('row jump to', uid, 'gave', ev and ev.uid, '- walking')
    end
    local dir, count = D.path(s.order, s.ev and s.ev.uid, uid)
    if dir then
        for _ = 1, count do
            if not step(DIRS[dir]) then fail('no_feedback') end
        end
        if s.ev.uid == uid then return true end
    end
    if s.listIndex or s.rewalked then return false end
    s.rewalked = true
    s.order = D.walk(s.inList)
    return D.findRow(uid)
end

-- The highlight must still be on uid: a value change never moves it, so an event for another row is foreign.
local function still(uid)
    local ev = poll()
    if ev and ev.uid ~= uid then
        D.S.abort = 'foreign'
        D.check()
    end
end

-- Value presses on the highlighted row.
function D.stepValue(dir, count, uid)
    still(uid)
    for _ = 1, count do
        press(DIRS[dir])
        still(uid)
    end
end

local function readConvar(name, ms)
    sleep(ms or 250)
    local v = GetConvarInt(name, -999)
    return v ~= -999 and v or nil
end

-- Absolute set (Mode A): GET_COLUMN_SELECTION + UPDATE_SLOT seed one step away, then one press; GTA receives
-- SET_PAUSE_MENU_PREF(uid, target) from the menu itself.
function D.seedSet(item, uid, target)
    still(uid)
    local slot = selection(1)
    if not slot then fail('seed_failed') end
    local seed, dir = D.seed(target)
    D.dbg('seed set uid', uid, 'slot', slot, 'seed', seed, dir, 'target', target)
    local args = { 1, slot, D.LIST + 1000, uid, 1, seed, 1, '' }
    for i = 0, math.max(item.count or 2, target + 1, 2) - 1 do args[#args + 1] = tostring(i) end
    D.fe('UPDATE_SLOT', table.unpack(args))
    -- The press goes to the menu movie in the same frame, right behind the seed: GTA refreshes some rows every frame
    -- (MSAA, Post FX follow the video memory bar), and a refresh between the two would turn the set into a +1 step.
    if D.cfg('SeedPress') == 'control' then
        Wait(0)
        D.stepValue(dir, 1, uid)
        return
    end
    D.fe('SET_INPUT_EVENT', DPAD[DIRS[dir]])
    D.S.lastCtrl, D.S.lastAt, D.S.expect = DIRS[dir], now(), now() + 700
    Wait(0)
    Wait(0)
    still(uid)
end

-- Absolute sets are trusted only after a self-test on a row with a convar: set it to its own value; if the seed
-- were ignored, the press would move the value and the convar would show it (then it is put back).
function D.seedReady(screen)
    local s, learn = D.S, D.learn
    if not D.cfg('UseSeed') then return false end
    if learn.seed ~= nil then return learn.seed end
    local test = D.SEED_TEST[screen]
    if not test then return false end
    local back = s.ev and s.ev.uid
    local uid = D.resolve(s.order, D.selectable(s.rows), test.uid)
    local convar = D.CONVARS[test.uid]
    local c = GetConvarInt(convar, -999)
    if not uid or c < 0 or c >= test.count or not D.findRow(uid) then return false end
    D.seedSet({ count = test.count }, uid, c)
    local v = readConvar(convar)
    learn.seed = v == c
    D.dbg('seed self-test', learn.seed, c, v)
    if v and v ~= c then
        local dir, n = D.relative('list', test.count, v, c)
        D.stepValue(dir, n, uid)
    end
    D.saveLearn()
    if back then D.findRow(back) end
    return learn.seed
end

-- Moves the highlighted row to item.target. Exact current value (convar, or item.from read by the Dirty oracle
-- before anything was pending): relative presses, convar rows verified after (closed loop, one repair pass).
-- Otherwise sliders clamp to 0 and count up, lists use a self-tested absolute set, else the last value we know.
function D.setItem(item, uid)
    local s = D.S
    local cur = item.convar and GetConvarInt(item.convar, -999) or -999
    if cur == -999 then cur = item.from end
    local exact = cur ~= nil
    if not exact then cur = item.current or D.cached(item.id) end
    s.changed[uid] = { item = item, from = exact and cur or nil, screen = s.inList }
    D.dbg('set', item.id, 'uid', uid, 'from', cur, exact and 'exact' or 'guess', 'to', item.target)
    if exact and cur == item.target then return end
    -- Rows GTA redraws with its own value every frame: each press moves that value one step and the list wraps, so
    -- the set is relative from the value we tracked (the last one we applied; GTA's default 0 when never set).
    if D.STEP[uid] and not exact then
        local from = cur or 0
        local dir, n = D.relative('list', item.count or 4, from, item.target)
        D.dbg('step row', item.id, 'from', from, 'to', item.target, dir, n)
        D.stepValue(dir, n, uid)
        return
    end
    if item.kind == 'slider' and not exact then
        D.stepValue('LEFT', item.count or 20, uid)
        D.stepValue('RIGHT', item.target, uid)
    elseif exact then
        local dir, n = D.relative(item.kind, item.count, cur, item.target)
        D.stepValue(dir, n, uid)
    elseif D.GFX[s.inList] and D.seedReady(s.inList) then
        D.findRow(uid)
        D.seedSet(item, uid, item.target)
    elseif cur then
        local dir, n = D.relative(item.kind, item.count, cur, item.target)
        D.stepValue(dir, n, uid)
    else
        fail('unknown_current')
    end
    if item.convar then
        local v = readConvar(item.convar)
        if v and v ~= item.target then
            local dir, n = D.relative(item.kind, item.count, v, item.target)
            D.stepValue(dir, n, uid)
            v = readConvar(item.convar, 400)
        end
        if v ~= item.target then fail('verify_failed') end
    elseif D.cfg('VerifySets') and s.slots and s.slots[uid] then
        -- GTA writes every value press into its list (seen in game): the row read back shows a press the menu dropped,
        -- which is pressed again, before Apply rather than after.
        for try = 1, 3 do
            sleep(60)
            local v = D.readValue(s.slots[uid], uid, item.kind, item.count)
            if v ~= nil and v ~= item.target then
                sleep(150) -- a row GTA redraws itself may show the press a few frames later: not a dropped press yet
                v = D.readValue(s.slots[uid], uid, item.kind, item.count)
            end
            if v == nil or v == item.target then return end
            if try == 3 then fail('verify_failed') end
            D.dbg('set check', item.id, 'shows', v, 'not', item.target, '- pressing again')
            local dir, n = D.relative(item.kind, item.count, v, item.target)
            D.stepValue(dir, n, uid)
        end
    end
end

-- Dirty oracle (research B 7.3): with nothing else pending, GTA is clean exactly when this row shows its applied
-- value. Leaves the row on that value and returns it (nil when it cannot be told).
function D.readRow(item, uid)
    -- Without a readable GFX_Dirty every try would look "current": no read, the set is absolute instead.
    if not D.dirtyKnown() then return nil end
    if item.kind == 'slider' then
        local n = item.count or 20
        D.stepValue('LEFT', n, uid)
        for v = 0, n do
            sleep(30)
            if not D.dirty() then return v end
            if v < n then D.stepValue('RIGHT', 1, uid) end
        end
        return nil
    end
    if not D.seedReady(D.S.inList) or not D.findRow(uid) then return nil end
    local n, first = item.count or 2, D.cached(item.id)
    local tries = (first and first < n) and { first } or {}
    for v = 0, n - 1 do
        if v ~= first then tries[#tries + 1] = v end
    end
    for _, v in ipairs(tries) do
        D.seedSet(item, uid, v)
        -- GTA raises GFX_Dirty a few frames after the change: only a clean menu for the whole window means "current".
        local stop, dirtyAt = now() + D.cfg('DirtyWaitMs'), nil
        repeat
            Wait(0)
            if D.dirty() then dirtyAt = now() break end
        until now() >= stop
        D.dbg('read', item.id, 'try', v, dirtyAt and 'dirty' or 'clean')
        if not dirtyAt then return v end
    end
    return nil
end

-- The read oracle on b3258 (GFX_Dirty is unreadable there): leaving a graphics list with a pending change makes GTA ask
-- "apply the changes?". Leaves the list; true when GTA did not ask (every value shown was the applied one). A question
-- is answered with CANCEL (discard), never ACCEPT, so nothing is ever applied.
function D.leaveProbe()
    local s = D.S
    press(IN.CANCEL)
    s.expect = now() + 1500
    local stop, warned, left, backOut = now() + D.cfg('WarnWaitMs'), false, nil, false
    repeat
        Wait(0)
        D.check()
        if IsWarningMessageActive() then
            warned = true
            local hash = GetWarningMessageTitleHash()
            backOut = hash == D.BACK_OUT
            D.dbg('leave probe: GTA asks, title hash', hash)
            break
        end
        local ev = poll()
        if ev then
            s.ev = ev
            if D.isCategory(ev.menuId) then left = left or now() end
        end
    -- Back on the category column with no question for a short while: nothing was pending.
    until now() > stop or (left and now() - left > D.cfg('WarnSettleMs'))
    if warned then
        press(IN.CANCEL)
        s.expect = now() + 1500
        local gone = now() + 3000
        while IsWarningMessageActive() and now() < gone do Wait(0) end
        if IsWarningMessageActive() then fail('warning_stuck') end
        sleep(250)
        local ev = poll()
        if ev then s.ev = ev end
    end
    s.inList, s.listIndex, s.rows, s.order, s.slots = nil, false, nil, nil, nil
    -- The answer is only whether GTA asked. Where the highlight ended is another matter: anywhere but the category
    -- column (some questions, texture quality's "the game must restart", keep CANCEL as "stay" with the change still
    -- pending; a leave can also run on to the header) and the caller closes GTA's menu, which drops any pending change
    -- (checked in game: nothing reached the settings file), and opens it again.
    if not (s.ev and D.isCategory(s.ev.menuId)) then
        s.reopen = true
        -- GFX_BACK_OUT_BODY ("Unapplied Changes") is only ever asked for a pending change: a sure "differs" even here.
        if backOut then
            D.dbg('leave probe: asked (value differs), position unclear, reopening')
            return false
        end
        -- The leave ran on (to the header or back into the list) and the question, if any, was another one.
        D.dbg('leave probe: position unclear (last event menu', s.ev and s.ev.menuId, ') - inconclusive, reopening')
        return nil
    end
    D.dbg('leave probe', warned and 'asked (value differs)' or 'clean (value matches)')
    return not warned
end

-- Steps every row this run touched on the open graphics screen back until GTA has nothing pending.
function D.clean()
    local s = D.S
    if not D.dirty() then return true end
    for _, known in ipairs({ true, false }) do
        for uid, ch in pairs(s.changed) do
            if ch.screen == s.inList and (ch.from ~= nil) == known and D.findRow(uid) then
                if known then
                    local at = ch.item.convar and GetConvarInt(ch.item.convar, -999) or ch.item.target
                    local dir, n = D.relative(ch.item.kind, ch.item.count, at ~= -999 and at or ch.item.target, ch.from)
                    D.stepValue(dir, n, uid)
                    sleep(50)
                else
                    D.readRow(ch.item, uid)
                end
                if not D.dirty() then return true end
            end
        end
    end
    return not D.dirty()
end

-- Shows a question on our overlay and waits for the player (pm:driver:confirm). No answer means no.
function D.ask(kind, ms, alive)
    local s = D.S
    s.prompt, s.promptMs, s.answer = kind, ms, nil
    if s.mode == 'nofocus' then PM.SetInput('ui') end
    D.state()
    local stop = now() + ms
    while s.answer == nil and now() < stop and not s.cancel and not s.abort and (not alive or alive()) do Wait(50) end
    local yes = s.answer == true
    s.prompt, s.promptMs, s.answer = nil, nil, nil
    if s.mode == 'nofocus' then PM.SetInput('game') end
    D.state()
    return yes
end

-- Apply (INPUT_FRONTEND_X, only while GFX_Dirty) and what GTA asks afterwards: "keep these settings?" is kept at once
-- when no display mode row changed, and goes to the player when one did; any other question (texture quality restarts
-- the game on b3258) goes to the player too. Returns 'clean' | 'applied' | 'reverted'.
function D.apply(video)
    local s = D.S
    s.keep = nil
    local known = D.dirtyKnown()
    D.dbg('apply: dirty', D.dirty(), 'dirty readable', known)
    if known and not D.dirty() then return 'clean' end
    -- On the settings screens X is only Apply (pausemenu.xml): with nothing pending it does nothing.
    press(IN.X)
    local stop, asked, gone = now() + D.cfg('ApplyTimeoutMs'), false, nil
    local settle = now() + (known and 0 or D.cfg('WarnShowMs')) -- unreadable dirty: give a warning prompt time to show
    while true do
        poll()
        if IsWarningMessageActive() then
            gone = nil
            if not asked then
                asked = true
                local hash = GetWarningMessageTitleHash()
                D.dbg('warning after apply, title hash', hash)
                if not video and D.cfg('AutoKeep') and u32(hash) == u32(D.KEEP_WARN) then
                    -- GTA's revert guards against a display mode the screen cannot show; these rows (MSAA, Post FX...)
                    -- cannot change the mode, and the player already chose Apply.
                    D.dbg('apply: keeping the new settings (no display mode row)')
                    s.keep = true
                else
                    local kind = video and 'keep' or 'gta'
                    s.keep = D.ask(kind, D.cfg(video and 'KeepPromptMs' or 'ConfirmMs'), IsWarningMessageActive)
                end
                if IsWarningMessageActive() then
                    if s.keep then accept('keep') else press(IN.CANCEL) end
                end
                stop = now() + D.cfg('ApplyTimeoutMs')
            end
        else
            gone = gone or now()
            -- A question already answered needs no more waiting for one.
            if not D.dirty() and (asked or now() >= settle) then return (asked and not s.keep) and 'reverted' or 'applied' end
            if asked and now() - gone > 1500 then return 'reverted' end
        end
        if now() > stop then fail('apply_timeout') end
        Wait(50)
        D.check()
    end
end
