--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
--------------------------------------
-- <!>--  Unified Xtreme Store --<!>--
--------------------------------------
-- Destek & Geri Bildirim: https://discord.com/invite/bodhix
--------------------------------------
-- MÜŞTERİ YAPILANDIRMA DOSYASI
-- Fiyatları, görüntülenen isimleri, mağaza konumlarını vb. özelleştirmek için bu dosyayı düzenleyin.
-- Teknik ayarlar config_protected.lua içinde korunmaktadır (escrowlu)
--------------------------------------

Config = {}

Config.Debug = false -- Hata Ayıklama (Debug) Sistemi için True / False
Config.Framework = "qbox" -- "qb" / "qbox" / "esx" / "vrp" / "creative" / "custom" / "standalone"
-- "standalone" = altyapı yok (framework'süz). Tüm para/envanter/tanımlayıcı (identifier) çağrıları atlanır:
--   GetPlayerMoney  -> math.huge (oyuncu her zaman zengindir)
--   RemoveMoney/GiveMoney/GiveItem/RemoveItem/RemoveAllItems -> true döndürür
--   HasItem         -> true döndürür (oyuncu her zaman tüm ekipmanlara "sahiptir")
--   ShowNotification -> chat:addMessage kanalına yönlendirilir
--   GetPlayerIdentifier -> oyuncunun lisans (license:) tanımlayıcısı (VT için sabit)
Config.Target = "ox" -- Target Sisteminizi yazın: "qb", "ox" veya "none".
Config.TextFont = 4
Config.FrameworkResourceName = nil
Config.EnablePeds = true

-- KONTROL TARAFI (CLIENT-SIDE) envanter kontrolü, yalnızca Config.Framework == "custom" olduğunda kullanılır.
-- Ekipman çarkı istemci tarafında çalışır ve sunucu tarafındaki HasItem fonksiyonunu çağıramaz,
-- bu nedenle oyuncunun bu eşyaya sahip olup olmadığını sormak için kendi yöntemine ihtiyaç duyar.
-- Oyuncu itemName eşyasına sahipse true, değilse false döndürün. Sunucu kullanım sırasında tekrar doğrular,
-- bu yüzden bu ayar yalnızca çarkın ekipmanı sunup sunmayacağını veya satın alma uyarısı verip vermeyeceğini kontrol eder.
-- nil bırakırsanız çark oyuncunun her şeye sahip olduğunu varsayar (sunucu yetkili olmaya devam eder).
--
-- Örnek (ox_inventory):
--   Config.CustomHasItem = function(itemName)
--       return (exports.ox_inventory:Search('count', itemName) or 0) > 0
--   end
Config.CustomHasItem = function(itemName)
    return (exports.ox_inventory:Search('count', itemName) or 0) > 0
end

-- ═══════════════════════════════════════════════════════════════
-- 🎮 SPOR ÇARKI (SPORT WHEEL) YAPILANDIRMASI
-- ═══════════════════════════════════════════════════════════════
-- Spor Çarkı, oyuncuların ekipmanları arasında hızlıca geçiş yapmasını sağlar
-- Radyal çark menüsünü açmak için yapılandırılan tuşu basılı tutun
-- Tuş referansı: https://docs.fivem.net/docs/game-references/controls/
Config.SportWheel = {
    enabled = false, -- Spor çarkını tamamen devre dışı bırakmak için false yapın
    key = 0         -- Varsayılan: 0 = V tuşu (INPUT_NEXT_CAMERA)
                    -- Yaygın alternatifler:
                    -- 57 = F10, 344 = F11, 288 = F1
                    -- 289 = F2, 170 = F3, 311 = K
}

-- ═══════════════════════════════════════════════════════════════
-- 🚲 CEP BİSİKLETİ MODU (POCKETBIKE MODE) (BMX + Slopstyle)
-- ═══════════════════════════════════════════════════════════════
-- Bisikletlerin envanter eşyası olarak mı (yanınızda taşıdığınız cep bisikleti)
-- yoksa gerçek bir araç gibi park edip almanız gereken fiziksel bir nesne olarak mı
-- işleneceğini kontrol eder. Yalnızca BMX ve Slopstyle için geçerlidir.
--
-- true  (varsayılan) — mevcut davranış: bisiklet satın almak size bir eşya verir, kullanıldığında
--                      bisikleti çıkarır (spawn eder), geri kaldırma/silme işleminde siler.
-- false            — fiziksel bisiklet modu:
--                    • Satın alma işlemi bir envanter eşyası VERMEZ; bisiklet doğrudan
--                      mağazada doğar ve dünyada kalır.
--                    • Mağazanın sizinki ile başka bir oyuncununkini ayırt edebilmesi için
--                      bisiklete bir sahip dekorasyonu eklenir.
--                    • Her satın alma yeni bir bisiklet oluşturur (birden fazlasına sahip olabilirsiniz).
--                    • Tekrar özelleştirmek için bisikletinizi mağazanın yakınına getirmelisiniz:
--                        ≤ 5 m  → özelleştirmeye geçilir (ödeme gerekmez)
--                        5–20 m → bisikletinizi alana taşımanız için bildirim verilir
--                        > 20 m → mağaza yeni bir bisiklet satın almanızı ister
--                    • Bisikleti geri getirmek artık onu silmez — tekrar sürebilmeniz için
--                      en son nerede bıraktıysanız orada kalır.
Config.PocketBike = true

-- ═══════════════════════════════════════════════════════════════
-- 🌟 ÖZEL İÇERİK (Keşfet Sayfasındaki VIP Bölümü)
-- ═══════════════════════════════════════════════════════════════
-- Keşfet sayfasındaki VIP/Özel içerik bölümünü gizlemek için false yapın
-- Bu işlem yalnızca VIP paket tanıtım alanını gizler, Keşfet sayfasının tamamını gizlemez
Config.ExclusiveContent = {
    enabled = false  -- Keşfet sayfasındaki VIP bölümünü devre dışı bırakmak/gizlemek için false yapın
}

-- ═══════════════════════════════════════════════════════════════
-- 🌍 DİL SEÇİMİ (LANGUAGE)
-- ═══════════════════════════════════════════════════════════════
-- Tek bir birleşik dil seçici — Arayüz menülerini, bildirimleri,
-- mağaza istemlerini ve VIP/Discord doğrulama içeriklerini kapsar.
-- Kullanılabilir: "en", "es", "de", "fr", "it", "pt", "ru", "tr", "ar",
--                 "zh", "ja", "ko", "hi", "pl", "nl"
-- Dil dosyaları locales/<code>.lua altında yer alır. İngilizce dışındaki dosyalar
-- yalnızca VIP bölümünü çevirir; Bilgi/Mağaza/Menü bölümleri config/config_merge.lua
-- içindeki çözücü aracılığıyla otomatik olarak locales/en.lua dosyasına geri döner.
Config.Language = "tr"

-- ═══════════════════════════════════════════════════════════════
-- 🌐 DISCORD API PROXY (Kısıtlamalı Bölgeler İçin)
-- ═══════════════════════════════════════════════════════════════
-- Discord ülkenizde engelliyse (Çin, Rusya vb.), Discord API çağrılarını
-- vekil sunucumuz (proxy) üzerinden yönlendirmek için bunu true yapın.
-- Bu, kısıtlamalı bölgelerde bile Discord doğrulamasının çalışmasını sağlar.
-- ═══════════════════════════════════════════════════════════════
Config.DiscordProxy = false

-- ═══════════════════════════════════════════════════════════════
-- 🏪 MAĞAZA SAHİPLİĞİ SİSTEMİ (İsteğe Bağlı Özellik)
-- ═══════════════════════════════════════════════════════════════
-- YÖNETİCİ (ADMIN) KOMUTU: /removeowner <mağazaadı>
-- Örnek: /removeowner Skateshop
-- Bu komut, belirtilen mağazadan mevcut sahibini kaldırır.
-- Yalnızca uygun ACE izinlerine sahip yöneticiler bu komutu kullanabilir.
-- ═══════════════════════════════════════════════════════════════
Config.StoreOwnership = {
    enabled = false, -- Mağaza sahipliği sistemini etkinleştirmek için true yapın

    -- Her mağaza için satın alma fiyatları (oyuncular mağazaları satın alabilir)
    storePrices = {
        Skateshop = 500000,  -- Venice Skate Shop satın almak için $500,000
        Xtreme = 450000,     -- Xtreme Store satın almak için $450,000
        Future = 750000,     -- Future Store (özel hoverboard konumu) satın almak için $750,000
        Snowmoh = 400000     -- Mountain Ski Shop satın almak için $400,000
    },

    -- ═══════════════════════════════════════════════════════════════
    -- 🔒 SATIN ALMA BEYAZ LİSTESİ (İsteğe Bağlı - Mağaza satın alabilecekleri kısıtlayın)
    -- ═══════════════════════════════════════════════════════════════
    -- Etkinleştirildiğinde yalnızca beyaz listede tanımlayıcısı (identifier) olan oyuncular mağaza satın alabilir.
    -- Desteklenenler: steam, discord, fivem, license tanımlayıcıları
    -- Format: "tip:id" (ör. "discord:123456789", "steam:110000112345678")
    purchaseWhitelist = {
        enabled = false, -- Satın alma beyaz listesini etkinleştirmek için true yapın

        -- İzin verilen oyuncu tanımlayıcılarının listesi (Steam, Discord, FiveM, Lisans)
        -- Mağaza satın almasına izin verilen güvenilir oyuncularınızı ekleyin
        allowedPlayers = {
            -- Örnekler (gerçek kimliklerle değiştirin):
            -- "discord:123456789012345678",  -- Discord Kullanıcı ID
            -- "steam:110000112345678",       -- Steam Hex ID
            -- "fivem:12345678",              -- FiveM ID
            -- "license:abcdef1234567890",    -- Rockstar Lisansı
        }
    }
}

-- Arka Plan Müziği Yapılandırması
-- Menü açıldığında YouTube video kimlikleri rastgele seçilecektir
Config.BackgroundMusic = {
    enabled = false, -- Arka plan müziğini kapatmak için false yapın
    volume = 0.0, -- Ses seviyesi (0.0 ile 1.0 arası) - Test için geçici olarak artırıldı
    links = {

    }
}

-- Config.Language tüm shared_scripts yüklendikten sonra config_merge.lua
-- tarafından locales/<code>.lua dosyasından çözümlenir. Burada tekrar tanımlamayın.

-- ═══════════════════════════════════════════════════════════════
-- 💰 EKİPMAN FİYATLARI (Müşteri Tarafından Yapılandırılabilir)
-- Tüm ekipman kategorileri için genel fiyatlar
-- ═══════════════════════════════════════════════════════════════

Config.EquipmentPrices = {
    helmet = 5000,
    forearms = 3500,
    shinguards = 3500
}

-- ═══════════════════════════════════════════════════════════════
-- 🎮 KATEGORİ TANIMLARI (Müşteri Tarafından Yapılandırılabilir)
-- Fiyatları, görünen isimleri ve kullanılabilirliği yapılandırın
-- Teknik ayarlar config_protected.lua içindedir (escrowlu)
-- ═══════════════════════════════════════════════════════════════

Config.Categories = {
    skateboard = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Kaykay",
        parts = {
            deck = {
                price = 4500,
                modern = { count = 20 },
                classic = { count = 18 }
            },
            trucks = {
                price = 2000,
                modern = { count = 14 },
                classic = { count = 13 }
            },
            wheels = {
                price = 1500,
                modern = { count = 14 },
                classic = { count = 13 }
            }
        },
        baseItemPrice = 30000,
        repairPrice = 5000,
        itemName = "skateboard"
    },

    bmx = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "BMX",
        baseItemPrice = 20000,
        price = 15000,
        count = 10,
        itemName = "bmx",
        -- Özelleştirme sepeti fiyatlandırması. Oyuncu BMX özelleştirme
        -- sepetinden boya/parça/kaplama satın alımını onayladığında tahsil edilir.
        -- Sunucu bakiyeyi doğrular ve tasarımı yalnızca ödeme alındıktan sonra kaydeder.
        -- O türdeki değişikliği ücretsiz yapmak için herhangi bir satırı 0 yapın.
        customization = {
            pricePerColor      = 100,   -- kova renk değişimi başına (yuvalar 1-6)
            pricePerPartAssign = 50,    -- parça-kova ataması başına
            pricePerLivery     = 250,   -- kadro tasarımı / kaplama değişimi başına
            pricePerKeyChain   = 75,    -- anahtarlık eklentisi değişimi başına
            freeForOwner       = true,  -- mağaza sahipleri kendi dükkanlarında ücretsiz özelleştirme alır
        },
    },

    slopstyle = {
        -- Slopstyle bisikleti — ekipman çarkında BMX yuvasını paylaşır ancak
        -- kendi tasarımları/fiyatlandırması olan ayrı bir mağaza kategorisidir.
        displayName = "Slopstyle",
        baseItemPrice = 25000,
        price = 18000,
        count = 10,
        itemName = "slopstyle",
        customization = {
            pricePerColor      = 100,
            pricePerPartAssign = 50,
            pricePerLivery     = 250,
            pricePerKeyChain   = 75,
            freeForOwner       = true,
        },
    },

    hoverboard = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Hoverboard",
        styles = {
            ultra = {
                count = 16,
                displayName = "Ultra"
            },
            retro = {
                count = 16,
                displayName = "Retro"
            }
        },
        baseItemPrice = 50000,
        price = 35000,
        itemName = "hoverboard"
    },

    rollers = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Paten",
        styles = {
            retro = {
                count = 8,
                displayName = "Retro"
            },
            modern = {
                count = 8,
                displayName = "Modern"
            }
        },
        baseItemPrice = 12000,
        price = 8500,
        itemName = "rollers"
    },

    scooter = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Scooter",
        baseItemPrice = 15000,
        price = 10000,
        count = 10,
        itemName = "scooter"
    },

    ski = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Kayak",
        baseItemPrice = 10000,
        price = 6500,
        count = 15,
        itemName = "skis"
    },

    iceskates = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Buz Pateni",
        baseItemPrice = 7500,
        price = 4500,
        count = 6,
        itemName = "iceskates"
    },

    snowboard = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Snowboard",
        baseItemPrice = 12000,
        price = 7500,
        count = 16,
        itemName = "snowboard"
    },

    surfboard = {
        -- Müşteri tarafından yapılandırılabilir ayarlar
        displayName = "Sörf Tahtası",
        baseItemPrice = 25000,
        price = 15000,
        count = 10,
        itemName = "surfboard"
    }
}

