local Utils = require 'modules.utils.client'

client = client or {}

function client.syncStepTimers()
    local steps = client.currentJob and client.currentJob.steps or {}
    for _, step in ipairs(steps) do
        if not step.done and step.endTime then
            local remaining = step.endTime - GetCloudTimeAsInt()
            step.timeLimit = remaining > 0 and remaining or 0
        end
    end
end

--[[ JobManager State ]]

Jobs = {
    modules = {}, -- jobName => module
    data = {},    -- jobName => config
}

local expandMenuKeyBind = nil
local isJobInfoMenuExpanded = false
local givedVehicleKeys = {}

function Jobs.DiscordLog(type, title, color, fields)
    TriggerServerEvent(_e('server:jobs:discordLog'), type, title, color, fields)
end

function Jobs.onLoad()
    CreateThread(function()
        while not client.uiLoad do Wait(1) end
        client.sendReactMessage('ui:setIllegalJobs', Jobs.data)
    end)
end

function Jobs.onUnload()
    if not client.currentJob then return end
    Jobs.stop(client.currentJob.name)
end

function Jobs.register(name, module)
    local config = lib.load(('escrow.jobs.%s.config'):format(name))
    if not config or
        config.enabled == false or
        config.active == false
    then
        return
    end

    config.name = name
    Jobs.modules[name] = module
    Jobs.data[name] = config
end

function Jobs.get(name)
    return Jobs.modules[name]
end

function Jobs.getData(name)
    local data = Jobs.data[name]
    return data and shared.deepCopy(data) or nil
end

function Jobs.start(name)
    local job = Jobs.get(name)
    if not job or not job.start then
        lib.print.error(('Job \'%s\' not found or missing .start()'):format(name))
        return 'missing-job'
    end

    if not client.exports.beforeJobStart(cache.serverId, client.currentJob) then
        local text = locale('job_start_blocked_by_player', cache.serverId)
        lib.callback.await(_e('server:jobs:abortIllegalJob'), false, client.lobby.id, text)
        return false
    end

    if not job.start() then return false end

    client.exports.onJobStarted(cache.serverId, client.currentJob)
    return true
end

function Jobs.stop(name)
    local job = Jobs.get(name)
    if not job or not job.stop then
        lib.print.error(('Job \'%s\' not found or missing .stop()'):format(name))
        return false
    end

    local lastJob = shared.deepCopy(client.currentJob or {})
    if not job.stop() then return false end

    client.currentJob = nil
    client.exports.onJobStopped(cache.serverId, lastJob)

    for key, value in pairs(givedVehicleKeys) do
        Utils.removeVehicleKey(value.plate, NetToVeh(value.netId))
    end
    givedVehicleKeys = {}

    return true
end

function Jobs.giveVehicleKey(plate, vehicle)
    if not plate or not vehicle then return end

    local keyData = {
        plate = plate,
        netId = VehToNet(vehicle),
    }

    table.insert(givedVehicleKeys, keyData)
    Utils.giveVehicleKey(plate, vehicle)
end

--[[ JobManager Events ]]

RegisterNUICallback('nui:job:start', function(jobName, resultCallback)
    if client.currentJob then
        client.sendReactAlert(locale('jobs.have_already_job'), 'error')
        return resultCallback(false)
    end

    local jobData = Jobs.getData(jobName)
    if not jobData then
        lib.print.error('Job config not found for key: ' .. tostring(jobName))
        return resultCallback(false)
    end

    local response = lib.callback.await(_e('server:jobs:startIllegalJob'), false, jobName, client.lobby.id)
    if not response then
        return resultCallback(false)
    end

    if response.error then
        Utils.notify(response.error, 'error')
        return resultCallback(false)
    end

    client.hideUI()

    resultCallback(true)
end)

RegisterNUICallback('nui:job:stop', function(jobName, resultCallback)
    if not client.currentJob then
        return resultCallback(false)
    end

    local jobData = Jobs.getData(jobName)
    if not jobData then
        lib.print.error('Job config not found for key: ' .. tostring(jobName))
        return resultCallback(false)
    end

    if jobName == 'corner_deal' then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    else
        lib.callback.await(_e('server:jobs:stopIllegalJob'), false, jobName, client.lobby.id)
    end

    client.hideUI()

    resultCallback(true)
end)

