-- DaddyRP: debug only, players never see these commands
if not Config.Debug then return end
local DEBUG_VISUALS_ENABLED = false

-- Hızlı toggle: /farmzone — aktif tarlanın polyzone'unu canlı çizer
RegisterCommand('farmzone', function()
    DEBUG_VISUALS_ENABLED = not DEBUG_VISUALS_ENABLED
    ClientState.debugEnabled = DEBUG_VISUALS_ENABLED
    local state = DEBUG_VISUALS_ENABLED and '^2AÇIK^7' or '^1KAPALI^7'
    print('[FarmZone] Polyzone debug visuals: ' .. state)
    if Krypton and Krypton.Notify then
        Krypton.Notify('Zone debug: ' .. (DEBUG_VISUALS_ENABLED and 'AÇIK' or 'KAPALI'), 'info')
    end
end, false)

local function DrawDebugPolyZone(zone, r, g, b, a, label)
    if not zone or not zone.points then return end
    
    local points = zone.points
    local minZ = zone.minZ or 0
    local maxZ = zone.maxZ or 100
    local centerX, centerY = 0, 0
    for _, p in ipairs(points) do
        centerX = centerX + p.x
        centerY = centerY + p.y
    end
    centerX = centerX / #points
    centerY = centerY / #points
    
    for i = 1, #points do
        local p1 = points[i]
        local p2 = points[(i % #points) + 1]
        DrawLine(p1.x, p1.y, minZ, p2.x, p2.y, minZ, r, g, b, a)
        DrawLine(p1.x, p1.y, maxZ, p2.x, p2.y, maxZ, r, g, b, a)
        DrawLine(p1.x, p1.y, minZ, p1.x, p1.y, maxZ, r, g, b, a)
    end
    
    for i = 1, #points do
        local p1 = points[i]
        local p2 = points[(i % #points) + 1]
        DrawPoly(centerX, centerY, minZ + 0.1, p1.x, p1.y, minZ + 0.1, p2.x, p2.y, minZ + 0.1, r, g, b, 80)
        DrawPoly(p2.x, p2.y, minZ + 0.1, p1.x, p1.y, minZ + 0.1, centerX, centerY, minZ + 0.1, r, g, b, 80)
        DrawPoly(p1.x, p1.y, minZ, p2.x, p2.y, minZ, p2.x, p2.y, maxZ, r, g, b, 40)
        DrawPoly(p2.x, p2.y, maxZ, p1.x, p1.y, maxZ, p1.x, p1.y, minZ, r, g, b, 40)
    end
    
    if label then
        DrawText3DDebug(centerX, centerY, maxZ + 1.0, label, r, g, b)
    end
end

function DrawText3DDebug(x, y, z, text, r, g, b)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - vector3(x, y, z))
    
    if onScreen and dist < 100.0 then
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        if scale > 0.5 then scale = 0.5 end
        
        SetTextScale(0.0, scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(r or 255, g or 255, b or 255, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function DrawDebugHarvestSpot(coords, index, collected)
    local r, g, b = 50, 205, 50
    if collected then r, g, b = 128, 128, 128 end
    
    DrawMarker(27, coords.x, coords.y, coords.z + 0.5, 0, 0, 0, 0, 0, 0,
        0.5, 0.5, 0.5, r, g, b, 150, true, true, 2, false, nil, nil, false)
    DrawText3DDebug(coords.x, coords.y, coords.z + 1.0, tostring(index), r, g, b)
end

CreateThread(function()
    while true do
        if not DEBUG_VISUALS_ENABLED then
            Wait(2000)
            goto continue
        end

        if ClientState.debugEnabled then
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            if ClientState.isJobActive and ClientState.currentJob and ClientState.currentJob.region then
                local region = ClientState.currentJob.region
                if region.zone and region.zone.points then
                    local centerDist = region.center and #(playerCoords - region.center) or 0
                    if centerDist < 150.0 then
                        local r, g, b = 100, 200, 255
                        if region.type == 'starter' then r, g, b = 50, 255, 50
                        elseif region.type == 'advanced' then r, g, b = 255, 200, 50
                        elseif region.type == 'elite' then r, g, b = 255, 50, 50 end
                        
                        DrawDebugPolyZone(region.zone, r, g, b, 255, region.name .. ' [' .. (region.difficulty or '?') .. ']')
                        if region.center then
                            DrawMarker(1, region.center.x, region.center.y, region.center.z - 0.95, 0, 0, 0, 0, 0, 0,
                                2.0, 2.0, 0.5, r, g, b, 100, false, false, 0, false, nil, nil, false)
                        end
                    end
                end
            end
            
            if ClientState.isJobActive and ClientState.currentJob and #ClientState.harvestSpots > 0 then
                for _, spot in pairs(ClientState.harvestSpots) do
                    DrawDebugHarvestSpot(spot.coords, spot.index, spot.collected)
                end
            end
        end

        ::continue::
        Wait(ClientState.debugEnabled and 0 or 2000)
    end
end)
