local id = DL.require('fw/detect')()
local adapter = DL.require('fw/' .. id).server

local fw = { id = id }

-- Who plays which character, read once per player: qb/qbx hand over the whole character on every lookup.
local bySource, byCid = {}, {}

local function remember(source, cid)
    local old = bySource[source]
    if old and old ~= cid and byCid[old] == source then byCid[old] = nil end
    bySource[source], byCid[cid] = cid, source
end

local function forget(source)
    local cid = bySource[source]
    if cid and byCid[cid] == source then byCid[cid] = nil end
    bySource[source] = nil
end

-- Character id: citizenid, ESX identifier, ND character id or license. Nil (still choosing) is never kept.
function fw.citizenId(source)
    source = tonumber(source)
    if not source then return nil end
    local cid = bySource[source]
    if cid then return cid end
    cid = adapter.citizenId(source)
    if cid then remember(source, cid) end
    return cid
end
fw.playerName = adapter.playerName

-- Job and duty per player: on qb/qbx each lookup copies the whole character across resources, and role checks ask
-- for them for every player in every sweep. Where the framework announces loads, job and duty changes (qb, qbx)
-- the kept value is written from those events and never expires: one lookup per player, the first time it is
-- asked. Elsewhere it is read again after a few seconds. A drop or unload forgets it.
local watched = adapter.watchJobs ~= nil
local JOB_TTL = 5000
local jobs = {}

local function read(source)
    if adapter.jobState then return adapter.jobState(source) end
    local job = adapter.job(source)
    return { job = job, duty = job ~= nil and adapter.onDuty(source) == true }
end

local function jobEntry(source)
    source = tonumber(source)
    if not source then return nil end
    local entry = jobs[source]
    if entry and (watched or GetGameTimer() - entry.at < JOB_TTL) then return entry end
    local state = read(source)
    if not state then return nil end -- still choosing a character: nothing kept, asked again next time
    entry = { at = GetGameTimer(), job = state.job, duty = state.duty == true }
    jobs[source] = entry
    return entry
end

local function forgetJob(source)
    source = tonumber(source)
    if source then jobs[source] = nil end
end
fw.forgetJob = forgetJob

-- With job events the watcher runs the job-change callbacks itself, after it wrote the new job: the scheduler calls
-- the handlers of one event in no fixed order, so a handler of its own could still read the old one. Each callback
-- gets its own thread, as a handler would.
local jobChanged = {}

if watched then
    adapter.watchJobs(function(source, state)
        source = tonumber(source)
        if source then jobs[source] = { at = GetGameTimer(), job = state.job, duty = state.duty == true } end
    end, function(source, onDuty)
        source = tonumber(source)
        local entry = source and jobs[source]
        if entry then entry.duty = onDuty end
    end, function(source)
        for _, cb in ipairs(jobChanged) do Citizen.CreateThreadNow(function() cb(source) end) end
    end)
end

-- { name, grade, label } or nil.
function fw.job(source)
    local job = (jobEntry(source) or {}).job
    return job and { name = job.name, grade = job.grade, label = job.label }
end

-- { name, grade, label } or nil; frameworks without gangs return nil.
fw.gang = adapter.gang

-- Accounts are 'cash' and 'bank'.
function fw.money(source, account)
    return tonumber(adapter.money(source, account)) or 0
end

function fw.removeMoney(source, account, amount, reason)
    if amount <= 0 then return true end
    if fw.money(source, account) < amount then return false end
    return adapter.removeMoney(source, account, amount, reason) == true
end

-- Online and offline characters by name or id: { { citizenid, name } }.
function fw.searchCharacters(query, limit)
    query = DL.util.trim(query, 64)
    if not query or #query < 2 then return {} end
    return adapter.searchCharacters(query, math.min(limit or 20, 50))
end

-- One character, online or not: { citizenid, name } or nil.
function fw.character(citizenid)
    if type(citizenid) ~= 'string' or citizenid == '' then return nil end
    return adapter.character(citizenid)
end

