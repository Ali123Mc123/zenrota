local showing = false

local function dprint(...)
    if Config.Debug then
        print('[daddy-gps:ui]', ...)
    end
end

local function GetPlayerJobName()
    return Editable.GetPlayerJob()
end

local function IsAllowedJobClient()
    return Editable.IsAllowedJob()
end

local function Notify(message, type)
    Editable.Notify(message, type or 'info')
end

local deptOrderCache

local function GetDepartmentOrderFromConfigFile()
    if deptOrderCache then return deptOrderCache end

    deptOrderCache = {}
    local cfg = LoadResourceFile(GetCurrentResourceName(), 'shared/config.lua')
    if not cfg then return deptOrderCache end

    local inDepartments = false
    local depth = 0

    for line in cfg:gmatch('[^\r\n]+') do
        if not inDepartments then
            if line:find('Config%.Departments%s*=%s*{') then
                inDepartments = true
                depth = 1
            end
        else
            for ch in line:gmatch('.') do
                if ch == '{' then depth = depth + 1 end
                if ch == '}' then depth = depth - 1 end
            end

            local key = line:match('^%s*([%a_][%w_]*)%s*=%s*{')
            if key and Config.Departments[key] then
                deptOrderCache[#deptOrderCache + 1] = key
            end

            if depth <= 0 then break end
        end
    end

    return deptOrderCache
end

local function BuildDepartmentOptionsForPlayer()
    local opts = {}

    for _, k in ipairs(GetDepartmentOrderFromConfigFile()) do
        local d = Config.Departments[k]
        if d and d.enabled then
            opts[#opts+1] = {
                key = k,
                label = d.label,
                text = d.text,
                color = d.color,
                hex = d.hex,
                enabled = d.enabled
            }
        end
    end

    if #opts == 0 then
        for k, d in pairs(Config.Departments) do
            if d.enabled then
                opts[#opts+1] = {
                    key = k,
                    label = d.label,
                    text = d.text,
                    color = d.color,
                    hex = d.hex,
                    enabled = d.enabled
                }
            end
        end
    end

    return opts
end

local function LoadLocales()
    local locale = Config.Locale or 'en'
    local jsonFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.json')
    if jsonFile then
        return json.decode(jsonFile)
    else
        print('[daddy-gps] Failed to load locales/' .. locale .. '.json, falling back to en.json')
        local fallback = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
        if fallback then
            return json.decode(fallback)
        else
            print('[daddy-gps] Failed to load fallback locales/en.json')
            return {}
        end
    end
end

local function openUI(reason)
    dprint('openUI called. Reason:', reason, 'showing:', showing)
    
    -- Check for item
    if Config.RequireItem then
        if not Editable.HasItem(Config.ItemName) then
            Notify(L('notify.no_gps_item', 'You do not have a GPS device.'), 'error')
            return
        end
    end

    -- Check if GPS is broken by water damage
    if exports['daddy-gps']:IsGPSBroken() then
        local inWater = exports['daddy-gps']:IsInWater()
        dprint('GPS is broken. InWater:', inWater)
        
        -- Reset showing flag to allow broken UI
        showing = false
        Wait(100)
        
        showing = true
        SetNuiFocus(true, true)
        SendNUIMessage({ 
            action = 'broken',
            inWater = inWater,
            locales = LoadLocales()
        })
        return
    end
    
    if Config.RequireRealJob and not IsAllowedJobClient() then
        dprint('Permission denied. Job not allowed.')
        Notify(L('notify.no_permission', 'You do not have permission to use this system.'), 'error')
        return
    end
    
    if showing then 
        dprint('UI already showing.')
        return 
    end
    showing = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', locales = LoadLocales() })
    SendNUIMessage({ action = 'deps', list = BuildDepartmentOptionsForPlayer() })

    -- Send config to NUI
    SendNUIMessage({
        action = 'config',
        data = {
            channelMode = Config.ChannelMode or 'department',
            selfBlipDefault = Config.SelfBlip and Config.SelfBlip.Default or false,
            localSource = GetPlayerServerId(PlayerId()),
            callsignMin = Config.Callsign.Min,
            callsignMax = Config.Callsign.Max,
            selfBlipCurrent = ShowSelfBlip,
            currentLocale = Config.Locale or 'en',
            availableLocales = { 'en', 'tr', 'de', 'fr', 'es', 'it', 'nl', 'pt' },
            blipSizes = {
                Vehicle    = Config.BlipSizes.Vehicle or 0.70,
                OnFoot     = Config.BlipSizes.OnFoot or 0.70,
                Bike       = Config.BlipSizes.Bike or 0.70,
                Helicopter = Config.BlipSizes.Helicopter or 0.70,
                Plane      = Config.BlipSizes.Plane or 0.70,
                Boat       = Config.BlipSizes.Boat or 0.70,
            },
            blipCategoryMode = BlipCategoryMode or 'single',
        }
    })

    -- If already connected (e.g. reopening minimized GPS), use cached profile
    -- to avoid server roundtrip that causes a ~500ms login screen flash
    if GPS_Client.IsOpen then
        SendNUIMessage({
            action  = 'autoConnect',
            profile = GPS_Client.CachedProfile or {},
            units   = GPS_Client.CachedUnits or {},
        })
        return
    end

    -- Fetch profile from server
    dprint('Fetching profile...')
    Framework.TriggerCallback('daddy:gps:getProfile', function(profile)
        dprint('Profile fetched:', json.encode(profile))
        if profile and profile.department then
            profile.department = NormalizeDeptKey(profile.department)
        end
        
        local job = GetPlayerJobName()
        if job == 'ambulance' or job == 'ems' then
            profile.department = 'lsms'
        end
        
        SendNUIMessage({ action = 'prefill', profile = profile or {} })
    end)
end

local function closeUI()
    if not showing then return end
    showing = false
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
end

RegisterNetEvent('daddy-gps:client:open', function(reason) 
    openUI(reason or 'net') 
end)

RegisterNetEvent('daddy:gps:openUi', function() 
    openUI('server') 
end)

RegisterCommand('gps', function()
    if Config.RequireItem then return end
    openUI('command')
end)

-- ============================================================================
-- Keybind
-- ============================================================================

if Config.Keybind and Config.Keybind.Enabled and Config.Keybind.DefaultKey and Config.Keybind.DefaultKey ~= '' then
    lib.addKeybind({
        name = 'daddy_gps_toggle',
        description = Config.Keybind.Description or 'GPS Aç / Kapat',
        defaultKey = Config.Keybind.DefaultKey,
        defaultMapper = 'keyboard',
        onPressed = function(self)
            if showing then
                closeUI()
            else
                openUI('keybind')
            end
        end
    })
end

-- ox_inventory item use callback
exports('open', function()
    openUI('item')
end)

RegisterNUICallback('onConnect', function(data, cb)
    if Config.RequireRealJob and not IsAllowedJobClient() then
        Notify(L('notify.no_permission', 'You do not have permission to use this system.'), 'error')
        cb('ok')
        return
    end

    local deptInput = (data and data.department) or ''
    local officer   = tostring(data and data.officerName or '')
    local callsign  = tonumber(data and data.callsign)

    local deptKey = ResolveDeptKeyFromUserInput(deptInput)
    local job = GetPlayerJobName()
    if (job == 'ambulance' or job == 'ems') then 
        deptKey = 'lsms' 
    end

    if not deptKey or not Config.Departments[deptKey] then
        Notify(L('notify.select_department', 'You must select a department.'), 'error')
        cb('ok')
        return
    end
    
    if (officer:gsub("%s+","") == "") then
        Notify(L('notify.name_empty', 'Officer name cannot be empty.'), 'error')
        cb('ok')
        return
    end
    
    if not callsign or callsign < Config.Callsign.Min or callsign > Config.Callsign.Max then
        Notify(L('notify.callsign_range', 'Callsign must be a number between %s and %s.', Config.Callsign.Min, Config.Callsign.Max), 'error')
        cb('ok')
        return
    end
    callsign = math.floor(callsign)

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    TriggerServerEvent('daddy:gps:joinUi', { 
        department = deptKey, 
        officerName = officer, 
        callsign = callsign,
        channel = 'Global',
        x = coords.x,
        y = coords.y,
        z = coords.z
    })
    
    GPS_Client.CachedCallsign = callsign
    GPS_Client.CachedProfile  = { department = deptKey, officerName = officer, callsign = callsign }
    GPS_Client.IsOpen = true
    
    if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
        LocalPlayer.state:set('callsign', callsign, true)
    end
    
    TriggerEvent('daddy:gps:connected')
    Notify(L('notify.gps_connecting', 'GPS connecting...'), 'success')
    cb('ok')
end)

RegisterNUICallback('onLeave', function(_, cb)
    if GPS_Client.IsOpen then
        TriggerServerEvent('daddy:gps:leave')
        GPS_Client.IsOpen = false
        TriggerEvent('daddy:gps:disconnected')
        Notify(L('notify.gps_disconnecting', 'GPS disconnecting...'), 'error')
    end
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb) 
    closeUI() 
    cb('ok') 
end)

