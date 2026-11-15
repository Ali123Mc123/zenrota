local isPlacing = false
local placeModel = nil
local placeGameType = nil
local placeItemName = nil
local ghostProp = nil

local function getTableConfig(gameType)
    if gameType == 'connect4' then return connect4Config end
    if gameType == 'chess' then return chessConfig end
    if gameType == 'checkers' then return checkersConfig end
    if gameType == 'jengo' then return jengoConfig end
    if gameType == 'armwrestling' then return armwrestlingConfig end
    if gameType == 'truthordare' then return truthOrDareConfig end
    if gameType == 'santosPoly' then return santosPolyConfig end
    if gameType == 'eno' then return enoConfig end
    if gameType == 'guessWho' then return guessWhoConfig end
    if gameType == 'xox' then return xoxConfig end
    if gameType == 'rodeo' then return rodeoConfig end
    if gameType == 'basketball' then return basketballConfig end
    if gameType == 'boxmachine' then return boxMachineConfig end
    return nil
end

RegisterNetEvent('ak4y-core:PlayerLoaded', function()
    TriggerServerEvent('ak4y-boardGames:server:RequestTables')
end)

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    TriggerServerEvent('ak4y-boardGames:server:RequestTables')
end)

local defaultTables = {}
local defaultTableSpawns = {}

local gameNames = {
    'connect4', 'chess', 'checkers', 'jengo', 'armwrestling', 
    'truthordare', 'santosPoly', 'eno', 'guessWho', 'xox', 'rodeo', 'basketball', 'boxmachine'
}

-- Back up the original tables defined in the configs at resource start
for _, gName in ipairs(gameNames) do
    local cfg = getTableConfig(gName)
    if cfg then
        if not defaultTables[gName] and cfg.Tables then
            defaultTables[gName] = {}
            for tid, tData in pairs(cfg.Tables) do
                defaultTables[gName][tid] = tData
            end
        end
        if not defaultTableSpawns[gName] and cfg.TableSpawns then
            defaultTableSpawns[gName] = {}
            for tid, tData in pairs(cfg.TableSpawns) do
                defaultTableSpawns[gName][tid] = tData
            end
        end
        if (gName == 'rodeo' or gName == 'basketball' or gName == 'boxmachine') and not defaultTables[gName] then
            local list = cfg.Rodeos or cfg.Machines
            if list then
                defaultTables[gName] = {}
                for tid, tData in pairs(list) do
                    defaultTables[gName][tid] = tData
                end
            end
        end
    end
end

RegisterNetEvent('ak4y-boardGames:client:SyncTables', function(placedTables)
    _G.AK4Y_PlacedTables = placedTables
    -- Restore original config-placed tables from backup first
    for _, gName in ipairs(gameNames) do
        local cfg = getTableConfig(gName)
        if cfg then
            cfg.Tables = {}
            if defaultTables[gName] then
                for tid, tData in pairs(defaultTables[gName]) do
                    cfg.Tables[tid] = tData
                end
            end
            cfg.TableSpawns = {}
            if defaultTableSpawns[gName] then
                for tid, tData in pairs(defaultTableSpawns[gName]) do
                    cfg.TableSpawns[tid] = tData
                end
            end
            if gName == 'rodeo' then
                cfg.Rodeos = {}
                if defaultTables[gName] then
                    for tid, tData in pairs(defaultTables[gName]) do
                        cfg.Rodeos[tid] = tData
                    end
                end
            elseif gName == 'basketball' or gName == 'boxmachine' then
                cfg.Machines = {}
                if defaultTables[gName] then
                    for tid, tData in pairs(defaultTables[gName]) do
                        cfg.Machines[tid] = tData
                    end
                end
            end
        end
    end
    
    for id, tableData in pairs(placedTables) do
        local cfg = getTableConfig(tableData.game)
        if cfg then
            local coords = tableData.coords
            local heading = tableData.heading
            
            local hashProp = (type(tableData.model) == "string") and GetHashKey(tableData.model) or tableData.model
            local tObj = {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                w = heading,
                coords = vec4(coords.x, coords.y, coords.z, heading),
                heading = heading,
                prop = hashProp,
                label = getLocale("general", "game", "table"),
                price = tableData.price or 0,
                seats = {
                    A = vec3(-0.1225, -0.5975, 0.533),
                    B = vec3( 0.1225,  0.5975, 0.533)
                }
            }
            
            if tableData.game == "rodeo" then
                if not cfg.Rodeos then cfg.Rodeos = {} end
                cfg.Rodeos[id] = tObj
            elseif tableData.game == "basketball" or tableData.game == "boxmachine" then
                if not cfg.Machines then cfg.Machines = {} end
                cfg.Machines[id] = tObj
            else
                cfg.Tables[id] = tObj
                cfg.TableSpawns[id] = tObj
            end
        end
    end
    TriggerEvent("ak4y-rodeo:client:SyncProps")
    TriggerEvent("ak4y-boardGames:client:SyncProps")
end)

