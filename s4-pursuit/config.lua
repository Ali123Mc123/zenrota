Config = {}

-- For oil spill
-- Config.AvaibleVehicleClass = { -- https://docs.fivem.net/natives/?_0x29439776AAA00A62
--     1,3
-- }

Config.AvaibleSeats = { -- for oiltank use only
    [-1] = true,
    [0] = false,
    [1] = true,
    [2] = false,
    [3] = true,
    [4] = false,
    [5] = false,
    [6] = false,
}

Config.Lang = {
    ["no_class"] = "Bu araçta bagaja erişemezsiniz!",
    ["no_seat"] = "Bu koltukta otururken bagaja erişemezsiniz!",
    ["oil_spill"] = "Yağ dökülüyor...",
    ["lose_con"] = "Araç kontrolü kaybediliyor",
    ["not_allowed_vehicle"] = "Bu araçla bunu yapamazsınız!",
}

Config.TimeOilSpilling = 5000


-- for better client performance
Config.RemoveDecals = true
Config.RemoveDecalDistance = 50.0
Config.RemoveDecalsTimeout = 5000
-- if you want keep oil on the ground Config.RemoveDecals set false


Config.OilItem = "oiltank"

Config.OilBottleItem = "oil_bottle"

Config.BottleModel = "prop_bottle_cognac" -- alternatives: prop_oiltub_06


Config.NailBagItem = "nail_bag"

Config.NailBagModel = "prop_paper_bag_01"
Config.NailBagModel2 = "p_stinger_03"


Config.FireExtItem = "fire_extinguisher"

Config.FireExtModel = "prop_tool_blowtorch"


Config.LoseControlTime = 5000 -- time in ms
Config.ShowProgressBar = true


Config.AllowUseItemsInVehicleClasses = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = false,
    [17] = false,
    [18] = true,
    [19] = false,
    [20] = false,
    [21] = false,
    [22] = false
}

Config.IgnoreVehicleClasses = { -- https://docs.fivem.net/natives/?_0x29439776AAA00A62
    [0] = false,
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = false,
    [19] = true,
    [20] = true,
    [21] = true,
    [22] = true
}


Config.Notify = function(type_, title, description)
    lib.notify({
        type = type_,
        title = title,
        description = description
    })
end

Config.ProgressBar = function(time, label)
    lib.progressBar({
        duration = time,
        label = label,
        useWhileDead = false,
        canCancel = false,
    })
end


Config.ShowMarkers = true


-- Ready to use items
-- oiltank = { name = 'oiltank', label = 'Oil Tank', weight = 500, type = 'item', image = 'oiltank.png', unique = false, useable = true, shouldClose = true, description = 'edit here' },
-- oil_bottle = { name = 'oil_bottle', label = 'Oil Bottle', weight = 100, type = 'item', image = 'oil_bottle.png', unique = false, useable = true, shouldClose = true, description = 'edit here' },
-- nail_bag = { name = 'nail_bag', label = 'Nail Bag', weight = 100, type = 'item', image = 'nail_bag.png', unique = false, useable = true, shouldClose = true, description = 'edit here' },
-- fire_extinguisher = { name = 'fire_extinguisher', label = 'Fire Extinguisher', weight = 1000, type = 'item', image = 'fire_extinguisher.png', unique = false, useable = true, shouldClose = true, description = 'edit here' },
