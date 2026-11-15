Config = {}

Config.Locale = 'en' -- en | tr

-- The tablet item; without an inventory or with RequireItem false, the command opens it.
Config.Item = 'student_tablet'
Config.RequireItem = true
Config.Command = '' -- e.g. 'studentpad'; empty adds no command

Config.Session = { TimeoutMs = 90000, HeartbeatMs = 30000 }

-- Courses teachers write in the tablet; a passed quiz gives its lesson College's study XP once (Xp.StudyPerUnit).
Config.Curriculum = {
    MaxUnitsPerLesson = 60,
    MaxTopicsPerUnit = 80,
    MaxTitleLength = 160,
    MaxSummaryLength = 600,
    MaxTopicBodyBytes = 24000,
    QuizPassPct = 70,
    MaxNotes = 60,
}

-- The home screen. role: 'student' (students only), 'school' (students and staff) or 'council' (the student council and
-- teachers).
-- needs: the product the app reads from; without it the app is not shown. icon names the glyph, tint its colour.
Config.Apps = {
    { id = 'schedule', role = 'school', needs = 'college', icon = 'calendar', tint = 'red', dock = true },
    { id = 'courses', role = 'school', needs = 'college', icon = 'book', tint = 'blue', dock = true },
    { id = 'grades', role = 'student', needs = 'college', icon = 'chart', tint = 'green', dock = true },
    { id = 'attendance', role = 'student', needs = 'college', icon = 'check-list', tint = 'teal' },
    { id = 'leaderboard', role = 'school', needs = 'college', icon = 'trophy', tint = 'yellow' },
    { id = 'announcements', role = 'school', needs = 'college', icon = 'megaphone', tint = 'orange', dock = true },
    { id = 'wallet', role = 'school', needs = 'college', icon = 'card', tint = 'indigo', dock = true },
    { id = 'affairs', role = 'school', needs = 'college', icon = 'landmark', tint = 'orange' },
    { id = 'clubs', role = 'student', needs = 'college', icon = 'people', tint = 'purple' },
    { id = 'council', role = 'council', needs = 'college', icon = 'gavel', tint = 'indigo' },
    { id = 'locker', role = 'school', needs = 'lockers', icon = 'lock', tint = 'gray' },
    { id = 'arcade', role = 'school', needs = 'arcade', icon = 'dice', tint = 'pink' },
    { id = 'notebook', role = 'school', icon = 'notebook', tint = 'pink' },
    { id = 'settings', role = 'school', icon = 'gear', tint = 'gray' },
}

-- Widgets in order: '<app>.<widget>' or the shell's 'clock'. One whose app is hidden for the player is skipped.
Config.Widgets = {
    home = { 'schedule.today', 'clock', 'leaderboard.rank' }, -- 4 columns: small takes 1, medium 2
    lock = { 'schedule.next', 'affairs.permit', 'announcements.urgent' }, -- the lock screen's left column
}

-- Money in the wallet and the locker app: the symbol, and after = true for "1.240 ₺" style.
Config.Currency = { symbol = '$', after = false }

Config.Theme = {
    accent = '#D43D45', accentHover = '#C2353D', accentActive = '#A92D35',
    accentSubtle = 'rgba(212, 61, 69, 0.15)', accentMuted = 'rgba(212, 61, 69, 0.08)',
    accentRing = 'rgba(212, 61, 69, 0.35)', accentText = '#F08A8F',
}

-- Server settings (overrides/daddy_studentpad/config.lua)
-- The server's language.
Config.Locale = 'tr'
