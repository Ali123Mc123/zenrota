if not lib.checkDependency('ox_lib', '3.30.0', true) then return end

lib.locale()

local utils = require 'client.utils'
local state = require 'client.state'
local api = require 'client.api'
local options = api.getTargetOptions()

require 'client.debug'
require 'client.defaults'
require 'client.compat.qtarget'

local SendNuiMessage = SendNuiMessage
local GetEntityCoords = GetEntityCoords
local GetEntityType = GetEntityType
local HasEntityClearLosToEntity = HasEntityClearLosToEntity
local GetEntityBoneIndexByName = GetEntityBoneIndexByName
local GetEntityBonePosition_2 = GetEntityBonePosition_2
local GetEntityModel = GetEntityModel
local IsDisabledControlJustPressed = IsDisabledControlJustPressed
local DisableControlAction = DisableControlAction
local GetModelDimensions = GetModelDimensions
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local GetOffsetFromEntityGivenWorldCoords = GetOffsetFromEntityGivenWorldCoords
local GetScreenCoordFromWorldCoord = GetScreenCoordFromWorldCoord
local GetPedBoneCoords = GetPedBoneCoords
local DoesEntityExist = DoesEntityExist
local currentTarget = {}
local currentMenu
local menuChanged
local menuHistory = {}
local nearbyZones

local debug = GetConvarInt('ox_target:debug', 0) == 1
-- Options further away than this never prompt, whatever their own distance says.
local maxDistance = tonumber(GetConvar('ox_target:maxDistance', '3.0')) or 3.0
-- Nearby targets within this distance get a small dot.
local dotDistance = tonumber(GetConvar('ox_target:dotDistance', '6.0')) or 6.0
local maxDots = GetConvarInt('ox_target:maxDots', 16)
-- E is the horn in a vehicle, so prompts are off while driving unless enabled.
local allowInVehicle = GetConvarInt('ox_target:inVehicle', 0) == 1
local vec0 = vec3(0, 0, 0)
local chestBone = 24818

local interactCacheMs = 250
local interactCache = setmetatable({}, { __mode = 'k' })
local groupCache = setmetatable({}, { __mode = 'k' })

---Group checks call into the framework every time; cache them for a few seconds.
local function hasGroup(filter)
    local now = GetGameTimer()
    local cached = groupCache[filter]

    if cached and now < cached.expires then return cached.ok end

    local ok = utils.hasPlayerGotGroup(filter)
    groupCache[filter] = { ok = ok, expires = now + 3000 }

    return ok
end

-- Prompt state
local promptVisible = false
local visibleCount = 0
local anchorEntity, anchorOffset, anchorCoords, anchorZone
local cooldown = 0
local dots = {}

---@param option OxTargetOption
---@param distance number
---@param endCoords vector3
---@param entityHit? number
---@param entityType? number
---@param entityModel? number | false
local function shouldHide(option, distance, endCoords, entityHit, entityType, entityModel)
    if option.menuName ~= currentMenu then
        return true
    end

    -- A shown option gets a little slack so standing right at the limit does not flicker it.
    if distance > math.min(option.distance or 7, maxDistance) + (option.hide == false and 0.3 or 0) then
        return true
    end

    if option.groups and not hasGroup(option.groups) then
        return true
    end

    if option.items and not utils.hasPlayerGotItems(option.items, option.anyItem) then
        return true
    end

    if entityHit and api.isResourceIgnoredOn(entityHit, option.resource) then
        return true
    end

    local bone = entityModel and option.bones or nil

    if bone then
        ---@cast entityHit number
        ---@cast entityType number
        ---@cast entityModel number

        local _type = type(bone)

        if _type == 'string' then
            local boneId = GetEntityBoneIndexByName(entityHit, bone)

            if boneId ~= -1 and #(endCoords - GetEntityBonePosition_2(entityHit, boneId)) <= 2 then
                bone = boneId
            else
                return true
            end
        elseif _type == 'table' then
            local closestBone, boneDistance

            for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entityHit, bone[j])

                if boneId ~= -1 then
                    local dist = #(endCoords - GetEntityBonePosition_2(entityHit, boneId))

                    if dist <= (boneDistance or 1) then
                        closestBone = boneId
                        boneDistance = dist
                    end
                end
            end

            if closestBone then
                bone = closestBone
            else
                return true
            end
        end
    end

    local offset = entityModel and option.offset or nil

    if offset then
        ---@cast entityHit number
        ---@cast entityType number
        ---@cast entityModel number

        if not option.absoluteOffset then
            local min, max = GetModelDimensions(entityModel)
            offset = (max - min) * offset + min
        end

        offset = GetOffsetFromEntityInWorldCoords(entityHit, offset.x, offset.y, offset.z)

        if #(endCoords - offset) > (option.offsetSize or 1) then
            return true
        end
    end

    if option.canInteract then
        -- canInteract is usually another resource's function (a costly cross-resource call),
        -- so its answer is reused for a short while as long as the target stays the same.
        local now = GetGameTimer()
        local cached = interactCache[option]

        if cached and cached.entity == entityHit and now < cached.expires then
            return cached.hide
        end

        local success, resp = pcall(option.canInteract, entityHit, distance, endCoords, option.name, bone)
        local hide = not success or not resp

        if cached then
            cached.entity, cached.expires, cached.hide = entityHit, now + interactCacheMs, hide
        else
            interactCache[option] = { entity = entityHit, expires = now + interactCacheMs, hide = hide }
        end

        return hide
    end
