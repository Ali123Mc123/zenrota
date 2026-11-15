RegisterNetEvent('can9work-radialmenu/client/spawnCone', function()
    TriggerEvent('police:client:spawnPObj', 'cone')
end)

RegisterNetEvent('can9work-radialmenu/client/spawnGate', function()
    TriggerEvent('police:client:spawnPObj', 'barrier')
end)

RegisterNetEvent('can9work-radialmenu/client/spawnSpeedSign', function()
    TriggerEvent('police:client:spawnPObj', 'roadsign')
end)

RegisterNetEvent('can9work-radialmenu/client/spawnTent', function()
    TriggerEvent('police:client:spawnPObj', 'tent')
end)

RegisterNetEvent('can9work-radialmenu/client/spawnLighting', function()
    TriggerEvent('police:client:spawnPObj', 'light')
end)

RegisterNetEvent('can9work-radialmenu/client/spawnSpikeStrip', function()
    TriggerEvent('police:client:SpawnSpikeStrip')
end)

RegisterNetEvent('can9work-radialmenu/client/deleteObject', function()
    TriggerEvent('police:client:deleteObject')
end)
