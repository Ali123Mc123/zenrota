-- Campus Life on the client: one world snapshot, a target on every place and the calls to the server.
-- What the options show is only a hint; the server decides every action.
local t = DL.locale.t
Campus = { world = World.client() }
local kinds = {}

function Campus.call(name, data)
    return Nui.result(lib.callback.await('daddy_campuslife:' .. name, false, data or {}))
end

-- A failed answer as a notice: each code has its text under campus.<code>; its value fills the text.
function Campus.fail(result)
    local key = 'campus.' .. (result and result.error or 'unavailable')
    if t(key) == key then key = 'campus.unavailable' end
    Nui.notify(key, 'error', result and (result.price or result.item or result.opens))
end

function Campus.free()
    return not Nui.isOpen() and not IsPedInAnyVehicle(cache.ped, false) and not IsEntityDead(cache.ped) and not LocalPlayer.state.campusSeat
end

-- Each kind gives the options of one place: Campus.kind('chair', function(record) return { options = {...} } end).
function Campus.kind(kind, build) kinds[kind] = build end

Campus.world.subscribe(function()
    for kind, build in pairs(kinds) do
        local defs = {}
        for _, record in ipairs(Campus.world.entities({ kind = kind })) do
            local def = build(record)
            if def then
                def.uid, def.label, def.coords, def.revision = ('%s:%s'):format(kind, record.uid), record.label, record.coords, record.revision
                def.presentation, def.model, def.scenario = record.presentation, record.model, record.scenario
                def.shape, def.distance = DL.geo.fromRecord(record), def.distance or 2.0
                defs[#defs + 1] = def
            end
        end
        Campus.world.anchors.sync(kind, defs)
    end
end)

-- The ped or prop the world spawned for a place, when it is near.
function Campus.entity(kind, uid) return Campus.world.anchors.entity(('%s:%s'):format(kind, uid)) end
