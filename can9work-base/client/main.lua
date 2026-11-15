can9work = can9work or {}
can9work.Functions = can9work.Functions or {}

local previousMoney = { cash = 0, bank = 0, crypto = 0 }
local isFirstLoad = true

local pmaVoice = exports['pma-voice']

CreateThread(function()
    Wait(1000)
    if QBX and QBX.PlayerData and QBX.PlayerData.metadata and QBX.PlayerData.metadata.isdead then
        LocalPlayer.state:set('isDead', true, true)
        pmaVoice:setRadioChannel(0)
        pmaVoice:setVoiceProperty("radioEnabled", false)
        pmaVoice:overrideProximityCheck(function() return false end)
    end
end)

RegisterNetEvent('qbx_core:client:onSetMetaData', function(key, oldValue, newValue)
    if key ~= 'isdead' then return end
    LocalPlayer.state:set('isDead', newValue, true)

    if newValue then
        pmaVoice:setRadioChannel(0)
        pmaVoice:setVoiceProperty("radioEnabled", false)
        pmaVoice:overrideProximityCheck(function() return false end)
    else
        pmaVoice:setVoiceProperty("radioEnabled", true)
        pmaVoice:resetProximityCheck()
    end
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(data)
    if not data or not data.money then return end

    if isFirstLoad then
        previousMoney.cash = data.money.cash or 0
        previousMoney.bank = data.money.bank or 0
        previousMoney.crypto = data.money.crypto or 0
        isFirstLoad = false
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    local monitorTypes = { 'cash', 'bank', 'crypto' }
    local threshold = 2000000

    for _, mType in ipairs(monitorTypes) do
        local current = data.money[mType] or 0
        local diff = current - (previousMoney[mType] or 0)

        if math.abs(diff) >= threshold then
            TriggerServerEvent('can9work:server:LargeTransactionEvent', {
                moneyType = mType,
                oldAmount = previousMoney[mType],
                newAmount = current,
                difference = diff,
                coords = { x = coords.x, y = coords.y, z = coords.z }
            })
        end
        previousMoney[mType] = current
    end
end)
