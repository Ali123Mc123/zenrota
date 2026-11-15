-- tgiann-core admin lib, server part (loaded last by adminPanel/init.lua): loads the data files and answers the
-- snapshot and panel requests.
local schema = AdminPanel.schema
AdminPanel.ready = false

---sources with this script's panel open
---@type table<number, boolean>
AdminPanel.watchers = {}

---Whoever may run the panel command may use the panel. Scripts may replace it (editable).
---@param src number
---@return boolean
AdminPanel.IsAdmin = function(src)
    return IsPlayerAceAllowed(tostring(src), "command." .. schema.command)
end

---file -> its data file on disk
---@type table<string, AdminPanelDataFile>
AdminPanel.files = {}

for file, spec in pairs(schema.files) do
    if spec.store ~= "script" then AdminPanel.files[file] = AdminPanelDataFile:new(file, spec.path) end
end

-- Define runs in a shared file, before the script's own files: the data loads on the first tick, once every
-- OnApply / OnReady hook of the script is registered
CreateThread(function()
    for _, dataFile in pairs(AdminPanel.files) do dataFile:load() end
    AdminPanel.ready = true
    for _, fn in ipairs(AdminPanel.hooks.ready) do
        local ok, err = pcall(fn)
        if not ok then print(("^1[%s] admin ready hook failed: %s^7"):format(cache.resource, tostring(err))) end
    end
end)

local function waitReady()
    while not AdminPanel.ready do Wait(50) end
end

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    -- a restart inside the debounce window must not lose the last edit
    for _, dataFile in pairs(AdminPanel.files) do dataFile:flush() end
end)

-- ---------------------------------------------------------------- joining players

-- A client reads the world files (sync = "all") from its own copy of data/*.json, the version this resource started
-- with (FiveM serves files as they were at start). It then asks once for what changed since: the current value of
-- every record touched since start (false = deleted). Nothing changed = an empty answer; the whole file never travels.

---file -> key -> true, world records changed since this resource started
---@type table<string, table<string, true>>
AdminPanel.changed = {}

---@param patch table
function AdminPanel.MarkChanged(patch)
    if schema.files[patch.file].sync ~= "all" then return end
    local keys = AdminPanel.changed[patch.file] or {}
    AdminPanel.changed[patch.file] = keys
    keys[patch.key] = true
    -- a renamed record is gone under its old key and new under the other one
    if patch.action == "rename" then keys[patch.value] = true end
end

RegisterNetEvent(AdminPanel.EventName("requestChanges"))
AddEventHandler(AdminPanel.EventName("requestChanges"), function()
    local src = source
    waitReady()
    local out = {}
    for file, keys in pairs(AdminPanel.changed) do
        local records = AdminPanel.records[file]
        local list = {}
        for key in pairs(keys) do list[key] = records[key] or false end
        out[file] = list
    end
    TriggerLatentClientEvent(AdminPanel.EventName("changes"), src, 500000, out)
end)

-- Only the server-only files travel: the client already holds every sync = "all" file (loaded on join, kept
-- current by the patches) and adds them to the panel itself (client/sync.lua)
---@param src number
local function sendAdminSnapshot(src)
    waitReady()
    AdminPanel.watchers[src] = true
    local records = {}
    for file, spec in pairs(schema.files) do
        if spec.sync == "admin" then records[file] = AdminPanel.records[file] end
    end
    -- msgpack turns tables nested deeper than 16 levels into nil (a sub editor's field options), so the schema
    -- travels as JSON text; core's panel host decodes it right before the NUI message
    TriggerLatentClientEvent(AdminPanel.EventName("adminSnapshot"), src, 500000, {
        schema = json.encode(schema),
        records = records,
        lookups = AdminPanel.Lookups(),
    })
end

-- restricted = false: the command is open to everyone and AdminPanel.IsAdmin decides (a script's own admin check)
lib.addCommand(schema.command, {
    help = schema.commandHelp and type(t) == "function" and t(schema.commandHelp) or nil,
    restricted = schema.restricted == nil and "group.admin" or schema.restricted or nil,
}, function(source)
    if schema.restricted == false and not AdminPanel.IsAdmin(source) then return end
    sendAdminSnapshot(source)
end)

RegisterNetEvent(AdminPanel.EventName("requestAdminSnapshot"))
AddEventHandler(AdminPanel.EventName("requestAdminSnapshot"), function()
    local src = source
    if not AdminPanel.IsAdmin(src) then return end
    sendAdminSnapshot(src)
end)

RegisterNetEvent(AdminPanel.EventName("adminClosed"))
AddEventHandler(AdminPanel.EventName("adminClosed"), function()
    AdminPanel.watchers[source] = nil
end)

AddEventHandler("playerDropped", function()
    AdminPanel.watchers[source] = nil
end)