-- ═══════════════════════════════════════════════════════════════
-- 🏪 MAĞAZA KONUMLARI (Nokta Bazlı Yapılandırma)
-- Her nokta şunları tanımlar: NPC konumu, kullanılabilir kategoriler, kamera ve ekipman doğma (spawn) koordinatları
-- ═══════════════════════════════════════════════════════════════

Config.Spots = {
    -- Skateshop = {
    --     -- Kaynak bağımlılığı (NPC yalnızca bu kaynak varsa doğar, nil = her zaman doğar)
    --     dependency = "BDX-XTreme-Stores",

    --     -- Mağaza Çalışma Saatleri (24 saatlik format, nil = her zaman açık)
    --     hours = {
    --         open = 7,   -- 08:00
    --         close = 22  -- 22:00
    --     },

    --     -- Mağaza Kapanış Etkinlikleri (mağaza açıldığında/kapandığında tetiklenir)
    --     closureEvents = {
    --         enabled = true,                              -- Bu mağaza için kapanış etkinliklerini etkinleştir
    --         onOpen = "xtreme-store:venice:open",         -- Mağaza açıldığında tetiklenen etkinlik (event)
    --         onClose = "xtreme-store:venice:close"        -- Mağaza kapandığında tetiklenen etkinlik (event)
    --     },

    --     -- NPC Konumu
    --     npc = {
    --         x = -1391.1029,       -- Varıştaki doğma (spawn) noktası
    --         y = -1353.1666,
    --         z = 3.8108,
    --         heading = 216.3694,
    --         model = 'A_F_Y_Beach_02',
    --         sex = 'female', -- Tepki sesleri için kullanılır
    --         scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
    --     },

    --     -- NPC Doğma/Ayrılma Noktaları (gerçekçi geliş/gidiş için)
    --     npcSpawn = {
    --         x = -1389.0210,       -- Varıştaki doğma (spawn) noktası       
    --         y = -1358.1669, 
    --         z = 3.8109, 
    --         heading = 34.7941
    --     },
    --     npcLeave = {
    --         x = -1389.0210, 
    --         y = -1358.1669, 
    --         z = 3.8109, 
    --         heading = 214.7941    -- Ayrılırken bu noktaya yürür
    --     },

    --     -- Müzik Mesafe Ayarları (yakınlığa dayalı arka plan müziği)
    --     musicDistance = {
    --         maxDistance = 20.0,      -- Müziğin sessizleştiği mesafe (0 ses seviyesi)
    --         maxVolumeDistance = 5.0  -- Müziğin maksimum ses seviyesine ulaştığı mesafe
    --     },
    --     -- Kamera Pozisyonları (kategori başına)
    --     cameras = {
    --         skateboard = {
    --             x = -1387.0508,   
    --             y = -1361.0262,
    --             z = 4.2108,
    --             heading = 284.1524,
    --             angle = -9.0
    --         },
    --         hoverboard = {
    --             x = -1387.0508,   
    --             y = -1361.0262,
    --             z = 4.2108,
    --             heading = 284.1524,
    --             angle = -9.0
    --         },
    --         bmx = {
    --             x = -1392.9088,   
    --             y = -1365.2523,
    --             z = 3.4401,
    --             heading = 302.2807,
    --             angle = -14.0
    --         },
    --         -- Slopstyle kendi fiziksel noktasını kullanır. Varsayılan olarak BMX koordinatlarıdır;
    --         -- slopstyle'ın kendi matında olmasını istiyorsanız farklı bir konuma ayarlayın.
    --         slopstyle = {
    --             x = -1392.9088,   
    --             y = -1365.2523,
    --             z = 3.4401,
    --             heading = 302.2807,
    --             angle = -14.0
    --         },
    --         scooter = {
    --            x = -1392.9088,   
    --             y = -1365.2523,
    --             z = 3.4401,
    --             heading = 302.2807,
    --             angle = -14.0
    --         },
    --         rollers = {
    --             x = -1386.2020, 
    --             y = -1361.1079, 
    --             z = 6.8957, 
    --             heading = 97.5469,
    --             angle = -11.0,
    --             dict = 'amb@lo_res_idles@',
    --             name = 'world_human_picnic_female_lo_res_base'
    --         },
    --         ski = {
    --             x = -1387.0508,   
    --             y = -1361.0262,
    --             z = 4.2108 ,
    --             heading = 284.1524,
    --             angle = -9.0
    --         },
    --         iceskates = {
    --             x = -1386.2020, 
    --             y = -1361.1079, 
    --             z = 6.8957, 
    --             heading = 97.5469,
    --             angle = -11.0,
    --             dict = 'amb@lo_res_idles@',
    --             name = 'world_human_picnic_female_lo_res_base'
    --         },
    --         snowboard = {
    --             x = -1387.0508,   
    --             y = -1361.0262,
    --             z = 4.2108,
    --             heading = 284.1524,
    --             angle = -9.0
    --         },
    --         surfboard = {
    --             x = -1387.0508,   
    --             y = -1361.0262,
    --             z = 4.2108,
    --             heading = 284.1524,
    --             angle = -9.0
    --         }
    --     },
    --     -- Ekipman Doğma Pozisyonları (kategori başına)
    --     gearSpawns = {
    --         skateboard = {
    --             x = -1386.0243,   
    --             y = -1360.8073,
    --             z = 3.95,
    --             heading = 219.9016,
    --             angle = -17.0
    --         },
    --         hoverboard = {
    --             x = -1386.0243,   
    --             y = -1360.8073,
    --             z = 3.5,
    --             heading = 39.9016,
    --             angle = 197.0
    --         },
    --         bmx = {
    --             x = -1391.4526,   
    --             y = -1364.3229,
    --             z = 3.8109,
    --             heading = 78.7178,
    --             angle = 180.0
    --         },
    --         -- Slopstyle kendi fiziksel noktasını kullanır. Varsayılan olarak BMX koordinatlarıdır;
    --         -- slopstyle'ın kendi matında olmasını istiyorsanız farklı bir konuma ayarlayın.
    --         slopstyle = {
    --             x = -1391.4526,   
    --             y = -1364.3229,
    --             z = 3.8109,
    --             heading = 78.7178,
    --             angle = 180.0
    --         },
    --         scooter = {
    --             x = -1391.4526,   
    --             y = -1364.3229,
    --             z = 2.8,
    --             heading = 78.7178,
    --             angle = 180.0
    --         },
    --         rollers = {
    --             x = -1387.5719,   
    --             y = -1361.1594,
    --             z = 6.5,
    --             heading = 301.1185,
    --             angle = 0.0
    --         },
    --         ski = {
    --             x = -1386.0243,   
    --             y = -1360.8073,
    --             z = 3.4,
    --             heading = 219.9016,
    --             angle = 127.0
    --         },
    --         iceskates = {
    --             x = -1387.5719,   
    --             y = -1361.1594,
    --             z = 6.5,
    --             heading = 301.1185,
    --             angle = 0.0
    --         },
    --         snowboard = {
    --             x = -1386.0243,   
    --             y = -1360.8073,
    --             z = 3.6,
    --             heading = 219.9016,
    --             angle = 127.0
    --         },
    --         surfboard = {
    --             x = -1386.0243,   
    --             y = -1360.8073,
    --             z = 4.0,
    --             heading = 219.9016,
    --             angle = 127.0
    --         }
    --     },
    --     -- Bu noktadaki kullanılabilir kategoriler
    --     availableCategories = {
    --         "skateboard",
    --         "hoverboard",
    --         "bmx",
    --         "slopstyle",
    --         "scooter",
    --         "rollers",
    --         "ski",
    --         "iceskates",
    --         "snowboard",
    --         "surfboard"
    --     },

    --     -- Ekipman Mağazası Koordinatları
    --     equipmentCoords = vector4(-1391.7386, -1357.7323, 3.8108, 217.5584), -- Venice Beach ekipman alanı
    --     equipmentCameraCoords = vector4(-1390.2413, -1360.0151, 3.8108, 36.2253) -- Ekipman kamerası pozisyonu
    -- },
    -- Xtreme = {
    --     -- Kaynak bağımlılığı (NPC yalnızca bu kaynak varsa doğar, nil = her zaman doğar)
    --     dependency = "BDX-XTreme-Stores",

    --     -- Mağaza Çalışma Saatleri (24 saatlik format, nil = her zaman açık)
    --     hours = {
    --         open = 8,   -- 09:00
    --         close = 22  -- 21:00
    --     },

    --     -- NPC Konumu
    --     npc = {
    --         x = 273.6808,
    --         y = 136.0932,
    --         z = 104.4110,
    --         heading = 338.3990,
    --         model = 'a_m_m_skater_01',
    --         sex = 'male', -- Tepki sesleri için kullanılır
    --         scenario = 'WORLD_HUMAN_STRIP_WATCH_STAND'
    --     },

    --     -- NPC Doğma/Ayrılma Noktaları (gerçekçi geliş/gidiş için)
    --     npcSpawn = {
    --         x = 278.0,
    --         y = 132.0,
    --         z = 104.4,
    --         heading = 180.0
    --     },
    --     npcLeave = {
    --         x = 270.0,
    --         y = 142.0,
    --         z = 104.4,
    --         heading = 60.0
    --     },
    --     -- Müzik Mesafe Ayarları (yakınlığa dayalı arka plan müziği)
    --     musicDistance = {
    --         maxDistance = 15.0,      -- Müziğin sessizleştiği mesafe (0 ses seviyesi)
    --         maxVolumeDistance = 5.0  -- Müziğin maksimum ses seviyesine ulaştığı mesafe
    --     },
    --     -- Kamera Pozisyonları (kategori başına)
    --     cameras = {
    --         skateboard = {
    --             x = 276.8861,
    --             y = 139.7246,
    --             z = 104.88,
    --             heading = 213.8,
    --             angle = -8.0
    --         },
    --         hoverboard = {
    --             x = 276.8861,
    --             y = 139.7246,
    --             z = 104.88,
    --             heading = 213.8,
    --             angle = -8.0
    --         },
    --         bmx = {
    --             x = 277.3705,
    --             y = 136.1456,
    --             z = 104.4036,
    --             heading = 233.7569,
    --             angle = -8.0
    --         },
    --         -- Slopstyle kendi fiziksel noktasını kullanır. Varsayılan olarak BMX koordinatlarıdır;
    --         -- slopstyle'ın kendi matında olmasını istiyorsanız farklı bir konuma ayarlayın.
    --         slopstyle = {
    --             x = 277.3705,
    --             y = 136.1456,
    --             z = 104.4036,
    --             heading = 233.7569,
    --             angle = -8.0
    --         },
    --         scooter = {
    --             x = 277.3705,
    --             y = 136.1456,
    --             z = 104.4036,
    --             heading = 233.7569,
    --             angle = -13.0
    --         },
    --         rollers = {
    --             x = 276.5972,
    --             y = 141.7703,
    --             z = 104.3924,
    --             heading = 69.4569,
    --             angle = -8.0,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         ski = {
    --             x = 276.8861,
    --             y = 139.7246,
    --             z = 104.88,
    --             heading = 213.8,
    --             angle = -8.0
    --         },
    --         iceskates = {
    --             x = 276.5972,
    --             y = 141.7703,
    --             z = 104.3924,
    --             heading = 69.4569,
    --             angle = -8.0,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         snowboard = {
    --             x = 276.8861,
    --             y = 139.7246,
    --             z = 104.88,
    --             heading = 213.8,
    --             angle = -8.0
    --         },
    --         surfboard = {
    --             x = 276.8861,
    --             y = 139.7246,
    --             z = 104.88,
    --             heading = 213.8,
    --             angle = -8.0
    --         }
    --     },
    --     -- Ekipman Doğma Pozisyonları (kategori başına)
    --     gearSpawns = {
    --         skateboard = {
    --             x = 277.35,
    --             y = 138.9,
    --             z = 104.31,
    --             heading = 159.0,
    --             angle = -17.0
    --         },
    --         hoverboard = {
    --             x = 277.35,
    --             y = 138.9,
    --             z = 104.11,
    --             heading = -20.0,
    --             angle = 197.0
    --         },
    --         bmx = {
    --             x = 278.5116,
    --             y = 135.4036,
    --             z = 103.9110,
    --             heading = 296.0635,
    --             angle = 180.0
    --         },
    --         -- Slopstyle kendi fiziksel noktasını kullanır. Varsayılan olarak BMX koordinatlarıdır;
    --         -- slopstyle'ın kendi matında olmasını istiyorsanız farklı bir konuma ayarlayın.
    --         slopstyle = {
    --             x = 278.5116,
    --             y = 135.4036,
    --             z = 103.9110,
    --             heading = 296.0635,
    --             angle = 180.0
    --         },
    --         scooter = {
    --             x = 278.5116,
    --             y = 135.4036,
    --             z = 103.4110,
    --             heading = 95.0635,
    --             angle = 180.0
    --         },
    --          rollers = {
    --             x = 274.8313,
    --             y = 142.3921,
    --             z = 103.4111,
    --             heading = 247.7757,
    --             angle = -17.0
    --         },
    --         ski = {
    --             x = 277.35,
    --             y = 138.9,
    --             z = 104.08,
    --             heading = 120.0,
    --             angle = 127.0
    --         },
    --         iceskates = {
    --             x = 274.8313,
    --             y = 142.3921,
    --             z = 103.4111,
    --             heading = 247.7757,
    --             angle = -17.0
    --         },
    --         snowboard = {
    --             x = 277.35,
    --             y = 138.9,
    --             z = 104.20,
    --             heading = 120.0,
    --             angle = 127.0
    --         },
    --         surfboard = {
    --             x = 277.35,
    --             y = 138.9,
    --             z = 104.60,
    --             heading = 120.0,
    --             angle = 127.0
    --         }
    --     },
    --     -- Bu noktadaki kullanılabilir kategoriler
    --     availableCategories = {
    --         "skateboard",
    --         "hoverboard",
    --         "bmx",
    --         "slopstyle",
    --         "scooter",
    --         "rollers",
    --         "ski",
    --         "iceskates",
    --         "snowboard",
    --         "surfboard"
    --     },

    --     -- Ekipman Mağazası Koordinatları
    --     equipmentCoords = vector4(274.3246, 132.5146, 104.4111, 246.3417), -- Xtreme Store ekipman alanı
    --     equipmentCameraCoords = vector4(276.2878, 131.9357, 104.4111, 69.9333) -- Ekipman kamerası pozisyonu
    -- },
    -- Future = {
    --     -- Kaynak bağımlılığı (NPC yalnızca bu kaynak varsa doğar, nil = her zaman doğar)
    --     dependency = "BDX-Future-Store",

    --     -- Mağaza Çalışma Saatleri (24 saatlik format, nil = her zaman açık)
    --     hours = {
    --         open = 0,   -- Her zaman açık (0 = gece yarısı, 24 saat)
    --         close = 24  -- Her zaman açık
    --     },

    --     -- NPC Konumu
    --     npc = {
    --         x = -1403.8314,
    --         y = -1417.6881,
    --         z = 6.6386,
    --         heading = 2.9339,
    --         model = 'cs_chrisformage',
    --         sex = 'male', -- Tepki sesleri için kullanılır
    --         scenario = 'WORLD_HUMAN_CLIPBOARD'
    --     },

    --     -- NPC Doğma/Ayrılma Noktaları (gerçekçi geliş/gidiş için)
    --     npcSpawn = {
    --         x = -1408.0,
    --         y = -1420.0,
    --         z = 6.6,
    --         heading = 90.0
    --     },
    --     npcLeave = {
    --         x = -1398.0,
    --         y = -1414.0,
    --         z = 6.6,
    --         heading = 270.0
    --     },
    --     -- Müzik Mesafe Ayarları (yakınlığa dayalı arka plan müziği)
    --     musicDistance = {
    --         maxDistance = 20.0,      -- Müziğin sessizleştiği mesafe (0 ses seviyesi)
    --         maxVolumeDistance = 5.0  -- Müziğin maksimum ses seviyesine ulaştığı mesafe
    --     },
    --     -- Kamera Pozisyonları (kategori başına)
    --     cameras = {
    --         skateboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         hoverboard = {
    --             x = -1404.0228,   
    --             y = -1414.1089,
    --             z = 7.1,
    --             heading = 296.6042,
    --             angle = -14.0
    --         },
    --         bmx = {
    --             x = nil,   
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         -- Slopstyle girişi — bu mağaza için BMX ile eşleşen nil dolu taslak.
    --         slopstyle = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         scooter = {
    --             x = nil,   
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         rollers = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         ski = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         iceskates = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         snowboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil,
    --         },
    --         surfboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --     },
    --     -- Ekipman Doğma Pozisyonları (kategori başına)
    --     gearSpawns = {
    --         skateboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         hoverboard = {
    --             x = -1403.1,
    --             y = -1413.65,
    --             z = 6.0,
    --             heading = 29.0 ,
    --             angle = 205.0
    --         },
    --         bmx = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         -- Slopstyle girişi — bu mağaza için BMX ile eşleşen nil dolu taslak.
    --         slopstyle = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         scooter = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --          rollers = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         ski = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         iceskates = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         snowboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         surfboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         }
    --     },
    --     -- Bu noktadaki kullanılabilir kategoriler
    --     availableCategories = {
    --         "hoverboard",
    --     },

    --     -- Ekipman Mağazası Koordinatları
    --     equipmentCoords = vector4(-1404.5692, -1410.6354, 3.7961, 207.8536), -- Future Store ekipman alanı
    --     equipmentCameraCoords = vector4(-1403.7079, -1412.4713, 3.7961, 28.6214) -- Ekipman kamerası pozisyonu
    -- },
    -- Snowmoh = {
    --     -- Kaynak bağımlılığı (NPC yalnızca bu kaynak varsa doğar, nil = her zaman doğar)
    --     dependency = "BDX-Snow-Motion",

    --     -- Mağaza Çalışma Saatleri (24 saatlik format, nil = her zaman açık)
    --     hours = {
    --         open = 6,   -- 07:00 (kayak dükkanları erken açılır)
    --         close = 23  -- 20:00
    --     },

    --     -- NPC Konumu
    --     npc = {
    --         x = 464.8428,
    --         y = 5572.7905,
    --         z = 782.3241,
    --         heading = 90.4061,
    --         model = 'a_m_y_motox_02',
    --         sex = 'male', -- Tepki sesleri için kullanılır
    --         scenario = 'WORLD_HUMAN_AA_COFFEE'
    --     },
    --     -- NPC Doğma/Ayrılma Noktaları (gerçekçi geliş/gidiş için)
    --     npcSpawn = {
    --         x = 468.0,
    --         y = 5575.0,
    --         z = 782.3,
    --         heading = 200.0
    --     },
    --     npcLeave = {
    --         x = 460.0,
    --         y = 5568.0,
    --         z = 782.3,
    --         heading = 45.0
    --     },
        
    --     -- Müzik Mesafe Ayarları (yakınlığa dayalı arka plan müziği)
    --     musicDistance = {
    --         maxDistance = 25.0,      -- Müziğin sessizleştiği mesafe (0 ses seviyesi)
    --         maxVolumeDistance = 5.0  -- Müziğin maksimum ses seviyesine ulaştığı mesafe
    --     },
    --     -- Kamera Pozisyonları (kategori başına)
    --     cameras = {
    --         skateboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         hoverboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         bmx = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         -- Slopstyle girişi — bu mağaza için BMX ile eşleşen nil dolu taslak.
    --         slopstyle = {
    --             x = 461.1019,   
    --             y = 5575.7612,
    --             z = 782.3240,
    --             heading = 11.3329,
    --             angle = 0.0
    --         },
    --         scooter = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         rollers = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         ski = {
    --             x = 461.7201,
    --             y = 5571.4639,
    --             z = 782.8,
    --             heading = 180.6092,
    --             angle = -8.0
    --         },
    --         iceskates = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil,
    --             dict = 'rcm_barry3',
    --             name = 'barry_3_sit_loop'
    --         },
    --         snowboard = {
    --             x = 461.7201,
    --             y = 5571.4639,
    --             z = 782.8,
    --             heading = 180.6092,
    --             angle = -8.0
    --         },
    --         surfboard = {
    --             x = 461.7201,
    --             y = 5571.4639,
    --             z = 782.8,
    --             heading = 180.6092,
    --             angle = -8.0
    --         }
    --     },
    --     -- Ekipman Doğma Pozisyonları (kategori başına)
    --     gearSpawns = {
    --         skateboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         hoverboard = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         bmx = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         -- Slopstyle girişi — bu mağaza için BMX ile eşleşen nil dolu taslak.
    --         slopstyle = {
    --             x = 461.0858,   
    --             y = 5578.3721,
    --             z = 782.3239,
    --             heading = 170.8248,
    --             angle = 0.0
    --         },
    --         scooter = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --          rollers = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         ski = {
    --             x = 461.8075,
    --             y = 5569.8018,
    --             z = 781.8,
    --             heading = 90.0,
    --             angle = 127.0
    --         },
    --         iceskates = {
    --             x = nil,
    --             y = nil,
    --             z = nil,
    --             heading = nil,
    --             angle = nil
    --         },
    --         snowboard = {
    --             x = 461.8075,
    --             y = 5569.8018,
    --             z = 781.8,
    --             heading = 90.0,
    --             angle = 127.0
    --         },
    --         surfboard = {
    --             x = 461.8075,
    --             y = 5569.8018,
    --             z = 782.2,
    --             heading = 90.0,
    --             angle = 127.0
    --         }
    --     },
    --     -- Bu noktadaki kullanılabilir kategoriler
    --     availableCategories = {
    --         "ski",
    --         "snowboard",
    --         "slopstyle",
    --     },

    --     -- Ekipman Mağazası Koordinatları
    --     equipmentCoords = vector4(464.5814, 5566.9805, 782.3248, 28.1487), -- Snowmoh Store ekipman alanı
    --     equipmentCameraCoords = vector4(463.1483, 5568.6631, 782.3248, 209.5430) -- Ekipman kamerası pozisyonu
    -- },
}

-- ═══════════════════════════════════════════════════════════════
-- WAX YOLU SİSTEMİ (Tüm sporlar için ortak kayma rayları)
-- ═══════════════════════════════════════════════════════════════
-- Wax moduna girmek için /waxmode kullanın, yüzeylere nişan alın ve wax noktaları yerleştirmek için E tuşuna basın.
-- Kaydetmek için /waxsave, iptal etmek için /waxcancel, son noktayı kaldırmak için /waxundo kullanın.
-- Kaydedilen yolları görmek için /waxlist, birini kaldırmak için /waxdelete [id], tümünü kaldırmak için /waxclear kullanın.
-- Raylar sunucu tarafında saklanır ve tüm oyuncular ile spor komut dosyaları arasında paylaşılır.

-- ═══════════════════════════════════════════════════════════════
-- TUŞ ATAMA AYARLARI MENÜSÜ
-- ═══════════════════════════════════════════════════════════════
-- Tuş atama ayarları menüsünü açmak için oyun içinde bu tuşa basın
-- Oyuncular spor kontrollerini kişisel olarak özelleştirebilir (KVP aracılığıyla kaydedilir)
-- Tuş referansı: https://docs.fivem.net/docs/game-references/controls/
Config.KeyBindMenu = 311 -- 311 = K tuşu

Config.Wax = {
    GrindDetectDistance = 3.0,  -- Hedef seçeneklerini göstermek için wax yolu başlangıcına ne kadar yakın olunacağı
    SetupKey = 38,              -- Kurulum modunda wax noktası koyma tuşu (38 = E)
    UndoKey = 202,              -- Kurulum modunda son wax noktasını geri alma tuşu (202 = Backspace)

    -- OTOMATİK İZLEME (AUTO-TRACE): Kayılabilir bir rayın yakınına nişan aldığınızda, sistem
    -- kenarı her iki yönde yürütür ve tüm yolu otomatik olarak doldurur.
    -- "Save Path" seçeneğine tıklamak izlenen sonucu kaydeder. Eski tek tek nokta
    -- tıklama davranışına geri dönmek için false yapın.
    AutoTrace          = true,
    AutoTraceInterval  = 200,   -- Nişan alırken yeniden izleme arasındaki milisaniye (düşük = daha seri sarı hedef)
    AutoTraceMoveGate  = 0.3,   -- Nişan bundan daha fazla hareket ederse hemen yeniden izle (metre)

    -- Beyaz Liste (Whitelist): /waxmode komutunu kimlerin kullanabileceğini kısıtlayın (wax yolu koyma/düzenleme/silme)
    -- Etkinleştirildiğinde yalnızca beyaz listede tanımlayıcılara sahip oyuncular wax moduna girebilir.
    -- Devre dışı bırakıldığında wax modu varsayılan ACE iznini kullanır (yalnızca yöneticiler).
    Whitelist = {
        enabled = false,        -- Wax modu beyaz listesini etkinleştirmek için true yapın
        allowedPlayers = {
            -- Örnekler (gerçek kimliklerle değiştirin):
            -- "discord:123456789012345678",
            -- "steam:110000112345678",
            -- "fivem:12345678",
            -- "license:abcdef1234567890",
        }
    }
}
