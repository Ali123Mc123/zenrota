if Config.Inventory ~= 'bs-inventory' then return end

exports('hasEnoughOfItem', function(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
end)

exports('getItemInfo', function(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return getItemInfo(itemid, amount, shouldReturnText, checkQuality, metaInformation)
end)

exports('getQuantity', function(itemid, checkQuality, metaInformation)
    return getQuantity(itemid, checkQuality, metaInformation)
end)

local function getQuality(info)
    if info ~= nil and next(info) ~= nil then
        for i = 1, #info do 
            local v = info[i]
            if v and v.quality and v.quality > 0.0 then 
                return true, i
            end 
        end
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
    local slot = 0
    local found = false

    local quantityFunc = getQuantity(itemid, checkQuality, metaInformation)
    -- print(3162, quantityFunc)
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
    local clientInventory = Cylex.GetPlayerItems()
    if clientInventory == nil or next(clientInventory) == nil then return 0 end
    if checkQuality == nil then 
        checkQuality = false
    end

    for i,v in pairs(clientInventory) do
        if v.name:lower() == itemid:lower() then
            local qCheck = (checkQuality == false and true) or (getQuality(v.info) == true and true or false)
            -- local qCheck = (checkQuality == true and getQuality(v.info) == true) or true
            -- print(3131313131, qCheck, checkQuality, itemid)
            if itemid == "cash" then qCheck = true end
            if qCheck == true then
                if metaInformation then
                    local totalMetaKeys = 0
                    local metaFoundCount = 0
                    local itemMeta = v.info
                    for metaKey, metaValue in pairs(metaInformation) do
                        totalMetaKeys = totalMetaKeys + 1
                        for f = 1, #itemMeta do
                            if itemMeta[f] then
                                -- print(70, f, itemMeta[f][metaKey], metaValue)
                                if itemMeta[f][metaKey] and itemMeta[f][metaKey] == metaValue then
                                    metaFoundCount = metaFoundCount + 1
                                end
                            end
                        end
                    end
                    -- print(7777777777,totalMetaKeys, metaFoundCount)
                    if totalMetaKeys <= metaFoundCount then
                        amount = amount + v.amount
                    end
                else
                    amount = amount + v.amount
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

    local clientInventory = Cylex.GetPlayerItems()

    for i,v in pairs(clientInventory) do
        if amount and #itemsFound >= amount then
            break
        end

        local qCheck = false
        if checkQuality and v.info and v.info[1] and v.info[1].quality and v.info[1].quality > minQuality then
            qCheck = true
        elseif not checkQuality then
            qCheck = true
        end
        if v.name == itemid and qCheck then
            if metaInformation then
                for k, itemMeta in pairs(v.info) do
                    local totalMeta = 0
                    local foundMeta = 0

                    for metaKey, metaValue in pairs(metaInformation) do
                        local itemValue = itemMeta[metaKey]
                        if itemValue then
                            totalMeta += 1
                            if itemValue == metaValue then
                                foundMeta += 1
                            end
                        end
    
                    end

                    if totalMeta > 0 and foundMeta >= totalMeta then
                        return v, k
                    end

                    -- print(totalMeta, foundMeta)
                end
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

    local characterId = tonumber(getCharacterId())
    local has_usb_racing_create = Cylex.HasEnoughItem('racingusb0', 1, false, true, {
        characterId = tostring(characterId),
    })
    local has_usb_racing, infoIndex = Cylex.GetItemInfo('racingusb2', 1, true, {
        characterId = tostring(characterId),
    })
    local pdRacingUsbItem = Cylex.HasEnoughItem('racingusb3', 1, false, true)
    local has_usb_pd_racing = pdRacingUsbItem ~= nil and currentJob.name == 'police'
    local usbMetadata = has_usb_racing and has_usb_racing.info[infoIndex] or {}

    local racingAlias = has_usb_racing and usbMetadata.alias or nil
    return {
        has_usb_racing = has_usb_racing and true or false,
        has_usb_racing_create = has_usb_racing_create and true or false,
        has_usb_pd_racing = has_usb_pd_racing and true or false,
        racingAlias = racingAlias,
    }
end

exports('getHasRaceUsbAndAlias', getHasRaceUsbAndAlias)