local function RotationToDirection(rotation)
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = vector3(cameraCoord.x + direction.x * distance, cameraCoord.y + direction.y * distance, cameraCoord.z + direction.z * distance)
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

local placePrice = 0

RegisterNetEvent('ak4y-boardGames:client:UseItem', function(itemName, customGame, customModel, customPrice)
    if isPlacing then return end
    placePrice = customPrice or 0
    
    local gameData = nil
    if itemName then
        for k, v in pairs(Config.Items) do
            if v.name == itemName then
                gameData = v
                break
            end
        end
    else
        gameData = {
            game = customGame,
            model = customModel,
            name = nil
        }
    end
    
    if not gameData then return end
    
    if gameData.game == "guessWho" then
        TriggerEvent('ak4y-guessWho:client:openMenu')
        if itemName then
            TriggerServerEvent('ak4y-boardGames:server:CancelPlacement', itemName)
        end
        return
    end
    
    placeModel = gameData.model
    placeGameType = gameData.game
    placeItemName = itemName
    
    local isColorable = false
    if type(placeModel) == "string" and (placeModel == "boardgame_table" or string.find(placeModel, "boardgame_table_")) then
        isColorable = true
    end

    if isColorable then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openColorPicker",
            gameType = placeGameType,
            itemName = placeItemName,
            price = placePrice
        })
        return
    end

    StartPlacementLoop(placeModel, placeGameType, placeItemName, placePrice)
end)

function StartPlacementLoop(pModel, pGameType, pItemName, pPrice)
    local hash = GetHashKey(pModel)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    ghostProp = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(ghostProp, false, false)
    SetEntityAlpha(ghostProp, 150, false)
    SetEntityHeading(ghostProp, heading)
    
    isPlacing = true
    
    CreateThread(function()
        local currentHeading = heading
        while isPlacing do
            Wait(0)
            
            local hit, hitCoords, entity = RayCastGamePlayCamera(10.0)
            if hit then
                SetEntityCoords(ghostProp, hitCoords.x, hitCoords.y, hitCoords.z)
                SetEntityHeading(ghostProp, currentHeading)
                PlaceObjectOnGroundProperly(ghostProp)
            end
            
            SetTextComponentFormat("STRING")
            AddTextComponentString(getLocale("general", "game", "place_object_text"))
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            
            if IsControlPressed(0, 14) then
                currentHeading = currentHeading - 2.0
            end
            if IsControlPressed(0, 15) then
                currentHeading = currentHeading + 2.0
            end
            
            if IsControlJustPressed(0, 176) then
                local finalCoords = GetEntityCoords(ghostProp)
                local finalHeading = GetEntityHeading(ghostProp)
                
                DeleteEntity(ghostProp)
                ghostProp = nil
                isPlacing = false
                
                if pGameType == "truthordare" then
                    TriggerServerEvent("ak4y-truthOrDare:server:createBottle", finalCoords)
                else
                    TriggerServerEvent('ak4y-boardGames:server:PlaceTable', pGameType, pModel, finalCoords, finalHeading, pItemName == nil, pPrice, pItemName)
                end
            end
            
            if IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200) then
                DeleteEntity(ghostProp)
                ghostProp = nil
                isPlacing = false
                TriggerServerEvent('ak4y-boardGames:server:CancelPlacement', pItemName)
            end
        end
    end)
