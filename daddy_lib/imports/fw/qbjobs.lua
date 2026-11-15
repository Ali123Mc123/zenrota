-- Job and duty for qb and qbx, kept up to date by the core's own events (as can9work-base's jobCount does):
-- the events carry the job, so no lookup copies the whole character across resources.

-- { job = { name, grade, label } or nil, duty } from a PlayerData.job.
local function state(job)
    if type(job) ~= 'table' or not job.name then return { job = nil, duty = false } end
    local grade = type(job.grade) == 'table' and job.grade.level or job.grade
    return { job = { name = job.name, grade = tonumber(grade) or 0, label = job.label }, duty = job.onduty == true }
end

-- set(source, state) on a load or a job change; duty(source, onDuty) on a duty toggle; then changed(source) after a
-- job change or a duty toggle, in the same handler (handlers of one event run in no fixed order).
local function watch(set, duty, changed)
    AddEventHandler('QBCore:Server:PlayerLoaded', function(p)
        local data = type(p) == 'table' and p.PlayerData
        if data and data.source then set(data.source, state(data.job)) end
    end)
    AddEventHandler('QBCore:Server:OnJobUpdate', function(src, job)
        if src and type(job) == 'table' then set(src, state(job)) end
        if src and changed then changed(src) end
    end)
    AddEventHandler('QBCore:Server:SetDuty', function(src, onDuty)
        if src then duty(src, onDuty == true) end
        if src and changed then changed(src) end
    end)
end

return { state = state, watch = watch }
