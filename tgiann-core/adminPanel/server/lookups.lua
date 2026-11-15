-- tgiann-core admin lib: lists the panel picks from (items, jobs, businesses, accounts, item pictures).

local function core()
    return tgiCore or exports["tgiann-core"]:getCore()
end

---@type { name: string, label: string }[]|nil
local itemList = nil

---@return { name: string, label: string }[]
local function items()
    if itemList then return itemList end
    local list = {}
    for itemName, def in pairs(core().Items() or {}) do
        list[#list + 1] = { name = itemName, label = type(def) == "table" and def.label or itemName }
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    itemList = list
    return list
end

AddEventHandler("onResourceStart", function(resource)
    if resource:find("inventory") then itemList = nil end
end)

---@return { name: string, label: string }[]
local function jobs()
    return core().GetJobList()
end

---@param value any
local function langText(value)
    if type(value) == "string" then return value end
    if type(value) == "table" then return value[config.lang] or value.en or select(2, next(value)) end
    return nil
end

---tgiann-core businesses (ownable rules)
---@return { name: string, label: string, resource: string }[]
local function panels()
    local out = {}
    local ok, list = pcall(function() return exports["tgiann-core"]:GetAllControlPanels() end)
    if not ok or type(list) ~= "table" then return out end
    for keyName, panel in pairs(list) do
        local shop = type(panel) == "table" and panel.tgiannShopData or nil
        out[#out + 1] = {
            name = keyName,
            label = langText(shop and shop.name) or langText(type(panel) == "table" and panel.label) or keyName,
            resource = type(panel) == "table" and tostring(panel.ownerResource or "") or "",
        }
    end
    table.sort(out, function(a, b) return a.name < b.name end)
    return out
end

---Accounts of the framework (tgiCore names); cash and bank when the framework does not tell.
---@return { name: string, label: string }[]
local function accounts()
    local ok, list = pcall(function() return core().GetMoneyTypes() end)
    if ok and type(list) == "table" and #list > 0 then return list end
    return { { name = "cash", label = "cash" }, { name = "bank", label = "bank" } }
end

---Item picture presets of tgiann-core (config.itemImages) and the url it resolves now.
---@return { name: string, url: string, started: boolean }[]
local function imagePresets()
    local ok, list = pcall(function() return core().GetItemImagePresets() end)
    return ok and type(list) == "table" and list or {}
end

---Everything the panel looks names up in, sent with the admin snapshot.
---@return table
function AdminPanel.Lookups()
    local custom = {}
    for name, fn in pairs(AdminPanel.hooks.lookup) do custom[name] = fn() end
    return {
        items = items(), jobs = jobs(), panels = panels(), accounts = accounts(), imagePresets = imagePresets(), itemImages = core().GetItemImageUrl(), custom = custom,
        -- the script's languages (langText fields) and the server language the panel shows first
        languages = AdminPanel.Languages(), language = type(config) == "table" and config.lang or "en",
    }
end

---Changes one entry of a script lookup in every open panel (nil removes it).
---@param name string
---@param key string
---@param value any
function AdminPanel.SetLookup(name, key, value)
    for src in pairs(AdminPanel.watchers) do
        TriggerClientEvent(AdminPanel.EventName("lookup"), src, name, key, value)
    end
end
