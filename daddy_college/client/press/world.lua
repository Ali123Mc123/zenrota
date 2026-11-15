-- Newspaper things in the world: stacks and dropped copies (local props that follow the server's list) and the
-- newsroom desks placed with /collegeadmin.
if Config.Modules.press == false or not Config.Press then return end

local cfg = Config.Press
local t = DL.locale.t
local Press = Core.Press
local copies = {}

local function stackModel()
    if IsModelInCdimage(joaat(cfg.Models.Stack)) then return cfg.Models.Stack end
    return cfg.Models.StackFallback
end

local function take(id)
    local result = Press.call('take', { stackId = id })
    if not result.ok then Press.fail(result) end
end

local function fill(id)
    local result = Press.call('fill', { stackId = id })
    if not result.ok then Press.fail(result) end
end

local function placedBy(id)
    local result = Press.call('placedBy', { stackId = id })
    if not result.ok then Press.fail(result) end
end

-- What a stack or a rack holding one offers: read, take one, fill it up, and for staff who put it there.
local function optionsOf(id, spot)
    local options = {
        { name = 'press_read', label = t('press.target_read'), icon = 'fa-solid fa-newspaper', distance = cfg.TargetDistance,
            canInteract = function() return not Core.Nui.IsOpen() end,
            onSelect = function() CreateThread(function() Press.openReader(nil, nil, id) end) end },
        { name = 'press_take', label = spot.stock and t('press.target_take_left', spot.stock) or t('press.target_take'), icon = 'fa-solid fa-hand', distance = cfg.TargetDistance,
            onSelect = function() CreateThread(function() take(id) end) end },
    }
    if spot.stock then
        options[#options + 1] = { name = 'press_fill', label = t('press.target_fill'), icon = 'fa-solid fa-box-open', distance = cfg.TargetDistance,
            onSelect = function() CreateThread(function() fill(id) end) end }
    end
    if Core.IsTeacher() or Core.IsAdmin() then
        options[#options + 1] = { name = 'press_who', label = t('press.target_who'), icon = 'fa-solid fa-user-secret', distance = cfg.TargetDistance,
            onSelect = function() CreateThread(function() placedBy(id) end) end }
    end
    return options
end

local function anchor(id, spot)
    local loose = spot.kind == 'loose'
    return {
        uid = 'press:' .. id, presentation = 'prop', model = loose and cfg.Models.Loose or stackModel(), revision = spot.stock or 1,
        coords = { x = spot.x, y = spot.y, z = spot.z, w = spot.heading }, streamDistance = cfg.StreamDistance, distance = cfg.TargetDistance,
        options = optionsOf(id, spot),
    }
end

-- The racks: the stand (Models.Rack) always stands on its spot, on the floor; the copies of the issue at it are taken
-- from the stand itself (no pile of papers on top). An empty stand only says so.
local function settle(_, entity)
    if not entity or not DoesEntityExist(entity) then return end
    FreezeEntityPosition(entity, false)
    PlaceObjectOnGroundProperly(entity)
    FreezeEntityPosition(entity, true)
end

local function racks()
    local atRack = {}
    for id, spot in pairs(copies) do
        if type(spot) == 'table' and spot.rack and spot.kind ~= 'loose' then atRack[spot.rack] = id end
    end
    local defs = {}
    for _, spot in ipairs(Core.World.entities({ kind = 'press_rack' })) do
        local id = atRack[spot.uid]
        local stack = id and copies[id]
        local options = stack and optionsOf(id, stack) or { {
            name = 'press_rack_empty', label = t('press.target_rack_empty'), icon = 'fa-solid fa-newspaper', distance = cfg.TargetDistance,
            canInteract = function() return true end, onSelect = function() end,
        } }
        defs[#defs + 1] = {
            uid = 'pressrack:' .. spot.uid, label = spot.label, coords = spot.coords, presentation = 'prop',
            model = (spot.model or '') ~= '' and spot.model or cfg.Models.Rack or 'prop_news_disp_01a',
            revision = ('%s:%s:%s'):format(spot.revision or 1, id or 0, stack and stack.stock or 0),
            streamDistance = spot.streamDistance or cfg.StreamDistance, distance = cfg.TargetDistance,
            options = options, onSpawn = settle,
        }
    end
    Core.World.anchors.sync('pressrack', defs)
end

local function show()
    local defs = {}
    for id, spot in pairs(copies) do
        -- A stack at a rack is drawn by the rack's stand.
        if type(spot) == 'table' and not (spot.rack and spot.kind ~= 'loose') then defs[#defs + 1] = anchor(id, spot) end
    end
    Core.World.anchors.sync('press', defs)
    racks()
end

RegisterNetEvent('daddy_college:press:all', function(list)
    copies = type(list) == 'table' and list or {}
    show()
end)

RegisterNetEvent('daddy_college:press:world', function(id, spot)
    copies[id] = spot
    show()
end)

-- The desks: a prop with the desk's own option.
local function desks()
    local defs = {}
    for _, spot in ipairs(Core.World.entities({ kind = 'press_desk' })) do
        local reach = spot.interactDistance or 2.0
        defs[#defs + 1] = {
            uid = 'pressdesk:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision, presentation = 'prop',
            model = (spot.model or '') ~= '' and spot.model or cfg.Models.Desk, streamDistance = spot.streamDistance, distance = reach,
            options = { {
                name = 'press_desk', label = t('press.target_desk'), icon = 'fa-solid fa-pen-nib', distance = reach,
                canInteract = function() return not Core.Nui.IsOpen() end,
                onSelect = function() CreateThread(Press.openDesk) end,
            } },
        }
    end
    Core.World.anchors.sync('pressdesk', defs)
end

Core.World.subscribe(desks)
Core.World.subscribe(racks)

Core.OnLogin(function()
    copies = lib.callback.await('daddy_college:press:getWorld', false) or {}
    show()
end)

-- Roles changed: the staff option comes and goes.
AddEventHandler('daddy_college:rolesChanged', show)

-- The racks on the map for a while, coloured by how many copies they hold: red empty, yellow low, green full.
local blips = {}
local function clearBlips()
    for _, blip in ipairs(blips) do RemoveBlip(blip) end
    blips = {}
end

Core.Nui.SafeCallback('press:showRacks', function()
    local result = Press.call('racks')
    if not result.ok then Press.fail(result) return result end
    clearBlips()
    for _, rack in ipairs(result.data.racks or {}) do
        local blip = AddBlipForCoord(rack.x, rack.y, rack.z)
        SetBlipSprite(blip, 590)
        SetBlipScale(blip, 0.75)
        SetBlipColour(blip, rack.stock == 0 and 1 or (rack.stock < rack.max / 2 and 5 or 2))
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(t('press.blip_rack', rack.stock, rack.max))
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
    SetTimeout(600000, clearBlips)
    return result
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    Core.World.anchors.clear('press')
    Core.World.anchors.clear('pressdesk')
    Core.World.anchors.clear('pressrack')
    clearBlips()
end)
