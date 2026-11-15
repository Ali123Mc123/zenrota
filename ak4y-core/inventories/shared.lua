function checkInventory()
    local returnInv = false
    if Config.Inventory == "auto" then
        local foundInv = false
        for k,v in pairs(Config.Inventorys) do
            if GetResourceState(k) == "started" then
                foundInv = true
                Config.Inventory = v
                returnInv = v
                break
            end
        end
        if not foundInv then
            Config.Inventory = "framework"
            returnInv = "framework"
        end
    else
        returnInv = Config.Inventory
        return Config.Inventory
    end
    return returnInv
end