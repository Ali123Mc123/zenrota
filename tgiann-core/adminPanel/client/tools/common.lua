-- tgiann-core admin lib: shared parts of the world tools (AdminPanel.Tools). A script's OnWorldEdit hook builds
-- its preview and calls a tool; the tool moves things in the world and returns the new value, nil = cancelled.
AdminPanel.Tools = {}
local Tools = AdminPanel.Tools

Tools.CONFIRM_KEYS = { 191, 201 } -- Enter
-- keyboard only: 177 also fires on the right mouse button, which looks around in the free camera
Tools.CANCEL_KEYS = { 194, 200, 202, 322 } -- Backspace, Esc
Tools.HELPER_MODEL = `hei_heist_bank_usb_drive` -- small prop the gizmo moves when the edited thing is not an entity

-- free cameras move slowly in every tool (tgiann-core's default 0.2 is ~12 m/s)
Tools.FREECAM = { speed = 0.03, shiftMultiplier = 3.0, slowMultiplier = 0.3 }
-- a camera that is being set sits a few centimetres from its target
Tools.FREECAM_FINE = { speed = 0.006, shiftMultiplier = 3.0, slowMultiplier = 0.3 }

---@return table<string, string>
function Tools.Lang()
    return exports["tgiann-core"]:AdminPanelLang()
end

---@param keys integer[]
---@return boolean
function Tools.JustPressed(keys)
    for i = 1, #keys do
        if IsDisabledControlJustPressed(0, keys[i]) then return true end
    end
    return false
end

---@param n number
---@param decimals integer
---@return number
function Tools.Round(n, decimals)
    local m = 10 ^ decimals
    return math.floor(n * m + 0.5) / m
end

---Puts the admin exactly at a point and keeps it there (SetEntityCoords would drop it onto the ground).
---@param pos vector3
---@param heading number
function Tools.PlacePed(pos, heading)
    local ped = cache.ped
    FreezeEntityPosition(ped, true)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoordsNoOffset(ped, pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, false, false, false)
    SetEntityHeading(ped, heading + 0.0)
end

---Waits until the world around the admin has collision (up to 5 s).
function Tools.WaitCollision()
    local ped = cache.ped
    local c = GetEntityCoords(ped)
    RequestCollisionAtCoord(c.x, c.y, c.z)
    local deadline = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do Wait(50) end
end

---Ground height under a point, or the point's own height when there is none.
---@param pos vector3
---@return number
function Tools.GroundZ(pos)
    local found, z = GetGroundZFor_3dCoord(pos.x + 0.0, pos.y + 0.0, pos.z + 2.0, false)
    return found and z or pos.z
end

---A frozen, collision-less helper prop at a point with a rotation (rotation order 2).
---@param pos vector3
---@param rot vector3
---@return number
function Tools.Helper(pos, rot)
    lib.requestModel(Tools.HELPER_MODEL)
    pcall(function() exports['FeloxAC']:CreateObject(Tools.HELPER_MODEL) end) --[[FeloxAC:auto]]
    local obj = CreateObjectNoOffset(Tools.HELPER_MODEL, pos.x + 0.0, pos.y + 0.0, pos.z + 0.0, false, false, false)
    SetModelAsNoLongerNeeded(Tools.HELPER_MODEL)
    SetEntityRotation(obj, rot.x + 0.0, rot.y + 0.0, rot.z + 0.0, 2, true)
    SetEntityCollision(obj, false, false)
    FreezeEntityPosition(obj, true)
    return obj
end

---@param anim { dict: string, clip: string }|nil
---@return boolean loaded
function Tools.LoadAnim(anim)
    if not anim then return false end
    local ok = pcall(lib.requestAnimDict, anim.dict, 3000)
    return ok and HasAnimDictLoaded(anim.dict)
end

---Takes the admin to a point (frozen, collision loaded), runs fn there and brings the admin back where it stood.
---@param pos vector3
---@param heading number
---@param fn fun(): any
---@return any result of fn, nil when it failed
function Tools.Visit(pos, heading, fn)
    local ped = cache.ped
    local here = GetEntityCoords(ped)
    local backHeading = GetEntityHeading(ped)
    Tools.PlacePed(pos, heading)
    Tools.WaitCollision()
    local ok, result = pcall(fn)
    if not ok then print(("^1[%s] admin world tool failed: %s^7"):format(cache.resource, tostring(result))) end
    Tools.PlacePed(here, backHeading)
    FreezeEntityPosition(ped, false)
    return ok and result or nil
end
