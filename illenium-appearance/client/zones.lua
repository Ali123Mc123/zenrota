if Config.UseTarget then return end
currentZone = nil

local Zones = {
    Store = {},
    ClothingRoom = {},
    PlayerOutfitRoom = {}
}

local function RemoveZones()
    for i = 1, #Zones.Store do
        if Zones.Store[i]["remove"] then
            Zones.Store[i]:remove()
        end
    end
    for i = 1, #Zones.ClothingRoom do
        Zones.ClothingRoom[i]:remove()
    end
    for i = 1, #Zones.PlayerOutfitRoom do
        Zones.PlayerOutfitRoom[i]:remove()
    end
end

local function lookupZoneIndexFromID(zones, id)
    for i = 1, #zones do
        if zones[i].id == id then
            return i
        end
    end
end

local function lookupTypeIndex(globalIndex, shopType)
    local typeIndex = 0
    for i = 1, globalIndex do
        if Config.Stores[i].type == shopType then
            typeIndex = typeIndex + 1
        end
    end
    return typeIndex
end

local function onStoreEnter(data)
    local index = lookupZoneIndexFromID(Zones.Store, data.id)
    local store = Config.Stores[index]

    local jobName = (store.job and client.job.name) or (store.gang and client.gang.name)
    if jobName == (store.job or store.gang) then
        local zone = {
            name = store.type,
            index = index,
            businessId = store.businessId
        }
        currentZone = zone
        local businessId = store.businessId or (zone.name .. "_" .. zone.index)
        local dynamicPrice = lib.callback.await("illenium-appearance:server:getShopPrice", false, zone.name,
            businessId)

        local prefix = Config.UseRadialMenu and "" or "[E] "
        if zone.name == "clothing" then
            lib.showTextUI(prefix .. string.format(_L("textUI.clothing"), dynamicPrice), Config.TextUIOptions)
        elseif zone.name == "barber" then
            lib.showTextUI(prefix .. string.format(_L("textUI.barber"), dynamicPrice), Config.TextUIOptions)
        elseif zone.name == "tattoo" then
            lib.showTextUI(prefix .. string.format(_L("textUI.tattoo"), dynamicPrice), Config.TextUIOptions)
        elseif zone.name == "surgeon" then
            lib.showTextUI(prefix .. string.format(_L("textUI.surgeon"), dynamicPrice), Config.TextUIOptions)
        end
        Radial.AddOption(zone)
    end
end

local function onClothingRoomEnter(data)
    local index = lookupZoneIndexFromID(Zones.ClothingRoom, data.id)
    local clothingRoom = Config.ClothingRooms[index]

    local jobName = clothingRoom.job and client.job.name or client.gang.name
    if jobName == (clothingRoom.job or clothingRoom.gang) then
        if CheckDuty() or clothingRoom.gang then
            currentZone = {
                name = "clothingRoom",
                index = index
            }
            local prefix = Config.UseRadialMenu and "" or "[E] "
            lib.showTextUI(prefix .. _L("textUI.clothingRoom"), Config.TextUIOptions)
            Radial.AddOption(currentZone)
        end
    end
end

local function onPlayerOutfitRoomEnter(data)
    local index = lookupZoneIndexFromID(Zones.PlayerOutfitRoom, data.id)
    local playerOutfitRoom = Config.PlayerOutfitRooms[index]

    local isAllowed = IsPlayerAllowedForOutfitRoom(playerOutfitRoom)
    if isAllowed then
        currentZone = {
            name = "playerOutfitRoom",
            index = index
        }
        local prefix = Config.UseRadialMenu and "" or "[E] "
        lib.showTextUI(prefix .. _L("textUI.playerOutfitRoom"), Config.TextUIOptions)
        Radial.AddOption(currentZone)
    end
end

local function onZoneExit()
    currentZone = nil
    Radial.RemoveOption()
    lib.hideTextUI()
end

