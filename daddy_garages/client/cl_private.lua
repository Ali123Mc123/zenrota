-- The real-estate menu for private garages (ox_lib): every private garage with its owners, and a new one where you stand.
local LIST, ONE = 'daddy_garages_private', 'daddy_garages_private_one'
local show

-- One change on the server; its fresh list, or nil (with the reason shown) when it failed.
local function ask(action, data)
    local res = lib.callback.await('daddy_garages:private', false, action, data)
    if type(res) ~= 'table' or not res.ok then
        Page.notice('msg.' .. (type(res) == 'table' and res.err or 'failed'), 'error')
        return type(res) == 'table' and res.list or nil
    end
    return res.list
end

local function confirm(header, text)
    return lib.alertDialog({ header = header, content = text, centered = true, cancel = true }) == 'confirm'
end

local function garageMenu(g)
    local options = {}
    for _, owner in ipairs(g.owners) do
        options[#options + 1] = {
            title = owner.name,
            description = Core.t('ui.pv_remove'),
            icon = 'user',
            onSelect = function()
                if not confirm(owner.name, Core.t('ui.pv_remove_ask', owner.name, g.label)) then return show(g.id) end
                show(g.id, ask('removeOwner', { id = g.id, owner = owner.id }))
            end,
        }
    end
    options[#options + 1] = {
        title = Core.t('ui.pv_add_owner'),
        icon = 'user-plus',
        onSelect = function()
            local input = lib.inputDialog(Core.t('ui.pv_add_owner'), { { type = 'number', label = Core.t('ui.pv_player'), required = true, min = 1 } })
            show(g.id, input and ask('addOwner', { id = g.id, player = input[1] }))
        end,
    }
    options[#options + 1] = {
        title = Core.t('ui.pv_waypoint'),
        icon = 'location-dot',
        onSelect = function() if g.coords then SetNewWaypoint(g.coords.x, g.coords.y) end end,
    }
    options[#options + 1] = {
        title = Core.t('ui.pv_move'),
        icon = 'location-crosshairs',
        onSelect = function()
            if not confirm(g.label, Core.t('ui.pv_move_ask')) then return show(g.id) end
            show(g.id, ask('move', { id = g.id }))
        end,
    }
    options[#options + 1] = {
        title = Core.t('ui.pv_rename'),
        icon = 'pen',
        onSelect = function()
            local input = lib.inputDialog(Core.t('ui.pv_rename'), { { type = 'input', label = Core.t('ui.pv_name'), default = g.label, required = true, max = 48 } })
            show(g.id, input and ask('rename', { id = g.id, label = input[1] }))
        end,
    }
    options[#options + 1] = {
        title = Core.t('ui.pv_delete'),
        icon = 'trash',
        onSelect = function()
            if not confirm(g.label, Core.t('ui.pv_delete_ask', g.label)) then return show(g.id) end
            show(nil, ask('delete', { id = g.id }))
        end,
    }
    lib.registerContext({ id = ONE, title = g.label, menu = LIST, options = options })
    lib.showContext(ONE)
end

local function listMenu(list)
    local here = GetEntityCoords(cache.ped)
    local options = {
        {
            title = Core.t('ui.pv_new'),
            description = Core.t('ui.pv_new_hint'),
            icon = 'plus',
            onSelect = function()
                local types = {}
                for i, kind in ipairs({ 'car', 'sea', 'air' }) do types[i] = { value = kind, label = Core.t('ui.pv_' .. kind) } end
                local input = lib.inputDialog(Core.t('ui.pv_new'), {
                    { type = 'input', label = Core.t('ui.pv_name'), required = true, max = 48 },
                    { type = 'select', label = Core.t('ui.pv_type'), options = types, default = 'car', required = true },
                    { type = 'number', label = Core.t('ui.pv_player'), required = true, min = 1 },
                })
                if not input then return show() end
                show(nil, ask('create', { name = input[1], type = input[2], player = input[3] }))
            end,
        },
    }
    for _, g in ipairs(list) do
        local c = g.coords
        local dist = c and #(here - vector3(c.x, c.y, c.z)) or 0
        options[#options + 1] = {
            title = g.label,
            description = Core.t('ui.pv_line', #g.owners, math.floor(dist)),
            icon = 'warehouse',
            arrow = true,
            onSelect = function() garageMenu(g) end,
        }
    end
    lib.registerContext({ id = LIST, title = Core.t('ui.pv_title'), options = options })
    lib.showContext(LIST)
end

-- The list again (or one garage of it) after a change; list is the server's fresh one when there is one.
function show(id, list)
    list = list or ask('list') or {}
    if id then
        for _, g in ipairs(list) do
            if g.id == id then return garageMenu(g) end
        end
    end
    listMenu(list)
end

RegisterNetEvent('daddy_garages:privateMenu', function() show() end)
