-- Objects of the places, drawn as local objects (no network entities). An object only exists near the player,
-- and only objects with a use get a marker and an E key. Nothing here runs on a timer.

Venue.Local = Venue.Local or {}
local objects = {}
local busy = false

local function warn(model)
    print(('^3[daddy_venue] model %s does not exist, change it in Config.Build^0'):format(model))
end

local function spawn(entry)
    if entry.data.existing then return end
    -- an object without a prop (the pickup counter) is only its marker and its E
    local kind = Config.Build.Objects[entry.data.type]
    if kind and kind.prop == false then return end
    local hash = joaat(entry.data.model)
    if not IsModelInCdimage(hash) then
        if not entry.warned then entry.warned = true warn(entry.data.model) end
        return
    end
    -- runs in its own thread (see add): a slow model must not hold up the ox_lib points loop, and requestModel throws
    -- on a timeout; when the player left meanwhile, or the object went, nothing is made
    if not pcall(lib.requestModel, hash, 5000) then return end
    if not entry.inside or entry.entity or objects[entry.data.id] ~= entry then
        SetModelAsNoLongerNeeded(hash)
        return
    end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local object = CreateObject(hash, entry.data.x, entry.data.y, entry.data.z, false, false, false)
    SetEntityHeading(object, entry.data.h)
    SetEntityCoordsNoOffset(object, entry.data.x, entry.data.y, entry.data.z, false, false, false)
    FreezeEntityPosition(object, true)
    SetModelAsNoLongerNeeded(hash)
    entry.entity = object
    -- DaddyRP: wais-tv targets every prop_tv_flat_01 from its escrowed code; our screens are not its TVs
    if GetResourceState('ox_target') == 'started' then
        pcall(function() exports.ox_target:ignoreResourceOn(object, 'wais-tv') end)
    end
end

local function despawn(entry)
    if entry.entity and DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
    entry.entity = nil
end

local function forget(id)
    local entry = objects[id]
    if not entry then return end
    despawn(entry)
    if entry.stream then entry.stream:remove() end
    if entry.touch then entry.touch.remove() end
    if entry.show then entry.show.remove() end
    objects[id] = nil
end

-- DaddyRP: staff objects (office, depot, stations) show their E only to the staff of the place's business.
-- Asked from the server, again when an object comes into range (at most every 30 s) and on login.
local staffOf, staffAt, staffAsking = {}, nil, false

local function refreshStaff(force)
    if staffAsking or (not force and staffAt and GetGameTimer() - staffAt < 30000) then return end
    staffAsking, staffAt = true, GetGameTimer()
    CreateThread(function()
        local set = {}
        for _, place in ipairs(lib.callback.await('daddy_venue:staffPlaces', false) or {}) do set[tonumber(place)] = true end
        staffOf, staffAsking = set, false
    end)
end

local function isStaff(placeId)
    return staffOf[tonumber(placeId)] == true
end

local function add(data)
    forget(data.id)
    local def = Config.Build.Objects[data.type]
    if not def then return end
    local entry = { data = data }
    objects[data.id] = entry
    local at = vec3(data.x, data.y, data.z)

    entry.stream = lib.points.new({
        coords = at, distance = Config.Build.Stream,
        onEnter = function()
            entry.inside = true
            refreshStaff()
            if not entry.entity and not entry.spawning then
                entry.spawning = true
                CreateThread(function()
                    spawn(entry)
                    entry.spawning = false
                end)
            end
        end,
        onExit = function()
            entry.inside = false
            despawn(entry)
        end,
    })

    if def.display and Venue.Local.display then entry.show = Venue.Local.display(entry, def) end

    if def.use or def.group == 'station' then
        entry.touch = Venue.Interact.add({
            coords = at, label = Venue.objectName(data.type), icon = def.icon, lift = (data.existing or def.prop == false) and 1.0 or 0.5,
            canInteract = not def.public and function() return isStaff(data.place) end or nil,
            marker = function()
                if data.existing or def.prop == false then
                    DrawMarker(2, data.x, data.y, data.z + 1.2, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, 61, 220, 151, 160, true, true, 2, false, nil, nil, false)
                else
                    DrawMarker(1, data.x, data.y, data.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.4, 61, 220, 151, 110, false, false, 2, false, nil, nil, false)
                end
            end,
            onSelect = function()
                if def.group ~= 'station' then return TriggerServerEvent('daddy_venue:objectUse', data.id) end
                if busy then return end
                busy = true
                Venue.Local.station(data)
                busy = false
            end,
        })
    end
