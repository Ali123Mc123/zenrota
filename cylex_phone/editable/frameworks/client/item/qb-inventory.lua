if Config.Inventory ~= 'qb-inventory' then return end

exports('hasEnoughOfItem', function(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    return hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
end)

exports('getQuantity', function(itemid, checkQuality, metaInformation)
    return getQuantity(itemid, checkQuality, metaInformation)
end)

local function getQuality(v)
    if (not v or not v.quality) or (v.quality and v.quality) > 0.0 then
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
    local slot = 0
    local found = false

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
    local clientInventory = Cylex.GetPlayerItems()
    if clientInventory == nil or next(clientInventory) == nil then return 0 end
    if checkQuality == nil then
        checkQuality = false
    end

    for i, v in pairs(clientInventory) do
        if v and next(v) and v.name:lower() == itemid:lower() then
            local qCheck = (checkQuality == false and true) or (getQuality(v.info) == true and true or false)
            if itemid == 'cash' then qCheck = true end

            if qCheck == true then
                local itemCount = v.amount or v.count
                if metaInformation then
                    local totalMetaKeys = 0
                    local metaFoundCount = 0
                    local itemMeta = v.info
                    for metaKey, metaValue in pairs(metaInformation) do
                        totalMetaKeys = totalMetaKeys + 1
                        if itemMeta[metaKey] and itemMeta[metaKey] == metaValue then
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
    local items = Cylex.GetPlayerItems()

    for i,v in pairs(items) do
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
                    local itemMeta = v.info
                    for metaKey, metaValue in pairs(metaInformation) do
                        totalMetaKeys = totalMetaKeys + 1
                        if itemMeta[metaKey] and tostring(itemMeta[metaKey]) == tostring(metaValue) then
                            metaFoundCount = metaFoundCount + 1
                        end
                    end
                    if totalMetaKeys <= metaFoundCount then
                        -- itemsFound[#itemsFound+1] = v
                        return v, k
                    end
                end
            end
        end
    end
    return false, 0
end


-- racing

local cachedResult = nil
local cachedAt = 0

function getHasRaceUsbAndAlias()
    local now = GetGameTimer()
    if cachedResult and now - cachedAt < 1000 then -- 1 saniye boyunca cache kullan
        return cachedResult
    end

    -- Buradan itibaren mevcut kodun devamı...
    local currentJob = Cylex.GetJob()
    if not Config.RacingItemRequired then
        cachedResult = {
            has_usb_racing = true,
            has_usb_racing_create = true,
            has_usb_pd_racing = true,
            racingAlias = "test",
        }
        cachedAt = now
        return cachedResult
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

    cachedResult = {
        has_usb_racing = has_usb_racing and true or false,
        has_usb_racing_create = has_usb_racing_create and true or false,
        has_usb_pd_racing = has_usb_pd_racing and true or false,
        racingAlias = racingAlias,
    }
    cachedAt = now
    return cachedResult
end


exports('getHasRaceUsbAndAlias', getHasRaceUsbAndAlias)