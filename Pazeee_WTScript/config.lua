Config = {}

Config.Debug = false


Config.Animations = {
    {
        label = "Telsiz A (Sağ Ön)",
        dict = "pazeee@radioa@animations",
        anim = "pazeee@radioa@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 57005,
        coords = { 0.160, 0.060, -0.010, -119.52, -157.824, 46.041 }
    },
    {
        label = "Telsiz B (Sol Ön)",
        dict = "pazeee@radiob@animations",
        anim = "pazeee@radiob@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 18905,
        coords = { 0.141, 0.066, 0.0110, -120.8, -33.752, -32.259 }
    },
    {
        label = "Telsiz C (Sağ Yan)",
        dict = "pazeee@radioc@animations",
        anim = "pazeee@radioc@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 57005,
        coords = { 0.160, 0.060, 0.0, -119.52, -157.824, 46.041 }
    },
    {
        label = "Telsiz D (Sol Yan)",
        dict = "pazeee@radiod@animations",
        anim = "pazeee@radiod@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 18905,
        coords = { 0.154, 0.067, 0.010, -120.8, -33.752, -32.259 }
    },
    {
        label = "Telsiz E (Sağ Kalkan)",
        dict = "pazeee@radioe@animations",
        anim = "pazeee@radioe@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 57005,
        coords = { 0.160, 0.060, 0.0, -119.52, -157.824, 46.041 }
    },
    {
        label = "Telsiz F (Sol Kalkan)",
        dict = "pazeee@radiof@animations",
        anim = "pazeee@radiof@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 18905,
        coords = { 0.154, 0.067, 0.010, -120.8, -33.752, -32.259 }
    },
    {
        label = "Telsiz G (Sağ Omuz)",
        dict = "pazeee@radiog@animations",
        anim = "pazeee@radiog@clip",
        flag = 49,
        prop = "none",
        bone = 0,
        coords = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
    },
    {
        label = "Telsiz H (Sol Omuz)",
        dict = "pazeee@radioh@animations",
        anim = "pazeee@radioh@clip",
        flag = 49,
        prop = "none",
        bone = 0,
        coords = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
    },
    {
        label = "Telsiz I (Kötü Sinyal)",
        dict = "pazeee@radioi@animations",
        anim = "pazeee@radioi@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 57005,
        coords = { 0.160, 0.060, 0.0, -119.52, -157.824, 46.041 }
    },
    {
        label = "Telsiz J (Bozuk)",
        dict = "pazeee@radioj@animations",
        anim = "pazeee@radioj@clip",
        flag = 49,
        prop = "prop_cs_hand_radio",
        bone = 57005,
        coords = { 0.160, 0.060, 0.0, -119.52, -157.824, 46.041 }
    },
}

function dPrint(...)
    if Config.Debug then
        print("[RadioAnimSelector]", ...)
    end
end