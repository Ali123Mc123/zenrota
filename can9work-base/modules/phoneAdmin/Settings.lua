Settings = Settings or {}

Settings.PhoneAdmin = {
    Command = 'phoneadmin',
    Aliases = { 'teladmin', 'cylexadmin', 'telefonyonetim' },
    RequiredPermission = 'admin', -- 'admin', 'god' or ACE permission

    -- Discord Loglama
    EnableDiscordLog = true,
    DiscordWebhook = 'REDACTED_BEFORE_GITHUB_UPLOAD',

    -- Güvenlik & @everyone Bildirim Ayarları
    PingEveryoneOnSensitiveAction = true, -- Şifre değişimi, hesap silme, numara değişiminde @everyone atar
    LogOnPlayerInspect = true,           -- Bir yetkili birinin profilini/şifrelerini açıp incelediğinde log atar
    PingEveryoneOnInspect = true,         -- Bir yetkili birinin şifrelerini stalkladığında @everyone atar

    -- Desteklenen Sosyal Medya Uygulamaları
    SupportedApps = {
        { name = 'twitter', label = 'Twitter / Frogger', icon = 'brands fa-twitter', color = '#1DA1F2', hasYellow = true },
        { name = 'instagram', label = 'Instagram', icon = 'brands fa-instagram', color = '#E1306C', hasYellow = false },
        { name = 'frogly', label = 'Frogly', icon = 'camera-retro', color = '#20D5EC', hasYellow = false },
        { name = 'foffy', label = 'Foffy', icon = 'fire', color = '#FF5252', hasYellow = false },
    }
}
