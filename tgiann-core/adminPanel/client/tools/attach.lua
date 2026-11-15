-- tgiann-core admin lib: where an attached thing sits on its parent (a prop in a hand, a player on another's
-- back), set with the gizmo while it stays attached. An invisible ghost carries the gizmo, a probe attached with
-- no offset gives the bone's frame every frame, and the engine converts between rotation orders
-- (tgiann-prop-attach-editor's method).
local Tools = AdminPanel.Tools

---@param a vector3
---@param b vector3
local function dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

---@param v vector3
local function normalize(v)
    local len = #v
    return len > 0 and v / len or v
end

---Rotation order 2 angles of forward / right / up axes (the core gizmo's math).
---@return vector3
local function rotationFromAxes(f, r, u)
    f, r, u = normalize(f), normalize(r), normalize(u)
    local pitch = math.deg(math.asin(math.max(-1.0, math.min(1.0, f.z))))
    local roll = math.deg(math.atan(-r.z, u.z))
    local yaw = math.deg(math.atan(-f.x, f.y))
    return vector3(pitch, roll, yaw)
end

---World transform of an entity in the frame of a probe attached to the bone.
---@return vector3 pos
---@return vector3 rot rotation order 2
local function inBoneFrame(entity, probe)
    local wF, wR, wU, wA = GetEntityMatrix(entity)
    local bF, bR, bU, bA = GetEntityMatrix(probe)
    local d = wA - bA
    local pos = vector3(dot(d, bR), dot(d, bF), dot(d, bU))
    local f = vector3(dot(wF, bR), dot(wF, bF), dot(wF, bU))
    local r = vector3(dot(wR, bR), dot(wR, bF), dot(wR, bU))
    local u = vector3(dot(wU, bR), dot(wU, bF), dot(wU, bU))
    return pos, rotationFromAxes(f, r, u)
end

---@param model integer
---@return integer entity invisible, collision-less, frozen
local function helper(model)
    local c = GetEntityCoords(cache.ped)
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    local entity = CreateObject(model, c.x, c.y, c.z, false, false, false)
    SetEntityAlpha(entity, 0, false)
    SetEntityCollision(entity, false, false)
    FreezeEntityPosition(entity, true)
    return entity
end

---@class AdminToolAttachOptions
---@field rotationOrder? integer the order AttachEntityToEntity is called with (default 2)
---@field anim? { ped: number, dict: string, clip: string } G plays / holds this clip on the parent meanwhile
---@field keys? table[] extra gizmo keys

---Moves an attached entity with the gizmo; it stays attached and follows the bone the whole time. Returns its new
---offset and rotation on the bone (in opts.rotationOrder), nil when cancelled (the old placement comes back).
---@param entity number the attached thing
---@param parent number
---@param boneIndex integer GetPedBoneIndex of the parent
---@param offset vector3
---@param rotation vector3
---@param opts? AdminToolAttachOptions
---@return { pos: vector3, rot: vector3 }|nil
function Tools.EditAttachment(entity, parent, boneIndex, offset, rotation, opts)
    opts = opts or {}
    local order = opts.rotationOrder or 2
    local pos, rot = offset, rotation
    local function attach()
        AttachEntityToEntity(entity, parent, boneIndex, pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, rot.x + 0.0, rot.y + 0.0, rot.z + 0.0, false, false, false, false, order, true)
    end
    attach()

    lib.requestModel(Tools.HELPER_MODEL)
    local probe, ghost = helper(Tools.HELPER_MODEL), helper(Tools.HELPER_MODEL)
    local converter = order ~= 2 and helper(Tools.HELPER_MODEL) or nil
    SetModelAsNoLongerNeeded(Tools.HELPER_MODEL)
    FreezeEntityPosition(probe, false)
    AttachEntityToEntity(probe, parent, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    local anim = opts.anim
    local playing = false
    local function hold(on)
        if not anim then return end
        playing = not on
        SetEntityAnimSpeed(anim.ped, anim.dict, anim.clip, on and 0.0 or 1.0)
    end
    hold(true)

    -- the ghost sits on the attached entity; a drag (the ghost moved by someone else) rewrites the placement
    local lastPos, lastRot
    local function syncGhost()
        local f, r, u, a = GetEntityMatrix(entity)
        local ghostRot = rotationFromAxes(f, r, u)
        SetEntityCoordsNoOffset(ghost, a.x, a.y, a.z, false, false, false)
        SetEntityRotation(ghost, ghostRot.x, ghostRot.y, ghostRot.z, 2, false)
        lastPos, lastRot = vector3(a.x, a.y, a.z), ghostRot
    end
    local function ghostMoved()
        if not lastPos then return false end
        if #(GetEntityCoords(ghost) - lastPos) > 0.0005 then return true end
        local now = GetEntityRotation(ghost, 2)
        return math.abs(now.x - lastRot.x) > 0.02 or math.abs(now.y - lastRot.y) > 0.02 or math.abs(now.z - lastRot.z) > 0.02
    end
    Wait(0)
    syncGhost()

    local mirroring = true
    CreateThread(function()
        while mirroring do
            if not playing and ghostMoved() then
                local p, r = inBoneFrame(ghost, probe)
                if converter then
                    SetEntityRotation(converter, r.x, r.y, r.z, 2, false)
                    r = GetEntityRotation(converter, order)
                end
                pos, rot = p, r
                attach()
                lastPos, lastRot = GetEntityCoords(ghost), GetEntityRotation(ghost, 2)
            else
                syncGhost()
            end
            Wait(0)
        end
    end)

    local lang = Tools.Lang()
    local keys = {}
    for _, key in ipairs(opts.keys or {}) do keys[#keys + 1] = key end
    if anim then
        keys[#keys + 1] = { icon = "gKey", label = lang.ADMIN_TOOL_ANIM_TOGGLE, control = 47, onPress = function() hold(playing) end }
    end
    local startPos, startRot = offset, rotation
    local moved = Tools.Gizmo(ghost, { keys = keys, disables = { snapToGround = true, drawOutline = true } })
    mirroring = false
    Wait(0)
    hold(true)

    for _, e in ipairs({ probe, ghost, converter }) do
        if e and DoesEntityExist(e) then DeleteEntity(e) end
    end
    if not moved then
        pos, rot = startPos, startRot
        attach()
        return nil
    end
    return {
        pos = vector3(Tools.Round(pos.x, 4), Tools.Round(pos.y, 4), Tools.Round(pos.z, 4)),
        rot = vector3(Tools.Round(rot.x, 2), Tools.Round(rot.y, 2), Tools.Round(rot.z, 2)),
    }
end
