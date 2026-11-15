-- this function is called when the local game is started
function GameStarted(coords)

end

-- this function is called when the local game is ended
function GameEnded(coords)
    
end

-- rcore_gameprops dinamik masa senkronizasyonu
CreateThread(function()
    Wait(1500)
    if Config.SyncTablesFromGameProps then
        Config.SyncTablesFromGameProps()
    end
end)
