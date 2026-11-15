-- Settings driver (Engine B), scaleform reads: the values GTA's C++ wrote into its own menu movie when it built a
-- settings list (SET_DATA_SLOT rows in currentPage.column2.model.viewList[0].dataList), read back with method calls
-- on the frontend movie (research gfxread 1-4). What b3258 does with those calls (disassembly, gfxread/4-build.md §10):
-- * GTA invokes "TIMELINE." .. name through a path-resolving GFx call, so a dotted name can reach the list; names are
--   cut at 49 characters.
-- * A return value is kept only when the AS result is defined (otherwise the handle never turns ready), for about 20
--   frames, at most 20 per frame. The first GET_SCALEFORM_MOVIE_METHOD_RETURN_VALUE_* call takes it out of its slot, so a
--   handle is read with one getter only: int (-1 for a non-number), str ('' for a non-string) or bool.
-- * The string getter keeps at most 63 characters: a list is read one row per call (a row's head fits).
-- * 20 ready slots in total (0x14201BB20), each held up to 20 frames unless read. Map readers (client/map/names.lua,
--   focus.lua) use at most 8 at a time each; the settings driver runs on another screen.
-- The F8 experiment 'pausemenu_gfxread' finds the form that works on this game; Sync and Run use the one it learned.
local D = PMDrv
local now = GetGameTimer
local RESOURCE = GetCurrentResourceName()

local VIEW = 'currentPage.column2.model.viewList.0' -- the settings list view, relative to TIMELINE
local CTL = 'GET_COLUMN_SELECTION'
D.STR_CAP = 63 -- characters GTA's string getter keeps
local BATCH = 16 -- return-value calls queued per frame (GTA keeps 20)

-- The reader: our AS2 movie (D.inject) answers the row count (an int), then one row per call (a string: the row's
-- fields joined by ','). Dotted paths to the list itself are 52+ characters, past the 49 GTA keeps of a name.
D.READERS = {
    { id = 'inject', count = 'DXR_N', row = function(i) return 'DXR_V', { i } end },
}
D.READER_KEY = 7341 -- what DXR_K answers once the reader movie is in

-- A getter that a runtime (or the test sim) may lack, or that throws on an unexpected result type.
local function get(fn, handle)
    if type(fn) ~= 'function' then return nil end
    local ok, value = pcall(fn, handle)
    if ok then return value end
end

local function push(args)
    for _, v in ipairs(args or {}) do
        if type(v) == 'boolean' then ScaleformMovieMethodAddParamBool(v)
        elseif type(v) == 'string' then ScaleformMovieMethodAddParamTextureNameString(v)
        elseif type(v) == 'table' then
            -- A text param GTA composes now: a blip's name (the getter its map legend uses) or a literal. Unparsed: ~x~
            -- tokens stay as they are instead of turning into HTML, so the 63 bytes of an answer keep more of the name.
            BeginTextCommandScaleformString('STRING')
            if v.blip then AddTextComponentSubstringBlipName(v.blip)
            else AddTextComponentSubstringPlayerName(tostring(v.text)) end
            EndTextCommandUnparsedScaleformString()
        elseif math.type(v) == 'float' then ScaleformMovieMethodAddParamFloat(v)
        else ScaleformMovieMethodAddParamInt(v) end
    end
end

-- One method call with a return value, to be read as kind ('int' by default, 'str' or 'bool'). Returns the call
-- record; call.handle is false when GTA refused the call.
local function queue(began, name, args, kind)
    local call = { name = name, get = kind or 'int', raw = began }
    -- The binding answers true or 1 for a started call (1 in game on b3258), false, nil or 0 for a refused one.
    call.begin = began == true or began == 1
    if not call.begin then
        call.handle = false
        return call
    end
    push(args)
    call.handle = EndScaleformMovieMethodReturnValue()
    return call
end

-- On the frontend content movie.
function D.feQueue(name, args, kind) return queue(BeginScaleformMovieMethodOnFrontend(name), name, args, kind) end

-- The same on a movie this resource requested (RequestScaleformMovie handle).
function D.mvQueue(handle, name, args, kind) return queue(BeginScaleformMovieMethod(handle, name), name, args, kind) end

local function open(c) return c.handle ~= false and c.handle ~= nil and c.ready == nil end

-- A running session's stop (deadline, cancel, menu closed) is raised in the session's own thread only: the map
-- readers wait through these same calls in theirs. s.thread unknown: every wait checks.
local function check()
    local s = D.S
    if s and (s.thread == nil or s.thread == coroutine.running()) then D.check() end
end

-- The one read a handle allows (the getter empties its slot). again: a second int read, to show that.
local function take(c)
    if c.get == 'str' then c.str = get(GetScaleformMovieMethodReturnValueString, c.handle)
    elseif c.get == 'bool' then c.bool = get(GetScaleformMovieMethodReturnValueBool, c.handle)
    else c.int = get(GetScaleformMovieMethodReturnValueInt, c.handle) end
    if c.again then c.int2 = get(GetScaleformMovieMethodReturnValueInt, c.handle) end
end

-- Waits (ms for the whole set) for queued calls and reads each ready one with its getter. tick: called every frame
-- while waiting (a movie of ours that must be drawn to run its calls).
function D.feAwait(calls, ms, tick)
    local start = now()
    local stop = start + (ms or 500)
    while true do
        local waiting = false
        for _, c in ipairs(calls) do
            if open(c) then
                if IsScaleformMovieMethodReturnValueReady(c.handle) then
                    c.ready, c.ms = true, now() - start
                    take(c)
                else
                    waiting = true
                end
            end
        end
        if not waiting or now() > stop then break end
        if tick then tick() end
        Wait(0)
        check()
    end
    for _, c in ipairs(calls) do
        if open(c) then c.ready, c.ms = false, now() - start end
    end
    return calls
end

function D.feCall(name, args, ms, kind)
    return D.feAwait({ D.feQueue(name, args, kind) }, ms)[1]
end

local function keyed(call) return call.ready == true and call.int == D.READER_KEY end

local function waitKey(ms)
    local stop = now() + ms
    repeat
        Wait(0)
        check()
        if keyed(D.feCall('DXR_K', nil, 150)) then return true end
    until now() > stop
    return false
end

-- The reader movie ships streamed (stream/daddy_dxr*.gfx): GTA loads menu pages by name from its scaleform store, so
-- once requested it can be loaded inside the menu by that name. GTA takes each name once per game session: after a
-- restart of this resource a request for a name it loaded before throws or never loads (seen in game). So 16 names
-- ship (tools/pausemenu/dxr/build.mjs), and KVP keeps when each was last requested, in GetGameTimer (back to 0 with
-- every game start): a name requested later than now was requested in an earlier game session.
local NAMES = {}
for i = 0, 15 do NAMES[#NAMES + 1] = i == 0 and 'daddy_dxr' or ('daddy_dxr' .. i) end
local USED_KVP = RESOURCE .. ':driver:dxrused'
local LOAD_MS = 1500 -- a fresh name loads in the frame it is requested
local STREAMED -- the name this start loaded
local streamedHandle, streamedBroken, requesting = nil, false, false

local function loadedMovie(handle)
    if not handle then return false end
    local ok, v = pcall(HasScaleformMovieLoaded, handle)
    return ok and (v == true or v == 1)
end

-- Names in the order to try: not requested in this game session first, then the one requested longest ago.
local function candidates(used, at)
    local fresh, old = {}, {}
    for _, name in ipairs(NAMES) do
        local t = tonumber(used[name])
        if not t or t > at then fresh[#fresh + 1] = name else old[#old + 1] = name end
    end
    -- tonumber: a hand-edited KVP may hold numeric strings (a string against a number throws)
    table.sort(old, function(a, b) return tonumber(used[a]) < tonumber(used[b]) end)
    for _, name in ipairs(old) do fresh[#fresh + 1] = name end
    return fresh
end

-- One pass over the names: true once one loaded, false when GTA refused every one.
local function requestAny()
    local ok, used = pcall(json.decode, GetResourceKvpString(USED_KVP) or '')
    used = ok and type(used) == 'table' and used or {}
    for _, name in ipairs(candidates(used, now())) do
        used[name] = now()
        SetResourceKvp(USED_KVP, json.encode(used))
        local fine, handle = pcall(RequestScaleformMovie, name)
        if fine then
            local stop = now() + LOAD_MS
            while not loadedMovie(handle) and now() < stop do Wait(0) end
            if loadedMovie(handle) then
                streamedHandle, STREAMED = handle, name
                D.dbg('reader movie', name, 'handle', handle, 'loaded')
                return true
            end
            pcall(SetScaleformMovieAsNoLongerNeeded, handle)
            D.dbg('reader movie', name, 'did not load')
        else
            D.dbg('reader movie', name, 'request threw:', handle)
        end
    end
    return false
end

-- Requests the streamed movie and waits for it (once: the first Settings open already starts it, D.prewarm). A name
-- GTA refuses (the request throws or never loads) is skipped for the next one; with none left, the slower reads take
-- over until the game restarts. warm: the prewarm thread (no session to check while it waits).
local function requestStreamed(warm)
    -- A session waiting on the prewarm still stops on its deadline, a cancel or our menu closing.
    while requesting do
        Wait(0)
        if not warm then check() end
    end
    if loadedMovie(streamedHandle) then return true end
    if streamedBroken then return false end
    -- The flag is cleared whatever happens: one left set would hold every later request (and its session) forever.
    requesting = true
    local ok, loaded = pcall(requestAny)
    requesting = false
    if not ok then
        print(('^1[%s] graphics reader request failed: %s^7'):format(RESOURCE, tostring(loaded)))
        return false
    end
    if loaded then return true end
    streamedBroken = true
    print(('^3[%s] graphics reader unavailable until the game restarts (every reader name was used this game session)^7'):format(RESOURCE))
    return false
end

-- Requested on the first Settings open, so a broken request shows before a session opens GTA's menu for it.
function D.prewarm() CreateThread(function() requestStreamed(true) end) end

-- 'streamed', 'broken' (no name left this game session) or 'unknown' (not loaded yet); and the name in use.
function D.readerState()
    if streamedBroken then return 'broken', STREAMED end
    return loadedMovie(streamedHandle) and 'streamed' or 'unknown', STREAMED
end

-- Loads the reader movie into GTA's menu movie (an empty clip TIMELINE.dxr, then loadMovie), once per menu: its frame
-- script adds DXR_K (the key), DXR_N (row count), DXR_V(i) (one row), DXR_R (every row), DXR_S(a, b) (rows a..b-1)
-- and DXR_E(path, method, arg) to the content TIMELINE and to _level0. true when DXR_K answers.
-- GTA's LOAD_PAGE is never used for it: replacing the page container broke the settings menu in game.
function D.inject()
    local s = D.S
    -- A menu this session just opened has no reader yet (the check would wait out its whole timeout).
    if (not s or s.dxr) and keyed(D.feCall('DXR_K', nil, 150)) then return true end
    if not requestStreamed() then return false end
    D.fe('TIMELINE.createEmptyMovieClip', 'dxr', 9000)
    D.fe('TIMELINE.dxr.loadMovie', STREAMED)
    if waitKey(1200) then
        D.dbg('reader movie loaded from', STREAMED)
        if s then s.dxr = true end
        if D.learn then D.learn.dxrurl = STREAMED end
        return true, STREAMED
    end
    D.dbg('reader movie not loaded from', STREAMED)
    return false
end

-- One reader's dump of the open list: the row count, then one row per call (GTA keeps 63 characters of a string),
-- BATCH calls per frame; rows that did not answer are asked once more. Rows joined by '|' (with a trailing '|'); a
-- row that still does not answer is left out. nil when the count does not answer.
function D.readRows(reader, ms)
    local n = D.feCall(reader.count, nil, 300)
    local count = n.ready == true and math.type(n.int) == 'integer' and n.int or 0
    if count <= 0 then return nil end
    count = math.min(count, 120)
    local got, calls, missing = {}, 0, {}
    for i = 0, count - 1 do missing[#missing + 1] = i end
    for _ = 1, 2 do
        local left = {}
        for first = 1, #missing, BATCH do
            local batch = {}
            for k = first, math.min(first + BATCH - 1, #missing) do
                local name, args = reader.row(missing[k])
                local c = D.feQueue(name, args, 'str')
                c.index = missing[k]
                batch[#batch + 1] = c
            end
            D.feAwait(batch, ms or 300)
            for _, c in ipairs(batch) do
                calls = calls + 1
                if c.ready == true and type(c.str) == 'string' and c.str ~= '' then got[c.index] = c.str
                else left[#left + 1] = c.index end
            end
        end
        missing = left
        if #missing == 0 then break end
    end
    local parts = {}
    for i = 0, count - 1 do
        if got[i] then parts[#parts + 1] = got[i] end
    end
    return { ready = #parts > 0, str = #parts > 0 and (table.concat(parts, '|') .. '|') or nil, rows = count, calls = calls, got = #parts }
end

-- One row's value as the open list holds it now (DXR_V of its slot); nil when it does not answer or cannot be told.
function D.readValue(slot, uid, kind, count)
    local c = D.feCall('DXR_V', { slot }, 300, 'str')
    local rows = c.ready == true and type(c.str) == 'string' and c.str ~= '' and D.parseRows(c.str .. '|')
    return rows and D.rowValue(rows, uid, kind, count) or nil
end

-- Direct pref writes (research next/2-direct-write.md): DXR_P(uid, value) makes the call a settings row makes
-- (SET_PAUSE_MENU_PREF) without the row; GTA's handler (b3258) only needs Settings on top of the menu stack. DXR_M(uid,
-- dir) is the row's arrow click (HANDLE_MOUSE_LEFT_RIGHT). Both answer the uid when they ran, -1 when the movie refused.
D.PREF_MAX = 176 -- GTA indexes its pref array with the uid, unchecked below 0 (b3258 0x1401abd00)
-- Never written directly: restore defaults, startup flow, landing page, languages and the display mode rows (they keep
-- the confirm path and GTA's own lists).
D.NO_DIRECT = { [144] = true, [55] = true, [168] = true, [40] = true, [41] = true, [56] = true, [57] = true, [58] = true }

local function prefCall(name, uid, arg)
    if math.type(uid) ~= 'integer' or uid < 0 or uid > D.PREF_MAX or D.BLOCKED[uid] or D.NO_DIRECT[uid] then D.fail('bad_pref') end
    if math.type(arg) ~= 'integer' then D.fail('bad_value') end
    local c = D.feQueue(name, { uid, arg }, 'int')
    c.uid = uid
    return c
end

-- The menu rebuilds its rows after a write and may report layout events: ours, drained before anything polls them as
-- foreign. GTA runs a flash callback on its next update, so a read back comes after this.
function D.quiet(frames)
    if D.S then D.S.expect = now() + 800 end
    for _ = 1, frames or 3 do
        if HasMenuLayoutChangedEventOccurred() then GetMenuLayoutChangedEventDetails() end
        Wait(0)
    end
end

-- The movie in GTA's menu carries the writers (a copy from before them answers DXR_K but never DXR_P): DXR_P refuses
-- uid -1 itself and answers -1, nothing reaches GTA.
function D.canWrite()
    local c = D.feCall('DXR_P', { -1, 0 }, 150)
    return c.ready == true and c.int == -1
end

-- writes = { { uid, value }, ... } in dependency order. Returns the uids the movie ran.
function D.writePrefs(writes)
    local ran = {}
    for first = 1, #writes, BATCH do
        local batch = {}
        for i = first, math.min(first + BATCH - 1, #writes) do
            local w = writes[i]
            if math.type(w[2]) ~= 'integer' or w[2] < 0 or w[2] > 999 then D.fail('bad_value') end
            batch[#batch + 1] = prefCall('DXR_P', w[1], w[2])
        end
        D.feAwait(batch, 300)
        for _, c in ipairs(batch) do
            if c.ready == true and c.int == c.uid then ran[#ran + 1] = c.uid end
        end
    end
    D.quiet()
    return ran
end

-- n arrow clicks on a pref (GTA's own step and limits); false when the movie did not run one.
function D.stepPref(uid, dir, n)
    for _ = 1, n or 1 do
        local c = D.feAwait({ prefCall('DXR_M', uid, dir) }, 300)[1]
        if c.ready ~= true or c.int ~= uid then return false end
        D.quiet(2)
    end
    return true
end

-- A read is used when it is of this screen's list (the column can still show the category passed on the way) and,
-- for the graphics list, its well-known rows hold values in range.
local function accept(screen, call)
    local rows, count = D.parseRows(call and call.str)
    if not rows or not D.belongs(rows, screen) then return nil end
    if screen == 137 and not D.plausible(rows) then return nil end
    return rows, count
end

local function learnReader(id)
    if not D.learn or D.learn.sfread == id then return end
    D.learn.sfread = id
    D.saveLearn()
end

-- Reads that found no reader in this session: after two, the reads give up at once (the slower paths take over).
local failures = 0

-- The rows of the open settings list (or of the highlighted category: GTA builds that list before it is entered) as
-- GTA wrote them: { [uid] = row }, the reader, the row count and whether every row answered (a row missing from an
-- incomplete read is unknown, not absent); nil and why ('noreader' or 'mismatch') otherwise.
-- Read before anything is seeded (UPDATE_SLOT replaces a row).
function D.readScaleform(screen)
    if streamedBroken or failures >= 2 then return nil, 'noreader' end
    local reader = D.READERS[1]
    if not D.inject() then
        failures = failures + 1
        if screen == 137 then learnReader(nil) end
        return nil, 'noreader'
    end
    failures = 0
    local dump = D.readRows(reader)
    local rows, count = accept(screen, dump)
    if not rows then return nil, 'mismatch' end
    if screen == 137 then learnReader(reader.id) end
    return rows, reader.id, count, dump.got == dump.rows
end

-- Forget the failed reads (every session tries again; only a request that threw stays off for the game session).
function D.readReset() failures = 0 end

-- The experiment (F8 pausemenu_gfxread, run.lua). Every line starts with '[pmread] <phase> <variant>' and holds what
-- GTA answered: begin (the call was accepted), ready (a return value came), ms, the one getter read (get=) and its
-- value. research gfxread/4-build.md explains each variant and what to change once one works.
local function rep(text, n) return text:rep(n) end
local PROBES -- built on the first run of the experiment (DEV only), not at every start
local function probes()
    if PROBES then return PROBES end
    PROBES = {
        -- Controls: the proven call, a missing method (what a failure looks like), the getter rules and a string return.
        { id = 'ctl_sel', name = CTL, args = { 1 }, want = 'the highlighted slot (control)', ctl = true },
        { id = 'ctl_missing', name = 'DADDY_NO_SUCH_METHOD', want = 'ready=false (an undefined result is never kept)' },
        { id = 'ctl_twice', name = CTL, args = { 1 }, again = true, want = 'int = ctl_sel, int2 = -1 (a getter empties the slot)' },
        { id = 'ctl_as_str', name = CTL, args = { 1 }, get = 'str', want = 'str "" (a number read as a string)' },
        { id = 'ctl_page', name = 'GET_PAGE', args = { 1006 }, get = 'str', want = 'string PAUSE_MENU_PAGES_SETTINGS' },
        -- Name model: does GTA prefix "TIMELINE." (prefix: names start at the TIMELINE instance; root: at _level0) and
        -- parse dots at all (any: both bases reach it)? same: the int must equal ctl_sel (and not sep, not ctl_missing).
        { id = 'dot_maxcols', name = 'currentPage.getMaxColumns', want = 'int 2', expect = 2, model = 'prefix' },
        { id = 'dot_modelsel', name = 'currentPage.column2.model.getCurrentSelection', want = 'same as ctl_sel', same = true, model = 'prefix' },
        { id = 'dot_getter49', name = VIEW .. '.__get__index', want = 'same as ctl_sel (49 chars)', same = true, len = true, model = 'prefix' },
        { id = 'base_self', name = 'TIMELINE.TIMELINE.' .. CTL, args = { 1 }, want = 'same as ctl_sel if prefixed', same = true, model = 'prefix' },
        { id = 'base_parent', name = 'CONTENT._parent.TIMELINE.' .. CTL, args = { 1 }, want = 'same as ctl_sel if dots are parsed', same = true, model = 'any' },
        { id = 'base_root', name = 'TIMELINE.' .. CTL, args = { 1 }, want = 'same as ctl_sel if not prefixed', same = true, model = 'root' },
        { id = 'base_level0', name = '_level0.TIMELINE.' .. CTL, args = { 1 }, want = 'same as ctl_sel if not prefixed', same = true, model = 'root' },
        -- Name length: where GTA cuts the method name (one ladder per model; len50 reaches the page from either base).
        { id = 'len50', name = 'CONTENT._parent.TIMELINE.currentPage.getMaxColumns', want = 'int 2 if 50 chars pass', expect = 2, len = true, model = 'any' },
        { id = 'len52', name = VIEW .. '.__get__maxitems', want = 'the row count if 52 chars pass', positive = true, len = true, model = 'prefix' },
        { id = 'len56', name = rep('TIMELINE.TIMELINE.', 2) .. CTL, args = { 1 }, want = 'same as ctl_sel if 56 chars pass', same = true, len = true, model = 'prefix' },
        { id = 'len74', name = rep('TIMELINE.TIMELINE.', 3) .. CTL, args = { 1 }, want = 'same as ctl_sel if 74 chars pass', same = true, len = true, model = 'prefix' },
        { id = 'len128', name = rep('TIMELINE.TIMELINE.', 6) .. CTL, args = { 1 }, want = 'same as ctl_sel if 128 chars pass', same = true, len = true, model = 'prefix' },
        { id = 'len47_root', name = rep('TIMELINE.', 3) .. CTL, args = { 1 }, want = 'same as ctl_sel if not prefixed', same = true, len = true, model = 'root' },
        { id = 'len65_root', name = rep('TIMELINE.', 5) .. CTL, args = { 1 }, want = 'same as ctl_sel if not prefixed and 65 pass', same = true, len = true, model = 'root' },
        -- String returns through a dotted owner (Array.join binds this to the array); a 120-char separator tests params
        -- (the answer is cut at 63 characters, so the param shows as strlen 63 instead of a short one).
        { id = 'str_gfxlist', name = 'menuGFXList.join', args = { '|' }, get = 'str', want = 'the page gfx names (63 chars at most)' },
        { id = 'str_columns', name = 'currentPage.columnList.join', args = { '|' }, get = 'str', want = 'two clip paths ..c1MC|..c2MC' },
        { id = 'str_col2', name = 'currentPage.column2.toString', get = 'str', want = 'a clip path or [object Object]' },
        { id = 'str_sep120', name = 'currentPage.columnList.join', args = { rep('~', 120) }, get = 'str', want = 'strlen 63 with ~ after the first path' },
        -- Owner binding on _level0: an empty clip made and measured (removed again at the end of the phase).
        -- (the two makers return a MovieClip, so they go without a return value request)
        { id = 'clip_make', name = 'TIMELINE.createEmptyMovieClip', args = { 'dxrprobe', 9001 }, want = 'makes _level0.dxrprobe', bare = true },
        { id = 'clip_depth', name = 'TIMELINE.dxrprobe.getDepth', want = 'int 9001 if prefixed', expect = 9001, model = 'prefix' },
        { id = 'clip_make_root', name = 'createEmptyMovieClip', args = { 'dxrprobe2', 9002 }, want = 'root form', bare = true },
        { id = 'clip_depth_root', name = 'dxrprobe2.getDepth', want = 'int 9002 if not prefixed', expect = 9002, model = 'root' },
        -- The reader movie (only when it ships and loads): key, row count, one row, a page and the generic call.
        { id = 'inj_key', name = 'DXR_K', want = 'int 7341', expect = 7341, inject = true },
        { id = 'inj_count', name = 'DXR_N', want = 'the row count', positive = true, inject = true },
        { id = 'inj_row', name = 'DXR_V', args = { 3 }, get = 'str', want = 'row 3 joined by commas', inject = true },
        { id = 'inj_page', name = 'DXR_S', args = { 0, 8 }, get = 'str', want = 'rows 0..7, cut at 63 chars', dump = true, inject = true },
        { id = 'inj_eval', name = 'DXR_E', args = { VIEW .. '.dataList', 'join', '|' }, get = 'str', want = 'rows (any path), cut at 63 chars', dump = true, inject = true },
        -- Whole-list dumps in one string (cut at 63 characters, so never a full read; they show the cut and the name cut).
        { id = 'full_hover', name = 'lastHoveredItem.storeScope.dataList.join', args = { '|' }, get = 'str', want = 'rows only after a mouse hover (40 chars)', dump = true, full = true },
        { id = 'full_join', name = VIEW .. '.dataList.join', args = { '|' }, get = 'str', want = 'rows if 50 chars pass, cut at 63 chars', dump = true, full = true },
        { id = 'full_tostring', name = VIEW .. '.dataList.toString', get = 'str', want = 'rows if 54 chars pass, cut at 63 chars', dump = true, full = true },
        { id = 'full_join_root', name = 'TIMELINE.' .. VIEW .. '.dataList.join', args = { '|' }, get = 'str', want = 'root model, 59 chars', dump = true, full = true },
    }
    -- Every reader is a dump variant too (dump_<reader id>): its count, then one call per row.
    for _, r in ipairs(D.READERS) do
        PROBES[#PROBES + 1] = { id = 'dump_' .. r.id, name = r.count, want = 'every row, one call each', dump = true, reader = r }
    end
    return PROBES
end
local CLEANUP = { 'TIMELINE.dxrprobe.removeMovieClip', 'dxrprobe2.removeMovieClip' }

local function clip(text, n)
    text = tostring(text):gsub('[\r\n]', ' ')
    if #text > n then return text:sub(1, n) .. '...' end
    return text
end

local function argText(args)
    if not args or #args == 0 then return '-' end
    local out = {}
    for i, a in ipairs(args) do out[i] = type(a) == 'string' and (#a > 40 and ('s' .. #a) or ('"' .. a .. '"')) or tostring(a) end
    return table.concat(out, ',')
end

local function sample(rows)
    local out = {}
    for _, uid in ipairs(D.READ_CHECK) do
        local row = rows and rows[uid]
        if row then out[#out + 1] = uid .. '=' .. tostring(row.value) .. (row.state == 2 and '*' or '') end
    end
    return table.concat(out, ',')
end

-- A probe passes when it returns its expected int (positive: any count above 0), or for a same-probe the control's
-- slot, which must differ from the separator call just before it and from what a missing method answers (fail).
local function matched(v, c, ctl, fail)
    if c.ready ~= true or math.type(c.int) ~= 'integer' or c.int == fail then return false end
    if v.expect then return c.int == v.expect end
    if v.positive then return c.int > 0 end
    return v.same == true and c.int == ctl and c.int ~= c.sep and c.int ~= -1
end

-- One experiment line: phase, variant id and everything GTA answered.
local function report(phase, v, c)
    local parts = {
        ('name="%s" len=%d args=%s get=%s'):format(v.name, #v.name, argText(v.args), v.reader and 'rows' or (v.get or 'int')),
        ('begin=%s(%s) ready=%s ms=%s int=%s bool=%s strlen=%s'):format(tostring(c.begin), tostring(c.raw), tostring(c.ready), tostring(c.ms),
            tostring(c.int), tostring(c.bool), type(c.str) == 'string' and #c.str or 'nil'),
    }
    if v.again then parts[#parts + 1] = 'int2=' .. tostring(c.int2) end
    if c.sep ~= nil then parts[#parts + 1] = 'sep=' .. tostring(c.sep) end
    if v.same or v.expect or v.positive then parts[#parts + 1] = 'match=' .. tostring(c.match) end
    if v.reader then parts[#parts + 1] = ('count=%s calls=%s answered=%s'):format(tostring(c.rowsCount), tostring(c.calls), tostring(c.got)) end
    if v.dump then
        parts[#parts + 1] = ('rows=%d hits=%d plausible=%s sample=%s'):format(c.count or 0, c.hits or 0,
            tostring(c.plausible == true), sample(c.rows))
    end
    if c.err then parts[#parts + 1] = 'error=' .. clip(c.err, 200) end
    parts[#parts + 1] = 'want=' .. v.want
    parts[#parts + 1] = 'str=' .. (type(c.str) == 'string' and ('"' .. clip(c.str, 1500) .. '"') or 'nil')
    print(('[pmread] %s %s %s'):format(phase, v.id, table.concat(parts, ' ')))
end

-- One variant alone (a fresh handle, its own wait), so every answer belongs to it. A same-probe is preceded by a
-- plain call with another answer (the category column's slot): a failure that returns the last value shows as sep.
-- A reader variant reads the whole list its way (D.readRows).
function D.readTrial(phase, v, ctl, fail)
    local c = { id = v.id }
    local ok, err = pcall(function()
        if v.same then c.sep = D.feCall(CTL, { 0 }, 300).int end
        if v.reader then
            local t0 = now()
            local d = D.readRows(v.reader)
            -- begin: the count answered (count= is the row count, answered= the rows that came back)
            c.begin, c.ready, c.ms = d ~= nil, d ~= nil and d.ready, now() - t0
            if d then c.str, c.rowsCount, c.calls, c.got = d.str, d.rows, d.calls, d.got end
            return
        end
        if v.bare then
            c.begin = D.fe(v.name, table.unpack(v.args or {}))
            return
        end
        local q = D.feQueue(v.name, v.args, v.get)
        c.begin, c.handle, c.get, c.again = q.begin, q.handle, q.get, v.again
        if c.begin then D.feAwait({ c }, v.ms or 500) end
    end)
    if not ok then
        if type(err) == 'table' and err.driver then error(err, 0) end
        c.err = tostring(err)
    end
    if v.dump then
        c.rows, c.count = D.parseRows(c.str)
        c.plausible, c.hits = D.plausible(c.rows)
    end
    c.match = matched(v, c, ctl, fail)
    report(phase, v, c)
    return c
end

-- The experiment in the open list: the int-only control (exactly as D.feInt reads it), then every variant; quick
-- runs the controls and the reader dumps only. Returns { [variant id] = call }.
function D.readPhase(phase, screen, quick)
    local out = {}
    local base = D.feInt(CTL, 1)
    local ev = D.S and D.S.ev or {}
    print(('[pmread] %s info screen=%s expected_rows=%d selectable=%d highlight=%s/%s ctl_feint=%s reader_movie=%s'):format(
        phase, tostring(screen), #D.visible(screen, D.ctx), #D.selectable(D.visible(screen, D.ctx)), tostring(ev.menuId),
        tostring(ev.uid), tostring(base), (D.readerState())))
    local ctl, fail, loaded = base, nil, nil
    for _, v in ipairs(probes()) do
        if not quick or v.ctl or (v.dump and not v.full) or v.id == 'ctl_missing' or v.id == 'dot_modelsel' then
            local needs = v.inject or (v.reader and v.reader.id == 'inject')
            -- One load attempt per phase: a movie that did not come in skips the rest without another 1.5 s wait.
            if needs and loaded ~= false then loaded = D.inject() end
            if needs and not loaded then
                print(('[pmread] %s %s skipped (reader movie %s)'):format(phase, v.id, (D.readerState())))
            else
                local c = D.readTrial(phase, v, ctl, fail)
                if v.ctl and c.ready and math.type(c.int) == 'integer' then ctl = c.int end
                if v.id == 'ctl_missing' then fail = c.ready and c.int or nil end
                out[v.id] = c
            end
        end
    end
    out.ctl = ctl
    if not quick then
        for _, name in ipairs(CLEANUP) do pcall(D.fe, name) end
    end
    return out
end

-- What the phases say together, one line per question, and the reader learned for Sync and Run.
function D.readSummary(phases)
    local full = phases.list137 or {}
    local missing, ctl = full.ctl_missing, full.ctl
    local stale = missing ~= nil and missing.ready == true and missing.int == ctl
    local model
    for _, v in ipairs(probes()) do
        local c = full[v.id]
        if c and c.match and (v.model == 'prefix' or v.model == 'root') then model = model or v.model end
    end
    -- Name length: the longest name that answered, and (once the model is known) the shortest of its form that did not.
    local pass, fail = nil, nil
    for _, v in ipairs(probes()) do
        local c = full[v.id]
        if c and v.len then
            if c.match then pass = math.max(pass or 0, #v.name)
            elseif model and (v.model == 'any' or v.model == model) then fail = math.min(fail or 999, #v.name) end
        end
    end
    local dotted = (full.base_parent and full.base_parent.match) or (full.dot_maxcols and full.dot_maxcols.match)
        or (full.dot_modelsel and full.dot_modelsel.match) or false
    -- The getter rules: one read per handle (int2) and the longest string GTA handed back (the cut, 63 expected).
    local strmax = 0
    for _, c in pairs(full) do
        if type(c) == 'table' and type(c.str) == 'string' and c.calls == nil then strmax = math.max(strmax, #c.str) end
    end
    local twice = full.ctl_twice
    print(('[pmread] summary model=%s dotted=%s missing_returns_ctl=%s name_ok_up_to=%s name_fails_from=%s ctl=%s second_get=%s str_max=%d'):format(
        tostring(model or 'unknown'), tostring(dotted), tostring(stale), tostring(pass), tostring(fail), tostring(ctl),
        tostring(twice and twice.int2), strmax))
    local best
    for _, phase in ipairs({ 'cat137', 'list137', 'list138' }) do
        local got = {}
        for _, r in ipairs(D.READERS) do
            local c = (phases[phase] or {})['dump_' .. r.id]
            if c then got[#got + 1] = ('%s:%d%s'):format(r.id, c.count or 0, c.plausible and '!' or '') end
            if phase == 'list137' and c and c.plausible and not best then best = r.id end
        end
        print(('[pmread] summary %s dumps %s'):format(phase, #got > 0 and table.concat(got, ' ') or 'none'))
    end
    if D.learn then
        D.learn.sfread = best
        D.saveLearn()
    end
    print(('[pmread] summary learned=%s reader_url=%s (Sync and Run use it; nil: they keep the leave-question reads)'):format(
        tostring(best), tostring(D.learn and D.learn.dxrurl)))
    return best
end

-- The streamed reader movie is released with the resource, so a restart of it can request the movie again.
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and streamedHandle then
        pcall(SetScaleformMovieAsNoLongerNeeded, streamedHandle)
        streamedHandle = nil
    end
end)

-- The reader movie is requested on the first Settings open (every session starts there), so it is in GTA's store
-- before a settings session needs it; a player who never opens Settings never loads it.
if PM and PM.RegisterScreen then
    local warmed = false
    PM.RegisterScreen('settings', {
        enter = function()
            if warmed or not (Config.Settings and Config.Settings.FrontendDriver) then return end
            warmed = true
            D.prewarm()
        end,
    })
end
