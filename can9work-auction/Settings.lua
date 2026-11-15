Settings = {
    Locale = 'tr',
    Debug = false,
    minCleanDays = 7,     -- Son bu kadar günde hapse giren (lb-tablet hapis kaydı) teklif veremez
    auctionDuration = 14,  -- İlk tekliften sonra açık artırma süresi (gün)
    -- Ihale kurallari (server/market.lua)
    Rules = {
        deposit = 10,                              -- teklifin %10'u teminat olarak bloke edilir, gecilince doner
        increase = { percent = 2, min = 1000 },    -- yeni teklif en yuksek tekliften en az %2 (en az $1.000) fazla
        closeWindow = { from = 20, to = 23 },      -- ihaleler bu saatler arasinda biter (nil: saat siniri yok)
        limits = { total = 3, perType = 2 },       -- kisi basi isletme siniri (ortakliklar sayilmaz)
        license = { percent = 1, missedWeeks = 2 }, -- haftalik ruhsat: taban fiyatin %1'i; 2 hafta ust uste odenmezse ihaleye cikar
        inactivity = { warnDays = 30, releaseDays = 45 }, -- sahip 30 gun girmezse uyari, 45 gunde ihaleye cikar
        saleFee = 5,                               -- sahip satarsa belediye harci (%)
    },
    EnableBids = true,   -- Açık artırma teklif verme ve zaman ilerleme sistemini açar/kapatır
    CancelBidPenalty = 1500, -- Teklif iptal ceza bedeli ($)
    CancelBidMinRemainingTime = 3600, -- İptal için gereken minimum kalan süre (Saniye: 60 dakika = 3600s, son 60 dk iptal edilemez)

    -- short: ekranda ve NPC'de gorunen kisa ad ("Berber #2"). resource'un GetLocations export'u isletme listesini verir.
    -- manage: panelin Kasa sayfasindaki tipe ozel yonetim butonu; o scriptin client export'unu isletme id'siyle acar.
    -- Garajin ucreti garaj ekraninin icinde (daddy_garages), burada butonu yok.
    BusinessLicenses = {
        market   = { label = "Market Lisansı", short = "Market", resource = "cloud-shop", basePrice = 100000,
                     manage = { export = "OpenStockMenu", label = "Stok ve fiyat", icon = "fa-boxes-stacked" } },
        clothing = { label = "Kıyafetçi Lisansı", short = "Kıyafet", resource = "illenium-appearance", basePrice = 50000,
                     manage = { export = "OpenBusinessPrice", label = "Hizmet fiyatı", icon = "fa-tag" } },
        barber   = { label = "Berber & Bakım", short = "Berber", resource = "illenium-appearance", basePrice = 50000,
                     manage = { export = "OpenBusinessPrice", label = "Hizmet fiyatı", icon = "fa-tag" } },
        gas      = { label = "Akaryakıt İstasyonu", short = "Benzinlik", resource = "savana-fuel", basePrice = 200000,
                     manage = { export = "OpenStationManagement", label = "İstasyon yönetimi", icon = "fa-gas-pump" } },
        wash     = { label = "Araç Yıkama", short = "Yıkama", resource = "can9work-carwash", basePrice = 30000,
                     manage = { export = "OpenBusinessPrice", label = "Yıkama fiyatı", icon = "fa-tag" } },
        garage   = { label = "Garaj İşletmesi", short = "Garaj", resource = "jg-advancedgarages", basePrice = 100000 },
    },

    -- Her isletmenin onundeki ihale gorevlisi; oyuncu distance metre icindeyken dogar. Konumlari /ihalenpc ile yerlestirilir.
    SitePed = { model = "a_m_y_business_03", scenario = "WORLD_HUMAN_CLIPBOARD", distance = 30.0 },

    Registry = {
        Ped = false, -- DaddyRP: belediye binasinin dibindeki ihale NPC'si kapali (belge ve devir tabletten yapilir)
        Location = vector4(-547.8667, -209.3323, 36.6499, 216.9071), -- x, y, z, h
        PedModel = "csb_vagspeak",
        CertificatePrice = 2000,
        TransferFee = 5000,
        ItemName = "auction_certificate"
    }
}