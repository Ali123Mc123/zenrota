-- ============================================================================
-- Daddy GPS - Blip Rendering System
-- ============================================================================
-- Single coord-blip per remote player. When the player is in streaming range
-- the blip position is updated from their entity coords (real-time smooth).
-- When out of range, LERP interpolation is used toward the last server target.
-- No dual ped/coord mode switching, no alpha/display juggling.
-- ============================================================================

-- ============================================================================
-- Heading Conversion Helper
-- ============================================================================
-- FiveM game heading: 0° = North, increases COUNTER-CLOCKWISE (0-360)
-- SetBlipRotation:     0° = North, increases CLOCKWISE (0-360)
-- Correction: blipRot = (360 - heading) % 360

local function HeadingToBlipRotation(heading)
    -- FiveM SetBlipRotation already uses the same system as the game,
    -- no extra conversion needed, pass heading directly
    return math.ceil((heading or 0) % 360)
end

-- The pause menu lists player blips under Players (daddy_pausemenu SetBlipMeta); the overlay stays out of its list.
local function pauseMeta(b, meta)
    if GetResourceState('daddy_pausemenu') ~= 'started' then return end
    pcall(function() exports.daddy_pausemenu:SetBlipMeta(b, meta) end)
end

-- Grouped by department (the 'department' / 'none' legend modes), the pause menu lists units under their department too.
local function playerMeta(d)
    local dept = (BlipCategoryMode == 'department' or BlipCategoryMode == 'none') and Config.Departments[d.lastJob or '']
    return { category = 'players', group = dept and (dept.text or dept.label) or nil }
end

-- ============================================================================
-- Blip Creation Helpers
-- ============================================================================