end

---Lighter check for dots: no distance, bone or offset rules, only home-menu options.
---@param list? OxTargetOption[]
---@return boolean
local function hasDotOption(list, entity, distance, coords)
    if not list then return false end

    for i = 1, #list do
        local option = list[i]

        if not option.menuName
            and (not option.groups or hasGroup(option.groups))
            and (not option.items or utils.hasPlayerGotItems(option.items, option.anyItem)) then
            if not option.canInteract then return true end

            local success, resp = pcall(option.canInteract, entity, distance, coords, option.name)

            if success and resp then return true end
        end
    end

    return false
end

local function canTarget()
    return not state.isDisabled()
        and not IsNuiFocused()
        and not IsPauseMenuActive()
        and not lib.progressActive()
        and (allowInVehicle or not cache.vehicle)
        and not IsPlayerFreeAiming(cache.playerId)
        and GetGameTimer() >= cooldown
end

local function openMenu()
    state.setMenuOpen(true)
    SendNuiMessage('{"event": "open"}')
end

local function closeMenu()
    if not state.isMenuOpen() and not currentMenu then return end

    state.setMenuOpen(false)
    currentMenu = nil
    table.wipe(menuHistory)
    menuChanged = true
    options:wipe()
    SendNuiMessage('{"event": "close"}')
end

local function clearPrompt()
    promptVisible = false
    visibleCount = 0
    anchorEntity, anchorOffset, anchorCoords, anchorZone = nil, nil, nil, nil
    closeMenu()
end

---Sets where the prompt is drawn: the zone's centre, the ped's chest,
---or the point on the entity the player was looking at.
local function setAnchor(entityHit, entityType, endCoords)
    anchorEntity, anchorOffset, anchorCoords, anchorZone = nil, nil, nil, nil

    for i = 1, #nearbyZones do
        local zoneOptions = nearbyZones[i].options

        for j = 1, #zoneOptions do
            if not zoneOptions[j].hide then
                anchorZone = nearbyZones[i]
                anchorCoords = anchorZone.coords
                return
            end
        end
    end

    if entityHit and entityHit > 0 then
        anchorEntity = entityHit

        if entityType ~= 1 then
            anchorOffset = GetOffsetFromEntityGivenWorldCoords(entityHit, endCoords.x, endCoords.y, endCoords.z)
        end

        return
    end

    anchorCoords = endCoords
end

---@return vector3?
local function getAnchorCoords()
    if anchorEntity then
        if not DoesEntityExist(anchorEntity) then return end

        if not anchorOffset then
            return GetPedBoneCoords(anchorEntity, chestBone, 0.0, 0.0, 0.0)
        end

        return GetOffsetFromEntityInWorldCoords(anchorEntity, anchorOffset.x, anchorOffset.y, anchorOffset.z)
    end

    return anchorCoords
end

