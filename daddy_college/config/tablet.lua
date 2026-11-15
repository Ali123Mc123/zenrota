-- Staff tablet for teachers, security and the principal.
Config.Tablet = {
    Item = 'school_tablet',   -- using this item opens the tablet; '' for no item
    OtherItems = { 'teacher_tablet' }, -- older item names that open it too (DaddyRP: the first version's tablet)
    RequireItem = false,      -- the command also needs the item
    Command = 'schooltablet', -- '' for no command
    FreezePlayer = false,     -- keep the player still while the tablet is open
    Prop = { model = 'prop_cs_tablet', bone = 28422, pos = vec3(0.03, 0.002, -0.02), rot = vec3(10.0, 160.0, 0.0) }, -- false for no prop
    Anim = { dict = 'amb@world_human_seat_wall_tablet@female@base', clip = 'base' },

    SessionTimeoutMs = 90000,
    HeartbeatMs = 30000,
    PageSize = 25,
    MaxPageSize = 50,
    NearbyRadius = 10.0,      -- used both to list nearby players and to check them when saving

    DoorResource = 'ox_doorlock', -- security zones lock these doors

    -- CCTV camera viewer and editor.
    Cctv = { MinFov = 20.0, MaxFov = 90.0, FovStep = 1.0, MoveSpeed = 0.35, LookSpeed = 3.0 },

    -- role: teacher (all staff), security (all staff) or admin (principal). module or resource hides the app when it is not running;
    -- integration apps show only while that product (Config.Integrations) is running.
    Apps = {
        { id = 'student', role = 'teacher', icon = 'fa-solid fa-address-card' },
        { id = 'classrooms', role = 'teacher', icon = 'fa-solid fa-graduation-cap' },
        { id = 'clubs', role = 'teacher', icon = 'fa-solid fa-people-group' },
        { id = 'lesson', module = 'classpoints', role = 'teacher', icon = 'fa-solid fa-chalkboard-user' },
        { id = 'schedule', module = 'classpoints', role = 'teacher', icon = 'fa-solid fa-calendar-week' },
        { id = 'exam', module = 'exam', role = 'teacher', icon = 'fa-solid fa-file-pen' },
        { id = 'discipline', module = 'discipline', role = 'teacher', icon = 'fa-solid fa-gavel' },
        { id = 'campus', module = 'wishes', role = 'teacher', icon = 'fa-solid fa-seedling' },
        { id = 'security', module = 'security', role = 'security', icon = 'fa-solid fa-shield-halved' },
        { id = 'trips', module = 'security', role = 'teacher', icon = 'fa-solid fa-bus' },
        { id = 'press', module = 'press', role = 'teacher', icon = 'fa-solid fa-newspaper' },
        { id = 'principal', role = 'admin', icon = 'fa-solid fa-user-tie' },
        { id = 'announce', role = 'admin', icon = 'fa-solid fa-bullhorn' },
        { id = 'election', integration = 'Election', role = 'admin', icon = 'fa-solid fa-check-to-slot' },
    },
}