--[[ JobManager Keybinds ]]

expandMenuKeyBind = lib.addKeybind({
    name = 'expand_illegal_job_info_box',
    description = 'Expand illegal job info box',
    defaultKey = Config.ExpandJobInfoBoxKey,
    onPressed = function(self)
        self:disable(true)
        client.syncStepTimers()
        client.sendReactMessage('ui:setJobInfo', {
            expandMenu = not isJobInfoMenuExpanded,
            steps = client.currentJob and client.currentJob.steps or {}
        })
        isJobInfoMenuExpanded = not isJobInfoMenuExpanded
        Wait(1000)
        self:disable(false)
    end,
    disabled = true,
})

--[[ JobManager events ]]

---@param jobName string
---@param data Job
RegisterNetEvent(_e('client:jobs:onJobStart'), function(jobName, data)
    if not jobName or not data then return end

    client.currentJob = data

    local response = Jobs.start(jobName)
    if not response then return end
    if response == 'missing-job' then
        if client.lobby.owner == cache.serverId then
            lib.callback.await(_e('server:jobs:abortIllegalJob'), false, client.lobby.id,
                ('Job \'%s\' not found or missing .start()'):format(jobName))
        end
        return
    end

    expandMenuKeyBind:disable(false)
    isJobInfoMenuExpanded = false

    Utils.notify(locale('jobs.job_started'), 'success')
    client.syncStepTimers()
    client.sendReactMessage('ui:setCurrentJob', client.currentJob)
    client.sendReactMessage('ui:setJobInfo',
        { expandMenu = false, steps = client.currentJob.steps })
end)

---@param jobName string
---@param isDone boolean
RegisterNetEvent(_e('client:jobs:onJobStop'), function(jobName, isDone)
    Jobs.stop(jobName)
    expandMenuKeyBind:disable(true)
    Utils.notify(locale('jobs.job_stopped'), 'success')
    client.sendReactMessage('ui:setJobInfo', nil)
    client.sendReactMessage('ui:setCurrentJob', nil)
    if isDone then
        Utils.notify(locale('jobs.job_done'), 'success', 4000)
    end
end)

---@param state boolean
RegisterNetEvent(_e('client:jobs:onJobAborted'), function(jobName, err)
    if not jobName then
        jobName = client.currentJob.name
    end
    if jobName then Jobs.stop(jobName) end

    client.currentJob = nil

    expandMenuKeyBind:disable(true)
    Utils.notify(locale('jobs.job_aborted'), 'inform')
    client.sendReactMessage('ui:setJobInfo', nil)
    client.sendReactMessage('ui:setCurrentJob', nil)

    if err then Utils.notify(err, 'error', 4000) end
end)

RegisterNetEvent(_e('client:jobs:onStepDone'), function(jobName, stepId, updatedJob)
    local job = Jobs.get(jobName)
    client.currentJob = updatedJob

    isJobInfoMenuExpanded = true
    client.syncStepTimers()
    client.sendReactMessage('ui:setJobInfo',
        { expandMenu = true, steps = client.currentJob.steps })

    if job and job.onStepDone then
        if job.onStepDone(stepId) then
            Utils.notify(locale('jobs.step_done'), 'success')
        end
    end
end)

RegisterNetEvent(_e('client:jobs:onStepProgressed'), function(jobName, updatedJob)
    local job = Jobs.get(jobName)
    client.currentJob = updatedJob
    client.syncStepTimers()
    client.sendReactMessage('ui:setJobInfo',
        { expandMenu = true, steps = client.currentJob.steps })
end)

RegisterNetEvent(_e('client:jobs:restoreLabInterior'), function(jobName, labIndex)
    local job = Jobs.get(jobName)
    if job and job.restoreLabInterior then
        job.restoreLabInterior(labIndex)
    end
end)
