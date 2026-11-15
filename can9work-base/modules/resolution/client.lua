local playerLoaded = false
local nuiShown = false
local invalidStart = nil
local dropTime = 60000

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() playerLoaded = true end)

Citizen.CreateThread(function()
    while true do
        Wait(12000)
        if playerLoaded then
            if GetIsWidescreen() then
                if nuiShown then
                    SendNUIMessage({ action = 'hide' })
                    nuiShown = false
                end
                invalidStart = nil
            else
                if not invalidStart then invalidStart = GetGameTimer() end
                local elapsed = GetGameTimer() - invalidStart
                local timeLeft = math.ceil((dropTime - elapsed) / 1000)

                SendNUIMessage({ action = 'show', timeLeft = timeLeft })
                nuiShown = true

                if elapsed >= dropTime then
                    TriggerServerEvent('can9work:resolution:server:DropPlayer')
                    Wait(5000)
                end
            end
        else
            Wait(1000)
        end
    end
end)
