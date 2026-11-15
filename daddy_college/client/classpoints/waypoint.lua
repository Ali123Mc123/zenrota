-- Marking a classroom or the teacher from a lesson card.
if not Core.ModuleEnabled('classpoints') then return end

local Lessons = Core.Lessons
local t = DL.locale.t

-- target: { kind 'classroom'|'teacher', label, name, coords {x,y,z} }
function Lessons.mark(target)
    local c = type(target) == 'table' and type(target.coords) == 'table' and target.coords
    local x, y, z = c and tonumber(c.x), c and tonumber(c.y), c and tonumber(c.z)
    if not x or not y or not z then return Core.NotifyL('classpoints.waypoint_none', 'error') end
    local label = target.kind == 'teacher' and t('classpoints.teacher_marker_fmt', target.name or target.label or t('classpoints.teacher_fallback'))
        or target.label or t('classpoints.default_room')
    Core.Waypoint.mark(label, { x = x, y = y, z = z - 1.0 }, nil, false, target.kind)
end
