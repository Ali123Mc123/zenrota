-- =============================================================================
-- OPEN SOURCE: Zone / Targeting Abstraction  (client-side)
-- =============================================================================
-- Set Config.TargetSystem in config/config.lua to control which system is used.
--
--   'ox_target'   → ox_target:addSphereZone        (requires ox_target)
--   'qtarget'     → qtarget:AddCircleZone           (requires qtarget)
--   'drawtext'    → proximity thread + draw-text hint  (no extra dependency)
--                   controlled by Config.DrawTextSystem:
--                     'ox_lib'   → lib.showTextUI / lib.hideTextUI
--                     'qb-core'  → exports['qb-core']:DrawText / HideText
--                     'custom'   → _G.OxlynShowText(label) / _G.OxlynHideText()
-- =============================================================================

OxlynZones = {}

local activeProximityThreads = {}

-- ── DrawText helpers ─────────────────────────────────────────────────────────

local function ShowDrawtext(label)
    local system = Config.DrawTextSystem or 'ox_lib'
    local opts   = Config.DrawTextOptions or {}

    if system == 'ox_lib' then
        local uiOpts = { position = opts.position or 'right-center' }
        if opts.icon          then uiOpts.icon          = opts.icon          end
        if opts.iconColor     then uiOpts.iconColor     = opts.iconColor     end
        if opts.iconAnimation then uiOpts.iconAnimation = opts.iconAnimation end
        if opts.style         then uiOpts.style         = opts.style         end
        lib.showTextUI(label, uiOpts)

    elseif system == 'qb-core' then
        exports['qb-core']:DrawText(label, opts.position or 'left')

    elseif system == 'custom' then
        if _G.OxlynShowText then
            _G.OxlynShowText(label)
        else
            print('[Oxlyn Backpack] DrawTextSystem = custom but _G.OxlynShowText is not defined.')
        end
    end
end

local function HideDrawtext()
    local system = Config.DrawTextSystem or 'ox_lib'
    if system == 'ox_lib'  then lib.hideTextUI() end
    if system == 'qb-core' then exports['qb-core']:HideText() end
    if system == 'custom' and _G.OxlynHideText then _G.OxlynHideText() end
end

-- ── Proximity thread (drawtext mode) ────────────────────────────────────────

-- coordsFn: function() → vector3  (allows dynamic coords from a live entity)
local function StartProximityThread(name, coordsFn, radius, options)
    if activeProximityThreads[name] then return end
    activeProximityThreads[name] = true

    local label = '[E] ' .. (options[1] and options[1].label or 'Etkileşim')
    DebugPrint(('[Oxlyn Backpack] drawtext zone started: %s  radius: %s  label: %s'):format(name, radius, label))

    CreateThread(function()
        local inside = false
        while activeProximityThreads[name] do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local targetCoords = coordsFn()
            local dist = #(playerCoords - targetCoords)

            if dist <= radius then
                if not inside then
                    inside = true
                    DebugPrint(('[Oxlyn Backpack] drawtext zone ENTER: %s  dist: %.2f'):format(name, dist))
                    ShowDrawtext(label)
                end
                if IsControlJustReleased(0, 38) then  -- E key
                    DebugPrint('[Oxlyn Backpack] E key pressed!')
                    HideDrawtext()
                    inside = false
                    if options[1] and options[1].onSelect then
                        DebugPrint('[Oxlyn Backpack] Calling onSelect handler...')
                        options[1].onSelect()
                    else
                        print('[Oxlyn Backpack] No onSelect handler found for this zone!')
                    end
                end
                Wait(0)
            else
                if inside then
                    inside = false
                    HideDrawtext()
                end
                Wait(500)
            end
        end
        if inside then HideDrawtext() end
    end)
end

local function StartProximityZone(name, coords, radius, options)
    StartProximityThread(name, function() return coords end, radius, options)
end

-- ── Public API ───────────────────────────────────────────────────────────────

