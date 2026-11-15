-- ============================================================================
-- Daddy GPS - Blip Event Handlers
-- ============================================================================
-- Processes server refresh data, creates/updates blip entries, sends NUI
-- updates. Local player is excluded from blip creation (only shown in NUI).
-- ============================================================================

local FollowTargetSrc = nil
local mySource = nil

local function GetMySource()
    if mySource then return mySource end
    local id = PlayerId()
    if id and id >= 0 then
        mySource = GetPlayerServerId(id)
    end
    return mySource or 0
end

RegisterNetEvent('daddy:gps:refresh', function(units)
    if not IsConnected then return end

    local localSrc = GetMySource()
    local nuiUnits = {}
    local currentUnits = {}
    local playerCoords = GetEntityCoords(PlayerPedId())

    -- ================================================================
    -- Pass 1: Parse all units & build vehicle groups
    -- ================================================================
    local parsedUnits = {}
    local vehicleGroups = {}  -- vehNetId -> { driverSrc=number|nil, driverUnit=table|nil }
    local unitsBySrc = {}

    for _, data in ipairs(units) do
        local src = data[1]

        local u = {
            source   = src,
            coords   = { x = data[2] / 10.0, y = data[3] / 10.0, z = data[4] / 10.0 },
            heading  = data[5] * 1.0,
            vehType  = vTypeIDMap[data[6]] or 'car',
            job      = data[7],
            callsign = data[8],
            name     = data[9],
            siren    = (data[10] == 1),
            vehNetId = data[11] or 0,
            vehSeat  = data[12] or -2
        }

        parsedUnits[#parsedUnits + 1] = u
        unitsBySrc[src] = u

        -- Build vehicle groups: track if a driver exists in this vehicle
        local vid = u.vehNetId
        if vid and vid ~= 0 then
            if not vehicleGroups[vid] then
                vehicleGroups[vid] = { driverSrc = nil, driverUnit = nil }
            end
            if u.vehSeat == -1 then
                vehicleGroups[vid].driverSrc = src
                vehicleGroups[vid].driverUnit = u
            end
        end
    end

    -- ================================================================
    -- Pass 2: Process blips (hide passengers when driver is on GPS)
    -- ================================================================
    for _, u in ipairs(parsedUnits) do
        local src = u.source
        currentUnits[src] = true

        -- Signal strength for NUI display
        local signal = CalculateSignalStrength(u.coords, playerCoords)

        local dept = Config.Departments[u.job]
        table.insert(nuiUnits, {
            source   = src,
            name     = u.name,
            callsign = u.callsign,
            job      = u.job,
            vehType  = u.vehType,
            deptLabel = dept and dept.text or u.job,
            signal   = signal,
            coords   = u.coords,
            color    = dept and string.format('%d,%d,%d',
                           dept.r or 255, dept.g or 255, dept.b or 255) or nil
        })

        -- Skip blip creation for the local player (unless self-blip enabled)
        if src == localSrc and not ShowSelfBlip then goto continue end

        -- Channel filter: hide blips for units outside the active channel
        if CurrentChannel ~= 'Global' and u.job ~= CurrentChannel then
            if Blips[src] then
                RemoveBlipSafe(Blips[src].blip)
                RemoveBlipSafe(Blips[src].overlay)
                Blips[src] = nil
            end
            goto continue
        end

        -- Vehicle grouping: when a passenger shares a vehicle with a GPS driver
        -- we still render their blip, but inherit the driver's identity (label,
        -- sprite, colour, vehicle kind, siren state). Because the engine groups
        -- legend entries by name, this collapses the carpool into a single line
        -- like "[12] Driver Name (2)" while still keeping every player's blip
        -- on the map.
        local groupingHost = u
        local vid = u.vehNetId
        if vid and vid ~= 0 and u.vehSeat ~= -1 then
            local group = vehicleGroups[vid]
            if group and group.driverSrc and group.driverUnit then
                groupingHost = group.driverUnit
            end
        end

        -- Get or create blip data entry
        local d = Blips[src]
        if not d then
            d = {
                blip        = nil,
                overlay     = nil,
                cur         = nil,
                target      = nil,
                lastSprite  = nil,
                lastColour  = nil,
                lastLabel   = nil,
                lastHeading = nil,
                lastJob     = nil,
                isStationary = false,
            }
            Blips[src] = d
        end

        -- Update target position (use the actual unit's coords, not the host's)
        if u.coords then
            d.target = { x = u.coords.x, y = u.coords.y, z = u.coords.z }
            if not d.cur then
                d.cur = { x = u.coords.x, y = u.coords.y, z = u.coords.z }
            end
        end

        d.lastHeading = u.heading or 0
        d.lastJob     = groupingHost.job

        -- Resolve visual properties from the grouping host so passengers visually
        -- merge into the driver's legend entry.
        local hostDept = Config.Departments[groupingHost.job]
        local sprite = ResolveSprite(groupingHost)
        local colour = (hostDept and hostDept.color) or GetJobStyle(groupingHost.job).color or 0
        -- 'none' mode (dept-label): show only the short department tag (e.g. "PD") as
        -- the blip name. Every other mode shows the full "[callsign] Name" label.
        local label  = (BlipCategoryMode == 'none') and GetDeptLabel(groupingHost.job) or BuildLabel(groupingHost)
        local vKind  = VehKind(groupingHost)

        local needsUpdate = ForceImmediateReskin
            or (d.lastSprite ~= sprite)
            or (d.lastColour ~= colour)
            or (d.lastLabel  ~= label)
            or (d.lastVehKind ~= vKind)

        if needsUpdate then
            ApplyVisualsToBlip(d, sprite, colour, label, vKind)
        end

        ::continue::
    end

    -- Cache for instant reopen (avoids blank unit list on GPS reopen)
    GPS_Client.CachedUnits = nuiUnits

    -- Push unit list to NUI (include localSource for self-action filtering)
    SendNUIMessage({
        action = 'updateUnits',
        units  = nuiUnits,
        localSource = localSrc
    })

    -- Remove blips for players that left the GPS
    for src, d in pairs(Blips) do
        if not currentUnits[src] then
            RemoveBlipSafe(d.blip)
            RemoveBlipSafe(d.overlay)
            Blips[src] = nil
            UnitsPresent[src] = nil
        end
    end

    ForceImmediateReskin = false
end)

