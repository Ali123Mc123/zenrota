-- Closed island: only students, school staff, the free jobs and visitors with a pass may be on Cayo Perico.
-- Anyone else gets a warning, then is put back on the bridge to town. The line follows the island's coast about
-- 80 m out at sea (lagoon included) and crosses the bridge where it reaches the island.
Config.ClosedCampus = {
    Enabled = true,
    -- Polygon (world x, y) and the height band it covers.
    Points = {
        vec2(4120.0, -4205.0), vec2(4015.0, -4455.0), vec2(3770.0, -4615.0), vec2(3760.0, -4750.0),
        vec2(3795.0, -4805.0), vec2(3895.0, -4840.0), vec2(4115.0, -4790.0), vec2(4245.0, -4810.0),
        vec2(4370.0, -4900.0), vec2(4455.0, -5045.0), vec2(4620.0, -5170.0), vec2(4675.0, -5380.0),
        vec2(4575.0, -5680.0), vec2(4670.0, -6025.0), vec2(4740.0, -6095.0), vec2(4820.0, -6110.0),
        vec2(5125.0, -5960.0), vec2(5245.0, -5960.0), vec2(5445.0, -6040.0), vec2(5575.0, -5985.0),
        vec2(5700.0, -5680.0), vec2(5710.0, -5205.0), vec2(5655.0, -5115.0), vec2(5430.0, -4980.0),
        vec2(5400.0, -4860.0), vec2(5305.0, -4575.0), vec2(5110.0, -4390.0), vec2(5040.0, -4160.0),
        vec2(4925.0, -4110.0), vec2(4430.0, -4090.0),
    },
    MinZ = -60.0,                  -- divers under the island count as inside
    MaxZ = 600.0,                  -- aircraft over the island too
    Gate = vec4(4600.0, -4125.0, 3.4, 196.0),  -- the island end of the bridge
    Drop = vec4(4590.0, -4040.0, 7.8, 16.0),   -- on the bridge outside the line, facing town
    -- The bridge end just inside the line: someone waiting here for a pass is left alone.
    Reception = { Coords = vec3(4601.0, -4135.0, 3.0), Radius = 15.0 },

    CheckMs = 2000,
    WarnSeconds = 10,
    FadeMs = 600,

    Pass = {
        Minutes = 60,              -- default length
        MaxMinutes = 240,
        WarnMinutes = 5,           -- a notice this long before it runs out
        IssueRadius = 40.0,        -- the issuer stands this close to the gate (0: anywhere)
        TargetDistance = 4.0,
        -- Who hands passes out: teachers (with the principal), school security, and extra job names.
        Issuers = { Teachers = true, Security = true, Jobs = {} },
    },

    -- Never stopped: police and EMS (qbx job names).
    FreeJobs = { 'police', 'sasp', 'bcso', 'pbsd', 'cppd', 'sapr', 'ambulance' },
    -- Riding in one of these models is never stopped (school buses); stepping out is.
    SchoolVehicles = {},

    -- Sunucu adminleri sınırdan muaf mı. true: adminler kampüsten atılmaz; false: öğrenci/personel/serbest meslek değilse onlar da atılır.
    AdminsFree = true,

    Commands = { pass = 'visitorpass', test = 'campustest' },
    -- Test: citizen ids (comma separated) treated as outsiders even when they are staff or admins.
    TestConvar = 'daddy_college:outsider_test',
}
