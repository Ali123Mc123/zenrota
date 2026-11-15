-- tgiann-core admin lib: the player owned business block every script with a tgiann-core business shares (food jobs,
-- mechanic, vehicle shop...): its data model, its panel cards with the core texts, the CreateControlPanel data built
-- from a record, and the map legend group of the script's blips. A script merges Sections() into its file's sections,
-- puts Cards() into its tab and calls ControlPanelData() on the server.
AdminPanel.Business = {}

---@param min number
---@param max number
---@param optional? boolean
---@return table
local function int(min, max, optional)
    return { type = "number", min = min, max = max, integer = true, optional = optional }
end

---@class AdminBusinessOptions
---@field accounts? { file: string, path: string } settings list the price account is picked from (default settings.accounts)

---Data model sections: ownable (buy / rent, employees), changeJob (framework job of the staff), shopData (tgiann-shop listing)
---@param opts? AdminBusinessOptions
---@return table<string, table>
function AdminPanel.Business.Sections(opts)
    local accounts = opts and opts.accounts or { file = "settings", path = "accounts" }
    return {
        ownable = {
            type = "object",
            optional = true,
            fields = {
                price = int(0, 1000000000),
                priceType = { type = "enum", list = accounts, optional = true, err = "ADMIN_BIZ_ERR_ACCOUNT" },
                priceSymbol = { type = "text", max = 5, optional = true },
                noMoneyMsg = { type = "text", max = 200, optional = true },
                canBuy = { type = "bool", optional = true },
                canTransfer = { type = "bool", optional = true },
                canSellBack = { type = "bool", optional = true },
                rentUnlimited = { type = "bool", trueOnly = true, optional = true },
                maxEmployee = int(0, 500, true),
                rentMoneyPercent = { type = "number", min = 0, max = 1 },
                rentPeriodDay = int(1, 365),
                rentPayBeforeDay = int(0, 365),
            },
        },
        changeJob = {
            type = "object",
            optional = true,
            fields = {
                name = { type = "name", max = 64, err = "ADMIN_BIZ_ERR_JOB" },
                bossGrade = int(0, 100),
                employeeGrade = int(0, 100),
                onDuty = { type = "bool", optional = true },
            },
        },
        shopData = {
            type = "object",
            optional = true,
            fields = {
                name = { type = "langText", max = 60 },
                description = { type = "langText", max = 500, optional = true },
                image = { type = "text", max = 300, optional = true },
                subCategory = { type = "text", max = 50 },
            },
        },
    }
end

---@class AdminBusinessCardOptions
---@field group? string card group of the tab ("business")
---@field default? table ownable values a switched on card starts with
---@field subCategory? string tgiann-shop category of the listing ("vehicleShop")
---@field listingName? table|string name a switched on list entry starts with ({ en = "Food" })
---@field accountsSource? string select source of the price account (default "settings:settings:accounts")
---@field showIf? table extra condition of every card
---@field keyPrefix? string the script's business keyName before the record key ("vehicleshop_"): the Can be bought hint
---then shows the admin commands that give the business out and take it back, ready to copy

local RENTED = { path = "ownable.rentUnlimited", notEquals = true }
local OWNED = { path = "ownable" }

---Name of a tgiann-core admin command (its config can rename it)
---@param key string
---@return string
local function commandName(key)
    local commands = type(config) == "table" and type(config.commands) == "table" and config.commands or {}
    return commands[key] and commands[key].name or key
end

---@param cond table
---@param extra? table
---@return table
local function both(cond, extra)
    if not extra then return cond end
    local out = {}
    for k, v in pairs(cond) do out[k] = v end
    out["and"] = extra
    return out
end

