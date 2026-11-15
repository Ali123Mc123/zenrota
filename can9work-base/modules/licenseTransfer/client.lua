local function startTransferProcess(searchQuery)
    if not searchQuery or searchQuery == '' then return end

    lib.notify({
        title = 'Hesap Taranıyor',
        description = 'Rockstar ve karakter verileri sorgulanıyor...',
        type = 'info',
        duration = 2500
    })

    lib.callback('can9work:licenseTransfer:search', false, function(res)
        if not res then
            lib.notify({ title = 'Hata', description = 'Sunucudan yanıt alınamadı!', type = 'error' })
            return
        end

        if not res.success then
            lib.notify({ title = 'Arama Başarısız', description = res.message or 'Hesap bulunamadı!', type = 'error', duration = 6000 })
            return
        end

        local data = res.data
        local target = data.target
        local characters = data.charactersToTransfer

        local menuOptions = {
            {
                title = string.format('🎯 Hedef Yeni Hesap: %s', target.username),
                description = string.format('Discord: **%s**\nYeni Lisans: %s\nDurum: **%s**',
                    data.discord, target.license2:sub(1, 26) .. '...', target.isOnline and ('🟢 Sunucuda Bağlı (ID: ' .. tostring(target.onlineSource) .. ')') or '⚪ Çevrimdışı'),
                icon = 'user-check',
                disabled = true
            }
        }

        local hasDummyChar = false
        local dummyCid = nil
        if target.existingCharacters and #target.existingCharacters > 0 then
            hasDummyChar = true
            dummyCid = target.existingCharacters[1].citizenid
            table.insert(menuOptions, {
                title = '⚠️ Yeni Hesapta Geçici Karakter Var!',
                description = string.format('Yeni hesapta [%s] (%s) adlı karakter bulundu. Aktarım sırasında bu geçici karakter otomatik temizlenir.',
                    target.existingCharacters[1].name, dummyCid),
                icon = 'triangle-exclamation',
                iconColor = '#e67e22',
                disabled = true
            })
        end

        local transferCitizenIds = {}
        local transferNames = {}
        for _, ch in ipairs(characters) do
            table.insert(transferCitizenIds, ch.citizenid)
            table.insert(transferNames, string.format('%s (%s)', ch.name, ch.citizenid))
            table.insert(menuOptions, {
                title = string.format('📦 %s [%s]', ch.name, ch.citizenid),
                description = string.format('Slot: **%d** | Nakit: **%s** | Banka: **%s**\nMeslek: **%s** | Araç: **%d Adet**',
                    ch.cid, ch.cash, ch.bank, ch.job, ch.vehicles),
                icon = 'user',
                disabled = true
            })
        end

        table.insert(menuOptions, {
            title = '✅ Aktarımı Onayla ve Tamamla',
            description = string.format('Toplam %d karakteri ve bağlı araçları bu Rockstar hesabına aktarır.', #characters),
            icon = 'circle-check',
            iconColor = '#2ecc71',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Hesap Aktarım Onayı',
                    content = string.format('**%s** kullanıcısının %d adet karakteri yeni Rockstar lisansına (%s) taşınacaktır.\n\nİşlemi onaylıyor musunuz?',
                        target.username, #characters, target.license2:sub(1, 26) .. '...'),
                    centered = true,
                    cancel = true
                })

                if alert == 'confirm' then
                    lib.notify({ title = 'İşleniyor', description = 'Veritabanı güncelleniyor...', type = 'info', duration = 2000 })
                    lib.callback('can9work:licenseTransfer:execute', false, function(execRes)
                        if execRes and execRes.success then
                            lib.notify({
                                title = 'İşlem Başarılı! 🎉',
                                description = string.format('%d karakter başarıyla yeni Rockstar lisansına aktarıldı!', execRes.count),
                                type = 'success',
                                duration = 7000
                            })
                        else
                            lib.notify({
                                title = 'Hata',
                                description = execRes and execRes.message or 'Aktarım sırasında bir hata meydana geldi!',
                                type = 'error',
                                duration = 6000
                            })
                        end
                    end, {
                        targetUserId = target.userId,
                        targetUsername = target.username,
                        targetLicense = target.license,
                        targetLicense2 = target.license2,
                        discord = data.discord,
                        oldLicense2 = data.primaryOldLicense2,
                        characterCitizenIds = transferCitizenIds,
                        characterNames = transferNames,
                        replaceDummy = hasDummyChar,
                        dummyCitizenId = dummyCid,
                        onlineSource = target.onlineSource
                    })
                end
            end
        })

        table.insert(menuOptions, {
            title = '❌ İptal',
            description = 'İşlemi iptal et ve menüyü kapat',
            icon = 'xmark'
        })

        lib.registerContext({
            id = 'license_transfer_preview',
            title = 'Rockstar Hesap Aktarımı',
            options = menuOptions
        })

        lib.showContext('license_transfer_preview')
    end, searchQuery)
end

local function openTransferPrompt(param)
    if param and param ~= '' then
        startTransferProcess(param)
        return
    end

    local dialog = lib.inputDialog('Rockstar Hesap / Lisans Aktarımı', {
        {
            type = 'input',
            label = 'Oyuncu / Hesap Tanımlayıcısı',
            description = 'Oyuncunun Sunucu ID\'si, Discord ID\'si veya Eski CitizenID\'si',
            placeholder = 'Örn: 12 veya 779459833333940246 veya XP7QDOE1',
            required = true
        }
    })

    if dialog and dialog[1] and dialog[1] ~= '' then
        startTransferProcess(dialog[1])
    end
end

-- Komut Tanımı (RegisterCommand + chat:addSuggestion)
local mainCmd = (Settings and Settings.LicenseTransfer and Settings.LicenseTransfer.Command) or 'hesapaktar'
RegisterCommand(mainCmd, function(_, args)
    local target = args and args[1]
    openTransferPrompt(target)
end, false)

TriggerEvent('chat:addSuggestion', '/' .. mainCmd, 'Rockstar hesabı değişen oyuncunun karakterlerini yeni lisansına aktarır (Admin)', {
    { name = 'hedef', help = 'Oyuncu ID, Discord ID veya CitizenID (opsiyonel)' }
})

-- Alternatif komutlar (Aliases)
local aliases = (Settings and Settings.LicenseTransfer and Settings.LicenseTransfer.Aliases) or { 'licensetransfer', 'rockstaraktar' }
for _, alias in ipairs(aliases) do
    if alias ~= mainCmd then
        RegisterCommand(alias, function(_, args)
            local target = args and args[1]
            openTransferPrompt(target)
        end, false)

        TriggerEvent('chat:addSuggestion', '/' .. alias, 'Rockstar hesabı değişen oyuncunun karakterlerini yeni lisansına aktarır (Admin)', {
            { name = 'hedef', help = 'Oyuncu ID, Discord ID veya CitizenID (opsiyonel)' }
        })
    end
end