local function SetupZone(store, onEnter, onExit)
    if Config.RCoreTattoosCompatibility and store.type == "tattoo" then
        return {}
    end

    if Config.UseRadialMenu or store.usePoly then
        return lib.zones.poly({
            points = store.points,
            debug = Config.Debug,
            onEnter = onEnter,
            onExit = onExit
        })
    end

    return lib.zones.box({
        coords = store.coords,
        size = store.size,
        rotation = store.rotation,
        debug = Config.Debug,
        onEnter = onEnter,
        onExit = onExit
    })
end

local function SetupStoreZones()
    for _, v in pairs(Config.Stores) do
        Zones.Store[#Zones.Store + 1] = SetupZone(v, onStoreEnter, onZoneExit)
    end
end

local function SetupClothingRoomZones()
    for _, v in pairs(Config.ClothingRooms) do
        Zones.ClothingRoom[#Zones.ClothingRoom + 1] = SetupZone(v, onClothingRoomEnter, onZoneExit)
    end
end

local function SetupPlayerOutfitRoomZones()
    for _, v in pairs(Config.PlayerOutfitRooms) do
        Zones.PlayerOutfitRoom[#Zones.PlayerOutfitRoom + 1] = SetupZone(v, onPlayerOutfitRoomEnter, onZoneExit)
    end
end

local function SetupZones()
    SetupStoreZones()
    SetupClothingRoomZones()
    SetupPlayerOutfitRoomZones()
end

local function OpenBusinessMenu(businessId)
    local shopType = currentZone.name
    lib.registerContext({
        id = 'illenium_appearance_business_menu',
        title = 'İşletme Yönetimi',
        options = {
            {
                title = 'Kasa Yönetimi',
                description = 'Dükkan kasasındaki parayı gör ve çek',
                icon = 'fas fa-wallet',
                onSelect = function()
                    local stats = lib.callback.await('cloud-shop:server:getBusinessStats', false, businessId)
                    if stats then
                        lib.registerContext({
                            id = 'illenium_appearance_cash_menu',
                            title = 'Kasa: $' .. stats.balance,
                            menu = 'illenium_appearance_business_menu',
                            options = {
                                {
                                    title = 'Para Çek',
                                    icon = 'fas fa-hand-holding-usd',
                                    onSelect = function()
                                        local input = lib.inputDialog('Para Çek',
                                            { { type = 'number', label = 'Miktar', min = 1 } })
                                        if input then
                                            local success = lib.callback.await('cloud-shop:server:manageFunds', false,
                                                businessId, 'withdraw', input[1])
                                            if success then
                                                lib.notify({
                                                    title = 'Başarılı',
                                                    description = '$' .. input[1] .. ' başarıyla çekildi.',
                                                    type = 'success'
                                                })
                                            else
                                                lib.notify({
                                                    title = 'Hata',
                                                    description = 'Para çekme işlemi başarısız!',
                                                    type = 'error'
                                                })
                                            end
                                            OpenBusinessMenu(businessId) -- Menüyü tazele
                                        end
                                    end
                                }
                            }
                        })
                        lib.showContext('illenium_appearance_cash_menu')
                    end
                end
            },
            {
                title = 'Fiyat Yönetimi',
                description = 'Hizmet bedelini güncelle (%50 - %200 aralığında)',
                icon = 'fas fa-tag',
                onSelect = function()
                    local input = lib.inputDialog('Fiyat Güncelle', {
                        { type = 'number', label = 'Yeni Fiyat', placeholder = 'Örn: 100', min = 1 }
                    })

                    if input then
                        local success, message = lib.callback.await('illenium-appearance:server:updatePrice', false,
                            businessId, input[1], shopType)
                        lib.notify({
                            title = success and 'Başarılı' or 'Hata',
                            description = message,
                            type = success and 'success' or 'error'
                        })
                    end
                end
            }
        }
    })
    lib.showContext('illenium_appearance_business_menu')
end

local function OpenShopByType(zone)
    if zone.name == "clothingRoom" then
        local clothingRoom = Config.ClothingRooms[zone.index]
        local outfits = GetPlayerJobOutfits(clothingRoom.job)
        TriggerEvent("illenium-appearance:client:openJobOutfitsMenu", outfits)
    elseif zone.name == "playerOutfitRoom" then
        local outfitRoom = Config.PlayerOutfitRooms[zone.index]
        OpenOutfitRoom(outfitRoom)
    elseif zone.name == "clothing" then
        TriggerEvent("illenium-appearance:client:openClothingShopMenu")
    elseif zone.name == "barber" then
        OpenBarberShop()
    elseif zone.name == "tattoo" then
        OpenTattooShop()
    elseif zone.name == "surgeon" then
        OpenSurgeonShop()
    end
end

local function ZonesLoop()
    Wait(1000)
    while true do
        local sleep = 1000
        if currentZone then
            sleep = 5
            -- E Tuşu: Mağazayı açar
            if IsControlJustReleased(0, 38) then
                 local zone = currentZone
                 local businessId = zone.businessId or (zone.name .. "_" .. zone.index)
                local isOwner = lib.callback.await('illenium-appearance:server:isStoreOwner', false, businessId)

                if isOwner then
                    -- Eğer gerçekten sahipse seçim menüsü aç
                    lib.registerContext({
                        id = 'illenium_appearance_owner_choice',
                        title = 'Mağaza Yönetimi',
                        options = {
                            {
                                title = 'Mağazayı Aç',
                                icon = 'fas fa-shop',
                                onSelect = function()
                                    OpenShopByType(zone)
                                end
                            },
                            {
                                title = 'İşletme Yönetimi',
                                description = 'Kasa ve Fiyat Ayarları',
                                icon = 'fas fa-briefcase',
                                onSelect = function()
                                    OpenBusinessMenu(businessId)
                                end
                            }
                        }
                    })
                    lib.showContext('illenium_appearance_owner_choice')
                else
                    -- Sahibi değilse direkt mağazayı aç
                    OpenShopByType(zone)
                end
            end
        end
        Wait(sleep)
    end
end

CreateThread(function()
    SetupZones()
    if not Config.UseRadialMenu then
        ZonesLoop()
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        RemoveZones()
    end
end)

RegisterNetEvent("illenium-appearance:client:OpenClothingRoom", function()
    local clothingRoom = Config.ClothingRooms[currentZone.index]
    local outfits = GetPlayerJobOutfits(clothingRoom.job)
    TriggerEvent("illenium-appearance:client:openJobOutfitsMenu", outfits)
end)

RegisterNetEvent("illenium-appearance:client:OpenPlayerOutfitRoom", function()
    local outfitRoom = Config.PlayerOutfitRooms[currentZone.index]
    OpenOutfitRoom(outfitRoom)
end)

-- can9work-auction'in isletme NPC'sinden: hizmet fiyatini degistir (sahiplik sunucuda kontrol edilir).
exports("OpenBusinessPrice", function(businessId)
    local shopType = tostring(businessId):match("^(%a+)_%d+$")
    local base = shopType == "barber" and Config.BarberCost or Config.ClothingCost
    local current = lib.callback.await("illenium-appearance:server:getShopPrice", false, shopType, businessId)
    local input = lib.inputDialog("Hizmet Fiyatı", {
        {
            type = "number", label = "Yeni fiyat", default = tonumber(current) or base, required = true,
            min = math.floor(base * 0.5), max = math.floor(base * 2.0),
            description = ("$%d ile $%d arası"):format(math.floor(base * 0.5), math.floor(base * 2.0))
        }
    })
    if not input then return end
    local success, message = lib.callback.await("illenium-appearance:server:updatePrice", false, businessId, input[1], shopType)
    lib.notify({ title = success and "Başarılı" or "Hata", description = message, type = success and "success" or "error" })
end)
