local openMainMenu
local openPlayerMenu
local openSocialMenu
local openAccountManageMenu

---@description Seçilen hesabın detaylı yönetim menüsü (Tik, Şifre, Tag Değiştirme, Hesap Silme)
---@param citizenid string
---@param acc table
openAccountManageMenu = function(citizenid, acc)
    local appIcon = 'hashtag'
    local iconCol = '#3498db'
    if acc.app == 'twitter' then
        appIcon = 'brands fa-twitter'
        iconCol = '#1DA1F2'
    elseif acc.app == 'instagram' then
        appIcon = 'brands fa-instagram'
        iconCol = '#E1306C'
    elseif acc.app == 'frogly' then
        appIcon = 'camera-retro'
        iconCol = '#20D5EC'
    elseif acc.app == 'foffy' then
        appIcon = 'fire'
        iconCol = '#FF5252'
    end

    local options = {
        {
            title = string.format('%s: @%s', acc.app:upper(), acc.tag),
            description = string.format('🔑 Mevcut Şifre: %s\n📛 Görünen Ad: %s', acc.password or 'Belirtilmemiş', acc.nickname or acc.tag),
            icon = appIcon,
            iconColor = iconCol,
            disabled = true
        },
        {
            title = '🔹 Mavi Onay Tik',
            description = acc.verified and 'Durum: AKTİF ✅ (Kaldırmak için tıkla)' or 'Durum: PASİF ❌ (Tanımlamak için tıkla)',
            icon = 'circle-check',
            iconColor = acc.verified and '#20D5EC' or '#7f8c8d',
            onSelect = function()
                local newStatus = not acc.verified
                lib.callback('can9work:phoneAdmin:toggleVerified', false, function(res)
                    if res and res.success then
                        lib.notify({ title = 'Rozet Güncellendi', description = res.message, type = 'success' })
                        acc.verified = newStatus
                        if newStatus then
                            acc.yellow_verified = false
                            acc.gray_verified = false
                        end
                        openAccountManageMenu(citizenid, acc)
                    else
                        lib.notify({ title = 'Hata', description = res and res.message or 'İşlem başarısız!', type = 'error' })
                    end
                end, citizenid, acc.app, acc.tag, 'blue', newStatus)
            end
        }
    }

    -- Sarı (Kurumsal) Tik (Twitter, Instagram, Frogly)
    if acc.app == 'twitter' or acc.app == 'instagram' or acc.app == 'frogly' then
        table.insert(options, {
            title = '🔸 Sarı (Kurumsal) Tik',
            description = acc.yellow_verified and 'Durum: AKTİF ✅ (Kaldırmak için tıkla)' or 'Durum: PASİF ❌ (Tanımlamak için tıkla)',
            icon = 'certificate',
            iconColor = acc.yellow_verified and '#f1c40f' or '#7f8c8d',
            onSelect = function()
                local newStatus = not acc.yellow_verified
                lib.callback('can9work:phoneAdmin:toggleVerified', false, function(res)
                    if res and res.success then
                        lib.notify({ title = 'Rozet Güncellendi', description = res.message, type = 'success' })
                        acc.yellow_verified = newStatus
                        if newStatus then
                            acc.verified = false
                            acc.gray_verified = false
                        end
                        openAccountManageMenu(citizenid, acc)
                    else
                        lib.notify({ title = 'Hata', description = res and res.message or 'İşlem başarısız!', type = 'error' })
                    end
                end, citizenid, acc.app, acc.tag, 'yellow', newStatus)
            end
        })

        table.insert(options, {
            title = '⚪ Gri (Resmi Kurum / Devlet) Tik',
            description = acc.gray_verified and 'Durum: AKTİF ✅ (Kaldırmak için tıkla)' or 'Durum: PASİF ❌ (Tanımlamak için tıkla)',
            icon = 'shield-halved',
            iconColor = acc.gray_verified and '#bdc3c7' or '#7f8c8d',
            onSelect = function()
                local newStatus = not acc.gray_verified
                lib.callback('can9work:phoneAdmin:toggleVerified', false, function(res)
                    if res and res.success then
                        lib.notify({ title = 'Rozet Güncellendi', description = res.message, type = 'success' })
                        acc.gray_verified = newStatus
                        if newStatus then
                            acc.verified = false
                            acc.yellow_verified = false
                        end
                        openAccountManageMenu(citizenid, acc)
                    else
                        lib.notify({ title = 'Hata', description = res and res.message or 'İşlem başarısız!', type = 'error' })
                    end
                end, citizenid, acc.app, acc.tag, 'gray', newStatus)
            end
        })
    end

    -- Şifre Değiştirme
    table.insert(options, {
        title = '🔑 Şifreyi Görüntüle / Değiştir',
        description = string.format('Mevcut: %s (Değiştirmek için tıkla)', acc.password or 'Yok'),
        icon = 'key',
        iconColor = '#f39c12',
        onSelect = function()
            local input = lib.inputDialog(string.format('Şifre Güncelle: @%s', acc.tag), {
                {
                    type = 'input',
                    label = 'Yeni Hesap Şifresi',
                    default = acc.password ~= 'Belirtilmemiş' and acc.password or '',
                    description = 'Hesap için yeni bir giriş şifresi belirleyin',
                    icon = 'lock',
                    required = true
                }
            })

            if not input or not input[1] then
                openAccountManageMenu(citizenid, acc)
                return
            end

            local newPassword = input[1]:gsub('^%s+', ''):gsub('%s+$', '')
            if newPassword == acc.password then
                lib.notify({ title = 'Bilgi', description = 'Şifrede bir değişiklik yapılmadı.', type = 'info' })
                openAccountManageMenu(citizenid, acc)
                return
            end

            lib.callback('can9work:phoneAdmin:changeAccountPassword', false, function(res)
                if res and res.success then
                    lib.notify({ title = 'Şifre Güncellendi! 🎉', description = res.message, type = 'success' })
                    acc.password = newPassword
                    openAccountManageMenu(citizenid, acc)
                else
                    lib.notify({ title = 'Hata', description = res and res.message or 'Şifre değiştirilemedi!', type = 'error' })
                    openAccountManageMenu(citizenid, acc)
                end
            end, citizenid, acc.app, acc.tag, newPassword)
        end
    })

    -- Kullanıcı Adı (@tag) Değiştirme
    table.insert(options, {
        title = '✏️ Kullanıcı Adını (@tag) Değiştir',
        description = string.format('Mevcut: @%s (Değiştirmek için tıkla)', acc.tag),
        icon = 'pen-to-square',
        iconColor = '#3498db',
        onSelect = function()
            local input = lib.inputDialog('Kullanıcı Adı Değiştir', {
                {
                    type = 'input',
                    label = 'Yeni Kullanıcı Adı',
                    default = acc.tag,
                    description = '@ sembolü olmadan yeni etiketi yazın (tüm eski gönderiler aktarılır)',
                    icon = 'at',
                    required = true
                }
            })

            if not input or not input[1] then
                openAccountManageMenu(citizenid, acc)
                return
            end

            local newTag = input[1]:gsub('^%s+', ''):gsub('%s+$', ''):gsub('^@', '')
            if newTag == acc.tag then
                lib.notify({ title = 'Bilgi', description = 'Kullanıcı adı değiştirilmedi.', type = 'info' })
                openAccountManageMenu(citizenid, acc)
                return
            end

            lib.callback('can9work:phoneAdmin:changeAccountTag', false, function(res)
                if res and res.success then
                    lib.notify({ title = 'Kullanıcı Adı Değiştirildi! 🎉', description = res.message, type = 'success' })
                    acc.tag = res.newTag or newTag
                    openAccountManageMenu(citizenid, acc)
                else
                    lib.notify({ title = 'Hata', description = res and res.message or 'Kullanıcı adı değiştirilemedi!', type = 'error' })
                    openAccountManageMenu(citizenid, acc)
                end
            end, citizenid, acc.app, acc.tag, newTag)
        end
    })

    -- Hesap Silme
    table.insert(options, {
        title = '🗑️ Hesabı Kalıcı Olarak Sil',
        description = 'Hesabı ve bu hesaba ait tüm gönderileri veritabanından kalıcı olarak siler',
        icon = 'trash-can',
        iconColor = '#e74c3c',
        onSelect = function()
            local confirm = lib.alertDialog({
                header = string.format('Hesap Silme: @%s', acc.tag),
                content = string.format('@%s (%s) hesabı tamamen silinecektir.\n\n⚠️ Bu hesaba ait tüm tweetler, fotoğraflar ve yorumlar da veritabanından temizlenir!\n\nBu işlem geri alınamaz. Onaylıyor musunuz?', acc.tag, acc.app:upper()),
                centered = true,
                cancel = true
            })

            if confirm ~= 'confirm' then
                openAccountManageMenu(citizenid, acc)
                return
            end

            lib.callback('can9work:phoneAdmin:deleteAccount', false, function(res)
                if res and res.success then
                    lib.notify({ title = 'Hesap Silindi! 🗑️', description = res.message, type = 'success', duration = 8000 })
                    openSocialMenu(citizenid)
                else
                    lib.notify({ title = 'Hata', description = res and res.message or 'Hesap silinemedi!', type = 'error' })
                    openAccountManageMenu(citizenid, acc)
                end
            end, citizenid, acc.app, acc.tag)
        end
    })

    table.insert(options, {
        title = '🔙 Hesaplar Listesine Dön',
        icon = 'arrow-left',
        onSelect = function()
            openSocialMenu(citizenid)
        end
    })

    lib.registerContext({
        id = 'phone_admin_badge_actions',
        title = string.format('@%s Yönetimi', acc.tag),
        menu = 'phone_admin_player_social',
        options = options
    })

    lib.showContext('phone_admin_badge_actions')
