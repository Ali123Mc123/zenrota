Settings = Settings or {}

Settings.LicenseTransfer = {
    Command = 'hesapaktar',
    Aliases = { 'licensetransfer', 'rockstaraktar' },
    RequiredPermission = 'admin', -- qbx_core permission or group.admin ace

    -- Discord Loglama (Aktarım yapıldığında detaylı log gönderilir)
    EnableDiscordLog = true,
    DiscordWebhook = 'REDACTED_BEFORE_GITHUB_UPLOAD',
}