local pools = { 'CObject', 'CPed', 'CVehicle' }
local modelCache = {}
local dotDict, dotTexture = 'shared', 'medaldot_32'
local dotWidth = 0.0075
local dotHeight = dotWidth * GetAspectRatio(false)
local SetDrawOrigin = SetDrawOrigin
local DrawSprite = DrawSprite
local ClearDrawOrigin = ClearDrawOrigin
local menuControls ={ 14, 15, 16, 17, 24, 37, 99, 100, 140, 141, 142, 172, 173, 174, 175, 177, 191, 199, 200, 201, 241, 242, 257 }

---Finds nearby zones and entities that have options for the player, nearest first.
local function scanDots(playerCoords)
    local found = {}
    local n = 0

    if Zones then
        local zones = lib.zones.getNearbyZones()

        for i = 1, #zones do
            local zone = zones[i]

            if zone.options and zone.drawSprite ~= false and zone.coords then
                local dist = #(playerCoords - zone.coords)

                if dist <= dotDistance and hasDotOption(zone.options, 0, dist, zone.coords) then
                    n += 1
                    found[n] = { zone = zone, dist = dist }
                end
            end
        end
    end

    -- Globals never get dots, so with no model/entity options there is nothing to scan.
    if not api.hasModelOrEntityOptions() then return found end

    for p = 1, #pools do
        local pool = pools[p]
        local entities = GetGamePool(pool)

        for i = 1, #entities do
            local entity = entities[i]

            if entity ~= cache.ped and entity ~= cache.vehicle then
                -- Handles keep their model while they exist; the cache is wiped now and then.
                local model = modelCache[entity]

                if not model then
                    model = GetEntityModel(entity)
                    modelCache[entity] = model
                end

                local localList, netList, modelList = api.getOwnOptions(entity, model)

                if localList or netList or modelList then
                    local coords = GetEntityCoords(entity)
                    local dist = #(playerCoords - coords)

                    if dist <= dotDistance and not (pool == 'CPed' and IsPedAPlayer(entity))
                        and (hasDotOption(localList, entity, dist, coords)
                            or hasDotOption(netList, entity, dist, coords)
                            or hasDotOption(modelList, entity, dist, coords))
                        and HasEntityClearLosToEntity(cache.ped, entity, 17) then
                        local dot = { entity = entity, dist = dist }

                        if pool == 'CObject' then
                            -- Props rarely move: fix the point now instead of every frame.
                            local min, max = GetModelDimensions(model)
                            local mid = (min + max) / 2
                            dot.coords = GetOffsetFromEntityInWorldCoords(entity, mid.x, mid.y, mid.z)
                        elseif pool == 'CVehicle' then
                            local min, max = GetModelDimensions(model)
                            dot.offset = (min + max) / 2
                        end

                        n += 1
                        found[n] = dot
                    end
                end
            end
        end
    end

    table.sort(found, function(a, b) return a.dist < b.dist end)

    for i = maxDots + 1, n do found[i] = nil end

    return found
end

local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot
-- Aim assist: how far (metres) the look line may pass beside a dotted target and still pick it, plus a
-- little more per metre from the camera (the third-person camera sits a few metres behind the player).
local assistBase = 0.35
local assistPerMetre = 0.07

---The dotted entity (ATM, prop, NPC... with its own options, already in sight of the player) the camera
---looks closest to, when the ray itself missed. Only hitting an entity exactly made targeting a matter
---of aiming at a few pixels; the dots already say which targets are near and visible.
---Two targets side by side (two ATMs): the one already shown is kept until the look is clearly closer
---to the other one, otherwise every small camera move swaps the prompt between them.
local assistKeep = 0.25

