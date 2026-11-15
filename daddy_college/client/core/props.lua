-- Props in the player's hands while a view is open, and props put down on a surface.

-- Holding --------------------------------------------------------------------------------------------
-- look: { Enabled, FreezePlayer, Animation = { Dict, Name, Flag }, Props = { { Model, Bone, Offset, Rotation } } }
local held

local function loaded(request, name)
    return pcall(request, name, 2500)
end

-- token: only that hold ends (from Core.Hold); without one, whatever is held.
function Core.Unhold(token)
    if not held or (token and held ~= token) then return end
    local ped = held.ped
    if DoesEntityExist(ped) then
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
    end
    for _, entity in ipairs(held.props) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
    held = nil
end

-- Dying or a new ped closes the open view and puts everything away.
function Core.Hold(look)
    Core.Unhold()
    if not look or not look.Enabled then return end
    local ped = cache.ped
    local current = { ped = ped, props = {} }
    held = current
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    if look.FreezePlayer then FreezeEntityPosition(ped, true) end
    local anim = look.Animation
    if anim and loaded(lib.requestAnimDict, anim.Dict) then
        TaskPlayAnim(ped, anim.Dict, anim.Name, 3.0, 3.0, -1, anim.Flag or 49, 0.0, false, false, false)
    end
    local coords = GetEntityCoords(ped)
    for _, prop in ipairs(look.Props or {}) do
        if loaded(lib.requestModel, prop.Model) then
            pcall(function() exports['FeloxAC']:CreateObject(joaat(prop.Model)) end) --[[FeloxAC:auto]]
            local entity = CreateObject(joaat(prop.Model), coords.x, coords.y, coords.z + 0.2, true, true, false)
            SetEntityCollision(entity, false, false)
            AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, prop.Bone), prop.Offset.x, prop.Offset.y, prop.Offset.z,
                prop.Rotation.x, prop.Rotation.y, prop.Rotation.z, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(joaat(prop.Model))
            current.props[#current.props + 1] = entity
        end
    end
    CreateThread(function()
        while held == current do
            Wait(300)
            if cache.ped ~= ped or IsEntityDead(ped) then
                Core.Nui.Close()
                Core.Unhold()
            end
        end
    end)
    return current
end

-- Placing --------------------------------------------------------------------------------------------

-- Where the camera looks, within reach.
local function aim(maxDistance)
    local origin = GetFinalRenderedCamCoord()
    local target = origin + DL.freecam.direction(GetFinalRenderedCamRot(2)) * maxDistance
    local probe = StartExpensiveSynchronousShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, 511, cache.ped, 7)
    local _, hit, coords, normal = GetShapeTestResult(probe)
    return hit == 1, coords, normal
end

-- A see-through copy follows the aim; the wheel turns it, Enter or left click puts it on a flat surface,
-- Backspace or right click cancels. title says what is being put down. Returns the spot and heading, or nil and 'model' | 'cancelled'.
function Core.PlaceOnSurface(model, title, reach)
    reach = reach or 3.5
    local hash = joaat(model)
    if not loaded(lib.requestModel, hash) then return nil, 'model' end
    local here = GetEntityCoords(cache.ped)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local ghost = CreateObject(hash, here.x, here.y, here.z, false, false, false)
    SetEntityCollision(ghost, false, false)
    FreezeEntityPosition(ghost, true)
    SetModelAsNoLongerNeeded(hash)
    local heading = GetEntityHeading(cache.ped)
    Core.Prompt('place', { title = title, keys = {
        { keys = { 'Enter', 'mouse:left' }, label = DL.locale.t('common.place_put') },
        { keys = { 'mouse:wheel' }, label = DL.locale.t('common.place_turn') },
        { keys = { 'Backspace', 'mouse:right' }, label = DL.locale.t('common.place_cancel') },
    } })

    local function finish(...)
        Core.Prompt('place')
        DeleteEntity(ghost)
        return ...
    end

    while true do
        Wait(0)
        for _, control in ipairs({ 24, 25, 14, 15 }) do DisableControlAction(0, control, true) end
        if IsDisabledControlJustPressed(0, 14) then heading = heading - 7.5 end
        if IsDisabledControlJustPressed(0, 15) then heading = heading + 7.5 end
        local ped = GetEntityCoords(cache.ped)
        local hit, coords, normal = aim(#(GetFinalRenderedCamCoord() - ped) + reach + 1.0)
        local valid = hit and #(coords - ped) <= reach and normal.z >= 0.7
        if hit then
            SetEntityCoordsNoOffset(ghost, coords.x, coords.y, coords.z + 0.015, false, false, false)
            SetEntityRotation(ghost, 0.0, 0.0, heading, 2, true)
        end
        SetEntityAlpha(ghost, valid and 200 or 70, false)
        if valid and (IsControlJustPressed(0, 18) or IsDisabledControlJustPressed(0, 24)) then
            return finish(vector3(coords.x, coords.y, coords.z + 0.015), heading)
        end
        if IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 25) then return finish(nil, 'cancelled') end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.Unhold() end
end)