end

-- DaddyRP: at the depot: open the stash (the ingredients in it are the stock), or the stock page
RegisterNetEvent('daddy_venue:depotMenu', function(id)
    lib.registerContext({ id = 'daddy_depot', title = L('obj_depot'), options = {
        { title = L('depot_stash'), description = L('depot_stash_hint'), icon = 'fa-solid fa-box-open', onSelect = function() TriggerServerEvent('daddy_venue:depotOpen', id) end },
        { title = L('depot_open'), icon = 'fa-solid fa-boxes-stacked', onSelect = function() TriggerServerEvent('daddy_venue:objectUse', id, true) end },
    } })
    lib.showContext('daddy_depot')
end)

function Venue.Local.owns(entity)
    for _, entry in pairs(objects) do
        if entry.entity == entity then return true end
        -- DaddyRP: a map prop given to the place (existing) is not spawned here, so match it by where it stands
        if entry.data.existing and DoesEntityExist(entity)
            and #(GetEntityCoords(entity) - vec3(entry.data.x, entry.data.y, entry.data.z)) < 0.3 then return true end
    end
    return false
end

-- one pass over our objects, for a scan of the whole prop pool: owned(entity) is then a table lookup
function Venue.Local.ownedTest()
    local spawned, spots = {}, {}
    for _, entry in pairs(objects) do
        if entry.entity then spawned[entry.entity] = true end
        if entry.data.existing then spots[#spots + 1] = vec3(entry.data.x, entry.data.y, entry.data.z) end
    end
    return function(entity)
        if spawned[entity] then return true end
        if #spots == 0 then return false end
        local at = GetEntityCoords(entity)
        for i = 1, #spots do
            if #(at - spots[i]) < 0.3 then return true end
        end
        return false
    end
end

-- DaddyRP: other scripts that target models globally (wais-tv on prop_tv_flat_01) leave our props alone with this
exports('IsVenueObject', function(entity)
    return Venue.Local.owns(entity)
end)

function Venue.Local.nearest(coords, range)
    local best, bestDistance
    for id, entry in pairs(objects) do
        local distance = #(coords - vec3(entry.data.x, entry.data.y, entry.data.z))
        if distance <= range and (not bestDistance or distance < bestDistance) then best, bestDistance = entry.data, distance end
    end
    return best
end

-- the objects of one type in a place, the closest first
function Venue.Local.ofType(placeId, kind)
    local at = GetEntityCoords(cache.ped)
    local out = {}
    for _, entry in pairs(objects) do
        if entry.data.place == placeId and entry.data.type == kind then
            out[#out + 1] = { data = entry.data, distance = #(at - vec3(entry.data.x, entry.data.y, entry.data.z)) }
        end
    end
    table.sort(out, function(a, b) return a.distance < b.distance end)
    return out
end

-- every object within `range`, the closest first
function Venue.Local.near(coords, range)
    local out = {}
    for _, entry in pairs(objects) do
        local distance = #(coords - vec3(entry.data.x, entry.data.y, entry.data.z))
        if distance <= range then out[#out + 1] = { data = entry.data, distance = distance } end
    end
    table.sort(out, function(a, b) return a.distance < b.distance end)
    return out
end

RegisterNetEvent('daddy_venue:objectAdd', function(data) if type(data) == 'table' then add(data) end end)
RegisterNetEvent('daddy_venue:objectMove', function(data) if type(data) == 'table' then add(data) end end)
RegisterNetEvent('daddy_venue:objectRemove', forget)

CreateThread(function()
    local list = lib.callback.await('daddy_venue:objectsState', false)
    for _, data in ipairs(list or {}) do add(data) end
    refreshStaff(true)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() refreshStaff(true) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function() refreshStaff(true) end)
RegisterNetEvent('daddy_venue:staffChanged', function() refreshStaff(true) end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id in pairs(objects) do forget(id) end
end)
