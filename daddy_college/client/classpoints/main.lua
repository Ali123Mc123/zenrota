-- Lessons on the client: panels, commands, the bell and the [G]/[H] keys on lesson cards.
if not Core.ModuleEnabled('classpoints') then return end

local cfg = Config.ClassPoints
local Lessons = {}
Core.Lessons = Lessons

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:classpoints:' .. name, false, data))
end

-- Lessons, attendance and the timetable all live in the staff tablet.
local function tablet(app) return function() if Core.OpenTablet then Core.OpenTablet(app) end end end

local commands = cfg.Commands
Core.Command(commands.create, tablet('lesson'))
Core.Command(commands.attendance, tablet('lesson'))
Core.Command(commands.schedule, tablet('schedule'))

-- At the Student Affairs desk: the house standings (and the discipline table).
Core.Affairs.RegisterAction('classpoints:board', { order = 30, icon = 'fa-solid fa-ranking-star', label = 'classpoints.target_board', panel = true,
    visible = function(context) return context.isStudent == true end })
Core.Command(commands.start, function() Core.HandleResult(call('startLesson'), 'classpoints') end)
Core.Command(commands.finish, function() Core.HandleResult(call('endLesson'), 'classpoints') end)

-- NUI bridge ---------------------------------------------------------------------------------------

local function bridge(nuiName, name, after)
    Core.Nui.SafeCallback(nuiName, function(data)
        local result = call(name, data)
        if after then after(result, data) elseif not result.ok then Core.HandleResult(result, 'classpoints') end
        return result
    end)
end

bridge('classpoints:createLesson', 'createLesson', function(result, data)
    if result.ok and not data.tabletContext then Core.Nui.Close() elseif not result.ok then Core.HandleResult(result, 'classpoints') end
end)
bridge('classpoints:getCreatePanel', 'getCreatePanel')
bridge('classpoints:markAttendance', 'markAttendance')
bridge('classpoints:addGuest', 'addGuest')
bridge('classpoints:guestCandidates', 'guestCandidates')
bridge('classpoints:getSchedule', 'getSchedule')
bridge('classpoints:saveScheduleEntry', 'saveScheduleEntry')
bridge('classpoints:deleteScheduleEntry', 'deleteScheduleEntry')
bridge('classpoints:announceFromSchedule', 'announceFromSchedule')

-- Bell and lesson cards ----------------------------------------------------------------------------

local keyToken = 0

-- While the card is on screen, [G] marks the classroom and [H] the teacher; a newer card takes over.
local function armKeys(room, teacher)
    keyToken = keyToken + 1
    local token = keyToken
    if not room and not teacher then return end
    local deadline = GetGameTimer() + cfg.AnnounceDuration
    CreateThread(function()
        while token == keyToken and GetGameTimer() < deadline do
            if not Core.Nui.IsOpen() then
                if room and IsControlJustReleased(0, cfg.Waypoint.Key) then return Lessons.mark(room) end
                if teacher and IsControlJustReleased(0, cfg.Waypoint.SummonKey) then return Lessons.mark(teacher) end
            end
            Wait(0)
        end
    end)
end

-- The core shows the card; this adds the bell and the marker keys. Bell-only packets arm no keys.
RegisterNetEvent('daddy_college:announce', function(data)
    if type(data) ~= 'table' or data.kind ~= 'lesson' then return end
    if type(data.bell) == 'table' and Core.OnCampus() then SendNUIMessage({ action = 'lessonBell', data = data.bell }) end
    if cfg.Waypoint.Enabled and not data.bellOnly then armKeys(data.target, data.teacherTarget) end
end)

Core.Nui.SafeCallback('classpoints:markTarget', function(data)
    if not Core.IsSchoolMember() or type(data.target) ~= 'table' then return { ok = false } end
    data.target.kind = data.kind or data.target.kind
    Lessons.mark(data.target)
    return { ok = true }
end)