---@return number? entity
---@return vector3? coords
local function assistTarget(playerCoords, current)
    local cam = GetFinalRenderedCamCoord()
    local rot = GetFinalRenderedCamRot(2)
    local rx, rz = math.rad(rot.x), math.rad(rot.z)
    local cx = math.abs(math.cos(rx))
    local dir = vec3(-math.sin(rz) * cx, math.cos(rz) * cx, math.sin(rx))
    local best, bestCoords, bestMiss
    local curCoords, curMiss

    for i = 1, #dots do
        local dot = dots[i]
        local entity = dot.entity

        if entity and DoesEntityExist(entity) then
            local coords = dot.coords
                or dot.offset and GetOffsetFromEntityInWorldCoords(entity, dot.offset.x, dot.offset.y, dot.offset.z)
                or GetPedBoneCoords(entity, chestBone, 0.0, 0.0, 0.0)

            if #(playerCoords - coords) <= maxDistance then
                local to = coords - cam
                local along = to.x * dir.x + to.y * dir.y + to.z * dir.z

                if along > 0 then
                    local miss = #(to - dir * along)

                    if miss <= assistBase + along * assistPerMetre then
                        if entity == current then curCoords, curMiss = coords, miss end

                        if not bestMiss or miss < bestMiss then
                            best, bestCoords, bestMiss = entity, coords, miss
                        end
                    end
                end
            end
        end
    end

    if curMiss and curMiss <= bestMiss + assistKeep then
        return current, curCoords
    end

    return best, bestCoords
end

---@param x number
---@param y number
local function fmt(x, y)
    -- 3 decimals is ~2 px at 1080p; idle frames then match and nothing is sent.
    return ('[%.3f,%.3f]'):format(x, y)
end

