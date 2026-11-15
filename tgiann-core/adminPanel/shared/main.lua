-- tgiann-core admin lib, shared part (loaded by adminPanel/init.lua, which a script includes before its schema).
-- It runs inside the script, so every record, hook and file belongs to that script.
-- The script describes its data and panel once with AdminPanel.Define(schema) (JSON safe, no functions)
-- and plugs behaviour in with the hooks below. Records are kept in wire form (plain tables, the shape of
-- the JSON files); AdminPanel.OnApply turns them into the runtime config tables the script reads.
-- A settings file (kind = "settings") holds one object as the record "main", filled from spec.defaults.
AdminPanel.LIB_VERSION = 1
---@type table|nil
AdminPanel.schema = nil
---file -> key -> record (wire form)
---@type table<string, table<string, table>>
AdminPanel.records = {}
AdminPanel.hooks = {
    apply = {},    -- file -> fn(key, record|nil)            runtime config tables (both sides)
    rule = {},     -- file -> fn[](record, key, patch) -> ok, errKey, reason   (server)
    applied = {},  -- file -> fn[](patch, src)               side effects after a panel commit (server)
    before = {},   -- file -> fn[](key, patch)               before a patch lands (client: destroy)
    after = {},    -- file -> fn[](key, patch)               after a patch landed (client: build)
    ready = {},    -- fn[]()                                 data loaded (server: files, client: world data)
    preview = {},  -- file -> fn(key|nil)                    record focused in the panel (client)
    pick = {},     -- file -> fn(key, path, phase) -> preview?  creator ghost / hide own prop (client)
    teleport = {}, -- file -> fn(key, path) -> vector4|nil  where "teleport" puts the admin (client)
    worldEdit = {}, -- tool -> fn(data) -> value|nil         interactive edit in the world (client)
    action = {},   -- name -> fn(data) -> result               script action of a button, a bulk list or an import (client)
    lookup = {},   -- name -> fn() -> table<string, any>       script lists sent with the admin snapshot (server)
    batch = {},    -- file -> fn[]()                           once after many patches were applied together (both sides)
    clientLookup = {}, -- name -> fn() -> table<string, any>   lists only the admin's game knows (client)
    open = {},     -- fn[](snapshot)                         the panel is about to open (client): snapshot.select
    close = {},    -- fn[]()                                 the panel closed (client)
}

---@param schema table
function AdminPanel.Define(schema)
    assert(type(schema) == "table" and type(schema.files) == "table", "AdminPanel.Define: schema.files is required")
    assert(type(schema.command) == "string", "AdminPanel.Define: schema.command is required")
    AdminPanel.schema = schema
    for file, spec in pairs(schema.files) do
        -- store = "script": the script keeps the records itself (database rows), fills them with AdminPanel.Load /
        -- AdminPanel.Commit and writes panel edits in OnApplied; no JSON file, only open panels see them
        if spec.store == "script" then
            spec.sync = "admin"
        else
            assert(type(spec.path) == "string", ("AdminPanel.Define: files.%s.path is required"):format(file))
        end
        assert(type(spec.sections) == "table", ("AdminPanel.Define: files.%s.sections is required"):format(file))
        spec.sync = spec.sync or "all"
        -- "records": a keyed list (stations, recipes); "settings": one object, stored as the record "main"
        spec.kind = spec.kind or "records"
        spec.keyMax = spec.keyMax or 30
        -- Lua pattern a record key must match (a script whose saved names hold capitals widens it)
        spec.keyPattern = spec.keyPattern or "^[a-z0-9_]+$"
        AdminPanel.records[file] = AdminPanel.records[file] or {}
    end
end

