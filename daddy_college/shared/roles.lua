-- College roles from job names. The server decides; the client only shows what it is told.
Roles = {}

local function lower(value) return tostring(value or ''):lower() end

local function inList(list, name)
    for _, value in ipairs(list or {}) do
        if lower(value) == name then return true end
    end
    return false
end

-- job: { name, grade } with grade a number or { level }.
local function grade(job)
    return type(job.grade) == 'table' and (tonumber(job.grade.level) or 0) or tonumber(job.grade) or 0
end
Roles.grade = function(job) return job and grade(job) or 0 end

function Roles.isStudentJob(name) return inList(Config.Roles.Students, lower(name)) end
function Roles.isPrincipalJob(name) return inList(Config.Roles.Principals, lower(name)) end
function Roles.isSecurityJob(name) return inList(Config.Roles.Security, lower(name)) end
function Roles.isCanteenJob(name) return inList(Config.Roles.Canteen, lower(name)) end

function Roles.isTeacher(job)
    if not job then return false end
    local name = lower(job.name)
    if Roles.isPrincipalJob(name) then return true end
    local minimum = Config.Roles.Teachers[name]
    return minimum ~= nil and grade(job) >= minimum
end

-- The guidance counselor; nil when the server names none (the principal does the job then).
function Roles.isCounselor(job)
    local list = Config.Roles.Counselors or {}
    if next(list) == nil then return nil end
    local minimum = job and list[lower(job.name)]
    return minimum ~= nil and grade(job) >= minimum
end

-- Any job the school hires into.
function Roles.isSchoolJob(name)
    name = lower(name)
    if name == '' or name == lower(Config.Roles.Unemployed) then return false end
    if Config.Roles.Teachers[name] ~= nil then return true end
    for _, list in ipairs({ Config.Roles.Students, Config.Roles.Principals, Config.Roles.Security, Config.Roles.Canteen, Config.Roles.Drivers, Config.Roles.Janitors }) do
        if inList(list, name) then return true end
    end
    return false
end

-- Announcement audiences: all, school, students, teachers.
function Roles.matchesAudience(job, scope)
    if scope == 'all' then return true end
    if not job then return false end
    if scope == 'school' then return Roles.isSchoolJob(job.name) end
    if scope == 'students' then return Roles.isStudentJob(job.name) end
    if scope == 'teachers' then return Roles.isTeacher(job) end
    return false
end

function Roles.studentJobs() return Config.Roles.Students end
