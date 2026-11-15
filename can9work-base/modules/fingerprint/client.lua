RegisterNetEvent('can9work:fingerprint:client:Check', function()
    local playerId = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), 2.5, false)
    if not playerId then
        return exports.qbx_core:Notify('Yakında kimse yok', 'error')
    end

    if lib.progressBar({
        duration = 4000,
        label = 'Parmak izi kontrol ediliyor...',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    }) then
        TriggerServerEvent('can9work:fingerprint:server:Check', GetPlayerServerId(playerId))
    else
        exports.qbx_core:Notify('Kontrol iptal edildi!', 'error')
    end
end)

RegisterNetEvent('can9work:fingerprint:client:Receive', function(playerName)
    lib.registerContext({
        id = 'fingerprint_info',
        title = 'Parmak İzi Bilgisi',
        options = {
            { title = 'Oyuncu Adı', description = playerName, icon = 'fa-solid fa-user' }
        }
    })
    lib.showContext('fingerprint_info')
end)
