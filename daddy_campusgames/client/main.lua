-- Campus Games on the client: one world snapshot, a target on every game place and the calls to the server.
-- What the options show is only a hint; the server decides every action.
local t = DL.locale.t
Games = { world = World.client() }
local kinds = {}

function Games.call(name, data)
    return Nui.result(lib.callback.await('daddy_campusgames:' .. name, false, data or {}))
end

-- A failed answer as a notice: each code has its text under games.<code>.
function Games.fail(result)
    local key = 'games.' .. (result and result.error or 'unavailable')
    if t(key) == key then key = 'games.unavailable' end
    Nui.notify(key, 'error')
end

function Games.free()
    return not Nui.isOpen() and not IsPedInAnyVehicle(cache.ped, false) and not IsEntityDead(cache.ped)
end

-- Each kind gives the target of one place: Games.kind('dart_board', function(record) return { options = {...} } end).
function Games.kind(kind, build) kinds[kind] = build end

-- Places of a kind: the ones placed with /gamesadmin and the ones set up from items (the server's GlobalState).
-- Kept per kind until the world snapshot or the portable list changes: the stream loops ask every second, and reading
-- GlobalState decodes the whole list each time. The lists are shared, so callers only read them.
local placesOf, portables = {}, nil
function Games.places(kind)
    local out = placesOf[kind]
    if out then return out end
    out = {}
    for _, record in ipairs(Games.world.entities({ kind = kind })) do out[#out + 1] = record end
    if portables == nil then portables = GlobalState['daddy_campusgames:portable'] or false end
    for _, record in pairs(portables or {}) do
        if record.kind == kind then out[#out + 1] = record end
    end
    placesOf[kind] = out
    return out
end
-- registered before sync below, so sync already reads the new snapshot
Games.world.subscribe(function() placesOf = {} end)
AddStateBagChangeHandler('daddy_campusgames:portable', 'global', function(_, _, value)
    portables, placesOf = value or false, {}
end)

local function firstModel(list)
    for _, name in ipairs(list or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

-- A place set up from an item: its prop, a target on a sphere (small props have no collision) and, for the owner,
-- the option to take it back while no game is on.
local function portable(record, def)
    local model = firstModel((Config.Items.Setup[record.portable.game] or {}).models)
    if model then def.presentation, def.model = 'prop', model end
    def.targetSphere = def.targetSphere or { radius = 1.0, height = 0.6 }
    def.options = def.options or {}
    def.options[#def.options + 1] = {
        name = 'party_take', label = t('games.party_take'), icon = 'fa-solid fa-hand',
        canInteract = function()
            return record.portable.owner == cache.serverId and not (GlobalState['daddy_campusgames:venues'] or {})[record.uid]
        end,
        onSelect = function() CreateThread(function()
            local result = Games.call('portable:take')
            if not result.ok then Games.fail(result) end
        end) end,
    }
end

local function sync()
    for kind, build in pairs(kinds) do
        local defs = {}
        for _, record in ipairs(Games.places(kind)) do
            local def = build(record)
            if def and record.portable then portable(record, def) end
            if def then
                def.uid, def.label, def.coords, def.revision = ('%s:%s'):format(kind, record.uid), record.label, record.coords, record.revision
                def.presentation, def.model = def.presentation or record.presentation, def.model or record.model
                def.shape, def.distance = DL.geo.fromRecord(record), def.distance or 2.0
                def.streamDistance = def.streamDistance or Config.StreamDistance
                defs[#defs + 1] = def
            end
        end
        Games.world.anchors.sync(kind, defs)
    end
end
Games.world.subscribe(sync)

-- The prop pack can start after this resource: the places pick their models again once it is up.
AddEventHandler('onClientResourceStart', function(resource)
    if resource == Config.Bottle.PropPack then SetTimeout(500, sync) end
end)

-- A place set up or taken back somewhere (read once the new value is in).
AddStateBagChangeHandler('daddy_campusgames:portable', 'global', function() SetTimeout(50, sync) end)
function Games.resync() sync() end

-- The prop the world spawned for a place, when it is near.
function Games.entity(kind, uid) return Games.world.anchors.entity(('%s:%s'):format(kind, uid)) end

-- Overlays: a view shown without taking the mouse or the keys (score strips, the card the ring sees).
-- Only one at a time, and never over a view the player opened.
local overlay
function Games.overlay(view, payload, seconds)
    if Nui.isOpen() then return end
    if overlay == view then return SendNUIMessage({ action = 'overlay', data = payload }) end
    overlay = view
    SendNUIMessage({ action = 'open', view = view, payload = payload, locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme })
    if seconds then SetTimeout(seconds * 1000, function() Games.hideOverlay(view) end) end
end

function Games.hideOverlay(view)
    if overlay ~= view then return end
    overlay = nil
    if not Nui.isOpen() then SendNUIMessage({ action = 'close' }) end
end

function Games.overlayShown(view) return overlay == view and not Nui.isOpen() end

-- A view the player opens takes the page's one view slot, so the overlay goes with it and opens again after.
local open, close = Nui.open, Nui.close
function Nui.open(...)
    open(...)
    overlay = nil
end
function Nui.close()
    if Nui.isOpen() then overlay = nil end
    close()
end

RegisterNetEvent('daddy_campusgames:notify', function(key, kind, ...) Nui.notify(key, kind, ...) end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for kind in pairs(kinds) do Games.world.anchors.clear(kind) end
end)