function fw.addMoney(source, account, amount, reason)
    if amount <= 0 then return true end
    return adapter.addMoney(source, account, amount, reason) == true
end

-- Online source or offline citizen id; grade falls back to the lowest that exists.
function fw.setJob(target, job, grade)
    if type(job) ~= 'string' or job == '' then return false end
    local ok = adapter.setJob(target, job, math.floor(tonumber(grade) or 0)) == true
    if type(target) == 'number' then forgetJob(target) end
    return ok
end

-- Job definitions: { [name] = { label, grades = { [level] = { name, payment, isboss } } } }.
fw.jobs = adapter.jobs

-- Players of a job on duty (frameworks without duty count everyone in the job).
function fw.dutyCount(job)
    -- only the first value: qbx's GetDutyCountJob also returns the players, which tonumber took as its base and threw
    local count = adapter.dutyCount(job)
    return tonumber(count) or 0
end

function fw.onDuty(source)
    local entry = jobEntry(source)
    return entry ~= nil and entry.duty == true
end

-- Owned vehicles: { plate, model, owner }.
function fw.ownedVehicle(plate)
    plate = tostring(plate or ''):upper():match('^%s*(.-)%s*$')
    return plate ~= '' and adapter.ownedVehicle(plate) or nil
end

fw.vehiclesOf = adapter.vehiclesOf

function fw.searchVehicles(text, limit, offset)
    text = DL.util.trim(text, 32)
    if not text then return {}, 0 end
    return adapter.searchVehicles(text, math.min(limit or 20, 100), offset or 0)
end

function fw.isAdmin(source)
    return IsPlayerAceAllowed(tostring(source), 'daddy.admin') or adapter.isAdmin(source) == true
end

-- Runs cb(source) when a character finishes loading.
-- Without job events the kept job is dropped first, so cb already reads the new character's job (with them the
-- watcher, registered before any cb, has written it already).
function fw.onLoaded(cb)
    adapter.onLoaded(function(source, ...)
        if not watched then forgetJob(source) end
        return cb(source, ...)
    end)
end

-- The online player playing a character, or nil.
function fw.sourceOf(citizenid)
    local source = citizenid and byCid[citizenid]
    if source and bySource[source] == citizenid then return source end
    return nil
end

-- Runs cb(source) on logout and on disconnect.
function fw.onUnloaded(cb)
    adapter.onUnloaded(cb)
    AddEventHandler('playerDropped', function() cb(source) end)
end

-- Runs cb(source) after a character's job changes (or its duty).
-- Without job events the kept job is dropped first, so cb reads the new one.
function fw.onJobChange(cb)
    if watched then
        jobChanged[#jobChanged + 1] = cb
        return
    end
    adapter.onJobChange(function(source, ...)
        if not watched then forgetJob(source) end
        return cb(source, ...)
    end)
end

-- Runs cb(source) after a character's cash or bank changes (read the balance with fw.money).
fw.onMoneyChange = adapter.onMoneyChange

-- Framework-level usable item, for inventories that defer to it.
fw.registerUsable = adapter.registerUsable

fw.onLoaded(function(source)
    source = tonumber(source)
    if not source then return end
    forget(source)
    fw.citizenId(source)
end)

adapter.onUnloaded(forgetJob)
AddEventHandler('playerDropped', function() forgetJob(source) end)

-- Forgotten a tick later, so the resource's own unload handlers still know who left; a new character loaded meanwhile stays.
fw.onUnloaded(function(source)
    source = tonumber(source)
    local cid = source and bySource[source]
    if cid then SetTimeout(0, function() if bySource[source] == cid then forget(source) end end) end
end)

-- Players already in at start, then every minute anyone a load event missed; players who left are dropped.
CreateThread(function()
    while true do
        for i, id in ipairs(GetPlayers()) do
            local source = tonumber(id)
            if source and not bySource[source] then fw.citizenId(source) end
            if i % 25 == 0 then Wait(0) end
        end
        for source in pairs(bySource) do
            if not GetPlayerName(source) then forget(source) end
        end
        Wait(60000)
    end
end)

return fw