RegisterNUICallback('hardReset', function(_, cb)
    -- Clear all KVP data
    DeleteResourceKvp('daddy_gps_selfblip')
    DeleteResourceKvp('daddy_gps_blipsizes')
    DeleteResourceKvp('daddy_gps_blipcatmode')

    -- Reset runtime state to config defaults
    ShowSelfBlip = Config.SelfBlip and Config.SelfBlip.Default or false
    Config.BlipSizes.Vehicle    = 0.70
    Config.BlipSizes.OnFoot     = 0.70
    Config.BlipSizes.Bike       = 0.70
    Config.BlipSizes.Helicopter = 0.70
    Config.BlipSizes.Plane      = 0.70
    Config.BlipSizes.Boat       = 0.70
    BlipCategoryMode = 'single'
    TriggerEvent('daddy:gps:blipCategoryChanged')
    
    -- Disconnect if connected
    if GPS_Client.IsOpen then
        TriggerServerEvent('daddy:gps:leave')
        GPS_Client.IsOpen = false
        GPS_Client.CachedProfile = nil
        GPS_Client.CachedUnits = nil
        GPS_Client.CachedCallsign = nil
        TriggerEvent('daddy:gps:disconnected')
    end
    
    cb('ok')
end)

RegisterNUICallback('repair', function(_, cb)
    exports['daddy-gps']:RepairGPS()
    cb('ok')
    Wait(100)
    closeUI()
end)

