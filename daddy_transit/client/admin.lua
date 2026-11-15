-- The stops panel on the client: its calls, the place editor and a 3D view of the stops.
local VIEW = 'transit.admin'
local records = { entities = {}, zones = {} }

local function call(name, data)
    return Nui.result(lib.callback.await('daddy_transit:admin:' .. name, false, data or {}))
end

local function bootstrap()
    local result = call('bootstrap')
    if result.ok then records = { entities = result.stops or {}, zones = {} } end
    return result
end

local editor = World.editor({
    canStart = function() return Nui.isOpen(VIEW) end,
    suspend = Nui.suspend, resume = Nui.resume,
    records = function() return records end,
    color = World.draw.rgb(Config.Theme.accent), maxPoints = 1, reach = Config.Admin.PlacementReach,
})

RegisterNetEvent('daddy_transit:admin:open', function()
    local result = bootstrap()
    if not result.ok then return Nui.notify('transit.no_permission', 'error') end
    Nui.open(VIEW, result)
end)

RegisterNetEvent('daddy_transit:admin:invalidate', function(message)
    if Nui.isOpen(VIEW) then Nui.send('admin:invalidate', message) end
end)

RegisterNUICallback('admin:getBootstrap', function(_, cb) cb(bootstrap()) end)

for _, name in ipairs({ 'saveStop', 'setActive', 'remove', 'history', 'rollback' }) do
    RegisterNUICallback('admin:' .. name, function(data, cb) cb(call(name, data)) end)
end

Nui.onClose(VIEW, function()
    editor.stop()
    TriggerServerEvent('daddy_transit:admin:close')
end)
