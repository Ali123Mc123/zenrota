-- tgiann-core admin lib, client part (loaded by adminPanel/init.lua). Runs inside the script: world data (files with
-- sync = "all") is read from the script's own data/*.json (FiveM's cached copy, from when the resource started), the
-- records changed since then come from the server once, every later edit as a patch. The panel itself is drawn by
-- tgiann-core; this part answers its calls (client/adminPanel/bridge.lua in core) through local events.
assert(AdminPanel and AdminPanel.schema, "tgiann-core admin lib: AdminPanel.Define(schema) must run in a shared script before the client part")

local schema = AdminPanel.schema
local resource = cache.resource
AdminPanel.ready = false

---Runs a script hook; an error is printed, never thrown into the lib.
---@param name string
---@param ... any fn, args
function AdminPanel.RunHook(name, ...)
    local ok, err = pcall(...)
    if not ok then print(("^1[%s] admin %s hook failed: %s^7"):format(resource, name, tostring(err))) end
end

local run = AdminPanel.RunHook

---@param records table<string, table<string, table>>
local function load(records)
    for file, spec in pairs(schema.files) do
        if spec.sync == "all" then AdminPanel.Load(file, (AdminPanel.WithDefaults(file, records[file] or {}))) end
    end
    AdminPanel.ready = true
    for _, fn in ipairs(AdminPanel.hooks.ready) do run("ready", fn) end
end

-- the files as they were when the resource started, then only what changed since (server/main.lua)
RegisterNetEvent(AdminPanel.EventName("changes"))
AddEventHandler(AdminPanel.EventName("changes"), function(changes)
    if AdminPanel.ready or type(changes) ~= "table" then return end
    local records = {}
    for file, spec in pairs(schema.files) do
        if spec.sync == "all" then
            local list = AdminPanel.ReadFile(file)
            for key, record in pairs(type(changes[file]) == "table" and changes[file] or {}) do
                list[key] = record or nil
            end
            records[file] = list
        end
    end
    load(records)
end)

CreateThread(function()
    TriggerServerEvent(AdminPanel.EventName("requestChanges"))
end)

---@param patch table
local function applyWorldPatch(patch)
    for _, fn in ipairs(AdminPanel.hooks.before[patch.file] or {}) do run("before", fn, patch.key, patch) end
    AdminPanel.ApplyPatch(patch)
    -- a rename builds the record again under its new key
    local key = patch.action == "rename" and patch.value or patch.key
    for _, fn in ipairs(AdminPanel.hooks.after[patch.file] or {}) do run("after", fn, key, patch) end
end

RegisterNetEvent(AdminPanel.EventName("patch"))
AddEventHandler(AdminPanel.EventName("patch"), function(patch)
    if type(patch) ~= "table" or not schema.files[patch.file] then return end
    -- a patch can outrun the changes answer; re-applying one the answer already holds is harmless
    while not AdminPanel.ready do Wait(100) end
    applyWorldPatch(patch)
    TriggerEvent("tgiann-core:adminPanel:patch", resource, patch)
end)

-- many patches of one file at once (AdminPanel.CommitMany): the runtime rebuilds once
RegisterNetEvent(AdminPanel.EventName("patches"))
AddEventHandler(AdminPanel.EventName("patches"), function(file, patches)
    if type(patches) ~= "table" or not schema.files[file] then return end
    while not AdminPanel.ready do Wait(100) end
    for _, patch in ipairs(patches) do
        for _, fn in ipairs(AdminPanel.hooks.before[file] or {}) do run("before", fn, patch.key, patch) end
    end
    AdminPanel.ApplyPatches(file, patches)
    for _, patch in ipairs(patches) do
        for _, fn in ipairs(AdminPanel.hooks.after[file] or {}) do run("after", fn, patch.key, patch) end
        TriggerEvent("tgiann-core:adminPanel:patch", resource, patch)
    end
end)

RegisterNetEvent(AdminPanel.EventName("adminPatches"))
AddEventHandler(AdminPanel.EventName("adminPatches"), function(file, patches)
    if type(patches) ~= "table" or not schema.files[file] then return end
    for _, patch in ipairs(patches) do TriggerEvent("tgiann-core:adminPanel:patch", resource, patch) end
end)

-- server-only files (sync = "admin") only reach open panels
RegisterNetEvent(AdminPanel.EventName("adminPatch"))
AddEventHandler(AdminPanel.EventName("adminPatch"), function(patch)
    if type(patch) ~= "table" or not schema.files[patch.file] then return end
    TriggerEvent("tgiann-core:adminPanel:patch", resource, patch)
end)

---Shows a value in this admin's open panel only (AdminPanel.SetLookup on the server reaches every open panel),
---e.g. a just recorded picture before its file is served.
---@param name string
---@param key string
---@param value any
function AdminPanel.ShowLookup(name, key, value)
    TriggerEvent("tgiann-core:adminPanel:lookup", resource, name, key, value)
end

-- one entry of a script lookup changed (AdminPanel.SetLookup)
RegisterNetEvent(AdminPanel.EventName("lookup"))
AddEventHandler(AdminPanel.EventName("lookup"), function(name, key, value)
    if type(name) ~= "string" or type(key) ~= "string" then return end
    TriggerEvent("tgiann-core:adminPanel:lookup", resource, name, key, value)
end)

RegisterNetEvent(AdminPanel.EventName("adminSnapshot"))
AddEventHandler(AdminPanel.EventName("adminSnapshot"), function(snapshot)
    if type(snapshot) ~= "table" then return end
    -- the world files are here already (the server sends only the server-only ones)
    while not AdminPanel.ready do Wait(100) end
    snapshot.records = type(snapshot.records) == "table" and snapshot.records or {}
    for file, spec in pairs(schema.files) do
        if spec.sync == "all" then snapshot.records[file] = AdminPanel.records[file] end
    end
    local lookups = type(snapshot.lookups) == "table" and snapshot.lookups or {}
    lookups.custom = type(lookups.custom) == "table" and lookups.custom or {}
    for name, fn in pairs(AdminPanel.hooks.clientLookup) do lookups.custom[name] = fn() end
    snapshot.lookups = lookups
    snapshot.resource = resource
    snapshot.lang = config.langs and config.langs[config.lang] or {}
    for _, fn in ipairs(AdminPanel.hooks.open) do run("open", fn, snapshot) end
    AdminPanel.open = true
    TriggerEvent("tgiann-core:adminPanel:open", resource, snapshot)
end)

---true while this script's panel is on screen (closed by the admin or replaced by another script's panel)
AdminPanel.open = false

---Shows a message in this script's open panel (a notification that would hide behind it). tone: "error" | "info".
---@param text string
---@param tone? "error"|"info"
function AdminPanel.Toast(text, tone)
    TriggerEvent("tgiann-core:adminPanel:toast", resource, text, tone or "info")
end
