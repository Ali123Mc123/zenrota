-- The target options of a piece; each one reads the piece's current state when it is shown.
local defs = Config.Pieces
Options = {}

local function piece(id) return Client.pieces[id] end
local function is(id, ...)
    local p = piece(id)
    if not p then return false end
    for _, state in ipairs({ ... }) do if p.state == state then return true end end
    return false
end

local function option(label, icon, onSelect, canInteract)
    return { label = Client.t(label), icon = 'fa-solid fa-' .. icon, onSelect = onSelect, canInteract = canInteract }
end

local function act(id, action, work, ms)
    return function()
        if work and not Client.work(work, ms or 1500) then return end
        Client.act(id, action)
    end
end

local function cooking(id) local p = piece(id) return p and p.data and p.data.cook end
local function done(id) local job = cooking(id) return job and job.done end
local function hot(id) return is(id, 'burning', 'embers') end

function Options.of(id)
    local p = piece(id)
    local def = defs[p.key]
    local list = {}
    local add = function(o) list[#list + 1] = o end

    if def.seats then add(option('camp.opt_sit', 'chair', function(entity) Rest.sit(id, entity) end, function() return not is(id, 'folded') end)) end
    if def.lie then
        add(option('camp.opt_lie', 'bed', function(entity) Rest.lie(id, entity) end, function()
            return not is(id, 'rolled', 'pitching') and (def.kind ~= 'tent' or is(id, 'open'))
        end))
    end
    if def.door then
        add(option('camp.opt_open', 'door-open', act(id, 'door'), function() return is(id, 'closed') end))
        add(option('camp.opt_close', 'door-closed', act(id, 'door'), function() return is(id, 'open') end))
    end
    if def.stash then add(option('camp.opt_stash', 'box-open', act(id, 'stash'), function() return not is(id, 'pitching') end)) end
    if p.key == 'camp_chair' or p.key == 'sleeping_bag' then add(option('camp.opt_fold', 'repeat', act(id, 'fold'))) end

    if def.kind == 'fire' then
        add(option('camp.opt_wood', 'tree', act(id, 'wood', 'camp.work_wood'), function() return not cooking(id) end))
        add(option('camp.opt_light', 'fire', act(id, 'light', 'camp.work_light', 2500), function() return is(id, 'laid') end))
        add(option('camp.opt_douse', 'bucket', act(id, 'douse', 'camp.work_douse', 2000), function() return hot(id) end))
        add(option('camp.opt_roast', 'drumstick-bite', function() Cook.roastMenu(id) end, function() return hot(id) end))
    end
    if def.kind == 'fire' or def.kind == 'grill' or def.kind == 'stove' or def.kind == 'tripod' then
        add(option('camp.opt_cook', 'utensils', function() Cook.menu(id) end, function() return not cooking(id) end))
        add(option('camp.opt_collect', 'hand-holding', act(id, 'collect', 'camp.work_collect', 1000), function() return done(id) end))
    end
    if def.kind == 'tripod' then add(option('camp.opt_fill', 'droplet', act(id, 'fill', 'camp.work_fill'), function() return is(id, 'empty') end)) end
    if def.kind == 'stove' then
        add(option('camp.opt_stove_on', 'fire-burner', act(id, 'stove'), function() return is(id, 'off') end))
        add(option('camp.opt_stove_off', 'power-off', act(id, 'stove'), function() return is(id, 'on') and not cooking(id) end))
    end
    if def.kind == 'stack' then
        add(option('camp.opt_take_wood', 'hand', act(id, 'take_wood', 'camp.work_wood', 1000), function() return (piece(id).data.wood or 0) > 0 end))
        add(option('camp.opt_store_wood', 'tree', act(id, 'store_wood', 'camp.work_wood', 1000)))
    end
    if def.kind == 'block' then
        add(option('camp.opt_put_log', 'tree', act(id, 'put_log', 'camp.work_place', 1200), function() return is(id, 'empty') end))
        add(option('camp.opt_chop', 'hammer', function(entity) Cook.chop(id, entity) end, function() return is(id, 'log') end))
    end
    if def.kind == 'light' and p.key ~= 'torch' then
        add(option('camp.opt_switch', 'lightbulb', act(id, 'switch')))
    end
    add(option('camp.opt_pickup', 'hand-back-fist', function()
        if Client.work('camp.work_pickup', def.kind == 'tent' and 4000 or 1200) then lib.callback.await('daddy_camp:pickup', false, id) end
    end, function() return piece(id) and piece(id).owner == Client.me end))
    return list
end
