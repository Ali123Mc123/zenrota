-- The NUI side of the place editor for setup panels built on @daddy/college-kit (ShapeField, PlacementHud):
-- callbacks world:startPlacement, world:playerCoords and world:debug; messages world:placementHud, world:placementResult.
--   local editor = World.editor({ canStart = fn, suspend = fn, resume = fn, records = fn -> { entities, zones },
--                                 color = { r, g, b }, maxPoints = 32, reach = 150 })
World = World or {}

local function send(action, data) SendNUIMessage({ action = action, data = data }) end

-- Fields on top and in data, as the kit reads both.
local function answer(fields)
    local data = {}
    for key, value in pairs(fields) do data[key] = value end
    fields.ok, fields.data = true, data
    return fields
end

function World.editor(opts)
    local editor = { debug = false, focused = nil }
    local color = opts.color or World.draw.colors.valid

    -- Gold is the record the panel points at, red an inactive one, the panel colour the rest. Behind the place
    -- editor every place within reach shows faintly.
    local function drawAll(faint)
        local records = opts.records() or {}
        local camera = GetFinalRenderedCamCoord()
        for _, list in ipairs({ records.zones or {}, records.entities or {} }) do
            for _, record in ipairs(list) do
                local shape = DL.geo.fromRecord(record)
                local middle = shape and DL.geo.centroid(shape)
                if middle and (not faint or #(vector3(middle.x, middle.y, middle.z or camera.z) - camera) < 200.0) then
                    local focused = not faint and record.uid == editor.focused
                    World.draw.shape(shape, {
                        color = focused and World.draw.colors.focused or not record.active and World.draw.colors.inactive or color,
                        focused = focused, faint = faint, label = ('%s (%s)'):format(record.label ~= '' and record.label or record.kind, record.uid),
                    })
                end
            end
        end
    end

    function editor.setDebug(enabled, uid)
        local wasOn = editor.debug
        editor.debug, editor.focused = enabled == true, uid
        if not editor.debug or wasOn then return end
        CreateThread(function()
            while editor.debug do
                if IsEntityDead(cache.ped) then editor.debug = false end
                drawAll()
                Wait(0)
            end
        end)
    end

    function editor.stop()
        World.placement.cancel()
        editor.setDebug(false)
    end

    -- Pointing at a record turns the view on; pointing at it again turns it off.
    RegisterNUICallback('world:debug', function(data, cb)
        data = type(data) == 'table' and data or {}
        local uid = data.focusedUid
        if uid and uid == editor.focused and data.toggleFocus then editor.setDebug(false)
        else editor.setDebug(uid ~= nil or data.enabled == true, uid) end
        cb(answer({ enabled = editor.debug, focusedUid = editor.focused }))
    end)

    RegisterNUICallback('world:playerCoords', function(_, cb)
        local p = GetEntityCoords(cache.ped)
        cb(answer({ x = p.x, y = p.y, z = p.z, w = GetEntityHeading(cache.ped) }))
    end)

    RegisterNUICallback('world:startPlacement', function(data, cb)
        data = type(data) == 'table' and data or {}
        if opts.canStart and not opts.canStart() then return cb({ ok = false, error = 'conflict' }) end
        editor.setDebug(false)
        local requestId = tostring(data.requestId or GetGameTimer())
        local started = World.placement.start({
            shape = data.shape, presentation = data.presentation, model = data.model, scenario = data.scenario, label = data.label,
            heading = tonumber(data.heading), existing = data.existing, batch = data.batch == true, maxPoints = opts.maxPoints,
            reach = opts.reach, color = color, backdrop = function() drawAll(true) end,
        }, {
            hud = function(hud) send('world:placementHud', hud) end,
            done = function(result)
                if opts.resume then opts.resume() end
                send('world:placementResult', result and { ok = true, data = result, requestId = requestId } or { ok = false, error = 'cancelled', requestId = requestId })
            end,
        })
        if not started then return cb({ ok = false, error = 'conflict' }) end
        if opts.suspend then opts.suspend() end
        cb(answer({ started = true }))
    end)

    return editor
end
