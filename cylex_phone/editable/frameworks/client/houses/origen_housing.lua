if Config.Housing ~= 'origen_housing' then return end

function getHouses(data)
    isFrameworkReady()

    local identifier = Cylex.GetIdentifier()
    local globalHouse = exports['origen_housing']:getPlayerHouses(identifier)
    
    -- print(9, json.encode(globalHouse, { indent = true }))
    -- local globalHouse = data or GlobalState.Houses
    local tempTable = {}
    local cid = tostring(Cylex.GetIdentifier())
    if globalHouse then
        for k, v in pairs(globalHouse) do
            local house = v
            if v then
                local door = exports.origen_housing:getHouseDoor(v.id)
                v.door = tostring(door)

                v.name = v.label
                v.zone = v.location
                if not v.access then
                    v.access = {}
                    v.access.keyAccess = {}
                end

                v.can_transfer = false
                v.can_lock = true

                if v.citizenid and tostring(v.citizenid) == cid then
                    table.insert(tempTable, house)
                    v.owned = true
                end
                if v.holders then
                    for k, va in pairs(v.holders) do
                        table.insert(v.access.keyAccess, k)
                        if tostring(k) == cid and not v.owned then
                            table.insert(tempTable, house)
                        end
                    end
                end
            end
        end
    end
    return tempTable
end

AddStateBagChangeHandler('Houses', 'global', function(bagName, value, data)
    SendNUIMessage({
        action = 'setData',
        key = 'houses',
        type = 'set',
        value = getHouses(data),
    })
end)

function hasPlayerAccess(houseId, owner)
    isFrameworkReady()
    local cid = tostring(Cylex.GetIdentifier())
    local data = exports['origen_housing']:getPlayerHouses(cid)
    -- print(55, "hasPlayerAccess", houseId, json.encode(data, { indent = true }))
    if not data then return end


    if data then
        for ka, globalHouse in pairs(data) do
            -- globalHouse.id = globalHouse.name
            local door = exports.origen_housing:getHouseDoor(globalHouse.id)
            globalHouse.door = tostring(door)
            globalHouse.name = globalHouse.label

            if globalHouse.id == houseId then
                if globalHouse.citizenid and tostring(globalHouse.citizenid) == cid then
                    return globalHouse
                end

                if globalHouse.holders and not owner then
                    for k, v in pairs(globalHouse.holders) do
                        if tostring(k) == cid then
                            return globalHouse
                        end
                    end
                end
            end
        end
    end
    return false
end

function giveKey(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    exports.origen_housing:addKeyHolder(tonumber(houseId), target)
    Wait(1000)
    refreshHome()
end

function removeKey(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    exports.origen_housing:removeKeyHolder(houseId, target)
    Wait(500)
    refreshHome()
end

function markHouse(houseId)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    PhoneNotification({
        title = language('house', 'header'),
        text = language('house', 'location_marked'),
        icon = { name = 'app-icon/house.png' },
        timeout = 3,
    })
    exports.origen_housing:setHousePosition(houseId)
end

function lockHouse(houseId)
    local house = hasPlayerAccess(houseId)
    if not house then return end
    if not house.door then
        return
    end
    exports.origen_housing:toggleDoor(houseId, house.door)
end