boxMachineConfig = {}

boxMachineConfig.Text = {
    TimeUp = "Süre doldu. İşlem iptal edildi.",
    NotEnoughMoney = "Yeterli paran yok.",
    InUse = "Bu makine şu an kullanımda. Lütfen bekle.",
    Play = "Boks Makinesi Oyna"
}

boxMachineConfig.MachineProp = "aura-gc-boxing"
boxMachineConfig.BagProp = "aura-gc-box-bag"

boxMachineConfig.Machines = {
    {
        coords = vec4(-1442.41, -1032.25, 4.19, 49.27),
        RequiredResource = "AuraStudio-GameYard" 
    }
}

if boxMachineConfig.Machines and FilterRequiredResourceSpawns then
    boxMachineConfig.Machines = FilterRequiredResourceSpawns(boxMachineConfig.Machines)
end
