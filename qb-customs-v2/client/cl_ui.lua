-----------------------
----   Locales     ----
-----------------------
localeData = {}

local function loadLocales()
    local lang = Config and Config.Locale or GetConvar("locale", "tr")
    local path = "locales/" .. lang .. ".json"
    local f = LoadResourceFile(GetCurrentResourceName(), path)
    if not f then
        f = LoadResourceFile(GetCurrentResourceName(), "locales/tr.json")
    end
    if f then
        localeData = json.decode(f) or {}
    end
end

function L(key)
    return localeData[key] or key
end

-- Maps config.lua vehicleCustomisation category strings to locale keys
-- Menu routing keys (used in gsub) must NOT change — only display labels change
local categoryLocaleMap = {
    ["Spoiler"]              = "spoiler",
    ["Front Bumper"]         = "front_bumper",
    ["Rear Bumper"]          = "rear_bumper",
    ["Side Skirt"]           = "side_skirt",
    ["Exhaust"]              = "exhaust",
    ["Roll Cage"]            = "roll_cage",
    ["Grille"]               = "grille",
    ["Hood"]                 = "hood",
    ["Left Fender"]          = "left_fender",
    ["Right Fender"]         = "right_fender",
    ["Roof"]                 = "roof",
    ["Engine Upgrade"]       = "engine_upgrade",
    ["Brake Upgrade"]        = "brake_upgrade",
    ["Transmission Upgrade"] = "transmission_upgrade",
    ["Suspension Upgrade"]   = "suspension_upgrade",
    ["Armour Upgrade"]       = "armour_upgrade",
    ["Turbo Upgrade"]        = "turbo_upgrade",
    ["Vanity Plates"]        = "vanity_plates",
    ["Trim A"]               = "trim_a",
    ["Ornaments"]            = "ornaments",
    ["Dashboard"]            = "dashboard",
    ["Dial"]                 = "dial",
    ["Door Speaker"]         = "door_speaker",
    ["Seats"]                = "seats",
    ["Steering Wheel"]       = "steering_wheel",
    ["Shifter Leaver"]       = "shifter_lever",
    ["Plaque"]               = "plaque",
    ["Speaker"]              = "speaker",
    ["Trunk"]                = "trunk",
    ["Hydraulic"]            = "hydraulic",
    ["Engine Block"]         = "engine_block",
    ["Air Filter"]           = "air_filter",
    ["Strut"]                = "strut",
    ["Arch Cover"]           = "arch_cover",
    ["Aerial"]               = "aerial",
    ["Trim B"]               = "trim_b",
    ["Fuel Tank"]            = "fuel_tank",
    ["Window"]               = "window",
    ["Livery"]               = "livery_mod",
    ["Horns"]                = "horns",
}

-- Returns translated display label for a category; menu key (gsub) stays the original English
local function LC(category)
    local key = categoryLocaleMap[category]
    if key then return L(key) end
    return category
end

-- Display-only labels for wheel / respray categories (routing keys stay English)
local displayLabelMap = {
    ["Custom Tyres"] = "Özel Lastikler", ["Tyre Smoke"] = "Lastik Dumanı", ["Sport"] = "Spor", ["Muscle"] = "Muscle",
    ["Lowrider"] = "Lowrider", ["SUV"] = "SUV", ["Offroad"] = "Arazi", ["Tuner"] = "Tuner", ["Motorcycle"] = "Motosiklet",
    ["Highend"] = "Lüks", ["BennysWheel"] = "Benny's Jant", ["BespokeWheel"] = "Özel Yapım Jant", ["Dragster"] = "Dragster",
    ["Street"] = "Sokak", ["Rally"] = "Ralli",
    ["Classic"] = "Klasik", ["Metallic"] = "Metalik", ["Matte"] = "Mat", ["Metals"] = "Metal",
}

function CustomsLabel(category)
    if displayLabelMap[category] then return displayLabelMap[category] end
    return LC(category)
end

loadLocales()

-----------------------
----   Variables   ----
-----------------------
local currentMenuItemID = 0
local currentMenuItem = ""
-- Maps mainMenu item ID → real English-based menu key (routing safe, locale-independent)
local vehicleMenuMap = {}
local currentMenuItem2 = ""
local currentMenu = "mainMenu"
local currentCategory = 0
local currentResprayCategory = 0
local currentResprayType = 0
local currentWheelCategory = 0
local currentNeonSide = 0

-----------------------
----   Functions   ----
-----------------------

local function toggleMenuContainer(state)
    SendNUIMessage({
        toggleMenuContainer = true,
        state = state
    })
end

local function createMenu(menu, heading, subheading)
    SendNUIMessage({
        createMenu = true,
        menu = menu,
        heading = heading,
        subheading = subheading
    })
end

local function destroyMenus()
    SendNUIMessage({
        destroyMenus = true
    })
end

