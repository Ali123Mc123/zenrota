local animProp = nil
local waitFinish = false
local tasks = {}
local taskId = 1

if Savana.Keys then
    lib.addKeybind({
        name = Savana.menuCommand,
        description = 'Kamu Hizmeti Menüsünü Aç',
        defaultKey = Savana.MenuKey,
        defaultMapper = 'keyboard',
        onPressed = function(self)
            openMenu()
        end
    })

    lib.addKeybind({
        name = Savana.menuDashboard,
        description = 'Kamu Hizmeti Panelini Aç',
        defaultKey = Savana.DashboardKey,
        defaultMapper = 'keyboard',
        onPressed = function(self)
            openDashboard()
        end
    })
else
    RegisterCommand(Savana.menuCommand, function()
        openMenu()
    end)

    RegisterCommand(Savana.menuDashboard, function()
        openDashboard()
    end)
end



function openDashboard()
    if checkAccess() then
        laodProfile()
        loadDashboard()

        SendNUIMessage({
            action = "openDashboard"
        })

        SetNuiFocus(true, true)
    end
end

function openMenu()
    if checkAccess() then
        laodProfile()
        loadNearPlayers()

        SendNUIMessage({
            action = "openMenu"
        })

        SetNuiFocus(true, true)
    end
end

function checkAccess()
    local fetch = lib.callback.await('savana-community:getJob', false)

    for k, v in pairs(Savana.Jobs) do
        if v == fetch then
            return true
        end
    end

    return false
end

function laodProfile()
    local fetch = lib.callback.await('savana-community:getProfile', false)
    local mugshot = GetMugShot(PlayerPedId())

    SendNUIMessage({
        action = "updateProfile",
        name = fetch.name,
        grade = fetch.grade,
        mugshot = mugshot
    })
end

local targetLocation = nil
local targetType = nil

RegisterNetEvent('savana-community:send')
AddEventHandler('savana-community:send', function(data)
    targetLocation = data.location
    targetType = data.type

    sendLocation(targetLocation)

    SendNUIMessage({
        action = "openProgress",
        amount = data.amount,
        type = data.type,
        progress = data.progress,
        location = Savana.Locations[targetLocation].label
    })
end)

RegisterNetEvent('savana-community:update')
AddEventHandler('savana-community:update', function(data, finish)
    SendNUIMessage({
        action = "updateProgress",
        amount = data.amount,
        type = data.type,
        progress = data.progress,
        location = Savana.Locations[targetLocation].label
    })

    if finish then
        TriggerServerEvent('savana-community:release')
        waitFinish = "gg"
    else
        waitFinish = false
    end
end)

RegisterNetEvent('savana-community:release')
AddEventHandler('savana-community:release', function(data)
    if targetLocation then
        local loc = targetLocation
        targetLocation = nil

        resetZones()

        SendNUIMessage({
            action = "release"
        })

        DoScreenFadeOut(100)
        Citizen.Wait(150)

        local coord = Savana.Locations[loc].releaseCoord
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(PlayerPedId(), coord.x, coord.y, coord.z)
        SetEntityHeading(PlayerPedId(), coord.w)

        Citizen.Wait(1000)
        DoScreenFadeIn(500)

        waitFinish = false
        tasks = {}
        taskId = 1
    end
end)

function sendLocation()
    DoScreenFadeOut(100)
    Citizen.Wait(150)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(PlayerPedId(), Savana.Locations[targetLocation].coord)
    Citizen.Wait(1000)
    DoScreenFadeIn(500)
end

Citizen.CreateThread(function()
    while true do
        if targetLocation then
            local info = Savana.Locations[targetLocation]
            local coord = vec3(info.coord.x, info.coord.y, info.coord.z)
            local radius = info.radius
            local distance = #(GetEntityCoords(PlayerPedId()) - coord)


            if distance > radius then
                sendLocation()
            end

            while waitFinish do
                if waitFinish == "gg" then
                    break
                end
                Citizen.Wait(1)
            end

            if waitFinish ~= "gg" then
                local taskNumber = 0

                for k, v in pairs(tasks) do
                    taskNumber = taskNumber + 1
                end

                if taskNumber <= 0 then
                    createNewTask()
                end
                waitFinish = false
            end
        end
        Citizen.Wait(1000)
    end
end)

RegisterNUICallback('send', function(data)
    local response = lib.callback.await('savana-community:send', false, data)
end)

RegisterNUICallback('loadName', function(data, cb)
    local location = data.loc

    cb(Savana.Locations[location].label or "Bulunamadı")
end)

RegisterNUICallback('release', function(data)
    TriggerServerEvent('savana-community:release', data.id)
end)

RegisterNUICallback('exit', function()
    SetNuiFocus(false, false)
    clearMugshot()
end)

RegisterNetEvent('savana-community:refreshDashboard')
AddEventHandler('savana-community:refreshDashboard', function()
    loadDashboard()
end)

