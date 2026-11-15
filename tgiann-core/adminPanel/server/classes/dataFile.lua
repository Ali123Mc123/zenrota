-- tgiann-core admin lib: one data/*.json file of the script on the server. SaveResourceFile writes into the
-- script itself, so no filesystem permission is needed; saves are debounced and written with sorted keys.

---@class AdminPanelDataFile : OxClass
---@field file string schema file name
---@field path string data/*.json inside the script
---@field queued boolean a save is waiting for the debounce
AdminPanelDataFile = lib.class("AdminPanelDataFile")

local SAVE_DELAY = 500 -- ms, edits in a row become one write

---@param file string
---@param path string
function AdminPanelDataFile:constructor(file, path)
    self.file = file
    self.path = path
    self.queued = false
end

---Reads the file into the records (settings missing from it start at their defaults).
function AdminPanelDataFile:load()
    local version = AdminPanel.schema.version or 1
    local records, fileVersion = AdminPanel.ReadFile(self.file)
    if fileVersion > version then
        print(("^1[%s] %s was written by a newer version (v%d), update the script^7"):format(cache.resource, self.path, fileVersion))
    end
    local filled
    records, filled = AdminPanel.WithDefaults(self.file, records)
    if filled then self:queueSave() end
    AdminPanel.Load(self.file, records)
end

function AdminPanelDataFile:save()
    local data = { version = AdminPanel.schema.version or 1, records = AdminPanel.records[self.file] }
    if not SaveResourceFile(cache.resource, self.path, AdminPanel.Json.Encode(data), -1) then
        print(("^1[%s] could not write %s^7"):format(cache.resource, self.path))
    end
end

function AdminPanelDataFile:queueSave()
    if self.queued then return end
    self.queued = true
    SetTimeout(SAVE_DELAY, function() self:flush() end)
end

---Writes a waiting save now (resource stop inside the debounce window).
function AdminPanelDataFile:flush()
    if not self.queued then return end
    self.queued = false
    self:save()
end
