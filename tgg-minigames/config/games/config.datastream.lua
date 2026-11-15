Config = Config or {}

Config.DataStream = {
    description = "Güvenli iletişimi kırmak için ağ veri paketlerini yakala ve şifresini çöz!",
    numberOfStages = 3,    -- Total stages to complete
    instantFail = false,   -- Fail on wrong answer

    packetSpeed = 0.8,     -- Speed of moving packets
    targetPacketCount = 3, -- Packets to intercept per stage
    timeLimit = 75,        -- Time per stage in seconds
    penaltySeconds = 3,    -- Time penalty for wrong answer
}
