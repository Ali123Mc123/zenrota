RacePreviewConfig = ActivitySettings.resolve('race_preview', {
    -- Live preview shown while a race lobby is open: one car per player drives the real track.
    -- The screen stays black for settleMilliseconds while the cars are created and get up to speed.
    enabled = true,
    debug = false, -- true: preview camera key logs only.
    settleMilliseconds = 1500,
    -- Per race: startFraction = where on the lap the lead car starts (0..1), gap = metres between cars,
    -- maxSpeed in m/s, cornerGrip = how fast the cars take corners, acceleration / braking in m/s².
    races = {
        formula1 = { startFraction = 0.35, gap = 26.0, maxSpeed = 55.0, cornerGrip = 22.0, acceleration = 9.0, braking = 16.0 },
        skart_race = { startFraction = 0.35, gap = 20.0, maxSpeed = 40.0, cornerGrip = 15.0, acceleration = 7.0, braking = 12.0 },
        gokart = { startFraction = 0.35, gap = 14.0, maxSpeed = 31.2, cornerGrip = 18.6, acceleration = 6.5, braking = 11.7 },
    },
})
