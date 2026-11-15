-- Blip names as GTA itself has them (the text its map legend shows), read while the map screen shows. No native reads a
-- blip's name, but ADD_TEXT_COMPONENT_SUBSTRING_BLIP_NAME composes it into a scaleform text param with the legend's own
-- getter, and a string's concat hands that param back: prefix .. name, read with the string getter (63 bytes,
-- client/driver/read.lua). The echo is learned per visit, cheapest first: our own copy of a vanilla movie (no GTA menu
-- needed), then GTA's menu movie, then the reader movie in it. Research: maplegend/names.md, plan.md section 3.
local D = PMDrv
local Cfg = Config.Map or {}
local ON = Cfg.GameNames ~= false
local MOVIE = type(Cfg.NameMovie) == 'string' and Cfg.NameMovie or 'INSTRUCTIONAL_BUTTONS'
local DRAW = Cfg.NameMovieDraw == true -- set from diagnostic N1: true when an undrawn movie never answers
local BATCH = 8 -- calls per batch: GTA has 20 return-value slots in all, each held up to 20 frames
local WAIT_MS = 700 -- 20 frames down to 30 fps: a late answer never outlives its batch and holds no slot
local REFRESH_MS = 30000 -- a shown blip is read again after this (renames, reused handles of the same sprite)
local LEARN_MS = 4000 -- without our movie the echo needs GTA's map page in (fullmap.lua FrontReady)
local MARK = 'pmEcho' -- the calibration literal: an echo's answer ends with it
local MAX_PREFIX = 24

local ECHOES = {
    { id = 'std', name = 'TIMELINE._name.concat', movie = true }, -- _level0._name of our vanilla movie copy
    { id = 'stdt', name = 'TIMELINE._target.concat', movie = true },
    { id = 'name', name = 'TIMELINE._name.concat' }, -- GTA's menu movie, under the full map
    { id = 'target', name = 'TIMELINE._target.concat' },
    { id = 'dbg', name = 'dbgID.concat' }, -- 'PAUSE_MENU_SP_CONTENT', set by the content object's constructor
    { id = 'dxr', name = 'DXR_E', args = { 'TIMELINE.dxr._name', 'concat' }, inject = true }, -- the reader: 'dxr'
}

local cache = {} -- [blip] = { text = name or false, s = sprite, c = colour, at = GetGameTimer() of the read }
local queue, head, queued = {}, 1, {}
local echo, prefix, movie, movieDead, loading = nil, nil, nil, false, nil
local fails, visits, token, hold = 0, 0, 0, false
local dirty, flagged = false, 0

PM.Map = PM.Map or {}

-- PM.Debug, and the temporary diagnostics' listener when one is set (client/map/diag.lua).
local function log(fmt, ...)
    PM.Debug(fmt, ...)
    if PM.Map.Trace then PM.Map.Trace(fmt, ...) end
end

local function colourOf(blip) return select(2, PMMap.colourHex(GetBlipColour(blip))) end

