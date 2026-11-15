local lib = lib


-- ============================================
-- Blip Configuration
-- ============================================
local BlipConfig = {
    gunshop = {
        sprite = 110,
        color = 40,
        scale = 0.7,
        label = 'Silah Dükkanı',
        coords = 'silahcikordinat',
        enabled = false
    },
    clothes = {
        sprite = 366,
        color = 46,
        scale = 0.6,
        label = 'Kıyafet Dükkanı',
        coords = 'clotheShops',
        enabled = false
    },
    barber = {
        sprite = 71,
        color = 46,
        scale = 0.6,
        label = 'Berber Dükkanı',
        coords = 'barberShops',
        enabled = false
    },
    market = {
        sprite = 59,
        color = 69,
        scale = 0.6,
        label = 'Market',
        coords = 'Market',
        enabled = false
    },
    benzin = {
        sprite = 361,
        color = 47,
        scale = 0.5,
        label = 'Benzin İstasyonu',
        coords = 'BenzinS',
        enabled = false
    },
    garaj = {
        sprite = 357,
        color = 82,
        scale = 0.5,
        label = 'Garaj',
        coords = 'GarajS',
        enabled = false
    },
    -- Numarasiz garajlar (helikopter garajlari, Garaj Kolej, cete ve cekme otoparki): isletme degiller, ihalede yoklar.
    -- Her biri kendi adiyla, helikopter garaji helikopter simgesiyle gorunur.
    ozelgaraj = {
        sprite = 357,
        color = 3,
        scale = 0.5,
        label = 'Özel Garaj',
        coords = 'OzelGarajS',
        enabled = false
    },
    -- 0r-activities isaretlerini burasi cizer (0r-activities'in kendi isaretleri kapali); yer, simge ve ad
    -- 0r-activities'in config'inden gelir (exports['0r-activities']:GetActivityBlips()).
    aktiviteler = {
        sprite = 266,
        color = 3,
        scale = 0.75,
        label = 'Aktivite',
        coords = 'AktiviteS',
        enabled = false
    },
    seagaraj = {
        sprite = 356,
        color = 82,
        scale = 0.5,
        label = 'Tekne Garajı',
        coords = 'SeaS',
        enabled = false
    },
    tattos = {
        sprite = 75,
        color = 75,
        scale = 0.5,
        label = 'Dövme Dükkanı',
        coords = 'tattos',
        enabled = false
    },
    yikama = {
        sprite = 100,
        color = 3,
        scale = 0.65,
        label = 'Araç Yıkama',
        coords = 'YikamaS',
        enabled = false
    },
}

-- ============================================
-- Active Blips Storage
-- ============================================
local ActiveBlips = {}

-- ============================================
-- Helper Functions
-- ============================================

--- Create a single blip on the map
--- @param coords vector3 - Coordinates for the blip
--- @param sprite number - Blip sprite ID
--- @param color number - Blip color
--- @param scale number - Blip scale
--- @param label string - Blip label
--- @return number - Blip handle
-- Numbered places ("Garaj #59"): GTA gets the shared name ("Garaj"), the pause menu the numbered one through
-- SetBlipMeta. GTA's own map legend has a row per name; a row per garage, station and shop made it so long that the
-- pause menu's map-pan helper row fell out of it and the map no longer moved to the place picked in the list.
local function PauseLabel(blip, label)
    if GetResourceState('daddy_pausemenu') ~= 'started' then return end
    pcall(function() exports['daddy_pausemenu']:SetBlipMeta(blip, { label = label }) end)
end

local function CreateBlip(coords, sprite, color, scale, label)
    local numbered = type(label) == 'string' and label:match('^(.-)%s*#%d+$')
    if numbered and numbered ~= '' then
        local blip = CreateBlip(coords, sprite, color, scale, numbered)
        PauseLabel(blip, label)
        return blip
    end
    local blip = AddBlipForCoord(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- ============================================
-- Coordinate Tables
-- ============================================
silahcikordinat = {
    vector3(-659.04, -938.83, 21.83),  -- uwu yakını
    vector3(18.30, -1107.94, 29.80),   -- galeri yanı
    vector3(-3172.16, 1087.05, 20.84), -- sahil sasp altı blanco mekanik üstü
    vector3(247.97, -51.81, 69.94),    -- motel üstü
    vector3(-1316.43, -389.97, 36.45), -- motel arkası
    vector3(812.3385, -2146.1985, 29.3739), -- liman yakını
}

tattos = {
    vector3(-112.2402, -12.2316, 70.5195),
    vector3(-1154.99, -1427.23, 4.95),
    vector3(323.20, 180.82, 103.59),
    vector3(1865.1566, 3747.1926, 33.0318),
    vector3(-3170.9092, 1075.3573, 20.8292),
    vector3(1324.0079, -1653.1140, 52.2756),
    vector3(2515.9431, 4104.1152, 38.5846)
}

clotheShops = {}
barberShops = {}
Market = {}
BenzinS = {}
GarajS = {}
OzelGarajS = {}
AktiviteS = {}
SeaS = {}
YikamaS = {}

-- ============================================
-- Updaters
-- ============================================

local function UpdateGarageCoords()
    if GetResourceState('jg-advancedgarages') == 'started' then
        local garages = exports['jg-advancedgarages']:getAvailableGarageLocations()
        if garages and type(garages) == 'table' and #garages > 0 then
            GarajS = {}
            OzelGarajS = {}
            SeaS = {}
            for _, garage in pairs(garages) do
                if garage and garage.coords then
                    -- "Garaj N": ihaledeki isletme garaji (can9work-auction garage_N). Digerleri ozel garaj.
                    -- Numara garajin adindan: "Garaj 59" ihaledeki garage_59, blipte de "Garaj #59" (NPC ve tabletle ayni).
                    local number = tostring(garage.name or ''):match('(%d+)$')
                    local business = (garage.type == 'car' or not garage.type) and number
                    if business then
                        GarajS[#GarajS + 1] = { coords = garage.coords, label = ('Garaj #%s'):format(number) }
                    elseif garage.type == 'car' or garage.type == 'air' or not garage.type then
                        OzelGarajS[#OzelGarajS + 1] = { coords = garage.coords, label = garage.label or garage.name, sprite = garage.type == 'air' and 43 or nil }
                    elseif garage.type == 'sea' then
                        SeaS[#SeaS + 1] = { coords = garage.coords, label = number and ('Tekne Garajı #%s'):format(number) or garage.label or garage.name }
                    end
                end
            end
        end
    end
end

local function UpdateActivityCoords()
    if GetResourceState('0r-activities') == 'started' then
        local ok, list = pcall(function() return exports['0r-activities']:GetActivityBlips() end)
        if ok and type(list) == 'table' then AktiviteS = list end
    end
end

local function UpdateFuelCoords()
    if GetResourceState('savana-fuel') == 'started' then
        local stations = exports['savana-fuel']:GetStationCoords()
        if stations and type(stations) == 'table' then
            BenzinS = {}
            for k, coords in pairs(stations) do
                BenzinS[k] = coords
            end
        end
    end
end

local function UpdateMarketCoords()
    if GetResourceState('cloud-shop') == 'started' then
        local shops = exports['cloud-shop']:GetShopCoords()
        if shops and type(shops) == 'table' then
            Market = {}
            for k, coords in pairs(shops) do
                Market[k] = coords
            end
        end
    end
end

local function UpdateClothingCoords()
    if GetResourceState('illenium-appearance') == 'started' then
        local clothes = exports['illenium-appearance']:GetStoreCoordsByType('clothing')
        if clothes and type(clothes) == 'table' then
            clotheShops = {}
            for k, coords in pairs(clothes) do
                clotheShops[k] = coords
            end
        end

        local barbers = exports['illenium-appearance']:GetStoreCoordsByType('barber')
        if barbers and type(barbers) == 'table' then
            barberShops = {}
            for k, coords in pairs(barbers) do
                barberShops[k] = coords
            end
        end
    end
end

local function UpdateCarwashCoords()
    if GetResourceState('can9work-carwash') == 'started' then
        local washes = exports['can9work-carwash']:GetCarwashCoords()
        if washes and type(washes) == 'table' then
            YikamaS = {}
            for k, coords in pairs(washes) do
                YikamaS[k] = coords
            end
        end
    end
end

-- Isletme bliplerinin numarasi can9work-auction'daki numarayla ayni ("Market #3", "Kıyafet Dükkanı #7"): ihalenin konum
-- listesinde 30 m icindeki isletmenin numarasi alinir; ihalede olmayan (ya da ihale kapaliyken) blip numarasiz kalir.
-- Ad hep "<tur adi> #N": pause menu ayni adli blipleri tek satirda toplar, numarayi secilen yerde gosterir.
local BUSINESS_KIND = { market = 'market', clothes = 'clothing', barber = 'barber', benzin = 'gas', yikama = 'wash' }
local siteLabels = nil

local function LoadSiteLabels()
    if GetResourceState('can9work-auction') ~= 'started' then siteLabels = nil return end
    local ok, list = pcall(function() return lib.callback.await('can9work-auction/server/siteLabels', false) end)
    siteLabels = ok and type(list) == 'table' and list or nil
end

local function BusinessLabel(blipType, coords)
    local kind = BUSINESS_KIND[blipType]
    if not kind or not siteLabels or not coords then return nil end
    local x, y = coords.x or coords[1], coords.y or coords[2]
    local best, bestDist = nil, 30.0
    for _, site in ipairs(siteLabels) do
        if site.type == kind then
            local d = math.sqrt((site.x - x) ^ 2 + (site.y - y) ^ 2)
            if d < bestDist then best, bestDist = tostring(site.label):match('#(%d+)$'), d end
        end
    end
    return best
end

local function InitializeBlips()
    UpdateFuelCoords()
    UpdateMarketCoords()
    UpdateClothingCoords()
    UpdateCarwashCoords()
    UpdateGarageCoords()
end

--- Toggle blips for a specific type
--- @param blipType string - The type of blip to toggle
--- @param silent boolean? - If true, skip notifications
local function ToggleBlips(blipType, silent)
    local config = BlipConfig[blipType]
    if not config then
        print("^1[ERROR] Invalid blip type: " .. tostring(blipType) .. "^7")
        return
    end

    config.enabled = not config.enabled

    if config.enabled then
        if BUSINESS_KIND[blipType] then LoadSiteLabels() end
        if blipType == 'garaj' or blipType == 'seagaraj' or blipType == 'ozelgaraj' then
            UpdateGarageCoords()
        elseif blipType == 'aktiviteler' then
            UpdateActivityCoords()
        elseif blipType == 'benzin' and next(BenzinS) == nil then
            UpdateFuelCoords()
        elseif blipType == 'market' and next(Market) == nil then
            UpdateMarketCoords()
        elseif (blipType == 'clothes' or blipType == 'barber') and (next(clotheShops) == nil or next(barberShops) == nil) then
            UpdateClothingCoords()
        elseif blipType == 'yikama' and next(YikamaS) == nil then
            UpdateCarwashCoords()
        end

        ActiveBlips[blipType] = {}
        local coordsList = _G[config.coords]

        if coordsList and type(coordsList) == 'table' then
            for k, coords in pairs(coordsList) do
                -- { coords, label, sprite, colour, scale } girdisi kendi adi ve gorunumuyle cizilir
                local entry = type(coords) == 'table' and coords.coords and coords or nil
                local number = not entry and BusinessLabel(blipType, coords)
                local blip = entry and CreateBlip(entry.coords, entry.sprite or config.sprite, entry.colour or config.color, entry.scale or config.scale, entry.label or config.label)
                    or CreateBlip(coords, config.sprite, config.color, config.scale, number and ('%s #%s'):format(config.label, number) or config.label)
                ActiveBlips[blipType][k] = blip
            end
            if not silent then
                lib.notify({ description = locale('success.blips_activated', { label = config.label }), type = 'success' })
            end
        else
            print("^1[ERROR] Coordinate list not found: " .. tostring(config.coords) .. "^7")
        end
    else
        if ActiveBlips[blipType] then
            for _, blip in pairs(ActiveBlips[blipType]) do
                if DoesBlipExist(blip) then
                    -- the numbered label goes with the blip: GTA gives its handle to the next new blip
                    pcall(function() exports['daddy_pausemenu']:ClearBlipMeta(blip) end)
                    RemoveBlip(blip)
                end
            end
            ActiveBlips[blipType] = {}
        end
        if not silent then
            lib.notify({ description = locale('error.blips_deactivated', { label = config.label }), type = 'error' })
        end
    end
end

-- ============================================
-- Event Handlers
-- ============================================

RegisterNetEvent('blips:toggleGunShop', function()
    ToggleBlips('gunshop')
end)

RegisterNetEvent('blips:toggleClothes', function()
    ToggleBlips('clothes')
end)

RegisterNetEvent('blips:toggleBarber', function()
    ToggleBlips('barber')
end)

RegisterNetEvent('blips:toggleMarket', function()
    ToggleBlips('market')
end)

RegisterNetEvent('blips:toggleBenzin', function()
    ToggleBlips('benzin')
end)

RegisterNetEvent('blips:toggleGaraj', function()
    ToggleBlips('garaj')
end)

RegisterNetEvent('blips:toggleAktiviteler', function()
    ToggleBlips('aktiviteler')
end)

RegisterNetEvent('blips:toggleOzelGaraj', function()
    ToggleBlips('ozelgaraj')
end)

RegisterNetEvent('blips:toggleSeaGaraj', function()
    ToggleBlips('seagaraj')
end)

RegisterNetEvent('blips:toggleTattos', function()
    ToggleBlips('tattos')
end)

RegisterNetEvent('blips:toggleYikama', function()
    ToggleBlips('yikama')
end)

RegisterNetEvent('blips:toggleAll', function()
    local anyActive = false
    for _, cfg in pairs(BlipConfig) do
        if cfg.enabled then
            anyActive = true
            break
        end
    end

    local targetState = not anyActive
    for blipType, cfg in pairs(BlipConfig) do
        if cfg.enabled ~= targetState then
            ToggleBlips(blipType, true)
        end
    end

    if anyActive then
        lib.notify({ description = 'Tüm blipler kapatıldı.', type = 'error' })
    else
        lib.notify({ description = 'Tüm blipler açıldı.', type = 'success' })
    end
end)

-- Update on resource start/stop if needed or just use command
RegisterNetEvent('blips:refresh', function()
    InitializeBlips()
    lib.notify({ description = 'Blipler güncellendi.', type = 'inform' })
end)

-- Initialize on load
CreateThread(function()
    Wait(1000)
    InitializeBlips()
end)
