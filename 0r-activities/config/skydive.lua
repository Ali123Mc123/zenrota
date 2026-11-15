SkyDiveConfig = ActivitySettings.resolve('skydive', {
    debug = false, -- true: logs for this activity only.
    enabled = false, -- DaddyRP: iskeledeki sorun cozulene kadar kapali (cok ticket). false disables the activity and prevents NPCs and blips from spawning.
    gameplay = {
        maxPlayers = 5,
        flightSeconds = 43, -- Flight time before jumping, in seconds.
        landingSeconds = 180, -- Time allowed to reach the landing area, in seconds.
        resultsSeconds = 15,
        maxLandingDistance = 5000.0,
    },
    npc = {
        model = 's_m_y_pilot_01',
        interactionRadius = 3.0,
    },
    blip = {
        enabled = false, -- false hides the map blip.
        sprite = 94,
        colour = 3,
        scale = 0.80,
        name = ActivityLocale.a_parachute_jump(),
    },
    parachute = {
        tint = 0, -- Parachute canopy colour index.
        showBackpackInAircraft = true, -- false: no parachute backpack on the player in the aircraft.
        backpackComponent = 5, -- Clothing slot for the backpack (5 = bag / parachute).
        backpackDrawable = 1, -- Backpack model number in that slot.
        backpackTexture = 0, -- Backpack colour / texture variant.
    },
    atmosphere = {
        timecycle = 'MP_corona_tournament',
        timecycleStrength = 0.35,
        windSpeed = 8.0,
    },
    worldTarget = {
        markerType = 1,
        checkpointRadius = 55.0,
        checkpointHeight = 140.0,
        colour = {
            r = 35,
            g = 210,
            b = 255,
            a = 180,
        },
    },
    landingMarker = {
        blip = {
            sprite = 38,
            colour = 3,
            scale = 0.90,
            route = true,
            name = ActivityLocale.parachute_landing_area(),
        },
    },
    clouds = {
        enabled = true,
        opacity = 225,
    },
    entryPoints = { -- NPC positions and headings.
        vector4(-1844.7808, -1314.6636, 2.0674, 42.8466),
        -- vector4(-1037.8065, -2737.7478, 19.1693, 338.9654),
    },
    locations = { -- Landing target positions.
        -- vector3(925.3853, -3183.5308, 5.9008), -- liman: atlama alanina 5476 m, 5000 m sinirini asiyordu
        -- vector3(1489.5513, -2345.7639, 73.0959), -- atlama alanina 4527 m, paraşütle ulaşılamıyordu
        vector3(1063.7164, 3078.6897, 41.1630), -- atlama alanina ~1.7 km (scriptin varsayilani)
        -- vector3(-1793.8777, -761.0137, 9.0336),
    },
})
