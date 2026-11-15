-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

--- @important When player loaded, this event will be triggered.
RegisterNetEvent('wais:primehud:client:custom:playerLoaded', function()
    wFramework.CustomPlayerLoaded()
end)

--- @important When player unloaded, this event will be triggered.
RegisterNetEvent('wais:primehud:client:custom:playerUnloaded', function()
    wFramework.playerUnloaded()
end)

--- @param job table { label = string, grade = { name = string }, onDuty = boolean }
RegisterNetEvent('wais:primehud:client:custom:setPlayerJob', function(job)
    wFramework.SetPlayerJob(job)
end)

--- @param gang table { label = string, grade = { name = string } }
RegisterNetEvent('wais:primehud:client:custom:setPlayerGang', function(gang)
    wFramework.SetPlayerGang(gang)
end)

--- @param money number
RegisterNetEvent('wais:primehud:client:custom:setPlayerMoney', function(money)
    wFramework.SetPlayerMoney(money)
end)

--- @param bank number
RegisterNetEvent('wais:primehud:client:custom:setPlayerBank', function(bank)
    wFramework.SetPlayerBank(bank)
end)

--- @param status table { hunger = number, thirst = number, stress = number }
RegisterNetEvent('wais:primehud:client:custom:setPlayerStatus', function(status)
    wFramework.SetPlayerCustomStatus(status)
end)

--- This code block is doing this action: If the qs-crime-creator resource exist, its listening the statebag for gang stuff.
if GetResourceState("qs-crime-creator"):find("start") then
    AddStateBagChangeHandler("organization", nil, function(bagName, key, value) 
        if value ~= nil then
            TriggerEvent('wais:get:crime', value, function(label)
                wFramework.SetPlayerGang({label = label,grade = {name = Lang('unknown')}})
            end)

            return
        end

        return wFramework.SetPlayerGang({label = Lang('unknown'), grade = {name = Lang('unknown')}})
    end)
end

-----------------------------------------------------------------------------------------
-- NUI CALLBACK'S --
-----------------------------------------------------------------------------------------

RegisterNUICallback('toggleEngine', function(_, cb)
    if Player.vehicle.vehicle <= 0 or not DoesEntityExist(Player.vehicle.vehicle) then
        return cb('ok')
    end

    local currState = IsVehicleEngineOn(Player.vehicle.vehicle)
    SetVehicleEngineOn(Player.vehicle.vehicle, not currState, false, true)
    cb('ok')
end)

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

local function markPostal(postalId)
    for _, v in pairs(Postals) do
        if v.code == postalId then
            SetNewWaypoint(v.x, v.y)
            return Config.Notification(Lang("postal"), Lang("postal_marked"), "success")
        end
    end

    return Config.Notification(Lang("postal"), Lang("postal_not_found"), "error")
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

if not Config.Commands.postal.disabled then
    RegisterCommand(Config.Commands.postal.command, function(_, args)
        local postalId = args[1] and args[1] or nil
        markPostal(postalId)
    end, false)

    TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Commands.postal.command), Config.Commands.postal.help.command, {
        { name = 'postalid', help = Config.Commands.postal.help.postalid },
    })
end

if not Config.Commands.seat.disabled then
    RegisterCommand(Config.Commands.seat.command, function(_, args)
        if Player.vehicle.vehicle < 0 then 
            return Config.Notification(Lang("seat"), Lang('you_not_in_vehicle'), "error") 
        end

        local seatId = args[1] and tonumber(args[1]) or nil
        if not seatId then 
            return Config.Notification(Lang("seat"), Lang("seat_seatid_not_found"), "error") 
        end

        seatId = seatId - 2
        local max = GetVehicleModelNumberOfSeats(GetEntityModel(Player.vehicle.vehicle)) - 2
        if seatId > max then 
            return Config.Notification(Lang("seat"), Lang("seat_max_exceeded"), "error") 
        end

        if not IsVehicleSeatFree(Player.vehicle.vehicle, seatId) then
            return Config.Notification(Lang("seat"), Lang("seat_busy"), "error") 
        end

        local ped = cache.ped
        SetPedIntoVehicle(ped, Player.vehicle.vehicle, seatId)
        Config.Notification(Lang("seat"), Lang('seat_changed_to', seatId), "success")
    end, false)

    TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Commands.seat.command), Config.Commands.seat.help.command, {
        { name = 'seatid', help = Config.Commands.seat.help.seatid },
    })
end

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

-- Düşük açlık/susuzluk uyarısı (dahili Config.SendStatusAlert eşiği escrow'da 20'ye sabit, bu yüzden kapalı;
-- yerine %15 eşikli, tekrarlı uyarı burada).
local LowStatusAlert = {
    threshold = 15,             -- % altında uyar
    interval = 4 * 60 * 1000,   -- eşik altındayken tekrar aralığı (ms)
    check = 15 * 1000,          -- kontrol aralığı (ms)
}

local function getStatusValue(key)
    local v = LocalPlayer.state[key]
    if v == nil and GetResourceState('qbx_core') == 'started' then
        local ok, pd = pcall(function() return exports.qbx_core:GetPlayerData() end)
        v = ok and pd and pd.metadata and pd.metadata[key] or nil
    end
    return tonumber(v)
end

local function isDowned()
    if IsEntityDead(cache.ped) then return true end
    if GetResourceState('qbx_medical') ~= 'started' then return false end
    local ok, downed = pcall(function() return exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand() end)
    return ok and downed or false
end

CreateThread(function()
    local lastAlert = { hunger = 0, thirst = 0 }
    local texts = {
        hunger = 'Acıktın, bir şeyler yemelisin.',
        thirst = 'Susadın, bir şeyler içmelisin.',
    }

    while true do
        Wait(LowStatusAlert.check)
        if LocalPlayer.state.isLoggedIn and not isDowned() then
            local now = GetGameTimer()
            for key, text in pairs(texts) do
                local value = getStatusValue(key)
                if value and value < LowStatusAlert.threshold then
                    if lastAlert[key] == 0 or now - lastAlert[key] >= LowStatusAlert.interval then
                        lastAlert[key] = now
                        lib.notify({
                            title = Lang('status_alert'),
                            description = text,
                            type = 'warning',
                            duration = 7000,
                            position = 'center-right',
                        })
                    end
                else
                    lastAlert[key] = 0
                end
            end
        end
    end
end)

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------