RegisterNUICallback('updateCallsign', function(data, cb)
    local newCallsign = tonumber(data.callsign)
    if newCallsign and newCallsign >= Config.Callsign.Min and newCallsign <= Config.Callsign.Max then
        newCallsign = math.floor(newCallsign)
        TriggerServerEvent('daddy:gps:updateCallsign', newCallsign)
        GPS_Client.CachedCallsign = newCallsign
        if GPS_Client.CachedProfile then
            GPS_Client.CachedProfile.callsign = newCallsign
        end
        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
            LocalPlayer.state:set('callsign', newCallsign, true)
        end
    end
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data.x and data.y then
        SetNewWaypoint(data.x, data.y)
        Notify(L('notify.waypoint_set', 'Waypoint set.'), 'success')
    end
    cb('ok')
end)

RegisterNUICallback('followUnit', function(data, cb)
    local targetNetId = data.netId
    if not targetNetId then
        TriggerEvent('daddy:gps:setFollowTarget', nil)
        Notify(L('notify.follow_cancelled', 'Follow cancelled.'), 'info')
    else
        TriggerEvent('daddy:gps:setFollowTarget', targetNetId)
    end
    cb('ok')
end)

-- NUI callback: Update officer name
RegisterNUICallback('updateOfficerName', function(data, cb)
    local newName = tostring(data.name or '')
    if newName ~= '' then
        TriggerServerEvent('daddy:gps:updateOfficerName', newName)
        if GPS_Client.CachedProfile then
            GPS_Client.CachedProfile.officerName = newName
        end
        SendNUIMessage({ action = 'profileUpdated', officerName = newName })
    end
    cb('ok')
end)

-- NUI callback: Update both officer name and callsign together (ProfileTab)
RegisterNUICallback('updateProfile', function(data, cb)
    local newName = tostring(data.officerName or '')
    local newCallsign = tonumber(data.callsign)

    if newName ~= '' then
        TriggerServerEvent('daddy:gps:updateOfficerName', newName)
        if GPS_Client.CachedProfile then
            GPS_Client.CachedProfile.officerName = newName
        end
    end

    if newCallsign and newCallsign >= Config.Callsign.Min and newCallsign <= Config.Callsign.Max then
        newCallsign = math.floor(newCallsign)
        TriggerServerEvent('daddy:gps:updateCallsign', newCallsign)
        GPS_Client.CachedCallsign = newCallsign
        if GPS_Client.CachedProfile then
            GPS_Client.CachedProfile.callsign = newCallsign
        end
        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
            LocalPlayer.state:set('callsign', newCallsign, true)
        end
    end

    -- Update NUI (header and all components stay in sync)
    SendNUIMessage({
        action   = 'profileUpdated',
        officerName = newName ~= '' and newName or nil,
        callsign = newCallsign,
    })
    cb('ok')
end)