local function populateMenu(menu, id, item, item2)
    SendNUIMessage({
        populateMenu = true,
        menu = menu,
        id = id,
        item = item,
        item2 = item2
    })
end

local function finishPopulatingMenu(menu)
    SendNUIMessage({
        finishPopulatingMenu = true,
        menu = menu
    })
end

local function updateMenuHeading(menu)
    SendNUIMessage({
        updateMenuHeading = true,
        menu = menu
    })
end

local function updateMenuSubheading(menu)
    SendNUIMessage({
        updateMenuSubheading = true,
        menu = menu
    })
end

local function updateMenuStatus(text)
    SendNUIMessage({
        updateMenuStatus = true,
        statusText = text
    })
end

local function toggleMenu(state, menu)
    SendNUIMessage({
        toggleMenu = true,
        state = state,
        menu = menu
    })
end

local function updateItem2Text(menu, id, text)
    SendNUIMessage({
        updateItem2Text = true,
        menu = menu,
        id = id,
        item2 = text
    })
end

local function updateItem2TextOnly(menu, id, text)
    SendNUIMessage({
        updateItem2TextOnly = true,
        menu = menu,
        id = id,
        item2 = text
    })
end

local function scrollMenuFunctionality(direction, menu)
    SendNUIMessage({
        scrollMenuFunctionality = true,
        direction = direction,
        menu = menu
    })
end

local function playSoundEffect(soundEffect, volume)
    SendNUIMessage({
        playSoundEffect = true,
        soundEffect = soundEffect,
        volume = volume
    })
end

local function isMenuActive(menu)
    local menuActive = false

    if menu == "modMenu" then
        for _, v in pairs(vehicleCustomisation) do
            if (v.category:gsub("%s+", "") .. "Menu") == currentMenu then
                menuActive = true

                break
            else
                menuActive = false
            end
        end
    elseif menu == "ResprayMenu" then
        for _, v in pairs(vehicleResprayOptions) do
            if (v.category:gsub("%s+", "") .. "Menu") == currentMenu then
                menuActive = true

                break
            else
                menuActive = false
            end
        end
    elseif menu == "WheelsMenu" then
        for _, v in pairs(vehicleWheelOptions) do
            if (v.category:gsub("%s+", "") .. "Menu") == currentMenu then
                menuActive = true

                break
            else
                menuActive = false
            end
        end
    elseif menu == "NeonsSideMenu" then
        for _, v in pairs(vehicleNeonOptions.neonTypes) do
            if (v.name:gsub("%s+", "") .. "Menu") == currentMenu then
                menuActive = true

                break
            else
                menuActive = false
            end
        end
    end

    return menuActive
end

local function updateCurrentMenuItemID(id, item, item2)
    currentMenuItemID = id
    currentMenuItem = item
    currentMenuItem2 = item2

    if isMenuActive("modMenu") then
        if currentCategory ~= 18 then
            PreviewMod(currentCategory, currentMenuItemID)
        end
    elseif isMenuActive("ResprayMenu") then
        PreviewColour(currentResprayCategory, currentResprayType, currentMenuItemID)
    elseif isMenuActive("WheelsMenu") then
        if currentWheelCategory ~= -1 and currentWheelCategory ~= 20 then
            PreviewWheel(currentCategory, currentMenuItemID, currentWheelCategory)
        end
    elseif isMenuActive("NeonsSideMenu") then
        PreviewNeon(currentNeonSide, currentMenuItemID)
    elseif currentMenu == "WindowTintMenu" then
        PreviewWindowTint(currentMenuItemID)
    elseif currentMenu == "NeonColoursMenu" then
        local r = vehicleNeonOptions.neonColours[currentMenuItemID].r
        local g = vehicleNeonOptions.neonColours[currentMenuItemID].g
        local b = vehicleNeonOptions.neonColours[currentMenuItemID].b

        PreviewNeonColour(r, g, b)
    elseif currentMenu == "XenonColoursMenu" then
        PreviewXenonColour(currentMenuItemID)
    elseif currentMenu == "OldLiveryMenu" then
        PreviewOldLivery(currentMenuItemID)
    elseif currentMenu == "PlateIndexMenu" then
        PreviewPlateIndex(currentMenuItemID)
    end
end

