-- Other Daddy Studio products College works with. Each is found by itself when it runs; Enabled = false ignores it.
-- Any product's access rules can also name College roles: role:college:student, teacher, principal, security,
-- staff, member or president (LiveBoard boards for teachers, Art Studio canvases for students...).
Config.Integrations = {
    -- daddy_election: the school president is elected. Elections for this office let only students vote and
    -- run (students with CandidateBlockCount sanctions cannot run) and the winner becomes school president.
    -- The office is created in Election once; the principal can run elections from the tablet.
    Election = { Enabled = true, Office = 'school_president', TermDays = 30 },
    -- daddy_dorms: the Dorms app on the staff tablet (applications, rooms, leases, moving boxes, log).
    Dorms = { Enabled = false }, -- DaddyRP: KAPALI (daddy_dorms [disabled]'da)
    -- Star Skill Tree locks in other RP scripts. Only enrolled students need the skill; everyone else is never
    -- stopped, and server admins never are. A locked student is told the lessons and levels that open it.
    -- A lock is a skill key ('skill:karate') or a level rule ({ lesson = 'dans', level = 6 }, { all = { ... } }).
    -- Remove a line to drop that lock. Status: [daddy]/docs/skilltree-baglanti.md.
    Skills = {
        Enabled = true,
        -- Usable items (BDX-Sport-Hub server/framework-bridge.lua asks before the item runs).
        Items = {
            skateboard = 'skill:skate_bike', -- PE 3
            bmx = 'skill:skate_bike',        -- PE 3
        },
        -- wais-speaker: bir öğrenci boombox'u ancak bu elle verilen sertifikayla kurar (bridge/editable/server.lua sorar).
        -- Öğretmen/müdür /<Command> [oyuncu id] ile verir ya da geri alır; tabletten de geri alınabilir.
        Boombox = { Certificate = 'boombox_permit', Command = 'bbizin', OnlyAtSchool = true }, -- OnlyAtSchool: izin sadece okul içinde aranır
        -- prp-scenes spray can (nil = open; Art 3 makes spray cans at the workshop bench instead).
        Spray = nil,
        -- can9work-base stage microphones by stage id (none for now).
        StageMics = {},
        -- BDX-Fighting styles: 1 Dojo (Karate), 2 Boxing, 3 MMA.
        Fighting = {
            [1] = 'skill:karate',          -- PE 6 + Dance 6
            [2] = 'skill:advanced_combat', -- PE 10
            [3] = 'skill:advanced_combat', -- PE 10
        },
        -- krypton-farming: a student who has one picks the difficulty without the mastery runs (none for now).
        Farming = {},
        -- wais-hunting: a student needs this College certificate to get the rifle, animal parts or pay
        -- (config_sv.lua AddItem / AddMoney ask). It comes by itself at Policing 3 + Biology 3.
        Hunting = { Certificate = 'hunting_license' },
        -- krypton-farming: the certificate a student needs to start a field or a livestock job (every group member).
        FarmCertificates = { farm = 'farmer', livestock = 'farm_work' }, -- Biology 3 / Culinary 3 + Biology 3
        -- bostra_poledance: the certificate a student needs to dance on a pole.
        PoleDance = 'venue_dancer', -- Dance 10
        -- qbx_ambulancejob: a student with this treats wounds with a bandage like EMS ([E] on a player).
        WoundCare = 'skill:ems_intern', -- Health 10 + Biology 10
        WoundCareCommand = 'yarasar',    -- the command that treats the nearest player (no target menu)
        -- can9work-jobsv2 recipe id -> lock (empty = none; Culinary lives at the school kitchen bench).
        Recipes = {},
    },
}
