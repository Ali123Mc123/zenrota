-- can9work-ck | Client Side Refactor
local function ShowConfirmationMenu(targetData)
    local alert = lib.alertDialog({
        header = Settings.Notifications.ConfirmTitle,
        content = string.format(
            '**Karakter Bilgileri:**\n\n' ..
            'İsim: %s\n' ..
            'CitizenID: %s\n' ..
            'Discord: %s\n' ..
            'Durum: %s\n\n' ..
            '**UYARI:** Bu işlem geri alınamaz ve tüm veriler silinecektir!',
            targetData.name,
            targetData.identifier,
            targetData.discord or 'Bilinmiyor',
            targetData.isOnline and 'Çevrimiçi' or 'Çevrimdışı'
        ),
        centered = true,
        cancel = true,
        labels = {
            confirm = 'SİL (CK)',
            cancel = 'İptal'
        }
    })

    if alert == 'confirm' then
        local success = lib.callback.await('can9work-ck:server:deleteCharacter', false, targetData.source,
            targetData.identifier, targetData.name, targetData.discord)
        if success then
            lib.notify({
                title = 'Başarılı',
                description = Settings.Notifications.Success,
                type = 'success'
            })
        end
    end
end

local function ShowCharacterSelectionMenu(characters)
    local options = {}
    for i, char in ipairs(characters) do
        table.insert(options, {
            title = char.name,
            description = string.format("CitizenID: %s | %s", char.identifier,
                char.isOnline and "Çevrimiçi" or "Çevrimdışı"),
            icon = 'user',
            onSelect = function()
                ShowConfirmationMenu(char)
            end
        })
    end

    lib.registerContext({
        id = 'ck_character_selection',
        title = 'Karakter Seçimi',
        options = options
    })
    lib.showContext('ck_character_selection')
end

RegisterNetEvent('can9work-ck:client:openCKMenu', function(targetInput)
    if not targetInput then
        lib.notify({
            title = 'Hata',
            description = 'Kullanım: /ck [ID] veya /ck [DiscordID]',
            type = 'error'
        })
        return
    end

    local playerList = lib.callback.await('can9work-ck:server:getPlayerInfo', false, targetInput)

    if not playerList or #playerList == 0 then
        lib.notify({
            title = 'Hata',
            description = Settings.Notifications.PlayerNotFound,
            type = 'error'
        })
        return
    end

    if #playerList > 1 then
        ShowCharacterSelectionMenu(playerList)
    else
        ShowConfirmationMenu(playerList[1])
    end
end)

RegisterNetEvent('can9work-ck:client:openMassCK', function()
    if not Settings.MassCK.Enabled then return end

    local input = lib.inputDialog('Discord ID ile CK', {
        {
            type = 'input',
            label = 'Discord ID',
            description = 'Belirtilen Discord ID\'ye bağlı TÜM karakterler silinecektir.',
            placeholder = '123456789...',
            required = true
        },
    })

    if not input or not input[1] then return end

    local discordId = input[1]:gsub("%s+", "")
    if discordId == "" then return end

    local discordIds = { discordId }

    if #discordIds > Settings.MassCK.MaxLimit then
        lib.notify({
            title = 'Hata',
            description = string.format(Settings.Notifications.LimitExceeded, Settings.MassCK.MaxLimit),
            type = 'error'
        })
        return
    end

    local alert = lib.alertDialog({
        header = Settings.Notifications.MassConfirmTitle,
        content = string.format('**%s** Discord ID\'sine bağlı tüm karakterler silinecektir. Emin misiniz?', discordId),
        centered = true,
        cancel = true,
        labels = { confirm = 'EVET, TÜMÜNÜ SİL', cancel = 'İptal' }
    })

    if alert == 'confirm' then
        local successCount = lib.callback.await('can9work-ck:server:massDelete', false, discordIds)
        if successCount and successCount > 0 then
            lib.notify({
                title = 'Başarılı',
                description = string.format(Settings.Notifications.MassSuccess, successCount),
                type = 'success'
            })
        else
            lib.notify({
                title = 'Bilgi',
                description = 'Herhangi bir karakter silinmedi veya bir hata oluştu.',
                type = 'inform'
            })
        end
    end
end)

local cachedArchives = {}

local function HandleRestoreAction(archive, originalIndex)
    local input = lib.inputDialog('Karakter Geri Getirme', {
        {
            type = 'number',
            label = 'CID (Karakter Slotu)',
            description = 'Hangi slota geri gelsin? (Boş bırakılırsa sıradaki boş slota atanır)',
            icon = 'hashtag'
        }
    })

    if not input then return end

    local targetCid = input[1]

    local contentText = string.format('**%s** (%s) karakterini geri getirmek istediğinizden emin misiniz?',
            archive.characterName, archive.identifier)
    
    if targetCid then
        contentText = string.format('**%s** (%s) karakterini **Slot %s** olarak geri getirmek istediğinizden emin misiniz?',
            archive.characterName, archive.identifier, targetCid)
    end

    local alert = lib.alertDialog({
        header = 'Onay Bekleniyor',
        content = contentText,
        centered = true,
        cancel = true,
        labels = { confirm = 'Geri Getir', cancel = 'İptal' }
    })

    if alert == 'confirm' then
        local success, message = lib.callback.await('can9work-ck:server:restoreCharacter', false, originalIndex, targetCid)
        lib.notify({
            title = success and 'Başarılı' or 'Hata',
            description = message,
            type = success and 'success' or 'error'
        })
    end
