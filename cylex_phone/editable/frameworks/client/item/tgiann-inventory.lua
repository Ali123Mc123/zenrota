if Config.Inventory ~= 'tgiann-inventory' then return end

exports('hasEnoughOfItem', function(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
end)

exports('getQuantity', function(itemid, checkQuality, metaInformation)
    return getQuantity(itemid, checkQuality, metaInformation)
end)

local function getQuality(v)
    if (not v or not v.info or not v.info.quality) or (v.info.quality and v.info.quality > 0.0) then
        return true
    end
    return false
end

function hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    if shouldReturnText == nil then shouldReturnText = true end
    if itemid == nil or itemid == 0 or amount == nil or amount == 0 then
        if shouldReturnText then
            Cylex.Notify('phone', 'no_item')
        end
        return false
    end
    amount = tonumber(amount) or 1

    local quantityFunc = getQuantity(itemid, checkQuality, metaInformation)
    if quantityFunc >= amount then
        return true
    end
    if shouldReturnText then
        Cylex.Notify('phone', 'no_item')
    end
    return false
end

function getQuantity(itemid, checkQuality, metaInformation)
    if itemid == nil then return 0 end
    local amount = 0
    
    local clientInventory = exports["tgiann-inventory"]:GetPlayerItems()
    if not clientInventory or next(clientInventory) == nil then return 0 end
    
    if checkQuality == nil then
        checkQuality = false
    end

    for i, v in pairs(clientInventory) do
        if v and next(v) and v.name and v.name:lower() == itemid:lower() then
            local qCheck = (checkQuality == false and true) or (getQuality(v) == true and true or false)
            if itemid == 'cash' then qCheck = true end

            if qCheck == true then
                local itemCount = v.count or v.amount or 1
                if metaInformation then
                    local totalMetaKeys = 0
                    local metaFoundCount = 0
                    local itemInfo = v.info or {}
                    for metaKey, metaValue in pairs(metaInformation) do
                        totalMetaKeys = totalMetaKeys + 1
                        if itemInfo[metaKey] and itemInfo[metaKey] == metaValue then
                            metaFoundCount = metaFoundCount + 1
                        end
                    end
                    if totalMetaKeys <= metaFoundCount then
                        amount = amount + itemCount
                    end
                else
                    amount = amount + itemCount
                end
            end
        end
    end
    return amount
end

function getItemInfo(itemid, limitAmount, checkQuality, metaInformation)
    if itemid == nil then
        return false
    end
    local minQuality = type(checkQuality) == "number" and checkQuality or 0
    local itemsFound = {}
    local amount = tonumber(limitAmount)
    
    local items = exports['tgiann-inventory']:GetItemList()
    if not items then return false, 0 end

    for k, v in pairs(items) do
        if amount and #itemsFound >= amount then
            break
        end

        local qCheck = false
        if checkQuality and v.info and v.info.quality and v.info.quality > minQuality then
            qCheck = true
        elseif not checkQuality then
            qCheck = true
        end
        
        if v.name == itemid and qCheck then
            if metaInformation then
                if v.info then
                    local totalMetaKeys = 0
                    local metaFoundCount = 0
                    local itemInfo = v.info
                    for metaKey, metaValue in pairs(metaInformation) do
                        totalMetaKeys = totalMetaKeys + 1
                        if itemInfo[metaKey] and tostring(itemInfo[metaKey]) == tostring(metaValue) then
                            metaFoundCount = metaFoundCount + 1
                        end
                    end
                    if totalMetaKeys <= metaFoundCount then
                        return v, k
                    end
                end
            else
                return v, k
            end
        end
    end
    return false, 0
end

-- racing

function getHasRaceUsbAndAlias()
    local currentJob = Cylex.GetJob()

    if not Config.RacingItemRequired then
        return {
            has_usb_racing = true,
            has_usb_racing_create = true,
            has_usb_pd_racing = true,
            racingAlias = "test",
        }
    end

    local characterId = getCharacterId()
    local has_usb_racing_create = Cylex.HasEnoughItem('racingusb0', 1, false, true, {
        characterId = tostring(characterId),
    })
    local has_usb_racing, infoIndex = Cylex.GetItemInfo('racingusb2', 1, true, {
        characterId = tostring(characterId),
    })
    local pdRacingUsbItem = Cylex.HasEnoughItem('racingusb3', 1, false, true)
    local has_usb_pd_racing = pdRacingUsbItem ~= nil and currentJob.name == 'police'
    local usbMetadata = has_usb_racing and has_usb_racing.info or {}

    local racingAlias = has_usb_racing and usbMetadata.alias or nil

    return {
        has_usb_racing = has_usb_racing and true or false,
        has_usb_racing_create = has_usb_racing_create and true or false,
        has_usb_pd_racing = has_usb_pd_racing and true or false,
        racingAlias = racingAlias,
    }
end

exports('getHasRaceUsbAndAlias', getHasRaceUsbAndAlias)


