-- Mileage and worn part notices.

if not Config.Servicing.Enabled then return end

CreateThread(function()
    local km, last, sent = 0.0, nil, GetGameTimer()
    while true do
        Wait(1000)
        local vehicle = cache.vehicle
        if vehicle and cache.seat == -1 then
            local pos = GetEntityCoords(vehicle)
            if last and GetEntitySpeed(vehicle) > 1.0 then km = km + #(pos - last) / 1000 end
            last = pos
            if GetGameTimer() - sent > 30000 then
                if km > 0.01 then TriggerServerEvent('daddy_mechanic:km', VehToNet(vehicle), km) end
                km, sent = 0.0, GetGameTimer()
            end
        else
            last = nil
        end
    end
end)

lib.onCache('seat', function(seat)
    if seat ~= -1 or not cache.vehicle then return end
    local vehicle = cache.vehicle
    SetTimeout(1500, function()
        local data = DoesEntityExist(vehicle) and Entity(vehicle).state.dmech
        for part, health in pairs(data and data.service or {}) do
            if (tonumber(health) or 100) < Config.Servicing.Warn then
                return Bridge.notify(nil, Core.t('msg.service_due', Core.t('parts.' .. part), math.floor(health)), 'error')
            end
        end
    end)
end)