local function startTargeting()
    if not canTarget() or state.isActive() then return end

    state.setActive(true)
    lib.requestStreamedTextureDict(dotDict)

    local flag = 511
    local hit, entityHit, endCoords, distance, lastEntity, entityType, entityModel, hasTarget, zonesChanged
    local zones = {}
    local graceTicks = 0

    -- Every frame: move the prompt and dots, and read the list keys while it is open.
    CreateThread(function()
        local lastFrame

        while state.isActive() do
            if debug and endCoords and endCoords ~= vec0 then
                DrawMarker(28, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2,
                    0.2,
                    ---@diagnostic disable-next-line: param-type-mismatch
                    255, 42, 24, 100, false, false, 0, true, false, false, false)
            end

            if state.isMenuOpen() then
                -- weapon wheel / scroll, phone arrows, backspace and pause
                for i = 1, #menuControls do
                    DisableControlAction(0, menuControls[i], true)
                end

                if IsDisabledControlJustPressed(0, 15) or IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 172) then
                    SendNuiMessage('{"event": "nav", "dir": -1}')
                elseif IsDisabledControlJustPressed(0, 14) or IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 173) then
                    SendNuiMessage('{"event": "nav", "dir": 1}')
                elseif IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 201) then
                    -- left click / Enter confirm like the interact key
                    SendNuiMessage('{"event": "confirm"}')
                elseif IsDisabledControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 200) then
                    closeMenu()
                end
            end

            local dotCount = #dots

            -- Nothing on screen: no reason to run every frame.
            if dotCount == 0 and not promptVisible and not state.isMenuOpen() then
                if lastFrame ~= 'null' then
                    SendNuiMessage('{"event":"frame","p":null}')
                    lastFrame = 'null'
                end

                Wait(100)
            else
                local prompt = 'null'
                local skipZone, skipEntity

                if promptVisible then
                    local coords = getAnchorCoords()

                    if coords then
                        local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

                        if onScreen then prompt = fmt(x, y) end
                    end

                    skipZone, skipEntity = anchorZone, anchorEntity
                end

                -- Only the prompt goes through NUI, and only when it moved.
                if prompt ~= lastFrame then
                    SendNuiMessage(('{"event":"frame","p":%s}'):format(prompt))
                    lastFrame = prompt
                end

                -- Dots are drawn by the game itself: no NUI message per frame.
                if dotCount > 0 then
                    for i = 1, dotCount do
                        local dot = dots[i]
                        local coords

                        if dot.zone then
                            if dot.zone ~= skipZone then coords = dot.zone.coords end
                        elseif dot.coords then
                            if dot.entity ~= skipEntity then coords = dot.coords end
                        elseif dot.entity ~= skipEntity and DoesEntityExist(dot.entity) then
                            coords = dot.offset and GetOffsetFromEntityInWorldCoords(dot.entity, dot.offset.x, dot.offset.y, dot.offset.z)
                                or GetPedBoneCoords(dot.entity, chestBone, 0.0, 0.0, 0.0)
                        end

                        if coords then
                            SetDrawOrigin(coords.x, coords.y, coords.z)
                            DrawSprite(dotDict, dotTexture, 0.0, 0.0, dotWidth, dotHeight, 0.0, 244, 242, 241, 235)
                        end
                    end

                    ClearDrawOrigin()
                end

                Wait(0)
            end
        end
    end)

    -- Refresh the dots a couple of times a second.
    CreateThread(function()
        local scans = 0

        while state.isActive() do
            scans += 1

            -- Drop handles of deleted entities so a reused handle gets its real model.
            if scans % 25 == 0 then table.wipe(modelCache) end

            dots = scanDots(GetEntityCoords(cache.ped))
            Wait(750)
        end

        dots = {}
    end)

    while state.isActive() do
        if not canTarget() then
            state.setActive(false)
            break
        end

        local playerCoords = GetEntityCoords(cache.ped)
        -- Ray logic as it was before the 3 Nov "one ray per tick" change (which left only a tiny spot on
        -- props, ATMs and vehicles that still targeted): the ray kind that last found something is tried
        -- first; when it finds no entity the other kind is tried too and the closer one wins and is kept.
        hit, entityHit, endCoords = lib.raycast.fromCamera(flag, 4, 20)

        if entityHit ~= 0 and entityHit ~= lastEntity then
            local success, result = pcall(GetEntityType, entityHit)
            entityType = success and result or 0
        end

        if entityType == 0 then
            local _flag = flag == 511 and 26 or 511
            local _hit, _entityHit, _endCoords = lib.raycast.fromCamera(_flag, 4, 20)

            if #(playerCoords - _endCoords) < #(playerCoords - endCoords) then
                flag, hit, entityHit, endCoords = _flag, _hit, _entityHit, _endCoords

                if entityHit ~= 0 then
                    local success, result = pcall(GetEntityType, entityHit)
                    entityType = success and result or 0
                end
            end
        end

        -- The ray missed (wall, floor, or a prop with no options of its own): take the dotted target the
        -- player is looking next to. A zone under the look keeps priority (utils.getNearbyZones).
        if #dots > 0 then
            local own = false

            if entityHit ~= 0 then
                local okModel, model = pcall(GetEntityModel, entityHit)
                local et = entityType
                local l, n, m = api.getOwnOptions(entityHit, okModel and model or 0)
                own = (l or n or m) and true or et == 1 or et == 2
            end

            if not own and Zones then
                local zones = lib.zones.getNearbyZones()

                for i = 1, #zones do
                    if zones[i].options and zones[i]:contains(endCoords) then own = true break end
                end
            end

            if not own then
                local assisted, coords = assistTarget(playerCoords, hasTarget and lastEntity or nil)

                if assisted then
                    flag, hit, entityHit, endCoords = 511, true, assisted, coords
                    local success, result = pcall(GetEntityType, entityHit)
                    entityType = success and result or 0
                end
            end
        end

        -- A single missed ray (edge of a prop, a frame of jitter) must not drop the prompt:
        -- keep the last target for a couple of ticks before letting it go.
        if hasTarget and entityHit ~= lastEntity and lastEntity and lastEntity > 0 and graceTicks < 2
            and DoesEntityExist(lastEntity) then
            graceTicks += 1
            entityHit, endCoords = lastEntity, currentTarget.coords
        elseif entityHit == lastEntity then
            graceTicks = 0
        end

        distance = #(playerCoords - endCoords)

        if entityHit ~= 0 and entityHit ~= lastEntity then
            local success, result = pcall(GetEntityType, entityHit)
            entityType = success and result or 0
        end

        nearbyZones, zonesChanged = utils.getNearbyZones(endCoords)

        local entityChanged = entityHit ~= lastEntity
        local newOptions = (zonesChanged or entityChanged or menuChanged) and true

        if entityHit > 0 and entityChanged then
            currentMenu = nil

            if flag ~= 511 then
                entityHit = HasEntityClearLosToEntity(entityHit, cache.ped, 7) and entityHit or 0
            end

            if lastEntity ~= entityHit and debug then
                if lastEntity then
                    SetEntityDrawOutline(lastEntity, false)
                end

                if entityType ~= 1 then
                    SetEntityDrawOutline(entityHit, true)
                end
            end

            if entityHit > 0 then
                local success, result = pcall(GetEntityModel, entityHit)
                entityModel = success and result
            end
        end

        if hasTarget and (zonesChanged or entityChanged and type(hasTarget) == 'number' and hasTarget > 1) then
            SendNuiMessage('{"event": "leftTarget"}')
            clearPrompt()

            if entityChanged then options:wipe() end

            if debug and lastEntity > 0 then SetEntityDrawOutline(lastEntity, false) end

            hasTarget = false
        end

        if newOptions and entityModel and entityHit > 0 then
            options:set(entityHit, entityType, entityModel)
        end

        lastEntity = entityHit
        currentTarget.entity = entityHit
        currentTarget.model = entityModel
        currentTarget.options = options
        currentTarget.zones = nearbyZones
        currentTarget.coords = endCoords
        currentTarget.distance = distance
        local hidden = 0
        local totalOptions = 0

        for k, v in pairs(options) do
            local optionCount = #v
            totalOptions += optionCount

            for i = 1, optionCount do
                local option = v[i]
                local hide = shouldHide(option, distance, endCoords, entityHit, entityType, entityModel)

                if option.hide ~= hide then
                    option.hide = hide
                    newOptions = true
                end

                if hide then hidden += 1 end
            end
        end

        if zonesChanged then table.wipe(zones) end

        for i = 1, #nearbyZones do
            local zone = nearbyZones[i]
            local zoneOptions = zone.options
            local optionCount = #zoneOptions
            totalOptions += optionCount
            zones[i] = zoneOptions
            -- a zone picked by a near-miss ray is measured from the player to the zone, not to the wall behind it
            local zoneDistance = zone.coords and math.min(distance, #(playerCoords - zone.coords)) or distance

            for j = 1, optionCount do
                local option = zoneOptions[j]
                local hide = shouldHide(option, zoneDistance, endCoords, entityHit)
                    or (zone.coords and api.isResourceIgnoredNear(zone.coords, option.resource or zone.resource))

                if option.hide ~= hide then
                    option.hide = hide
                    newOptions = true
                end

                if hide then hidden += 1 end
            end
        end

        if newOptions then
            if hasTarget == 1 and (totalOptions - hidden) > 1 then
                hasTarget = true
            end

            if hasTarget and hidden == totalOptions then
                if hasTarget and hasTarget ~= 1 then
                    hasTarget = false
                    SendNuiMessage('{"event": "leftTarget"}')
                    clearPrompt()
                end
            elseif menuChanged or hasTarget ~= 1 and hidden ~= totalOptions then
                hasTarget = options.size

                if currentMenu and options.__global[1]?.name ~= 'builtin:goback' then
                    table.insert(options.__global, 1,
                        {
                            icon = 'fa-solid fa-circle-chevron-left',
                            label = locale('go_back'),
                            name = 'builtin:goback',
                            menuName = currentMenu,
                            openMenu = 'home'
                        })
                end

                promptVisible = true
                visibleCount = totalOptions - hidden
                setAnchor(entityHit, entityType, endCoords)

                SendNuiMessage(json.encode({
                    event = 'setTarget',
                    options = options,
                    zones = zones,
                }, { sort_keys = true }))
            end

            menuChanged = false
        end

        if not hasTarget or hasTarget == 1 then
            flag = flag == 511 and 26 or 511
        end

        Wait(hit and 50 or 100)
    end

    if lastEntity and debug then
        SetEntityDrawOutline(lastEntity, false)
    end

    clearPrompt()
    SendNuiMessage('{"event": "visible", "state": false}')
    table.wipe(currentTarget)
    options:wipe()

    if nearbyZones then table.wipe(nearbyZones) end
end

---@type CKeybind
local keybind = lib.addKeybind({
    name = 'ox_target_interact',
    defaultKey = GetConvar('ox_target:interactKey', 'E'),
    defaultMapper = 'keyboard',
    description = locale('interact_key'),
    onPressed = function()
        if not state.isActive() or not promptVisible then return end

        if not state.isMenuOpen() and visibleCount > 1 then
            return openMenu()
        end

        SendNuiMessage('{"event": "confirm"}')
    end,
})

local function sendStrings()
    SendNuiMessage(json.encode({
        event = 'strings',
        key = keybind:getCurrentKey(),
        interact = locale('interact'),
        select = locale('nav_select'),
        confirm = locale('nav_confirm'),
        close = locale('nav_close'),
    }))
end

-- Prompts are always on: start whenever the player can interact.
CreateThread(function()
    while true do
        if not state.isActive() and canTarget() then
            sendStrings()
            local success, err = pcall(startTargeting)

            if not success then
                -- Never leave the prompt stuck: reset and start again on the next tick.
                lib.print.error(err)
                state.setActive(false)
                clearPrompt()
                SendNuiMessage('{"event": "visible", "state": false}')
            end
        end

        Wait(250)
    end
end)

---@generic T
---@param option T
---@param server? boolean
---@return T
local function getResponse(option, server)
    local response = table.clone(option)
    response.entity = currentTarget.entity
    response.zone = currentTarget.zone
    response.coords = currentTarget.coords
    response.distance = currentTarget.distance

    if server then
        response.entity = response.entity ~= 0 and NetworkGetEntityIsNetworked(response.entity) and
            NetworkGetNetworkIdFromEntity(response.entity) or 0
    end

    response.icon = nil
    response.groups = nil
    response.items = nil
    response.canInteract = nil
    response.onSelect = nil
    response.export = nil
    response.event = nil
    response.serverEvent = nil
    response.command = nil

    return response
end

RegisterNUICallback('select', function(data, cb)
    cb(1)

    if not state.isActive() then return end

    local zone = data[3] and nearbyZones[data[3]]

    ---@type OxTargetOption?
    local option = zone and zone.options[data[2]] or options[data[1]] and options[data[1]][data[2]]

    if not option then return end

    if option.openMenu then
        local menuDepth = #menuHistory

        if option.name == 'builtin:goback' then
            option.menuName = option.openMenu
            option.openMenu = menuHistory[menuDepth]

            if menuDepth > 0 then
                menuHistory[menuDepth] = nil
            end
        else
            menuHistory[menuDepth + 1] = currentMenu
        end

        menuChanged = true
        currentMenu = option.openMenu ~= 'home' and option.openMenu or nil

        options:wipe()

        if not state.isMenuOpen() then openMenu() end
    else
        -- Done: hide everything for a moment so the script's own UI can open.
        cooldown = GetGameTimer() + 600
        state.setActive(false)
    end

    currentTarget.zone = zone?.id

    if option.onSelect then
        option.onSelect(option.qtarget and currentTarget.entity or getResponse(option))
    elseif option.export then
        exports[option.resource or zone.resource][option.export](nil, getResponse(option))
    elseif option.event then
        TriggerEvent(option.event, getResponse(option))
    elseif option.serverEvent then
        TriggerServerEvent(option.serverEvent, getResponse(option, true))
    elseif option.command then
        ExecuteCommand(option.command)
    end
end)

-- DaddyRP: /targetinfo prints the targeted entity and which resource added each option (F8)
RegisterCommand('targetinfo', function()
    local t = currentTarget
    print(('[ox_target] entity=%s model=%s coords=%s distance=%.2f'):format(tostring(t.entity), tostring(t.model), tostring(t.coords), t.distance or -1))
    for kind, list in pairs(t.options or {}) do
        if type(list) == 'table' then
            for i = 1, #list do
                local o = list[i]
                print(('  [%s] resource=%s name=%s label=%s hide=%s ignored=%s'):format(kind, tostring(o.resource), tostring(o.name), tostring(o.label), tostring(o.hide), tostring(api.isResourceIgnoredOn(t.entity, o.resource))))
            end
        end
    end
    for i = 1, #(t.zones or {}) do
        local z = t.zones[i]
        for j = 1, #(z.options or {}) do
            local o = z.options[j]
            print(('  [zone %s] resource=%s name=%s label=%s coords=%s hide=%s'):format(tostring(z.id or i), tostring(o.resource or z.resource), tostring(o.name), tostring(o.label), tostring(z.coords), tostring(o.hide)))
        end
    end
end, false)
