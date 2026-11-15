-- Working at a kitchen station (DaddyRP): only accepted orders show up here. Each product is made with a short
-- minigame (food, drink or dessert); the product goes into the cook's inventory and is handed over by hand.

local errors = {
    off_duty = 'err_off_duty', forbidden = 'err_not_worker', locked = 'err_locked', busy = 'err_busy',
    not_found = 'err_nothing', no_stock = 'err_no_stock', broken = 'err_broken', no_space = 'err_no_space', not_accepted = 'err_not_accepted',
}

local function fail(error)
    lib.notify({ type = 'error', description = L(errors[error] or 'failed') })
end

local ANIMS = {
    food = { dict = 'amb@prop_human_bbq@male@base', clip = 'base' },
    drink = { dict = 'anim@amb@clubhouse@bar@drink@one', clip = 'one_bartender' },
    dessert = { dict = 'amb@prop_human_bbq@male@base', clip = 'base' },
}

-- the animation runs while the minigame is open, the game decides: true when it was won, false on ESC
local function play(kind, title, path)
    local anim = ANIMS[kind] or ANIMS.food
    -- an animation the game does not have only skips the show, never the work
    local loaded = pcall(lib.requestAnimDict, anim.dict)
    if loaded then TaskPlayAnim(cache.ped, anim.dict, anim.clip, 3.0, 3.0, -1, 1, 0, false, false, false) end
    local won = Venue.Local.minigame({ kind = kind, title = title, path = path })
    ClearPedTasks(cache.ped)
    if loaded then RemoveAnimDict(anim.dict) end
    return won
end

local function make(data, state, order, line)
    if not play(line.kind, ('%d× %s'):format(line.qty, line.name), order.id .. ' · ' .. state.label) then return false end
    local res = lib.callback.await('daddy_venue:stationMake', false, data.id, order.id, line.id)
    if not (res and res.ok) then
        fail(res and res.error)
        return false
    end
    lib.notify({ type = 'success', description = res.ready and L('station_ready', order.id) or L('station_made', line.name) })
    return true
end

-- DaddyRP: making products without an order. The cook picks a product and an amount, plays the same minigame as for an
-- order; only a won game takes the recipe from the depot and puts the products into the inventory (stationFreeMake).
local function freeMake(data, state, product)
    local input = lib.inputDialog(product.name, {
        { type = 'number', label = L('free_amount'), description = L('free_amount_hint', product.can), default = 1, min = 1, max = state.max, required = true },
    })
    local qty = input and math.floor(tonumber(input[1]) or 0)
    if not qty or qty < 1 then return false end
    if not play(product.kind, ('%d× %s'):format(qty, product.name), L('free_title') .. ' · ' .. state.label) then return false end
    local res = lib.callback.await('daddy_venue:stationFreeMake', false, data.id, product.id, qty)
    if not (res and res.ok) then
        fail(res and res.error)
        return false
    end
    lib.notify({ type = 'success', description = L('free_made', res.qty, res.name) })
    return true
end

local function freeMenu(data, label)
    local state = lib.callback.await('daddy_venue:stationFree', false, data.id)
    if not (state and state.ok) then return fail(state and state.error) end
    if #state.products == 0 then return lib.notify({ type = 'inform', description = L('free_none') }) end
    state.label = label
    local options = {}
    for _, product in ipairs(state.products) do
        options[#options + 1] = {
            title = product.name,
            description = L('station_recipe', product.recipe) .. '\n' .. (product.can > 0 and L('free_can', product.can) or L('free_cant')),
            icon = product.kind == 'drink' and 'martini-glass' or product.kind == 'dessert' and 'cake-candles' or 'fire',
            disabled = product.can < 1,
            onSelect = function()
                if freeMake(data, state, product) then freeMenu(data, label) end
            end,
        }
    end
    lib.registerContext({ id = 'daddy_station_free', title = L('free_title'), menu = 'daddy_station', options = options })
    lib.showContext('daddy_station_free')
end

function Venue.Local.station(data)
    local state = lib.callback.await('daddy_venue:stationOrders', false, data.id)
    if not (state and state.ok) then return fail(state and state.error) end

    -- making without an order is always there, the orders follow
    local options = {
        { title = L('free_title'), description = L('free_desc'), icon = 'hammer', onSelect = function() freeMenu(data, state.label) end },
    }
    if #state.orders == 0 then
        -- the products of the accepted orders are made at another station of the place
        local text = state.elsewhere and #state.elsewhere > 0 and L('station_elsewhere', table.concat(state.elsewhere, ', ')) or L('station_empty', state.label:lower())
        options[#options + 1] = { title = text, icon = 'circle-info', readOnly = true }
    end
    for _, order in ipairs(state.orders) do
        for _, line in ipairs(order.lines) do
            options[#options + 1] = {
                -- what the product took from the depot (taken when the order was accepted), so the cook knows the recipe
                title = ('%s · %d× %s'):format(order.id, line.qty, line.name),
                description = line.recipe and line.recipe ~= '' and (L('station_make_' .. line.kind) .. '\n' .. L('station_recipe', line.recipe)) or L('station_make_' .. line.kind),
                icon = line.kind == 'drink' and 'martini-glass' or line.kind == 'dessert' and 'cake-candles' or 'fire',
                onSelect = function()
                    if make(data, state, order, line) then Venue.Local.station(data) end
                end,
            }
        end
    end
    lib.registerContext({ id = 'daddy_station', title = state.label, options = options })
    lib.showContext('daddy_station')
end
