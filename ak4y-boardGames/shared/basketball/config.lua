basketballConfig = {}

basketballConfig.Text = {
    TakeBall = "[E] Topu Al",
    ThrowBall = "[E] Topu At",
    Power = "Güç: %d%% [< >]",
    Sway = "Sallanma: %d%%",
    TimeUp = "~r~Süre doldu!~w~ Toplam Skor: %d",
    Hud = "Süre: ~y~%d~w~ | Skor: ~g~%d",
    NotEnoughMoney = "Yeterli paran yok.",
    InUse = "Bu makine şu an kullanımda. Lütfen bekle.",
    Failed = "İşlem başarısız.",
    Play = "Basketbol Oyna"
}

basketballConfig.GameTime = 60
basketballConfig.MachineProp = "ak4y-gc-bbolmachine"

basketballConfig.Machines = {
    {
        coords = vec4(-1440.31, -1029.77, 4.2, 49.17),
        RequiredResource = "AuraStudio-GameYard"
    }
}

if basketballConfig.Machines and FilterRequiredResourceSpawns then
    basketballConfig.Machines = FilterRequiredResourceSpawns(basketballConfig.Machines)
end
