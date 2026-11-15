-- Client side of paint surfaces: mounts what the player stands in, the paint NUI bridge, live deltas.
--   local canvases = Canvas.client({ radius = 12.0, height = 4.0, options = function(item) end, open = function(payload) end, close = function() end })
-- With rights = function(uid) -> { can, canRev } the drawing lives elsewhere (the ink engine): a mount reads the rights
-- only, no strokes and no surface; onList(items) hears every new board list.
Canvas = Canvas or {}

local RESOURCE = GetCurrentResourceName()
local EVENT = RESOURCE .. ':canvas'
local CACHE_KEEP, BUFFER_MAX, BULK_WAIT_MS, RETRY_MS = 3, 64, 30000, 5000

local function await(name, data)
    local result = lib.callback.await(EVENT .. ':' .. name, false, data)
    return type(result) == 'table' and result or { ok = false, error = 'integration_unavailable' }
end

local function nui(action, data)
    SendNUIMessage({ action = action, data = data })
end

-- Big boards come as a latent event and the answer only names its token; either may arrive first.
local bulks, waiting = {}, {}

RegisterNetEvent(EVENT .. ':bulk', function(token, strokes)
    local pending = waiting[token]
    if pending then
        waiting[token] = nil
        return pending:resolve(strokes)
    end
    bulks[token] = strokes
    SetTimeout(BULK_WAIT_MS, function() bulks[token] = nil end)
end)

local function fetch(input)
    local result = await('get', input)
    local token = result.ok and result.data.latent
    if not token then return result end
    local strokes = bulks[token]
    bulks[token] = nil
    if not strokes then
        local pending = promise.new()
        waiting[token] = pending
        SetTimeout(BULK_WAIT_MS, function()
            if waiting[token] ~= pending then return end
            waiting[token] = nil
            pending:resolve(false)
        end)
        strokes = Citizen.Await(pending)
    end
    if type(strokes) ~= 'table' then return { ok = false, error = 'integration_unavailable' } end
    result.data.strokes = strokes
    return result
end

-- Screen corners of the surface, so the NUI can map the pointer onto it.
local function screenRect(item, viewer)
    local rad = math.rad(item.heading)
    local nx, ny = math.cos(rad), math.sin(rad)
    local rx, ry = math.cos(rad + math.pi / 2), math.sin(rad + math.pi / 2)
    if nx * (viewer.x - item.coords.x) + ny * (viewer.y - item.coords.y) < 0 then nx, ny = -nx, -ny end
    local c = item.coords + vector3(nx, ny, 0.0) * 0.005
    local hw, hh = item.width * 0.5, item.height * 0.5
    local corners = {
        c + vector3(-rx * hw, -ry * hw, hh), c + vector3(rx * hw, ry * hw, hh),
        c + vector3(-rx * hw, -ry * hw, -hh), c + vector3(rx * hw, ry * hw, -hh),
    }
    local out, minX, minY, maxX, maxY = {}, 1, 1, 0, 0
    for i, corner in ipairs(corners) do
        local onScreen, x, y = GetScreenCoordFromWorldCoord(corner.x, corner.y, corner.z)
        if not onScreen then return nil end
        out['p' .. i] = { x = x, y = y }
        minX, minY, maxX, maxY = math.min(minX, x), math.min(minY, y), math.max(maxX, x), math.max(maxY, y)
    end
    out.left, out.top, out.width, out.height = minX, minY, maxX - minX, maxY - minY
    return out
end

