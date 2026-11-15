---@diagnostic disable: need-check-nil
local function openLocationMenu(shop)
    local options = {
        {
            title = '📍 Bulunduğum Yere Taşı',
            description = 'Dükkanın NPC ve etkileşim noktasını şu an bulunduğunuz konuma getirir.',
            icon = 'location-crosshairs',
            arrow = true,
            onSelect = function()
                local ped = cache.ped or PlayerPedId()
                local pCoords = GetEntityCoords(ped)
                local pHeading = GetEntityHeading(ped)

                -- Zemin Z seviyesini tespit et (NPC havada kalmasın)
                local foundGround, groundZ = GetGroundZFor_3dCoord(pCoords.x, pCoords.y, pCoords.z, false)
                local finalZ = foundGround and groundZ or pCoords.z
                local targetCoords = vector3(pCoords.x, pCoords.y, finalZ)

                local confirm = lib.alertDialog({
                    header = 'Dükkan Konumu Taşıma',
                    content = string.format('**%s** dükkanını bulunduğunuz konuma taşımak istiyor musunuz?\n\n**Yeni Koordinat:**\nvector4(%.2f, %.2f, %.2f, %.2f)', shop.name, targetCoords.x, targetCoords.y, targetCoords.z, pHeading),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then
                    openLocationMenu(shop)
                    return
                end

                local res = lib.callback.await('qbx_pawnshop:server:updateLocation', false, shop.id, targetCoords, pHeading, false)
                if res and res.success then
                    exports.qbx_core:Notify(string.format('%s dükkanı yeni konumuna taşındı!', shop.name), 'success')
                    shop.coords = targetCoords
                    shop.heading = pHeading
                    shop.isCoordsOverridden = true
                else
                    exports.qbx_core:Notify(res and res.message or 'Konum güncellenemedi!', 'error')
                end
                openLocationMenu(shop)
            end
        },
        {
            title = '⚡ Mevcut Konuma Işınlan (TP)',
            description = string.format('Dükkanın şu anki koordinatlarına ışınlanırsınız.\nvector3(%.2f, %.2f, %.2f)', shop.coords.x, shop.coords.y, shop.coords.z),
            icon = 'bolt',
            onSelect = function()
                local ped = cache.ped or PlayerPedId()
                pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                SetEntityCoords(ped, shop.coords.x, shop.coords.y, shop.coords.z + 0.1, false, false, false, false)
                SetEntityHeading(ped, shop.heading or 0.0)
                exports.qbx_core:Notify(string.format('%s konumuna ışınlandınız.', shop.name), 'inform')
                TriggerServerEvent('qbx_pawnshop:server:logTeleport', shop.id)
                openLocationMenu(shop)
            end
        },
        {
            title = '✍️ Manuel Koordinat Gir',
            description = 'X, Y, Z ve Heading değerlerini elle girerek dükkanı taşıyın.',
            icon = 'pen-to-square',
            arrow = true,
            onSelect = function()
                local input = lib.inputDialog(string.format('%s - Manuel Koordinat', shop.name), {
                    { type = 'input', label = 'X Koordinatı', default = tostring(math.floor(shop.coords.x * 100) / 100), required = true },
                    { type = 'input', label = 'Y Koordinatı', default = tostring(math.floor(shop.coords.y * 100) / 100), required = true },
                    { type = 'input', label = 'Z Koordinatı', default = tostring(math.floor(shop.coords.z * 100) / 100), required = true },
                    { type = 'input', label = 'Heading (Açı)', default = tostring(math.floor((shop.heading or 0.0) * 100) / 100), required = true }
                })

                if not input then
                    openLocationMenu(shop)
                    return
                end

                local x, y, z, h = tonumber(input[1]), tonumber(input[2]), tonumber(input[3]), tonumber(input[4])
                if not x or not y or not z or not h then
                    exports.qbx_core:Notify('Geçersiz koordinat değeri girdiniz!', 'error')
                    openLocationMenu(shop)
                    return
                end

                local targetCoords = vector3(x, y, z)
                local res = lib.callback.await('qbx_pawnshop:server:updateLocation', false, shop.id, targetCoords, h, false)
                if res and res.success then
                    exports.qbx_core:Notify(string.format('%s dükkanı manuel koordinatına taşındı!', shop.name), 'success')
                    shop.coords = targetCoords
                    shop.heading = h
                    shop.isCoordsOverridden = true
                else
                    exports.qbx_core:Notify(res and res.message or 'Konum güncellenemedi!', 'error')
                end
                openLocationMenu(shop)
            end
        },
        {
            title = '🔄 Orijinal Konuma Sıfırla (Fabrika Ayarı)',
            description = string.format('Dükkanı config dosyasındaki orijinal konumuna geri döndürür.\nvector4(%.2f, %.2f, %.2f, %.2f)', shop.defaultCoords.x, shop.defaultCoords.y, shop.defaultCoords.z, shop.defaultCoords.w),
            icon = 'rotate-left',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Konum Sıfırlama Onayı',
                    content = string.format('**%s** dükkanının konumunu orijinal fabrika ayarlarına sıfırlamak istediğinize emin misiniz?', shop.name),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then
                    openLocationMenu(shop)
                    return
                end

                local res = lib.callback.await('qbx_pawnshop:server:updateLocation', false, shop.id, nil, nil, true)
                if res and res.success then
                    exports.qbx_core:Notify(string.format('%s dükkanı orijinal konumuna sıfırlandı!', shop.name), 'success')
                    shop.coords = vector3(shop.defaultCoords.x, shop.defaultCoords.y, shop.defaultCoords.z)
                    shop.heading = shop.defaultCoords.w
                    shop.isCoordsOverridden = false
                else
                    exports.qbx_core:Notify(res and res.message or 'Konum sıfırlanamadı!', 'error')
                end
                openLocationMenu(shop)
            end
        }
    }

    lib.registerContext({
        id = 'pawnshop_admin_location',
        title = '📍 Konum: ' .. shop.name,
        menu = 'pawnshop_admin_shop_sub',
        options = options
    })
    lib.showContext('pawnshop_admin_location')
end

local function openPriceMenu(shop)
    local options = {}

    -- Tüm fiyatları fabrika ayarlarına sıfırla butonu
    table.insert(options, {
        title = '🔄 Tüm Fiyatları Fabrika Ayarına Sıfırla',
        description = 'Bu dükkandaki tüm eşyaların satış fiyatlarını orijinal config ayarlarına döndürür.',
        icon = 'rotate-left',
        onSelect = function()
            local confirm = lib.alertDialog({
                header = 'Fiyat Sıfırlama Onayı',
                content = string.format('**%s** dükkanındaki tüm eşya fiyatlarını orijinal varsayılan değerlerine döndürmek istediğinize emin misiniz?', shop.name),
                centered = true,
                cancel = true
            })

            if confirm ~= 'confirm' then
                openPriceMenu(shop)
                return
            end

            local res = lib.callback.await('qbx_pawnshop:server:updatePrice', false, shop.id, nil, nil, true)
            if res and res.success then
                exports.qbx_core:Notify(string.format('%s dükkanındaki tüm fiyatlar fabrika ayarlarına sıfırlandı!', shop.name), 'success')
                for _, item in ipairs(shop.items) do
                    item.price = item.defaultPrice
                end
                shop.isPricesOverridden = false
            else
                exports.qbx_core:Notify(res and res.message or 'Fiyatlar sıfırlanamadı!', 'error')
            end
            openPriceMenu(shop)
        end
    })

    if shop.items and #shop.items > 0 then
        for _, item in ipairs(shop.items) do
            local isOverridden = item.price ~= item.defaultPrice
            local badge = isOverridden and ' (Özel Fiyat)' or ''

            table.insert(options, {
                title = string.format('%s (%s)%s', item.label, item.item, badge),
                description = string.format('Güncel Fiyat: $%s | Orijinal: $%s', item.price, item.defaultPrice),
                icon = 'tag',
                arrow = true,
                onSelect = function()
                    local isOxShop = shop.type == 'ox_shop'
                    local dialogLabel = isOxShop and 'Yeni Satış Fiyatı ($)' or 'Yeni Alım Fiyatı ($)'
                    local dialogDesc = isOxShop
                        and string.format('Oyuncunun bu eşyayı satın alacağı birim fiyat (Varsayılan: $%s)', item.defaultPrice)
                        or string.format('Oyuncunun bu eşyayı satarken alacağı birim fiyat (Varsayılan: $%s)', item.defaultPrice)

                    local input = lib.inputDialog(string.format('%s - Fiyat Belirle', item.label), {
                        {
                            type = 'number',
                            label = dialogLabel,
                            description = dialogDesc,
                            default = item.price,
                            min = 0,
                            max = 10000000,
                            required = true
                        }
                    })

                    if not input or not input[1] then
                        openPriceMenu(shop)
                        return
                    end

                    local newPrice = tonumber(input[1])
                    local res = lib.callback.await('qbx_pawnshop:server:updatePrice', false, shop.id, item.item, newPrice, false)
                    if res and res.success then
                        exports.qbx_core:Notify(string.format('%s için yeni birim fiyat: $%s', item.label, newPrice), 'success')
                        item.price = newPrice
                        shop.isPricesOverridden = true
                    else
                        exports.qbx_core:Notify(res and res.message or 'Fiyat güncellenemedi!', 'error')
                    end
                    openPriceMenu(shop)
                end
            })
        end
    else
        table.insert(options, {
            title = 'Eşya Bulunamadı',
            description = 'Bu dükkanda herhangi bir eşya tanımlı değil.',
            icon = 'circle-exclamation',
            disabled = true
        })
    end

    lib.registerContext({
        id = 'pawnshop_admin_prices',
        title = '💰 Fiyat: ' .. shop.name,
        menu = 'pawnshop_admin_shop_sub',
        options = options
    })
    lib.showContext('pawnshop_admin_prices')
end

local function openShopSubMenu(shop)
    local statusParts = {}
    if shop.isCoordsOverridden then table.insert(statusParts, '📍 Konum Özel') end
    if shop.isPricesOverridden then table.insert(statusParts, '💰 Fiyat Özel') end
    local statusText = #statusParts > 0 and table.concat(statusParts, ' | ') or '🟢 Fabrika Ayarları Aktif'

    lib.registerContext({
        id = 'pawnshop_admin_shop_sub',
        title = shop.name .. ' (' .. shop.key .. ')',
        menu = 'pawnshop_admin_main',
        options = {
            {
                title = '📍 Konum Yönetimi',
                description = string.format('Dükkan koordinatını taşı, ışınlan veya sıfırla.\nDurum: %s', shop.isCoordsOverridden and 'Özel Konum' or 'Orijinal Konum'),
                icon = 'map-location-dot',
                arrow = true,
                onSelect = function()
                    openLocationMenu(shop)
                end
            },
            {
                title = '💰 Fiyat Yönetimi',
                description = string.format('%s fiyatlarını düzenle veya sıfırla.\nDurum: %s', shop.type == 'ox_shop' and 'Dükkandaki satış' or 'Satılan eşyaların', shop.isPricesOverridden and 'Özel Fiyatlar' or 'Orijinal Fiyatlar'),
                icon = 'money-bill-wave',
                arrow = true,
                onSelect = function()
                    openPriceMenu(shop)
                end
            }
        }
    })
    lib.showContext('pawnshop_admin_shop_sub')
end

local function openAdminMainMenu()
    local shops = lib.callback.await('qbx_pawnshop:server:getAdminShops', false)
    if not shops then
        exports.qbx_core:Notify('Bu menüye erişim yetkiniz bulunmuyor!', 'error')
        return
    end

    local options = {}
    for _, shop in ipairs(shops) do
        local statusParts = {}
        if shop.isCoordsOverridden then
            table.insert(statusParts, '📍 Özel Konum')
        end
        if shop.isPricesOverridden then
            table.insert(statusParts, '💰 Özel Fiyat')
        end
        local statusBadge = #statusParts > 0 and table.concat(statusParts, ' | ') or '🟢 Fabrika Ayarı'
        local desc = string.format('Meslek/Kısıtlama: %s\nDurum: %s', shop.job, statusBadge)

        local icon = 'store'
        if shop.type == 'ox_shop' then
            if shop.key and shop.key:find('blackmarket') then
                icon = 'skull'
            elseif shop.key and shop.key:find('lojistik') then
                icon = 'boxes-packing'
            elseif shop.key and shop.key:find('torbaci') then
                icon = 'cannabis'
            else
                icon = 'shopping-basket'
            end
        elseif shop.type == 'money' then
            icon = 'money-bill-transfer'
        elseif shop.type == 'black' then
            icon = 'cannabis'
        end

        table.insert(options, {
            title = shop.name .. ' (' .. shop.key .. ')',
            description = desc,
            icon = icon,
            arrow = true,
            onSelect = function()
                openShopSubMenu(shop)
            end
        })
    end

    lib.registerContext({
        id = 'pawnshop_admin_main',
        title = '🏪 İllegal & Pawnshop NPC Yönetimi',
        options = options
    })
    lib.showContext('pawnshop_admin_main')
end

-- Komut Tanımlaması
RegisterCommand('pwadmin', function()
    openAdminMainMenu()
end, false)

TriggerEvent('chat:addSuggestion', '/pwadmin', 'Pawnshop ve Tacir NPC/Fiyat Yönetim Menüsü (Admin)')