function InitiateMenus(isMotorcycle, vehicleHealth, categories, welcomeLabel)
    local plyPed = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    --#[Repair Menu]#--
    if vehicleHealth < 1000.0 and categories.repair then
        local repairCost = 0

        TriggerServerEvent("qb-customs:server:updateRepairCost", repairCost)
        createMenu("repairMenu", welcomeLabel, L("vehicle_repair"))
        populateMenu("repairMenu", -1, L("repair_vehicle"), "$" .. repairCost)
        finishPopulatingMenu("repairMenu")
    end

    --#[Main Menu]#--
    vehicleMenuMap = {} -- reset on each InitiateMenus call
    createMenu("mainMenu", welcomeLabel, L("category_select"))

    for _, v in ipairs(vehicleCustomisation) do
        local _, amountValidMods = CheckValidMods(v.category, v.id)

        if amountValidMods > 0 or v.id == 18 then
            if (v.id == 11 or v.id == 12 or v.id == 13 or v.id == 15) then
                if categories.mods and maxVehiclePerformanceUpgrades ~= -1 then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            elseif v.id == 16 then
                if categories.armor then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            elseif v.id == 14 then
                if categories.horn then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            elseif v.id == 18 then
                if categories.turbo then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            elseif v.id == 48 then
                if categories.liveries then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            else
                if categories.cosmetics then
                    vehicleMenuMap[v.id] = v.category:gsub("%s+", "") .. "Menu"
                    populateMenu("mainMenu", v.id, LC(v.category), "none")
                end
            end
        end
    end

    if categories.respray then populateMenu("mainMenu", -1, L("paint"), "none") end

    if not isMotorcycle then
        if categories.tint then populateMenu("mainMenu", -2, L("window_tint"), "none") end
        if categories.neons then populateMenu("mainMenu", -3, L("neons"), "none") end
    end

    if categories.xenons then populateMenu("mainMenu", 22, L("xenons"), "none") end
    if categories.wheels then populateMenu("mainMenu", 23, L("wheels"), "none") end

    local livCount = GetVehicleLiveryCount(plyVeh)
    if livCount > 0 and categories.liveries then
        populateMenu("mainMenu", 24, L("old_livery"), "none")
    end

    if categories.plate then populateMenu("mainMenu", 25, L("plate_colour"), "none") end
    if categories.extras then populateMenu("mainMenu", 26, L("vehicle_extras"), "none") end

    finishPopulatingMenu("mainMenu")

    --#[Mods Menu]#--
    for _, v in ipairs(vehicleCustomisation) do
        local validMods, amountValidMods = CheckValidMods(v.category, v.id)
        local currentMod, _ = GetCurrentMod(v.id)

        if amountValidMods > 0 or v.id == 18 then
            if v.id == 11 or v.id == 12 or v.id == 13 or v.id == 15 or v.id == 16 then --Performance Upgrades
                local tempNum = 0

                createMenu(v.category:gsub("%s+", "") .. "Menu", LC(v.category), L("upgrade_select"))

                for _, n in pairs(validMods) do
                    tempNum = tempNum + 1

                    if maxVehiclePerformanceUpgrades == 0 then
                        populateMenu(v.category:gsub("%s+", "") .. "Menu", n.id, n.name,
                            "$" .. vehicleCustomisationPrices.performance.prices[tempNum])

                        if currentMod == n.id then
                            updateItem2Text(v.category:gsub("%s+", "") .. "Menu", n.id, L("installed"))
                        end
                    else
                        if tempNum <= (maxVehiclePerformanceUpgrades + 1) then
                            populateMenu(v.category:gsub("%s+", "") .. "Menu", n.id, n.name,
                                "$" .. vehicleCustomisationPrices.performance.prices[tempNum])

                            if currentMod == n.id then
                                updateItem2Text(v.category:gsub("%s+", "") .. "Menu", n.id, L("installed"))
                            end
                        end
                    end
                end

                finishPopulatingMenu(v.category:gsub("%s+", "") .. "Menu")
            elseif v.id == 18 then
                local currentTurboState = GetCurrentTurboState()
                createMenu(v.category:gsub("%s+", "") .. "Menu", LC(v.category) .. " " .. L("customisation"),
                    L("turbo_toggle"))

                populateMenu(v.category:gsub("%s+", "") .. "Menu", -1, L("turbo_off"), "$0")
                populateMenu(v.category:gsub("%s+", "") .. "Menu", 0, L("turbo_on"),
                    "$" .. vehicleCustomisationPrices.turbo.prices[2])

                updateItem2Text(v.category:gsub("%s+", "") .. "Menu", currentTurboState, L("installed"))

                finishPopulatingMenu(v.category:gsub("%s+", "") .. "Menu")
            else
                createMenu(v.category:gsub("%s+", "") .. "Menu", LC(v.category) .. " " .. L("customisation"),
                    L("modification_select"))

                for _, n in pairs(validMods) do
                    populateMenu(v.category:gsub("%s+", "") .. "Menu", n.id, n.name,
                        "$" .. vehicleCustomisationPrices.cosmetics.price)

                    if currentMod == n.id then
                        updateItem2Text(v.category:gsub("%s+", "") .. "Menu", n.id, L("installed"))
                    end
                end

                finishPopulatingMenu(v.category:gsub("%s+", "") .. "Menu")
            end
        end
    end

    --#[Respray Menu]#--
    createMenu("ResprayMenu", L("paint"), L("colour_category_select"))

    populateMenu("ResprayMenu", 0, L("primary_colour"), "none")
    populateMenu("ResprayMenu", 1, L("secondary_colour"), "none")
    populateMenu("ResprayMenu", 2, L("pearlescent_colour"), "none")
    populateMenu("ResprayMenu", 3, L("wheel_colour"), "none")
    populateMenu("ResprayMenu", 4, L("interior_colour"), "none")
    populateMenu("ResprayMenu", 5, L("dashboard_colour"), "none")

    finishPopulatingMenu("ResprayMenu")

    --#[Respray Types]#--
    createMenu("ResprayTypeMenu", L("paint_types"), L("colour_type_select"))

    for _, v in ipairs(vehicleResprayOptions) do
        populateMenu("ResprayTypeMenu", v.id, CustomsLabel(v.category), "none")
    end

    finishPopulatingMenu("ResprayTypeMenu")

    --#[Respray Colours]#--
    for _, v in ipairs(vehicleResprayOptions) do
        local menuName = v.category:gsub("%s+", "") .. "Menu"

        createMenu(menuName, CustomsLabel(v.category) .. " " .. L("colours"), L("colour_select"))

        for _, n in ipairs(v.colours) do
            populateMenu(menuName, n.id, n.name, "$" .. vehicleCustomisationPrices.respray.price)
        end

        finishPopulatingMenu(menuName)
    end

    --#[Wheel Categories Menu]#--
    createMenu("WheelsMenu", L("wheels"), L("wheel_category_select"))

    for _, v in ipairs(vehicleWheelOptions) do
        if isMotorcycle then
            if v.id == -1 or v.id == 20 or v.id == 6 then --Motorcycle Wheels
                populateMenu("WheelsMenu", v.id, CustomsLabel(v.category), "none")
            end
        else
            populateMenu("WheelsMenu", v.id, CustomsLabel(v.category), "none")
        end
    end

    finishPopulatingMenu("WheelsMenu")

    --#[Wheels Menu]#--
    for _, v in ipairs(vehicleWheelOptions) do
        if v.id == -1 then
            local currentCustomWheelState = GetCurrentCustomWheelState()
            createMenu(v.category:gsub("%s+", "") .. "Menu", CustomsLabel(v.category), L("custom_tyre_toggle"))

            populateMenu(v.category:gsub("%s+", "") .. "Menu", 0, L("off"), "$0")
            populateMenu(v.category:gsub("%s+", "") .. "Menu", 1, L("on"),
                "$" .. vehicleCustomisationPrices.customwheels.price)

            updateItem2Text(v.category:gsub("%s+", "") .. "Menu", currentCustomWheelState, L("installed"))

            finishPopulatingMenu(v.category:gsub("%s+", "") .. "Menu")
        elseif v.id ~= 20 then
            if isMotorcycle then
                if v.id == 6 then --Motorcycle Wheels
                    local validMods, _ = CheckValidMods(v.category, v.wheelID, v.id)
                    local menuName = v.category:gsub("%s+", "") .. "Menu"

                    createMenu(menuName, CustomsLabel(v.category) .. " " .. L("wheels_suffix"), L("wheel_select"))

                    for _, n in pairs(validMods) do
                        populateMenu(menuName, n.id, n.name, "$" .. vehicleCustomisationPrices.wheels.price)
                    end

                    finishPopulatingMenu(menuName)
                end
            else
                local validMods, _ = CheckValidMods(v.category, v.wheelID, v.id)
                local menuName = v.category:gsub("%s+", "") .. "Menu"

                createMenu(menuName, CustomsLabel(v.category) .. " " .. L("wheels_suffix"), L("wheel_select"))

                for _, n in pairs(validMods) do
                    populateMenu(menuName, n.id, n.name, "$" .. vehicleCustomisationPrices.wheels.price)
                end

                finishPopulatingMenu(menuName)
            end
        end
    end

    --#[Wheel Smoke Menu]#--
    local currentWheelSmokeR, currentWheelSmokeG, currentWheelSmokeB = GetCurrentVehicleWheelSmokeColour()
    createMenu("TyreSmokeMenu", L("customisation"), L("colour_select"))

    for k, v in ipairs(vehicleTyreSmokeOptions) do
        populateMenu("TyreSmokeMenu", k, v.name, "$" .. vehicleCustomisationPrices.wheelsmoke.price)

        if v.r == currentWheelSmokeR and v.g == currentWheelSmokeG and v.b == currentWheelSmokeB then
            updateItem2Text("TyreSmokeMenu", k, L("installed"))
        end
    end

    finishPopulatingMenu("TyreSmokeMenu")

    --#[Window Tint Menu]#--
    local currentWindowTint = GetCurrentWindowTint()
    createMenu("WindowTintMenu", L("window_tint") .. " " .. L("customisation"), L("filter_select"))

    for _, v in ipairs(vehicleWindowTintOptions) do
        populateMenu("WindowTintMenu", v.id, v.name, "$" .. vehicleCustomisationPrices.windowtint.price)

        if currentWindowTint == v.id then
            updateItem2Text("WindowTintMenu", v.id, L("installed"))
        end
    end

    finishPopulatingMenu("WindowTintMenu")

    --#[Old Livery Menu]#--
    if livCount > 0 then
        local tempOldLivery = GetVehicleLivery(plyVeh)
        createMenu("OldLiveryMenu", L("old_livery") .. " " .. L("customisation"), L("livery_select"))
        for i = 0, livCount - 1 do
            populateMenu("OldLiveryMenu", i, L("livery"), "$100")
            if tempOldLivery == i then
                updateItem2Text("OldLiveryMenu", i, L("installed"))
            end
        end
        finishPopulatingMenu("OldLiveryMenu")
    end

    --#[Plate Colour Index Menu]#--

    local tempPlateIndex = GetVehicleNumberPlateTextIndex(plyVeh)
    createMenu("PlateIndexMenu", L("plate_colour"), L("style_select"))
    local plateTypes = {
        "Beyaz Üzeri Mavi #1",
        "Siyah Üzeri Sarı",
        "Mavi Üzeri Sarı",
        "Beyaz Üzeri Mavi #2",
        "Beyaz Üzeri Mavi #3",
        "North Yankton",
    }
    for i = 0, #plateTypes - 1 do
        if i ~= 4 or (i == 4 and GetVehicleClass(plyVeh) == 18) or Config.allowGovPlateIndex then
            populateMenu("PlateIndexMenu", i, plateTypes[i + 1], "$" .. vehicleCustomisationPrices.plateindex.price)
            if tempPlateIndex == i then
                updateItem2Text("PlateIndexMenu", i, L("installed"))
            end
        end
    end
    finishPopulatingMenu("PlateIndexMenu")

    --#[Vehicle Extras Menu]#--
    createMenu("VehicleExtrasMenu", L("vehicle_extras") .. " " .. L("customisation"), L("extra_select"))
    for i = 1, 12 do
        if DoesExtraExist(plyVeh, i) then
            populateMenu("VehicleExtrasMenu", i, L("extra_prefix") .. " " .. tostring(i), L("toggle"))
        else
            populateMenu("VehicleExtrasMenu", i, L("none_option"), "NONE")
        end
    end
    finishPopulatingMenu("VehicleExtrasMenu")

    --#[Neons Menu]#--
    createMenu("NeonsMenu", L("neons") .. " " .. L("customisation"), L("category_select"))

    for _, v in ipairs(vehicleNeonOptions.neonTypes) do
        populateMenu("NeonsMenu", v.id, v.name, "none")
    end

    populateMenu("NeonsMenu", -1, L("neon_colours"), "none")
    finishPopulatingMenu("NeonsMenu")

    --#[Neon State Menu]#--
    for _, v in ipairs(vehicleNeonOptions.neonTypes) do
        local currentNeonState = GetCurrentNeonState(v.id)
        createMenu(v.name:gsub("%s+", "") .. "Menu", L("neons") .. " " .. L("customisation"), L("neon_toggle"))

        populateMenu(v.name:gsub("%s+", "") .. "Menu", 0, L("off"), "$0")
        populateMenu(v.name:gsub("%s+", "") .. "Menu", 1, L("on"), "$" .. vehicleCustomisationPrices.neonside.price)

        updateItem2Text(v.name:gsub("%s+", "") .. "Menu", currentNeonState, L("installed"))

        finishPopulatingMenu(v.name:gsub("%s+", "") .. "Menu")
    end

    --#[Neon Colours Menu]#--
    local currentNeonR, currentNeonG, currentNeonB = GetCurrentNeonColour()
    createMenu("NeonColoursMenu", L("neon_colours"), L("colour_select"))

    for k, _ in ipairs(vehicleNeonOptions.neonColours) do
        populateMenu("NeonColoursMenu", k, vehicleNeonOptions.neonColours[k].name,
            "$" .. vehicleCustomisationPrices.neoncolours.price)

        if currentNeonR == vehicleNeonOptions.neonColours[k].r and currentNeonG == vehicleNeonOptions.neonColours[k].g and currentNeonB == vehicleNeonOptions.neonColours[k].b then
            updateItem2Text("NeonColoursMenu", k, L("installed"))
        end
    end

    finishPopulatingMenu("NeonColoursMenu")

    --#[Xenons Menu]#--
    createMenu("XenonsMenu", L("xenons") .. " " .. L("customisation"), L("category_select"))

    populateMenu("XenonsMenu", 0, L("headlights"), "none")
    populateMenu("XenonsMenu", 1, L("xenon_colours"), "none")

    finishPopulatingMenu("XenonsMenu")

    --#[Xenons Headlights Menu]#--
    local currentXenonState = GetCurrentXenonState()
    createMenu("HeadlightsMenu", L("xenons") .. " " .. L("customisation"), L("xenon_toggle"))

    populateMenu("HeadlightsMenu", 0, L("headlights_off"), "$0")
    populateMenu("HeadlightsMenu", 1, L("headlights_on"), "$" .. vehicleCustomisationPrices.headlights.price)

    updateItem2Text("HeadlightsMenu", currentXenonState, L("installed"))

    finishPopulatingMenu("HeadlightsMenu")

    --#[Xenons Colour Menu]#--
    local currentXenonColour = GetCurrentXenonColour()
    createMenu("XenonColoursMenu", L("xenon_colours"), L("colour_select"))

    for _, v in ipairs(vehicleXenonOptions.xenonColours) do
        populateMenu("XenonColoursMenu", v.id, v.name, "$" .. vehicleCustomisationPrices.xenoncolours.price)

        if currentXenonColour == v.id then
            updateItem2Text("XenonColoursMenu", v.id, L("installed"))
        end
    end

    finishPopulatingMenu("XenonColoursMenu")