function Canvas.client(opts)
    local radius, height = opts.radius or 12.0, opts.height or 4.0
    local items, mounted, loading, recent = {}, {}, {}, {}
    local active, claimed, camera
    local nearest = math.huge
    local canvases = { items = items }
    local applyDelta

    -- Surfaces and targets -------------------------------------------------

    -- The floor area (with its floors) when there is one, else the radius on the board's own floor.
    local function inside(item, pcoords)
        if item.zone then return DL.geo.inZone(item.zone, pcoords) end
        return math.abs(pcoords.z - item.coords.z) <= height and #(pcoords - item.coords) <= radius
    end

    local function streamDistance(item)
        if not item.zone then return radius + 5.0 end
        local _, size = DL.geo.bounds(item.zone.points)
        return size * 2.0 + 5.0
    end

    local function addTarget(item)
        DL.target.addBox(item.uid, {
            coords = item.coords, heading = item.heading + 90.0,
            size = vector3(item.width + 0.2, 0.6, item.height + 0.2),
            distance = opts.distance or 2.5, options = opts.options(item),
        })
    end

    -- Strokes stay cached for the last few boards left, so stepping out and back costs one small check.
    local function keep(uid)
        for i = #recent, 1, -1 do
            if recent[i] == uid then table.remove(recent, i) end
        end
        table.insert(recent, 1, uid)
        while #recent > CACHE_KEEP do
            local old = items[table.remove(recent)]
            if old and not mounted[old.uid] then old.strokes, old.contentVersion = nil, nil end
        end
    end

    -- Fetches a board: a copy that is still current costs nothing; full asks for all of it. Deltas that land
    -- meanwhile wait and are replayed after. A second caller waits for the fetch already running.
    local function load(uid, full)
        if loading[uid] then
            while loading[uid] do Wait(50) end
            return items[uid] ~= nil and items[uid].strokes ~= nil
        end
        local item = items[uid]
        if not item then return false end
        local pending = { deltas = {} }
        loading[uid] = pending
        local known = not full and item.strokes and #item.strokes or 0
        local result = fetch({ uid = uid, since = known, contentVersion = item.contentVersion })
        loading[uid] = nil
        item = items[uid]
        if not item then return false end
        if result.ok then
            local data = result.data
            local version = data.canvas.contentVersion
            item.tools, item.limits, item.painter = data.tools, data.limits, data.painter
            -- Rights pushed while this was on its way are newer than the ones in it.
            if data.canvas.can and (data.canvas.canRev or 0) >= (item.canRev or 0) then item.can, item.canRev = data.canvas.can, data.canvas.canRev end
            -- The painter's own strokes may already be newer than this answer.
            if not (active == uid and claimed and version < (item.contentVersion or 0)) then
                if data.base > 0 and item.strokes then
                    for _, stroke in ipairs(data.strokes) do item.strokes[#item.strokes + 1] = stroke end
                else
                    item.strokes = data.strokes
                end
                item.contentVersion, item.fill = version, data.fill
            end
        end
        if pending.again then return load(uid, true) end
        for _, payload in ipairs(pending.deltas) do applyDelta(payload, true) end
        return result.ok and item.strokes ~= nil, result.error
    end

    -- Rights alone when the drawing lives elsewhere (opts.rights: the ink engine); a newer push still wins.
    local function rightsOf(uid)
        local got = opts.rights(uid)
        local item = items[uid]
        if type(got) ~= 'table' or type(got.can) ~= 'table' or not item then return false end
        if (tonumber(got.canRev) or 0) >= (item.canRev or 0) then item.can, item.canRev = got.can, tonumber(got.canRev) or 0 end
        return true
    end

    local function mount(uid)
        local item = items[uid]
        if not item or mounted[uid] or (item.retryAt and item.retryAt > GetGameTimer()) then return end
        mounted[uid] = 'loading'
        local loaded
        if opts.rights then loaded = rightsOf(uid) else loaded = load(uid, false) end
        item = items[uid]
        if mounted[uid] ~= 'loading' or not item then return end
        if not loaded then
            mounted[uid], item.retryAt = nil, GetGameTimer() + RETRY_MS
            return
        end
        mounted[uid] = true
        addTarget(item)
        if not opts.rights then
            local data = {
                coords = item.coords, heading = item.heading, width = item.width, height = item.height,
                background = item.background, strokes = item.strokes, streamDistance = streamDistance(item),
            }
            if opts.surface then opts.surface(item, data) end
            Surface.set(uid, data)
        end
        if opts.onMount then opts.onMount(item) end
    end
    canvases.streamDistance = streamDistance

    local function unmount(uid)
        if not mounted[uid] then return end
        mounted[uid] = nil
        DL.target.remove(uid)
        if not opts.rights then Surface.remove(uid) end
        keep(uid)
        if opts.onUnmount then opts.onUnmount(uid) end
    end

    local function shapeKey(item)
        return json.encode({ item.coords, item.heading, item.width, item.height, item.background, item.zone, opts.key and opts.key(item) })
    end

    -- Only surfaces whose shape changed are rebuilt; the rest keep their pages, strokes and rights.
    function canvases.refresh()
        local result = await('list')
        if not result.ok then return false end
        local fresh, stale = {}, {}
        for _, item in ipairs(result.data) do
            item.coords = vector3(item.coords.x, item.coords.y, item.coords.z)
            item.shape = shapeKey(item)
            local old = items[item.uid]
            if old then
                local serverVersion = item.contentVersion
                item.can, item.canRev, item.strokes, item.contentVersion = old.can, old.canRev, old.strokes, old.contentVersion
                item.tools, item.limits, item.painter, item.fill = old.tools, old.limits, old.painter, old.fill
                if mounted[item.uid] and old.shape ~= item.shape then unmount(item.uid) end
                if not opts.rights and mounted[item.uid] == true and serverVersion ~= old.contentVersion then stale[#stale + 1] = item.uid end
            end
            fresh[item.uid] = item
        end
        for uid in pairs(items) do
            if not fresh[uid] then
                if active == uid then canvases.close() end
                unmount(uid)
                items[uid] = nil
            end
        end
        for uid, item in pairs(fresh) do items[uid] = item end
        for uid in pairs(mounted) do
            if mounted[uid] == true then addTarget(items[uid]) end
        end
        for _, uid in ipairs(stale) do CreateThread(function() canvases.resync(uid) end) end
        canvases.wake = true
        if opts.onList then opts.onList(items) end
        return true
    end

    -- One loop for every item; it sleeps long when nothing is close.
    CreateThread(function()
        local last
        while true do
            local pcoords = GetEntityCoords(PlayerPedId())
            if canvases.wake or not last or #(pcoords - last) > 1.0 then
                canvases.wake, last, nearest = false, pcoords, math.huge
                for uid, item in pairs(items) do
                    nearest = math.min(nearest, #(pcoords - item.coords))
                    if inside(item, pcoords) then
                        if not mounted[uid] then CreateThread(function() mount(uid) end) end
                    elseif mounted[uid] and uid ~= active then
                        unmount(uid)
                    end
                end
            end
            Wait((nearest < 60.0 or next(mounted)) and 500 or 2000)
        end
    end)

    -- Live deltas ----------------------------------------------------------

    function canvases.resync(uid)
        if not load(uid, true) then return end
        local item = items[uid]
        if mounted[uid] == true then Surface.replace(uid, item.strokes) end
        if active == uid then nui('canvas:replace', { uid = uid, strokes = item.strokes, contentVersion = item.contentVersion, fill = item.fill }) end
    end

    applyDelta = function(payload, fromServer)
        local item = type(payload) == 'table' and items[payload.uid]
        if not item then return end
        local pending = loading[item.uid]
        if pending then
            if #pending.deltas < BUFFER_MAX then pending.deltas[#pending.deltas + 1] = payload else pending.again = true end
            return
        end
        if not item.strokes then return end
        local current = item.contentVersion or 0
        if payload.contentVersion <= current then return end
        -- A restore swaps the whole board: everyone refetches, spread over a moment.
        if payload.op == 'restore' then return CreateThread(function() Wait(math.random(0, 1500)) canvases.resync(item.uid) end) end
        if payload.contentVersion ~= current + 1 then return CreateThread(function() canvases.resync(item.uid) end) end

        if payload.op == 'append' or payload.op == 'redo' then
            item.strokes[#item.strokes + 1] = payload.stroke
            if mounted[item.uid] == true then Surface.append(item.uid, payload.stroke) end
        elseif payload.op == 'undo' then
            table.remove(item.strokes)
            if mounted[item.uid] == true then Surface.replace(item.uid, item.strokes) end
        elseif payload.op == 'clear' then
            item.strokes = {}
            if mounted[item.uid] == true then Surface.clear(item.uid) end
        end
        item.contentVersion = payload.contentVersion
        if payload.fill then item.fill = payload.fill end
        if payload.strokeCount ~= #item.strokes then return CreateThread(function() canvases.resync(item.uid) end) end
        if fromServer and active == item.uid then nui('canvas:delta', payload) end
    end

    RegisterNetEvent(EVENT .. ':delta', function(payload) applyDelta(payload, true) end)

    -- Rights changed on the server (a student called up, the class opened, a lesson started or ended); an older push never
    -- wins. A painter who lost them stops here too: a student's claim that ran out had nobody to revoke it.
    RegisterNetEvent(EVENT .. ':can', function(uid, can, rev)
        local item = items[uid]
        rev = tonumber(rev) or 0
        if not item or type(can) ~= 'table' or rev < (item.canRev or 0) then return end
        item.can, item.canRev = can, rev
        if active == uid and claimed and not can.paint then
            claimed = false
            canvases.close()
            opts.notify('revoked', nil, 'inform')
        end
    end)

    -- The server ended this player's turn (taken over, rights gone): the paint view closes.
    RegisterNetEvent(EVENT .. ':revoked', function(uid, reason)
        if active ~= uid or not claimed then return end
        claimed = false
        canvases.close()
        opts.notify(reason or 'revoked', nil, 'inform')
    end)

    -- Boards changed: players near one ask within 3 s, everyone else at a random moment within 30 s.
    local refreshAt
    RegisterNetEvent(EVENT .. ':changed', function()
        local delay = (next(mounted) or nearest < 80.0) and math.random(0, 3000) or math.random(3000, 30000)
        local at = GetGameTimer() + delay
        if refreshAt and refreshAt <= at then return end
        refreshAt = at
        SetTimeout(delay, function()
            if refreshAt ~= at then return end
            refreshAt = nil
            canvases.refresh()
        end)
    end)

    -- Paint NUI ------------------------------------------------------------

    local function focusCamera(item)
        local rad = math.rad(item.heading)
        local normal = vector3(math.cos(rad), math.sin(rad), 0.0)
        local distance = math.max(1.0, math.max(item.width, item.height) * 1.3)
        local ped = GetEntityCoords(PlayerPedId())
        local front, back = item.coords + normal * distance, item.coords - normal * distance
        local pos = #(ped - front) < #(ped - back) and front or back
        camera = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 45.0, false, 2)
        pcall(function() exports['FeloxAC']:createCam(camera) end) --[[FeloxAC:auto]]
        PointCamAtCoord(camera, item.coords.x, item.coords.y, item.coords.z)
        SetCamActive(camera, true)
        RenderScriptCams(true, true, 800, true, false)
        Wait(850)
    end

    local function dropCamera()
        if not camera then return end
        RenderScriptCams(false, true, 800, true, false)
        pcall(function() exports['FeloxAC']:destroyCam(camera) end) --[[FeloxAC:auto]]
        DestroyCam(camera, false)
        camera = nil
    end

    -- Opens the paint view; painting needs the claim, otherwise it is read-only. Rights come fresh from the server.
    function canvases.open(uid, viewOnly)
        if not items[uid] or active then return end
        local loaded, reason = load(uid, false)
        if not loaded then return opts.notify(reason or 'integration_unavailable') end
        local item = items[uid]
        if not item then return end
        local can, painter = item.can or {}, item.painter
        claimed = false
        if not viewOnly and can.paint then
            local claim = await('claim', { uid = uid })
            claimed = claim.ok
            if not claim.ok then
                painter = claim.detail or painter
                opts.notify(claim.error, painter)
            end
        end

        active = uid
        focusCamera(item)
        opts.open({
            canvas = { uid = item.uid, label = item.label, width = item.width, height = item.height, background = item.background },
            strokes = item.strokes, tools = item.tools, limits = item.limits, fill = item.fill or 0,
            readOnly = not claimed, painter = painter, canManage = can.manage == true, canClear = can.clear == true,
            contentVersion = item.contentVersion, screenRect = screenRect(item, GetCamCoord(camera)),
        })
    end

    -- The UI goes first: a revoke must not yield while another resource takes focus.
    function canvases.close()
        if not active then return end
        local uid, held = active, claimed
        active, claimed = nil, false
        dropCamera()
        opts.close()
        if held then await('release', { uid = uid }) end
    end

    function canvases.active() return active end
    function canvases.mounted(uid) return mounted[uid] == true end

    -- Strokes are sent one at a time, in order; the NUI already shows them. The server's cleaned copy is kept.
    local queue, sending = {}, false

    local function sendQueue()
        if sending then return end
        sending = true
        CreateThread(function()
            while #queue > 0 do
                local entry = table.remove(queue, 1)
                local result = await('stroke', { uid = entry.uid, stroke = entry.stroke })
                local item = items[entry.uid]
                if result.ok and item and item.strokes then
                    local stroke = type(result.data.stroke) == 'table' and result.data.stroke or entry.stroke
                    item.strokes[#item.strokes + 1] = stroke
                    item.contentVersion, item.fill = result.data.contentVersion, result.data.fill or item.fill
                    Surface.commit(entry.uid, stroke)
                else
                    Surface.preview(entry.uid, 'clear')
                    if result.error == 'conflict' then opts.notify('conflict', result.detail) end
                end
                entry.cb(result)
            end
            sending = false
        end)
    end

    RegisterNUICallback('canvas:stroke', function(data, cb)
        if data.uid ~= active or not claimed then return cb({ ok = false, error = 'no_permission' }) end
        queue[#queue + 1] = { uid = data.uid, stroke = data.stroke, cb = cb }
        sendQueue()
    end)

    RegisterNUICallback('canvas:preview', function(data, cb)
        if data.uid == active and claimed then Surface.preview(data.uid, data.kind, data.stroke) end
        cb({ ok = true })
    end)

    for _, name in ipairs({ 'undo', 'redo' }) do
        RegisterNUICallback('canvas:' .. name, function(data, cb)
            local result = await(name, { uid = data.uid })
            if result.ok then applyDelta(result.data, false) end
            cb(result)
        end)
    end

    RegisterNUICallback('canvas:clear', function(data, cb)
        cb(await('clear', { uid = data.uid }))
    end)

    RegisterNUICallback('canvas:resync', function(data, cb)
        CreateThread(function() canvases.resync(data.uid) end)
        cb({ ok = true })
    end)

    RegisterNUICallback('canvas:close', function(_, cb)
        cb({ ok = true })
        canvases.close()
    end)

    -- Lifecycle ------------------------------------------------------------

    -- A random wait first: after a restart every client asks at once otherwise.
    local function boot()
        Wait(math.random(0, 4000))
        local delay = 1000
        while not canvases.refresh() do
            Wait(delay)
            delay = math.min(delay * 2, 15000)
        end
    end

    CreateThread(function()
        DL.fw.awaitLogin()
        boot()
    end)
    DL.fw.onLoaded(function() CreateThread(boot) end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= RESOURCE then return end
        dropCamera()
        for uid in pairs(mounted) do unmount(uid) end
    end)

    return canvases
end