---Panel cards of the block: Business (toggle), Framework job (toggle, only with a business), Business list entry
---@param opts? AdminBusinessCardOptions
---@return table[]
function AdminPanel.Business.Cards(opts)
    opts = opts or {}
    local accountsSource = opts.accountsSource or "settings:settings:accounts"
    local default = opts.default or { price = 100000, priceType = "bank", maxEmployee = 10, rentMoneyPercent = 0.1, rentPeriodDay = 30, rentPayBeforeDay = 10 }
    local canBuy = { widget = "switch", path = "ownable.canBuy", defaultOn = true, label = "ADMIN_BIZ_CAN_BUY", hint = "ADMIN_BIZ_CAN_BUY_HINT" }
    if opts.keyPrefix then
        canBuy.hint = "ADMIN_BIZ_CAN_BUY_CMD_HINT"
        canBuy.hintArgs = { commandName("addOwnableLocation"), opts.keyPrefix .. "{$key}", commandName("removeOwnableLocation") }
    end
    return {
        { group = opts.group, icon = "key", title = "ADMIN_BIZ_TITLE", desc = "ADMIN_BIZ_DESC", showIf = opts.showIf, toggle = { section = "ownable", default = default, descOff = "ADMIN_BIZ_OFF" }, fields = {
            { widget = "number", path = "ownable.price", min = 0, max = 1000000000, step = 1000, integer = true, unit = "$", label = "ADMIN_BIZ_PRICE", hint = "ADMIN_BIZ_PRICE_HINT" },
            { widget = "select", path = "ownable.priceType", source = accountsSource, label = "ADMIN_BIZ_ACCOUNT", hint = "ADMIN_BIZ_ACCOUNT_HINT" },
            canBuy,
            { widget = "switch", path = "ownable.rentUnlimited", clear = true, on = true, label = "ADMIN_BIZ_UNLIMITED", hint = "ADMIN_BIZ_UNLIMITED_HINT" },
            { widget = "number", path = "ownable.rentMoneyPercent", scale = 100, min = 0, max = 100, step = 1, decimals = 0, unit = "%", label = "ADMIN_BIZ_RENT", hint = "ADMIN_BIZ_RENT_HINT", showIf = RENTED },
            { widget = "number", path = "ownable.rentPeriodDay", min = 1, max = 365, integer = true, label = "ADMIN_BIZ_PERIOD", hint = "ADMIN_BIZ_PERIOD_HINT", showIf = RENTED },
            { widget = "number", path = "ownable.rentPayBeforeDay", min = 0, max = 365, integer = true, label = "ADMIN_BIZ_BEFORE", hint = "ADMIN_BIZ_BEFORE_HINT", showIf = RENTED },
            { widget = "number", path = "ownable.maxEmployee", min = 0, max = 500, integer = true, label = "ADMIN_BIZ_EMPLOYEES", hint = "ADMIN_BIZ_EMPLOYEES_HINT" },
            { widget = "switch", path = "ownable.canTransfer", defaultOn = true, advanced = true, label = "ADMIN_BIZ_TRANSFER", hint = "ADMIN_BIZ_TRANSFER_HINT" },
            { widget = "switch", path = "ownable.canSellBack", defaultOn = true, advanced = true, label = "ADMIN_BIZ_SELL", hint = "ADMIN_BIZ_SELL_HINT" },
            { widget = "text", path = "ownable.priceSymbol", max = 5, advanced = true, label = "ADMIN_BIZ_SYMBOL", hint = "ADMIN_BIZ_SYMBOL_HINT", placeholder = "ADMIN_BIZ_PH_SYMBOL" },
            { widget = "text", path = "ownable.noMoneyMsg", max = 200, advanced = true, label = "ADMIN_BIZ_NO_MONEY", hint = "ADMIN_BIZ_NO_MONEY_HINT", placeholder = "ADMIN_BIZ_PH_NO_MONEY" },
        } },
        { group = opts.group, icon = "user-tie", title = "ADMIN_BIZ_JOB_TITLE", desc = "ADMIN_BIZ_JOB_DESC", showIf = both(OWNED, opts.showIf), toggle = { section = "changeJob", draft = true, default = { onDuty = true, bossGrade = 0, employeeGrade = 0 } }, fields = {
            { widget = "select", path = "changeJob.name", source = "jobs", label = "ADMIN_BIZ_JOB", hint = "ADMIN_BIZ_JOB_HINT" },
            { widget = "number", path = "changeJob.bossGrade", min = 0, max = 100, integer = true, label = "ADMIN_BIZ_BOSS_GRADE", hint = "ADMIN_BIZ_BOSS_GRADE_HINT" },
            { widget = "number", path = "changeJob.employeeGrade", min = 0, max = 100, integer = true, label = "ADMIN_BIZ_EMPLOYEE_GRADE", hint = "ADMIN_BIZ_EMPLOYEE_GRADE_HINT" },
            { widget = "switch", path = "changeJob.onDuty", defaultOn = true, label = "ADMIN_BIZ_ON_DUTY", hint = "ADMIN_BIZ_ON_DUTY_HINT" },
        } },
        { group = opts.group, icon = "store", title = "ADMIN_BIZ_LISTING_TITLE", desc = "ADMIN_BIZ_LISTING_DESC", showIf = both(OWNED, opts.showIf), toggle = { section = "shopData", default = { name = opts.listingName or { en = "Business" }, subCategory = opts.subCategory or "business" } }, fields = {
            { widget = "langText", path = "shopData.name", max = 60, label = "ADMIN_BIZ_LISTING_NAME", hint = "ADMIN_BIZ_LISTING_NAME_HINT" },
            { widget = "langText", path = "shopData.description", max = 500, label = "ADMIN_BIZ_LISTING_TEXT", hint = "ADMIN_BIZ_LISTING_TEXT_HINT" },
            { widget = "text", path = "shopData.image", max = 300, mono = true, label = "ADMIN_BIZ_LISTING_IMAGE", hint = "ADMIN_BIZ_LISTING_IMAGE_HINT", placeholder = "ADMIN_BIZ_PH_URL" },
            { widget = "text", path = "shopData.subCategory", max = 50, mono = true, advanced = true, label = "ADMIN_BIZ_LISTING_CATEGORY", hint = "ADMIN_BIZ_LISTING_CATEGORY_HINT" },
        } },
    }
