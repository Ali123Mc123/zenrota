Config = {}
Config.Framework = {
    ["Framework"] = "auto", -- auto, esx, qbcore, qbox or vrp
    ["ResourceName"] = "auto", -- auto, es_extended or qb-core or your resource name. If you using qbx you should write qb-core. vRP: the vrp resource folder name (auto = vrp)
    ["SharedEvent"] = "" -- Event name for old cores.
}

Config.VRP = {
    ["version"] = "auto", -- auto, 1 (vRP 1.x, ImagicTheCat tag 1.0) or 2 (vRP 2.0, master branch with vRP.EXT extensions). Start the vrp resource before this one.
    ["jobType"] = "job", -- vRP group `gtype` shown as the job (cfg/groups.lua `_config.gtype`)
    ["gangType"] = "gang", -- vRP group `gtype` shown as the gang. Set `false` to hide the gang.
    ["defaultJob"] = "Citizen", -- Text shown when the player has no group of `jobType`
    ["refresh"] = 2500, -- vRP 1.x only: money / hunger / thirst polling interval (ms). vRP 1.x has no money event, vRP 2.0 is event based.
}

Config.Language = "tr" -- ar, cz, ro, it, fr, de, tr
Config.ShowDebug = false -- If you set this to `true`, the debug messages will be printed in the console. If you set it to `false`, no debug messages will be printed.
Config.ClockType = 24 --[[ 12 = 12 hour clock 9.30 PM || 24 = 24 hour clock 21.30 ]]
Config.ShowICTime = false -- If you set it to `true`, the in-game time will be displayed. If you set it to `false`, UTC (OOC) Time will be displayed.
Config.ShowMapOnFoot = false -- If `true` is set, the player can see the map when not in the vehicle. If `false`, the map will only be visible when in the vehicle.
Config.MinimapSafeZone = { -- Minimap alignment with the in-game Safe Zone slider. Use `/mapsafe <position> <size>` (needs ShowDebug) to compare values live. Each value is the exponent of the safe zone size: 0 = off, 1 = divide by the safe zone, 2 = divide by its square.
    ["position"] = 0, -- Exponent applied to the minimap position.
    ["size"] = 0, -- Exponent applied to the minimap size.
}
Config.SendStatusAlert = false -- If this option is `true`, the player will be notified if the hunger or thirst value falls below 20. Tick `false` if you do not want to use this system
Config.StressSystem = false -- If you make `true`, stress will come next to the status bars. You will be able to see your stress values. You need to use a script for qb-stress esx for QBCore
Config.DisableRightCorner = false -- If you want to disable the top right corner, set it to `true`. This will hide all server and player information. If set to `false`, users can see and customize the top right corner.
Config.DisableMapAnimation = false -- If you set it to `true`, the minimap loading animation will be disabled. If you set it to `false`, the minimap loading animation will be enabled.
Config.DisableLocationInfo = false -- If you set it to `true`, the location and compass will not be displayed. If the nearby postal address is also not visible, the element there will be automatically hidden. If set to `false`, the Compass and Location will be displayed.
Config.MaxArmourValue = 100 -- If your maximum armor level is above 100, you should write it here. This way, the HUD bar will act accordingly. [[📛📛 ATTENTION: Does not modify or set player data. It is only an offset setting for visual appearance. 📛📛]]
Config.ShowCompassAlways = false -- If you set it to `true`, the compass will always be visible. If you set it to `false`, the compass will only be visible when in a vehicle or when the map is open.
Config.ShowMinimapToggleOption = true -- If you set it to `true`, the option to show or hide the minimap will be available in the settings menu. If you set it to `false`, the option to show or hide the minimap will not be available in the settings menu and the minimap will always be visible.

Config.DamageIndicator = {
    ["enabled"] = true, -- If you set this to `true`, a direction indicator and a blood overlay are shown when the player takes damage, and a Damage page is added to the settings menu. If you set it to `false`, nothing runs and the page is hidden.
    ["indicatorDuration"] = 2000, -- How long (ms) a direction indicator stays on screen.
    ["bloodDuration"] = 5250, -- How long (ms) a blood overlay takes to fade out.
    ["criticalHealth"] = 35, -- At or below this health (0-100) the low-health blood overlay stays on screen.
    ["maxIndicators"] = 6, -- How many direction indicators can be on screen at the same time.
}