end

function DestroyMenus()
    destroyMenus()
end

function DisplayMenuContainer(state)
    toggleMenuContainer(state)
end

function DisplayMenu(state, menu)
    if state then
        currentMenu = menu
        updateMenuStatus(L("scroll_to_select"))
    end

    toggleMenu(state, menu)
    updateMenuHeading(menu)
    updateMenuSubheading(menu)
end

function MenuManager(state, repairOnly)
    if state then
        if currentMenuItem2 ~= L("installed") then
            if isMenuActive("modMenu") then
                if currentCategory == 18 then --Turbo
                    if AttemptPurchase("turbo", currentMenuItemID) then
                        ApplyMod(currentCategory, currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentCategory == 11 or currentCategory == 12 or currentCategory == 13 or currentCategory == 15 or currentCategory == 16 then --Performance Upgrades
                    if AttemptPurchase("performance", currentMenuItemID) then
                        ApplyMod(currentCategory, currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                else
                    if AttemptPurchase("cosmetics") then
                        ApplyMod(currentCategory, currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                end
            elseif isMenuActive("ResprayMenu") then
                if AttemptPurchase("respray") then
                    ApplyColour(currentResprayCategory, currentResprayType, currentMenuItemID)
                    playSoundEffect("respray", 1.0)
                    updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                    updateMenuStatus(L("purchased"))
                else
                    updateMenuStatus(L("insufficient_funds"))
                end
            elseif isMenuActive("WheelsMenu") then
                if currentWheelCategory == 20 then
                    if AttemptPurchase("wheelsmoke") then
                        local r = vehicleTyreSmokeOptions[currentMenuItemID].r
                        local g = vehicleTyreSmokeOptions[currentMenuItemID].g
                        local b = vehicleTyreSmokeOptions[currentMenuItemID].b

                        ApplyTyreSmoke(r, g, b)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                else
                    if currentWheelCategory == -1 then --Custom Wheels
                        local currentWheel = GetCurrentWheel()

                        if currentWheel == -1 then
                            updateMenuStatus(L("no_stock_wheel"))
                        else
                            if AttemptPurchase("customwheels") then
                                ApplyCustomWheel(currentMenuItemID)
                                playSoundEffect("wrench", 0.4)
                                updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                                updateMenuStatus(L("purchased"))
                            else
                                updateMenuStatus(L("insufficient_funds"))
                            end
                        end
                    else
                        local currentWheel = GetCurrentWheel()
                        local currentCustomWheelState = GetOriginalCustomWheel()

                        if currentCustomWheelState and currentWheel == -1 then
                            updateMenuStatus(L("no_custom_wheel"))
                        else
                            if AttemptPurchase("wheels") then
                                ApplyWheel(currentCategory, currentMenuItemID, currentWheelCategory)
                                playSoundEffect("wrench", 0.4)
                                updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                                updateMenuStatus(L("purchased"))
                            else
                                updateMenuStatus(L("insufficient_funds"))
                            end
                        end
                    end
                end
            elseif isMenuActive("NeonsSideMenu") then
                if AttemptPurchase("neonside") then
                    ApplyNeon(currentNeonSide, currentMenuItemID)
                    playSoundEffect("wrench", 0.4)
                    updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                    updateMenuStatus(L("purchased"))
                else
                    updateMenuStatus(L("insufficient_funds"))
                end
            else
                if currentMenu == "repairMenu" then
                    if AttemptPurchase("repair") then
                        currentMenu = "mainMenu"

                        RepairVehicle()

                        if not repairOnly then
                            toggleMenu(false, "repairMenu")
                            toggleMenu(true, currentMenu)
                        else
                            ExitBennys()
                            QBCore.Functions.Notify(L("vehicle_repaired"))
                        end
                        updateMenuHeading(currentMenu)
                        updateMenuSubheading(currentMenu)
                        playSoundEffect("wrench", 0.4)
                        updateMenuStatus("")
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "mainMenu" then
                    local specialMenuMap = {
                        [-1] = "ResprayMenu",
                        [-2] = "WindowTintMenu",
                        [-3] = "NeonsMenu",
                        [22] = "XenonsMenu",
                        [23] = "WheelsMenu",
                        [24] = "OldLiveryMenu",
                        [25] = "PlateIndexMenu",
                        [26] = "VehicleExtrasMenu",
                    }
                    currentMenu = specialMenuMap[currentMenuItemID] or vehicleMenuMap[currentMenuItemID] or
                        (currentMenuItem:gsub("%s+", "") .. "Menu")
                    currentCategory = currentMenuItemID

                    toggleMenu(false, "mainMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "ResprayMenu" then
                    currentMenu = "ResprayTypeMenu"
                    currentResprayCategory = currentMenuItemID

                    toggleMenu(false, "ResprayMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "ResprayTypeMenu" then
                    -- colour category names come from config (English), safe to gsub — but use ID-based safe fallback
                    local resprayTypeMenuMap = {}
                    for _, rv in ipairs(vehicleResprayOptions) do
                        resprayTypeMenuMap[rv.id] = rv.category:gsub("%s+", "") .. "Menu"
                    end
                    currentMenu = resprayTypeMenuMap[currentMenuItemID] or (currentMenuItem:gsub("%s+", "") .. "Menu")
                    currentResprayType = currentMenuItemID

                    toggleMenu(false, "ResprayTypeMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "WheelsMenu" then
                    local currentWheel, _, currentWheelType = GetCurrentWheel()

                    -- wheel category names come from config (English), safe to gsub
                    local wheelMenuMap = {}
                    for _, wv in ipairs(vehicleWheelOptions) do
                        wheelMenuMap[wv.id] = wv.category:gsub("%s+", "") .. "Menu"
                    end
                    currentMenu = wheelMenuMap[currentMenuItemID] or (currentMenuItem:gsub("%s+", "") .. "Menu")
                    currentWheelCategory = currentMenuItemID

                    if currentWheelType == currentWheelCategory then
                        updateItem2Text(currentMenu, currentWheel, L("installed"))
                    end

                    toggleMenu(false, "WheelsMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "NeonsMenu" then
                    local neonMenuMap = { [-1] = "NeonColoursMenu" }
                    for _, nv in ipairs(vehicleNeonOptions.neonTypes) do
                        neonMenuMap[nv.id] = nv.name:gsub("%s+", "") .. "Menu"
                    end
                    currentMenu = neonMenuMap[currentMenuItemID] or (currentMenuItem:gsub("%s+", "") .. "Menu")
                    currentNeonSide = currentMenuItemID

                    toggleMenu(false, "NeonsMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "XenonsMenu" then
                    local xenonMenuMap = { [0] = "HeadlightsMenu", [1] = "XenonColoursMenu" }
                    currentMenu = xenonMenuMap[currentMenuItemID] or (currentMenuItem:gsub("%s+", "") .. "Menu")

                    toggleMenu(false, "XenonsMenu")
                    toggleMenu(true, currentMenu)
                    updateMenuHeading(currentMenu)
                    updateMenuSubheading(currentMenu)
                elseif currentMenu == "WindowTintMenu" then
                    if AttemptPurchase("windowtint") then
                        ApplyWindowTint(currentMenuItemID)
                        playSoundEffect("respray", 1.0)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "NeonColoursMenu" then
                    if AttemptPurchase("neoncolours") then
                        local r = vehicleNeonOptions.neonColours[currentMenuItemID].r
                        local g = vehicleNeonOptions.neonColours[currentMenuItemID].g
                        local b = vehicleNeonOptions.neonColours[currentMenuItemID].b

                        ApplyNeonColour(r, g, b)
                        playSoundEffect("respray", 1.0)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "HeadlightsMenu" then
                    if AttemptPurchase("headlights") then
                        ApplyXenonLights(currentCategory, currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "XenonColoursMenu" then
                    if AttemptPurchase("xenoncolours") then
                        ApplyXenonColour(currentMenuItemID)
                        playSoundEffect("respray", 1.0)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "OldLiveryMenu" then
                    if AttemptPurchase("oldlivery") then
                        ApplyOldLivery(currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "PlateIndexMenu" then
                    if AttemptPurchase("plateindex") then
                        ApplyPlateIndex(currentMenuItemID)
                        playSoundEffect("wrench", 0.4)
                        updateItem2Text(currentMenu, currentMenuItemID, L("installed"))
                        updateMenuStatus(L("purchased"))
                    else
                        updateMenuStatus(L("insufficient_funds"))
                    end
                elseif currentMenu == "VehicleExtrasMenu" then
                    ApplyExtra(currentMenuItemID)
                    playSoundEffect("wrench", 0.4)
                    updateItem2TextOnly(currentMenu, currentMenuItemID, L("toggle"))
                    updateMenuStatus(L("purchased"))
                end
            end
        else
            if currentMenu == "VehicleExtrasMenu" then
                ApplyExtra(currentMenuItemID)
                playSoundEffect("wrench", 0.4)
                updateItem2TextOnly(currentMenu, currentMenuItemID, L("toggle"))
                updateMenuStatus(L("purchased"))
            end
        end
    else
        updateMenuStatus(L("scroll_to_select"))

        if isMenuActive("modMenu") then
            toggleMenu(false, currentMenu)

            currentMenu = "mainMenu"

            if currentCategory ~= 18 then
                RestoreOriginalMod()
            end

            toggleMenu(true, currentMenu)
            updateMenuHeading(currentMenu)
            updateMenuSubheading(currentMenu)
        elseif isMenuActive("ResprayMenu") then
            toggleMenu(false, currentMenu)

            currentMenu = "ResprayTypeMenu"

            RestoreOriginalColours()

            toggleMenu(true, currentMenu)
            updateMenuHeading(currentMenu)
            updateMenuSubheading(currentMenu)
        elseif isMenuActive("WheelsMenu") then
            if currentWheelCategory ~= 20 and currentWheelCategory ~= -1 then
                local currentWheel = GetOriginalWheel()

                updateItem2Text(currentMenu, currentWheel, "$" .. vehicleCustomisationPrices.wheels.price)

                RestoreOriginalWheels()
            end

            toggleMenu(false, currentMenu)

            currentMenu = "WheelsMenu"


            toggleMenu(true, currentMenu)
            updateMenuHeading(currentMenu)
            updateMenuSubheading(currentMenu)
        elseif isMenuActive("NeonsSideMenu") then
            toggleMenu(false, currentMenu)

            currentMenu = "NeonsMenu"

            RestoreOriginalNeonStates()

            toggleMenu(true, currentMenu)
            updateMenuHeading(currentMenu)
            updateMenuSubheading(currentMenu)
        else
            if currentMenu == "mainMenu" or currentMenu == "repairMenu" then
                ExitBennys()
            elseif currentMenu == "ResprayMenu" or currentMenu == "WindowTintMenu" or currentMenu == "WheelsMenu" or currentMenu == "NeonsMenu" or currentMenu == "XenonsMenu" or currentMenu == "OldLiveryMenu" or currentMenu == "PlateIndexMenu" or currentMenu == "VehicleExtrasMenu" then
                toggleMenu(false, currentMenu)

                if currentMenu == "WindowTintMenu" then
                    RestoreOriginalWindowTint()
                end

                if currentMenu == "OldLiveryMenu" then
                    RestoreOldLivery()
                end
                if currentMenu == "PlateIndexMenu" then
                    RestorePlateIndex()
                end

                currentMenu = "mainMenu"

                toggleMenu(true, currentMenu)
                updateMenuHeading(currentMenu)
                updateMenuSubheading(currentMenu)
            elseif currentMenu == "ResprayTypeMenu" then
                toggleMenu(false, currentMenu)

                currentMenu = "ResprayMenu"

                toggleMenu(true, currentMenu)
                updateMenuHeading(currentMenu)
                updateMenuSubheading(currentMenu)
            elseif currentMenu == "NeonColoursMenu" then
                toggleMenu(false, currentMenu)

                currentMenu = "NeonsMenu"

                RestoreOriginalNeonColours()

                toggleMenu(true, currentMenu)
                updateMenuHeading(currentMenu)
                updateMenuSubheading(currentMenu)
            elseif currentMenu == "HeadlightsMenu" then
                toggleMenu(false, currentMenu)

                currentMenu = "XenonsMenu"

                toggleMenu(true, currentMenu)
                updateMenuHeading(currentMenu)
                updateMenuSubheading(currentMenu)
            elseif currentMenu == "XenonColoursMenu" then
                toggleMenu(false, currentMenu)

                currentMenu = "XenonsMenu"

                RestoreOriginalXenonColour()

                toggleMenu(true, currentMenu)
                updateMenuHeading(currentMenu)
                updateMenuSubheading(currentMenu)
            end
        end
    end
end

function MenuScrollFunctionality(direction)
    scrollMenuFunctionality(direction, currentMenu)
end

-----------------------
----   Threads     ----
-----------------------

-----------------------
---- Client Events ----
-----------------------

RegisterNUICallback("selectedItem", function(data, cb)
    updateCurrentMenuItemID(tonumber(data.id), data.item, data.item2)
    cb("ok")
end)

RegisterNUICallback("updateItem2", function(data, cb)
    currentMenuItem2 = data.item
    cb("ok")
end)
