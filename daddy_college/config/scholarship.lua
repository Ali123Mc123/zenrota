-- Scholarship: a rate each student wins at the scholarship press. It lowers what they pay at school
-- and pays a small allowance every hour. The server picks the slice; the press only plays it.
-- Settings saved from the admin panel win over the ones here.
Config.Scholarship = {
    -- How a student gets to spin: 'machine' (scholarship_machine spots), 'desk' (at Student Affairs),
    -- 'jobchange' (on becoming a student or logging in as one), 'command' (only when an admin opens it).
    TriggerMode = 'machine',
    MachineModel = 'ch_prop_casino_slot_08a', -- used when the spot has no model
    MachineDistance = 2.5,
    NearDistance = 5.0, -- the spin needs the player this close to a machine or a desk

    -- The wheel; weight is the chance of a slice and is never sent to players.
    Slices = {
        { percent = 25, weight = 25 },
        { percent = 50, weight = 25 },
        { percent = 75, weight = 25 },
        { percent = 100, weight = 25 },
    },
    ResetDays = 3,            -- a scholarship lasts this long, then the student spins again
    EnrollDefaultPercent = 0, -- given on enrolment; 0: none until the student spins

    -- A 100% scholarship pays Hourly an hour, lower rates less. Paid to the student card when cardpay runs,
    -- otherwise to this account.
    Payout = { Hourly = 800, IntervalMinutes = 60, Account = 'cash' }, -- DaddyRP: nakit

    -- With academics: the rate follows the student's lesson levels instead of the press. Every enrolled student has
    -- Base; each lesson that reaches Level moves it one step up (Steps[1] with one such lesson, Steps[2] with two ...,
    -- more keep the last). The press then only shows the rate. A rate set by hand (admin, tablet, package) stays until
    -- it ends. Enabled = false: the press as before.
    Levels = {
        Enabled = true,
        Base = 25,
        Level = 10,
        Steps = { 50, 75, 100 },
    },

    -- Players with the ACE get the package: 'fixed' gives its rate, 'boost' spins only slices at or above it.
    Packages = {
        -- gold = { ace = 'daddy.scholarship.gold', percent = 75 },
    },
    PackageMode = 'fixed',

    Commands = { open = 'scholarshipopen', reset = 'scholarshipreset', set = 'scholarshipset', mine = 'myscholarship' },

    -- The press: card, lever, drum, printer and stamp times in ms.
    Presentation = { CardInsertMs = 650, LeverMs = 500, DrumMs = 2100, PrinterMs = 900, StampMs = 1100, SoundVolume = 0.12 },
}
