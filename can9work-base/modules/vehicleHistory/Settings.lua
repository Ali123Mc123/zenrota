Settings = Settings or {}

Settings.VehicleHistory = {
    Command = 'aracgecmis',
    Aliases = { 'gecmiskontrol', 'vehhistory', 'araclog' },
    RequiredPermission = 'admin', -- qbx_core permission or group.admin ace
    MaxOrders = 30, -- Listelenecek maksimum geçmiş sipariş sayısı

    -- Discord Loglama (Araç sorgulama, tuning takip ve parça geri yükleme işlemleri loglanır)
    EnableDiscordLog = true,
    DiscordWebhook = 'REDACTED_BEFORE_GITHUB_UPLOAD',
}
