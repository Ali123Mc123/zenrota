local product = {}

local function say(text, ...) print(('[%s] ' .. text):format(DL.resource, ...)) end

-- One bridge call for `daddy check`: what it answered, or the error.
local function try(label, fn)
    local ok, result, extra = pcall(fn)
    if not ok then return say('^1%s failed: %s^7', label, result) end
    say('%s: %s', label, type(result) == 'table' and ('%d rows'):format(extra or #result) or tostring(result))
end

-- Clothing and housing scripts found; what would break a character selector only when one (multichar) is installed.
local function checkCharacters()
    local homes = DL.housing.ids
    say('appearance %s, housing %s', DL.appearance.current(), #homes > 0 and table.concat(homes, ', ') or 'none')
    if not (GlobalState['daddy_lib:products'] or {}).multichar then return end
    local found = DL.chars.conflicts()
    if #found == 0 then return say('characters: no conflicts') end
    for _, item in ipairs(found) do
        say('%scharacters %s %s: %s^7', item.level == 'error' and '^1' or '^3', item.level, item.code, item.text)
    end
end

-- What the framework bridge sees on this server; asked of one product only.
local function checkBridge()
    local fw = DL.fw
    say('framework %s, inventory %s', fw.id, DL.inv.id)
    try('jobs', function()
        local count = 0
        for _ in pairs(fw.jobs() or {}) do count = count + 1 end
        return count
    end)
    -- '__' is any two characters to SQL LIKE, so the search returns the first characters there are.
    try('character search', function() return fw.searchCharacters('__', 5) end)
    local first = (fw.searchCharacters('__', 1) or {})[1]
    if first then try('character ' .. first.citizenid, function() return (fw.character(first.citizenid) or {}).name end) end
    try('vehicle search', function() return fw.searchVehicles('__', 5, 0) end)
    local car = (fw.searchVehicles('__', 1, 0) or {})[1]
    if car then try('vehicle ' .. car.plate, function() return (fw.ownedVehicle(car.plate) or {}).owner end) end
    local ok, err = pcall(checkCharacters)
    if not ok then say('^1characters check failed: %s^7', err) end
end

-- Usable items this product registered that the inventory does not know.
local function checkItems()
    local inv = rawget(DL, 'inv')
    if not inv then return end
    local missing = {}
    for _, item in ipairs(inv.usable) do
        if not inv.definition(item) then missing[#missing + 1] = item end
    end
    if #missing > 0 then say('^3items missing from %s: %s^7', inv.id, table.concat(missing, ', ')) end
end

-- Registers this resource with daddy_lib and waits for the shared tables.
function product.register(id, minimumLib)
    if not exports.daddy_lib:registerProduct(id, minimumLib or '1.0.0') then
        error(('%s cannot run on daddy_lib %s'):format(DL.resource, DL.VERSION))
    end
    product.id = id
    AddEventHandler('daddy_lib:check', function(bridge)
        if bridge == DL.resource then checkBridge() end
        checkItems()
    end)
end

function product.awaitLib()
    while not exports.daddy_lib:isReady() do Wait(100) end
end

return product
