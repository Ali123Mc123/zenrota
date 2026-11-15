-- "Why did it not work": the health scan (admins), a player's own view and the list of caught errors.
-- Errors are stored by daddy_lib under a short code; its config_sv.lua holds the Discord webhook and the test mode.
Config.Health = {
    -- DaddyRP: Turkish command names.
    Commands = {
        check = 'kolejkontrol', -- admins: resources, database, items, placed things, staff grades, settings
        me = 'kolejben',        -- anyone: role, record, class and what each device needs ([id] for admins)
        faults = 'kolejhata',   -- admins: the latest errors; [code] shows one, [count] more
    },

    -- Resources that should be started ({ name, need = false }: only a note when it is not).
    Resources = {
        'oxmysql', 'ox_lib', 'ox_inventory', 'ox_target', 'daddy_lib', 'daddy_college', 'daddy_onboarding', 'daddy_studentpad', 'daddy_studentphone',
        'daddy_campuslife', 'daddy_campusgames', 'daddy_lockers', 'daddy_liveboard', 'daddy_elevator', 'daddy_college_props', 'daddy_schoolprops',
        { 'daddy_transit', need = false }, { 'daddy_artstudio', need = false }, { 'daddy_arcadepad', need = false }, { 'daddy_election', need = false },
    },

    -- Inventory items whose export belongs to a resource matching this must have a handler and a picture.
    ItemResources = '^daddy[_-]',

    -- Placed things: rows of `kind` (active) in `table`, at least `min` (1). key names the line (locales health.world).
    World = {
        { key = 'affairs_desk', table = 'daddycl_world_entities', kind = 'affairs_desk' },
        { key = 'campus', table = 'daddycl_world_zones', kind = 'campus' },
        { key = 'classroom', table = 'daddycl_world_zones', kind = 'classroom' },
        { key = 'cardpay_atm', table = 'daddycl_world_entities', kind = 'cardpay_atm', need = false },
        { key = 'wish_tree', table = 'daddycl_world_entities', kind = 'wish_tree', need = false },
        { key = 'canteen', table = 'daddy_campus_world_entities', kind = 'canteen' },
        { key = 'vending', table = 'daddy_campus_world_entities', kind = 'vending_machine', min = 2 },
        { key = 'shop', table = 'daddy_campus_world_entities', kind = 'shop' },
        { key = 'nurse', table = 'daddy_campus_world_entities', kind = 'nurse', need = false },
        { key = 'boards', table = 'daddy_lb_boards' },
        { key = 'lockers', table = 'daddy_lockers_world_entities', kind = 'locker' },
        { key = 'bottle', table = 'daddy_games_world_entities', kind = 'bottle_ring' },
        { key = 'darts', table = 'daddy_games_world_entities', kind = 'dart_board', need = false },
        { key = 'taboo', table = 'daddy_games_world_entities', kind = 'taboo_table', need = false },
        { key = 'whoami', table = 'daddy_games_world_entities', kind = 'whoami_ring', need = false },
        { key = 'potato', table = 'daddy_games_world_entities', kind = 'potato_ring', need = false },
        { key = 'chairs', table = 'daddy_games_world_entities', kind = 'chairs_ring', need = false },
        { key = 'transit', table = 'daddy_transit_world_entities', kind = 'transit_stop', need = false },
    },

    -- One-time database steps: the query's first value must be `expect` (0), or at least `min`.
    -- DaddyRP: the steps of kolej-canli-2026-11-09.sql.
    Sql = {
        { key = 'class_sync', query = "SELECT COUNT(*) FROM daddy_onboarding_characters o JOIN daddycl_students s ON s.citizenid = o.citizenid WHERE o.role = 'student' AND o.quiz = 'done' AND o.class_name IS NOT NULL AND s.active = 1 AND s.class_name IS NULL" },
        { key = 'old_exams', query = "SELECT COUNT(*) FROM daddycl_exam_definitions WHERE title IN ('dddd', 'aaaaaa', 'aaaaaabbbb', 'aaaawdwadaw') OR course = 'Rehberlik ve Psikoloji'" },
        { key = 'teacher_grades', query = "SELECT COUNT(*) FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = 'ogretmen' AND CAST(JSON_EXTRACT(job, '$.grade.level') AS UNSIGNED) > 13" },
        { key = 'council', min = 1, query = "SELECT COUNT(*) FROM daddycl_council_members WHERE rank_key = 'president'" },
        { key = 'boards', query = "SELECT COUNT(*) FROM daddy_lb_boards WHERE JSON_SEARCH(access, 'one', 'student', NULL, '$.draw[*].name') IS NULL" },
        { key = 'bottle_deck', min = 1, query = "SELECT COUNT(*) FROM daddy_games_world_entities WHERE uid = 'bottle_ring_2369agrt' AND JSON_UNQUOTE(JSON_EXTRACT(settings, '$.deck')) = 'truth_dare'" },
        { key = 'canteen_items', min = 7, query = "SELECT COUNT(*) FROM daddy_campus_canteen_items WHERE canteen_uid = 'canteen_1'" },
        { key = 'vending', min = 2, query = "SELECT COUNT(*) FROM daddy_campus_world_entities WHERE uid IN ('vending_snack_1', 'vending_drink_1')" },
    },

    -- What a player uses, for the own view: who = 'staff' | 'member' (students and staff) | 'student' | 'anyone'.
    Devices = {
        { item = 'school_tablet', who = 'staff' },
        { item = 'student_tablet', who = 'member' },
        { item = 'student_phone', who = 'anyone' },
        { item = 'school_notebook', who = 'anyone' },
        { item = 'exit_permit', who = 'student' },
    },
}
