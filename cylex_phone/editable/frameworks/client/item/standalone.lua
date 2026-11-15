if Config.Inventory ~= 'standalone' then return end

exports('hasEnoughOfItem', function(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
end)

exports('getQuantity', function(itemid, checkQuality, metaInformation)
    return getQuantity(itemid, checkQuality, metaInformation)
end)

local function getQuality(v)
    return true
end

function hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return true
end


function getQuantity(itemid, checkQuality, metaInformation)
    if itemid == nil then return 0 end
    return 1
end


function getItemInfo(itemid, limitAmount, checkQuality, metaInformation)
    if itemid == nil then
        return false
    end
    return true, 1
end

-- racing

function getHasRaceUsbAndAlias()
    return {
        has_usb_racing = true,
        has_usb_racing_create = true,
        has_usb_pd_racing = true,
        racingAlias = "test",
    }
end

exports('getHasRaceUsbAndAlias', getHasRaceUsbAndAlias)