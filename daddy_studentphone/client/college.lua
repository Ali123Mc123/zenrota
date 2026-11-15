-- College's moments on the client, handed to the page: lesson cards, the countdown outside the campus, an expired
-- permit, detention and the end of an exam. The page shows them in the island; a card's places become waypoints from the phone.
local RESOURCE = GetCurrentResourceName()
local places = {} -- the last card's places: classroom and teacher, each { coords = { x, y, z } }

local function send(kind, data) SendNUIMessage({ action = 'college', kind = kind, data = data }) end

local function line(card, id)
    for _, l in ipairs(type(card.lines) == 'table' and card.lines or {}) do
        if l.id == id then return l.value or '' end
    end
    return ''
end

-- Bell-only packets are for the rest of the school; cards go to the roster and the teacher. College names a teacher's
-- call '<session>:summon:<n>'.
RegisterNetEvent('daddy_college:announce', function(card)
    if type(card) ~= 'table' or card.kind ~= 'lesson' or card.bellOnly then return end
    places = { classroom = card.target, teacher = card.teacherTarget }
    send('card', {
        id = tostring(card.announcementId or ''), state = card.state, title = card.title or '',
        summon = tostring(card.announcementId or ''):find(':summon:', 1, true) ~= nil,
        lesson = line(card, 'lesson'), teacher = line(card, 'teacher'), room = line(card, 'room'),
        place = card.teacherTarget and 'teacher' or card.target and 'classroom' or '',
    })
end)

local function countdown(data)
    return type(data) == 'table' and { total = tonumber(data.total) or 0, remaining = tonumber(data.remaining) or 0 } or false
end

-- Outside the campus without a permit, and the grace after a permit ran out; nil from College ends them.
RegisterNetEvent('daddy_college:security:outOfBounds', function(data) send('outside', countdown(data)) end)
RegisterNetEvent('daddy_college:security:grace', function(data) send('grace', countdown(data)) end)

local function detention(data)
    if type(data) ~= 'table' then return end
    local out = countdown(data)
    out.reason, out.hasTask, out.nextIn = data.reason or '', data.task ~= nil, tonumber(data.nextIn) or 0
    -- Public detention counts jobs, not time (Faz 3): the jobs done and set, and the job in hand with its area.
    out.mode, out.jobsTotal, out.jobsDone, out.pieces = data.mode or 'room', tonumber(data.jobsTotal) or 0, tonumber(data.tasksDone) or 0, tonumber(data.pieces) or 0
    out.job = type(data.job) == 'table' and { kind = data.job.kind or '', zone = data.job.zone or '' } or false
    send('detention', out)
end

RegisterNetEvent('daddy_college:discipline:begin', detention)
RegisterNetEvent('daddy_college:discipline:sync', detention)
RegisterNetEvent('daddy_college:discipline:release', function() send('detention', false) end)

-- Outside the detention area: the countdown back (nothing in it means back inside).
RegisterNetEvent('daddy_college:discipline:leave', function(data)
    local seconds = type(data) == 'table' and tonumber(data.seconds)
    send('detentionLeave', seconds and { total = seconds, remaining = seconds } or false)
    if seconds then TriggerServerEvent(RESOURCE .. ':collegeNotice', 'detention_leave', {}) end
end)

-- Lesson quizzes: a question asked to the player or to someone in their lesson, a station turn, the result, the end.
-- The page shows the sheet and the island; only the asked student gets kept notifications (the question, its result).
local paperRound -- the last round asked on the paper card (no phone in the pocket): its result is not kept either
RegisterNetEvent('daddy_college:lessonquiz:round', function(p)
    if type(p) ~= 'table' then return end
    send('quiz', p)
    if p.state == 'open' and p.paper then paperRound = p.roundId end
    if p.paper or (p.roundId ~= nil and p.roundId == paperRound) then return end
    if p.state == 'open' and p.mine and not p.world and p.kind ~= 'activity' then TriggerServerEvent(RESOURCE .. ':collegeNotice', 'quiz_open', { lesson = p.lesson }) end
    if p.state == 'world' and p.turn then TriggerServerEvent(RESOURCE .. ':collegeNotice', 'quiz_turn', { station = p.station }) end
    if p.state == 'result' and p.mine and p.name then
        local reward = type(p.reward) == 'table' and p.reward or {}
        TriggerServerEvent(RESOURCE .. ':collegeNotice', 'quiz_result', { lesson = p.lesson, outcome = p.outcome, class = reward.class, answerer = reward.answerer })
    end
end)

-- The lesson's attendance code: opened, refreshed, closed, or the student's own mark moved (never the code itself). The
-- page brings up its sheet; with the phone away a kept notification says it opened. A student on paper has no phone.
RegisterNetEvent('daddy_college:attendcode:state', function(p)
    if type(p) ~= 'table' or p.paper then return end
    send('attend', p)
    if p.open and p.notice and not PhoneUI.open then TriggerServerEvent(RESOURCE .. ':collegeNotice', 'attend_open', { lesson = p.lesson }) end
end)