local function createBlipForPlayer(d)
    -- Defensive cleanup: never leak a previous blip handle when (re)creating.
    if d.blip and DoesBlipExist(d.blip) then RemoveBlip(d.blip) end

    local x = (d.target and d.target.x) or 0
    local y = (d.target and d.target.y) or 0
    local z = (d.target and d.target.z) or 0

    local b = AddBlipForCoord(x, y, z)

    -- IMPORTANT: Assign the handle *before* any Wait(0) below.
    -- A yield with a stale/nil d.blip + d.isEntityBlip combination allowed a
    -- concurrent refresh tick to mis-detect the blip state and create a
    -- second blip without removing the old one, leaving the player with two
    -- desynchronised blips on the map.
    d.blip = b
    d.isEntityBlip = false
    pauseMeta(b, playerMeta(d))

    local blipSize = GetBlipSizeForState(d.lastVehKind or 'car', d.lastSprite)
    SetBlipScale(b, blipSize)
    SetBlipAsShortRange(b, true)
    SetBlipCategory(b, ResolveBlipCategory(d.lastJob))

    local sprite = d.lastSprite or 1
    SetBlipSprite(b, sprite)

    -- Heading indicator should only be visible on the on-foot sprite (1).
    -- SetBlipRotation rotates vehicle sprites independently of the indicator.
    ShowHeadingIndicatorOnBlip(b, sprite == 1)

    -- Apply initial rotation immediately (on-foot sprite only)
    if d.lastHeading and sprite == 1 then
        SetBlipRotation(b, HeadingToBlipRotation(d.lastHeading))
    end

    if not NON_TINTABLE[sprite] and d.lastColour then
        SetBlipColour(b, d.lastColour)
    end

    if d.lastLabel then
        -- Yield before issuing text commands; without this, batched blip name
        -- registrations on the same frame can drop labels (citizenfx/fivem#3334).
        Wait(0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(d.lastLabel)
        EndTextCommandSetBlipName(b)
    end

    return b
end

local function createEntityBlipForPlayer(d, ped)
    -- Defensive cleanup: never leak a previous blip handle when (re)creating.
    if d.blip and DoesBlipExist(d.blip) then RemoveBlip(d.blip) end

    local b = AddBlipForEntity(ped)

    -- Assign handle/state BEFORE the Wait(0) below (race-safety; see
    -- createBlipForPlayer for the full rationale).
    d.blip = b
    d.isEntityBlip = true
    pauseMeta(b, playerMeta(d))

    local blipSize = GetBlipSizeForState(d.lastVehKind or 'car', d.lastSprite)
    SetBlipScale(b, blipSize)
    SetBlipAsShortRange(b, true)
    SetBlipCategory(b, ResolveBlipCategory(d.lastJob))

    local sprite = d.lastSprite or 1
    SetBlipSprite(b, sprite)
    ShowHeadingIndicatorOnBlip(b, sprite == 1)

    if not NON_TINTABLE[sprite] and d.lastColour then
        SetBlipColour(b, d.lastColour)
    end

    if d.lastLabel then
        Wait(0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(d.lastLabel)
        EndTextCommandSetBlipName(b)
    end

    return b
end

local function createOverlayForPlayer(d, x, y, z)
    local ov = AddBlipForCoord(x, y, z)
    pauseMeta(ov, { hidden = true })
    SetBlipSprite(ov, 1)
    SetBlipScale(ov, Config.BlipSizes.Overlay or 0.70)
    SetBlipAsShortRange(ov, true)
    SetBlipCategory(ov, ResolveBlipCategory(d.lastJob))
    if SetBlipHiddenOnLegend then SetBlipHiddenOnLegend(ov, true) end
    -- Overlay heading indicator enabled: direction indicator for NON_TINTABLE vehicle sprites
    ShowHeadingIndicatorOnBlip(ov, true)

    -- Apply initial rotation immediately
    if d.lastHeading then
        SetBlipRotation(ov, HeadingToBlipRotation(d.lastHeading))
    end

    if d.lastColour then SetBlipColour(ov, d.lastColour) end
    d.overlay = ov
    return ov
end

-- ============================================================================
-- Visual Update (called from event handler when sprite/colour/label changes)
-- ============================================================================

function ApplyVisualsToBlip(d, sprite, colour, label, vKind)
    d.lastSprite  = sprite
    d.lastColour  = colour
    d.lastLabel   = label
    d.lastVehKind = vKind

    local blipSize = GetBlipSizeForState(vKind or 'car', sprite)

    if d.blip and DoesBlipExist(d.blip) then
        SetBlipSprite(d.blip, sprite)
        SetBlipScale(d.blip, blipSize)
        if not NON_TINTABLE[sprite] then SetBlipColour(d.blip, colour) end

        -- Re-apply category in case BlipCategoryMode changed since creation.
        SetBlipCategory(d.blip, ResolveBlipCategory(d.lastJob))
        pauseMeta(d.blip, playerMeta(d))

        -- Heading indicator only on the on-foot sprite (1).
        -- In entity blip mode the engine handles it; in coord blip mode we set it manually.
        ShowHeadingIndicatorOnBlip(d.blip, sprite == 1)

        -- Apply current heading immediately (coord blip only, on-foot sprite only)
        if not d.isEntityBlip and sprite == 1 then
            SetBlipRotation(d.blip, HeadingToBlipRotation(d.lastHeading or 0))
        end

        -- Yield before name registration to avoid name-drop on bulk updates
        -- (citizenfx/fivem#3334).
        Wait(0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(d.blip)
    end

    -- Overlay for non-tintable sprites (skip NoOverlay sprites like chase)
    local NO_OVERLAY = Config.NoOverlaySprites or {}
    if NON_TINTABLE[sprite] and not NO_OVERLAY[sprite] then
        if not d.overlay or not DoesBlipExist(d.overlay) then
            local t = d.cur or d.target or { x = 0, y = 0, z = 0 }
            createOverlayForPlayer(d, t.x, t.y, t.z)
        end
        if d.overlay and DoesBlipExist(d.overlay) then
            SetBlipColour(d.overlay, colour)
        end
    else
        if d.overlay and DoesBlipExist(d.overlay) then
            RemoveBlip(d.overlay)
            d.overlay = nil
        end
    end
end

-- ============================================================================
-- Main Render Loop
-- ============================================================================

CreateThread(function()
    while true do
        local anyMovement = false

        for sid, d in pairs(Blips) do
            -- Skip entries with no valid target yet
            if not d.target or (math.abs(d.target.x) < 1.0 and math.abs(d.target.y) < 1.0) then
                if d.blip and DoesBlipExist(d.blip) then SetBlipAlpha(d.blip, 0) end
                if d.overlay and DoesBlipExist(d.overlay) then SetBlipAlpha(d.overlay, 0) end
                goto continue_render
            end

            -- Determine desired blip type ONCE per tick so we never end up
            -- creating a coord blip and immediately swapping it out for an
            -- entity blip (which previously caused duplicate-blip races).
            local pid        = GetPlayerFromServerId(sid)
            local isStreamed = pid and pid ~= -1 and NetworkIsPlayerActive(pid)
            local ped        = (isStreamed and pid) and GetPlayerPed(pid) or 0
            local wantsEntityBlip = isStreamed and ped and ped ~= 0

            -- Ensure the main blip exists with the CORRECT type. The create
            -- helpers defensively remove any pre-existing handle on d.blip
            -- before allocating a new one, so there is no window for two
            -- blips to coexist for the same player.
            if wantsEntityBlip then
                if (not d.blip) or (not DoesBlipExist(d.blip)) or (not d.isEntityBlip) then
                    createEntityBlipForPlayer(d, ped)
                end
            else
                if (not d.blip) or (not DoesBlipExist(d.blip)) or d.isEntityBlip then
                    createBlipForPlayer(d)
                end
            end

            -- Make sure blip is visible
            if d.blip and DoesBlipExist(d.blip) then
                SetBlipAlpha(d.blip, 255)
            end

            if wantsEntityBlip then
                -- NEARBY: Entity blip (position is automatically tracked by the engine)
                do
                    local px, py, pz = table.unpack(GetEntityCoords(ped))

                    -- Use vehicle heading if in vehicle, otherwise ped heading (maintains continuity during FAR transition)
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle and vehicle ~= 0 then
                        d.lastHeading = GetEntityHeading(vehicle)
                    else
                        d.lastHeading = GetEntityHeading(ped)
                    end

                    -- Overlay is coord-based so it requires manual position updates
                    if d.overlay and DoesBlipExist(d.overlay) then
                        SetBlipCoords(d.overlay, px, py, pz)
                        SetBlipAlpha(d.overlay, 255)
                    end

                    -- Keep cur in sync for smooth transition when going out of range
                    d.cur = d.cur or {}
                    d.cur.x, d.cur.y, d.cur.z = px, py, pz

                    anyMovement = true
                end
            else
                -- FAR: LERP interpolation toward server target.
                -- The entity→coord transition (when leaving streaming range)
                -- is handled above by the "ensure correct blip type" block,
                -- which removes the entity blip and creates a fresh coord
                -- blip in a single, race-safe step.
                if d.cur and d.target then
                    local cx, cy, cz = d.cur.x, d.cur.y, d.cur.z
                    local tx, ty, tz = d.target.x, d.target.y, d.target.z
                    local dist = Distance2D(cx, cy, tx, ty)

                    if dist > EPS then
                        local nx = Lerp(cx, tx, LERP_ALPHA)
                        local ny = Lerp(cy, ty, LERP_ALPHA)
                        local nz = Lerp(cz, tz, LERP_ALPHA)
                        d.cur.x, d.cur.y, d.cur.z = nx, ny, nz

                        if d.blip and DoesBlipExist(d.blip) then
                            SetBlipCoords(d.blip, nx, ny, nz)
                        end
                        if d.overlay and DoesBlipExist(d.overlay) then
                            SetBlipCoords(d.overlay, nx, ny, nz)
                            SetBlipAlpha(d.overlay, 255)
                        end
                        anyMovement    = true
                        d.isStationary = false
                    else
                        -- Arrived at target
                        d.cur.x, d.cur.y, d.cur.z = tx, ty, tz
                        if d.blip and DoesBlipExist(d.blip) then
                            SetBlipCoords(d.blip, tx, ty, tz)
                        end
                        if d.overlay and DoesBlipExist(d.overlay) then
                            SetBlipCoords(d.overlay, tx, ty, tz)
                        end
                        d.isStationary = true
                    end
                end
            end

            -- ----------------------------------------------------------------
            -- Heading Rotation — coord blips only, on-foot sprite (1) only
            -- Vehicle sprites do not rotate, and no arrow is shown.
            -- ----------------------------------------------------------------
            if d.lastHeading and not d.isEntityBlip and (d.lastSprite or 1) == 1 then
                local rot = HeadingToBlipRotation(d.lastHeading)
                if d.blip and DoesBlipExist(d.blip) then
                    SetBlipRotation(d.blip, rot)
                end
                if d.overlay and DoesBlipExist(d.overlay) then
                    SetBlipRotation(d.overlay, rot)
                end
            end

            ::continue_render::
        end

        Wait(anyMovement and TICK_MS or (TICK_MS * 4))
    end
end)