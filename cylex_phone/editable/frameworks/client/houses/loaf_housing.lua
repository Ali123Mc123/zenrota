if Config.Housing ~= 'loaf_housing' then return end

function getHouses(data)
    isFrameworkReady()

    local globalHouse = Cylex.TriggerCallback('qb-phone:server:GetPlayerHouses')
    -- local globalHouse = data or GlobalState.Houses
    local tempTable = {}
    local cid = tostring(Cylex.GetIdentifier())
    for k, v in pairs(globalHouse) do
        local house = v
        v.id = v.name
        v.name = v.label
        if v then
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

            if v.keyHolders then
                for k, va in pairs(v.keyHolders) do
                    table.insert(v.access.keyAccess, v.citizenid)
                    if tostring(va.citizenid) == cid then
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
    local data = Cylex.TriggerCallback('qb-phone:server:GetPlayerHouses')
    if not data then return end

    local cid = tostring(Cylex.GetIdentifier())

    for ka, globalHouse in pairs(data) do
        globalHouse.id = globalHouse.name
        globalHouse.name = globalHouse.label
        if globalHouse.owner and tostring(globalHouse.owner) == cid then
            return globalHouse
        end


        if globalHouse.keyHolders and not owner then
            for k, v in pairs(globalHouse.keyHolders) do
                if tostring(v.citizenid) == cid then
                    return globalHouse
                end
            end
        end
    end
    return false
end

function giveKey(houseId)
    PhoneNotification({
        title = language('house', 'header'),
        text = language('house', 'under_development'),
        icon = { name = 'app-icon/house.png' },
        timeout = 3,
    })
end

function removeKey(houseId, target)
    local house = hasPlayerAccess(houseId, true)
    if not house then return end
    PhoneNotification({
        title = language('house', 'header'),
        text = language('house', 'under_development'),
        icon = { name = 'app-icon/house.png' },
        timeout = 3,
    })
end

function setWaypoint(houseId)
    local houseConfig = exports['loaf_housing']:GetHouses()[house.id]
    if not houseConfig then return end
    SetNewWaypoint(houseConfig.entrance.x, houseConfig.entrance.y)
    PhoneNotification({
        title = language('house', 'header'),
        text = language('house', 'location_marked'),
        icon = { name = 'app-icon/house.png' },
        timeout = 3,
    })
end