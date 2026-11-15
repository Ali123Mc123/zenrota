-- tgiann-core admin lib loader (the @ox_lib/init.lua way). A script includes only this file, in shared_scripts
-- before its schema:
--   shared_scripts { "@ox_lib/init.lua", ..., "@tgiann-core/adminPanel/init.lua", "shared/adminSchema.lua", ... }
-- The shared part loads now; the server or client part needs the schema, so it loads when the script calls
-- AdminPanel.Define. Every file runs inside the script (its globals, its records, its data files).
local CORE = "tgiann-core"

-- the namespace the modules fill, declared here so editors know it in every script that includes this file
---@class AdminPanelLib
AdminPanel = {}

local MODULES = {
    shared = { "shared/main.lua", "shared/records.lua", "shared/controls.lua", "shared/business.lua" },
    server = {
        "server/utils/json.lua",
        "server/classes/dataFile.lua",
        "server/classes/writeBudget.lua",
        "server/validation.lua",
        "server/lookups.lua",
        "server/search.lua",
        "server/commit.lua",
        "server/importer.lua",
        "server/main.lua",
    },
    client = {
        "client/classes/requests.lua",
        "client/tools/common.lua",
        "client/tools/gizmo.lua",
        "client/tools/pedPose.lua",
        "client/tools/camera.lua",
        "client/tools/rings.lua",
        "client/tools/bones.lua",
        "client/tools/attach.lua",
        "client/sync.lua",
        "client/actions.lua",
    },
}

---@param file string path inside adminPanel/
local function loadModule(file)
    local path = "adminPanel/" .. file
    local code = LoadResourceFile(CORE, path)
    assert(code, ("tgiann-core admin lib: %s is missing (is tgiann-core started and up to date?)"):format(path))
    local chunk, err = load(code, ("@@%s/%s"):format(CORE, path))
    assert(chunk, err)
    chunk()
end

for _, file in ipairs(MODULES.shared) do loadModule(file) end

local define = AdminPanel.Define

---@param schema table
function AdminPanel.Define(schema)
    assert(not AdminPanel.schema, "AdminPanel.Define runs once per script")
    define(schema)
    for _, file in ipairs(IsDuplicityVersion() and MODULES.server or MODULES.client) do loadModule(file) end
end
