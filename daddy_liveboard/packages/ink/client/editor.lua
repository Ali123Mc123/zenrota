-- Ink editor bridge (6-tahta-video-sanat.md 3.2, 3.4): the NUI editor on one board at a time. The camera faces the
-- board so it takes at most 80 % of the screen's width and 72 % of its height (the dock stays clear of it); the
-- board's four corners go to the NUI, which lays the page exactly on them, and the board's own page in the world hides
-- its ink meanwhile. Ops from the NUI go into the outbox, live chunks to the server (5 a second at most); pushes,
-- roles, refusals and the outbox's count come back. Every NUI call carries the session's token (a token stays good
-- 5 s after a close, so the last ops still go). The editor closes on Esc, death, a vehicle, walking away (reach + 2 m),
-- a teleport and the board going; the product closes it when focus is taken or the character changes. The page's
-- baked tiles (P3) come by hash when the NUI asks (ink:tiles); a bake while it is open is folded there (ink:fold).
--   local editor = Ink.editor(client, { show = function(payload, board) end, hide = function(reason) end, reach = function(board) end })
Ink = Ink or {}

function Ink.editor(client, opts)
    local codec, rules = Ink.codec, Ink.rules
    local E = client.event
    local CHUNK = 300
    local ed = {}
    local session, opening, last = nil, false, nil

    local function token()
        local out = {}
        for i = 1, 16 do out[i] = string.char(math.random(97, 122)) end
        return table.concat(out)
    end

    local function nui(action, data)
        SendNUIMessage({ action = action, data = data })
    end

    -- Camera and corners --------------------------------------------------------------------------------------

    local function focus(b)
        local fov = opts.fov or 50.0
        local rad = math.rad(b.heading)
        local tanHalf = math.tan(math.rad(fov) * 0.5)
        local aspect = GetAspectRatio(false)
        local dist = math.max(0.6, b.height / (2.0 * tanHalf * (opts.fillHeight or 0.72)),
            b.width / (2.0 * tanHalf * aspect * (opts.fillWidth or 0.8)))
        local pos = b.coords + vector3(math.cos(rad), math.sin(rad), 0.0) * dist
        local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, fov, false, 2)
        pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
        PointCamAtCoord(cam, b.coords.x, b.coords.y, b.coords.z)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, false)
        local t = GetGameTimer()
        repeat Wait(50) until not IsCamInterpolating(cam) or GetGameTimer() - t > 1500
        Wait(0)
        return cam
    end

    -- The board's ink face on screen (0..1): p1 top-left, p2 top-right, p3 bottom-left, p4 bottom-right.
    local function corners(b)
        local rad = math.rad(b.heading)
        local nx, ny = math.cos(rad), math.sin(rad)
        local rx, ry = math.cos(rad + math.pi / 2), math.sin(rad + math.pi / 2)
        local cx, cy, cz = b.coords.x + nx * 0.005, b.coords.y + ny * 0.005, b.coords.z
        local hw, hh = b.width * 0.5, b.height * 0.5
        local pts = {
            { cx - rx * hw, cy - ry * hw, cz + hh }, { cx + rx * hw, cy + ry * hw, cz + hh },
            { cx - rx * hw, cy - ry * hw, cz - hh }, { cx + rx * hw, cy + ry * hw, cz - hh },
        }
        local out = {}
        for i, p in ipairs(pts) do
            local seen, x, y = GetScreenCoordFromWorldCoord(p[1], p[2], p[3])
            if not seen then return nil end
            out['p' .. i] = { x = x, y = y }
        end
        return out
    end

    local function dropCamera(cam)
        if not cam then return end
        RenderScriptCams(false, true, 500, true, false)
        pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
        DestroyCam(cam, false)
    end

    -- Open and close -------------------------------------------------------------------------------------------

    local watch

    -- Opens the editor on a board (readOnly: to look only; studio: the page full screen without the camera, Art
    -- Studio). Waits up to 4 s for the board's page. true or false, why.
    function ed.open(uid, readOnly, studio)
        if session or opening then return false, 'busy' end
        local b = client.boards[uid]
        if not b then return false, 'not_found' end
        opening = true
        -- a mounted board whose page the server let go (past the pages one player may follow) is opened again
        if not client.mounted[uid] then
            client.mount(uid)
        elseif not (client.model(uid) or {}).open then
            client.open(uid, true)
        end
        local t, m = GetGameTimer(), client.model(uid)
        while not (m and m.open) and GetGameTimer() - t < 4000 do
            Wait(100)
            m = client.model(uid)
        end
        if not (m and m.open) or not client.boards[uid] then
            opening = false
            return false, 'not_ready'
        end
        local s = { uid = uid, page = m.id, token = token(), readOnly = readOnly == true, studio = studio == true }
        if not s.studio then s.cam = focus(b) end
        local ops, first = m.ops, {}
        for i = 1, math.min(#ops, CHUNK) do first[i] = ops[i] end
        local payload = {
            token = s.token,
            board = { uid = uid, label = b.label or uid, width = b.width, height = b.height },
            page = { page = m.id, e = m.e, rev = m.rev, clear = m.clear, me = m.me, ops = first, base = m.base },
            more = #ops > CHUNK, role = m.role or false, readOnly = s.readOnly, screen = s.cam and corners(b) or nil, studio = s.studio,
            tools = opts.tools and opts.tools(b) or nil, raster = opts.raster or 2048,
        }
        session, opening = s, false
        client.surfaces.editing(uid, true)
        opts.show(payload, b)
        if #ops > CHUNK then
            -- The rest one chunk a frame; the snapshot is the page now (pushes after it come behind it).
            local rest = {}
            for i = CHUNK + 1, #ops do rest[#rest + 1] = ops[i] end
            CreateThread(function()
                for i = 1, #rest, CHUNK do
                    if session ~= s then return end
                    nui('ink:chunk', { page = s.page, ops = table.move(rest, i, math.min(#rest, i + CHUNK - 1), 1, {}), done = i + CHUNK > #rest })
                    Wait(0)
                end
            end)
        end
        local n, state = client.outbox.count(s.page)
        nui('ink:outbox', { page = s.page, n = n, state = state })
        watch(s)
        return true
    end

    function ed.close(reason)
        local s = session
        if not s then return end
        session = nil
        last = { token = s.token, page = s.page, untilMs = GetGameTimer() + 5000 }
        client.surfaces.editing(s.uid, false)
        local ok, err = pcall(opts.hide, reason)
        if not ok then print(('[ink] closing the editor failed: %s'):format(tostring(err))) end
        dropCamera(s.cam)
    end

    function ed.active() return session and session.uid or nil end
    function ed.holds(uid) return session ~= nil and session.uid == uid end

    -- Death, a vehicle, walking away, a teleport or the board going close it.
    watch = function(s)
        CreateThread(function()
            local before = GetEntityCoords(PlayerPedId())
            while session == s do
                Wait(200)
                if session ~= s then return end
                local ped = PlayerPedId()
                local here = GetEntityCoords(ped)
                local b = client.boards[s.uid]
                local why
                if not b then
                    why = 'gone'
                elseif IsEntityDead(ped) then
                    why = 'dead'
                elseif IsPedInAnyVehicle(ped, true) then
                    why = 'vehicle'
                elseif #(here - before) > 8.0 then
                    why = 'teleport'
                elseif #(here - b.coords) > (opts.reach and opts.reach(b) or 6.0) + 2.0 then
                    why = 'away'
                end
                before = here
                if why then return ed.close(why) end
            end
        end)
    end

    -- From the client ------------------------------------------------------------------------------------------

    local function mine(m) return session ~= nil and m ~= nil and m.id == session.page end

    function ed.push(m, p)
        if mine(m) then nui('ink:push', { page = m.id, rev = p.rev, ops = p.ops, live = p.live, laser = p.laser }) end
    end

    -- The board shows another page now (P4 page strip): the editor follows it.
    function ed.moved(uid, m)
        if not session or session.uid ~= uid or session.page == m.id then return end
        session.page = m.id
        nui('ink:switch', { page = m.id, e = m.e, rev = m.rev, clear = m.clear, me = m.me, ops = m.ops, role = m.role or false, base = m.base })
        local n, state = client.outbox.count(m.id)
        nui('ink:outbox', { page = m.id, n = n, state = state })
    end

    -- The page the editor shows (the product's own NUI calls check it), or nil.
    function ed.page() return session and session.page or nil end
    function ed.token() return session and session.token or nil end

    -- The page came again: replaced (another epoch) means the editor loads it again; the role may have moved.
    function ed.state(m, replaced)
        if not mine(m) then return end
        if replaced then nui('ink:reload', { page = m.id, e = m.e, rev = m.rev, clear = m.clear, me = m.me, ops = m.ops, base = m.base }) end
        nui('ink:role', { page = m.id, role = m.role or false })
    end

    -- A bake (P3): the editor folds the ops up to upTo into its ground, as the page in the world does.
    function ed.baked(m, upTo)
        if mine(m) then nui('ink:fold', { page = m.id, upTo = upTo, base = m.base }) end
    end

    function ed.role(m, role)
        if mine(m) then nui('ink:role', { page = m.id, role = role or false }) end
    end

    function ed.dropped(page, cks, code, extra)
        if session and session.page == page then nui('ink:dropped', { page = page, cks = cks, code = code, extra = extra }) end
        if opts.onDrop then opts.onDrop(page, cks, code, extra) end
    end

    function ed.count(page, n, state)
        if session and session.page == page then nui('ink:outbox', { page = page, n = n, state = state }) end
    end

    -- NUI ----------------------------------------------------------------------------------------------------

    -- The session the token names (or the one just closed, for its last ops).
    local function sessionOf(data)
        if type(data) ~= 'table' then return nil end
        if session and data.token == session.token and tonumber(data.page) == session.page then return session end
        if last and data.token == last.token and tonumber(data.page) == last.page and GetGameTimer() < last.untilMs then return last end
        return nil
    end

    RegisterNUICallback('ink:ops', function(data, cb)
        cb({})
        local s = sessionOf(data)
        if s and type(data.ops) == 'table' then client.outbox.add(s.page, data.ops) end
    end)

    RegisterNUICallback('ink:live', function(data, cb)
        cb({})
        local s = session and sessionOf(data) == session and session or nil
        if not s or not codec.isKey(data.ck) or type(data.d) ~= 'string' or #data.d > rules.CLIENT.LIVE_BYTES then return end
        local t = GetGameTimer()
        if t - (s.liveAt or 0) < 180 then return end
        s.liveAt = t
        TriggerServerEvent(E .. ':live', s.page, data.ck, data.d)
    end)

    -- The baked tiles of the page the editor shows, by sha256 (16 a call): what came within 20 s.
    local blobs = Ink.blobClient and Ink.blobClient(E)
    RegisterNUICallback('ink:tiles', function(data, cb)
        local s = sessionOf(data)
        if not s or not blobs or type(data.hashes) ~= 'table' then return cb({ tiles = {} }) end
        local list = {}
        for i = 1, math.min(#data.hashes, 16) do
            local hash = data.hashes[i]
            if type(hash) == 'string' and #hash == 64 then list[#list + 1] = hash end
        end
        blobs.fetch(list, function(map) cb({ tiles = map }) end, 20000)
    end)

    RegisterNUICallback('ink:close', function(data, cb)
        cb({})
        if session and type(data) == 'table' and data.token == session.token then ed.close('esc') end
    end)

    -- Studio mode and back: 'world' turns the camera to the board and answers its corners, 'studio' lets it go.
    RegisterNUICallback('ink:view', function(data, cb)
        local s = session and sessionOf(data) == session and session or nil
        local b = s and client.boards[s.uid]
        if not b then return cb({}) end
        if data.view == 'world' and not s.cam then
            s.cam = focus(b)
        elseif data.view == 'studio' and s.cam then
            dropCamera(s.cam)
            s.cam = nil
        end
        if session ~= s then return cb({}) end
        cb({ screen = s.cam and corners(b) or nil })
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() or not session then return end
        local cam = session.cam
        session = nil
        if cam then
            RenderScriptCams(false, false, 0, true, false)
            pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
            DestroyCam(cam, false)
        end
    end)

    client.editor = ed
    return ed
end

return Ink.editor