---@param hooks table
---@param file string
---@param fn function
local function push(hooks, file, fn)
    hooks[file] = hooks[file] or {}
    hooks[file][#hooks[file] + 1] = fn
end

---Writes one record into the script's runtime tables (nil = removed). Runs on load and on every patch.
---@param file string
---@param fn fun(key: string, record: table|nil)
function AdminPanel.OnApply(file, fn) AdminPanel.hooks.apply[file] = fn end

---Server: extra rule on a record after a patch would apply (cross-field, cross-record).
---@param file string
---@param fn fun(record: table|nil, key: string, patch: table): boolean, string|nil, string|nil
function AdminPanel.Rule(file, fn) push(AdminPanel.hooks.rule, file, fn) end

---Server: side effects after a panel patch was committed (useable items, caches); src = the admin who made it.
---@param file string
---@param fn fun(patch: table, src: number)
function AdminPanel.OnApplied(file, fn) push(AdminPanel.hooks.applied, file, fn) end

---Client: before / after a world record changes (destroy and rebuild props, points, blips).
---@param file string
---@param before fun(key: string, patch: table)|nil
---@param after fun(key: string, patch: table)|nil
function AdminPanel.OnChange(file, before, after)
    if before then push(AdminPanel.hooks.before, file, before) end
    if after then push(AdminPanel.hooks.after, file, after) end
end

---Both sides: once after many patches of the file were applied together (AdminPanel.CommitMany). OnApply runs
---per record meanwhile with AdminPanel.batching = true, so a costly rebuild can wait for this.
---@param file string
---@param fn fun()
function AdminPanel.OnBatch(file, fn) push(AdminPanel.hooks.batch, file, fn) end

---Data is loaded: on the server the data files (first tick after the script started; read records here, not
---at file load), on the client the world data (snapshot or files).
---@param fn fun()
function AdminPanel.OnReady(fn) AdminPanel.hooks.ready[#AdminPanel.hooks.ready + 1] = fn end

---Client: the panel focuses a record of this file (key) or leaves it (nil). Draw outlines, markers.
---@param file string
---@param fn fun(key: string|nil)
function AdminPanel.OnPreview(file, fn) AdminPanel.hooks.preview[file] = fn end

---Client: a world pick starts ("before", return the creator preview) and ends ("after").
---@param file string
---@param fn fun(key: string|nil, path: string, phase: "before"|"after", record: table|nil): table|nil
function AdminPanel.OnPick(file, fn) AdminPanel.hooks.pick[file] = fn end

---Client: position the panel's teleport button puts the admin at. path = the field the button belongs to
---("locations.2" for the second point of a points list).
---@param file string
---@param fn fun(key: string, path: string|nil): vector4|nil
function AdminPanel.OnTeleport(file, fn) AdminPanel.hooks.teleport[file] = fn end

---Client: an interactive world editor of the script (move a screen, a point...). Blocking; returns the new
---value of data.path, or nil when cancelled. data = { file, key, path, value, record, tool }.
---@param tool string
---@param fn fun(data: table): any
function AdminPanel.OnWorldEdit(tool, fn) AdminPanel.hooks.worldEdit[tool] = fn end

---Client: a script action the panel runs (an action button, a bulk action on picked records, an import).
---Blocking; data = { action, file, key?, keys?, record?, values? }. The result goes back to the panel:
---{ ok, value?, msgKey?, msgArgs? } (msgKey is a language key the panel shows).
---@param name string
---@param fn fun(data: table): table|nil
function AdminPanel.OnAction(name, fn) AdminPanel.hooks.action[name] = fn end

---Server: a list of the script sent with the admin snapshot (lookups.custom[name], key -> value), e.g. the
---preview picture of every record. AdminPanel.SetLookup changes one entry in the open panels.
---@param name string
---@param fn fun(): table<string, any>
function AdminPanel.Lookup(name, fn) AdminPanel.hooks.lookup[name] = fn end

---Client: a list only the admin's game can tell (a missing anim dict or model), added to lookups.custom[name] when
---the panel opens. Same use as AdminPanel.Lookup (row pictures, whenLookup chips).
---@param name string
---@param fn fun(): table<string, any>
function AdminPanel.ClientLookup(name, fn) AdminPanel.hooks.clientLookup[name] = fn end

---Client: the panel is about to open. The hook may set snapshot.select = { tab = "<tab id>", key = "<record key>" }
---to open on a record (the location the admin stands in).
---@param fn fun(snapshot: table)
function AdminPanel.OnOpen(fn) AdminPanel.hooks.open[#AdminPanel.hooks.open + 1] = fn end

---Client: the panel closed (the admin closed it, or another script's panel took its place).
---@param fn fun()
function AdminPanel.OnClose(fn) AdminPanel.hooks.close[#AdminPanel.hooks.close + 1] = fn end

---@param name string
---@return string
function AdminPanel.EventName(name)
    -- one admin lib, many scripts: every event carries the script's own name
    return ("%s:tgiAdmin:%s"):format(cache.resource, name)
end
