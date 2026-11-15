currentZone = nil
menuOpened = false
cachedMugshot = nil
currentRoom = nil

RegisterNUICallback('close', function(data)
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
    menuOpened = false
end)

Citizen.CreateThread(function()
    for _, motel in pairs(Config.Motels) do
        CreateBlip(vector3(motel.centerCoords.x, motel.centerCoords.y, motel.centerCoords.z), motel.name)
    end
end)

Citizen.CreateThread(function()
    local ped = PlayerPedId()
    
    if not Config.UseTarget then
        lib.zones.sphere({
            coords = vector3(92.9, -485.99, -109.01),
            radius = 6.0,
            debug = false,
            inside = function()
                HandleActionZone(vector3(92.9, -485.99, -109.01))
            end
        })

        lib.zones.sphere({
            coords = vector3(92.6, -483.82, -109.01),
            radius = 6.0,
            debug = false,
            inside = function()
                HandleStashZone(vector3(92.6, -483.82, -109.01))
            end
        })

        lib.zones.sphere({
            coords = vector3(91.27, -493.74, -109.01),
            radius = 6.0,
            debug = false,
            inside = function()
                HandleClothingZone(vector3(91.27, -493.74, -109.01))
            end
        })
    end

    local tmp = false
    for k, v in pairs(Config.Motels) do
        if not Config.UseTarget then
            lib.zones.sphere({
                coords = vector3(v.buyMotel.x, v.buyMotel.y, v.buyMotel.z),
                radius = 18.0,
                debug = false,
                inside = function()
                    currentZone = k
                    HandleBuyMotelZone(vector3(v.buyMotel.x, v.buyMotel.y, v.buyMotel.z))
                end
            })

            -- My Rooms Zone
            lib.zones.sphere({
                coords = vector3(v.myRooms.x, v.myRooms.y, v.myRooms.z),
                radius = 18.0,
                debug = false,
                inside = function()
                    currentZone = k
                    HandleMotelRoomsZone(vector3(v.myRooms.x, v.myRooms.y, v.myRooms.z))
                end
            })
        else
            local buyModelHash = GetHashKey(v.buyMotelPed)
            if not HasModelLoaded(buyModelHash) then
                if lib and lib.requestModel then
                    lib.requestModel(buyModelHash, 5000)
                else
                    RequestModel(buyModelHash)
                    local timeout = 0
                    while not HasModelLoaded(buyModelHash) and timeout < 50 do
                        Wait(100)
                        timeout = timeout + 1
                    end
                end
            end
            if not HasModelLoaded(buyModelHash) then return end

            pcall(function() exports['FeloxAC']:CreatePed(buyModelHash) end) --[[FeloxAC:auto]]
            local ped = CreatePed(4, buyModelHash, v.buyMotel.x, v.buyMotel.y, v.buyMotel.z -1, v.buyMotel.w, false, false)
            SetEntityHeading(ped, v.buyMotel.w)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedDiesWhenInjured(ped, false)
            SetPedCanRagdoll(ped, false)

            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:addBoxZone({
                    coords = v.buyMotel.xyz,
                    size = vec3(1, 1, 1),
                    rotation = 0,
                    drawSprite = true,
                    options = {
                        {
                            name = 'izzy-motels-' .. ped,
                            icon = 'fa-solid fa-briefcase',
                            label = MotelText(k, 'OpenBuyMenu'),
                            onSelect = function()
                                currentZone = k
                                OpenBuyMotelMenu()
                            end,
                            distance = 2.0
                        },
                    },
                })
            else
                exports['qb-target']:AddTargetEntity(ped, {
                    options = {
                        {
                            label = MotelText(k, 'OpenBuyMenu'),
                            icon = "fas fa-briefcase",
                            action = function()
                                currentZone = k
                                OpenBuyMotelMenu()
                            end
                        }
                    },
                    distance = 2.0
                })
            end

            local roomsModelHash = GetHashKey(v.myRoomsPed)
            if not HasModelLoaded(roomsModelHash) then
                if lib and lib.requestModel then
                    lib.requestModel(roomsModelHash, 5000)
                else
                    RequestModel(roomsModelHash)
                    local timeout = 0
                    while not HasModelLoaded(roomsModelHash) and timeout < 50 do
                        Wait(100)
                        timeout = timeout + 1
                    end
                end
            end
            if not HasModelLoaded(roomsModelHash) then return end

            pcall(function() exports['FeloxAC']:CreatePed(roomsModelHash) end) --[[FeloxAC:auto]]
            local ped = CreatePed(4, roomsModelHash, v.myRooms.x, v.myRooms.y, v.myRooms.z -1, v.myRooms.w, false, false)
            SetEntityHeading(ped, v.myRooms.w)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedDiesWhenInjured(ped, false)
            SetPedCanRagdoll(ped, false)

            if GetResourceState('ox_target') == 'started' then
                exports.ox_target:addBoxZone({
                    coords = v.myRooms.xyz,
                    size = vec3(1, 1, 1),
                    rotation = 0,
                    drawSprite = true,
                    options = {
                        {
                            name = 'izzy-motels-' .. ped,
                            icon = 'fa-solid fa-briefcase',
                            label = MotelText(k, 'OpenMyRoomMenu'),
                            onSelect = function()
                                currentZone = k
                                OpenMotelsMenu()
                            end,
                            distance = 2.0
                        },
                    },
                })
            else
                exports['qb-target']:AddTargetEntity(ped, {
                    options = {
                        {
                            label = MotelText(k, 'OpenMyRoomMenu'),
                            icon = "fas fa-briefcase",
                            action = function()
                                currentZone = k
                                OpenMotelsMenu()
                            end
                        }
                    },
                    distance = 2.0
                })
            end

            if not tmp then
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addBoxZone({
                        coords = vector3(94.06, -486.0, -108.85),
                        size = vec3(1, 1, 1),
                        rotation = 0,
                        drawSprite = true,
                        options = {
                            {
                                name = 'roomActions-open',
                                icon = 'fa-solid fa-tablet',
                                label = Config.Local.ExitRoom,
                                onSelect = ExitMotelRoom,
                                distance = 1.5
                            },
                            {
                                name = 'roomActions-invite',
                                icon = 'fa-solid fa-tablet',
                                label = Config.Local.InviteFriends,
                                onSelect = OpenInviteMenu,
                                canInteract = function()
                                    local response = lib.callback.await('izzy-motels:server:doIOwnedThisRoom', false, currentZone, currentRoom)
                                    return response
                                end,
                                distance = 1.5
                            },
                        },
                    })

                    exports.ox_target:addBoxZone({
                        coords = vector3(89.0953, -492.8885, -109.2455),
                        size = vec3(1, 1, 1),
                        rotation = 0,
                        drawSprite = true,
                        options = {
                            {
                                name = 'roomActions-stash',
                                icon = 'fa-solid fa-warehouse',
                                label = Config.Local.OpenStash,
                                onSelect = function()
                                    if currentRoom == nil then
                                        return Framework:Notify(Config.Local.NeedToBeInRoom, "error")
                                    end
    
                                    if currentZone == nil then
                                        return Framework:Notify(MotelText(currentZone, 'NeedToBeInMotel'), "error")
                                    end
    
                                    Framework:OpenStash(currentRoom, currentZone)
                                end,
                                distance = 1.5
                            },
                            {
                                name = 'roomActions-wardrobe',
                                icon = 'fa-solid fa-tshirt',
                                label = Config.Local.OpenWardobe,
                                onSelect = function()
                                    Framework:OpenClothing()
                                end,
                                distance = 1.5
                            },
                        },
                    })
                else
                    exports['qb-target']:AddCircleZone("roomActions", vector3(93.47, -486.02, -108.01), 1.0, {
                        name = "roomActions",
                        debugPoly = false,
                    },
                    {
                        options = {
                            {
                                icon = 'fas fa-door-open', -- This is the icon that will display next to this trigger option
                                label = Config.Local.ExitRoom, -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                                action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                                    ExitMotelRoom()
                                end,
                            },
                            {
                                icon = 'fas fa-door-open',
                                label = Config.Local.InviteFriends,
                                action = function()
                                    OpenInviteMenu()
                                end,
                                canInteract = function()
                                    local response = lib.callback.await('izzy-motels:server:doIOwnedThisRoom', false, currentZone, currentRoom)
                                    return response
                                end
                            }
                        },
                        distance = 1.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
                    })
                    
                    exports['qb-target']:AddCircleZone("moteldepo", vector3(89.0953, -492.8885, -109.2455), 1.0, {
                        name = "moteldepo",
                        debugPoly = false,
                    },
                    {
                        options = {
                            {
                                icon = 'fas fa-warehouse', -- This is the icon that will display next to this trigger option
                                label = Config.Local.OpenStash, -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                                action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                                    if currentRoom == nil then
                                        return Framework:Notify(Config.Local.NeedToBeInRoom, "error")
                                    end
    
                                    if currentZone == nil then
                                        return Framework:Notify(MotelText(currentZone, 'NeedToBeInMotel'), "error")
                                    end
    
                                    Framework:OpenStash(currentRoom, currentZone)
                                end,
                            },
                            {
                                icon = 'fas fa-tshirt', -- This is the icon that will display next to this trigger option
                                label = Config.Local.OpenWardobe, -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                                action = function() -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                                    Framework:OpenClothing()
                                end,
                            }
                        },
                        distance = 1.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
                    })
                end
            end
            tmp = true
        end 
    end
    tmp = false
end)

RegisterNUICallback('rentRoom', function(data, cb)
    local response = lib.callback.await('izzy-motels:server:rentRoom', false, currentZone, data.room, data.color, data.days)

    SetNuiFocus(false, false)
    menuOpened = false

    if response then
        EnterMotelRoom(data.room)
    end

    cb(response)
    SendNUIMessage({ action = "close" })
end)

RegisterNUICallback('goRoom', function(data, cb)
    SetNuiFocus(false, false)
    menuOpened = false
    EnterMotelRoom(data.room)
    cb(true)
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    local response = lib.callback.await('izzy-motels:server:invitePlayer', false, currentZone, currentRoom, data.id)
    cb(true)
end)

RegisterNUICallback('exitRoom', function(data, cb)
    SetNuiFocus(false, false)
    menuOpened = false
    ExitMotelRoom()
    cb(true)
end)

RegisterNetEvent('izzy-motels:client:invitePlayer')
AddEventHandler('izzy-motels:client:invitePlayer', function(motelId, roomId)
    CreateInviteJob(motelId, roomId)
end)