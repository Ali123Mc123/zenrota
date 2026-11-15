-- /dealeradmin: the catalogue and the dealerships' switches on the page; the server checks the admin on every call.
RegisterCommand(Config.Commands.Admin, function()
    local res = lib.callback.await('daddy_dealerships:admin', false)
    if not res or not res.ok then return Page.notice('msg.' .. (res and res.error or 'failed'), 'error') end
    Panel.open('dealer:admin', res.state)
end, false)

local function call(name, ...)
    return lib.callback.await('daddy_dealerships:admin' .. name, false, ...) or { ok = false, error = 'failed' }
end

Page.on('dealer:admin:save', function(d) return call(':save', d.row) end)
Page.on('dealer:admin:delete', function(d) return call(':delete', d.code) end)
Page.on('dealer:admin:bulk', function(d) return call(':bulk', d.codes, tonumber(d.percent)) end)
Page.on('dealer:admin:dealer', function(d) return call(':dealer', d.id, d.field, d.value) end)
Page.on('dealer:admin:reset', function(d) return call(':reset', d.id) end)
Page.on('dealer:admin:perms', function(d) return call(':perms', d.id, tonumber(d.grade), d.perm, d.on == true) end)
Page.on('dealer:admin:refund', function(d) return call(':refund', tonumber(d.id), tonumber(d.count)) end)

-- A dealership's desk from anywhere: the panel closes and the desk opens.
Page.on('dealer:admin:desk', function(d)
    Panel.close()
    Manage.open(d.id)
end)
