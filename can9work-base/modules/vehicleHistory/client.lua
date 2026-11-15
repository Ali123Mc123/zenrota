local handleHistoryCommand

local function openHistoryMenu(data)
    if not data or not data.vehicle then return end

    local veh = data.vehicle
    local mods = data.mods
    local mech = data.mechanic
    local orders = data.orders

    -- 1. Modlar Alt Menüsü
    lib.registerContext({
        id = 'veh_hist_mods',
        title = 'Mevcut Parçalar (DB)',
        menu = 'veh_hist_main',
        options = {
            { title = 'Motor', description = mods.engine, icon = 'gauge-high' },
            { title = 'Şanzıman', description = mods.transmission, icon = 'gear' },
            { title = 'Fren Sistemi', description = mods.brakes, icon = 'circle-stop' },
            { title = 'Süspansiyon', description = mods.suspension, icon = 'arrows-up-down' },
            { title = 'Turbo', description = mods.turbo, icon = 'bolt' },
            { title = 'Zırh', description = mods.armor, icon = 'shield-halved' },
            { title = 'Xenon Far', description = mods.xenon, icon = 'lightbulb' },
            { title = 'Cam Filmi', description = mods.tint, icon = 'mask' },
            { title = 'Lastik Türü', description = mods.bulletProof, icon = 'bullseye' },
        }
    })

    -- 2. JG Tuning & Stance Alt Menüsü
    local tuningOptions = {
        { title = 'Motor Swap', description = mech.engineSwap, icon = 'fire' },
        { title = 'Çekiş Sistemi (Drivetrain)', description = mech.drivetrain, icon = 'arrows-split-up-and-left' },
        { title = 'Tuning Turbocharger', description = mech.turboTuning, icon = 'bolt-lightning' },
        { title = 'Drift Modu', description = mech.driftTuning, icon = 'road' },
        { title = 'Seramik Frenler', description = mech.ceramicBrakes, icon = 'circle-dot' },
        { title = 'Özel Lastikler', description = mech.tyres, icon = 'ring' },
        { title = 'Stance Durumu', description = mech.stanceSummary, icon = 'car-side' },
    }

    local hasAnyTuningInstalled = mech.hasData and (
        mech.engineSwap ~= 'Yok (Orijinal Motor)' or
        mech.drivetrain ~= 'Stok Çekiş' or
        mech.ceramicBrakes ~= 'Yok' or
        mech.driftTuning ~= 'Kapalı' or
        mech.turboTuning ~= 'Yok'
    )

    if hasAnyTuningInstalled then
        if mech.hasRecordedOrder then
            table.insert(tuningOptions, 1, {
                title = '📜 Sipariş Kaydı: Doğrulandı ✅',
                description = string.format('Bu parçalar **#%s** (%s) numaralı resmi mekanik siparişinde kayıtlıdır.',
                    tostring(mech.latestOrderId or '?'), tostring(mech.latestOrderDate or '?')),
                icon = 'shield-check',
                iconColor = '#2ecc71',
                disabled = true
            })
        else
            table.insert(tuningOptions, 1, {
                title = '⚠️ Sipariş Kaydı Bulunmuyor',
                description = 'Bu tuning parçaları sipariş fişi kesilmeden doğrudan takılmış. Aşağıdaki butondan sipariş geçmişine arşivleyebilirsiniz.',
                icon = 'triangle-exclamation',
                iconColor = '#f39c12',
                disabled = true
            })

            table.insert(tuningOptions, {
                title = '💾 Bu Tuning Parçalarını Sipariş Geçmişine Kaydet',
                description = string.format('[%s] aracındaki mevcut V12, 4x4 veya tuning parçalarını resmi mekanik siparişi olarak sisteme kaydeder.', veh.plate),
                icon = 'floppy-disk',
                iconColor = '#3498db',
                onSelect = function()
                    lib.notify({ title = 'İşleniyor', description = 'Tuning parçaları sipariş geçmişine kaydediliyor...', type = 'info', duration = 2000 })

                    lib.callback('can9work:vehicleHistory:archiveSingleVehicleTuning', false, function(res)
                        if res and res.success then
                            lib.notify({
                                title = 'Sipariş Kaydedildi! 🎉',
                                description = res.message,
                                type = 'success',
                                duration = 6000
                            })
                            if handleHistoryCommand then
                                handleHistoryCommand(veh.plate)
                            end
                        else
                            lib.notify({
                                title = 'Bilgi',
                                description = res and res.message or 'İşlem tamamlanamadı.',
                                type = 'inform',
                                duration = 5000
                            })
                            lib.showContext('veh_hist_tuning')
                        end
                    end, veh.plate)
                end
            })
        end
    end

    if mech.stanceEnabled and mech.stanceDetails then
        local st = mech.stanceDetails
        table.insert(tuningOptions, {
            title = 'Stance Detayları',
            description = string.format('Alçaltma: %.2f | Ön Kamber: %.2f | Arka Kamber: %.2f\nÖn Ofset: %.4f | Arka Ofset: %.4f',
                st.height or 0.0, st.camberFront or 0.0, st.camberRear or 0.0, st.offsetFront or 0.0, st.offsetRear or 0.0),
            icon = 'sliders'
        })
    end

    lib.registerContext({
        id = 'veh_hist_tuning',
        title = 'JG Tuning & Stance',
        menu = 'veh_hist_main',
        options = tuningOptions
    })

    -- 3. Siparişler ve Alt Detay Menüleri
    local orderListOptions = {}
    if #orders > 0 then
        for _, ord in ipairs(orders) do
            local orderMenuId = 'veh_hist_ord_' .. tostring(ord.id)

            -- Sipariş Detay Menüsü
            local orderDetailOptions = {
                {
                    title = string.format('Sipariş #%s Genel Bilgi', ord.id),
                    description = string.format('Tarih: **%s**\nMekanik: **%s**\nToplam Tutar: **%s**\nDurum: **%s**\nMüşteri CID: **%s**',
                        ord.date, ord.mechanic, ord.amountFormatted, ord.statusText, ord.customerCitizenId),
                    icon = 'circle-info',
                    disabled = true
                }
            }

            if ord.items and #ord.items > 0 then
                for _, itm in ipairs(ord.items) do
                    table.insert(orderDetailOptions, {
                        title = string.format('%s: %s', itm.category, itm.desc),
                        description = string.format('Fiyat: **%s**', itm.priceFormatted),
                        icon = 'check'
                    })
                end
            else
                table.insert(orderDetailOptions, {
                    title = 'Ayrıştırılmış Parça Yok',
                    description = ord.summary or 'Detay bulunamadı',
                    disabled = true
                })
            end

            table.insert(orderDetailOptions, {
                title = '⚡ Bu Siparişteki Parçaları Araca Yükle',
                description = string.format('Yalnızca #%s numaralı siparişte satın alınan parçaları araca uygular.', ord.id),
                icon = 'circle-check',
                iconColor = '#3498db',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Tekil Sipariş Yükleme',
                        content = string.format('**%s [%s]** aracına **#%s** numaralı (%s tarihli) siparişte satın alınan parçalar yüklenecektir.\n\nİşlemi onaylıyor musunuz?', veh.label, veh.plate, ord.id, ord.date),
                        centered = true,
                        cancel = true
                    })

                    if confirm ~= 'confirm' then
                        lib.showContext(orderMenuId)
                        return
                    end

                    lib.notify({ title = 'İşleniyor', description = 'Sipariş parçaları uygulanıyor...', type = 'info', duration = 2000 })

                    lib.callback('can9work:vehicleHistory:restoreSingle', false, function(res)
                        if res and res.success then
                            local liveMsg = res.isLive and '\n*(Haritadaki araca canlı giydirildi)*' or '\n*(Veritabanına kaydedildi, araç garajda)*'
                            lib.notify({
                                title = 'Sipariş Yüklendi! 🎉',
                                description = string.format('#%s numaralı siparişteki parçalar başarıyla uygulandı!%s', ord.id, liveMsg),
                                type = 'success',
                                duration = 6000
                            })
                            if handleHistoryCommand then
                                handleHistoryCommand(veh.plate)
                            end
                        else
                            lib.notify({
                                title = 'Hata',
                                description = res and res.message or 'Sipariş yüklenirken hata oluştu!',
                                type = 'error',
                                duration = 5000
                            })
                            lib.showContext(orderMenuId)
                        end
                    end, veh.plate, ord.id)
                end
            })

            lib.registerContext({
                id = orderMenuId,
                title = string.format('Sipariş #%s (%s)', ord.id, ord.date),
                menu = 'veh_hist_orders',
                options = orderDetailOptions
            })

            -- Sipariş Listesi Butonu
            table.insert(orderListOptions, {
                title = string.format('[%s] %s', ord.date, ord.amountFormatted),
                description = string.format('Mekanik: **%s** | **%s**\nÖzet: %s', ord.mechanic, ord.statusText, ord.summary),
                icon = 'receipt',
                arrow = true,
                menu = orderMenuId
            })
        end
    else
        table.insert(orderListOptions, {
            title = 'Sipariş Kaydı Bulunamadı',
            description = 'Bu plakaya ait mekanik sipariş geçmişi yoktur.',
            disabled = true
        })
    end

    lib.registerContext({
        id = 'veh_hist_orders',
        title = string.format('Sipariş Geçmişi (%d Sipariş)', #orders),
        menu = 'veh_hist_main',
        options = orderListOptions
    })

    -- 4. Ana Menü
    local fakePlateNotice = veh.isFakePlate and ('\n*(Takılı Sahte Plaka: ' .. veh.displayPlate .. ')*') or ''
    local mainOptions = {
        {
            title = string.format('%s [%s]', veh.label, veh.plate),
            description = string.format('Sahip: **%s** (%s)\nTel: **%s** | Durum: **%s** (%s)%s',
                veh.ownerName, veh.ownerCid, veh.ownerPhone, veh.stateText, veh.garage, fakePlateNotice),
            icon = 'car',
            disabled = true
        },
        {
            title = '⚙️ Mevcut Parçalar (DB)',
            description = string.format('Motor: **%s** | Şanzıman: **%s**\nFren: **%s** | Turbo: **%s**',
                mods.engine, mods.transmission, mods.brakes, mods.turbo),
            icon = 'gauge-high',
            arrow = true,
            menu = 'veh_hist_mods'
        },
        {
            title = '🔧 JG Tuning & Stance',
            description = string.format('Swap: **%s** | Çekiş: **%s**\nStance: **%s**',
                mech.engineSwap, mech.drivetrain, mech.stanceSummary),
            icon = 'wrench',
            arrow = true,
            menu = 'veh_hist_tuning'
        },
        {
            title = string.format('📜 Mekanik Sipariş Geçmişi (%d Adet)', #orders),
            description = #orders > 0 and string.format('Son Sipariş: %s (%s)', orders[1].date, orders[1].amountFormatted) or 'Mekanik sipariş kaydı bulunmuyor.',
            icon = 'clock-rotate-left',
            arrow = true,
            menu = 'veh_hist_orders',
            disabled = (#orders == 0)
        },
        {
            title = '⚡ Tüm Parçaları Geri Yükle (Otomatik Restore)',
            description = #orders > 0
                and string.format('Bu araca ait %d siparişteki tüm parçaları kronolojik sırayla birleştirip araca yükler.', #orders)
                or 'Uygulanacak mekanik siparişi bulunmuyor.',
            icon = 'wrench',
            iconColor = '#2ecc71',
            disabled = (#orders == 0),
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Tüm Parçaları Geri Yükleme Onayı',
                    content = string.format('**%s [%s]** aracının geçmişteki **%d adet** siparişinde satın alınan tüm motor, şanzıman, kozmetik ve performans parçaları kronolojik sıra gözetilerek (en son yapılan modifiye geçerli olacak şekilde) birleştirilip araca ve veritabanına geri yüklenecektir.\n\nİşlemi onaylıyor musunuz?', veh.label, veh.plate, #orders),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then
                    lib.showContext('veh_hist_main')
                    return
                end

                lib.notify({ title = 'İşleniyor', description = 'Parçalar kronolojik sırayla birleştiriliyor...', type = 'info', duration = 2500 })

                lib.callback('can9work:vehicleHistory:restoreAll', false, function(res)
                    if res and res.success then
                        local liveMsg = res.isLive and '\n*(Haritadaki araca canlı giydirildi)*' or '\n*(Veritabanına kaydedildi, araç garajda)*'
                        lib.notify({
                            title = 'Parçalar Geri Yüklendi! 🎉',
                            description = string.format('%d adet siparişteki tüm parçalar başarıyla yüklendi!%s', res.count, liveMsg),
                            type = 'success',
                            duration = 6000
                        })
                        if handleHistoryCommand then
                            handleHistoryCommand(veh.plate)
                        end
                    else
                        lib.notify({
                            title = 'Hata',
                            description = res and res.message or 'Geri yükleme sırasında bir hata oluştu!',
                            type = 'error',
                            duration = 5000
                        })
                        lib.showContext('veh_hist_main')
                    end
                end, veh.plate)
            end
        },
        {
            title = '🛑 Aracı Fabrika Ayarlarına Sıfırla (Stock Yap)',
            description = 'Aracın tüm motor, şanzıman, turbo, kozmetik ve JG Tuning (V12, 4x4 vb.) parçalarını sıfırlar.',
            icon = 'trash-can',
            iconColor = '#e74c3c',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = '⚠️ Aracı Fabrika Ayarlarına Sıfırlama',
                    content = string.format('**%s [%s]** aracının tüm motor, şanzıman, fren, turbo, kozmetik parçaları ve JG Tuning (V12 Swap, 4x4 AWD vb.) donanımları SIFIRLANACAKTIR.\n\n*Not: Mekanik sipariş geçmişi korunur, istenirse geçmişten tekrar geri yüklenebilir.*\n\nBu işlemi onaylıyor musunuz?', veh.label, veh.plate),
                    centered = true,
                    cancel = true
                })

                if confirm ~= 'confirm' then
                    lib.showContext('veh_hist_main')
                    return
                end

                lib.notify({ title = 'İşleniyor', description = 'Araç parçaları sıfırlanıyor...', type = 'info', duration = 2000 })

                lib.callback('can9work:vehicleHistory:resetToStock', false, function(res)
                    if res and res.success then
                        local liveMsg = res.isLive and '\n*(Haritadaki araca anında uygulandı)*' or '\n*(Veritabanına kaydedildi, araç garajda)*'
                        lib.notify({
                            title = 'Araç Sıfırlandı!',
                            description = string.format('[%s] aracı fabrika ayarlarına (Stock) döndürüldü!%s', veh.plate, liveMsg),
                            type = 'warning',
                            duration = 6000
                        })
                        if handleHistoryCommand then
                            handleHistoryCommand(veh.plate)
                        end
                    else
                        lib.notify({
                            title = 'Hata',
                            description = res and res.message or 'Sıfırlama sırasında bir hata oluştu!',
                            type = 'error',
                            duration = 5000
                        })
                        lib.showContext('veh_hist_main')
                    end
                end, veh.plate)
            end
        }
    }

    lib.registerContext({
        id = 'veh_hist_main',
        title = 'Araç Denetim & Geçmiş',
        options = mainOptions
    })

    lib.showContext('veh_hist_main')
end

---@description Hedef plakayı belirler
---@param inputPlate string|nil
---@return string|nil
local function resolveTargetPlate(inputPlate)
    if inputPlate and type(inputPlate) == 'string' and inputPlate ~= '' then
        return inputPlate
    end

    local ped = cache.ped or PlayerPedId()

    -- 1. Araç içindeyse
    local curVeh = GetVehiclePedIsIn(ped, false)
    if curVeh and curVeh ~= 0 then
        local p = GetVehicleNumberPlateText(curVeh)
        if p and p ~= '' then return p end
    end

    -- 2. Yakındaki araca bakıyorsa
    local coords = GetEntityCoords(ped)
    local closestVeh = lib.getClosestVehicle(coords, 5.0, true)
    if closestVeh and closestVeh ~= 0 then
        local p = GetVehicleNumberPlateText(closestVeh)
        if p and p ~= '' then return p end
    end

    -- 3. Dialog ile sor
    local dialog = lib.inputDialog('Araç Geçmişi Denetim', {
        {
            type = 'input',
            label = 'Araç Plakası',
            description = 'Geçmişini incelemek istediğiniz plaka',
            placeholder = 'Örn: REGABIR',
            required = true
        }
    })

    if dialog and dialog[1] and dialog[1] ~= '' then
        return dialog[1]
    end

    return nil
end

---@description Komut tetikleyici
---@param plateArg string|nil
handleHistoryCommand = function(plateArg)
    local targetPlate = resolveTargetPlate(plateArg)
    if not targetPlate or targetPlate == '' then return end

    lib.notify({
        title = 'Araç Sorgulanıyor',
        description = ('[%s] verileri çekiliyor...'):format(targetPlate:upper()),
        type = 'info',
        duration = 2000
    })

    lib.callback('can9work:vehicleHistory:getData', false, function(res)
        if not res then
            lib.notify({ title = 'Hata', description = 'Sunucudan yanıt alınamadı!', type = 'error' })
            return
        end

        if not res.success then
            lib.notify({ title = 'Araç Bulunamadı', description = res.message or 'Bilinmeyen hata!', type = 'error', duration = 5000 })
            return
        end

        openHistoryMenu(res)
    end, targetPlate)
end

-- Komut Tanımı (RegisterCommand + chat:addSuggestion)
local mainCmd = (Settings and Settings.VehicleHistory and Settings.VehicleHistory.Command) or 'aracgecmis'
RegisterCommand(mainCmd, function(_, args)
    local targetPlate = args and args[1]
    handleHistoryCommand(targetPlate)
end, false)

TriggerEvent('chat:addSuggestion', '/' .. mainCmd, 'Aracın modlarını, JG tuning/stance ve mekanik geçmişini sorgular (Admin)', {
    { name = 'plaka', help = 'Araç plakası (opsiyonel)' }
})

-- Alternatif komutlar (Aliases)
local aliases = (Settings and Settings.VehicleHistory and Settings.VehicleHistory.Aliases) or { 'gecmiskontrol', 'vehhistory', 'araclog' }
for _, alias in ipairs(aliases) do
    if alias ~= mainCmd then
        RegisterCommand(alias, function(_, args)
            local targetPlate = args and args[1]
            handleHistoryCommand(targetPlate)
        end, false)

        TriggerEvent('chat:addSuggestion', '/' .. alias, 'Aracın modlarını, JG tuning/stance ve mekanik geçmişini sorgular (Admin)', {
            { name = 'plaka', help = 'Araç plakası (opsiyonel)' }
        })
    end
end

-- Komut: /tuningarsivle (Tüm sunucu tuning verilerini mekanik siparişlerine arşivler)
RegisterCommand('tuningarsivle', function()
    local confirm = lib.alertDialog({
        header = 'Tüm Sunucu Tuning Arşivleme',
        content = 'Sunucudaki (mechanic_vehicledata) tüm araçlar taranarak henüz sipariş geçmişine kaydedilmemiş V12, 4x4 ve diğer JG Tuning parçaları için resmi sipariş fişleri oluşturulacaktır.\n\nBu işlem tüm mevcut tuningli araçların geçmişini garantiye alır. Başlatmak istiyor musunuz?',
        centered = true,
        cancel = true
    })

    if confirm ~= 'confirm' then return end

    lib.notify({ title = 'Arşivleme Başlatıldı', description = 'Tüm araçların tuning verileri taranıyor...', type = 'info', duration = 3000 })

    lib.callback('can9work:vehicleHistory:archiveAllTuning', false, function(res)
        if res and res.success then
            lib.notify({
                title = 'Arşivleme Tamamlandı! 🎉',
                description = res.message,
                type = 'success',
                duration = 8000
            })
        else
            lib.notify({
                title = 'Hata',
                description = res and res.message or 'Arşivleme sırasında hata oluştu!',
                type = 'error',
                duration = 5000
            })
        end
    end)
end, false)

TriggerEvent('chat:addSuggestion', '/tuningarsivle', 'Sunucudaki tüm tuningli araçları tarayıp sipariş geçmişine arşivler (Admin)')


