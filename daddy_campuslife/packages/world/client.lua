-- World on the client: the product's snapshot and anchors that stream near the player.
--   local world = World.client()
--   world.subscribe(function(snapshot, message) world.anchors.sync('canteen', defs) end)
World = World or {}

local RESOURCE = GetCurrentResourceName()
local STREAM_DISTANCE, DESPAWN_MARGIN, DRAW_MARGIN = 85.0, 15.0, 20.0
local POINT_BOX, POINT_DROP = { x = 1.0, y = 1.0, z = 1.95 }, 0.15 -- a bare point's target: from 15 cm under the spot to 1.8 m over it

-- Anchors ------------------------------------------------------------------------
-- def: { uid, label, coords {x,y,z,w}, presentation 'point'|'ped'|'prop', model, scenario, shape?,
--        options?, distance?, blip?, marker?, text3d?, streamDistance?, revision?, onSpawn?,
--        onDespawn? (def, entity) as an entity onSpawn saw goes (out of reach, a new look, removed),
--        targetSphere? { radius, height } (the options on a sphere at the spot instead of the entity, for props whose
--        collision the target ray may miss, e.g. a tree with see-through leaves) }
local function newAnchors()
    local anchors, namespaces = {}, {}
    local draw, dirty, lastScan, running, drawing = {}, true, nil, false, false
    local api = {}

    local function addTarget(record)
        local def, shape = record.def, record.shape
        -- No options (any more): no target, so a refresh in place takes stale ones away too.
        if not def.options or #def.options == 0 then return DL.target.remove(def.uid) end
        local data = { distance = def.distance, options = def.options }
        if def.targetSphere then
            local c, sphere = def.coords, def.targetSphere
            data.coords, data.radius = vector3(c.x, c.y, c.z + (sphere.height or 1.0)), sphere.radius or 1.0
            return DL.target.addSphere(def.uid, data)
        end
        if record.entity then return DL.target.addEntity(def.uid, record.entity, data) end
        if shape.shape == 'sphere' then
            data.coords, data.radius = vector3(shape.center.x, shape.center.y, shape.center.z), shape.radius
            return DL.target.addSphere(def.uid, data)
        end
        if shape.shape == 'polygon' then
            data.points, data.minZ, data.maxZ = shape.points, shape.minZ, shape.maxZ
            return DL.target.addPoly(def.uid, data)
        end
        local size, center = shape.size, shape.center
        if shape.shape ~= 'box' then
            -- A look at the floor of the spot lands inside, not on the box's very edge.
            size, center = POINT_BOX, { x = center.x, y = center.y, z = center.z + POINT_BOX.z * 0.5 - POINT_DROP }
        end
        data.coords, data.size, data.heading = vector3(center.x, center.y, center.z), vector3(size.x, size.y, size.z), shape.rotation or 0.0
        DL.target.addBox(def.uid, data)
    end

    -- Where a ped's origin goes: on the ground under its point, a model's height above the floor. The world editor
    -- saves the origin (a metre up) and the place editor the feet, so the floor is looked for from just above both;
    -- with no ground found (collision not loaded) the point is taken as the origin, as the world editor saves it.
    local function pedOrigin(hash, c)
        local found, ground = GetGroundZFor_3dCoord(c.x, c.y, c.z + 1.2, false)
        if not found or ground < c.z - 1.5 or ground > c.z + 1.2 then return vector3(c.x, c.y, c.z) end
        local min = GetModelDimensions(hash)
        return vector3(c.x, c.y, ground - min.z)
    end

    local function spawnEntity(def)
        if def.presentation ~= 'ped' and def.presentation ~= 'prop' then return nil end
        local hash = type(def.model) == 'number' and def.model or joaat(tostring(def.model or ''))
        if not IsModelInCdimage(hash) then
            if def.presentation ~= 'ped' then return nil end
            hash = `a_m_y_business_01`
        end
        if not pcall(lib.requestModel, hash, 5000) then return nil end
        local c, heading = def.coords, def.coords.w or 0.0
        if def.presentation == 'ped' then c = pedOrigin(hash, c) end
        -- CreateObject sets the model's lowest point on the coords; exact = true puts its origin there (a card hanging from its tie).
        pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
        local entity = def.presentation == 'ped' and CreatePed(4, hash, c.x, c.y, c.z, heading, false, false)
            or (def.exact and CreateObjectNoOffset or CreateObject)(hash, c.x, c.y, c.z, false, false, false)
        SetModelAsNoLongerNeeded(hash)
        if not DoesEntityExist(entity) then return nil end
        SetEntityHeading(entity, heading)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        if def.presentation == 'ped' then
            SetBlockingOfNonTemporaryEvents(entity, true)
            SetPedCanRagdoll(entity, false)
            if def.scenario and def.scenario ~= '' then TaskStartScenarioAtPosition(entity, def.scenario, c.x, c.y, c.z, heading, 0, true, true) end -- c is the ped's origin (pedOrigin)
        end
        return entity
    end

    local hooked = {} -- entity -> the def whose onDespawn runs as it goes
    local function delete(entity)
        local def = entity and hooked[entity]
        if def then
            hooked[entity] = nil
            pcall(def.onDespawn, def, entity)
        end
        if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    end

    local function despawn(record)
        DL.target.remove(record.def.uid)
        delete(record.entity)
        delete(record.old)
        record.entity, record.old, record.spawned = nil, nil, false
    end

    -- The entity of the record's look now; the one it replaces (record.old) stood until it is up. A look changed or
    -- an anchor removed while the model loaded is noticed here.
    local function spawn(record)
        local look = record.look
        local entity = spawnEntity(record.def)
        if anchors[record.def.uid] ~= record then return delete(entity) end
        if record.look ~= look then -- it stands in until the next scan brings the newer look
            if entity then delete(record.old) record.old = entity end
            return
        end
        delete(record.old)
        record.entity, record.old, record.spawned = entity, nil, true
        addTarget(record)
        if record.def.onSpawn then pcall(record.def.onSpawn, record.def, record.entity) end
        if record.def.onDespawn and entity then hooked[entity] = record.def end
    end

    local function applyBlip(record)
        local blip = record.def.blip
        if record.blip and (not blip or not DoesBlipExist(record.blip)) then
            if DoesBlipExist(record.blip) then RemoveBlip(record.blip) end
            record.blip = nil
        end
        if not blip or record.blip then return end
        local c = record.center
        record.blip = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(record.blip, tonumber(blip.sprite) or 1)
        SetBlipColour(record.blip, tonumber(blip.color) or 0)
        SetBlipScale(record.blip, (tonumber(blip.scale) or 0.7) + 0.0)
        SetBlipAsShortRange(record.blip, blip.shortRange ~= false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(tostring(blip.label or record.def.label or ''))
        EndTextCommandSetBlipName(record.blip)
    end

    local function text3d(coords, text, scale)
        SetTextScale(0.0, scale or 0.35)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(text)
        SetDrawOrigin(coords.x, coords.y, coords.z, 0)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()
    end

    -- Markers and 3D texts of the few anchors near the player, every frame.
    local function startDraw()
        if drawing then return end
        drawing = true
        CreateThread(function()
            while #draw > 0 do
                local here = GetEntityCoords(PlayerPedId())
                for _, record in ipairs(draw) do
                    local def, c = record.def, record.def.coords
                    local distance = #(here - vector3(c.x, c.y, c.z))
                    local m = def.marker
                    if m and distance <= (m.drawDistance or 15.0) then
                        DrawMarker(m.type or 1, c.x, c.y, c.z + (m.offset or 0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, m.size.x, m.size.y, m.size.z,
                            m.color.r, m.color.g, m.color.b, m.color.a, m.bob == true, true, 2, m.rotate == true, nil, nil, false)
                    end
                    local t = def.text3d
                    if t and distance <= (t.distance or 3.0) then
                        local label = type(t.text) == 'function' and t.text(def) or t.text
                        if label and label ~= '' then text3d(vector3(c.x, c.y, c.z + (t.offset or 1.1)), label, t.scale) end
                    end
                end
                Wait(0)
            end
            drawing = false
        end)
    end

    -- One loop for every anchor; it sleeps long while the player stands still and wakes as soon as an anchor changes.
    local function scan()
        local here = GetEntityCoords(PlayerPedId())
        if not dirty and lastScan and #(here - lastScan) < 2.0 then return 4000 end
        dirty, lastScan = false, here
        local near, nextDraw, list = false, {}, {}
        for _, record in pairs(anchors) do list[#list + 1] = record end -- a spawn may wait for its model while anchors change
        for _, record in ipairs(list) do
            if anchors[record.def.uid] == record then
                local def, c = record.def, record.center
                local distance = #(here - vector3(c.x, c.y, c.z)) - record.radius
                local stream = def.streamDistance or STREAM_DISTANCE
                if distance <= stream then
                    near = true
                    if not record.spawned then spawn(record) end
                elseif record.old and not record.spawned then
                    delete(record.old) -- a new look out of reach: the old one goes now
                    record.old = nil
                elseif record.spawned and distance > stream + DESPAWN_MARGIN then
                    despawn(record)
                end
                local reach = math.max(def.marker and (def.marker.drawDistance or 15.0) or 0.0, def.text3d and (def.text3d.distance or 3.0) or 0.0)
                if record.spawned and reach > 0 and distance <= reach + DRAW_MARGIN then nextDraw[#nextDraw + 1] = record end
            end
        end
        draw = nextDraw
        if #draw > 0 then startDraw() end
        return near and 250 or 2000
    end

    local function startScan()
        if running then return end
        running = true
        CreateThread(function()
            while next(anchors) do
                local wake = GetGameTimer() + scan()
                while not dirty do
                    local left = wake - GetGameTimer()
                    if left <= 0 then break end
                    Wait(math.min(left, 100))
                end
            end
            running = false
        end)
    end

    function api.set(uid, def)
        def.uid = uid
        local shape = def.shape and DL.geo.shape(def.shape) or DL.geo.fromRecord(def)
        if not shape then return end
        local center, radius = DL.geo.extent(shape)
        local record = anchors[uid]
        if record then
            local same = DL.geo.equals(record.shape, shape) and record.def.revision ~= nil and record.def.revision == def.revision
                and record.def.presentation == def.presentation and record.def.model == def.model and record.def.scenario == def.scenario
            if same then
                -- Only labels or options changed: keep the entity, refresh the target.
                record.def, record.shape = def, shape
                if record.spawned then addTarget(record) end
                applyBlip(record)
                return
            end
            -- A new look: the old entity stays until the new one is up, so the thing never blinks out.
            DL.target.remove(record.def.uid)
            if record.entity then
                delete(record.old)
                record.old = record.entity
            end
            record.entity = nil
        end
        record = record or {}
        record.def, record.shape, record.center, record.radius, record.spawned = def, shape, center, radius, false
        record.look = (record.look or 0) + 1
        anchors[uid] = record
        applyBlip(record)
        dirty = true
        startScan()
    end

    function api.remove(uid)
        local record = anchors[uid]
        if not record then return end
        despawn(record)
        if record.blip and DoesBlipExist(record.blip) then RemoveBlip(record.blip) end
        anchors[uid] = nil
        for _, set in pairs(namespaces) do set[uid] = nil end
        for i = #draw, 1, -1 do
            if draw[i] == record then table.remove(draw, i) end
        end
        dirty = true
    end

    -- The list is the whole namespace: anchors missing from it are removed.
    function api.sync(namespace, defs)
        local previous, current = namespaces[namespace] or {}, {}
        for _, def in ipairs(defs or {}) do
            if def.uid and def.coords then
                current[def.uid] = true
                api.set(def.uid, def)
            end
        end
        for uid in pairs(previous) do
            if not current[uid] then api.remove(uid) end
        end
        namespaces[namespace] = current
    end

    function api.clear(namespace)
        for uid in pairs(namespace and (namespaces[namespace] or {}) or anchors) do api.remove(uid) end
        if namespace then namespaces[namespace] = nil end
    end

    function api.get(uid) return anchors[uid] and anchors[uid].def end
    function api.entity(uid) return anchors[uid] and anchors[uid].entity end

    -- The first anchor the player stands in, optionally by namespace kind.
    function api.find(filter, coords)
        coords = coords or GetEntityCoords(PlayerPedId())
        for _, record in pairs(anchors) do
            local def = record.def
            if (not filter or ((not filter.module or def.module == filter.module) and (not filter.kind or def.kind == filter.kind)))
                and DL.geo.contains(record.shape, coords) then
                return def
            end
        end
    end

    function api.isInside(uid, coords)
        local record = anchors[uid]
        return record ~= nil and DL.geo.contains(record.shape, coords or GetEntityCoords(PlayerPedId()))
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource == RESOURCE then api.clear() end
    end)

    return api
end

-- Snapshot -------------------------------------------------------------------------

function World.client(opts)
    opts = opts or {}
    local snapshot = { revision = 0, entities = {}, zones = {} }
    local listeners, queued, topics = {}, false, {}
    local world = { anchors = newAnchors() }

    local function filtered(rows, filter)
        local out = {}
        for _, row in ipairs(rows) do
            if not filter or ((not filter.module or row.module == filter.module) and (not filter.kind or row.kind == filter.kind)) then out[#out + 1] = row end
        end
        return out
    end

    function world.entities(filter) return filtered(snapshot.entities, filter) end
    function world.zones(filter) return filtered(snapshot.zones, filter) end
    function world.revision() return snapshot.revision end

    function world.entity(uid)
        for _, row in ipairs(snapshot.entities) do
            if row.uid == uid then return row end
        end
    end

    function world.zone(uid)
        for _, row in ipairs(snapshot.zones) do
            if row.uid == uid then return row end
        end
    end

    -- fn(snapshot, message) runs now if loaded, and after every change.
    function world.subscribe(fn)
        listeners[#listeners + 1] = fn
        if snapshot.revision > 0 then pcall(fn, snapshot, { topic = 'bootstrap' }) end
    end

    function world.refresh(message)
        local result = lib.callback.await(RESOURCE .. ':world:snapshot', false, opts.module)
        if type(result) ~= 'table' or not result.ok then return false end
        snapshot = result.data
        for _, fn in ipairs(listeners) do
            local ok, err = pcall(fn, snapshot, message or { topic = 'bootstrap' })
            if not ok then print(('^1[%s] world listener: %s^7'):format(RESOURCE, err)) end
        end
        return true
    end

    -- Many changes in a row become one refresh, spread over two seconds so a whole server does not ask at once; the
    -- listeners get the newest message with every topic that changed meanwhile, and a failed ask is tried again.
    RegisterNetEvent(RESOURCE .. ':world:changed', function(message)
        if type(message) ~= 'table' then return end
        if message.topic then topics[message.topic] = true end
        if queued then queued = message return end
        queued = message
        SetTimeout(250 + math.random(0, 2000), function()
            local latest, changed = queued, {}
            for topic in pairs(topics) do changed[#changed + 1] = topic end
            queued, topics = false, {}
            if (tonumber(latest.revision) or 0) > 0 and latest.revision <= snapshot.revision then return end
            latest.topics = changed
            for attempt = 1, 3 do
                if world.refresh(latest) then return end
                Wait(2000 * attempt)
            end
        end)
    end)

    CreateThread(function()
        DL.fw.awaitLogin()
        local delay = 1000
        while not world.refresh() do
            Wait(delay)
            delay = math.min(delay * 2, 15000)
        end
    end)

    return world
end
