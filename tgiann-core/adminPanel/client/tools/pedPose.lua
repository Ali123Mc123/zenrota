-- tgiann-core admin lib: where a character stands and faces, set on the admin's own character playing an animation.
local Tools = AdminPanel.Tools

---The admin's character is attached to an invisible anchor the gizmo moves, so it follows every frame while the
---animation plays and is never pushed up or down. Returns the ped root position and heading, nil when cancelled.
---The admin stays frozen at the last position (the caller brings it back).
---@param coords vector3 ped root
---@param heading number
---@param anim? { dict: string, clip: string } loaded animation (Tools.LoadAnim) to play meanwhile
---@return { coords: vector3, heading: number }|nil
function Tools.EditPedPose(coords, heading, anim)
    local ped = cache.ped
    ClearPedTasksImmediately(ped)
    local anchor = Tools.Helper(coords, vector3(0.0, 0.0, heading))
    SetEntityVisible(anchor, false, false)
    -- the attachment holds the character now (a frozen entity does not follow its parent)
    FreezeEntityPosition(ped, false)
    AttachEntityToEntity(ped, anchor, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    local lastAnim = 0
    local result = Tools.Gizmo(anchor, {
        headingOnly = true,
        disables = { drawOutline = true, freezeEntityPosition = true, entityCollision = true },
        onFrame = anim and function()
            local now = GetGameTimer()
            if now - lastAnim < 250 then return end
            lastAnim = now
            if not IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3) then
                TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, 8.0, -1, 1, 0.0, false, false, false)
            end
        end,
    })
    local pos, rot = GetEntityCoords(anchor), GetEntityRotation(anchor, 2)
    DetachEntity(ped, true, false)
    DeleteEntity(anchor)
    ClearPedTasks(ped)
    Tools.PlacePed(pos, rot.z)
    if not result then return nil end
    return { coords = result.coords, heading = result.rotation.z }
end
