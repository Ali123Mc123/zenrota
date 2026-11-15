--[[
    daddy-queue - lang.lua
    Oyunculara gosterilen mesajlar. Kendi dilinize gore duzenleyin.
]]

Lang = {
    -- Baglanti baslarken ilk mesaj
    initializing         = 'Bağlantın başlatılıyor, lütfen bekle...',

    -- Tanimlayicilar kontrol edilirken
    checkingIdentifiers  = 'Kimlik bilgilerin kontrol ediliyor...',

    -- Discord kontrol edilirken
    checkingDiscord      = 'Discord bilgilerin doğrulanıyor...',

    -- Tanimlayici bulunamadi
    noIdentifiers        = 'Kimlik bilgilerin alınamadı. Lütfen tekrar dene.',

    -- Belirli bir tanimlayici eksik
    -- %s = eksik tanimlayici adi (license, discord vs.)
    missingIdentifier    = "'%s' kimlik bilgisi bulunamadı.",

    -- Discord ID'si yok (Discord bagli degil)
    noDiscordIdentifier  = 'FiveM hesabına bağlı bir Discord yok. Discord hesabını bağlayıp tekrar dene.',

    -- Discord sunucusunda degil
    notInGuild           = 'Discord sunucumuza katılmadan bağlanamazsın. Sunucumuza katılıp tekrar dene.',

    -- Whitelisted rol yok
    notWhitelisted       = 'Bu sunucuya girmek için gereken Discord rolüne sahip değilsin.',

    -- Zaten connecting listesinde
    alreadyConnecting    = 'Zaten bağlanıyorsun. Birkaç saniye bekleyip tekrar dene.',

    -- Kuyrukta pos/toplam
    -- %d = konum, %d = toplam kuyruk
    inQueue              = 'Sıraya alındın. Sıran: %d / %d',

    -- Kuyruk bittikten sonra katilma
    joiningNow           = 'Sunucuya katılıyorsun, bekle...',

    -- Zaman asimi
    timedOut             = 'Bağlantı süresi doldu. Lütfen tekrar dene.',

    -- Baglanti hatasiyla dusuruldu
    connectionFailed     = 'Bağlantı kurulamadı.',
}