Config.WaypointMarker = true -- If you set this to `true`, the map waypoint is also shown in the world as a marker with its distance and height difference, and a Waypoint page is added to the settings menu. If you set it to `false`, nothing runs and the page is hidden.

Config.ElectricVehicles = {
    ["enabled"] = true, -- If you set this to `true`, electric vehicles are detected and the car HUD fuel icon, bar and arc turn blue with a lightning icon. If you set it to `false`, every vehicle uses the normal fuel look.
    ["models"] = { -- Spawn names of the electric vehicles. Set a model to `true` to mark it electric; remove it or set it to `false` for a normal fuel look. Add addon vehicles the same way: [`yourmodel`] = true,
        [`airtug`] = true,
        [`buffalo5`] = true,
        [`caddy`] = true,
        [`caddy2`] = true,
        [`caddy3`] = true,
        [`cyclone`] = true,
        [`cyclone2`] = true,
        [`dilettante`] = true,
        [`dilettante2`] = true,
        [`envisage`] = true,
        [`estride`] = true,
        [`imorgon`] = true,
        [`inductor`] = true,
        [`inductor2`] = true,
        [`iwagen`] = true,
        [`khamelion`] = true,
        [`coureur`] = true,
        [`neon`] = true,
        [`omnisegt`] = true,
        [`pipistrello`] = true,
        [`powersurge`] = true,
        [`raiden`] = true,
        [`rcbandito`] = true,
        [`surge`] = true,
        [`suzume`] = true,
        [`tezeract`] = true,
        [`virtue`] = true,
        [`vivanite`] = true,
        [`vivanite2`] = true,
        [`voltic`] = true,
        [`voltic2`] = true,
    },
}

Config.BlackMoney = {
    ["display"] = false, -- if you set this to `true`, the black money will be displayed in the HUD. If you set it to `false`, the black money will not be displayed in the HUD.
    ["name"] = "YOUR_BLACKMONEY_ITEM_NAME", -- If `isItem` is `true`, write the item name of the black money here. If `isItem` is `false`, you can leave it default.
    ["isItem"] = false, -- If `blackmoney` is an item, set it to `true`. In ESX, this operation typically comes from the “Accounts” section, so set it to `false`. In frameworks like Qbox and QBCore, this is an item. Enter the item name in the field labeled “name” on the line above.
    ["account"] = "black_money", --[[
        ESX: The default is `black_money`, but if it's different, find the “black money” entry in the Accounts table in the `es_extended/shared/main.lua` file and add it here.
        Qbox, QBCore: This is usually an item. If it's not an item, you can leave it as `false` and the system will try to get the data from player data.
    ]]
}

Config.MusicSystem = {
    --[[
        📛 Currently this system is not synchronised with other players. 
        🟠 I tried to synchronise as efficiently as possible, but it did not work as I wanted. 

        🟢🟢🟢
        The new Speaker/Boombox/Carplay script, which works with Sync 3D Audio and 4 different realistic effects, works in conjunction with this HUD.
        You can purchase this script separately for Sync music processing.
        https://0resmon.tebex.io/package/fivem-speaker-boombox-carplay-script
    --]]

    ["disable"] = true, -- DaddyRP: Q menüsünde radyo yok (araç müziği sadece mekanikten car_play ile, G). If you set `true`, people will not be able to use the music system from the car control menu. The system will switch off completely.
    ["distance"] = 10.0, -- If you are using the music system in the car control, it is the distance distance of the music played in the vehicle.  
}