end

local function OpenArchiveListMenu(listToRender, page, menuTitle)
    local itemsPerPage = 7
    local totalPages = math.ceil(#listToRender / itemsPerPage)
    if totalPages == 0 then totalPages = 1 end
    
    local startIndex = (page - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #listToRender)

    local options = {}

    table.insert(options, {
        title = '🔙 Ana Menüye Dön',
        icon = 'arrow-left',
        onSelect = function()
            lib.hideContext(false)
            Wait(50)
            TriggerEvent('can9work-ck:client:openRestoreMenu', true)
        end
    })

    for i = startIndex, endIndex do
        local archive = listToRender[i]
        table.insert(options, {
            title = archive.characterName,
            description = string.format("CitizenID: %s | Tarih: %s", archive.identifier, archive.date),
            icon = 'box-archive',
            onSelect = function()
                HandleRestoreAction(archive, archive.originalIndex)
            end
        })
    end

    if page > 1 then
        table.insert(options, {
            title = '⬅️ Önceki Sayfa',
            description = string.format("Sayfa %d / %d", page - 1, totalPages),
            icon = 'angle-left',
            onSelect = function()
                lib.hideContext(false)
                Wait(50)
                OpenArchiveListMenu(listToRender, page - 1, menuTitle)
            end
        })
    end

    if page < totalPages then
        table.insert(options, {
            title = 'Sonraki Sayfa ➡️',
            description = string.format("Sayfa %d / %d", page + 1, totalPages),
            icon = 'angle-right',
            onSelect = function()
                lib.hideContext(false)
                Wait(50)
                OpenArchiveListMenu(listToRender, page + 1, menuTitle)
            end
        })
    end

    local menuId = 'ck_archive_paginated_' .. page
    lib.registerContext({
        id = menuId,
        title = string.format('%s (Sayfa %d/%d)', menuTitle, page, totalPages),
        options = options
    })
    lib.showContext(menuId)
end

RegisterNetEvent('can9work-ck:client:openRestoreMenu', function(fromCache)
    if not fromCache then
        local archives = lib.callback.await('can9work-ck:server:getArchiveList', false)
        if not archives or #archives == 0 then
            lib.notify({ title = 'Bilgi', description = 'Arşivlenmiş karakter bulunamadı.', type = 'inform' })
            return
        end

        for i, v in ipairs(archives) do
            v.originalIndex = i
        end

        table.sort(archives, function(a, b)
            return (a.timestamp or 0) > (b.timestamp or 0)
        end)

        cachedArchives = archives
    end

    local options = {
        {
            title = '📜 Tüm Arşivleri Listele',
            description = string.format("Toplam %d kayıt bulunuyor.", #cachedArchives),
            icon = 'list',
            onSelect = function()
                OpenArchiveListMenu(cachedArchives, 1, 'Tüm Arşivler')
            end
        },
        {
            title = '🔍 İsim / CitizenID İle Ara',
            description = "Arşivlerde spesifik bir karakter arayın.",
            icon = 'magnifying-glass',
            onSelect = function()
                local input = lib.inputDialog('Arşivde Ara', {
                    {
                        type = 'input',
                        label = 'Arama Terimi',
                        description = 'Karakterin ismini veya CitizenID\'sini yazın',
                        required = true
                    }
                })

                if not input or not input[1] then 
                    TriggerEvent('can9work-ck:client:openRestoreMenu', true) 
                    return 
                end

                local searchTerm = string.lower(input[1])
                local filteredList = {}

                for _, arch in ipairs(cachedArchives) do
                    local nameMatch = arch.characterName and string.find(string.lower(arch.characterName), searchTerm)
                    local cidMatch = arch.identifier and string.find(string.lower(arch.identifier), searchTerm)
                    
                    if nameMatch or cidMatch then
                        table.insert(filteredList, arch)
                    end
                end

                if #filteredList > 0 then
                    OpenArchiveListMenu(filteredList, 1, 'Arama Sonuçları')
                else
                    lib.notify({ title = 'Bilgi', description = 'Aramanıza uygun sonuç bulunamadı.', type = 'error' })
                    TriggerEvent('can9work-ck:client:openRestoreMenu', true)
                end
            end
        }
    }

    lib.registerContext({
        id = 'ck_archive_main',
        title = 'CK Arşiv Yönetimi',
        options = options
    })
    lib.showContext('ck_archive_main')
end)

RegisterNetEvent('can9work-ck:client:notify', function(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type
    })
end)
