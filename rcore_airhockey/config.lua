Config = {
    -- send paddle position to your opponent every 33ms (30x/s)
    -- lower the value for faster sync sync between paddles
    PositionSendRate = 33,
    -- maximum time the puck can stay on one side in ms
    PenaltyTime = 10000,
    -- block these while playing
    RestrictedControls = {37, 157, 159, 160, 161, 162, 163, 164, 165, 158, 101, 337, 53, 54, 47, 140, 141, 263, 264,
                          142, 143, 24, 257, 44, 282, 283, 284, 285, 69, 70, 114, 99, 100, 102, 22, 74, 68, 25, 36, 345,
                          346, 347, 91, 92},
    BounceStrength = 0.05, -- camera bounce effect
    DrawTableScore = true, -- draw actual match score for viewers on top tables
    Framework = 2, -- 0: Standalone (no bets), 1: ESX, 2: QBCore
    EnableBets = true,
    MinBet = 1000,
    MaxBet = 10000,
    BetType = 2, -- 1: Choose the lower stake for both (P1 choose 1k, P2 choose 2k, stake will be 1k for both), 2: both can set their own stakes
    WinMultiplier = 2, -- winner gets 2x the stake
    SpawnDistance = 30.0,
    UIFontID = 0, -- fontId (used in menus)
    UIFontName = nil, -- name of the font (used in scaleforms and notifications)
    NotifySystem = 5, -- 1: native notify, 2: okokNotify, 3: esx_notify, 4: qb_notify, 5: ox_notify
    -- Enable rcore_stats? (https://store.rcore.cz/package/6273968)
    Rcore_Stats = GetResourceState("rcore_stats") ~= "missing"
}

Objects = {}

-- daddy-games dinamik masa senkronizasyonu
CreateThread(function()
    Wait(1500)
    pcall(function()
        local gamesExport = exports['daddy-games'] or exports['rcore_gameprops']
        if gamesExport and gamesExport.GetTablesByType then
            local extra = gamesExport:GetTablesByType('airhockey')
            if extra and #extra > 0 then
                for _, t in ipairs(extra) do
                    local exists = false
                    for _, obj in ipairs(Objects) do
                        if #(obj.pos - t.pos) < 1.0 then exists = true break end
                    end
                    if not exists then
                        Objects[#Objects + 1] = { pos = t.pos, heading = t.heading }
                    end
                end
            end
        end
    end)
end)

Translation = {
    MATCH_SETTINGS = "Maç Ayarları",
    SLOW = "Yavaş",
    MEDIUM = "Orta",
    FAST = "Hızlı",
    PUCK_SPEED = "Disk Hızı",
    PUCK_SPEED_DESC = "Diskin ulaşabileceği maksimum hız.",
    MAX_SCORE = "Maksimum Skor",
    MAX_SCORE_DESC = "Bir oyuncu bu gol sayısına ulaştığında maç sona erer.",
    START = "Başlat",
    START_DESC = "Kuralları kaydetmek ve maçı başlatmak için basın.",
    LATENCY_HIGH = "Gecikmen (%s) çok yüksek görünüyor. Oynanışın pek iyi olmayabilir.",
    LATENCY_NORMAL = "Gecikmen: %s",
    END_WINNER = "kazanan.",
    END_LOSER = "kaybeden.",
    END_STATS_SAVES = "%s kurtarış",
    END_STATS_SHOTS = "%s kaleye şut",
    END_STATS_GOALS = "%s gol",
    END_STATS_PLAYER = "%s m oyuncu hareketi",
    END_STATS_PUCK = "%s m disk hareketi",
    END_STATS_TITLE = "Hava Hokeyi",
    TIMERBAR_PENALTY = "CEZA",
    WAITING_FOR_OP = "Rakip bekleniyor.",
    TABLE_USED = "Bu Hava Hokeyi masası başka biri tarafından kullanılıyor.",
    NOT_CLOSE_ENOGUH = "Yeterince yakın değilsin. Biraz uzaklaşıp tekrar dene.",
    NOT_ENOUGH_PLAYERS = "Hava Hokeyi başlatmak için bir oyuncunun daha masaya yaklaşması gerekiyor.",
    WAITING_FOR_OP_TO_JOIN = "Rakibinin maça katılması bekleniyor.",
    PRESS_TO_PLAY = "Hava Hokeyi oynamak için [E] tuşuna bas.",
    MATCH_CANCELLED = "Maç İptal Edildi",
    MATCH_CANCELLED_DESC = "Oyunculardan biri bağlantıyı kesti veya maçı iptal etti.",
    STARTING = "Oyuncular bekleniyor...",
    WAITING_FOR_HOST = "%s kuralları değiştiriyor",
    PRESS_TO_CONFIRM_BET = "Kazanacağına %s bahis koymayı onaylamak için Enter'a bas",
    READY = "Hazır",
    READY_DESC = "Oynamaya hazırsan Enter'a bas.",
    WAITING_FOR_OP_READY = "Lütfen rakibinin hazır olduğunu onaylamasını bekle.",
    BETTINGS_CAPT = "Bahisler",
    BETTINGS_INFOPANEL = "BAHİS: %s",
    BETTING_ACC = "Hesap",
    BETTING_STAKE = "Bahis Miktarı",
    BETTINGS_USE_ACC_DESC = "Bahis ödemesi için '%s' hesabını kullan. Maks: %s",
    -- Update 1.1.0
    PADDLE_SKIN = "Vurucu Görünümü",
    PADDLE_SKIN_DESC = "Vurucunun görünümünü seç.",
    PUCK_SKIN = "Disk Görünümü",
    PUCK_SKIN_DESC = "Diskin görünümünü seç.",
    COLOR_BLUE = "Mavi",
    COLOR_GREEN = "Yeşil",
    COLOR_RED = "Kırmızı",
    COLOR_ORANGE = "Turuncu",
    COLOR_GRAY = "Gri",
    COLOR_PURPLE = "Mor",
    COLOR_PINK = "Pembe",
    COLOR_BLACK = "Siyah",
    
    Get = function(key)
        return Translation[key] or "Eksik Çeviri: " .. key
    end
}