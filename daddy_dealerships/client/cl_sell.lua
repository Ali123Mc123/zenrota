-- Selling a car back: driving one's own car to a dealership's sell point (where the dealership buys cars back) shows
-- the hint; E asks the server what it fetches, the card on the page is held to sell (X gives up). Its props and dents
-- go with it to the used hall.
local points, busy = {}, false

local function load(list)
    points = {}
    for _, id in ipairs(type(list) == 'table' and list or {}) do points[id] = true end
end

CreateThread(function()
    Wait(2000)
    load(lib.callback.await('daddy_dealerships:sell:points', false))
end)

-- a dealership's buy-back switched in game
RegisterNetEvent('daddy_dealerships:sell:points', load)

CreateThread(function()
    local shown
    while true do
        local pick
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped and not busy and not Hall.active then
            local here = GetEntityCoords(veh)
            for id, d in pairs(Dealers.all) do
                if points[id] and d.sell and #(here - d.sell) < 4.0 then pick = d end
            end
        end
        if pick ~= shown then
            shown = pick
            Bridge.hint(pick and { label = pick.label, verb = 'ui.sell_car' } or nil)
        end
        if pick then
            if IsControlJustPressed(0, 38) then
                busy = true
                Bridge.hint(nil)
                shown = nil
                local netId = NetworkGetNetworkIdFromEntity(veh)
                local q = lib.callback.await('daddy_dealerships:sell:quote', false, pick.id, netId)
                if not q or not q.ok then
                    Page.notice('msg.' .. (q and q.error or 'failed'), 'error')
                    busy = false
                else
                    Ask.hold({ kind = 'sell', dealer = q.dealer, brand = q.brand, name = q.name, model = '', price = q.price, plan = 'full',
                        today = q.price, each = 0, payments = 0, seconds = 20, hold = Config.DirectSale.Hold, seller = q.plate }, function(yes)
                        if yes then
                            -- the car as it stands goes with it, for the used hall
                            local car = Config.Used.Enabled and DoesEntityExist(veh) and Used.read(veh) or nil
                            local res = lib.callback.await('daddy_dealerships:sell', false, pick.id, netId, car)
                            if res and res.ok then Page.notice('msg.sold_back', 'success', Core.money(res.price))
                            else Page.notice('msg.' .. (res and res.error or 'failed'), 'error') end
                        end
                        busy = false
                    end)
                end
            end
            Wait(0)
        else
            Wait(veh ~= 0 and 300 or 1000)
        end
    end
end)