--- Create a sphere interaction zone.
-- @param name    string   Unique identifier (used for removal)
-- @param coords  vector3  World position
-- @param radius  number   Sphere radius in metres
-- @param debug   boolean  Show debug visuals (ox_target only)
-- @param options table    Array of { name, icon, label, onSelect }
function OxlynZones.AddSphere(name, coords, radius, debug, options)
    local system = Config.TargetSystem or 'ox_target'

    if system == 'ox_target' then
        exports.ox_target:addSphereZone({
            coords  = coords,
            radius  = radius,
            debug   = debug,
            options = options,
        })

    elseif system == 'qtarget' or system == 'qb-target' then
        local targetExport = system == 'qb-target' and exports['qb-target'] or exports.qtarget
        local qtOptions = {}
        for _, opt in ipairs(options) do
            local evName = 'oxlyn_backpack:zone_' .. opt.name
            table.insert(qtOptions, { type = 'client', event = evName, icon = opt.icon, label = opt.label })
            RegisterNetEvent(evName, opt.onSelect)
            AddEventHandler(evName, opt.onSelect)
        end
        targetExport:AddCircleZone(name, coords, radius,
            { name = name, debugPoly = debug },
            { options = qtOptions, distance = radius }
        )

    elseif system == 'drawtext' then
        StartProximityZone(name, coords, radius, options)

    else
        print('[Oxlyn Backpack] Unknown TargetSystem: ' .. tostring(system))
    end
end

--- Create an interaction zone attached to a local entity (ped/vehicle/object).
-- When enablePed is true, call this instead of AddSphere so targeting attaches to the ped.
-- @param name    string   Unique identifier
-- @param entity  number   Entity handle
-- @param radius  number   Interaction radius (drawtext mode only)
-- @param debug   boolean  Show debug visuals (ox_target only)
-- @param options table    Array of { name, icon, label, onSelect }
function OxlynZones.AddEntity(name, entity, radius, debug, options)
    local system = Config.TargetSystem or 'ox_target'

    if system == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, options)

    elseif system == 'qtarget' or system == 'qb-target' then
        local targetExport = system == 'qb-target' and exports['qb-target'] or exports.qtarget
        local qtOptions = {}
        for _, opt in ipairs(options) do
            local evName = 'oxlyn_backpack:zone_' .. opt.name
            table.insert(qtOptions, { type = 'client', event = evName, icon = opt.icon, label = opt.label })
            RegisterNetEvent(evName, opt.onSelect)
            AddEventHandler(evName, opt.onSelect)
        end
        targetExport:AddTargetEntity(entity,
            { options = qtOptions, distance = radius or 2.0 }
        )

    elseif system == 'drawtext' then
        StartProximityThread(name, function()
            return DoesEntityExist(entity) and GetEntityCoords(entity) or vector3(0, 0, 0)
        end, radius or 2.0, options)

    else
        print('[Oxlyn Backpack] Unknown TargetSystem: ' .. tostring(system))
    end
end

--- Create a target option on ALL player peds (global player target).
-- Used by the optional police backpack search. Each option carries its own
-- canInteract/onSelect; onSelect receives a table with `.entity` (the player ped).
-- drawtext mode is NOT supported for player targeting.
-- @param name     string  Unique identifier
-- @param options  table   Array of { name, icon, label, distance, canInteract, onSelect }
-- @param distance number  Max interaction distance (qb-target / qtarget)
function OxlynZones.AddGlobalPlayer(name, options, distance)
    local system = Config.TargetSystem or 'ox_target'

    if system == 'ox_target' then
        -- ox_target options carry their own canInteract / onSelect / distance.
        exports.ox_target:addGlobalPlayer(options)

    elseif system == 'qtarget' or system == 'qb-target' then
        local targetExport = system == 'qb-target' and exports['qb-target'] or exports.qtarget
        local qtOptions = {}
        for _, opt in ipairs(options) do
            local evName = 'oxlyn_backpack:zone_' .. opt.name
            RegisterNetEvent(evName)
            AddEventHandler(evName, function(entity)
                if opt.onSelect then opt.onSelect({ entity = entity }) end
            end)
            table.insert(qtOptions, {
                type        = 'client',
                event       = evName,
                icon        = opt.icon,
                label       = opt.label,
                canInteract = opt.canInteract,
            })
        end
        targetExport:AddGlobalPlayer({ options = qtOptions, distance = distance or 2.5 })

    else
        -- drawtext / unknown → player targeting unsupported; the command still works.
        print(('[Oxlyn Backpack] PoliceSearchUseTarget: TargetSystem "%s" does not support '
            .. 'player targeting. Officers can still use the /%s command.')
            :format(tostring(system), tostring(Config.PoliceSearchCommand or 'searchbackpack')))
    end
end

--- Remove a previously created zone.
-- @param name string
function OxlynZones.Remove(name)
    local system = Config.TargetSystem or 'ox_target'
    if system == 'ox_target'  then exports.ox_target:removeZone(name) end
    if system == 'qtarget'    then exports.qtarget:RemoveZone(name) end
    if system == 'qb-target'  then exports['qb-target']:RemoveZone(name) end
    if system == 'drawtext'   then activeProximityThreads[name] = nil end
end
