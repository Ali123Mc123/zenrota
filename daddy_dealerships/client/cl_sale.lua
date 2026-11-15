-- Direct sales. The seller: /araçsat at a dealership opens the showroom for selling (the car, the customer, the plan;
-- holding the last step sends the offer). The customer: the offer shows on the page without focus; E held signs it,
-- X declines, and the car is handed over as after a purchase.
local offer

RegisterCommand(Config.Commands.DirectSale, function()
    local here, best = GetEntityCoords(PlayerPedId()), 30.0
    local pick
    for _, d in pairs(Dealers.all) do
        if d.open and #(here - d.open) < best then pick, best = d, #(here - d.open) end
    end
    if not pick then return Page.notice('msg.far', 'error') end
    Showroom.open(pick.id, nil, 'sale')
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.DirectSale, Core.t('ui.offer'))

Page.on('dealer:offer', function(data)
    local res = lib.callback.await('daddy_dealerships:sale:offer', false, Hall.dealer(), tonumber(data.target), tostring(data.model or ''),
        tonumber(data.colour), data.plan, tonumber(data.used), data.rgb, tostring(data.coupon or ''))
    return res or { ok = false, error = 'failed' }
end)

-- A card on the page (no focus) answered in the game: E held fills it and says yes, X says no; done(yes) once.
Ask = {}

function Ask.hold(card, done)
    offer = card
    Page.send('dealer:offer', card)
    CreateThread(function()
        local held, last, lastVal = 0, GetGameTimer(), -1
        while offer == card do
            local now = GetGameTimer()
            if IsControlPressed(0, 38) then held = held + (now - last) else held = 0 end
            last = now
            local val = math.floor(math.min(1.0, held / card.hold) * 1000) / 1000
            if val ~= lastVal then
                lastVal = val
                Page.send('dealer:offer:hold', { value = val })
            end
            local yes = held >= card.hold
            if yes or IsControlJustPressed(0, 73) then
                offer = nil
                Page.send('dealer:offer:end')
                done(yes)
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('daddy_dealerships:sale:offer', function(o)
    Ask.hold(o, function(yes)
        TriggerServerEvent('daddy_dealerships:sale:answer', yes, Core.vtype(joaat(o.model)))
    end)
end)

RegisterNetEvent('daddy_dealerships:sale:gone', function()
    offer = nil
    Page.send('dealer:offer:end')
    Page.notice('msg.offer_expired', 'error')
end)

RegisterNetEvent('daddy_dealerships:bought', function(res, model)
    Purchase.handOver(res, joaat(model))
end)
