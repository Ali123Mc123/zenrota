local utils = {}

local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord
local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial

---@param flag number
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function utils.raycastFromCamera(flag)
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 10
    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
        flag, cache.ped, 4)

    while true do
        Wait(0)
        local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(
        handle)

        if retval ~= 1 then
            ---@diagnostic disable-next-line: return-type-mismatch
            return hit, entityHit, endCoords, surfaceNormal, materialHash
        end
    end
end

function utils.getTexture()
    return lib.requestStreamedTextureDict('shared'), 'emptydot_32'
end

-- SetDrawOrigin is limited to 32 calls per frame. Set as 0 to disable.
local drawZoneSprites = GetConvarInt('ox_target:drawSprite', 24)
local SetDrawOrigin = SetDrawOrigin
local DrawSprite = DrawSprite
local ClearDrawOrigin = ClearDrawOrigin
local colour = vector(155, 155, 155, 175)
local hover = vector(98, 135, 236, 255)
local currentZones = {}
local previousZones = {}
local drawZones = {}
local drawN = 0
-- How far (metres) the look ray may pass beside a zone and still target it;
-- zones the ray actually ends in always win over these near misses.
local assistTolerance = 0.35
local assistPenalty = 10.0
local width = 0.02
local height = width * GetAspectRatio(false)

if drawZoneSprites == 0 then drawZoneSprites = -1 end

---@param coords vector3
---@return CZone[], boolean
function utils.getNearbyZones(coords)
    if not Zones then return currentZones, false end

    local n = 0
    local nearbyZones = lib.zones.getNearbyZones()
    drawN = 0
    previousZones, currentZones = currentZones, table.wipe(previousZones)

    -- Only the zone closest to where the player looks is the target, so two zones next to each other
    -- stay two separate prompts instead of one merged list. A small zone also counts when the look
    -- ray passes close to its centre, not only when the ray ends exactly inside it.
    local best, bestScore
    local cam = GetFinalRenderedCamCoord()
    local ray = coords - cam
    local rayLength = #ray
    local dir = rayLength > 0 and ray / rayLength or ray

    for i = 1, #nearbyZones do
        local zone = nearbyZones[i]
        local contains = zone:contains(coords)

        if zone.options and zone.coords then
            local score

            if contains then
                score = #(coords - zone.coords)
            else
                local toZone = zone.coords - cam
                local along = toZone.x * dir.x + toZone.y * dir.y + toZone.z * dir.z

                -- in front of the camera and not behind what the ray hit
                if along > 0 and along <= rayLength + 0.5 then
                    local miss = #(toZone - dir * along)

                    if miss <= (zone.radius or 0.5) + assistTolerance then
                        score = miss + assistPenalty
                    end
                end
            end

            if score and (not bestScore or score < bestScore) then
                best, bestScore = zone, score
            end
        end

        if drawN <= drawZoneSprites and zone.drawSprite ~= false and (contains or (zone.distance or 7) < 7) then
            drawN += 1
            drawZones[drawN] = zone
            zone.colour = contains and hover or nil
        end
    end

    if best then
        n = 1
        currentZones[1] = best
        -- Zones at the very same spot (a shared and a personal stash) are one target: both lists show.
        for i = 1, #nearbyZones do
            local zone = nearbyZones[i]
            if zone ~= best and zone.options and zone.coords and #(zone.coords - best.coords) < 0.3 then
                n += 1
                currentZones[n] = zone
            end
        end
    end

    local previousN = #previousZones

    if n ~= previousN then
        return currentZones, true
    end

    if n > 0 then
        for i = 1, n do
            local zoneA = currentZones[i]
            local found = false

            for j = 1, previousN do
                local zoneB = previousZones[j]

                if zoneA == zoneB then
                    found = true
                    break
                end
            end

            if not found then
                return currentZones, true
            end
        end
    end

    return currentZones, false
end

function utils.drawZoneSprites(dict, texture)
    if drawN == 0 then return end

    for i = 1, drawN do
        local zone = drawZones[i]
        local spriteColour = zone.colour or colour

        if zone.drawSprite ~= false then
            SetDrawOrigin(zone.coords.x, zone.coords.y, zone.coords.z)
            DrawSprite(dict, texture, 0, 0, width, height, 0, spriteColour.r, spriteColour.g, spriteColour.b,
                spriteColour.a)
        end
    end

    ClearDrawOrigin()
end

function utils.hasExport(export)
    local resource, exportName = string.strsplit('.', export)

    return pcall(function()
        return exports[resource][exportName]
    end)
end

local playerItems = {}

function utils.getItems()
    return playerItems
end

---@param filter string | string[] | table<string, number>
---@param hasAny boolean?
---@return boolean
function utils.hasPlayerGotItems(filter, hasAny)
    if not playerItems then return true end

    local _type = type(filter)

    if _type == 'string' then
        return (playerItems[filter] or 0) > 0
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, amount in pairs(filter) do
                local hasItem = (playerItems[name] or 0) >= amount

                if hasAny then
                    if hasItem then return true end
                elseif not hasItem then
                    return false
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local hasItem = (playerItems[filter[i]] or 0) > 0

                if hasAny then
                    if hasItem then return true end
                elseif not hasItem then
                    return false
                end
            end
        end
    end

    return not hasAny
end

---stub
---@param filter string | string[] | table<string, number>
---@return boolean
function utils.hasPlayerGotGroup(filter)
    return true
end

SetTimeout(0, function()
    if utils.hasExport('ox_inventory.Items') then
        setmetatable(playerItems, {
            __index = function(self, index)
                self[index] = exports.ox_inventory:Search('count', index) or 0
                return self[index]
            end
        })

        AddEventHandler('ox_inventory:itemCount', function(name, count)
            playerItems[name] = count
        end)
    end

    if utils.hasExport('ox_core.GetPlayer') then
        require 'client.framework.ox'
    elseif utils.hasExport('es_extended.getSharedObject') then
        require 'client.framework.esx'
    elseif utils.hasExport('qbx_core.HasGroup') then
        require 'client.framework.qbx'
    elseif utils.hasExport('ND_Core.getPlayer') then
        require 'client.framework.nd'
    end
end)

function utils.warn(msg)
    local trace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())
    local _, _, src = string.strsplit('\n', trace, 4)

    warn(('%s ^0%s\n'):format(msg, src:gsub(".-%(", '(')))
end

return utils