end

---@description Oyuncunun tüm sosyal medya hesaplarını listeleyen menü
---@param citizenid string
openSocialMenu = function(citizenid)
    lib.callback('can9work:phoneAdmin:getPlayerDetails', false, function(data)
        if not data then
            lib.notify({ title = 'Hata', description = 'Oyuncu verisi alınamadı!', type = 'error' })
            return
        end

        local options = {}

        if not data.accounts or #data.accounts == 0 then
            table.insert(options, {
                title = '⚠️ Kayıtlı Hesap Yok',
                description = 'Bu oyuncuya ait herhangi bir sosyal medya hesabı bulunamadı.',
                icon = 'circle-exclamation',
                disabled = true
            })
        else
            for _, acc in ipairs(data.accounts) do
                local b = acc.verified and 'Mavi ✅' or 'Mavi ❌'
                local y = acc.yellow_verified and 'Sarı ✅' or 'Sarı ❌'
                local g = acc.gray_verified and 'Gri ✅' or 'Gri ❌'
                local statusSummary = string.format('%s | %s | %s | Şifre: %s', b, y, g, acc.password or 'Yok')

                local appIcon = 'hashtag'
                local iconCol = '#3498db'
                if acc.app == 'twitter' then
                    appIcon = 'brands fa-twitter'
                    iconCol = '#1DA1F2'
                elseif acc.app == 'instagram' then
                    appIcon = 'brands fa-instagram'
                    iconCol = '#E1306C'
                elseif acc.app == 'frogly' then
                    appIcon = 'camera-retro'
                    iconCol = '#20D5EC'
                elseif acc.app == 'foffy' then
                    appIcon = 'fire'
                    iconCol = '#FF5252'
                end

                table.insert(options, {
                    title = string.format('%s: @%s (%s)', acc.app:upper(), acc.tag, acc.nickname or acc.tag),
                    description = statusSummary,
                    icon = appIcon,
                    iconColor = iconCol,
                    arrow = true,
                    onSelect = function()
                        openAccountManageMenu(citizenid, acc)
                    end
                })
            end
        end

        table.insert(options, {
            title = '🔙 Oyuncu Detayına Dön',
            icon = 'arrow-left',
            onSelect = function()
                openPlayerMenu(citizenid)
            end
        })

        lib.registerContext({
            id = 'phone_admin_player_social',
            title = string.format('%s - Sosyal Hesaplar', data.name),
            menu = 'phone_admin_player_detail',
            options = options
        })

        lib.showContext('phone_admin_player_social')
    end, citizenid)