-- GTA's name of a place blip from the cache (nil: not read yet, or none) and a read queued when it is missing, of
-- another sprite or colour (a reused handle) or older than REFRESH_MS. colour: the id PMMap.colourHex gives.
function PM.Map.GameName(blip, sprite, colour)
    if not ON then return nil end
    local c = cache[blip]
    if not queued[blip] and (not c or c.s ~= sprite or c.c ~= colour or GetGameTimer() - c.at > REFRESH_MS) then
        queued[blip] = true
        queue[#queue + 1] = blip
    end
    return c and c.text or nil
end

function PM.Map.PruneNames()
    for blip in pairs(cache) do
        if not DoesBlipExist(blip) then cache[blip] = nil end
    end
    for blip in pairs(queued) do
        if not DoesBlipExist(blip) then queued[blip] = nil end
    end
end

-- What the reads stand on (diagnostics): the echo, its prefix, the cache and queue sizes, failed visits.
function PM.Map.NamesInfo()
    local n = 0
    for _ in pairs(cache) do n = n + 1 end
    return { on = ON, echo = echo and echo.id, prefix = prefix, cached = n, queued = #queue - head + 1, fails = fails,
        movie = movie ~= nil, movieDead = movieDead, draw = DRAW, hold = hold, cache = cache }
end

-- Holds the reads (diagnostics measure GTA's return-value slots without them).
function PM.Map.NamesHold(on) hold = on == true end

local function take(n)
    local out = {}
    while #out < n and head <= #queue do
        local blip = queue[head]
        head = head + 1
        if queued[blip] then
            queued[blip] = nil
            if DoesBlipExist(blip) then out[#out + 1] = blip end
        end
    end
    if head > #queue then queue, head = {}, 1 end
    return out
end

-- Our vanilla movie must be drawn for its calls to run (diagnostic N1 decides; zero size, zero alpha).
local function tick()
    if DRAW and movie then DrawScaleformMovie(movie, 0.5, 0.5, 0.001, 0.001, 255, 255, 255, 0, 0) end
end

-- One echo call: the method's own args, then the text param ({ blip = h } or { text = s }).
local function ask(e, param)
    local args = {}
    for i, v in ipairs(e.args or {}) do args[i] = v end
    args[#args + 1] = param
    if e.movie then return D.mvQueue(movie, e.name, args, 'str') end
    return D.feQueue(e.name, args, 'str')
end

local function frontReady() return PM.Map.FrontReady ~= nil and PM.Map.FrontReady() end

-- The echo of this visit: our movie, else GTA's menu movie, else the reader in it; the shortest prefix wins.
local function learn()
    echo, prefix = nil, nil
    for pass = 1, 3 do
        local calls = {}
        for _, e in ipairs(ECHOES) do
            local fits
            if pass == 1 then fits = e.movie and movie ~= nil and not movieDead
            elseif pass == 2 then fits = not e.movie and not e.inject and frontReady()
            else fits = e.inject == true and frontReady() and D.readerState() ~= 'broken' and D.inject() end
            if fits then
                local c = ask(e, { text = MARK })
                c.echo = e
                calls[#calls + 1] = c
            end
        end
        D.feAwait(calls, WAIT_MS, tick)
        for _, c in ipairs(calls) do
            local s = c.ready == true and type(c.str) == 'string' and c.str or ''
            if #s >= #MARK and s:sub(-#MARK) == MARK and #s - #MARK <= MAX_PREFIX then
                local p = s:sub(1, #s - #MARK)
                if not prefix or #p < #prefix then echo, prefix = c.echo, p end
            end
        end
        if pass == 1 and #calls > 0 and not echo then movieDead = true end -- never asked again this resource start
        if echo then
            log('map names: echo %s, prefix "%s"', echo.id, prefix)
            return true
        end
    end
    return false
end

-- One batch: queued in one frame, answered in the next ones. Returns how many answered.
local function readBatch(blips)
    local calls, now = {}, GetGameTimer()
    for _, blip in ipairs(blips) do
        local c = ask(echo, { blip = blip })
        c.blip, c.s, c.c = blip, GetBlipSprite(blip), colourOf(blip)
        calls[#calls + 1] = c
    end
    D.feAwait(calls, WAIT_MS, tick)
    local answered = 0
    for _, c in ipairs(calls) do
        local text = nil
        if c.ready == true then text = PMMap.echoName(c.str, prefix, D.STR_CAP) end
        if text ~= nil then
            answered = answered + 1
            local old = cache[c.blip]
            if not old or old.text ~= text then dirty = true end
            cache[c.blip] = { text = text, s = c.s, c = c.c, at = now }
        end
    end
    return answered
end

-- A changed name makes the next feed tick sweep and resend (blips.lua); at most every 500 ms, and once the queue drains.
local function flag(drained)
    if dirty and (drained or GetGameTimer() - flagged >= 500) then
        dirty, flagged = false, GetGameTimer()
        PM.Map.NamesChanged()
    end
end

local function run(my)
    local function live() return token == my and PM.Map.BlipsShown() end
    if not movie and not movieDead then
        -- A request of an earlier visit that was left before it loaded is waited for, not made again.
        loading = loading or RequestScaleformMovie(MOVIE)
        local stop = GetGameTimer() + 1500
        while live() and not HasScaleformMovieLoaded(loading) and GetGameTimer() < stop do Wait(0) end
        if HasScaleformMovieLoaded(loading) then movie, loading = loading, nil
        elseif live() then movieDead = true end
    end
    local stop, learned = GetGameTimer() + LEARN_MS, false
    while live() and not learned do
        learned = learn()
        if learned or GetGameTimer() > stop then break end
        Wait(250)
    end
    if not learned then
        if token == my then
            fails = fails + 1
            log('map names: no echo answered (%d)', fails)
        end
        return
    end
    fails = 0
    local silent = 0
    while live() do
        local blips = not hold and take(BATCH) or {}
        if #blips == 0 then
            flag(true)
            Wait(250)
        else
            silent = readBatch(blips) == 0 and silent + 1 or 0
            flag(false)
            -- The echo stopped answering (GTA rebuilt its menu): learn it again, or stop for this visit.
            if silent >= 3 then
                log('map names: echo %s went silent', echo and echo.id or '-')
                if not learn() then return end
                silent = 0
            end
        end
    end
end

PM.RegisterScreen('map', {
    enter = function()
        token = token + 1
        visits = visits + 1
        -- After two visits with no echo, try again only every third visit (no permanent switch-off).
        if not ON or (fails >= 2 and visits % 3 ~= 0) then return end
        local my = token
        CreateThread(function() run(my) end)
    end,
    leave = function()
        token = token + 1
        queue, head, queued = {}, 1, {}
    end,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and (movie or loading) then pcall(SetScaleformMovieAsNoLongerNeeded, movie or loading) end
end)
