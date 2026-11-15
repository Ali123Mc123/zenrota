local Config = require("config.main")

local function OpenOrderMenu(shopId)
    local shopItems = {}
    for _, s in pairs(Config.Shops) do
        for _, item in ipairs(s.Items) do
            shopItems[#shopItems + 1] = {
                title = item.label .. " ($" .. math.floor(item.price * 0.7) .. ")",
                description = "Toptan alım fiyatı",
                onSelect = function()
                    local input = lib.inputDialog("Ürün Siparişi: " .. item.label, {
                        { type = "number", label = "Miktar", description = "Kaç adet sipariş etmek istiyorsunuz?",
                            min = 1, default = 1 }
                    })
                    if input and input[1] then
                        local success = lib.callback.await("cloud-shop:server:orderItems", false, shopId, item.name,
                            input[1])
                        if success then
                            lib.notify({ title = "Başarılı", description = "Sipariş teslim edildi.", type = "success" })
                        else
                            lib.notify({ title = "Hata", description = "Bakiye yetersiz veya işlem başarısız.",
                                type = "error" })
                        end
                    end
                end
            }
        end
    end

    lib.registerContext({
        id = "shop_order_menu",
        title = "Toptan Ürün Siparişi",
        menu = "shop_owner_main",
        options = shopItems
    })
    lib.showContext("shop_order_menu")
end

local function OpenPriceMenu(shopId, data)
    local options = {}
    for itemName, item in pairs(data.items) do
        options[#options + 1] = {
            title = item.label,
            description = "Mevcut Fiyat: $" .. item.price .. " | Stok: " .. item.stock,
            onSelect = function()
                local input = lib.inputDialog("Fiyat Güncelle: " .. item.label, {
                    { type = "number", label = "Yeni Satış Fiyatı", min = 1, default = item.price }
                })
                if input and input[1] then
                    local success = lib.callback.await("cloud-shop:server:updatePrice", false, shopId, item.name,
                        input[1])
                    if success then
                        lib.notify({ title = "Başarılı", description = "Fiyat güncellendi.", type = "success" })
                    end
                end
            end
        }
    end

    lib.registerContext({
        id = "shop_price_menu",
        title = "Fiyat Düzenleme",
        menu = "shop_owner_main",
        options = options
    })
    lib.showContext("shop_price_menu")
end

local function OpenOwnerMenu(shopId)
    local data = lib.callback.await("cloud-shop:server:getBusinessStats", false, shopId)
    if not data then return end

    lib.registerContext({
        id = "shop_owner_main",
        title = "İşletme Yönetimi - " .. shopId,
        options = {
            {
                title = "Kasa İşlemleri",
                description = "Bakiye: $" .. data.balance,
                onSelect = function()
                    local input = lib.inputDialog("Kasa Yönetimi", {
                        { type = "select", label = "İşlem",
                            options = { { value = "deposit", label = "Para Yatır" },
                                { value = "withdraw", label = "Para Çek" } } },
                        { type = "number", label = "Miktar", min = 1 }
                    })
                    if input and input[1] and input[2] then
                        local success = lib.callback.await("cloud-shop:server:manageFunds", false, shopId, input[1],
                            input[2])
                        if success then
                            lib.notify({ title = "Başarılı", description = "İşlem tamamlandı.", type = "success" })
                        else
                            lib.notify({ title = "Hata", description = "Bakiye yetersiz.", type = "error" })
                        end
                    end
                end
            },
            {
                title = "Ürün Sipariş Et",
                description = "Toptancıdan mal tedarik et",
                onSelect = function() OpenOrderMenu(shopId) end
            },
            {
                title = "Fiyatları Düzenle",
                description = "Satıştaki ürünlerin fiyatlarını ayarla",
                onSelect = function() OpenPriceMenu(shopId, data) end
            }
        }
    })
    lib.showContext("shop_owner_main")
end

-- can9work-auction'in isletme NPC'sinden: stok siparisi ve fiyatlar (kasa ihale panelinde).
exports("OpenStockMenu", function(shopId)
    local data = lib.callback.await("cloud-shop:server:getBusinessStats", false, shopId)
    if not data then return end

    lib.registerContext({
        id = "shop_owner_main",
        title = "Stok ve Fiyat",
        options = {
            {
                title = "Ürün Sipariş Et",
                description = "Toptancıdan mal tedarik et, bedeli kasadan ödenir",
                icon = "fas fa-boxes-stacked",
                onSelect = function() OpenOrderMenu(shopId) end
            },
            {
                title = "Fiyatları Düzenle",
                description = "Satıştaki ürünlerin fiyatlarını ayarla",
                icon = "fas fa-tag",
                onSelect = function() OpenPriceMenu(shopId, data) end
            }
        }
    })
    lib.showContext("shop_owner_main")
end)

return OpenOwnerMenu