end

RegisterNUICallback('selectColor', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    if data.model then
        StartPlacementLoop(data.model, data.gameType, data.itemName, data.price)
    else
        TriggerServerEvent('ak4y-boardGames:server:CancelPlacement', data.itemName)
    end
end)

RegisterNetEvent('ak4y-boardGames:client:TryRemoveTable', function()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    
    local closestDist = 9999.0
    local closestId = nil
    
    for k, v in pairs(Config.Items) do
        local cfg = getTableConfig(v.game)
        if cfg and cfg.Tables then
            for id, tData in pairs(cfg.Tables) do
                local tCoords
                if tData.coords then
                    tCoords = vec3(tData.coords.x, tData.coords.y, tData.coords.z)
                else
                    tCoords = vec3(tData.x, tData.y, tData.z)
                end
                local dist = #(pCoords - tCoords)
                if dist < 3.0 and dist < closestDist then
                    closestDist = dist
                    closestId = id
                end
            end
        end
    end
    
    if closestId then
        TriggerServerEvent('ak4y-boardGames:server:RemoveTable', closestId)
    end
end)
RegisterNUICallback('getLocales', function(data, cb)
    cb(Config.locales[Config.Locale])
end)

function SendTurnNotification()
    exports["ak4y-core"]:NotifyViaFramework(getLocale("common", "ui", "your_turn"), "inform")
end

RegisterNetEvent('ak4y-boardGames:client:OpenAdminMenu', function(placedTables)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showAdminMenu",
        active = true,
        tables = placedTables,
        items = Config.Items
    })
end)

RegisterNetEvent('ak4y-boardGames:client:AdminSyncTables', function(placedTables)
    SendNUIMessage({
        action = "updateAdminTables",
        tables = placedTables
    })
end)

RegisterNetEvent('ak4y-boardGames:client:NotifyNotAdmin', function()
    exports["ak4y-core"]:NotifyViaFramework(getLocale("general", "game", "no_permission"), "error")
end)

RegisterNUICallback('closeAdminMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('adminSpawnTable', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    TriggerEvent('ak4y-boardGames:client:UseItem', nil, data.game, data.model, data.price)
end)

paymentPopupActive = false

RegisterNUICallback('acceptPayment', function(data, cb)
    paymentPopupActive = false
    TriggerServerEvent('ak4y-boardGames:server:AcceptPayment', data.sessionId)
    cb('ok')
end)

RegisterNUICallback('declinePayment', function(data, cb)
    paymentPopupActive = false
    TriggerServerEvent('ak4y-boardGames:server:DeclinePayment', data.sessionId)
    cb('ok')
end)

RegisterNetEvent('ak4y-boardGames:client:ShowPaymentPopup', function(sessionId, cost)
    paymentPopupActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showPaymentPopup",
        sessionId = sessionId,
        cost = cost
    })
end)

RegisterNetEvent('ak4y-boardGames:client:HidePaymentPopup', function(success)
    paymentPopupActive = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "hidePaymentPopup",
        success = success
    })
end)

RegisterNUICallback('adminDeleteTable', function(data, cb)
    TriggerServerEvent('ak4y-boardGames:server:AdminRemoveTable', data.id)
    cb('ok')
end)

RegisterNUICallback('adminTeleport', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
    
    local ped = PlayerPedId()
    local coords = data.coords
    if coords and coords.x and coords.y and coords.z then
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, false)
        exports["ak4y-core"]:NotifyViaFramework(getLocale("general", "game", "teleported"), "success")
    end
end)

RegisterNetEvent('ak4y-boardGames:client:ForceStandUp', function(gameType, tableId)
    SendNUIMessage({
        action = "forceStandUp",
        game = gameType
    })
    exports["ak4y-core"]:NotifyViaFramework(getLocale("general", "game", "table_removed"), "error")
end)
