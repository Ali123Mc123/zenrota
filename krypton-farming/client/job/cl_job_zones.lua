function IsPointInPolygon(point, polygon)
    local x, y = point.x, point.y
    local inside = false
    local j = #polygon
    
    for i = 1, #polygon do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y
        
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    
    return inside
end

function IsInsideZone(coords, zone)
    if not zone or not zone.points then return false end
    
    if zone.minZ and coords.z < zone.minZ then return false end
    if zone.maxZ and coords.z > zone.maxZ then return false end
    
    if zone.bounds then
        if coords.x < zone.bounds.minX or coords.x > zone.bounds.maxX or
           coords.y < zone.bounds.minY or coords.y > zone.bounds.maxY then
            return false
        end
    end
    
    return IsPointInPolygon(vector2(coords.x, coords.y), zone.points)
end

-- Zone'un kısa kenarının %30'unu wander radius olarak döner.
-- Hayvanlar merkeze yakın kalır; kenara çıkmalarını tetherle birlikte önler.
function GetZoneWanderRadius(zone)
    if not (zone and zone.bounds) then
        error('[GetZoneWanderRadius] Zone bounds yok — bu fonksiyon sadece polyzone destekli regionlarda çağırılmalı', 2)
    end
    local w = zone.bounds.maxX - zone.bounds.minX
    local h = zone.bounds.maxY - zone.bounds.minY
    local r = math.min(w, h) * 0.30 - 2.0
    return math.max(3.0, r)
end

-- Zone içinde + kenardan en az `margin` m içeride mi?
-- Polygon-aware: test noktasını AABB merkezi yönünde `margin` kadar kaydırarak
-- polygon testi yapar. Bu, dikörtgen olmayan zone'lardaki köşe boşluklarını
-- ve düzensiz kenarları doğru işler (sadece AABB margin yetersiz).
-- Polyzone zorunlu, yoksa hata atar.
function IsDeepInsideZone(coords, zone, margin)
    if not (zone and zone.bounds and zone.points) then
        error('[IsDeepInsideZone] Polyzone zorunlu — bounds/points eksik', 2)
    end
    margin = margin or 1.5
    local b = zone.bounds
    -- Hızlı AABB ön-red: kenarın margin kadar içindeki kutu dışındaysa direk false
    if coords.x < b.minX + margin or coords.x > b.maxX - margin then return false end
    if coords.y < b.minY + margin or coords.y > b.maxY - margin then return false end
    if zone.minZ and coords.z < zone.minZ then return false end
    if zone.maxZ and coords.z > zone.maxZ then return false end
    -- Polygon testi: noktası AABB merkezi yönünde margin kadar kaydır.
    -- Bu sayede polygon kenarına çok yakın noktalar (köşelerdeki AABB geşişleri dahil)
    -- false döndürür. Hayvan merkeze yaklaştırılırsa polygon testini geçmiyorsa sınırdayız.
    local cx = (b.minX + b.maxX) * 0.5
    local cy = (b.minY + b.maxY) * 0.5
    local dx, dy = cx - coords.x, cy - coords.y
    local lenSq = dx * dx + dy * dy
    local tx, ty
    if lenSq > margin * margin then
        local invLen = 1.0 / math.sqrt(lenSq)
        tx = coords.x + dx * invLen * margin
        ty = coords.y + dy * invLen * margin
    else
        tx, ty = coords.x, coords.y
    end
    return IsPointInPolygon(vector2(tx, ty), zone.points)
end

function PrecomputeRegionBounds(region)
    if region and region.zone and region.zone.points and #region.zone.points > 0 then
        local minX, maxX = math.huge, -math.huge
        local minY, maxY = math.huge, -math.huge
        for _, p in ipairs(region.zone.points) do
            if p.x < minX then minX = p.x end
            if p.x > maxX then maxX = p.x end
            if p.y < minY then minY = p.y end
            if p.y > maxY then maxY = p.y end
        end
        region.zone.bounds = { minX = minX, maxX = maxX, minY = minY, maxY = maxY }
    end
end

