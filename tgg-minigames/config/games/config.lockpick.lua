Config = Config or {}

Config.Lockpick = {
    description = "Yavaşça çevirip kilidin titremesini hissederek doğru noktayı bul!",

    slowMovementThreshold = 7, -- Max speed for slow movement detection (sections/second)
    sections = 36,             -- Number of discrete positions around the circle
    lightShakeTolerance = 6,   -- Distance for light shake (±sections from target)
    successZoneTolerance = 2,  -- Distance for success and intense shake (±sections)
}
