--- @return boolean @true if player is boss, false if not
tgiCore.isBoss = function(job)
    local jobData = tgiCore.GetJobData()
    if job and jobData.name ~= job then return false end

    return jobData.isBoss
end

-- Boss menu scripts, the first one running opens. Add yours here: resource name and how it opens for a job
---@type { resource: string, open: fun(job: string, resource: string) }[]
local bossMenus = {
    { resource = "ai-management", open = function(_, res) exports[res]:OpenBossMenu("job") end }, -- ai-core
    { resource = "qbx_management", open = function(_, res) exports[res]:OpenBossMenu("job") end },
    { resource = "wasabi_multijob", open = function(job, res) exports[res]:openBossMenu(job) end },
    { resource = "Ricky-BossMenu", open = function(job, res) exports[res]:OpenBossMenu(job) end },
    { resource = "qb-management", open = function() TriggerEvent("qb-bossmenu:client:OpenMenu") end },
    { resource = "esx_society", open = function(job) TriggerEvent("esx_society:openBossMenu", job, function() end, { wash = false }) end },
}

--- Open boss menu for player job
tgiCore.OpenBossMenu = function()
    if not tgiCore.isBoss() then return end
    local job = tgiCore.GetJobData().name
    if config.tgiannServer then
        return TriggerEvent('esx_society:openBossMenu', job, function(_, menu)
            menu.close()
        end, { wash = false })
    end

    for i = 1, #bossMenus do
        local menu = bossMenus[i]
        if GetResourceState(menu.resource) == "started" then return menu.open(job, menu.resource) end
    end
    -- none of them: other boss menus listen to the framework's own event
    if config.framework == "esx" then
        TriggerEvent("esx_society:openBossMenu", job, function() end, { wash = false })
    else
        TriggerEvent("qb-bossmenu:client:OpenMenu")
    end
end
