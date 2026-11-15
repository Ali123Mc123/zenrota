-- The school's own HUD pieces: a progress slip for things done by hand and key prompts at the bottom of the screen.

-- Progress -------------------------------------------------------------------------------------------

local MOVE = { 21, 22, 30, 31, 36 }
local CAR = { 63, 64, 71, 72, 75 }
local COMBAT = { 24, 25, 140, 141, 142, 257, 263 }
local CANCEL = 73 -- [X]
local busy = false
local ended -- 'done' | 'stopped' when the work it shows ended elsewhere

local function hold(list)
    for _, control in ipairs(list) do DisableControlAction(0, control, true) end
end

-- Something done by hand for a while, with an animation and a prop. opts as ox_lib's progressBar
-- ({ duration, label, canCancel, disable = { move, car, combat }, anim = { dict, clip, flag }, prop = { model, bone, pos, rot } })
-- plus kind, the slip's drawing ('sign', 'sweep', 'organize', 'trash', 'wipe'). True when it ran to the end.
function Core.Progress(opts)
    if Config.Ui and Config.Ui.Progress == 'ox' then return lib.progressBar(opts) end
    if busy then return false end
    busy, ended = true, nil
    local ped, anim, prop, entity = cache.ped, opts.anim, opts.prop, nil
    if anim and pcall(lib.requestAnimDict, anim.dict, 2500) then
        TaskPlayAnim(ped, anim.dict, anim.clip, 3.0, 3.0, -1, anim.flag or 49, 0.0, false, false, false)
    end
    local model = prop and (type(prop.model) == 'string' and joaat(prop.model) or prop.model)
    if model and pcall(lib.requestModel, model, 2500) then
        local here = GetEntityCoords(ped)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        entity = CreateObject(model, here.x, here.y, here.z + 0.2, true, true, false)
        AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z,
            prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
        SetModelAsNoLongerNeeded(model)
    end
    Core.Nui.Send('progress:show', { label = opts.label, duration = opts.duration, kind = opts.kind, cancel = opts.canCancel ~= false })

    local disable, ends, done = opts.disable or {}, GetGameTimer() + opts.duration, true
    while GetGameTimer() < ends do
        Wait(0)
        if disable.move then hold(MOVE) end
        if disable.car then hold(CAR) end
        if disable.combat then
            hold(COMBAT)
            DisablePlayerFiring(cache.playerId, true)
        end
        if ended then
            done = ended == 'done'
            break
        end
        if (opts.canCancel and IsControlJustPressed(0, CANCEL)) or IsEntityDead(ped) or IsPedRagdoll(ped) or cache.ped ~= ped then
            done = false
            break
        end
    end

    Core.Nui.Send('progress:hide', { done = done })
    if anim then StopAnimTask(ped, anim.dict, anim.clip, 1.0) end
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    busy = false
    return done
end

-- Ends the running progress early: done = the work finished (a tick), otherwise it is struck through.
function Core.ProgressEnd(done)
    if Config.Ui and Config.Ui.Progress == 'ox' then
        if lib.progressActive() then lib.cancelProgress() end
    elseif busy then
        ended = done and 'done' or 'stopped'
    end
end

function Core.ProgressActive()
    if Config.Ui and Config.Ui.Progress == 'ox' then return lib.progressActive() == true end
    return busy
end

-- Key prompts ----------------------------------------------------------------------------------------

-- A line at the bottom of the screen: { title, tone = 'alert'?, keys = { { keys = { 'G' }, label } } };
-- 'mouse:left', 'mouse:right' and 'mouse:wheel' draw a mouse. No data takes it away.
function Core.Prompt(id, data)
    if not data then return Core.Nui.Send('prompt:hide', { id = id }) end
    data.id = id
    Core.Nui.Send('prompt:show', data)
end

-- The keyboard key bound to a control, as the game names it ('G').
function Core.KeyName(control)
    return (GetControlInstructionalButton(0, control, true) or ''):match('^t_(.+)$') or '?'
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and busy then ClearPedTasks(cache.ped) end
end)
