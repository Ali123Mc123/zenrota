-- Client-side framework bridge

Framework = {}
Framework.name = 'standalone'

local function debugPrint(msg)
    if Config.Debug then
        print(('[krypton-combatlog] [DEBUG] %s'):format(msg))
    end
end

local function detectFramework()
    if Config.Framework ~= 'auto' then
        Framework.name = Config.Framework:lower()
        return
    end

    if GetResourceState('qbx_core') == 'started' then
        Framework.name = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        Framework.name = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        Framework.name = 'esx'
    else
        Framework.name = 'standalone'
    end

    debugPrint(('Framework detected: %s'):format(Framework.name))
end

-- Register callback for when player is fully loaded in framework
function Framework.OnPlayerLoaded(cb)
    if Framework.name == 'qbx' then
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)

    elseif Framework.name == 'qb' then
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)

    elseif Framework.name == 'esx' then
        RegisterNetEvent('esx:playerLoaded', function(xPlayerData)
            cb()
        end)

    else
        -- Standalone: just call it after a short delay
        CreateThread(function()
            Wait(2000)
            cb()
        end)
    end
end

detectFramework()
