-- The client of a World.admin panel: opening, the panel's calls and the place editor with a 3D view of the
-- saved places. NUI 'admin:<name>' goes to the server's admin callback <name>. The view manager is the kit's
-- Nui (packages/kit/nui.lua) unless the product passes its own with the same calls as opts.nui.
--   World.panel({ view = 'campus.admin', calls = { 'saveItem', 'removeItem' }, reach = 150 })
World = World or {}

local CALLS = { 'bootstrap', 'history', 'saveEntity', 'saveEntities', 'saveZone', 'setActive', 'remove', 'rollback' }

function World.panel(opts)
    local nui = opts.nui or Nui
    local event = GetCurrentResourceName() .. ':admin'
    local records = { entities = {}, zones = {} }
    local panel = {}

    -- A server answer, or nothing when the call failed (the view then shows unavailable).
    function panel.call(name, data)
        local ok, result = pcall(lib.callback.await, ('%s:%s'):format(event, name), false, data or {})
        return nui.result(ok and result or nil)
    end

    -- The panel's places are kept for the 3D view (inactive ones too).
    local function bootstrap()
        local result = panel.call('bootstrap')
        if result.ok then records = { entities = result.entities or {}, zones = result.zones or {} } end
        return result
    end

    local editor = World.editor({
        canStart = function() return nui.isOpen(opts.view) end,
        suspend = nui.suspend, resume = nui.resume,
        records = function() return records end,
        color = World.draw.rgb(Config.Theme.accent), maxPoints = opts.maxPoints or 1, reach = opts.reach,
    })

    -- The world editor: the same places, edited in the world with the page as a dock.
    local worldedit = World.worldedit({
        call = panel.call, records = function() return records end, send = nui.send, suspend = nui.suspend, resume = nui.resume,
        canStart = function() return nui.isOpen(opts.view) end, color = World.draw.rgb(Config.Theme.accent),
        maxPoints = opts.maxPoints or 1, reach = opts.reach,
    })

    RegisterNetEvent(event .. ':open', function()
        local result = bootstrap()
        if not result.ok then return nui.notify('kit.no_permission', 'error') end
        nui.open(opts.view, result)
    end)

    RegisterNetEvent(event .. ':invalidate', function(message)
        if not nui.isOpen(opts.view) then return end
        nui.send('admin:invalidate', message)
        if worldedit.active() then bootstrap() end
    end)

    RegisterNUICallback('admin:bootstrap', function(_, cb) cb(bootstrap()) end)
    for _, list in ipairs({ CALLS, opts.calls or {} }) do
        for _, name in ipairs(list) do
            if name ~= 'bootstrap' then
                RegisterNUICallback('admin:' .. name, function(data, cb) cb(panel.call(name, data)) end)
            end
        end
    end

    nui.onClose(opts.view, function()
        worldedit.stop()
        editor.stop()
        TriggerServerEvent(event .. ':close')
    end)

    return panel
end