-- NUI callback: Toggle self-blip visibility
RegisterNUICallback('toggleSelfBlip', function(data, cb)
    local state = data.state
    TriggerEvent('daddy:gps:updateSelfBlip', state)
    SaveSelfBlipKVP(state)
    cb('ok')
end)

-- NUI callback: Change blip-category mode (legend grouping preference)
RegisterNUICallback('updateBlipCategoryMode', function(data, cb)
    local mode = tostring(data and data.mode or '')
    if IsValidBlipCategoryMode(mode) then
        BlipCategoryMode = mode
        SaveBlipCategoryModeKVP(mode)
        TriggerEvent('daddy:gps:blipCategoryChanged')
    end
    cb('ok')
end)

-- NUI callback: Update blip sizes from UI
RegisterNUICallback('updateBlipSizes', function(data, cb)
    local VALID_KEYS = { Vehicle=true, OnFoot=true, Bike=true, Helicopter=true, Plane=true, Boat=true }
    if data and type(data) == 'table' then
        for key, val in pairs(data) do
            if VALID_KEYS[key] then
                local num = tonumber(val)
                if num and num >= 0.4 and num <= 1.5 then
                    Config.BlipSizes[key] = num
                end
            end
        end
        ForceImmediateReskin = true
        SaveBlipSizesKVP()
    end
    cb('ok')
end)

-- NUI callback: Join channel — updates blip filter
RegisterNUICallback('joinChannel', function(data, cb)
    local key = tostring(data and data.channel or 'Global')
    -- Validate: must be 'Global' or a known department key
    if key ~= 'Global' and not Config.Departments[key] then
        key = 'Global'
    end
    CurrentChannel = key
    -- Clear existing blips so the next refresh re-renders with the new filter
    ClearAllGpsBlips()
    ForceImmediateReskin = true
    cb('ok')
end)

-- NUI callback: Change language
RegisterNUICallback('changeLanguage', function(data, cb)
    local lang = tostring(data.locale or 'en')
    -- Validate: only allow known locale codes
    local VALID_LOCALES = { en=true, tr=true, de=true, fr=true, es=true, it=true, nl=true, pt=true }
    if not VALID_LOCALES[lang] then
        cb('ok')
        return
    end
    
    -- Update config locale
    Config.Locale = lang
    
    -- Reset cached locale data so it reloads
    ResetLocaleCache()
    
    -- Reload and send new locales to NUI
    local newLocales = LoadLocales()
    SendNUIMessage({ action = 'updateLocales', locales = newLocales, locale = lang })
    
    Notify(L('settings.language_changed', 'Language changed.'), 'success')
    cb('ok')
end)

-- ============================================================================
-- Water Damage: Force Close UI
-- ============================================================================

AddEventHandler('daddy:gps:forceCloseUI', function()
    showing = false
    SendNUIMessage({ action = 'forceDisconnect' })
    SetNuiFocus(false, false)
end)

-- ============================================================================
-- Auto-Reconnect After Repair
-- ============================================================================

AddEventHandler('daddy:gps:attemptReconnect', function()
    if GPS_Client.IsOpen then return end
    
    Framework.TriggerCallback('daddy:gps:getProfile', function(profile)
        if profile and profile.department and profile.officerName and profile.officerName ~= '' then
            local deptKey = NormalizeDeptKey(profile.department)
            if not deptKey or not Config.Departments[deptKey] then return end
            
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local callsign = tostring(profile.callsign or '')
            
            TriggerServerEvent('daddy:gps:joinUi', {
                department = deptKey,
                officerName = profile.officerName,
                callsign = callsign,
                channel = 'Global',
                x = coords.x,
                y = coords.y,
                z = coords.z
            })
            
            GPS_Client.CachedCallsign = callsign
            GPS_Client.IsOpen = true
            
            if LocalPlayer and LocalPlayer.state and LocalPlayer.state.set then
                LocalPlayer.state:set('callsign', callsign, true)
            end
            
            TriggerEvent('daddy:gps:connected')
            Notify(L('notify.gps_reconnected', 'GPS reconnected after repair.'), 'success')
        end
    end)
end)
