BungeeConfig = ActivitySettings.resolve('bungee', {
    debug = false, -- true: logs for this activity only.
    enabled = true,
    npc = {
        model = 'a_m_y_hiker_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        interactionRadius = 2.5,
        blip = {
            enabled = false,
            name = ActivityLocale.bungee_jumping(),
            sprite = 771,
            colour = 47,
            scale = 0.8,
        },
    },
    locations = { -- Bungee locations; add entries exported by /bungeenew.
        {
            npc = vector4(-68.7937, -801.7041, 44.2273, 340.4685), -- NPC position and heading.
            exit = vector4(-68.7937, -801.7041, 44.2273, 340.4685), -- Return position after the activity.
            platform = vector4(-69.8253, -803.9175, 321.0740, 154.0875), -- Platform position and heading.
            platformModel = '0r_prop_crane_platform',
            maxFallRange = 48.7125, -- Maximum fall distance below the platform.
        },
        {
            npc = vector4(781.4182, 1274.6881, 361.2848, 2.3205),
            exit = vector4(781.4182, 1274.6881, 361.2848, 2.3205),
            platform = vector4(758.3937, 1268.8217, 444.2465, 359.0740),
            platformModel = '0r_prop_crane_platform_long',
            maxFallRange = 48.7125,
        },
        {
            npc = vector4(501.7137, 5603.7544, 797.9095, 168.7414),
            exit = vector4(501.7137, 5603.7544, 797.9095, 168.7414),
            platform = vector4(415.4017, 5712.3198, 700.8267, 240.0043),
            platformModel = '0r_prop_crane_platform_long',
            maxFallRange = 48.7125,
        },
    },
})
