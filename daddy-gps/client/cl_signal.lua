local function getDistance(c1, c2)
    if not c1 or not c2 then return 99999.0 end
    local x1 = c1.x or 0
    local y1 = c1.y or 0
    local z1 = c1.z or 0
    local x2 = c2.x or 0
    local y2 = c2.y or 0
    local z2 = c2.z or 0
    return #(vector3(x1, y1, z1) - vector3(x2, y2, z2))
end

local function isDeadZone(coords)
    if not coords then return false end
    local z = coords.z or 0
    local x = coords.x or 0
    local y = coords.y or 0
    
    if z < -50.0 then return true end
    
    if #(vector2(x, y) - vector2(0, 0)) > 15000.0 then return true end
    
    if z > 400.0 and 
       x > -600.0 and x < 600.0 and 
       y > 4000.0 and y < 6000.0 then
        return true
    end
    
    return false
end

function CalculateSignalStrength(unitCoords, playerCoords)
    if not unitCoords or not playerCoords then return 0 end
    
    if isDeadZone(unitCoords) then return 0 end
    
    local dist = getDistance(unitCoords, playerCoords)
    
    if dist < 300.0 then
        return 4
    elseif dist < 1500.0 then
        return 3
    elseif dist < 4000.0 then
        return 2
    else
        return 1
    end
end

exports('CalculateSignalStrength', CalculateSignalStrength)
