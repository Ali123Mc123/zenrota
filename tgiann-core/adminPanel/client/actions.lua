-- tgiann-core admin lib: answers the calls of the core panel (client/adminPanel/bridge.lua in core) for this
-- script: patches, focus, teleport, world picks and the script's world editors.
local resource = cache.resource
local run = AdminPanel.RunHook

local requests = AdminPanelRequests:new(30000)

RegisterNetEvent(AdminPanel.EventName("patchResult"))
AddEventHandler(AdminPanel.EventName("patchResult"), function(id, ok, errKey)
    requests:resolve(id, { ok = ok == true, errKey = errKey })
end)

RegisterNetEvent(AdminPanel.EventName("importResult"))
AddEventHandler(AdminPanel.EventName("importResult"), function(id, result)
    requests:resolve(id, type(result) == "table" and result or { ok = false })
end)

-- built-in import of the panel's own export (server/importer.lua): import = { action = "lib:import", ... }
AdminPanel.OnAction("lib:import", function(data)
    return requests:send(function(id) TriggerLatentServerEvent(AdminPanel.EventName("import"), 100000, id, data.file, data.values or {}) end)
end)

---@param record table|nil
---@param path string
local function valueAt(record, path)
    local v = record
    for part in path:gmatch("[^%.]+") do
        if type(v) ~= "table" then return nil end
        -- "cabins.2.seat": a number part indexes a list
        local n = tonumber(part)
        v = n and v[n] ~= nil and v[n] or v[part]
    end
    return v
end

local previewFile = nil

local ACTIONS = {}

-- latent upload: a long list must not overflow a regular event
ACTIONS.patch = function(data)
    return requests:send(function(id) TriggerLatentServerEvent(AdminPanel.EventName("applyPatch"), 100000, id, data) end)
end

ACTIONS.refresh = function()
    TriggerServerEvent(AdminPanel.EventName("requestAdminSnapshot"))
    return { ok = true }
end

ACTIONS.close = function()
    if previewFile and AdminPanel.hooks.preview[previewFile] then run("preview", AdminPanel.hooks.preview[previewFile], nil) end
    previewFile = nil
    AdminPanel.open = false
    for _, fn in ipairs(AdminPanel.hooks.close) do run("close", fn) end
    TriggerServerEvent(AdminPanel.EventName("adminClosed"))
    return { ok = true }
end

ACTIONS.focus = function(data)
    if previewFile and previewFile ~= data.file and AdminPanel.hooks.preview[previewFile] then
        run("preview", AdminPanel.hooks.preview[previewFile], nil)
    end
    previewFile = data.file
    local fn = data.file and AdminPanel.hooks.preview[data.file]
    if fn then run("preview", fn, data.key) end
    return { ok = true }
end

ACTIONS.teleport = function(data)
    local fn = AdminPanel.hooks.teleport[data.file]
    local pos = fn and fn(data.key, data.path) or nil
    if not pos then
        -- default: the record's first vec4 / vec3 field given by the panel
        local v = data.path and valueAt(AdminPanel.Get(data.file, data.key), data.path)
        if type(v) == "table" and v.x then pos = vector4(v.x, v.y, v.z, v.w or 0.0) end
    end
    if not pos then return { ok = false } end
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHeading(cache.ped, pos.w)
    return { ok = true }
end

---@param state { heading?: number }
---@return table[]
local function keyHelp(state)
    local lang = exports["tgiann-core"]:AdminPanelLang()
    return {
        { icon = "eKey", label = lang.ADMIN_CREATOR_PLACE },
        { icon = "enterKey", label = lang.ADMIN_CREATOR_CONFIRM },
        { icon = "backspaceKey", label = lang.ADMIN_CREATOR_CANCEL },
        { icon = "mouseScroll", label = ("%s: %.0f°"):format(lang.ADMIN_CREATOR_ROTATE, state.heading or 0.0) },
        { icon = "shiftKey", label = lang.ADMIN_CREATOR_FAST },
    }
end

ACTIONS.pick = function(data)
    local hook = AdminPanel.hooks.pick[data.file]
    local record = data.key and AdminPanel.Get(data.file, data.key) or data.record
    local preview = nil
    if hook then
        local ok, result = pcall(hook, data.key, data.path, "before", record)
        if ok then preview = result end
    end
    local v = data.value
    local value = nil
    if type(v) == "table" and v.x then
        value = data.mode == "point4" and vector4(v.x + 0.0, v.y + 0.0, v.z + 0.0, (v.w or 0.0) + 0.0) or vector3(v.x + 0.0, v.y + 0.0, v.z + 0.0)
    end
    local ok, result = pcall(function()
        return exports["tgiann-core"]:StartZoneCreator({ mode = data.mode or "point4", value = value, preview = preview, keyHelp = keyHelp })
    end)
    if not ok then print(("^1[%s] zone creator failed: %s^7"):format(resource, tostring(result))) end
    if hook then pcall(hook, data.key, data.path, "after", record) end
    if not ok or not result then return { ok = false } end
    return { ok = true, value = { x = result.x, y = result.y, z = result.z, w = result.w } }
end

-- a search the server answers while the admin types (source "players")
ACTIONS.search = function(data)
    if type(data.source) ~= "string" or type(data.query) ~= "string" then return { ok = false } end
    return { ok = true, value = lib.callback.await(AdminPanel.EventName("search"), false, data.source, data.query) }
end

ACTIONS.worldEdit = function(data)
    local fn = AdminPanel.hooks.worldEdit[data.tool or ""]
    if not fn then return { ok = false } end
    data.record = data.key and AdminPanel.Get(data.file, data.key) or nil
    local value = fn(data)
    if value == nil then return { ok = false } end
    return { ok = true, value = value }
end

ACTIONS.action = function(data)
    local fn = AdminPanel.hooks.action[data.action or ""]
    if not fn then return { ok = false } end
    data.record = data.key and AdminPanel.Get(data.file, data.key) or nil
    local result = fn(data)
    if type(result) ~= "table" then return { ok = result ~= nil and result ~= false } end
    return result
end

AddEventHandler("tgiann-core:adminPanel:call:" .. resource, function(id, action, data)
    local fn = ACTIONS[action]
    CreateThread(function()
        local ok, result = false, nil
        if fn then ok, result = pcall(fn, type(data) == "table" and data or {}) end
        if not ok and fn then print(("^1[%s] admin action %s failed: %s^7"):format(resource, action, tostring(result))) end
        TriggerEvent("tgiann-core:adminPanel:reply", id, ok and result or { ok = false })
    end)
end)
