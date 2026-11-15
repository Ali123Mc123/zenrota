---@diagnostic disable: undefined-global
local isStatus = false

local textUiShown = false

local function OpenBossMenu(index)
    lib.registerContext({
        id = 'carwash_boss_menu',
        title = 'İşletme Yönetimi - ' .. Settings.Locations[index].name,
        options = {
            {
                title = 'Kasa Yönetimi',
                description = 'Dükkan kasasındaki parayı gör ve çek',
                icon = 'fas fa-wallet',
                onSelect = function()
                    local stats = lib.callback.await('can9work-carwash:server:getBusinessStats', false, index)
                    if stats then
                        lib.registerContext({
                            id = 'carwash_cash_menu',
                            title = 'Kasa: $' .. stats.balance,
                            menu = 'carwash_boss_menu',
                            options = {
                                {
                                    title = 'Para Çek',
                                    icon = 'fas fa-hand-holding-usd',
                                    onSelect = function()
                                        local input = lib.inputDialog('Para Çek',
                                            { { type = 'number', label = 'Miktar', min = 1 } })
                                        if input then
                                            TriggerServerEvent('can9work-carwash:server:WithdrawCash', index, input[1])
                                        end
                                    end
                                }
                            }
                        })
                        lib.showContext('carwash_cash_menu')
                    end
                end
            },
            {
                title = 'Fiyat Yönetimi',
                description = 'Hizmet bedelini güncelle (%50 - %200 aralığında)',
                icon = 'fas fa-tag',
                onSelect = function()
                    local input = lib.inputDialog('Fiyat Güncelle', {
                        { type = 'number', label = 'Yeni Fiyat', placeholder = 'Örn: 1000', min = 1 }
                    })

                    if input then
                        local success, message = lib.callback.await('can9work-carwash:server:UpdatePrice', false, index,
                            input[1])
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
    lib.showContext('carwash_boss_menu')
end

for index, location in pairs(Settings.Locations) do
    lib.zones.sphere({
        coords = location.carwash,
        radius = 5.0,
        debug = false,
        inside = function()
            local playerPed = cache.ped
            if not isStatus and IsPedInAnyVehicle(playerPed, false) then
                if not textUiShown then
                    lib.showTextUI('[E] - Araç Yıkama', {
                        position = "left-center",
                        icon = 'hot-tub-person',
                    })
                    textUiShown = true
                end

                if IsControlJustPressed(0, 38) then
                    local isOwner = lib.callback.await('can9work-carwash:server:isCarwashOwner', false, index)
                    local currentPrice = lib.callback.await('can9work-carwash:server:GetCarwashPrice', false, index) or
                        Settings.price

                    if isOwner then
                        lib.registerContext({
                            id = 'carwash_owner_choice',
                            title = 'Araç Yıkama Yönetimi',
                            options = {
                                {
                                    title = 'Aracı Yıka',
                                    description = 'Yıkarma paketlerini gör',
                                    icon = 'fas fa-shower',
                                    onSelect = function()
                                        TriggerEvent('can9work-carwash:client:OpenWashMenu', index, currentPrice)
                                    end
                                },
                                {
                                    title = 'İşletme Yönetimi',
                                    description = 'Kasa ve Fiyat Ayarları',
                                    icon = 'fas fa-briefcase',
                                    onSelect = function()
                                        OpenBossMenu(index)
                                    end
                                }
                            }
                        })
                        lib.showContext('carwash_owner_choice')
                    else
                        TriggerEvent('can9work-carwash:client:OpenWashMenu', index, currentPrice)
                    end
                end
            else
                if textUiShown then
                    lib.hideTextUI()
                    textUiShown = false
                end
            end
        end,
        onExit = function()
            if textUiShown then
                lib.hideTextUI()
                textUiShown = false
            end
        end
    })
end

RegisterNetEvent('can9work-carwash:client:OpenWashMenu', function(index, basePrice)
    local options = {}
    for _, pkg in ipairs(Settings.Packages) do
        local finalPrice = math.floor(basePrice * pkg.priceMultiplier)
        table.insert(options, {
            title = pkg.label,
            description = pkg.description .. " | Fiyat: " .. finalPrice .. "$",
            icon = pkg.icon,
            onSelect = function()
                TriggerEvent('can9work-carwash:client:StartWash', index, pkg, finalPrice)
            end
        })
    end

    lib.registerContext({
        id = 'carwash_main_menu',
        title = 'Araç Yıkama Paketleri',
        options = options
    })
    lib.showContext('carwash_main_menu')
end)

RegisterNetEvent('can9work-carwash:client:StartWash', function(index, pkg, price)
    if isStatus then return end
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if not vehicle or vehicle == 0 then return end

    local success, message = lib.callback.await('can9work-carwash:server:PayForWash', false, index, pkg.id)

    if not success then
        lib.notify({ title = 'Hata', description = message or 'Yetersiz bakiye.', type = 'error' })
        return
    end

    isStatus = true
    FreezeEntityPosition(vehicle, true)
    lib.hideTextUI()

    AnimpostfxPlay("MinigameTransitionIn", 0, true)

    local progressBarSuccess = lib.progressBar({
        duration = pkg.duration,
        label = pkg.label .. ' Yapılıyor...',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true }
    })

    if progressBarSuccess then
        local currentDirt = GetVehicleDirtLevel(vehicle)

        for i = currentDirt, 0, -0.5 do
            SetVehicleDirtLevel(vehicle, i)
            Wait(100)
        end

        SetVehicleDirtLevel(vehicle, 0.0)
        WashDecalsFromVehicle(vehicle, 1.0)

        if pkg.id == "premium" or pkg.id == "detail" then
            pcall(function() exports['FeloxAC']:MarkVehicleRepair() end) --[[FeloxAC:auto]]
            SetVehicleFixed(vehicle)
            SetVehicleEnveffScale(vehicle, 0.0)
        end

        if pkg.id == "detail" then
            local health = GetVehicleEngineHealth(vehicle)
            if health < 1000.0 then
                SetVehicleEngineHealth(vehicle, math.min(1000.0, health + 100.0))
            end
        end
    end


    AnimpostfxStop("MinigameTransitionIn")
    FreezeEntityPosition(vehicle, false)
    isStatus = false
    lib.notify({ title = 'Başarılı', description = 'Aracınız tertemiz oldu!', type = 'success' })
end)

exports("GetCarwashCoords", function()
    local coords = {}
    for _, location in pairs(Settings.Locations) do
        coords[#coords + 1] = location.carwash
    end
    return coords
end)

-- can9work-auction'in isletme NPC'sinden: yikama fiyati (businessId: wash_3; sahiplik sunucuda kontrol edilir).
exports('OpenBusinessPrice', function(businessId)
    local index = tonumber(tostring(businessId):match('^wash_(%d+)$'))
    if not index or not Settings.Locations[index] then return end
    local input = lib.inputDialog('Yıkama Fiyatı', {
        { type = 'number', label = 'Yeni fiyat', required = true, min = math.floor(Settings.price * 0.5), max = math.floor(Settings.price * 2.0),
            description = ('$%d ile $%d arası'):format(math.floor(Settings.price * 0.5), math.floor(Settings.price * 2.0)) }
    })
    if not input then return end
    local success, message = lib.callback.await('can9work-carwash:server:UpdatePrice', false, index, input[1])
    lib.notify({ title = success and 'Başarılı' or 'Hata', description = message, type = success and 'success' or 'error' })
end)
