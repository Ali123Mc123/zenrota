-- /campadmin menus: the camps near the admin, then one camp's pieces; every removal is confirmed and asked of the server.
local open

local function confirm(key, ...)
    return lib.alertDialog({ header = Client.t('camp.admin_title'), content = Client.t(key, ...), centered = true, cancel = true }) == 'confirm'
end

local function remove(data, question, ...)
    if not confirm(question, ...) then return end
    open(lib.callback.await('daddy_camp:admin:remove', false, data))
end

local function camp(c)
    local options = {
        { title = Client.t('camp.admin_mark'), icon = 'location-dot', onSelect = function() SetNewWaypoint(c.x, c.y) end },
        { title = Client.t('camp.admin_remove_camp'), icon = 'trash', iconColor = '#c0392b',
            onSelect = function() remove({ scope = 'camp', owner = c.owner }, 'camp.admin_sure_camp', c.name) end },
        { title = Client.t('camp.admin_remove_all', c.total), icon = 'trash-can', iconColor = '#c0392b',
            onSelect = function() remove({ scope = 'owner', owner = c.owner }, 'camp.admin_sure_all', c.total, c.name) end },
    }
    for _, piece in ipairs(c.pieces) do
        local label = Client.t('camp.piece.' .. piece.key)
        options[#options + 1] = { title = label, description = Client.t('camp.admin_dist', math.floor(piece.dist)), icon = 'cube',
            onSelect = function() remove({ scope = 'piece', id = piece.id }, 'camp.admin_sure_piece', label) end }
    end
    lib.registerContext({ id = 'daddy_camp_admin_camp', title = c.name, menu = 'daddy_camp_admin', options = options })
    lib.showContext('daddy_camp_admin_camp')
end

open = function(list)
    if not list then return end
    local options = {}
    for _, c in ipairs(list) do
        options[#options + 1] = { title = c.name, icon = 'campground', arrow = true, onSelect = function() camp(c) end,
            description = Client.t(c.online and 'camp.admin_camp_on' or 'camp.admin_camp_off', #c.pieces, c.total, math.floor(c.dist)) }
    end
    if #options == 0 then options[1] = { title = Client.t('camp.admin_none'), disabled = true } end
    lib.registerContext({ id = 'daddy_camp_admin', title = Client.t('camp.admin_title'), options = options })
    lib.showContext('daddy_camp_admin')
end

RegisterNetEvent('daddy_camp:admin', function(list) open(list) end)