end

---@description Seçilen oyuncunun yönetim kartı
---@param citizenid string
openPlayerMenu = function(citizenid)
    lib.callback('can9work:phoneAdmin:getPlayerDetails', false, function(data)
        if not data then
            lib.notify({ title = 'Hata', description = 'Oyuncu verileri bulunamadı!', type = 'error' })
            return
        end

        local statusText = data.isOnline and string.format('🟢 Çevrimiçi (ID: %s)', data.source) or '🔴 Çevrimdışı'

        local options = {
            {
                title = string.format('👤 %s (%s)', data.name, data.citizenid),
                description = string.format('📞 Tel: %s | 💳 IBAN: %s\n🌐 Durum: %s', data.phone, data.iban, statusText),
                icon = 'id-card',
                disabled = true
            },
            {
                title = '📞 Telefon Numarasını Değiştir',
                description = string.format('Mevcut Numara: %s (Değiştirmek için tıkla)', data.phone),
                icon = 'phone-flip',
                iconColor = '#2ecc71',
                onSelect = function()
                    local input = lib.inputDialog('Telefon Numarasını Değiştir', {
                        {
                            type = 'input',
                            label = 'Yeni Telefon Numarası',
                            default = data.phone ~= 'Yok' and data.phone or '',
                            placeholder = 'örn: 0000, 555123...',
                            description = 'Benzersiz bir numara giriniz (3-20 karakter)',
                            icon = 'phone',
                            required = true
                        }
                    })

                    if not input or not input[1] then return end
                    local newNumber = input[1]:gsub('^%s+', ''):gsub('%s+$', '')

                    if newNumber == data.phone then
                        lib.notify({ title = 'Bilgi', description = 'Numarada bir değişiklik yapılmadı.', type = 'info' })
                        openPlayerMenu(citizenid)
                        return
                    end

                    lib.callback('can9work:phoneAdmin:changePhoneNumber', false, function(res)
                        if res and res.success then
                            lib.notify({ title = 'Başarılı! 🎉', description = res.message, type = 'success', duration = 6000 })
                            openPlayerMenu(citizenid)
                        else
                            lib.notify({ title = 'Hata', description = res and res.message or 'Numara değiştirilemedi!', type = 'error', duration = 6000 })
                            openPlayerMenu(citizenid)
                        end
                    end, citizenid, newNumber)
                end
            },
            {
                title = '💎 Sosyal Medya Hesapları & Rozetler',
                description = string.format('Kayıtlı %d hesap (Mavi/Sarı Tik, Şifre, Tag, Hesap Silme)', #data.accounts),
                icon = 'certificate',
                iconColor = '#20D5EC',
                arrow = true,
                onSelect = function()
                    openSocialMenu(citizenid)
                end
            },
            {
                title = '⚙️ Telefon Ayarlarını Sıfırla (Fix/Reset)',
                description = 'Bozuk duvar kağıdı, takılı bildirim veya kilit/FaceID sorunlarını çözer',
                icon = 'wrench',
                iconColor = '#f39c12',
                onSelect = function()
                    local confirm = lib.alertDialog({
                        header = 'Telefon Ayarlarını Sıfırla (Fix / Reset)',
                        content = string.format('%s (%s) oyuncusunun telefon duvar kağıtları, kilit/FaceID şifresi ve takılı bildirimleri varsayılan fabrika ayarlarına döndürülecektir.\n\n🛡️ Rehber, fotoğraflar ve banka bakiyesine dokunulmaz.\n\nDevam etmek istiyor musunuz?', data.name, data.citizenid),
                        centered = true,
                        cancel = true
                    })

                    if confirm ~= 'confirm' then
                        openPlayerMenu(citizenid)
                        return
                    end

                    lib.callback('can9work:phoneAdmin:resetPhoneSettings', false, function(res)
                        if res and res.success then
                            lib.notify({ title = 'Telefon Sıfırlandı! ⚙️', description = res.message, type = 'success', duration = 6000 })
                            openPlayerMenu(citizenid)
                        else
                            lib.notify({ title = 'Hata', description = res and res.message or 'Sıfırlama başarısız!', type = 'error' })
                            openPlayerMenu(citizenid)
                        end
                    end, citizenid)
                end
            },
            {
                title = '💳 IBAN Değiştir',
                description = string.format('Mevcut IBAN: %s (Değiştirmek için tıkla)', data.iban),
                icon = 'credit-card',
                iconColor = '#e67e22',
                onSelect = function()
                    local input = lib.inputDialog('IBAN Değiştir', {
                        {
                            type = 'input',
                            label = 'Yeni IBAN',
                            default = data.iban ~= 'Yok' and data.iban or '',
                            placeholder = 'örn: 123456...',
                            icon = 'building-columns',
                            required = true
                        }
                    })

                    if not input or not input[1] then return end
                    local newIban = input[1]:gsub('^%s+', ''):gsub('%s+$', '')

                    if newIban == data.iban then
                        lib.notify({ title = 'Bilgi', description = 'IBAN değişikliği yapılmadı.', type = 'info' })
                        openPlayerMenu(citizenid)
                        return
                    end

                    lib.callback('can9work:phoneAdmin:changeIban', false, function(res)
                        if res and res.success then
                            lib.notify({ title = 'Başarılı! 🎉', description = res.message, type = 'success', duration = 6000 })
                            openPlayerMenu(citizenid)
                        else
                            lib.notify({ title = 'Hata', description = res and res.message or 'IBAN değiştirilemedi!', type = 'error', duration = 6000 })
                            openPlayerMenu(citizenid)
                        end
                    end, citizenid, newIban)
                end
            },
            {
                title = '🔄 Bilgileri Yenile',
                icon = 'rotate',
                onSelect = function()
                    openPlayerMenu(citizenid)
                end
            },
            {
                title = '🔙 Ana Menüye Dön',
                icon = 'arrow-left',
                onSelect = function()
                    openMainMenu()
                end
            }
        }

        lib.registerContext({
            id = 'phone_admin_player_detail',
            title = string.format('Yönetim: %s', data.name),
            options = options
        })

        lib.showContext('phone_admin_player_detail')
    end, citizenid)
end

---@description Ana Yönetim Menüsü
openMainMenu = function()
    lib.callback('can9work:phoneAdmin:checkPermission', false, function(allowed)
        if not allowed then
            lib.notify({ title = 'Yetki Hatası', description = 'Bu menüyü açma yetkiniz bulunmuyor!', type = 'error' })
            return
        end

        local options = {
            {
                title = '🟢 Aktif Online Oyuncular',
                description = 'Şu anda oyunda olan oyuncuları listeler ve hızlı işlem yapmanızı sağlar',
                icon = 'users',
                iconColor = '#2ecc71',
                arrow = true,
                onSelect = function()
                    lib.callback('can9work:phoneAdmin:getOnlinePlayers', false, function(list)
                        if not list or #list == 0 then
                            lib.notify({ title = 'Bilgi', description = 'Şu an oyunda aktif oyuncu bulunmuyor.', type = 'info' })
                            return
                        end

                        local playerOptions = {}
                        for _, p in ipairs(list) do
                            table.insert(playerOptions, {
                                title = string.format('(%s) %s', p.source, p.name),
                                description = string.format('CitizenID: %s | Tel: %s', p.citizenid, p.phone),
                                icon = 'user',
                                arrow = true,
                                onSelect = function()
                                    openPlayerMenu(p.citizenid)
                                end
                            })
                        end

                        table.insert(playerOptions, {
                            title = '🔙 Ana Menüye Dön',
                            icon = 'arrow-left',
                            onSelect = function()
                                openMainMenu()
                            end
                        })

                        lib.registerContext({
                            id = 'phone_admin_online_players',
                            title = string.format('Online Oyuncular (%d)', #list),
                            menu = 'phone_admin_main',
                            options = playerOptions
                        })

                        lib.showContext('phone_admin_online_players')
                    end)
                end
            },
            {
                title = '🔍 Oyuncu Ara (Tüm DB & Offline)',
                description = 'CitizenID, Ad Soyad, Telefon Numarası veya Sosyal Medya @tag ile arama yapın',
                icon = 'magnifying-glass',
                iconColor = '#3498db',
                onSelect = function()
                    local input = lib.inputDialog('Oyuncu Ara', {
                        {
                            type = 'input',
                            label = 'Arama Terimi',
                            description = 'CitizenID, İsim, Tel No veya @tag giriniz',
                            placeholder = 'örn: Arden, U0T982XU, 0000, @alicess...',
                            icon = 'search',
                            required = true
                        }
                    })

                    if not input or not input[1] then return end
                    local q = input[1]:gsub('^%s+', ''):gsub('%s+$', '')

                    lib.callback('can9work:phoneAdmin:searchPlayers', false, function(results)
                        if not results or #results == 0 then
                            lib.notify({ title = 'Arama Sonucu', description = 'Aramanıza uyan herhangi bir oyuncu/hesap bulunamadı!', type = 'warning' })
                            return
                        end

                        local searchOptions = {}
                        for _, r in ipairs(results) do
                            local statusText = r.isOnline and string.format('🟢 Online (ID: %s)', r.source) or '🔴 Offline'
                            table.insert(searchOptions, {
                                title = string.format('%s (%s)', r.name, r.citizenid),
                                description = string.format('Tel: %s | IBAN: %s | %s', r.phone, r.iban, statusText),
                                icon = 'user-tag',
                                arrow = true,
                                onSelect = function()
                                    openPlayerMenu(r.citizenid)
                                end
                            })
                        end

                        table.insert(searchOptions, {
                            title = '🔙 Ana Menüye Dön',
                            icon = 'arrow-left',
                            onSelect = function()
                                openMainMenu()
                            end
                        })

                        lib.registerContext({
                            id = 'phone_admin_search_results',
                            title = string.format('Arama Sonuçları (%d)', #results),
                            menu = 'phone_admin_main',
                            options = searchOptions
                        })

                        lib.showContext('phone_admin_search_results')
                    end, q)
                end
            }
        }

        lib.registerContext({
            id = 'phone_admin_main',
            title = '📱 Telefon & Rozet Yönetimi',
            options = options
        })

        lib.showContext('phone_admin_main')
    end)
end

-- Komut ve Alias Tanımlamaları
local cfg = Settings and Settings.PhoneAdmin or {}
local mainCmd = cfg.Command or 'phoneadmin'
local aliases = cfg.Aliases or { 'teladmin', 'cylexadmin', 'telefonyonetim' }

RegisterCommand(mainCmd, function()
    openMainMenu()
end, false)

TriggerEvent('chat:addSuggestion', '/' .. mainCmd, 'Telefon yönetim ve sosyal medya mavi tik menüsünü açar (Admin)')

for _, alias in ipairs(aliases) do
    if alias ~= mainCmd then
        RegisterCommand(alias, function()
            openMainMenu()
        end, false)

        TriggerEvent('chat:addSuggestion', '/' .. alias, 'Telefon yönetim ve sosyal medya mavi tik menüsünü açar (Admin)')
    end
end
