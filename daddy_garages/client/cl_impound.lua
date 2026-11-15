-- The officer's side of the impound (/iv next to a car opens the slip) and the buyer's side of an offer (the card waits
-- for Y or N with the page holding the keys).

-- Impounding ---------------------------------------------------------------------------------------------------------------
do
    local pending

    local function close()
        pending = nil
        Page.focus(false)
    end

    if Config.Impound.Enabled ~= false then RegisterCommand(Config.Impound.Command, function()
        if Page.open or Garage.busy or pending then return end
        local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 6.0, true)
        if not veh or not NetworkGetEntityIsNetworked(veh) then return Page.notice('msg.no_vehicle', 'error') end
        local netId = VehToNet(veh)
        local res = lib.callback.await('daddy_garages:impoundCheck', false, netId)
        if not res or not res.ok then return Page.notice('msg.' .. (res and res.err or 'failed'), 'error') end
        pending = netId
        local car = Garage.dress({ plate = res.plate, model = res.model, props = res.props or lib.getVehicleProperties(veh), fuel = 0, engine = 0, body = 0, km = 0, lastUsed = 0, state = 'out' })
        Page.send('garage:form', { car = car, hours = res.hours, fee = res.fee, locale = Core.locale(), lang = Core.language() })
        Page.focus(true)
    end, false) end

    Page.on('impound:submit', function(data)
        local netId = pending
        close()
        if not netId then return end
        local res = lib.callback.await('daddy_garages:impound', false, netId, { reason = data.reason, hours = data.hours, fee = data.fee, owner = data.owner ~= false })
        if not res or not res.ok then return Page.notice('msg.' .. (res and res.err or 'failed'), 'error') end
        Page.notice(res.unowned and 'msg.impound_unowned' or 'msg.impound_done', 'success')
        Page.sound('select')
    end)

    Page.on('impound:cancel', close)
end

-- An offer from another player ----------------------------------------------------------------------------------------------
do
    local waiting = false

    local function answer(yes)
        if not waiting then return end
        waiting = false
        Page.send('garage:offer', {})
        TriggerServerEvent('daddy_garages:offerAnswer', yes)
    end

    RegisterNetEvent('daddy_garages:offer', function(offer)
        if Page.open or Garage.busy or waiting or not Page.ready then return TriggerServerEvent('daddy_garages:offerAnswer', false) end
        waiting = true
        local car = Garage.dress({ plate = offer.plate, model = offer.model, props = offer.props, fuel = 0, engine = 0, body = 0, km = 0, lastUsed = 0, state = 'in' })
        Page.send('garage:offer', { from = offer.from or Core.t('ui.t_stranger', offer.fromId), car = car, price = offer.price, seconds = offer.seconds })
        Page.sound('select')
        local stop = GetGameTimer() + (offer.seconds or 60) * 1000
        CreateThread(function()
            while waiting and GetGameTimer() < stop do
                if IsControlJustPressed(0, 246) then
                    answer(true)
                    return
                elseif IsControlJustPressed(0, 249) then
                    answer(false)
                    return
                end
                Wait(0)
            end
            if waiting then answer(false) end
        end)
    end)

    Page.on('garage:offerAnswer', function(data) answer(data.yes == true) end)
end
