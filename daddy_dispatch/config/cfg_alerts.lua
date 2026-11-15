-- Alert types. The title is locales' alerts.<type> (or title = 'text' here). Every type is also an export under its
-- glxs / ps-dispatch name (server/sv_compat.lua, client/cl_compat.lua).
--   code      the radio code on the card
--   priority  1 (red), 2 (amber), 3 (grey)
--   icon      the page's icon: gun car fist fire badge med store house bank case eye pill lock phone siren news
--   kind      the player's filter group: weapons vehicle robbery fight citizen ems officer other
--   to        groups (Config.Jobs) or job names that get it
--   blip      the map blip: sprite, colour (https://docs.fivem.net/docs/game-references/blips/)
--   fuzz      metres the shown place may be off (0: exact)
--   context   what the caller's client adds: gender weapon vehicle
--   single    never folded into an earlier call of the same type
Config.Alerts = {
    shooting = { code = '10-32', priority = 1, icon = 'gun', kind = 'weapons', to = { 'leo' }, blip = { sprite = 110, colour = 1 }, fuzz = 60, context = { 'gender', 'weapon' } },
    vehicle_shooting = { code = '10-32V', priority = 1, icon = 'gun', kind = 'weapons', to = { 'leo' }, blip = { sprite = 229, colour = 1 }, fuzz = 60, context = { 'gender', 'weapon', 'vehicle' } },
    reckless_driving = { code = '10-55', priority = 2, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 227, colour = 47 }, fuzz = 40, context = { 'vehicle' } },
    street_racing = { code = '10-93R', priority = 2, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 315, colour = 47 }, fuzz = 60, context = { 'vehicle' } },
    vehicle_theft = { code = '10-37V', priority = 3, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 225, colour = 5 }, fuzz = 40, context = { 'gender', 'vehicle' } },
    carjacking = { code = '10-31', priority = 2, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 225, colour = 1 }, fuzz = 30, context = { 'gender', 'vehicle' } },
    emergency_vehicle_theft = { code = '10-37E', priority = 1, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 225, colour = 1 }, fuzz = 0, single = true, context = { 'gender', 'vehicle' } },
    car_boosting = { code = '10-35B', priority = 2, icon = 'car', kind = 'vehicle', to = { 'leo' }, blip = { sprite = 225, colour = 47 }, fuzz = 0, context = { 'vehicle' } },
    fight = { code = '10-10', priority = 3, icon = 'fist', kind = 'fight', to = { 'leo' }, blip = { sprite = 311, colour = 5 }, fuzz = 40, context = { 'gender' } },
    explosion = { code = '10-92', priority = 1, icon = 'fire', kind = 'other', to = { 'leo', 'ems' }, blip = { sprite = 436, colour = 1 }, fuzz = 30 },
    fire = { code = '10-70', priority = 1, icon = 'fire', kind = 'other', to = { 'leo', 'ems' }, blip = { sprite = 436, colour = 47 }, fuzz = 30 },
    suspicious_activity = { code = '10-37', priority = 3, icon = 'eye', kind = 'other', to = { 'leo' }, blip = { sprite = 66, colour = 5 }, fuzz = 40, context = { 'gender' } },
    drug_sale = { code = '10-56', priority = 2, icon = 'pill', kind = 'other', to = { 'leo' }, blip = { sprite = 51, colour = 1 }, fuzz = 40, context = { 'gender' } },
    prison_break = { code = '10-98', priority = 1, icon = 'lock', kind = 'other', to = { 'leo' }, blip = { sprite = 188, colour = 1 }, fuzz = 0, single = true },
    illegal = { code = '10-99', priority = 2, icon = 'eye', kind = 'other', to = { 'leo' }, blip = { sprite = 161, colour = 1 }, fuzz = 30 },

    officer_down = { code = '10-99', priority = 1, icon = 'badge', kind = 'officer', to = { 'leo', 'ems' }, blip = { sprite = 526, colour = 1 }, fuzz = 0, single = true },
    officer_backup = { code = '10-78', priority = 1, icon = 'badge', kind = 'officer', to = { 'leo' }, blip = { sprite = 526, colour = 47 }, fuzz = 0, single = true },
    officer_distress = { code = '10-00', priority = 1, icon = 'badge', kind = 'officer', to = { 'leo' }, blip = { sprite = 526, colour = 1 }, fuzz = 0, single = true },
    panic = { code = '99', priority = 1, icon = 'siren', kind = 'officer', to = { 'leo', 'ems' }, blip = { sprite = 526, colour = 1 }, fuzz = 0, single = true },
    backup = { code = '0', priority = 1, icon = 'siren', kind = 'officer', to = { 'leo' }, blip = { sprite = 526, colour = 47 }, fuzz = 0, single = true },
    code = { code = '%s', priority = 2, icon = 'radio', kind = 'officer', to = { 'leo', 'ems' }, blip = { sprite = 526, colour = 5 }, fuzz = 0, single = true },
    ems_down = { code = '10-52E', priority = 1, icon = 'med', kind = 'ems', to = { 'leo', 'ems' }, blip = { sprite = 153, colour = 1 }, fuzz = 0, single = true },
    player_down = { code = '10-52', priority = 1, icon = 'med', kind = 'ems', to = { 'ems' }, blip = { sprite = 153, colour = 1 }, fuzz = 20, context = { 'gender' } },
    civilian_dead = { code = '10-54', priority = 2, icon = 'med', kind = 'ems', to = { 'leo', 'ems' }, blip = { sprite = 153, colour = 1 }, fuzz = 20, context = { 'gender' } },

    store_robbery = { code = '211', priority = 1, icon = 'store', kind = 'robbery', to = { 'leo' }, blip = { sprite = 52, colour = 1 }, fuzz = 0, context = { 'gender', 'weapon' } },
    house_robbery = { code = '459', priority = 2, icon = 'house', kind = 'robbery', to = { 'leo' }, blip = { sprite = 40, colour = 1 }, fuzz = 20, context = { 'gender' } },
    bank_robbery = { code = '10-90B', priority = 1, icon = 'bank', kind = 'robbery', to = { 'leo' }, blip = { sprite = 108, colour = 1 }, fuzz = 0, context = { 'gender', 'weapon' } },
    pacific_bank_robbery = { code = '10-90P', priority = 1, icon = 'bank', kind = 'robbery', to = { 'leo' }, blip = { sprite = 108, colour = 1 }, fuzz = 0 },
    paleto_bank_robbery = { code = '10-90PB', priority = 1, icon = 'bank', kind = 'robbery', to = { 'leo' }, blip = { sprite = 108, colour = 1 }, fuzz = 0 },
    vangelico_robbery = { code = '10-90V', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 617, colour = 1 }, fuzz = 0 },
    art_gallery_robbery = { code = '10-90AG', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 269, colour = 1 }, fuzz = 0 },
    humane_labs_robbery = { code = '10-90HL', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 499, colour = 1 }, fuzz = 0 },
    union_robbery = { code = '10-90UD', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 473, colour = 1 }, fuzz = 0 },
    underground_robbery = { code = '10-90UT', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 478, colour = 1 }, fuzz = 0 },
    bobcat_robbery = { code = '10-90BC', priority = 1, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 67, colour = 1 }, fuzz = 0 },
    train_robbery = { code = '10-90T', priority = 2, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 795, colour = 1 }, fuzz = 0 },
    van_robbery = { code = '10-90AV', priority = 2, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 67, colour = 1 }, fuzz = 0 },
    yacht_robbery = { code = '10-90Y', priority = 2, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 455, colour = 1 }, fuzz = 0 },
    drug_boat_robbery = { code = '10-90DB', priority = 2, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 427, colour = 1 }, fuzz = 0 },
    sign_robbery = { code = '10-90S', priority = 3, icon = 'case', kind = 'robbery', to = { 'leo' }, blip = { sprite = 161, colour = 5 }, fuzz = 20 },

    call_911 = { code = '911', priority = 2, icon = 'phone', kind = 'citizen', to = { 'leo' }, blip = { sprite = 280, colour = 1 }, fuzz = 0, single = true },
    call_311 = { code = '311', priority = 2, icon = 'phone', kind = 'citizen', to = { 'ems' }, blip = { sprite = 280, colour = 5 }, fuzz = 0, single = true },
    call_211 = { code = '211', priority = 3, icon = 'news', kind = 'citizen', to = { 'news' }, blip = { sprite = 280, colour = 3 }, fuzz = 0, single = true },

    -- Alerts other scripts send with their own title (tgiann's Alert, ps-dispatch's CustomAlert ...).
    custom = { code = '10-00', priority = 2, icon = 'radio', kind = 'other', to = { 'leo' }, blip = { sprite = 161, colour = 1 }, fuzz = 0 },
}
