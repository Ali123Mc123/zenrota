Bridge = Bridge or {}

local function started(resource)
    return GetResourceState(resource) == 'started'
end

Bridge.Started = started

-- Looked up on every call so the start order of resources never matters.
function Bridge.Framework()
    local wanted = Config.Framework
    if wanted and wanted ~= 'auto' then return wanted end
    if started('qbx_core') then return 'qbx' end
    if started('qb-core') then return 'qb' end
    if started('es_extended') then return 'esx' end
    return 'standalone'
end

function Bridge.IsJobAllowed(jobName)
    if type(jobName) ~= 'string' then return false end
    local jobs = Config.JobName
    if type(jobs) == 'string' then return jobName == jobs end
    for i = 1, #jobs do
        if jobs[i] == jobName then return true end
    end
    return false
end

-- State bag every client keeps up to date with its own downed state.
Bridge.DownedStateKey = 'daddyPT:downed'
