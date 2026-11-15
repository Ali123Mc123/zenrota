-- College ID cards: collected at Student Affairs for the holder's role, shown to the people around when used.
-- Collecting again refreshes the card with today's class, club and scholarship.
Config.StudentCard = {
    Cards = {
        student = { item = 'student_card' },
        teacher = { item = 'teacher_card' },
        principal = { item = 'principal_card' },
        security = { item = 'security_card' },
    },
    DurationMs = 10000,
    Radius = 3.0,          -- players this close see the card
    CooldownMs = 5000,
    PhotoMaxBytes = 512000, -- the photo is taken with MugShotBase64 when it runs
    -- Languages on the student card from lesson levels; the highest step reached per lesson shows, named by the locale
    -- studentcard.language_<key>. e.g. { lesson = 'german', level = 3, key = 'german' }, { lesson = 'german', level = 10, key = 'german_fluent' }
    Languages = {},

    -- The card in hand while it is shown.
    Presentation = {
        Enabled = true,
        FreezePlayer = false,
        Animation = { Dict = 'paper_1_rcm_alt1-9', Name = 'player_one_dual-9', Flag = 50 },
        Props = { { Model = 'prop_cs_r_business_card', Bone = 57005, Offset = vec3(0.10, 0.02, -0.03), Rotation = vec3(-90.0, 170.0, 79.0) } },
    },
}

-- DaddyRP: German on the card from Almanca 3, fluent from 10.
Config.StudentCard.Languages = {
    { lesson = 'almanca', level = 3, key = 'german' },
    { lesson = 'almanca', level = 10, key = 'german_fluent' },
}
