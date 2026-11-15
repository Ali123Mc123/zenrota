-- Club logos' pictures on the client: each revision comes once (affairs:clubLogo answers, the bytes follow on the latent
-- event daddy_college:clubs:logo) and stays for the session, 32 at most. College's screens ask through the NUI
-- ('clubs:logo'), the Student Phone and the Student Tablet through the ClubLogo export, the world's stands ClubLogos.get.
if not Core.ModuleEnabled('affairs') then return end

ClubLogos = {}
local kept, order, waiting, refused = {}, {}, {}, {}
local busy = false

local function keep(key, data)
    if not kept[key] then order[#order + 1] = key end
    kept[key] = data
    while #order > 32 do kept[table.remove(order, 1)] = nil end
end

RegisterNetEvent('daddy_college:clubs:logo', function(key, data)
    if type(key) ~= 'string' or type(data) ~= 'string' or not data:find('^data:image/') then return end
    keep(key, data)
    local pending = waiting[key]
    if not pending then return end
    waiting[key] = nil
    pending:resolve(true)
end)

-- '<club>:<rev>' for a stored picture, '<club>:p<at>' for one waiting for a moderator (as the server names them).
local function keyOf(clubId, rev, pending) return pending and ('%d:p%d'):format(clubId, pending) or ('%d:%d'):format(clubId, rev) end

-- The answer says which picture comes (a newer revision than asked, maybe); its bytes follow or came first.
local function ask(clubId, rev, pending, staff, key)
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:affairs:clubLogo', false, { clubId = clubId, rev = rev, pending = pending ~= nil, staff = staff }))
    if not result.ok then return nil, result.error end
    local got = type(result.key) == 'string' and result.key or key
    if not kept[got] then
        local p = promise.new()
        waiting[got] = p
        SetTimeout(20000, function()
            if waiting[got] ~= p then return end
            waiting[got] = nil
            p:resolve(false)
        end)
        if not Citizen.Await(p) then return nil, 'timeout' end
    end
    local data = kept[got]
    if data and got ~= key then keep(key, data) end
    return data
end

-- Refusals that stay a while (asked again after a minute); anything else may be tried again soon.
local LASTING = { logo_gone = true, logo_hidden = true, logo_off = true, timeout = true }

-- A club logo's data URL, nil when it may not be seen. Blocks the calling thread; asked one at a time, as the server
-- sends one at a time. opts: pending = the waiting one's time (logoInfo.waiting), staff = asked from the staff tablet.
function ClubLogos.get(clubId, rev, opts)
    clubId, rev, opts = math.floor(tonumber(clubId) or 0), math.floor(tonumber(rev) or 0), type(opts) == 'table' and opts or {}
    local pending = (tonumber(opts.pending) or 0) > 0 and math.floor(opts.pending) or nil
    if clubId < 1 or (rev < 1 and not pending) then return nil end
    local key = keyOf(clubId, rev, pending)
    if kept[key] then return kept[key] end
    if (refused[key] or 0) > GetGameTimer() then return nil end
    while busy do Wait(50) end
    if kept[key] then return kept[key] end
    busy = true
    local done, data, err = pcall(ask, clubId, rev, pending, opts.staff == true, key)
    busy = false
    if done and data then return data end
    refused[key] = GetGameTimer() + ((done and LASTING[err]) and 60000 or 5000)
    return nil
end

-- Another resource's screen: cb(data URL or nil) a moment later; the export never blocks its caller.
exports('ClubLogo', function(clubId, rev, cb, opts)
    if not cb then return end
    CreateThread(function()
        local data = ClubLogos.get(clubId, rev, opts)
        pcall(cb, data)
    end)
end)

-- College's own screens (the brochure, the ledger, the staff tablet): { clubId, rev, pending, staff } -> { ok, src }.
Core.Nui.SafeCallback('clubs:logo', function(data)
    local src = ClubLogos.get(data.clubId, data.rev, { pending = data.pending, staff = data.staff == true })
    return src and { ok = true, src = src } or { ok = false, error = 'logo_gone' }
end, 60000)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for key, pending in pairs(waiting) do
        waiting[key] = nil
        pending:resolve(false)
    end
end)
