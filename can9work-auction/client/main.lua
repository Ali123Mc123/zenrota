can9work = {}
can9work.UI = { isOpen = false }

can9work.SendVueMessage = function(eventName, data)
    SendNUIMessage({ action = eventName, data = data })
end

local function StreetAt(c)
    if not c then return nil end
    local street = GetStreetNameAtCoord(c.x, c.y, c.z)
    local name = street and GetStreetNameFromHashKey(street)
    return name ~= '' and name or nil
end

-- mode: 'site' (isletme paneli, NPC'den) ya da 'board' (ilan tableti). Panel verisini kendisi ister.
can9work.UI.Open = function(self, mode, data)
    if self.isOpen then return end
    self.isOpen = true
    SetNuiFocus(true, true)
    data = data or {}
    data.mode = mode
    data.locales = GetTranslations()
    can9work.SendVueMessage("open", data)
end

can9work.UI.OpenTerminal = function(self, tab)
    self:Open('board', { tab = tab or 'list' })
end

-- site: client/npc.lua'daki isletme ({ id, label, ped })
can9work.UI.OpenSite = function(self, site)
    self:Open('site', { id = site.id, street = StreetAt(site.ped) })
end

-- Panelin sunucudan isteyebilecegi veriler; baska callback'e NUI'den ulasilamaz.
local PANEL_CALLS = {
    site = true, siteHistory = true, siteCash = true, sitePartners = true, siteLogs = true,
    siteWithdraw = true, siteDeposit = true, listings = true,
    placeBid = true, placeConsortiumBid = true, cancelBid = true, printCertificate = true, transferBusiness = true,
    setProxy = true, startSale = true, cancelSale = true, offerSale = true, invitePartner = true, removePartner = true,
    -- admin penceresi (sunucu yetkiyi kendisi kontrol eder)
    adminList = true, adminDetail = true, adminAction = true, adminRunChecks = true, placeSitePed = true, removeSitePed = true
}

RegisterNUICallback('can9work-auction/nui/call', function(data, cb)
    local name = type(data) == 'table' and data.name
    if not PANEL_CALLS[name] then return cb({}) end
    local result = table.pack(lib.callback.await('can9work-auction/server/' .. name, false, table.unpack(data.args or {})))

    -- Tablette sokak adlari burada eklenir (sadece istemci bilir).
    if name == 'listings' and type(result[1]) == 'table' then
        for _, row in ipairs(result[1].list or {}) do row.street = StreetAt(row.ped) end
    end
    cb({ result[1], result[2] })
end)

-- Kasa sayfasindaki tipe ozel yonetim (Settings.BusinessLicenses[tip].manage): panel kapanir, o scriptin menusu acilir.
RegisterNUICallback('can9work-auction/nui/manage', function(data, cb)
    cb('ok')
    local id = type(data) == 'table' and tostring(data.id or '')
    local license = id and Settings.BusinessLicenses[id:match('^(%a+)_%d+$') or '']
    if not license or not license.manage then return end

    SetNuiFocus(false, false)
    can9work.UI.isOpen = false
    can9work.SendVueMessage("closeUI")
    Wait(100)
    if GetResourceState(license.resource) ~= 'started' then
        return lib.notify({ title = 'İhale', description = 'Bu işletmenin sistemi şu an kapalı.', type = 'error' })
    end
    local resource = exports[license.resource]
    resource[license.manage.export](resource, id)
end)

-- Admin penceresi (/ihaleadmin)
RegisterNetEvent('can9work-auction/client/openAdmin', function()
    can9work.UI:Open('admin', {})
end)

-- Admin: NPC'nin 1.2 m onune, ona donuk isinlanir.
RegisterNUICallback('can9work-auction/nui/teleport', function(data, cb)
    cb('ok')
    if type(data) ~= 'table' or not data.x then return end
    local rad = math.rad(data.w or 0.0)
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(cache.ped, data.x - math.sin(rad) * 1.2, data.y + math.cos(rad) * 1.2, data.z - 1.0, false, false, false, false)
    SetEntityHeading(cache.ped, ((data.w or 0.0) + 180.0) % 360.0)
end)

RegisterNUICallback('can9work-auction/nui/waypoint', function(data, cb)
    if type(data) == 'table' and data.x and data.y then
        SetNewWaypoint(data.x + 0.0, data.y + 0.0)
        lib.notify({ title = 'İhale', description = 'Yol haritada işaretlendi.', type = 'success' })
    end
    cb('ok')
end)

exports('OpenAuctionTablet', function()
    can9work.UI:OpenTerminal()
end)

RegisterNetEvent('can9work-auction/client/openTerminal', function()
    can9work.UI:OpenTerminal()
end)

exports('OpenCertificate', function(data, itemData)
    if not itemData.metadata then
        can9work.SendVueMessage("showCertificate", itemData.metadata or {})
        return
    end

    SetNuiFocus(true, true)
    can9work.SendVueMessage("showCertificate", itemData.metadata)
end)

-- Bir teklif ya da ihale sonucu olunca acik panel kendi verisini yeniden ister.
RegisterNetEvent('can9work_auction/client/refreshData', function()
    if not can9work.UI.isOpen then return end
    can9work.SendVueMessage("refresh")
end)

RegisterNUICallback('can9work-auction/nui/placeBid', function(data, cb)
    cb(lib.callback.await('can9work-auction/server/placeBid', false, data))
end)

RegisterNUICallback('can9work-auction/nui/placeConsortiumBid', function(data, cb)
    cb(lib.callback.await('can9work-auction/server/placeConsortiumBid', false, data))
end)

RegisterNUICallback('can9work-auction/nui/cancelBid', function(data, cb)
    cb(lib.callback.await('can9work-auction/server/cancelBid', false, data))
end)

RegisterNUICallback('can9work-auction/nui/closeUI', function(data, cb)
    SetNuiFocus(false, false)
    can9work.UI.isOpen = false
    can9work.SendVueMessage("closeUI")
    cb('ok')
end)

RegisterNUICallback('can9work-auction/nui/getData', function(data, cb)
    local result = lib.callback.await('can9work-auction/server/getData', false)
    cb(result)
end)

-- CERTIFICATE & REGISTRY CLIENT LOGIC

RegisterNetEvent('can9work-auction/client/viewCertificate', function(metadata)
    SetNuiFocus(true, true)
    can9work.SendVueMessage("showCertificate", metadata)
end)

RegisterNUICallback('can9work-auction/nui/getOwnedAssets', function(_, cb)
    cb(lib.callback.await('can9work-auction/server/getOwnedAssets', false))
end)

RegisterNUICallback('can9work-auction/nui/printCertificate', function(assetId, cb)
    cb(lib.callback.await('can9work-auction/server/printCertificate', false, assetId))
end)

CreateThread(function()
    if Settings.Registry.Ped == false then return end
    local modelStr = Settings.Registry.PedModel
    local model = GetHashKey(modelStr)
    
    if not IsModelValid(model) then
        return
    end

    if not lib.requestModel(model, 10000) then
        return
    end

    local pedCoords = Settings.Registry.Location
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local npc = CreatePed(4, model, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, false)
    
    if DoesEntityExist(npc) then
        SetEntityHeading(npc, pedCoords.w)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)
        
        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'open_registry',
                icon = 'fas fa-file-contract',
                label = _L('notify.registry_office'),
                onSelect = function()
                    -- Tapu Dairesi: tablet "İşletmelerim" sekmesinde acilir (belge ve devir oradan).
                    can9work.UI:OpenTerminal('mine')
                end
            },
            {
                name = 'transfer_business',
                icon = 'fas fa-handshake',
                label = 'İşletme Devret',
                onSelect = function()
                    local assets = lib.callback.await('can9work-auction/server/getOwnedAssets', false)
                    if not assets or #assets == 0 then
                        lib.notify({ title = 'Hata', description = 'Devredecek bir işletmeniz yok!', type = 'error' })
                        return
                    end
                    
                    local options = {}
                    for i=1, #assets do
                        options[#options+1] = {
                            title = assets[i].title,
                            description = 'Bu işletmeyi devretmek için seçin.',
                            icon = 'fas fa-building',
                            onSelect = function()
                                local input = lib.inputDialog('İşletme Devri', {
                                    {type = 'number', label = 'Oyuncu ID', description = 'Devredilecek oyuncunun sunucu ID numarası. NOT: Devir işlemi $5,000 işlem ücreti keser!', required = true, min = 1}
                                })
                                if not input then return end
                                local targetId = input[1]
                                
                                local success, message = lib.callback.await('can9work-auction/server/transferBusiness', false, assets[i].id, targetId)
                                lib.notify({ title = success and 'Başarılı' or 'Hata', description = message, type = success and 'success' or 'error' })
                            end
                        }
                    end
                    
                    lib.registerContext({
                        id = 'business_transfer_menu',
                        title = 'Sahip Olduğunuz İşletmeler',
                        options = options
                    })
                    lib.showContext('business_transfer_menu')
                end
            }
        })
    end
