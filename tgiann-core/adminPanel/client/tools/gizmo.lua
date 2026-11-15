-- tgiann-core admin lib: position and rotation with the tgiann-core gizmo (it brings its own free camera).
local Tools = AdminPanel.Tools

---@class AdminToolGizmoOptions
---@field keys? table[] extra gizmo key rows ({ icon, label, controls = { ... } } are disabled for the game)
---@field onFrame? fun(entity: number) every frame while the gizmo runs: move the preview after the entity
---@field headingOnly? boolean pitch and roll stay 0 (a thing that only turns around its up axis)
---@field disables? table gizmo disables

---Moves an entity with the gizmo. Returns where it ended, nil when cancelled.
---@param entity number
---@param opts? AdminToolGizmoOptions
---@return { coords: vector3, rotation: vector3 }|nil
function Tools.Gizmo(entity, opts)
    opts = opts or {}
    local editing = true
    CreateThread(function()
        while editing do
            if DoesEntityExist(entity) then
                if opts.headingOnly then
                    local rot = GetEntityRotation(entity, 2)
                    if rot.x ~= 0.0 or rot.y ~= 0.0 then SetEntityRotation(entity, 0.0, 0.0, rot.z, 2, false) end
                end
                if opts.onFrame then opts.onFrame(entity) end
            end
            Wait(0)
        end
    end)
    local ok, result = pcall(function()
        return exports["tgiann-core"]:UseGizmo(entity, { camera = Tools.FREECAM, keys = opts.keys, disables = opts.disables })
    end)
    editing = false
    if not ok then print(("^1[%s] admin gizmo failed: %s^7"):format(cache.resource, tostring(result))) end
    if not ok or not result or not result.success or not DoesEntityExist(entity) then return nil end
    return { coords = GetEntityCoords(entity), rotation = GetEntityRotation(entity, 2) }
end

---Position and rotation of something that is not an entity (a page, a point): a helper prop stands in for it.
---onFrame gets the helper's live position and rotation.
---@param coords vector3
---@param rotation vector3
---@param opts? { keys?: table[], onFrame?: fun(coords: vector3, rotation: vector3), headingOnly?: boolean }
---@return { coords: vector3, rotation: vector3 }|nil
function Tools.EditTransform(coords, rotation, opts)
    opts = opts or {}
    local helper = Tools.Helper(coords, rotation)
    local result = Tools.Gizmo(helper, {
        keys = opts.keys,
        headingOnly = opts.headingOnly,
        onFrame = opts.onFrame and function(entity) opts.onFrame(GetEntityCoords(entity), GetEntityRotation(entity, 2)) end,
    })
    if DoesEntityExist(helper) then DeleteEntity(helper) end
    return result
end