-- ============================================================================
-- GPS Connection State
-- ============================================================================

AddEventHandler('daddy:gps:connected', function()
    IsConnected = true
    ForceImmediateReskin = true
    -- Hide default GTA player blip if self blip is enabled
    if ShowSelfBlip then
        local mainBlip = GetMainPlayerBlipId()
        if mainBlip and DoesBlipExist(mainBlip) then
            SetBlipDisplay(mainBlip, 0)
        end
    end
end)

AddEventHandler('daddy:gps:disconnected', function()
    IsConnected = false
    ClearAllGpsBlips()
    -- Restore default GTA player blip
    local mainBlip = GetMainPlayerBlipId()
    if mainBlip and DoesBlipExist(mainBlip) then
        SetBlipDisplay(mainBlip, 2)
    end
end)

-- ============================================================================
-- Reskin Events
-- ============================================================================

RegisterNetEvent('daddy:gps:updateSelfBlip', function(state)
    ShowSelfBlip = state
    local localSrc = GetMySource()
    if not state and Blips[localSrc] then
        RemoveBlipSafe(Blips[localSrc].blip)
        RemoveBlipSafe(Blips[localSrc].overlay)
        Blips[localSrc] = nil
    end
    -- Hide/show default GTA player blip (white triangle)
    local mainBlip = GetMainPlayerBlipId()
    if mainBlip and DoesBlipExist(mainBlip) then
        SetBlipDisplay(mainBlip, state and 0 or 2)
    end
    ForceImmediateReskin = true
end)

RegisterNetEvent('daddy:gps:forceReskin', function()
    ForceImmediateReskin = true
end)

-- Triggered locally when the user changes their blip-category preference.
-- Re-applies the category to every existing blip and forces a full reskin so
-- labels are also re-issued (which gives the engine a chance to register them
-- in fresh ticks - see citizenfx/fivem#3334).
AddEventHandler('daddy:gps:blipCategoryChanged', function()
    for _, d in pairs(Blips) do
        if d.blip and DoesBlipExist(d.blip) then
            SetBlipCategory(d.blip, ResolveBlipCategory(d.lastJob))
        end
        if d.overlay and DoesBlipExist(d.overlay) then
            SetBlipCategory(d.overlay, ResolveBlipCategory(d.lastJob))
        end
    end
    ForceImmediateReskin = true
end)

-- ============================================================================
-- Follow Target
-- ============================================================================

AddEventHandler('daddy:gps:setFollowTarget', function(src)
    FollowTargetSrc = src
    if src then
        Framework.Notify(nil, L('notify.tracking_activated', 'GPS tracking activated.'), 'success')
    else
        Framework.Notify(nil, L('notify.tracking_disabled', 'GPS tracking disabled.'), 'error')
    end
end)

CreateThread(function()
    while true do
        if FollowTargetSrc and IsConnected then
            local d = Blips[FollowTargetSrc]
            if d and d.target then
                SetNewWaypoint(d.target.x, d.target.y)
            end
        end
        Wait(6000)
    end
end)

-- ============================================================================
-- Resource Cleanup
-- ============================================================================

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    ClearAllGpsBlips()
end)
