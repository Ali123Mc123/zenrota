Config = {}

Config.Framework = "auto" --esx / qb / qbx
Config.UseExportForEsx = true --for old version esx doesn't have export so set false. For newer versions set true.

Config.Inventory = "auto" -- ak47 / codem / core / origen / ox / ps / qs / tgiann / framework ()

Config.Inventorys = {
    ["ox_inventory"] = "ox",
    ["core_inventory"] = "core",
    ["minventory"] = "codem",
    ["codem-inventory"] = "codem",
    ["ak47_inventory"] = "ak47",
    ["origen_inventory"] = "origen",
    ["qs-inventory"] = "qs",
    ["tgiann-inventory"] = "tgiann",
}

Config.Interaction = {
    useTarget = false, -- If you set false you will use drawtext

    targetScript = "auto" --qb-target / ox_target
}

Config.SQL = "oxmysql"

Config.ProfilePhoto = "none" -- steam / discord / mugshot / none

Config.Notification = 'framework' -- framework / codem-notification / okokNotify / mythic / 17mov / ox

exports('getConfig', function()
    return Config
end)