function loadDashboard()
    local fetch = lib.callback.await('savana-community:getData', false)

    local keys = {}

    for k in pairs(fetch.ongoing) do
        table.insert(keys, k)
    end

    table.sort(keys, function(a, b) return a > b end)

    for _, k in ipairs(keys) do
        local v = fetch.ongoing[k]
        SendNUIMessage({
            action = "addOngoing",
            id = k,
            data = v
        })
    end

    for i = #fetch.history, 1, -1 do
        local v = fetch.history[i]
        SendNUIMessage({
            action = "addHistory",
            data = v
        })
    end
end

function loadNearPlayers()
    local players = getNearbyPlayers()

    for k, v in pairs(players) do
        SendNUIMessage({
            action = "addPlayer",
            value = v
        })
    end
end

function getNearbyPlayers()
    local nearbyPlayers = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local targetServerIds = {}
    local pedMap = {}

    if lib and lib.getNearbyPlayers then
        local oxNearby = lib.getNearbyPlayers(playerCoords, 20.0, false)
        for i = 1, #oxNearby do
            local item = oxNearby[i]
            local sId = GetPlayerServerId(item.id)
            table.insert(targetServerIds, sId)
            pedMap[sId] = {
                ped = item.ped,
                coords = item.coords,
                distance = #(playerCoords - item.coords)
            }
        end
    else
        local players = GetActivePlayers()
        for _, playerId in ipairs(players) do
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if distance <= 20.0 then
                local sId = GetPlayerServerId(playerId)
                table.insert(targetServerIds, sId)
                pedMap[sId] = {
                    ped = targetPed,
                    coords = targetCoords,
                    distance = distance
                }
            end
        end
    end

    if #targetServerIds == 0 then
        return nearbyPlayers
    end

    -- Tek seferde toplu isimleri al
    local fetched = lib.callback.await('savana-community:getPlayersWithNames', false, targetServerIds)
    if fetched and type(fetched) == 'table' then
        for _, pData in ipairs(fetched) do
            local info = pedMap[pData.id]
            if info then
                table.insert(nearbyPlayers, {
                    id = pData.id,
                    ped = info.ped,
                    name = pData.name,
                    coords = info.coords,
                    distance = info.distance
                })
            end
        end
    end

    return nearbyPlayers
end

function createNewTask()
    local info = Savana.Locations[targetLocation]
    local coord = vec3(info.coord.x, info.coord.y, info.coord.z)
    local targetCoord = info.animations[targetType].locations[math.random(1, #info.animations[targetType].locations)]

    tasks[tostring(taskId)] = targetCoord
    taskId = taskId + 1


    createTaskBox(tostring(taskId - 1), targetCoord)
end

local targetAnim = {
    dict = nil,
    name = nil
}

Citizen.CreateThread(function()
    local sleep = 1000
    while true do
        if targetLocation then
            sleep = 0
        else
            sleep = 1000
        end

        local level = Savana.Levels[targetType]

        for k, v in pairs(tasks) do
            DrawMarker(level.marker.icon, v, 0.0, 0.0, 0.0, 0, 0.0, 0.0, level.marker.size, level.marker.size,
                level.marker.size, 0, level.marker.color.r, level.marker.color.g, level.marker.color.b, false, false, 2,
                true, false, false, false)
        end

        if animPlaying then
            DisableAllControlActions(0)

            if not IsEntityPlayingAnim(PlayerPedId(), targetAnim.dict, targetAnim.name, 3) then
                TaskPlayAnim(PlayerPedId(), targetAnim.dict, targetAnim.name, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end

        Citizen.Wait(sleep)
    end
end)

function progress(id)
    FreezeEntityPosition(PlayerPedId(), true)
    animPlaying = true

    playCustomAnimation(Savana.Locations[targetLocation].animations[targetType])
    Citizen.Wait(Savana.Locations[targetLocation].animations[targetType].time)

    animPlaying = false

    FreezeEntityPosition(PlayerPedId(), false)

    DeleteObject(animProp)
    ClearPedTasks(PlayerPedId())
    removeZone(id)
    waitFinish = true

    tasks[id] = nil

    TriggerServerEvent('savana-community:progress')
end

function playCustomAnimation(animData)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    RequestModel(animData.AnimationOptions.Prop)
    while not HasModelLoaded(animData.AnimationOptions.Prop) do
        Citizen.Wait(100)
    end

    local prop = CreateObject(GetHashKey(animData.AnimationOptions.Prop), playerCoords.x, playerCoords.y,
        playerCoords.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, animData.AnimationOptions.PropBone),
        animData.AnimationOptions.PropPlacement[1],
        animData.AnimationOptions.PropPlacement[2],
        animData.AnimationOptions.PropPlacement[3],
        animData.AnimationOptions.PropPlacement[4],
        animData.AnimationOptions.PropPlacement[5],
        animData.AnimationOptions.PropPlacement[6],
        true, true, false, true, 1, true)

    RequestAnimDict(animData.dict)
    while not HasAnimDictLoaded(animData.dict) do
        Citizen.Wait(100)
    end

    targetAnim = {
        dict = animData.dict,
        name = animData.name
    }

    animProp = prop

    TaskPlayAnim(playerPed, animData.dict, animData.name, 8.0, -8.0, -1, 1, 0, false, false, false)
end