-- Academics: an XP slip for the open app and a level reached as a notification (a level College already wrote a Mail
-- letter for needs none). A class year move is a Mail letter; College's paper letter is for students without a phone.
RegisterNetEvent('daddy_college:academics:xp', function(d) if type(d) == 'table' then send('xp', d) end end)
RegisterNetEvent('daddy_college:academics:level', function(d)
    if type(d) ~= 'table' then return end
    send('level', d)
    if not d.mailed then TriggerServerEvent(RESOURCE .. ':collegeNotice', 'level', { lesson = d.lesson, level = d.level }) end
end)

-- The entrance scan found something, or security took it.
RegisterNetEvent('daddy_college:scan:notice', function(d)
    if type(d) ~= 'table' then return end
    send('scan', d)
    TriggerServerEvent(RESOURCE .. ':collegeNotice', d.result == 'taken' and 'scan_taken' or 'scan_hit', d)
end)

-- One of the player's wish cards changed (approved, taken down, fell off): the list reads again, the server tells.
RegisterNetEvent('daddy_college:wishes:mine', function(d)
    if type(d) ~= 'table' or type(d.key) ~= 'string' then return end
    send('wishes', { key = d.key })
    TriggerServerEvent(RESOURCE .. ':collegeNotice', 'wish', { key = d.key, args = type(d.args) == 'table' and d.args or {} })
end)

-- Club tables: a request made at the table an officer stands at (the page reads again; College told them in game),
-- and an interview call for the player (a kept notification).
RegisterNetEvent('daddy_college:clubs:applied', function(d) if type(d) == 'table' then send('clubApplied', { club = d.club, name = d.name }) end end)
RegisterNetEvent('daddy_college:clubs:interview', function(d)
    if type(d) ~= 'table' then return end
    send('clubInterview', d)
    TriggerServerEvent(RESOURCE .. ':collegeNotice', 'club_interview', { club = d.club, when = d.when, place = d.place })
end)

-- A new work order for janitors (Campus Life), or one still waiting (remind).
RegisterNetEvent('daddy_campuslife:janitor:dispatch', function(view)
    if type(view) ~= 'table' then return end
    send('janitor', { id = view.id, kind = view.kind, label = view.label })
    TriggerServerEvent(RESOURCE .. ':collegeNotice', 'janitor', { kind = view.kind, label = view.label, remind = view.remind == true })
end)

-- A station's place as the game's waypoint (College sends it with a turn); the page's button asks for it again.
local station
RegisterNetEvent('daddy_college:practicals:waypoint', function(d) station = type(d) == 'table' and d.coords or nil end)
RegisterNUICallback('phone:stationWaypoint', function(_, cb)
    if type(station) == 'table' then SetNewWaypoint(station.x + 0.0, station.y + 0.0) end
    cb({ ok = type(station) == 'table' })
end)

-- Time is up or the teacher ended the session: the exam leaves the island before the server says so.
RegisterNetEvent('daddy_college:exam:sessionEnded', function() send('exam', false) end)

-- Campus dispatch (C4.1): College sends its alerts to security; their phone lists them and offers the waypoint.
RegisterNetEvent('daddy_college:security:dispatch', function(alert)
    if type(alert) == 'table' then SendNUIMessage({ action = 'college', kind = 'dispatch', data = alert }) end
end)

-- The attendance notebook (Class app): the phone goes away and College's own placement puts it on a desk; College
-- checks the spot and the lesson. Without the notebook (turned off in College) the player is told.
RegisterNUICallback('phone:placeSheet', function(data, cb)
    local res, id = DL.product.resource('college'), tonumber(data.id)
    cb({ ok = res ~= nil and id ~= nil })
    if not res or not id then return end
    PhoneUI.close()
    SetTimeout(300, function()
        local ok, placing = pcall(function() return exports[res]:PlaceSheet(id) end)
        if not ok or not placing then lib.notify({ description = DL.locale.t('errors.module_off'), type = 'error' }) end
    end)
end)

-- A club's logo for the page from College's client, which downloads each revision once for every screen: { ok, src }.
RegisterNUICallback('phone:clubLogo', function(data, cb)
    local res = DL.product.resource('college')
    local asked = res and pcall(function()
        exports[res]:ClubLogo(tonumber(data.clubId) or 0, tonumber(data.rev) or 0, function(src)
            cb(type(src) == 'string' and { ok = true, src = src } or { ok = false })
        end, { pending = tonumber(data.pending) or 0 })
    end)
    if not asked then cb({ ok = false }) end
end)

-- A card's place as the game's waypoint: the classroom, or where the teacher who called stands.
RegisterNUICallback('phone:waypoint', function(data, cb)
    local place = places[data.place]
    local c = type(place) == 'table' and type(place.coords) == 'table' and place.coords
    if c then SetNewWaypoint(c.x + 0.0, c.y + 0.0) end
    cb({ ok = c and true or false })
end)
