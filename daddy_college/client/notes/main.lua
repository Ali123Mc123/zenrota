-- Notebooks on the client: writing with the notebook in hand, reading pages and putting torn pages down.
if not Core.ModuleEnabled('notes') then return end

local cfg = Config.Notes
local world = cfg.World
local t = DL.locale.t
local placing = false
local pages = {}

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:notes:' .. name, false, data))
end

-- Size errors say the limit.
local function fail(result)
    if result.max then return Core.NotifyL('notes.' .. result.error, 'error', result.max) end
    Core.HandleResult(result, 'notes')
end

-- Views ----------------------------------------------------------------------------------------------

local function openNotebook(slot)
    local result = call('open', { slot = slot })
    if not result.ok then return fail(result) end
    result.slot = slot
    Core.Nui.Open('notes.editor', result)
    Core.Hold(cfg.Presentation)
end

-- slot is set when the page is read from the inventory; a page in the world can only be read.
local function openReader(noteId, slot)
    local result = call('read', { noteId = noteId })
    if not result.ok then return fail(result) end
    result.slot, result.editable = slot, result.editable and slot ~= nil
    Core.Nui.Open('notes.reader', result)
end

Core.Nui.OnClose('notes.editor', function()
    Core.Unhold()
    TriggerEvent('daddy_college:notes:closed') -- the desk view puts its camera back
end)

RegisterNetEvent('daddy_college:notes:useNotebook', function(slot)
    CreateThread(function() openNotebook(slot) end)
end)

RegisterNetEvent('daddy_college:notes:usePage', function(slot, noteId)
    if noteId then CreateThread(function() openReader(noteId, slot) end) end
end)

Core.Command(cfg.Commands.notebook, function() openNotebook(nil) end)

-- Putting a page down ----------------------------------------------------------------------------------

-- The view closes and the page follows the aim until it is put down or the player cancels.
local function place(token)
    if placing then return end
    placing = true
    local coords, heading = Core.PlaceOnSurface(world.PageModel, t('notes.placement_help'), world.PlaceDistance)
    placing = false
    if not coords then
        call('cancelPlacement', { token = token })
        if heading == 'model' then return Core.NotifyL('notes.placement_model', 'error') end
        return Core.NotifyL('notes.placement_cancelled', 'inform')
    end
    local result = call('confirmPlacement', { token = token, coords = { x = coords.x, y = coords.y, z = coords.z }, heading = heading })
    if result.ok then return end
    call('cancelPlacement', { token = token })
    fail(result)
end

local function placeLater(token)
    Core.Nui.Close()
    SetTimeout(200, function() place(token) end)
end

-- Editor and reader ----------------------------------------------------------------------------------

for _, name in ipairs({ 'loadPage', 'savePage', 'saveDetached', 'prepareTear' }) do
    Core.Nui.SafeCallback('notes:' .. name, function(data)
        local result = call(name, data)
        if not result.ok then fail(result) end
        return result
    end)
end

-- The editor tears the page out, plays the tear, then asks for the spot.
Core.Nui.SafeCallback('notes:startPlacement', function(data)
    if type(data.token) ~= 'string' then return { ok = false, error = 'validation' } end
    placeLater(data.token)
    return { ok = true }
end)

Core.Nui.SafeCallback('notes:preparePagePlacement', function(data)
    local result = call('preparePagePlacement', { slot = data.slot })
    if not result.ok then
        fail(result)
        return result
    end
    placeLater(result.token)
    return result
end)

-- A torn page opens in the editor as a notebook of one page; saves go to saveDetached.
Core.Nui.SafeCallback('notes:editDetached', function(data)
    local result = call('read', { noteId = data.noteId })
    if not result.ok then
        fail(result)
        return result
    end
    local page = { id = data.noteId, order = 1, revision = result.revision, hasContent = true, preview = '' }
    Core.Nui.Open('notes.editor', {
        detached = true, noteId = data.noteId, slot = data.slot, pages = { page },
        active = { id = data.noteId, order = 1, revision = result.revision, content = result.content },
        limits = result.limits, tools = result.tools, presentation = result.presentation, images = result.images,
    })
    Core.Hold(cfg.Presentation)
    return { ok = true }
end)

Core.Nui.SafeCallback('notes:delete', function(data)
    local result = call('delete', { noteId = data.noteId })
    if result.ok then Core.Nui.Close() else fail(result) end
    return result
end)

-- Pages lying around ---------------------------------------------------------------------------------

local function take(noteId)
    local result = call('take', { noteId = noteId })
    if not result.ok then fail(result) end
end

local function anchor(noteId, spot)
    return {
        uid = 'note:' .. noteId, presentation = 'prop', model = world.PageModel, revision = 1,
        coords = { x = spot.x, y = spot.y, z = spot.z, w = spot.heading }, streamDistance = world.StreamDistance, distance = world.TargetDistance,
        options = {
            { name = 'note_read', label = t('notes.target_read'), icon = 'fa-solid fa-note-sticky', distance = world.TargetDistance,
                onSelect = function() CreateThread(function() openReader(noteId) end) end },
            { name = 'note_take', label = t('notes.target_take'), icon = 'fa-solid fa-file-lines', distance = world.TargetDistance,
                onSelect = function() CreateThread(function() take(noteId) end) end },
        },
    }
end

-- Every page in the world; the whole set is handed to the anchors so none is left behind.
local function show()
    local defs = {}
    for noteId, spot in pairs(pages) do
        if type(spot) == 'table' then defs[#defs + 1] = anchor(noteId, spot) end
    end
    Core.World.anchors.sync('notes', defs)
end

RegisterNetEvent('daddy_college:notes:all', function(list)
    pages = type(list) == 'table' and list or {}
    show()
end)

RegisterNetEvent('daddy_college:notes:world', function(noteId, spot)
    pages[noteId] = spot
    show()
end)

Core.OnLogin(function()
    pages = lib.callback.await('daddy_college:notes:getWorld', false) or {}
    show()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('notes') end
end)