Config.DutySystem = {
    --[[
        ❇️❇️
        If your server has a ‘Duty’ system for jobs, you can use this feature to display the ‘Duty’ status in HUD.
        You can add the jobs that have a duty system in the ‘jobs’ section below.
        When a player goes on or off duty, the HUD will automatically update and show the current duty status.
    --]]

    ["enabled"] = true, -- If you want the duty value to appear in the HUD, set it to `true`. If you don't want the duty value to appear in the HUD, set it to `false`.
    ["jobs"] = {
        --[[
            ❓🤔
            If you want the duty value to appear in certain jobs, you should add them here.
            Examples:
                ["bcso"] = true,
                ["police"] = true,
                ["sheriff"] = true,
                ["ambulance"] = true,
                ["parkranger"] = true,
                ["mechanic"] = true,
        ]]
        ["police"] = true,
        ["ambulance"] = true,
        ["mechanic"] = true,
        ["sheriff"] = true,
        ["bcso"] = true,
    },
}

Config.PostalMap = {
    --[[
        ⚠️ If you have a postal map, the following enabled must be true. Otherwise problems may occur.
    --]]

    ["enabled"] = true, -- If you are using PostalMap on your server, you should set this to `true`. Otherwise, the map may disappear, visibility problems or mask problems may occur.
    ["zoom_level"] = 1100, -- Postal (custom) map zoom level. Recommended value: 1100 
    ["showNearPostal"] = true, -- If you do `true`, the code of the postal you are close to will appear just opposite your location information. (It may increase resmon, albeit very little)
}

Config.MapMasks = {
    ["square"] = "masks/square.png",
    ["square_round"] = "masks/square_round.png",
    ["circle"] = "masks/circle.png",
    ["hexagon"] = "masks/hexagon.png", -- Runtime minimap mask (white shape on a transparent 512x384 PNG). Add your own file here and the same key to web/public/Theme.json -> map.
    ["pentagon"] = "masks/pentagon.png",
    ["pill"] = "masks/pill.png",
}

local mapTextureNames = {
    ["minimap_0_0"] = { day = "minimap_0_0_daya", night = "minimap_0_0_nightb", stock = "minimap_0_0", postal = "minimap_0_0_postald", postalnight = "minimap_0_0_postalnighta" },
    ["minimap_0_1"] = { day = "minimap_0_1_dayo", night = "minimap_0_1_nightd", stock = "minimap_0_1", postal = "minimap_0_1_postalb", postalnight = "minimap_0_1_postalnighte" },
    ["minimap_1_0"] = { day = "minimap_1_0_day", night = "minimap_1_0_night", stock = "minimap_1_0", postal = "minimap_1_0_postal", postalnight = "minimap_1_0_postalnighta" },
    ["minimap_1_1"] = { day = "minimap_1_1_daya", night = "minimap_1_1_nightb", stock = "minimap_1_1", postal = "minimap_1_1_postalb", postalnight = "minimap_1_1_postalnight" },
    ["minimap_2_0"] = { day = "minimap_2_0_dayb7", night = "minimap_2_0_nightn7", stock = "minimap_2_0", postal = "minimap_2_0_postalce", postalnight = "minimap_2_0_postalnightdz" },
    ["minimap_2_1"] = { day = "minimap_2_1_day", night = "minimap_2_1_night", stock = "minimap_2_1", postal = "minimap_2_1_postal", postalnight = "minimap_2_1_postalnight" },
    ["minimap_lod_128"] = { day = "minimap_lod_128_daya", night = "minimap_lod_128_nightb", stock = "minimap_lod_128" },
    ["minimap_sea_0_0"] = { day = "minimap_sea_0_0_dayl", night = "minimap_sea_0_0_nightba", stock = "minimap_sea_0_0", postal = "minimap_sea_0_0_postaln", postalnight = "minimap_sea_0_0_postalnightbf" },
    ["minimap_sea_0_1"] = { day = "minimap_sea_0_1_day", night = "minimap_sea_0_1_night", stock = "minimap_sea_0_1", postal = "minimap_sea_0_1_postal", postalnight = "minimap_sea_0_1_postalnighta" },
    ["minimap_sea_1_0"] = { day = "minimap_sea_1_0_day", night = "minimap_sea_1_0_night", stock = "minimap_sea_1_0", postal = "minimap_sea_1_0_postal", postalnight = "minimap_sea_1_0_postalnight" },
    ["minimap_sea_1_1"] = { day = "minimap_sea_1_1_dayg", night = "minimap_sea_1_1_nightab", stock = "minimap_sea_1_1", postal = "minimap_sea_1_1_postalb", postalnight = "minimap_sea_1_1_postalnighte" },
    ["minimap_sea_2_0"] = { day = "minimap_sea_2_0_daya", night = "minimap_sea_2_0_night", stock = "minimap_sea_2_0", postal = "minimap_sea_2_0_postal", postalnight = "minimap_sea_2_0_postalnight" },
    ["minimap_sea_2_1"] = { day = "minimap_sea_2_1_day", night = "minimap_sea_2_1_night", stock = "minimap_sea_2_1", postal = "minimap_sea_2_1_postala", postalnight = "minimap_sea_2_1_postalnight" },
}

