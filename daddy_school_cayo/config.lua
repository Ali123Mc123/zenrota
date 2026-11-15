Config = {}

Config.Interior = vec3(5335.95, -5235.60, 32.00) -- a point inside the school; its interior is found from it
Config.Reach = 300.0                 -- layouts are looked after within this distance of that point
Config.Command = 'schoollayout'      -- /schoollayout <name> [on|off]; without a word it flips
Config.Aces = { 'daddyschool.layout', 'daddy.admin', 'admin', 'command' } -- who may: a player holding any of these
Config.Open = GetConvar('daddyschool:open', 'false') == 'true' -- set daddyschool:open true: everyone may (test servers)
Config.Tries = 3                     -- a set the interior does not take is asked for this often, then left alone

Config.DefaultSets = { 'class_day' } -- interior sets that are on unless a layout turns them off

-- on / off: interior sets; ipl: a map file of the campus; replaces: layouts that go off when this one comes on
Config.Layouts = {
    exam = { on = { 'class_exam' }, off = { 'class_day' } },            -- classrooms: one chair a desk, a sheet and a pencil
    graduation = { ipl = 'daddyschool_ev_grad', replaces = { 'fair' } }, -- chairs on the lawn before the stage
    fair = { ipl = 'daddyschool_ev_fair', replaces = { 'graduation' } }, -- marquees between the lawn's seat walls
}
Config.Names = { 'exam', 'graduation', 'fair' }

-- passages: two places joined by a fade. a, b = where one stands at each end (x, y, z, heading); the text shows at that end
-- Tünel kapısı <-> menfez E ile ışınlanma geçişi kapatıldı (istenmiyor). Boş kaldıkça client hiçbir geçiş çalıştırmaz.
Config.Passages = {}
Config.PassageReach = 1.5            -- how near an end one has to stand
Config.PassageFade = 700             -- the fade's length, milliseconds
