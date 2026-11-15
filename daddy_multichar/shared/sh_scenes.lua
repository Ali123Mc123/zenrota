-- Role scenes: the selection's backdrops for what a character is (Config.Selection.Roles), with their own people,
-- cars, props and what the character does there. Each character opens on one of its role; players can also pick
-- them in the Scene tab. A fresh database copies these once; edit in game with /mcedit, then
-- node tools/multichar/export-scenes.mjs writes the edited scenes back here.
--   setups.solo: the character's spot (one character per scene); points are local to the anchor
--   spot.act / female: what the actor does (scenario, or dict + clip + flag, prop = { model, bone, pos, rot })
--   spot.sync = { dict, dictB, a, b, with }: a two-person animation with the extra named with (CPR)
--   extras = { id, model, at, act, sex, walk, speed, alpha }; cars = { model, at, lights, siren, doors, tilt... }
Config.Scenes = Config.Scenes or {}
Config.Scenes.Presets = Config.Scenes.Presets or {}
local P = Config.Scenes.Presets

P.role_biz_limo = {
    label = 'Araban Hazır',
    desc = 'Vinewood Hills · şoför seni bekliyor',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 7.519, y = 547.691, z = 175.9, h = 20.264 },
    time = { h = 20, m = 0 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 252.643 }, act = { scenario = 'WORLD_HUMAN_STAND_MOBILE' } } } },
    extras = {
        {
            id = 'driver',
            model = 's_m_m_highsec_01',
            sex = 'm',
            at = { x = -1.834, y = -0.397, z = 0, h = 235.5 },
            act = { scenario = 'WORLD_HUMAN_GUARD_STAND' },
        },
        { id = 'guard', model = 's_m_m_highsec_02', sex = 'm', at = { x = 1.6, y = 1.8, z = 0, h = 200 }, act = { scenario = 'WORLD_HUMAN_GUARD_STAND' } },
        { id = 'photo', model = 'a_m_y_hipster_01', sex = 'm', at = { x = 2.8, y = -1.8, z = 0, h = 60 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
    },
    cars = { { model = 'stretch', at = { x = -4.153, y = 1.54, z = 0, h = 107.596 }, doors = { 2 }, engine = true, lights = true } },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.765, y = 13.501, z = 5.2 }, look = { x = 1.165, y = 2.061, z = 1 }, fov = 42 },
                { pos = { x = 2.565, y = 6.461, z = 1.8 }, look = { x = 1.165, y = 2.061, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.985, y = 7.341, z = 1.9 }, look = { x = 1.165, y = 2.061, z = 1.45 }, fov = 38 },
                { pos = { x = 2.565, y = 6.461, z = 1.8 }, look = { x = 1.165, y = 2.061, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_campus_hi = {
    label = 'Teneffüs',
    desc = 'ULSA · öğlen görüşürüz',
    role = 'campus',
    mode = 'single',
    anchor = { x = -1644.597, y = 216.678, z = 60.6, h = 290 },
    time = { h = 11, m = 0 },
    weather = 'EXTRASUNNY',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_AA_COFFEE' } } } },
    extras = {
        {
            id = 'friend',
            model = 'a_m_y_vinewood_01',
            sex = 'm',
            at = { x = -4.394, y = -4.622, z = -0.503, h = 327.459 },
            act = { dict = 'amb@prop_human_seat_chair_mp@male@generic@idle_a', clip = 'idle_a', flag = 1 },
        },
        {
            id = 'reader',
            model = 'a_f_y_vinewood_02',
            sex = 'f',
            at = { x = 1.647, y = -0.968, z = 0, h = 56.823 },
            act = {
                dict = 'cellphone@',
                clip = 'cellphone_text_read_base',
                flag = 49,
                prop = { model = 'prop_novel_01', bone = 6286, pos = { x = 0.15, y = 0.03, z = -0.065 }, rot = { x = 0, y = 180, z = 90 } },
            },
        },
        { id = 'lawn', model = 'a_m_y_hipster_01', sex = 'm', at = { x = 8.272, y = -1.028, z = 0, h = 13.375 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
        {
            id = 'coffee',
            model = 'a_f_y_hipster_01',
            sex = 'f',
            at = { x = -2.951, y = -4.623, z = 0, h = 75.129 },
            act = { dict = 'mini@prostitutestalk', clip = 'street_argue_f_a', flag = 1 },
        },
        {
            id = 'talk_a',
            model = 'a_m_y_bevhills_02',
            sex = 'm',
            at = { x = -3.4, y = -1.2, z = 0, h = 95 },
            act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' },
        },
        {
            id = 'talk_b',
            model = 'a_f_y_bevhills_02',
            sex = 'f',
            at = { x = -4.4, y = -1.1, z = 0, h = 275 },
            act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' },
        },
        {
            id = 'walker',
            model = 'a_f_y_vinewood_01',
            sex = 'f',
            at = { x = -6.648, y = 2.732, z = 0, h = 274.212 },
            walk = { { x = 10.747, y = 2, z = 0, h = 0 }, { x = 9.096, y = 24.067, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'walker2',
            model = 'a_m_y_hipster_02',
            sex = 'm',
            at = { x = 7.582, y = 3.113, z = 0, h = 95.044 },
            walk = { { x = -18.171, y = 1.515, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'runner',
            model = 'a_m_y_runner_01',
            sex = 'm',
            at = { x = -0.372, y = -11.367, z = 0, h = 6.156 },
            walk = { { x = -1.411, y = 1.983, z = 0, h = 0 }, { x = 19.469, y = 2.675, z = 0, h = 0 } },
            speed = 1.3,
        },
    },
    cars = { { model = 'scorcher', at = { x = 3.788, y = -2.459, z = 0, h = 224.058 } } },
    props = { { model = 'p_michael_backpack_s', at = { x = 8.845, y = -0.615, z = 0, h = 231.031 }, collision = false } },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.6, y = 10.92, z = 5.2 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = 1.4, y = 4.2, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.82, y = 5.04, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = 1.4, y = 4.2, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_boulevard = {
    label = 'Şöhretler Kaldırımı',
    desc = 'Vinewood Blvd · ışıklar yandı',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 293.469, y = 181.51, z = 104.3, h = 160 },
    time = { h = 22, m = 0 },
    weather = 'CLEAR',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 0 },
                act = { scenario = 'WORLD_HUMAN_TOURIST_MOBILE' },
                cam = { pos = { x = 0.173, y = 2.892, z = -0.079 }, look = { x = 1.48, y = -7.015, z = -0.437 }, fov = 42 },
            },
        },
    },
    extras = {
        { id = 'pap', model = 'a_m_y_vinewood_03', sex = 'm', at = { x = 4.522, y = 1.09, z = 0, h = 150 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
        { id = 'pap2', model = 'a_m_y_hipster_02', sex = 'm', at = { x = -2.8, y = 2.4, z = 0, h = 210 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
        { id = 'fan', model = 'a_f_y_tourist_01', sex = 'f', at = { x = -3.4, y = -1.6, z = 0, h = 60 }, act = { scenario = 'WORLD_HUMAN_TOURIST_MOBILE' } },
        {
            id = 'guard',
            model = 's_m_m_highsec_01',
            sex = 'm',
            at = { x = 1.864, y = -7.874, z = 0, h = 356.713 },
            act = { scenario = 'WORLD_HUMAN_GUARD_STAND' },
        },
        { id = 'walker', model = 'a_f_y_vinewood_02', sex = 'f', at = { x = -9, y = -1.487, z = 0, h = 270 }, walk = { { x = 9, y = -5.036, z = 0, h = 0 } } },
        { id = 'walker2', model = 'a_m_y_vinewood_01', sex = 'm', at = { x = 9, y = -2.773, z = 0, h = 90 }, walk = { { x = -9, y = -4.226, z = 0, h = 0 } } },
        {
            id = 'guardb',
            model = 's_m_m_highsec_02',
            sex = 'm',
            at = { x = -1.906, y = -8.128, z = 0, h = 356.713 },
            act = { scenario = 'WORLD_HUMAN_GUARD_STAND' },
        },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.7 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.4, y = 11.44, z = 5.4 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.08, y = 5.28, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_casino = {
    label = 'Büyük Oyuncu',
    desc = 'The Diamond · araban kapıya getiriliyor',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 913.73, y = 54.25, z = 80.9, h = 235 },
    time = { h = 23, m = 30 },
    weather = 'CLEAR',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 0 },
                act = {
                    dict = 'amb@world_human_drinking@coffee@male@idle_a',
                    clip = 'idle_c',
                    flag = 49,
                    prop = { model = 'prop_drink_champ', bone = 28422, pos = { x = 0, y = 0, z = -0.06 }, rot = { x = 0, y = 0, z = 0 } },
                },
                cam = { pos = { x = 0.603, y = 1.514, z = 0.257 }, look = { x = -0.503, y = -8.424, z = 0.128 }, fov = 42 },
            },
        },
    },
    extras = {
        { id = 'valet', model = 's_m_y_valet_01', sex = 'm', at = { x = 3.659, y = 0.489, z = 0, h = 200 }, act = { scenario = 'WORLD_HUMAN_STAND_IMPATIENT' } },
        { id = 'doorman', model = 's_m_m_highsec_01', sex = 'm', at = { x = -2.8, y = -3.4, z = 0, h = 160 }, act = { scenario = 'WORLD_HUMAN_GUARD_STAND' } },
        { id = 'guest', model = 'a_m_y_bevhills_02', sex = 'm', at = { x = -4, y = -1, z = 0, h = 95 }, act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' } },
        {
            id = 'guest2',
            model = 'a_f_y_bevhills_02',
            sex = 'f',
            at = { x = -5, y = -0.9, z = 0, h = 275 },
            act = {
                dict = 'amb@world_human_drinking@coffee@male@idle_a',
                clip = 'idle_c',
                flag = 49,
                prop = { model = 'prop_drink_champ', bone = 28422, pos = { x = 0, y = 0, z = -0.06 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
        { id = 'photo', model = 'a_m_y_vinewood_03', sex = 'm', at = { x = 1.8, y = 4.673, z = 0, h = 152.352 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
    },
    cars = {
        { model = 'stretch', at = { x = 5.687, y = 1.91, z = 0, h = 92.948 }, doors = { 2 }, engine = true, lights = true },
        { model = 'zentorno', at = { x = -6.434, y = 1.23, z = 0, h = 273.268 }, lights = true, tuned = true },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.7 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.4, y = 11.44, z = 5.4 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.08, y = 5.28, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_galileo = {
    label = 'Gözlemevi',
    desc = 'Galileo · şehrin ışıkları yanıyor',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -413.043, y = 1169.017, z = 325.85, h = 341 },
    time = { h = 20, m = 15 },
    weather = 'CLEAR',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 0 },
                act = { scenario = 'WORLD_HUMAN_TOURIST_MAP' },
                cam = { pos = { x = 0.384, y = 2.306, z = 0.038 }, look = { x = 1.386, y = -7.641, z = -0.206 }, fov = 42 },
            },
        },
    },
    extras = {
        { id = 'scope', model = 'a_m_m_tourist_01', sex = 'm', at = { x = -4, y = -3, z = 0, h = 200 }, act = { scenario = 'WORLD_HUMAN_BINOCULARS' } },
        { id = 'lawn', model = 'a_f_y_hipster_02', sex = 'f', at = { x = -5, y = -4.6, z = 0, h = 40 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
        { id = 'lawn2', model = 'a_m_y_hipster_01', sex = 'm', at = { x = -4, y = -5.2, z = 0, h = 300 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
        { id = 'photo', model = 'a_m_y_vinewood_03', sex = 'm', at = { x = 2.6, y = -6.4, z = 0, h = 180 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
        { id = 'guard', model = 's_m_m_security_01', sex = 'm', at = { x = -1, y = -10.505, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_GUARD_STAND' } },
        {
            id = 'jogger',
            model = 'a_f_y_runner_01',
            sex = 'f',
            at = { x = 8, y = -9.5, z = 0, h = 90 },
            walk = { { x = -8, y = -9.5, z = 0, h = 0 } },
            speed = 1.3,
        },
    },
    cars = { { model = 'tempesta', at = { x = 7.742, y = 6.687, z = 0, h = 112.681 }, lights = true } },
    light = false,
    dof = { near = 1, far = 3, strength = 0.7 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.4, y = 11.44, z = 5.4 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.08, y = 5.28, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_helipad = {
    label = 'En Üst Kat',
    desc = 'Maze Bank · şehir ayaklarının altında',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -74.94, y = -824.087, z = 327.17, h = 180 },
    time = { h = 23, m = 0 },
    weather = 'CLEAR',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 0 },
                female = {
                    dict = 'anim@amb@casino@peds@',
                    clip = 'amb_prop_human_seat_chair_drink_beer_female_idle_c',
                    flag = 1,
                    prop = { model = 'prop_drink_champ', bone = 28422, pos = { x = 0, y = 0, z = -0.06 }, rot = { x = 0, y = 0, z = 0 } },
                },
                cam = { pos = { x = -0.138, y = 2.116, z = -0.856 }, look = { x = 2.375, y = -7.561, z = -1.022 }, fov = 42 },
            },
        },
    },
    extras = {
        { id = 'pilot', model = 's_m_y_pilot_01', sex = 'm', at = { x = 2.6, y = -2.293, z = 0, h = 160 }, act = { scenario = 'WORLD_HUMAN_CLIPBOARD' } },
        { id = 'guard', model = 's_m_m_highsec_01', sex = 'm', at = { x = -2.8, y = 1.107, z = 0, h = 160 }, act = { scenario = 'WORLD_HUMAN_GUARD_STAND' } },
        { id = 'guard2', model = 's_m_m_highsec_02', sex = 'm', at = { x = 3.2, y = 1.907, z = 0, h = 200 }, act = { scenario = 'WORLD_HUMAN_GUARD_STAND' } },
        {
            id = 'assistant',
            model = 'a_f_y_business_02',
            sex = 'f',
            at = { x = -1.963, y = -1.218, z = 0, h = 344.303 },
            act = { scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        },
    },
    cars = { { model = 'swift2', at = { x = 0, y = -5.293, z = 0, h = 0 }, doors = { 0, 1 }, lights = true } },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.4, y = 14.147, z = 5.4 }, look = { x = 0, y = 2.707, z = 1 }, fov = 42 },
                { pos = { x = 1.6, y = 7.107, z = 1.8 }, look = { x = 0, y = 2.707, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.08, y = 7.987, z = 1.9 }, look = { x = 0, y = 2.707, z = 1.45 }, fov = 38 },
                { pos = { x = 1.6, y = 7.107, z = 1.8 }, look = { x = 0, y = 2.707, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_hotdog = {
    label = 'Öğle Arası',
    desc = 'Del Perro · bol hardallı',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 1537.176, y = 6618.731, z = 1.329, h = 231.571 },
    time = { h = 19, m = 45 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 339.765 },
                act = {
                    dict = 'mp_player_inteat@burger',
                    clip = 'mp_player_int_eat_burger',
                    flag = 49,
                    prop = { model = 'prop_cs_hotdog_01', bone = 60309, pos = { x = 0.05, y = 0, z = -0.02 }, rot = { x = 30, y = 0, z = 0 } },
                },
            },
        },
    },
    extras = {
        { id = 'vendor', model = 's_m_m_strvend_01', sex = 'm', at = { x = 0.539, y = -3.667, z = 0, h = 180 }, act = { scenario = 'PROP_HUMAN_BBQ' } },
        {
            id = 'phone',
            model = 'a_m_y_hipster_01',
            sex = 'm',
            at = { x = 3.152, y = -3.181, z = 0, h = 29.879 },
            act = {
                dict = 'cellphone@',
                clip = 'cellphone_text_read_base',
                flag = 49,
                prop = { model = 'prop_npc_phone_02', bone = 28422, pos = { x = 0, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
        {
            id = 'pigeon',
            model = 'a_c_pigeon',
            sex = 'm',
            at = { x = -1.625, y = -0.717, z = 0, h = 39.777 },
            walk = { { x = 2.119, y = -2.493, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'pigeon2',
            model = 'a_c_pigeon',
            sex = 'm',
            at = { x = -2.152, y = -0.453, z = 0, h = 324.154 },
            walk = { { x = 1.384, y = -2, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'walker',
            model = 'a_f_y_tourist_02',
            sex = 'f',
            at = { x = -14.956, y = -11.55, z = 0, h = 298.193 },
            walk = { { x = 12.417, y = 4.196, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'walker2',
            model = 'a_m_y_beach_02',
            sex = 'm',
            at = { x = 12.342, y = -5.397, z = 0, h = 77.4 },
            walk = { { x = -17.624, y = 5.222, z = 0, h = 0 } },
            speed = 1,
        },
        { id = 'fire_a', model = 'a_m_y_beach_01', sex = 'm', at = { x = -3.982, y = -4.145, z = 0, h = 236.427 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
        { id = 'fire_b', model = 'a_f_y_beach_01', sex = 'f', at = { x = -1.961, y = -5.049, z = 0, h = 114.365 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
        { id = 'fire_c', model = 'a_m_y_hippy_01', sex = 'm', at = { x = -2.637, y = -6.768, z = 0, h = 30 }, act = { scenario = 'WORLD_HUMAN_PICNIC' } },
    },
    props = {
        { model = 'prop_hotdogstand_01', at = { x = 0.416, y = -4.502, z = 0, h = 356.23 }, collision = true },
        { model = 'prop_bin_07a', at = { x = 1.757, y = -4.77, z = 0, h = 0 }, collision = false },
        { model = 'prop_beach_fire', at = { x = -3.178, y = -5.477, z = 0, h = 0 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 14.031, y = 3.467, z = 5.2 }, look = { x = 0.431, y = 0.347, z = 1 }, fov = 42 },
                { pos = { x = 3.831, y = 1.547, z = 1.8 }, look = { x = 0.431, y = 0.347, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 4.851, y = 1.787, z = 1.9 }, look = { x = 0.431, y = 0.347, z = 1.45 }, fov = 38 },
                { pos = { x = 3.831, y = 1.547, z = 1.8 }, look = { x = 0.431, y = 0.347, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_hug = {
    label = 'Uzun Zaman Oldu',
    desc = 'Del Perro İskelesi · gel buraya',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -1701.231, y = -1139.025, z = 12.111, h = 324.586 },
    time = { h = 19, m = 30 },
    weather = 'EXTRASUNNY',
    setups = { solo = { { at = { x = 0, y = 0.001, z = 0, h = 325.601 }, act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' } } } },
    extras = {
        {
            id = 'friend',
            model = 'a_f_y_hipster_02',
            sex = 'f',
            at = { x = -0.033, y = -5.282, z = 0, h = 214.107 },
            act = { dict = 'anim@amb@nightclub@dancers@solomun_entourage@', clip = 'mi_dance_facedj_17_v1_female^1', flag = 1 },
        },
        {
            id = 'musician',
            model = 'a_m_y_hippy_01',
            sex = 'm',
            at = { x = 0.944, y = -6.928, z = 0, h = 25.915 },
            act = {
                dict = 'amb@world_human_musician@guitar@male@idle_a',
                clip = 'idle_b',
                flag = 1,
                prop = { model = 'prop_acc_guitar_01', bone = 24818, pos = { x = -0.1, y = 0.31, z = 0.1 }, rot = { x = 0, y = 20, z = 150 } },
            },
        },
        {
            id = 'fisher',
            model = 'a_m_m_salton_02',
            sex = 'm',
            at = { x = -3.592, y = -8.391, z = 0, h = 172.211 },
            act = { scenario = 'WORLD_HUMAN_STAND_FISHING' },
        },
        {
            id = 'tourist',
            model = 'a_f_y_tourist_01',
            sex = 'f',
            at = { x = 1.357, y = -5.144, z = 0, h = 158.183 },
            act = { dict = 'anim@mp_player_intupperslow_clap', clip = 'idle_a', flag = 49 },
        },
        {
            id = 'stroll_a',
            model = 'a_m_y_beach_01',
            sex = 'm',
            at = { x = -9.033, y = -6.108, z = 0, h = 217.948 },
            walk = { { x = 11.255, y = 6.104, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'stroll_b',
            model = 'a_f_y_beach_01',
            sex = 'f',
            at = { x = -7.848, y = -6.729, z = 0, h = 78.936 },
            walk = { { x = 10.21, y = 6.9, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'walker',
            model = 'a_m_y_vinewood_02',
            sex = 'm',
            at = { x = 8.597, y = -7.122, z = 0, h = 82.48 },
            walk = { { x = -24.224, y = -3.501, z = 0, h = 0 } },
            speed = 1,
        },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.7 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 4.187, y = 10.921, z = 5.2 }, look = { x = -1.413, y = 0.001, z = 1 }, fov = 42 },
                { pos = { x = -0.013, y = 4.201, z = 1.8 }, look = { x = -1.413, y = 0.001, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 0.407, y = 5.041, z = 1.9 }, look = { x = -1.413, y = 0.001, z = 1.45 }, fov = 38 },
                { pos = { x = -0.013, y = 4.201, z = 1.8 }, look = { x = -1.413, y = 0.001, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_kortz = {
    label = 'Özel Manzara',
    desc = 'Kortz Center · okyanusta gün batımı',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -2255.896, y = 243.543, z = 172.186, h = 269.628 },
    time = { h = 19, m = 0 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = -0.015, h = 0 },
                act = {
                    dict = 'anim@amb@business@cfid@cfid_desk_no_work_bgen_chair_no_work@',
                    clip = 'phone_search_lazyworker',
                    flag = 1,
                    prop = { model = 'prop_npc_phone_02', bone = 60309, pos = { x = 0, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
                },
                cam = { pos = { x = 0.436, y = 1.58, z = 2.398 }, look = { x = 0.619, y = -8.35, z = 1.235 }, fov = 42 },
            },
        },
    },
    extras = {
        {
            id = 'guest',
            model = 'a_m_y_bevhills_02',
            sex = 'm',
            at = { x = -2.63, y = -2.674, z = 0, h = 95 },
            act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' },
        },
        {
            id = 'guest2',
            model = 'a_f_y_bevhills_02',
            sex = 'f',
            at = { x = -3.63, y = -2.574, z = 0, h = 275 },
            act = {
                dict = 'amb@world_human_drinking@coffee@male@idle_a',
                clip = 'idle_c',
                flag = 49,
                prop = { model = 'prop_drink_champ', bone = 28422, pos = { x = 0, y = 0, z = -0.06 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
        {
            id = 'waiter',
            model = 's_m_y_waiter_01',
            sex = 'm',
            at = { x = 6.313, y = -5.056, z = 0, h = 126.371 },
            act = { scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
        },
        { id = 'photo', model = 'a_m_y_vinewood_03', sex = 'm', at = { x = 3.17, y = -5.474, z = 0, h = 160 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } },
        {
            id = 'visitor',
            model = 'a_f_y_business_02',
            sex = 'f',
            at = { x = -9.73, y = -3.046, z = 0, h = 270 },
            walk = { { x = 5.296, y = -2.213, z = 0, h = 0 }, { x = 5.073, y = 2.813, z = 0, h = 0 }, { x = -18.922, y = 2.813, z = 0, h = 0 } },
        },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 7.17, y = 11.366, z = 5.4 }, look = { x = 0.77, y = -0.074, z = 1 }, fov = 42 },
                { pos = { x = 2.37, y = 4.326, z = 1.8 }, look = { x = 0.77, y = -0.074, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.85, y = 5.206, z = 1.9 }, look = { x = 0.77, y = -0.074, z = 1.45 }, fov = 38 },
                { pos = { x = 2.37, y = 4.326, z = 1.8 }, look = { x = 0.77, y = -0.074, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_lighthouse = {
    label = 'Fırtına Nöbeti',
    desc = 'El Gordo Deniz Feneri · deniz kabarmış',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 3352.071, y = 5153.068, z = 20.05, h = 280.5 },
    time = { h = 18, m = 30 },
    weather = 'THUNDER',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_SMOKING' } } } },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 8.461, y = 11.057, z = 5.4 }, look = { x = 2.061, y = -0.383, z = 1 }, fov = 42 },
                { pos = { x = 3.661, y = 4.017, z = 1.8 }, look = { x = 2.061, y = -0.383, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 4.141, y = 4.897, z = 1.9 }, look = { x = 2.061, y = -0.383, z = 1.45 }, fov = 38 },
                { pos = { x = 3.661, y = 4.017, z = 1.8 }, look = { x = 2.061, y = -0.383, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_lounger = {
    label = 'Şezlong',
    desc = 'Vespucci Plajı · rahatsız etmeyin',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -1481.85, y = -1417.794, z = 2.15, h = 119.39 },
    time = { h = 15, m = 0 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0.001, z = -0.596, h = 0 },
                act = { dict = 'amb@prop_human_seat_sunlounger@male@base', clip = 'base', flag = 1 },
                female = { dict = 'amb@prop_human_seat_sunlounger@female@base', clip = 'base', flag = 1 },
            },
        },
    },
    extras = {
        {
            id = 'neighbour',
            model = 'a_f_y_beach_01',
            sex = 'f',
            at = { x = 1.412, y = 0.174, z = -0.976, h = 359.656 },
            act = { dict = 'amb@prop_human_seat_sunlounger@female@base', clip = 'base', flag = 1 },
        },
        { id = 'tanning', model = 'a_f_y_beach_02', sex = 'f', at = { x = 3.409, y = -0.571, z = 0, h = 20 }, act = { scenario = 'WORLD_HUMAN_SUNBATHE' } },
        {
            id = 'flexer',
            model = 'a_m_y_musclbeac_01',
            sex = 'm',
            at = { x = -2.791, y = 2.429, z = 0, h = 160 },
            act = { scenario = 'WORLD_HUMAN_MUSCLE_FLEX' },
        },
        {
            id = 'jogger',
            model = 'a_f_y_runner_01',
            sex = 'f',
            at = { x = -9.991, y = 5.329, z = 0, h = 270 },
            walk = { { x = 10, y = 5.5, z = 0, h = 0 } },
            speed = 1.3,
        },
        {
            id = 'stroll_a',
            model = 'a_m_y_beach_03',
            sex = 'm',
            at = { x = 10.009, y = 3.829, z = 0, h = 90 },
            walk = { { x = -10, y = 4, z = 0, h = 0 } },
            speed = 1,
        },
        {
            id = 'stroll_b',
            model = 'a_f_y_beach_01',
            sex = 'f',
            at = { x = 10.809, y = 4.429, z = 0, h = 90 },
            walk = { { x = -9.2, y = 4.6, z = 0, h = 0 } },
            speed = 1,
        },
    },
    props = {
        { model = 'prop_patio_lounger1', at = { x = 0.009, y = -0.171, z = 0, h = 180 }, collision = true },
        { model = 'prop_patio_lounger1', at = { x = 1.409, y = -0.171, z = -0.003, h = 180 }, collision = true },
        { model = 'prop_beach_parasol_02', at = { x = 0.709, y = -0.771, z = 0, h = 0 }, collision = false },
        { model = 'prop_coolbox_01', at = { x = 0.709, y = 0.729, z = 0, h = 30 }, collision = false },
        { model = 'prop_beach_towel_02', at = { x = 3.409, y = -0.571, z = 0, h = 20 }, collision = false },
        { model = 'prop_beachball_02', at = { x = 2.209, y = 1.629, z = 0, h = 0 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.409, y = 9.709, z = 5 }, look = { x = 0.009, y = -0.171, z = 1 }, fov = 42 },
                { pos = { x = 1.609, y = 3.629, z = 1.4 }, look = { x = 0.009, y = -0.171, z = 1.1 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.089, y = 4.389, z = 1.5 }, look = { x = 0.009, y = -0.171, z = 1.1 }, fov = 38 },
                { pos = { x = 1.609, y = 3.629, z = 1.4 }, look = { x = 0.009, y = -0.171, z = 1.1 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_sign = {
    label = 'Vinewood Tabelası',
    desc = 'Mount Lee · harfler arkanda',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 711.532, y = 1196.968, z = 347.532, h = 350 },
    time = { h = 19, m = 30 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = -0.425, h = 173.362 },
                act = { dict = 'anim@heists@fleeca_bank@hostages@intro', clip = 'intro_loop_ped_a', flag = 1 },
                low = 'crouch',
                cam = { pos = { x = 1.194, y = 1.132, z = 0.82 }, look = { x = -4.266, y = -6.809, z = -1.849 }, fov = 42 },
            },
        },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.447, y = 12.326, z = 5.4 }, look = { x = 0.047, y = 0.886, z = 1 }, fov = 42 },
                { pos = { x = 1.647, y = 5.286, z = 1.8 }, look = { x = 0.047, y = 0.886, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.127, y = 6.166, z = 1.9 }, look = { x = 0.047, y = 0.886, z = 1.45 }, fov = 38 },
                { pos = { x = 1.647, y = 5.286, z = 1.8 }, look = { x = 0.047, y = 0.886, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_summit = {
    label = 'Dünyanın Zirvesi',
    desc = 'Mount Chiliad · ilk ışık',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 505.112, y = 5603.54, z = 797.91, h = 176.6 },
    time = { h = 6, m = 10 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 88.305 },
                act = {
                    dict = 'switch@michael@pier',
                    clip = 'pier_lean_toss_cigarette',
                    flag = 1,
                    prop = { model = 'prop_amb_ciggy_01', bone = 28422, pos = { x = 0.02, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
                },
                cam = { pos = { x = 0.513, y = -0.967, z = 0.572 }, look = { x = -7.803, y = 4.108, z = -1.687 }, fov = 42 },
            },
        },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 9.808, y = 10.581, z = 5.4 }, look = { x = 3.408, y = -0.859, z = 1 }, fov = 42 },
                { pos = { x = 5.008, y = 3.541, z = 1.8 }, look = { x = 3.408, y = -0.859, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 5.488, y = 4.421, z = 1.9 }, look = { x = 3.408, y = -0.859, z = 1.45 }, fov = 38 },
                { pos = { x = 5.008, y = 3.541, z = 1.8 }, look = { x = 3.408, y = -0.859, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_waterfall = {
    label = 'Gizli Şelale',
    desc = 'Raton Kanyonu · patikanın dışında',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -576.283, y = 4436.841, z = 16.473, h = 94.68 },
    time = { h = 14, m = 0 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = -0.001, y = 0, z = 0, h = 329.993 },
                act = { dict = 'rcmcollect_paperleadinout@', clip = 'meditiate_idle', flag = 1 },
                low = 'crouch',
                cam = { pos = { x = 1.065, y = 1.459, z = 0.586 }, look = { x = -3.325, y = -7.489, z = -0.233 }, fov = 42 },
            },
        },
    },
    light = false,
    dof = { near = 1, far = 3, strength = 0.6 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 8.189, y = 11.53, z = 5.4 }, look = { x = 1.789, y = 0.09, z = 1 }, fov = 42 },
                { pos = { x = 3.389, y = 4.49, z = 1.8 }, look = { x = 1.789, y = 0.09, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 3.869, y = 5.37, z = 1.9 }, look = { x = 1.789, y = 0.09, z = 1.45 }, fov = 38 },
                { pos = { x = 3.389, y = 4.49, z = 1.8 }, look = { x = 1.789, y = 0.09, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_civ_workout = {
    label = 'Kas Plajı',
    desc = 'Vespucci Plajı · tatil yok',
    role = 'civilian',
    mode = 'single',
    anchor = { x = -1203.698, y = -1563.149, z = 4.61, h = 35 },
    time = { h = 8, m = 30 },
    weather = 'EXTRASUNNY',
    setups = { solo = { { at = { x = 0.001, y = 0, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_MUSCLE_FREE_WEIGHTS' } } } },
    extras = {
        {
            id = 'pushups',
            model = 'a_m_y_musclbeac_01',
            sex = 'm',
            at = { x = 2.423, y = -2.47, z = 0, h = 269.702 },
            act = { scenario = 'WORLD_HUMAN_PUSH_UPS' },
        },
        { id = 'yoga', model = 'a_f_y_fitness_01', sex = 'f', at = { x = 1.013, y = -3.742, z = 0, h = 20 }, act = { scenario = 'WORLD_HUMAN_YOGA' } },
        { id = 'situps', model = 'a_m_y_musclbeac_02', sex = 'm', at = { x = -0.837, y = -2.9, z = 0, h = 160 }, act = { scenario = 'WORLD_HUMAN_SIT_UPS' } },
        { id = 'flexer', model = 'a_m_y_musclbeac_02', sex = 'm', at = { x = -2.6, y = -0.6, z = 0, h = 120 }, act = { scenario = 'WORLD_HUMAN_MUSCLE_FLEX' } },
        {
            id = 'lifter',
            model = 'a_m_y_musclbeac_01',
            sex = 'm',
            at = { x = 2.8, y = 0.6, z = 0, h = 240 },
            act = { scenario = 'WORLD_HUMAN_MUSCLE_FREE_WEIGHTS' },
        },
        { id = 'watcher', model = 'a_f_y_beach_01', sex = 'f', at = { x = -1.6, y = 2.4, z = 0, h = 200 }, act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' } },
        {
            id = 'jogger',
            model = 'a_f_y_runner_01',
            sex = 'f',
            at = { x = -10, y = 5, z = 0, h = 270 },
            walk = { { x = 10, y = 5, z = 0, h = 0 } },
            speed = 1.3,
        },
        {
            id = 'walker',
            model = 'a_m_y_beach_03',
            sex = 'm',
            at = { x = 10, y = 6.4, z = 0, h = 90 },
            walk = { { x = -10, y = 6.4, z = 0, h = 0 } },
            speed = 1,
        },
    },
    props = {
        { model = 'prop_boombox_01', at = { x = 1.6, y = 1.4, z = 0, h = 200 }, collision = false },
        { model = 'prop_beach_towel_02', at = { x = 1, y = -3.7, z = 0, h = 20 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.7 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.394, y = 6.745, z = 5.1 }, look = { x = -0.006, y = -4.695, z = 1 }, fov = 42 },
                { pos = { x = 1.594, y = -0.295, z = 1.7 }, look = { x = -0.006, y = -4.695, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.074, y = 0.585, z = 1.8 }, look = { x = -0.006, y = -4.695, z = 1.45 }, fov = 38 },
                { pos = { x = 1.594, y = -0.295, z = 1.7 }, look = { x = -0.006, y = -4.695, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_ems_break = {
    label = 'Uzun Gece',
    desc = 'Pillbox Hill · bir kahve daha',
    role = 'ems',
    mode = 'single',
    anchor = { x = 298.716, y = -583.898, z = 43.26, h = 75.303 },
    time = { h = 3, m = 0 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_AA_COFFEE' } } } },
    extras = {
        {
            id = 'paramedic',
            model = 's_m_m_paramedic_01',
            sex = 'm',
            at = { x = 4.341, y = -0.321, z = 0, h = 338.823 },
            act = { scenario = 'WORLD_HUMAN_SMOKING' },
        },
        {
            id = 'doctor',
            model = 's_m_m_doctor_01',
            sex = 'm',
            at = { x = -2.388, y = 0.113, z = 0, h = 23.144 },
            act = { dict = 'missfra1leadinoutfra_1_int_trevor', clip = '_trevor_leadin_talk_denise', flag = 1 },
        },
        {
            id = 'doctorb',
            model = 's_f_y_scrubs_01',
            sex = 'm',
            at = { x = -3.09, y = 0.622, z = 0, h = 241.308 },
            act = { dict = 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', clip = 'idle_a', flag = 1 },
        },
        {
            id = 'paramedicb',
            model = 'mp_m_securoguard_01',
            sex = 'm',
            at = { x = 1.949, y = -0.789, z = 0, h = 356.471 },
            act = { dict = 'amb@world_human_stand_guard@male@base', clip = 'base', flag = 1 },
        },
    },
    cars = { { model = 'ambulance', at = { x = -7.26, y = 3.322, z = -0.626, h = 84.026 }, doors = { 2, 3 }, lights = true } },
    light = { color = { r = 200, g = 230, b = 255 }, intensity = 3, range = 12 },
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.6, y = 10.903, z = 5.2 }, look = { x = 0, y = -0.017, z = 1 }, fov = 42 },
                { pos = { x = 1.4, y = 4.183, z = 1.6 }, look = { x = 0, y = -0.017, z = 1.1 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.82, y = 5.023, z = 1.7 }, look = { x = 0, y = -0.017, z = 1.1 }, fov = 38 },
                { pos = { x = 1.4, y = 4.183, z = 1.6 }, look = { x = 0, y = -0.017, z = 1.1 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_ems_cpr = {
    label = 'Kalp Masajı',
    desc = 'Vespucci Plajı · benimle kal',
    role = 'ems',
    mode = 'single',
    anchor = { x = -990.64, y = -1436.735, z = 4.076, h = 119.29 },
    time = { h = 18, m = 40 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 52.837 },
                sync = { b = 'cpr_pumpchest', dict = 'mini@cpr@char_a@cpr_str', dictB = 'mini@cpr@char_b@cpr_str', a = 'cpr_pumpchest', with = 'patient' },
                cam = { pos = { x = -1.263, y = 1.843, z = 0.595 }, look = { x = 4.218, y = -6.372, z = -0.975 }, fov = 44 },
            },
        },
    },
    extras = {
        {
            id = 'patient',
            model = 'a_m_m_beach_02',
            sex = 'm',
            at = { x = -0.703, y = 0.631, z = 0, h = 50.965 },
            act = { dict = 'mini@cpr@char_b@cpr_str', clip = 'cpr_pumpchest_idle', flag = 1 },
        },
        { id = 'medic', model = 's_m_m_paramedic_01', sex = 'm', at = { x = 0.584, y = 1.339, z = 0, h = 150 }, act = { scenario = 'CODE_HUMAN_MEDIC_KNEEL' } },
        {
            id = 'caller',
            model = 'a_f_y_beach_01',
            sex = 'f',
            at = { x = -3.716, y = 2.789, z = 0, h = 240 },
            act = {
                dict = 'cellphone@',
                clip = 'cellphone_call_listen_base',
                flag = 49,
                prop = { model = 'prop_npc_phone_02', bone = 28422, pos = { x = 0, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
        {
            id = 'filmer',
            model = 'a_m_y_beach_02',
            sex = 'm',
            at = { x = -1.516, y = 4.089, z = 0, h = 170 },
            act = { scenario = 'WORLD_HUMAN_MOBILE_FILM_SHOCKING' },
        },
        {
            id = 'tourist',
            model = 'a_f_y_tourist_01',
            sex = 'f',
            at = { x = 2.084, y = -2.811, z = 0, h = 20 },
            act = { scenario = 'WORLD_HUMAN_MOBILE_FILM_SHOCKING' },
        },
        { id = 'cop', model = 's_m_y_cop_01', sex = 'm', at = { x = -4.216, y = -0.411, z = 0, h = 330.834 }, act = { scenario = 'WORLD_HUMAN_COP_IDLES' } },
        {
            id = 'lifeguard',
            model = 's_m_y_baywatch_01',
            sex = 'm',
            at = { x = 2.531, y = -0.568, z = 0, h = 100 },
            act = { dict = 'random@arrests', clip = 'generic_radio_chatter', flag = 49 },
        },
    },
    cars = { { model = 'ambulance', at = { x = 5.425, y = 3.24, z = 0, h = 306.036 }, doors = { 2, 3 }, lights = true, siren = true } },
    props = { { model = 'prop_med_bag_01', at = { x = -0.154, y = 0.931, z = 0, h = 30 }, collision = false } },
    light = false,
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.146, y = 9.791, z = 4.9 }, look = { x = -1.054, y = 0.431, z = 1 }, fov = 44 },
                { pos = { x = 0.746, y = 4.031, z = 1.3 }, look = { x = -1.054, y = 0.431, z = 1.1 }, fov = 38 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.286, y = 4.751, z = 1.4 }, look = { x = -1.054, y = 0.431, z = 1.1 }, fov = 40 },
                { pos = { x = 0.746, y = 4.031, z = 1.3 }, look = { x = -1.054, y = 0.431, z = 1.1 }, fov = 38 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_gang_block = {
    label = 'Mahalle',
    desc = 'Grove Street · bizim mekan',
    role = 'gang',
    mode = 'single',
    anchor = { x = 99.176, y = -1992.051, z = 19.494, h = 320 },
    time = { h = 21, m = 30 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 0 }, act = { dict = 'anim@amb@nightclub_island@dancers@beachdance@', clip = 'hi_idle_c_m04', flag = 1 } } } },
    extras = {
        {
            id = 'homie',
            model = 'g_m_y_famca_01',
            sex = 'm',
            at = { x = -3.557, y = -2.628, z = 0, h = 238.379 },
            act = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET' },
        },
        {
            id = 'drinker',
            model = 'g_m_y_famfor_01',
            sex = 'm',
            at = { x = 1.663, y = -1.694, z = 0, h = 118.034 },
            act = { scenario = 'WORLD_HUMAN_DRINKING' },
        },
        { id = 'smoker', model = 'g_m_y_famdnf_01', sex = 'm', at = { x = -3.568, y = -4.086, z = 0, h = 330 }, act = { scenario = 'WORLD_HUMAN_SMOKING_POT' } },
        { id = 'griller', model = 'g_m_y_famca_01', sex = 'm', at = { x = -2.231, y = 0.252, z = 0, h = 56.917 }, act = { scenario = 'PROP_HUMAN_BBQ' } },
        {
            id = 'dancer',
            model = 'g_f_y_families_01',
            sex = 'f',
            at = { x = 1.436, y = -2.812, z = 0, h = 52.055 },
            act = { dict = 'anim@amb@nightclub@dancers@crowddance_facedj@hi_intensity', clip = 'hi_dance_facedj_09_v2_female^3', flag = 1 },
        },
    },
    cars = { { model = 'buccaneer2', at = { x = -1.385, y = -5.563, z = 0, h = 100 }, doors = { 0, 1 }, engine = true, lights = true } },
    props = {
        { model = 'prop_boombox_01', at = { x = 1.96, y = -2.311, z = 0, h = 40 }, collision = false },
        { model = 'prop_bbq_5', at = { x = -2.473, y = 0.649, z = 0, h = 58.265 }, collision = false },
        { model = 'prop_coolbox_01', at = { x = -2.785, y = -3.763, z = 0, h = 20 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.415, y = 10.277, z = 5.1 }, look = { x = -0.985, y = -1.163, z = 1 }, fov = 42 },
                { pos = { x = 0.615, y = 3.237, z = 1.7 }, look = { x = -0.985, y = -1.163, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.095, y = 4.117, z = 1.8 }, look = { x = -0.985, y = -1.163, z = 1.45 }, fov = 38 },
                { pos = { x = 0.615, y = 3.237, z = 1.7 }, look = { x = -0.985, y = -1.163, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_gang_corner = {
    label = 'Köşe Başı',
    desc = 'Forum Drive · tezgah açık',
    role = 'gang',
    mode = 'single',
    anchor = { x = -306.363, y = -1637.716, z = 30.849, h = 140 },
    time = { h = 0, m = 30 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = -0.001, y = -0.001, z = 0, h = 25 }, act = { scenario = 'WORLD_HUMAN_DRUG_DEALER' } } } },
    extras = {
        {
            id = 'buyer',
            model = 'a_m_m_soucent_02',
            sex = 'm',
            at = { x = -0.973, y = 0.499, z = 0, h = 239 },
            act = { scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
        },
        { id = 'smoker', model = 'g_m_y_famca_01', sex = 'm', at = { x = -2.795, y = -1.099, z = 0, h = 20 }, act = { scenario = 'WORLD_HUMAN_SMOKING_POT' } },
        {
            id = 'lookout',
            model = 'g_m_y_famfor_01',
            sex = 'm',
            at = { x = -4.795, y = -0.499, z = 0, h = 135.385 },
            act = { scenario = 'WORLD_HUMAN_GUARD_STAND' },
        },
        {
            id = 'dog',
            model = 'a_c_rottweiler',
            sex = 'm',
            at = { x = 1.253, y = 0.138, z = -0.524, h = 30 },
            act = { dict = 'creatures@rottweiler@amb@world_dog_sitting@base', clip = 'base', flag = 1 },
        },
    },
    cars = { { model = 'buccaneer2', at = { x = -0.862, y = -1.817, z = 0, h = 100 }, doors = { 0, 5 }, engine = true, lights = true } },
    props = {
        { model = 'prop_cs_heist_bag_02', at = { x = 1.453, y = -1.011, z = 0.618, h = 33.554 }, collision = false },
        { model = 'prop_weed_block_01', at = { x = 1.49, y = -1.717, z = 0.52, h = 60 }, collision = false },
        { model = 'prop_boombox_01', at = { x = -3.495, y = -0.599, z = 0, h = 150 }, collision = false },
    },
    light = { color = { r = 255, g = 210, b = 160 }, intensity = 3, range = 12 },
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 3.805, y = 11.941, z = 5.2 }, look = { x = -2.595, y = 0.501, z = 1 }, fov = 42 },
                { pos = { x = -0.995, y = 4.901, z = 1.8 }, look = { x = -2.595, y = 0.501, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = -0.515, y = 5.781, z = 1.9 }, look = { x = -2.595, y = 0.501, z = 1.45 }, fov = 38 },
                { pos = { x = -0.995, y = 4.901, z = 1.8 }, look = { x = -2.595, y = 0.501, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_mech_engine = {
    label = 'Kaputun Altında',
    desc = 'LS Customs · Burton',
    role = 'mechanic',
    mode = 'single',
    anchor = { x = 1210.154, y = 2668.361, z = 36.81, h = 243.086 },
    time = { h = 17, m = 30 },
    weather = 'CLOUDS',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 180 },
                act = { dict = 'anim@amb@carmeet@checkout_engine@male_a@base', clip = 'base', flag = 1 },
                female = { dict = 'anim@amb@carmeet@checkout_engine@female_a@base', clip = 'base', flag = 1 },
                cam = { pos = { x = 2.053, y = 0.732, z = 0.918 }, look = { x = -5.509, y = -5.809, z = 1.061 }, fov = 42 },
            },
        },
    },
    extras = {
        {
            id = 'mech',
            model = 's_m_m_autoshop_01',
            sex = 'm',
            at = { x = 1.987, y = -1.823, z = 0, h = 75.062 },
            act = {
                dict = 'missfam4',
                clip = 'base',
                flag = 49,
                prop = { model = 'p_amb_clipboard_01', bone = 36029, pos = { x = 0.16, y = 0.08, z = 0.1 }, rot = { x = -130, y = -50, z = 0 } },
            },
        },
        {
            id = 'under',
            model = 's_m_y_xmech_01',
            sex = 'm',
            at = { x = -1.401, y = -2.617, z = 0, h = 85.247 },
            act = { scenario = 'WORLD_HUMAN_VEHICLE_MECHANIC' },
        },
        {
            id = 'customer',
            model = 'a_m_y_business_01',
            sex = 'm',
            at = { x = -2.185, y = -0.759, z = 0, h = 263.508 },
            act = { scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
        },
    },
    cars = {
        { model = 'Coquette', at = { x = 0, y = -2.6, z = 0, h = 0 }, doors = { 4 } },
        { model = 'towtruck2', at = { x = 4.4, y = -3.8, z = 0, h = 20 }, lights = true },
    },
    props = {
        { model = 'prop_tool_box_04', at = { x = -1.4, y = -1, z = 0, h = 30 }, collision = false },
        { model = 'prop_jerrycan_01a', at = { x = 1.2, y = -0.8, z = 0, h = 40 }, collision = false },
        { model = 'prop_carjack', at = { x = 1.196, y = -2.834, z = 0, h = 254.456 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = -6.4, y = 10.4, z = 5.2 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = -1.6, y = 4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = -2.08, y = 4.8, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = -1.6, y = 4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_mech_late = {
    label = 'Gece Vardiyası',
    desc = 'Hayes Auto · sabaha hazır olur',
    role = 'mechanic',
    mode = 'single',
    anchor = { x = 496.854, y = -1331.873, z = 29.2, h = 302.728 },
    time = { h = 22, m = 30 },
    weather = 'CLEAR',
    frame = 'center',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 94.95 },
                act = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer', flag = 1 },
                female = { dict = 'anim@amb@carmeet@checkout_engine@female_a@base', clip = 'base', flag = 1 },
                cam = { pos = { x = 0.7, y = -2.3, z = 0.5 }, look = { x = -0.8, y = -0.23, z = -0.3 }, fov = 40 },
            },
        },
    },
    extras = {
        {
            id = 'mechanic',
            model = 's_m_y_xmech_02',
            sex = 'm',
            at = { x = -2.852, y = -1.926, z = 0, h = 304.258 },
            act = { scenario = 'WORLD_HUMAN_WELDING' },
        },
    },
    cars = { { model = 'sultan', at = { x = -1.6, y = -1.452, z = 2.759, h = 179.596 }, doors = { 4 }, lights = true, wrecked = true } },
    props = {
        { model = 'prop_toolchest_05', at = { x = -0.475, y = 3.432, z = -0.16, h = 5.663 }, collision = false },
        { model = 'prop_carjack', at = { x = -0.199, y = -1.804, z = 0, h = 288.306 }, collision = false },
    },
    light = { color = { r = 255, g = 200, b = 150 }, intensity = 3.5, range = 12 },
    dof = { near = 1.2, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6000,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.853, y = -6.75, z = 4.2 }, look = { x = -1.647, y = -2.45, z = 1.2 }, fov = 42 },
                { pos = { x = 1.253, y = -2.85, z = 1.65 }, look = { x = -1.647, y = -2.45, z = 1.2 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.853, y = -3.25, z = 1.75 }, look = { x = -1.647, y = -2.45, z = 1.2 }, fov = 38 },
                { pos = { x = 1.253, y = -2.85, z = 1.65 }, look = { x = -1.647, y = -2.45, z = 1.2 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.05, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_mech_tow = {
    label = 'Yol Kenarı',
    desc = 'Sandy Shores · yine bozuldu',
    role = 'mechanic',
    mode = 'single',
    anchor = { x = 843.009, y = 61.797, z = 66, h = 319.08 },
    time = { h = 19, m = 0 },
    weather = 'EXTRASUNNY',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 34.008 },
                act = {
                    dict = 'missfam4',
                    clip = 'base',
                    flag = 49,
                    prop = { model = 'p_amb_clipboard_01', bone = 36029, pos = { x = 0.16, y = 0.08, z = 0.1 }, rot = { x = -130, y = -50, z = 0 } },
                },
            },
        },
    },
    extras = {
        {
            id = 'owner',
            model = 'a_f_y_bevhills_01',
            sex = 'f',
            at = { x = 0.681, y = 1.382, z = 0, h = 120 },
            act = {
                dict = 'cellphone@',
                clip = 'cellphone_call_listen_base',
                flag = 49,
                prop = { model = 'prop_npc_phone_02', bone = 28422, pos = { x = 0, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
        { id = 'friend', model = 'a_f_y_bevhills_02', sex = 'm', at = { x = 0.177, y = -8.183, z = 0, h = 30 }, act = { scenario = 'WORLD_HUMAN_SMOKING' } },
    },
    cars = {
        { model = 'towtruck', at = { x = 2.707, y = -0.266, z = 0, h = 0 }, engine = true, lights = true },
        { model = 'issi2', at = { x = 2.252, y = -6.194, z = -0.158, h = 354.685 }, doors = { 4 }, lights = true, smoke = true, tilt = 12 },
    },
    props = {
        { model = 'prop_roadcone02a', at = { x = 3.4, y = -9.8, z = 0, h = 0 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = 4, y = -11, z = 0, h = 0 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = 4.6, y = -12.2, z = 0, h = 0 }, collision = false },
        { model = 'prop_jerrycan_01a', at = { x = 0.9, y = -5.8, z = 0, h = 60 }, collision = false },
        { model = 'prop_tool_box_04', at = { x = 0.724, y = -3.646, z = 0, h = 20 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.876, y = 16.558, z = 5.2 }, look = { x = 1.276, y = 4.598, z = 1 }, fov = 42 },
                { pos = { x = 2.676, y = 9.198, z = 1.8 }, look = { x = 1.276, y = 4.598, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 3.096, y = 10.118, z = 1.9 }, look = { x = 1.276, y = 4.598, z = 1.45 }, fov = 38 },
                { pos = { x = 2.676, y = 9.198, z = 1.8 }, look = { x = 1.276, y = 4.598, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_pd_arrest = {
    label = 'Tutuklama',
    desc = 'Mission Row · dizlerinin üstünde',
    role = 'pd',
    mode = 'single',
    anchor = { x = -1214.11, y = -320.582, z = 36.762, h = 108.042 },
    time = { h = 13, m = 0 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0.001, z = 0, h = 48.386 }, act = { aim = 'suspect', weapon = 'WEAPON_PISTOL' } } } },
    extras = {
        {
            id = 'suspect',
            model = 'a_m_y_stbla_02',
            sex = 'm',
            at = { x = -3.405, y = 2.118, z = 0, h = 238.532 },
            act = { dict = 'random@arrests@busted', clip = 'idle_a', flag = 1 },
        },
        {
            id = 'npc2',
            model = 's_f_y_cop_01',
            sex = 'm',
            at = { x = -0.323, y = 3.315, z = 0, h = 110.643 },
            act = { aim = 'suspect', weapon = 'WEAPON_PISTOL' },
        },
        {
            id = 'npc2b',
            model = 's_f_y_cop_01',
            sex = 'm',
            at = { x = 2.282, y = -0.08, z = 0, h = 63.019 },
            act = { aim = 'suspect', weapon = 'WEAPON_CARBINERIFLE' },
        },
        {
            id = 'npc2bb',
            model = 's_f_y_cop_01',
            sex = 'm',
            at = { x = -0.218, y = -4.514, z = 0, h = 25.837 },
            act = { dict = 'random@arrests', clip = 'generic_radio_chatter', flag = 1 },
        },
        {
            id = 'npc2bbb',
            model = 's_f_y_cop_01',
            sex = 'm',
            at = { x = -4.82, y = 5.939, z = 0, h = 187.305 },
            act = { aim = 'suspect', ready = true, weapon = 'WEAPON_PUMPSHOTGUN' },
        },
    },
    cars = {
        { model = 'police3', at = { x = -0.188, y = -2.453, z = 0, h = 79.315 }, doors = { 0, 1 }, lights = true, siren = true },
        { model = 'police3', at = { x = -1.54, y = 5.784, z = 0, h = 132.124 }, doors = { 0, 1 }, lights = true, siren = true },
        { model = 'police3', at = { x = 5.414, y = -3.265, z = 0, h = 7.981 }, doors = { 0, 1 }, lights = true, siren = true },
    },
    props = {
        { model = 'prop_barrier_work05', at = { x = 4.228, y = 1.076, z = 0.052, h = 96.345 }, collision = false },
        { model = 'prop_barrier_work05', at = { x = 1.5, y = -5, z = 0, h = 10 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = 2.6, y = -1.407, z = 0, h = 0 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = 1.991, y = 3.2, z = 0, h = 0 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = -3, y = -3.6, z = 0, h = 0 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 7.195, y = 12.967, z = 5.1 }, look = { x = -0.005, y = 0.487, z = 1 }, fov = 42 },
                { pos = { x = 1.795, y = 5.287, z = 1.7 }, look = { x = -0.005, y = 0.487, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.335, y = 6.247, z = 1.8 }, look = { x = -0.005, y = 0.487, z = 1.45 }, fov = 38 },
                { pos = { x = 1.795, y = 5.287, z = 1.7 }, look = { x = -0.005, y = 0.487, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_pd_crime = {
    label = 'Olay Yeri',
    desc = 'Legion Square · şerit çekildi',
    role = 'pd',
    mode = 'single',
    anchor = { x = -301.52, y = -761.989, z = 52.247, h = 73.118 },
    time = { h = 23, m = 10 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 335.712 }, act = { scenario = 'CODE_HUMAN_POLICE_INVESTIGATE' } } } },
    extras = {
        {
            id = 'body',
            model = 'a_m_y_genstreet_01',
            sex = 'm',
            at = { x = -0.921, y = -2.34, z = 0, h = 108.336 },
            act = { dict = 'dead', clip = 'dead_a', flag = 1 },
        },
        {
            id = 'officer',
            model = 's_m_y_cop_01',
            sex = 'm',
            at = { x = -2.514, y = -3.57, z = 0, h = 324.159 },
            act = {
                dict = 'amb@medic@standing@timeofdeath@base',
                clip = 'base',
                flag = 1,
                prop = { model = 'prop_notepad_01', bone = 18905, pos = { x = 0.1, y = 0.02, z = 0.05 }, rot = { x = 10, y = 0, z = 0 } },
            },
            fill = 1,
        },
        {
            id = 'officerb',
            model = 's_m_y_cop_01',
            sex = 'm',
            at = { x = 0.9, y = -4.074, z = 0, h = 61.495 },
            act = { dict = 'anim@heists@heist_corona@team_idles@male_a', clip = 'idle', flag = 1 },
            fill = 2,
        },
    },
    cars = {
        { model = 'police3', at = { x = -4.191, y = -4.317, z = 0, h = 41.526 }, lights = true, siren = true },
        { model = 'police3', at = { x = 2.471, y = -4.993, z = 0, h = 316.431 }, lights = true, siren = true },
    },
    props = {
        { model = 'prop_barrier_work05', at = { x = -2.813, y = 1.514, z = 0, h = 28.16 }, collision = false },
        { model = 'prop_barrier_work05', at = { x = 2.147, y = -1.341, z = 0, h = 312.684 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = 0.306, y = -3.013, z = 0, h = 0 }, collision = false },
        { model = 'prop_barrier_work05', at = { x = -1.138, y = -6.498, z = 0, h = 6.689 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = -2.815, y = -1.816, z = 0, h = 0 }, collision = false },
    },
    light = { color = { r = 210, g = 225, b = 255 }, intensity = 4, range = 14 },
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.506, y = 12.347, z = 5.2 }, look = { x = -0.894, y = 0.387, z = 1 }, fov = 42 },
                { pos = { x = 0.706, y = 4.987, z = 1.8 }, look = { x = -0.894, y = 0.387, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.186, y = 5.907, z = 1.9 }, look = { x = -0.894, y = 0.387, z = 1.45 }, fov = 38 },
                { pos = { x = 0.706, y = 4.987, z = 1.8 }, look = { x = -0.894, y = 0.387, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_pd_evidence = {
    label = 'Delil',
    desc = 'Sandy Shores · kimse bir şey görmedi',
    role = 'pd',
    mode = 'single',
    anchor = { x = 1872.496, y = 3673.481, z = 33.7, h = 210 },
    time = { h = 1, m = 30 },
    weather = 'CLEAR',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 0 }, act = { scenario = 'WORLD_HUMAN_PAPARAZZI' } } } },
    extras = {
        {
            id = 'deputy',
            model = 's_m_y_sheriff_01',
            sex = 'm',
            at = { x = -1.8, y = 1.2, z = 0, h = 300 },
            act = {
                dict = 'missfam4',
                clip = 'base',
                flag = 49,
                prop = { model = 'p_amb_clipboard_01', bone = 36029, pos = { x = 0.16, y = 0.08, z = 0.1 }, rot = { x = -130, y = -50, z = 0 } },
            },
        },
        {
            id = 'deputyb',
            model = 's_m_y_sheriff_01',
            sex = 'm',
            at = { x = 1.247, y = -2.462, z = 0, h = 284.098 },
            act = { dict = 'random@arrests', clip = 'generic_radio_chatter', flag = 1 },
        },
        {
            id = 'deputybb',
            model = 'a_f_m_eastsa_02',
            sex = 'm',
            at = { x = 2.246, y = -2.844, z = 0, h = 79.854 },
            act = { dict = 'anim@amb@casino@brawl@fights@argue@', clip = 'arguement_loop_mp_m_brawler_01', flag = 1 },
        },
    },
    cars = {
        { model = 'emperor2', at = { x = 0.259, y = 3.621, z = 0, h = 75 }, doors = { 0 } },
        { model = 'sheriff', at = { x = -3.06, y = -2.708, z = 0, h = 49.431 }, lights = true, siren = true },
        { model = 'sheriff', at = { x = 2.755, y = -4.752, z = 0, h = 119.035 }, lights = true, siren = true },
    },
    props = {
        { model = 'prop_roadcone02a', at = { x = 1.8, y = 1.6, z = 0, h = 0 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = -1.4, y = 4.6, z = 0, h = 0 }, collision = false },
        { model = 'prop_barrier_work05', at = { x = 3.4, y = -0.6, z = 0, h = 46.757 }, collision = false },
        { model = 'prop_barrier_work05', at = { x = -3.987, y = 1.708, z = 0, h = 70.803 }, collision = false },
        { model = 'prop_roadcone02a', at = { x = -2.309, y = -1.572, z = 0, h = 0 }, collision = false },
    },
    light = { color = { r = 255, g = 220, b = 180 }, intensity = 3.5, range = 12 },
    dof = { near = 1, far = 2.4, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 6.4, y = 11.44, z = 5.2 }, look = { x = 0, y = 0, z = 1 }, fov = 42 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 2.08, y = 5.28, z = 1.9 }, look = { x = 0, y = 0, z = 1.45 }, fov = 38 },
                { pos = { x = 1.6, y = 4.4, z = 1.8 }, look = { x = 0, y = 0, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_pd_traffic = {
    label = 'Trafik Çevirmesi',
    desc = 'Paleto Blvd · ehliyet ve ruhsat lütfen',
    role = 'pd',
    mode = 'single',
    anchor = { x = -172.832, y = 6449.86, z = 31.92, h = 230.702 },
    time = { h = 9, m = 20 },
    weather = 'OVERCAST',
    setups = { solo = { { at = { x = 0, y = 0, z = 0, h = 309.864 }, act = { scenario = 'WORLD_HUMAN_CLIPBOARD' } } } },
    extras = {
        {
            id = 'driver',
            model = 'g_m_m_armboss_01',
            sex = 'm',
            at = { x = 1.111, y = -0.053, z = 0, h = 86.612 },
            act = { dict = 'anim@amb@casino@brawl@fights@argue@', clip = 'arguement_loop_mp_m_brawler_02', flag = 1 },
        },
        { id = 'partner', model = 's_m_y_cop_01', sex = 'm', at = { x = -2.985, y = 0.81, z = 0, h = 281.918 }, act = { scenario = 'WORLD_HUMAN_COP_IDLES' } },
    },
    cars = {
        { model = 'bodhi2', at = { x = 2.415, y = 2.44, z = 0, h = 209.834 } },
        { model = 'police', at = { x = -4.2, y = 2.543, z = 0, h = 354.387 }, lights = true, siren = true },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.181, y = 12.687, z = 5.2 }, look = { x = -0.419, y = 0.727, z = 1 }, fov = 42 },
                { pos = { x = 0.981, y = 5.327, z = 1.8 }, look = { x = -0.419, y = 0.727, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.401, y = 6.247, z = 1.9 }, look = { x = -0.419, y = 0.727, z = 1.45 }, fov = 38 },
                { pos = { x = 0.981, y = 5.327, z = 1.8 }, look = { x = -0.419, y = 0.727, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}

P.role_race_meet = {
    label = 'Araba Buluşması',
    desc = 'LSIA · mesai sonrası',
    role = 'civilian',
    mode = 'single',
    anchor = { x = 609.33, y = -1432.116, z = 8.746, h = 102.308 },
    time = { h = 22, m = 30 },
    weather = 'CLEAR',
    setups = {
        solo = {
            {
                at = { x = 0, y = 0, z = 0, h = 28.193 },
                act = { dict = 'amb@world_human_leaning@male@wall@back@foot_up@idle_a', clip = 'idle_a', flag = 1 },
                female = { dict = 'anim@amb@carmeet@checkout_car@female_a@base', clip = 'base', flag = 1 },
            },
        },
    },
    extras = {
        {
            id = 'fan',
            model = 'a_f_y_genhot_01',
            sex = 'm',
            at = { x = -3.754, y = 4.056, z = 0, h = 251.267 },
            act = { dict = 'anim@amb@carmeet@listen_music@male_a@base', clip = 'base', flag = 1 },
        },
        {
            id = 'fan2',
            model = 'ig_jimmydisanto',
            sex = 'f',
            at = { x = 5.53, y = 0.525, z = 0, h = 70.714 },
            act = { dict = 'anim@amb@carmeet@checkout_engine@female_a@base', clip = 'base', flag = 1 },
        },
        {
            id = 'photo',
            model = 'u_m_m_streetart_01',
            sex = 'm',
            at = { x = 1.264, y = 2.79, z = 0, h = 39.274 },
            act = { dict = 'anim@amb@carmeet@take_photos@male_a@base', clip = 'base', flag = 1 },
        },
        { id = 'smoker', model = 'a_f_y_juggalo_01', sex = 'm', at = { x = -5.293, y = -0.323, z = 0, h = 312.61 }, act = { scenario = 'WORLD_HUMAN_SMOKING' } },
        {
            id = 'texter',
            model = 'u_m_m_aldinapoli',
            sex = 'f',
            at = { x = 4.983, y = 1.73, z = 0, h = 203.988 },
            act = {
                dict = 'cellphone@',
                clip = 'cellphone_text_read_base',
                flag = 49,
                prop = { model = 'prop_npc_phone_02', bone = 28422, pos = { x = 0, y = 0, z = 0 }, rot = { x = 0, y = 0, z = 0 } },
            },
        },
    },
    cars = {
        { model = 'elegy', at = { x = -0.729, y = -1.157, z = 0, h = 90 }, doors = { 4 }, lights = true, tuned = true },
        { model = 'futo', at = { x = 4.509, y = -1.642, z = 0, h = 120 }, doors = { 4 }, lights = true, tuned = true },
        { model = 'jester', at = { x = 1.503, y = 4.532, z = 0, h = 60 }, doors = { 0, 1 }, lights = true, tuned = true },
        { model = 'zr350', at = { x = 6.801, y = 2.698, z = 0, h = 197.933 }, lights = true, tuned = true },
        { model = 'kuruma', at = { x = -5.371, y = 2.774, z = 0, h = 356.083 }, lights = true, tuned = true },
    },
    props = {
        { model = 'prop_boombox_01', at = { x = 1.671, y = 0.643, z = 0, h = 320 }, collision = false },
        { model = 'prop_tool_box_04', at = { x = 4.223, y = 0.211, z = 0, h = 30 }, collision = false },
    },
    light = false,
    dof = { near = 1, far = 2.6, strength = 0.8 },
    shots = {
        establish = {
            ms = 6500,
            ease = 'smooth',
            keys = {
                { pos = { x = 5.671, y = 12.683, z = 5.1 }, look = { x = -0.729, y = 1.243, z = 1 }, fov = 42 },
                { pos = { x = 0.871, y = 5.643, z = 1.7 }, look = { x = -0.729, y = 1.243, z = 1.45 }, fov = 36 },
            },
        },
        focus = {
            ms = 2600,
            ease = 'outCubic',
            keys = {
                { pos = { x = 1.351, y = 6.523, z = 1.8 }, look = { x = -0.729, y = 1.243, z = 1.45 }, fov = 38 },
                { pos = { x = 0.871, y = 5.643, z = 1.7 }, look = { x = -0.729, y = 1.243, z = 1.45 }, fov = 36 },
            },
        },
        move = { ms = 1400, arc = 0.25 },
        sway = { x = 0.06, z = 0.03, period = 9, yaw = 0.5 },
    },
}