local mapTextureOrder = { "minimap_0_0", "minimap_0_1", "minimap_1_0", "minimap_1_1", "minimap_2_0", "minimap_2_1", "minimap_sea_0_0", "minimap_sea_0_1", "minimap_sea_1_0", "minimap_sea_1_1", "minimap_sea_2_0", "minimap_sea_2_1", "minimap_lod_128" }

local function mapTextureRows(kind)
    local rows = {}
    for _, dict in ipairs(mapTextureOrder) do
        rows[#rows + 1] = { dict, dict, dict, mapTextureNames[dict][kind] or mapTextureNames[dict].day }
    end
    return rows
end

Config.MapStyles = {
    ["default"] = { ["replace"] = mapTextureRows("stock") },
    ["colored"] = { ["label"] = "Colored", ["enabled"] = true, ["replace"] = mapTextureRows("day"), ["night"] = mapTextureRows("night") },
    ["postal"] = { ["label"] = "Postal", ["enabled"] = true, ["replace"] = mapTextureRows("postal"), ["night"] = mapTextureRows("postalnight") },
    --[[
        Add your own map looks here. Each id (letters, numbers, `_`, up to 32 characters) becomes a choice in the HUD settings (Map page).
        ["label"] = Name shown in the menu. If you leave it out, the id is shown.
        ["enabled"] = Set to `true` after streaming your own texture dictionary.
        ["replace"] = Rows { "original_dictionary", "original_texture", "your_dictionary", "your_texture" } applied all day.
        ["night"] = Optional rows applied only at night (20:00 - 05:00). A night row with the same original texture replaces the day row, so the look changes by itself with the in-game clock.
    --]]
}

Config.ApplyToAll = {
    ["enabled"] = true, -- If `true`, players in the groups below see the "Apply to everyone" button in the HUD customization menu and can push their theme to every player.
    ["groups"] = { "admin", "god", "superadmin" }, -- ESX: player group name. QBCore / QBox: permission name checked with HasPermission. vRP: group name checked with hasGroup.
    ["maxSize"] = 32768, -- Maximum theme code size (characters) the server accepts.
    ["cooldown"] = 5000, -- Minimum time (ms) between two apply requests of the same admin.
}

Config.Commands = {
    --[[ 
        ⁉️ VERY IMPORTANT: 
        ⚠️ When the keymapping system is activated, it will create a command in users with the current key. 
        ⚠️ When you change the Key or Command, this process will change for people entering the server for the first time. 
        ⚠️ Key and Command will not change for players already on the server. 
        ⚠️ Changing this setting does not change the key assignment in the game, it only changes the default. In the game, the key assignment is changed in settings / fivem / keybinds.
    --]]

    ["cinematic"] = { -- For those who want to activate cinematic mode by command
        ["disabled"] = false, -- If you set this variable to `true`, the cinematic mode code will be completely disabled.
        ["command"] = "cinematic",
    },
    ["togglehud"] = { -- Command and settings switch that hides every HUD element at once (no black bars). Run it again to bring the HUD back.
        ["disabled"] = false, -- If you set this variable to `true`, the hide-all-HUD feature is completely disabled.
        ["command"] = "togglehud",
    },
    ["belt"] = { -- You can use these button settings to fasten your seat belt in the vehicle.
        ["disabled"] = false, -- If you set this variable to `true`, the belt system will be completely disabled.
        ["notification"] = true, -- If you set it to `true`, you will receive a notification for the seatbelt connection. If it is `false`, you will not see a notification, only hear a sound.
        ["sound"] = true, -- If you set it to `true`, the seatbelt sounds (buckle, unbuckle, alarm) are played by the HUD itself (no xsound / InteractSound needed). Players can still mute them in the HUD settings.
        ["keymapping"] = {
            ["key"] = "B",
            ["usable"] = true,
            ["command"] = "belt",
            ["description"] = "Emniyet kemerini tak/çıkar",
        },
    },
    ["settings"] = { -- You can make the necessary command or key links to open Hud's settings menu here.
        ["disabled"] = false, -- If you set this variable to `true`, the settings menu will be completely disabled.
        ["keymapping"] = {
            ["key"] = "G",
            ["usable"] = false,
            ["command"] = "hud",
            ["description"] = "HUD ayarlarını aç",
        },
    },
    ["editor"] = { -- If you change the key, enter the equivalent of the key you changed here in this way or it will not work!
        ["disabled"] = false, -- If you set this variable to `true`, editor mode will be completely disabled.
        ["closeKey"] = "PageUp", -- https://www.toptal.com/developers/keycode => Keys such as F1-2-3-3-4-5-6-7-8-9 should be written in upper case and other keys should be written in lower case!
        ["keymapping"] = {
            ["key"] = "PageUp",
            ["usable"] = true,
            ["command"] = "editormode",
            ["description"] = "Düzenleme modunu aç",
        },
    },
    ["carcontrol"] = {
        ["key"] = "Q", -- Q ( RADIO KEYBIND )
        ["command"] = "carcontrol", -- Command to open car control menu
        ["disabled"] = false, -- If you set this variable to `true`, car control menu will be completely disabled.
        ["openevent"] = "wais:primehud:client:openCarControl", -- Event to open car control menu
        ["disableKey"] = false, -- If you set this variable to `true`, the keymapping system will be disabled and only command or event will be used to open car control menu.
        ["description"] = "Araç kontrol menüsünü aç", -- Description of the command
        ["mouseControl"] = false, -- Allows you to control both the mouse and keyboard simultaneously. If you set it to `true`, you can control car control without splitting the game. If set to `false`, the game will split because your keyboard will only focus on car control.
        ["tabs"] = {
            --[[
                If you set it to `false`, the tab will be enabled.
                If you set it to `true`, the tab will be disabled. 
            ]]

            ["music"] = Config.MusicSystem.disable, -- Music tab allows you to control the music system in your vehicle. If you set it to `true`, the music tab will be completely disabled.
            ["nearby"] = false, -- Nearby tabs show nearby banks, gas stations, and other important locations.
            ["carmenu"] = false, -- Car menu tab allows you to control your vehicle's doors, hood, trunk, and other features. If you set it to `true`, the car menu tab will be completely disabled.
        }
    },
    ["postal"] = {
        ["disabled"] = false, -- If you set this variable to `true`, postal code will be completely disabled.
        ["command"] = "postal", -- Command to mark postal
        ["help"] = {
            ["command"] = "Girdiğin posta kodunu haritada işaretler.",
            ["postalid"] = "Haritada işaretlemek istediğin posta kodu.",
        }
    },
    ["seat"] = {
        ["disabled"] = false, -- If you set this variable to `true`, seat changing command will be completely disabled.
        ["command"] = "koltuk", -- Command to change seat
        ["help"] = {
            ["command"] = "Araç içinde koltuk değiştirmeni sağlar.",
            ["seatid"] = "Geçmek istediğin koltuk numarası (1 sürücü, 2 ön yolcu, 3+ arka koltuklar).",
        }
    }
}

Config.MoneySettings = {
    ["name"] = "money",
    ["isItem"] = false, -- If your money is in the form of items, make it `true`. If you are using ox_inventory, make it `false`.
    ["isOldType"] = false, -- If you have an old ESX Version or Chezza Inventory etc. If you are using esx with an old infrastructure, make `true`. If you do not know what you are doing, please leave it as `false`
    
    -- [[ 🟢 Inventory detections, to work automatically compatible with some inventories. 🟢 ]]
    ["qs_inventory"] = GetResourceState("qs-inventory"):find("start") and true or false,
    ["ox_inventory"] = GetResourceState("ox_inventory"):find("start") and true or false,
}

Config.RefreshTimes = {
    --[[
        ⚠️ If you lower the refresh values here, hud will use more resmon. ⚠️
    --]]

    ["carhud"] = {  -- How often to refresh carhud
        ["balanced"] = 200,
        ["performance"] = 100,
    },
    ["status"] = { -- How often to refresh status
        ["balanced"] = 250,
        ["performance"] = 100,
    },
    ["compass"] = { -- How often to refresh compass
        ["balanced"] = 750,
        ["performance"] = 500,
    },
    ["waypoint"] = { -- How often to refresh the waypoint marker position while a waypoint is set and the camera or player is moving
        ["balanced"] = 50,
        ["performance"] = 33,
    },
    ["players"] = 10 * 1000, -- How often to refresh player counts
    ["statusControl"] = 1 * 60 * 1000, -- Control time of the system that checks the user hunger thirst value and sends notifications.
    ["sysControllers"] = {
        ["screenRes"] = 2 * 1000, -- The duration of the control structure that detects the screen resolution and rebuilds things accordingly
        ["beltAlarm"] = 7.5 * 1000, -- Control time for belt fastening tone and warning
    }
}

Config.BlacklistedVehicles = {
    --[[
        ⚠️ There is a special hiding and blocking feature for some tools. It works with Class or Specific Model. ⚠️
        🟢 ["belt"] = true, -- If you set this to `true`, the seat belt system will not work in this vehicle or class.
        🟢 ["music"] = true, -- If you set this to `true`, the music system will not work in this vehicle or class.
        🟢 ["carhud"] = true, -- If you set this to `true`, the carhud will not be visible in this vehicle or class.
    --]]

    ["class"] = {
        [8] = {
            ["belt"] = true,
            ["music"] = true,
        },
        [13] = {
            ["belt"] = true,
            ["music"] = true,
            ["carhud"] = true,
        },
        [14] = {
            ["belt"] = true,
        },
        [15] = {
            ["belt"] = true,
        },
        [16] = {
            ["belt"] = true,
        },
    },
    ["models"] = {
        [`t20`] = {
            ["carhud"] = false,
        },
    }
}

Config.VoiceSettings = {
    ["totalRange"] = 3,
    ["defaultRange"] = 2,
}

Config.Notification = function(title, text, type, time)
    title = title or "Hud"
    time = time or 5000

    if Config.Framework.Framework == "qbcore" then
        TriggerEvent('QBCore:Notify', text, type, time)
    elseif Config.Framework.Framework == "esx" then
        lib.notify({
            title = title,
            type = type,
            duration = time,
            description = text,
            iconAnimation = "beatFade",
            position = "center-right"
        })
    elseif GetResourceState("okokNotify"):find("start") then
        exports['okokNotify']:Alert(title, text, time, type, true)
    elseif Config.Framework.Framework == "qbox" or Config.Framework.Framework == "vrp" then
        lib.notify({
            title = title,
            type = type,
            duration = time,
            description = text,
            iconAnimation = "beatFade",
            position = "center-right"
        })
    end
end

Config.Debug = function(...)
    if not Config.ShowDebug then return end
    print(...)
end

Config.GetVehicleFuel = function(vehicle)
    return GetVehicleFuelLevel(vehicle) or 0.0
end

Config.CanOpenSettingsMenu = function()
    --[[
        -- Can the player open the settings menu?
        -- The person attempting to open the Settings menu will be monitored from here.
        -- return `true` allows the player to open the settings menu. return `false` prevents the player from opening the settings menu.

        📛📛📛
        If you want something like this, you must write custom code yourself or have your developer write the code.
        At this point, customizations like this are entirely your responsibility. We do not assist with Discord integration.
    ]]

    return true
end
