local AUTO = 'auto'

local function isStarted(res)
    return res and GetResourceState(res) == 'started'
end

-- One row per integration.
--   field      : key on Config ('Voice' is nested, see `nested`)
--   nested      : sub-key path for values not stored directly on Config
--   label       : name shown in the setup check
--   fallback    : value to use when 'auto' finds nothing (nil = stay 'auto')
--   candidates  : ordered { optionValue, resourceToProbe }.
--                 optionValue is what the framework files compare against.
--                 Several rows may share an optionValue to probe alternate
--                 resource names/casings.
CylexIntegrations = {
    {
        field = 'Garage', label = 'Garage',
        candidates = {
            { 'qb-garages',         'qb-garages' },
            { 'jg-advancedgarages', 'jg-advancedgarages' },
            { 'nation-garages',     'nation-garages' },
            { 'tgiann-realparking', 'tgiann-realparking' },
            { 'op-garages',         'op-garages' },
            { 'mGarage',            'mGarage' },
        },
    },
    {
        field = 'Housing', label = 'Housing',
        candidates = {
            { 'cylex_housing',  'cylex_housing' },
            { 'loaf_housing',   'loaf_housing' },
            { 'origen_housing', 'origen_housing' },
        },
    },
    {
        field = 'Inventory', label = 'Inventory',
        -- Without an inventory layer the phone item check breaks, so if nothing
        -- is detected we drop to 'standalone' (no item required) and warn loudly.
        fallback = 'standalone',
        builtin = { 'standalone' }, -- valid explicit values that need no resource
        candidates = {
            { 'ox_inventory',     'ox_inventory' },
            { 'qb-inventory',     'qb-inventory' },
            { 'origen_inventory', 'origen_inventory' },
            { 'tgiann-inventory', 'tgiann-inventory' },
            { 'mInventory',       'mInventory' },
        },
    },
    {
        field = 'BossMenu', label = 'Boss menu',
        candidates = {
            { 'qb-management',    'qb-management' },
            { 'qb-banking',       'qb-banking' },       -- newer qb, guard accepts it too
            { 'renewed-banking',  'renewed-banking' },
            { 'renewed-banking',  'Renewed-Banking' },  -- alternate folder casing
            { 'nation-management','nation-management' },
            { 'esx_society',      'esx_society' },
        },
    },
    {
        field = 'Voice', nested = 'Script', label = 'Voice',
        candidates = {
            { 'pma',      'pma-voice' },
            { 'mumble',   'mumble-voip' },
            { 'salty',    'saltychat' },
            { 'toko',     'tokovoip_script' },
            { 'bs-voice', 'bs-voice' },
        },
    },
}

-- Read/write helpers that understand the one nested field (Config.Voice.Script).
function CylexGetIntegration(row)
    if row.nested then
        local parent = Config[row.field]
        return parent and parent[row.nested]
    end
    return Config[row.field]
end

local function setIntegration(row, value)
    if row.nested then
        if Config[row.field] then Config[row.field][row.nested] = value end
        return
    end
    Config[row.field] = value
end

-- Resolve a row; return a short "Label=value" tag on success/fallback, or nil.
-- Problems (nothing detected, no fallback) print their own one-off warn line.
local function resolve(row)
    local current = CylexGetIntegration(row)
    if current ~= AUTO then
        return -- explicit choice, respect it (not shown)
    end

    for _, c in ipairs(row.candidates) do
        if isStarted(c[2]) then
            setIntegration(row, c[1])
            return ('%s=%s'):format(row.label, c[1])
        end
    end

    if row.fallback then
        setIntegration(row, row.fallback)
        return ('%s=%s(fallback)'):format(row.label, row.fallback)
    end

    -- stays 'auto'; framework guards stay inert; doctor will warn
    print(('^3[cylex_phone] Could not auto-detect %s, set it manually.^0'):format(row.label))
end

if Config then
    local detected = {}
    for _, row in ipairs(CylexIntegrations) do
        local tag = resolve(row)
        if tag then detected[#detected + 1] = tag end
    end
    if #detected > 0 then
        print(('^2[cylex_phone] Auto-detected: %s^0'):format(table.concat(detected, ', ')))
    end
end