function StartFieldArrivalCheck(region)
    PrecomputeRegionBounds(region)
    
    CreateThread(function()
        local wasInside = false
        local hasPolyZone = region.zone and region.zone.points and #region.zone.points >= 3
        
        -- For custom admin farms without PolyZone, calculate dynamic radii from harvestSpots
        local enterRadius = 50.0  -- default
        local exitRadius = 80.0   -- default (enter + buffer so player doesn't flip-flop)
        
        if not hasPolyZone and region.center and region.harvestSpots then
            local centerVec = vector3(region.center.x, region.center.y, region.center.z or 0.0)
            local maxSpotDist = 0.0
            for _, spot in ipairs(region.harvestSpots) do
                local spotVec = vector3(spot.coords.x, spot.coords.y, spot.coords.z or 0.0)
                local d = #(vector2(spotVec.x, spotVec.y) - vector2(centerVec.x, centerVec.y))
                if d > maxSpotDist then maxSpotDist = d end
            end
            -- Enter radius = farthest spot distance + 20m buffer (minimum 40m)
            enterRadius = math.max(40.0, maxSpotDist + 20.0)
            -- Exit radius = enter radius + 30m extra to prevent flip-flop
            exitRadius = enterRadius + 30.0
            DebugPrint('[Zone] Dynamic radius calculated - Enter:', enterRadius, 'Exit:', exitRadius, 'MaxSpotDist:', maxSpotDist)
        end
        
        while ClientState.isJobActive and ClientState.currentJob do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isInside = false
            local totalSpots = ClientState.currentJob.totalSpots or #(ClientState.currentJob.region and ClientState.currentJob.region.harvestSpots or {})
            local isJobComplete = ClientState.currentJob.isComplete or (totalSpots > 0 and ClientState.currentJob.progress >= totalSpots)

            if isJobComplete and not ClientState.currentJob.isComplete then
                ClientState.currentJob.isComplete = true
            end
            
            if hasPolyZone then
                isInside = IsInsideZone(playerCoords, region.zone)
            elseif region.center then
                -- Distance-based fallback for custom admin farms (hysteresis)
                local centerVec = vector3(region.center.x, region.center.y, region.center.z or playerCoords.z)
                local dist = #(playerCoords - centerVec)
                
                if wasInside then
                    -- Already inside: use larger exit radius (harder to leave)
                    isInside = dist < exitRadius
                else
                    -- Outside: use smaller enter radius (must get close enough)
                    isInside = dist < enterRadius
                end
            end
            
            if isInside and not wasInside then
                if not ClientState.currentJob.arrivedAtField then
                    ClientState.currentJob.arrivedAtField = true
                    
                    SendNUIMessage({
                        action = 'updateJobStep',
                        data = 'harvest'
                    })
                    
                    SendNUIMessage({
                        action = 'updatePlayerStatus',
                        data = T('status_working')
                    })
                    
                    Krypton.Notify(T('arrived_at_field'), 'success')
                    
                    if ClientState.centerBlip then
                        RemoveBlip(ClientState.centerBlip)
                        ClientState.centerBlip = nil
                    end
                    
                    SpawnHarvestSpots(region)
                    
                    if region.type == 'livestock' then
                        StartLivestockLoop()
                    else
                        StartHarvestLoop()
                    end
                end
            end

            -- Once the player has arrived at the field, zone entry/exit must
            -- NEVER change the active step. The only allowed transition is
            -- job completion → 'finish'. This prevents any glitch where briefly
            -- leaving the zone resets the HUD and blocks job completion.
            if ClientState.currentJob.arrivedAtField and isJobComplete
                and not ClientState.currentJob._finishSent then
                ClientState.currentJob._finishSent = true
                SendNUIMessage({
                    action = 'updateJobStep',
                    data = 'finish'
                })
                SendNUIMessage({
                    action = 'updatePlayerStatus',
                    data = T('status_idle')
                })
            end
            
            wasInside = isInside
            Wait(500)
        end
    end)
end

CreateThread(function()
    while true do
        Wait(1000)
        
        local region = ClientState.currentJob and ClientState.currentJob.region
        local totalSpots = region and #(region.harvestSpots or {}) or 0
        if ClientState.isJobActive and ClientState.currentJob and ClientState.currentJob.progress >= totalSpots then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isNearNpc = false
            for idx, npc in ipairs(Config.NPC or {}) do
                local nc = npc.coords
                if #(playerCoords - vector3(nc.x, nc.y, nc.z)) < (Config.DistanceToInteract or 2.5) + 1.0 then
                    isNearNpc = true
                    ClientState.activeNpcIndex = idx
                    break
                end
            end
            if isNearNpc then
                -- Job is complete; player should finish via NPC dialogue option
                ClientState.currentJob.isComplete = true
            end
        end
    end
end)