end

---@class AdminBusinessPanelExtra
---@field coords? vector3 where the business is (buy screen, listing)
---@field listing? table tgiannShopData used while the record has no shopData of its own

---CreateControlPanel data of a record with the block; nil when the record is not a business
---@param keyName string
---@param record table
---@param extra? AdminBusinessPanelExtra
---@return table?
function AdminPanel.Business.ControlPanelData(keyName, record, extra)
    local ownable = record.ownable
    if not ownable then return nil end
    extra = extra or {}
    local listing = record.shopData and {
        name = record.shopData.name,
        description = record.shopData.description,
        image = record.shopData.image,
        subCategory = record.shopData.subCategory,
    } or extra.listing
    if listing then listing.coords = listing.coords or extra.coords end
    return {
        keyName = keyName,
        price = ownable.price,
        priceType = ownable.priceType,
        priceSymbol = ownable.priceSymbol,
        noMoneyMsg = ownable.noMoneyMsg,
        rentMoneyPercent = ownable.rentMoneyPercent,
        rentPeriodDay = ownable.rentPeriodDay,
        rentPayBeforeDay = ownable.rentPayBeforeDay,
        rentUnlimited = ownable.rentUnlimited == true,
        canBuy = ownable.canBuy ~= false,
        canTransfer = ownable.canTransfer ~= false,
        canSellBack = ownable.canSellBack ~= false,
        canHireEmployee = true,
        maxEmployee = ownable.maxEmployee,
        changeJob = record.changeJob,
        coords = extra.coords,
        tgiannShopData = listing,
    }
end

-- Map legend group of a script's blips: { enable, id } in its settings file. GTA lists the blips of one category under
-- one heading in the pause map legend; ids 12 and up are free for scripts.
AdminPanel.Business.BlipCategory = {
    type = "object",
    fields = { enable = { type = "bool" }, id = int(12, 133) },
}

---Settings card of the legend group
---@param group? string
---@return table
function AdminPanel.Business.BlipCategoryCard(group)
    return { group = group, icon = "map-location", title = "ADMIN_BIZ_BLIPCAT_TITLE", desc = "ADMIN_BIZ_BLIPCAT_DESC", fields = {
        { widget = "switch", path = "blipCategory.enable", label = "ADMIN_BIZ_BLIPCAT_ON", hint = "ADMIN_BIZ_BLIPCAT_ON_HINT" },
        { widget = "number", path = "blipCategory.id", min = 12, max = 133, integer = true, label = "ADMIN_BIZ_BLIPCAT_ID", hint = "ADMIN_BIZ_BLIPCAT_ID_HINT", showIf = { path = "blipCategory.enable" } },
    } }
end

---Client: puts a blip into the script's legend group (setting = { enable, id }), the heading is the given text
---@param blip integer
---@param setting? { enable: boolean, id: integer }
---@param heading string
function AdminPanel.Business.ApplyBlipCategory(blip, setting, heading)
    if not setting or not setting.enable then return end
    SetBlipCategory(blip, setting.id)
    AddTextEntry(("BLIP_CAT_%d"):format(setting.id), heading)
end
