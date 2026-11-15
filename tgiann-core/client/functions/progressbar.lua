local bussy = false

local lumihud = GetResourceState("tgiann-lumihud") ~= "missing"
local tgiannProgressbar = GetResourceState("tgiann-progressbar") ~= "missing"

-- ai-core: ai-lib's progress (bar, animation, blocked controls, cancel key, death); props through ai-lib's attachProp
---@param prop? { model: string|number, bone?: number, coords?: vector3, rotation?: vector3 }
---@return integer entity 0 without a prop
local function attachAiLibProp(prop)
    if not prop or not prop.model then return 0 end
    return AiLib.attachProp(prop.model, { bone = prop.bone or 60309, offset = prop.coords, rotation = prop.rotation })
end

---@return boolean finished false when cancelled or the player went down
local function aiLibProgress(label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo)
    disableControls = disableControls or {}
    local props = { attachAiLibProp(prop), attachAiLibProp(propTwo) }
    -- walking allowed, running not: ai-lib's progress has no such flag
    if disableControls.disableRun then AiLib.controls.disable("tgiann-progress-run", { 21 }) end
    local finished = AiLib.progress({
        label = label,
        duration = duration,
        anim = animation and animation.animDict and { dict = animation.animDict, clip = animation.anim, flag = animation.flags } or nil,
        scenario = animation and animation.task or nil,
        allowVehicle = true,
        canCancel = canCancel == true,
        whileDead = useWhileDead == true,
        disable = {
            move = disableControls.disableMovement,
            car = disableControls.disableCarMovement,
            mouse = disableControls.disableMouse,
            combat = disableControls.disableCombat,
        },
    })
    if disableControls.disableRun then AiLib.controls.enable("tgiann-progress-run") end
    for _, object in ipairs(props) do
        if object ~= 0 and DoesEntityExist(object) then DeleteEntity(object) end
    end
    return finished
end

tgiCore.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if bussy then
        Notify("ALREADY_ERROR", "error")
        if onCancel then onCancel() end
        return false
    end

    if prop and not next(prop) then prop = nil end
    if propTwo and not next(propTwo) then propTwo = nil end
    if animation and not next(animation) then animation = nil end

    bussy = true

    if config.framework == "aicore" then
        local success = aiLibProgress(label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo)
        bussy = false
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
        return success
    elseif lumihud then
        local success = exports['tgiann-lumihud']:Progress({
            name = name:lower(),
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            controlDisables = disableControls,
            animation = animation and animation or {},
            prop = prop and prop or {},
            propTwo = propTwo and propTwo or {},
        })
        bussy = false
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
        return success
    elseif tgiannProgressbar then
        local p = promise.new()
        exports['tgiann-progressbar']:Progress({
            name = name:lower(),
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            controlDisables = disableControls,
            animation = animation and animation or {},
            prop = prop and prop or {},
            propTwo = propTwo and propTwo or {},
        }, function(cancelled)
            if not cancelled then
                p:resolve(true)
            else
                p:resolve(false)
            end
        end)
        local success = Citizen.Await(p)
        bussy = false
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
        return success
    elseif config.framework == "qb" and not config.qbx then -- QB Framework
        local p = promise.new()
        tgiCore.core.Functions.Progressbar(
            name:lower(),
            label,
            duration,
            useWhileDead,
            canCancel,
            disableControls,
            animation or {},
            prop or {},
            propTwo or {},
            function()
                p:resolve(true)
            end,
            function()
                p:resolve(false)
            end)

        local success = Citizen.Await(p)

        bussy = false
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
        return success
    else
        local propData = {}
        local firstPropData = prop and {
            model = prop.model,
            pos = prop.coords,
            rot = prop.rotation,
            bone = prop.bone
        } or nil

        local secondPropData = propTwo and {
            model = propTwo.model,
            pos = propTwo.coords,
            rot = propTwo.rotation,
            bone = propTwo.bone
        } or nil

        if firstPropData then propData[#propData + 1] = firstPropData end
        if secondPropData then propData[#propData + 1] = secondPropData end

        local propLength = #propData

        local success = lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = {
                car = disableControls.disableCarMovement,
                move = disableControls.disableMovement,
                sprint = disableControls.disableRun, -- walking allowed, running not (ox_lib `disable.sprint`)
                combat = disableControls.disableCombat,
                mouse = disableControls.disableMouse,
            },
            anim = animation and {
                dict = animation.animDict,
                clip = animation.anim,
                flag = animation.flags
            } or nil,
            prop = propLength > 0 and propData or nil
        })
        bussy = false
        if success then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
        return success
    end
end
