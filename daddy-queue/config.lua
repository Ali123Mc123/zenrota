Config = {}
Config.Debug = false

-- Birincil tanimlayici (license | discord | steam | fivem | ip)
-- Oyuncular bu kilitle takip edilir. 'license' onerilir.
Config.PrimaryIdentifier = 'discord'

-- Baglanmak icin sahip olunmasi gereken tanimlayicilar
-- Eger player bu tanimlayicilara sahip degilse reddedilir.
Config.RequiredIdentifiers = {
    'discord',
    -- 'license',
    -- 'steam',
}

-- ============================================================
--  SUNUCU SLOT AYARLARI
-- ============================================================
-- Ayrilmis slotlar (bu oyuncular kuyrugu tamamen atlar)
Config.ReservedSlots = {
    enabled   = false,
    count     = 5,       -- kac slot ayrilmis tutulacak
    -- Asagidaki tanimlayicilardan birine sahip oyuncular kuyrugu atlar
    identifiers = {
        -- 'license:abc123',
        -- 'discord:123456789',
        -- 'steam:110000100000001',
    },
}

-- ============================================================
--  KUYRUK DAVRANISI
-- ============================================================
-- Sunucu basladiktan kac ms sonra oyuncular kabul edilir
Config.JoinDelay = 30000  -- 30 saniye (ms)

-- Connecting listesindeki bir oyuncu kac saniye sonra timeout olur
Config.ConnectTimeout = 300  -- 5 dakika (saniye)

-- Kuyruk pozisyon guncelleme hizi (ms) - kart ve konum guncelleme
Config.QueueUpdateInterval = 3000  -- 3 saniye

-- Hayalet oyuncu ve timeout temizleme araligi (ms)
Config.CleanupInterval = 5000  -- 5 saniye

-- ============================================================
--  ANTI-SPAM (baglanma oncesi bekletme)
-- ============================================================
Config.AntiSpam = {
    enabled = false,
    minTime = 3000,   -- minimum bekleme (ms)
    maxTime = 8000,   -- maksimum bekleme (ms)
}

-- ============================================================
--  DISCORD ENTEGRASYONU
-- ============================================================
Config.Discord = {
    enabled = true,
    -- Discord kontrolü aktif. false yaparsanız sistem kapalı olur.
    
    apiVersion = 10,
    -- Discord API versiyonu. Genelde sabit kalır.
    
    requestsPerMinute = 30,
    -- Dakikada maksimum 30 istek Discord'a gönderilir
    -- (Rate limiting - Discord'un limitini aşmamak için)
    -- Max 50 olabilir, ama 30 güvenli
    
    rejectIfNotInGuild = false,
    -- AÇIK OLUNCA: Oyuncu Discord sunucunuzda değilse REDDEDILIR
    -- KAPAL OLUNCA: Discord sunucunda olmasa bile oyuncu giriş yapabilir
    -- Önerilir: true (kendi sunucunuzdaki oyuncuları filtrele)
    
    rejectIfNoRole = false,
    -- AÇIK OLUNCA: Oyuncu whitelist rolü yoksa REDDEDILIR
    -- KAPAL OLUNCA: Her oyuncu (sunucudaki herkes) girebilir
    -- Önerilir: false (daha esnek bir sistem için)
    
    apiTimeoutMs = 15000,
    -- Discord API'ye istek göndermek için 15 saniye bekle
    -- Eğer 15 saniye içinde cevap gelmezse "fail-open" yapılır
    -- fail-open = oyuncu giriş yapabilir (güvenlik değil, hız için)
}

-- ============================================================
--  WHITELIST (Sadece rollu oyuncular girebilir)
-- ============================================================
Config.Whitelist = {
    enabled = false,    -- true -> allowlistedRoles'ta olmayan oyuncu reddedilir
}

-- ============================================================
--  YENIDEN BAGLANMA ONCELIGI (Reconnect Priority)
-- ============================================================
Config.Reconnect = {
    enabled      = true,
    windowSecs   = 5 * 60,  -- 5 dakika (oyuncu bu sure icinde baglanirsay bonus alir)
    bonusPoints  = 5000,     -- ek puan
}

-- ============================================================
--  GRACE PERIOD (Aktif oyuncu dususten sonra bonus)
-- ============================================================
Config.Grace = {
    enabled      = true,
    windowSecs   = 3 * 60,  -- 3 dakika
    bonusPoints  = 2000,
}

-- ============================================================
--  HOSTNAME KUYRUK SAYACI
-- ============================================================
Config.Hostname = {
    showQueueCount = false,
    -- %d = kuyruk adedi, %s = orijinal hostname
    format = '[Queue: %d] %s',
}

-- ============================================================
--  ADAPTIVE CARD AYARLARI
-- ============================================================
Config.Card = {
    logoUrl     = '',   -- Sunucu logosu (serverName'in ustunde gozukur), bos ise gizlenir
    serverName  = 'Daddy Roleplay',  -- Sunucu adi (kuyruk kartinda gosterilir)
    -- Adaptive Card renkleri: Default, Dark, Light, Accent, Good, Warning, Attention
    serverNameColor = 'Warning',
    subtitle    = 'Sabırla beklediğiniz için teşekkürler!',  -- Kuyruk karti alt basligi
    message     = 'Sıraya girdiniz için teşekkürler! Sunucuya giriş yaptığınızda size haber vereceğiz.',  -- Kuyruk karti mesaji
    buttons     = {
        { label = 'Discord',  url = 'https://discord.com/invite/ddroleplay' },
        { label = 'Web Sitesi',  url = 'https://daddy.com.tr/' },
    },
}

-- ============================================================
--  ADMIN KOMUTU ACE IZNI
-- ============================================================
-- Oyuncu bu ace iznine sahipse admin komutlari kullanabilir
-- RCON / server konsolu daima izinlidir
Config.AdminAce = 'group.admin'
