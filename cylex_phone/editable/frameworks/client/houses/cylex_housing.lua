if Config.Housing ~= 'cylex_housing' then return end

function getHouses(data)
    isFrameworkReady()

    local identifier = Cylex.GetIdentifier()
    local globalHouse = exports['cylex_housing']:getPlayerHouses(identifier)
    
    -- print(9, json.encode(globalHouse, { indent = true }))
    -- local globalHouse = data or GlobalState.Houses
    local tempTable = {}
    local cid = tostring(Cylex.GetIdentifier())
    if globalHouse then
        for k, v in pairs(globalHouse) do
            local house = v
            if v then
                v.id = k
                v.name = v.streetName .. ' ' .. v.location
                v.zone = v.location
                if not v.access then
                    v.access = {}
                    v.access.keyAccess = {}
                end

                v.can_transfer = false
                v.can_lock = false

                if v.owner and tostring(v.owner) == cid then
                    table.insert(tempTable, house)
                    v.owned = true
                end
                if v.keys then
                    for k, va in pairs(v.keys) do
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
    local data = exports['cylex_housing']:getPlayerHouses(cid)
    -- print(55, "hasPlayerAccess", houseId, json.encode(data, { indent = true }))
    if not data then return false end


    if data then
        for ka, globalHouse in pairs(data) do
            -- globalHouse.id = globalHouse.name
            -- local door = exports.origen_housing:getHouseDoor(globalHouse.id)
            -- globalHouse.door = tostring(door)
            globalHouse.name = globalHouse.label

            if ka == houseId then
                if globalHouse.owner and tostring(globalHouse.owner) == cid then
                    return globalHouse
                end

                if globalHouse.keys and not owner then
                    for k, v in pairs(globalHouse.keys) do
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
    local playerData = UserData[tostring(target)]
    if playerData then
        TriggerServerEvent('cylex_housing:server:giveKey', houseId, playerData.online)
    end
    Wait(1000)
    refreshHome()
end

function removeKey(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    TriggerServerEvent('cylex_housing:server:removeKey', houseId, tostring(target))
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
    local enterCoords = house.enterCoords
    if enterCoords then
        SetNewWaypoint(enterCoords.x, enterCoords.y)
    end
end

local locked = false

function lockHouse(houseId)
    -- local house = hasPlayerAccess(houseId)
    -- if not house then return end
    -- if not house.door then
    --     return
    -- end
    -- locked = not locked
    -- if locked then
    --     PhoneNotification({
    --         title = language('house', 'header'),
    --         text = language('house', 'house_locked'),
    --         icon = { name = 'app-icon/house.png' },
    --         timeout = 3,
    --     })
    -- else
    --     PhoneNotification({
    --         title = language('house', 'header'),
    --         text = language('house', 'house_unlocked'),
    --         icon = { name = 'app-icon/house.png' },
    --         timeout = 3,
    --     })
    -- end

    -- local houses = getHouses(data)
    -- for k, v in pairs(houses) do
    --     v.unlocked = locked
    -- end
    -- SendNUIMessage({
    --     action = 'setData',
    --     key = 'houses',
    --     type = 'set',
    --     value = houses,
    -- })
end