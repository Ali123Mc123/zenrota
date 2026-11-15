Config = Config or {}

Config.PulseBar = {
    description = "Hareketli parça hedef bölgeyle çakıştığında E'ye bas!",

    segmentSpeed = 45,      -- Speed of moving segments (percentage per second)
    targetZoneSize = 15,    -- Size of target zone (percentage of bar width); right edge is fixed at 90%
    numberOfSegments = 10,  -- Number of moving segments that must all be hit
    minimalMode = false,    -- Hide container background and border
}
