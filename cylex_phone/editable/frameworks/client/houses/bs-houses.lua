if Config.Housing ~= 'bs-houses' then return end

function getHouses(data)
    isFrameworkReady()

    local globalHouse = data or GlobalState.Houses
    local tempTable = {}
    local cid = tostring(Cylex.GetIdentifier())
    for k, v in pairs(globalHouse) do
        local house = v
        v.id = k
        if v and v.access then
            if v.access.citizenid and tostring(v.access.citizenid) == cid then
                table.insert(tempTable, house)
                v.owned = true
            end

            v.can_lock = false

            if v.access.keyAccess then
                for k, va in pairs(v.access.keyAccess) do
                    if tostring(va) == cid then
                        table.insert(tempTable, house)
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
    local globalHouse = GlobalState.Houses[houseId]
    if not globalHouse then return end

    if not globalHouse.access then
        return false
    end

    local cid = tostring(Cylex.GetIdentifier())

    if globalHouse.access.citizenid and tostring(globalHouse.access.citizenid) == cid then
        return globalHouse
    end

    if globalHouse.access.keyAccess and not owner then
        for k, v in pairs(globalHouse.access.keyAccess) do
            if tostring(v) == cid then
                return globalHouse
            end
        end
    end

    return false
end

function giveKey(houseId)
    local house = hasPlayerAccess(houseId, true)
    if not house then
        return PhoneNotification({
            title = 'Ev',
            text = 'Ev sahibi olmadan evi kitleyemezsin!',
            icon = { name = 'app-icon/house.png' },
            timeout = 3,
        })
    end
    local player, distance = Cylex.GetClosestPlayer()
    if player == -1 or distance > 2.5 then
        return PhoneNotification({
            title = 'Ev',
            text = 'Yakında kimse yok!',
            icon = { name = 'app-icon/house.png' },
            timeout = 3,
        })
    end
    local targetPlayer = GetPlayerServerId(player)
    RPC.execute('bs-houses:giveKey', houseId, targetPlayer)
end

function removeKey(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    RPC.execute('bs-houses:removeKey', houseId, target)
end

function transferHouse(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    RPC.execute('bs-houses:transferHouse', houseId, target)
end

function markHouse(houseId)
    local house = hasPlayerAccess(houseId, true)
    print(104, json.encdode(house))

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

function lockHouse(houseId)
    local house = hasPlayerAccess(houseId)
    if not house then return end
    RPC.execute('bs-houses:toggleHouseDoorLock', houseId)
end