end)

RegisterNetEvent('can9work-auction/client/receiveConsortiumInvite', function(proposalId, leaderName, auctionName, share)
    local alert = lib.alertDialog({
        header = 'Konsorsiyum İhale Ortaklık Daveti',
        content = ('**%s** sizi **%s** işletmesi için ortak ihaleye davet ediyor.\n\n**Hisse Payınız:** %%%s\n\nDaveti kabul ediyor musunuz?'):format(leaderName, auctionName, share),
        centered = true,
        cancel = true,
        labels = { confirm = 'Kabul Et', cancel = 'Reddet' }
    })

    TriggerServerEvent('can9work-auction/server/respondConsortiumInvite', proposalId, alert == 'confirm')
end)

-- Bir isletme sahibinin satis teklifi (Ayarlar > Bir oyuncuya sat).
RegisterNetEvent('can9work-auction/client/saleOffer', function(id, sellerName, label, price, fee)
    local answer = lib.alertDialog({
        header = 'İşletme satış teklifi',
        content = ('**%s**, **%s** işletmesini sana **$%s** karşılığında satmak istiyor.\n\nKabul edersen para bankandan çekilir ve işletme senin olur.'):format(sellerName, label, price),
        centered = true,
        cancel = true,
        labels = { confirm = 'Satın al', cancel = 'Reddet' }
    })
    TriggerServerEvent('can9work-auction/server/respondSaleOffer', id, answer == 'confirm')
end)

-- Isletme sahibinin ortaklik daveti (Ortaklar > Ortak ekle).
RegisterNetEvent('can9work-auction/client/partnerInvite', function(id, ownerName, label, share)
    local answer = lib.alertDialog({
        header = 'Ortaklık daveti',
        content = ('**%s**, seni **%s** işletmesine **%%%s** hisseyle ortak olmaya davet ediyor.\n\nOrtak olursan kasaya giren her satıştan hissen kadar pay alırsın.'):format(ownerName, label, share),
        centered = true,
        cancel = true,
        labels = { confirm = 'Ortak ol', cancel = 'Reddet' }
    })
    TriggerServerEvent('can9work-auction/server/respondPartnerInvite', id, answer == 'confirm')
end)
