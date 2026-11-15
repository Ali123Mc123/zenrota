-- Arrival by coach: the coach pulls into the bus station, the doors open and the player steps off.
-- First-pass coordinates: calibrate in game with /mc_pose and /mc_point (Config.Debug). road = true snaps to the road.
do
    Cutscenes = Cutscenes or {}

    Cutscenes.bus = {
        title = 'cutscene.bus.title',
        ms = 21000,
        arrive = vec4(456.5, -622.0, 28.5, 90.0),
        stream = vec3(462.0, -618.0, 28.5),
        actors = {
            coach = { type = 'vehicle', model = 'coach', at = vec4(463.0, -560.0, 28.5, 180.0), road = true, driver = { model = 's_m_m_gentransport' } },
            me = { type = 'player', seat = { actor = 'coach', index = 0 } },
        },
        steps = {
            { t = 0, drive = { actor = 'coach', to = vec3(462.0, -618.0, 28.5), road = true, side = 1.5, speed = 9.0, stop = 2.5, timeout = 10000 } },
            { t = 0, follow = { actor = 'coach', from = vec3(455.0, -640.0, 30.3), look = vec3(0.0, 3.0, 1.0), fov = 40.0 } },
            { t = 1500, title = { key = 'cutscene.bus.title' } },
            { t = 9800, wait = { ['until'] = 'arrived:coach', timeout = 4000 } },
            { t = 10000, sound = { sfx = 'whoosh' } },
            { t = 10000, follow = { actor = 'coach', offset = vec3(5.5, 12.0, 1.7), look = vec3(1.3, 4.2, 0.9), fov = 40.0 } },
            { t = 10300, doors = { actor = 'coach', index = { 0, 1, 2, 3 }, open = true } },
            { t = 11000, leave = { ped = 'me', vehicle = 'coach' } },
            { t = 11500, subtitle = { key = 'cutscene.bus.line1', ms = 3500 } },
            { t = 13000, wait = { ['until'] = 'exited:me', timeout = 5000 } },
            { t = 13100, follow = { actor = 'me', from = 'camera', look = vec3(0.0, 0.0, 0.3), fov = 38.0 } },
            { t = 13200, walk = { ped = 'me', to = vec4(456.5, -622.0, 28.5, 90.0), speed = 1.0, timeout = 7000 } },
            { t = 14500, doors = { actor = 'coach', index = { 0, 1, 2, 3 }, open = false } },
            { t = 15000, drive = { actor = 'coach', ahead = 90.0, road = true, speed = 11.0, timeout = 6000, snap = false } },
            { t = 15500, subtitle = { key = 'cutscene.bus.line2', ms = 3000 } },
            { t = 19000, done = { blend = 1500 } },
        },
    }
end

-- Arrival by airliner: a jet on a spline approach over the sea onto the LSIA runway, then out of the terminal doors.
-- First-pass coordinates: calibrate in game with /mc_pose and /mc_point (Config.Debug). Path z is the wheel height.
do
    Cutscenes = Cutscenes or {}

    Cutscenes.plane = {
        title = 'cutscene.plane.title',
        ms = 25000,
        arrive = vec4(-1037.5, -2737.6, 20.17, 330.0),
        stream = vec3(-1726.3, -2819.2, 13.2),
        actors = {
            jet = { type = 'vehicle', model = 'jet', at = vec4(-2505.7, -2369.2, 61.0, 240.0), driver = { model = 's_m_m_pilot_01' }, frozen = true, gear = 0, lod = 3000 },
            me = { type = 'player', hidden = true },
        },
        steps = {
            { t = 0, path = { actor = 'jet', ms = 11000, ease = 'linear', pitch = 4.0, points = {
                vec3(-2505.7, -2369.2, 61.0), vec3(-2116.0, -2594.2, 37.6), vec3(-1830.2, -2759.2, 18.0), vec3(-1726.3, -2819.2, 13.2),
            } } },
            { t = 0, follow = { actor = 'jet', from = vec3(-2109.4, -2782.8, 18.0), look = vec3(0.0, 0.0, 0.0), fov = 42.0 } },
            { t = 1500, title = { key = 'cutscene.plane.title' } },
            { t = 5000, subtitle = { key = 'cutscene.plane.line1', ms = 3500 } },
            { t = 8500, sound = { sfx = 'whoosh' } },
            { t = 8500, follow = { actor = 'jet', from = vec3(-1644.8, -2918.2, 14.5), look = vec3(0.0, 0.0, 0.0), fov = 34.0 } },
            { t = 11000, path = { actor = 'jet', ms = 9000, ease = 'outQuad', pitch = 3.0, pitchTo = 0.0, points = {
                vec3(-1726.3, -2819.2, 13.2), vec3(-1553.1, -2919.2, 13.2), vec3(-1397.2, -3009.2, 13.2),
            } } },
            { t = 14000, focus = { at = vec3(-1037.5, -2737.6, 20.17) } },
            { t = 15500, fade = { out = 600 } },
            { t = 16200, place = { actor = 'me', at = vec4(-1041.0, -2743.7, 20.17, 330.0), visible = true } },
            { t = 16200, prop = { ped = 'me', model = 'prop_ld_suitcase_01', bone = 57005, offset = vec3(0.36, 0.0, -0.02), rot = vec3(0.0, 266.0, 80.0) } },
            { t = 16300, follow = { actor = 'me', from = vec3(-1033.7, -2734.6, 20.9), look = vec3(0.0, 0.0, 0.3), fov = 38.0 } },
            { t = 16900, fade = { ['in'] = 700 } },
            { t = 17000, walk = { ped = 'me', to = vec4(-1037.5, -2737.6, 20.17, 330.0), speed = 1.0, timeout = 8000 } },
            { t = 18000, subtitle = { key = 'cutscene.plane.line2', ms = 3500 } },
            { t = 23000, done = { blend = 1500 } },
        },
    }
end

-- Arrival by cab: the player rides in the back of a taxi downtown, gets out and the cab drives away.
-- First-pass coordinates: calibrate in game with /mc_pose and /mc_point (Config.Debug). road = true snaps to the road.
do
    Cutscenes = Cutscenes or {}

    Cutscenes.taxi = {
        title = 'cutscene.taxi.title',
        ms = 19000,
        arrive = vec4(195.17, -933.77, 30.69, 144.0),
        stream = vec3(195.17, -933.77, 30.69),
        actors = {
            cab = { type = 'vehicle', model = 'taxi', at = vec4(100.0, -1020.0, 29.3, 340.0), road = true, driver = { model = 'a_m_y_stlat_01' } },
            me = { type = 'player', seat = { actor = 'cab', index = 2 } },
        },
        steps = {
            { t = 0, drive = { actor = 'cab', to = vec3(195.17, -933.77, 30.69), road = true, side = 2.0, speed = 12.0, stop = 2.0, timeout = 9000 } },
            { t = 0, follow = { actor = 'cab', offset = vec3(2.2, -7.5, 2.2), look = vec3(0.0, 3.0, 0.6), fov = 45.0 } },
            { t = 1200, title = { key = 'cutscene.taxi.title' } },
            { t = 4800, sound = { sfx = 'whoosh' } },
            { t = 4800, follow = { actor = 'cab', offset = vec3(2.9, 0.4, 1.2), look = vec3(0.4, -0.7, 0.8), fov = 40.0 } },
            { t = 5400, subtitle = { key = 'cutscene.taxi.line1', ms = 3000 } },
            { t = 8800, wait = { ['until'] = 'arrived:cab', timeout = 4000 } },
            { t = 9000, follow = { actor = 'cab', offset = vec3(5.0, 3.5, 1.5), look = vec3(1.1, -0.8, 0.9), fov = 38.0 } },
            { t = 9300, leave = { ped = 'me', vehicle = 'cab' } },
            { t = 9800, subtitle = { key = 'cutscene.taxi.line2', ms = 3000 } },
            { t = 11500, wait = { ['until'] = 'exited:me', timeout = 5000 } },
            { t = 11600, follow = { actor = 'me', from = 'camera', look = vec3(0.0, 0.0, 0.3), fov = 38.0 } },
            { t = 11700, walk = { ped = 'me', to = vec4(195.17, -933.77, 30.69, 144.0), speed = 1.0, timeout = 6000 } },
            { t = 12500, drive = { actor = 'cab', ahead = 80.0, road = true, speed = 13.0, timeout = 6000, snap = false } },
            { t = 16500, done = { blend = 1500 } },
        },
    }
end

-- DaddyRP: arrival by light aircraft at the Sandy Shores airfield. A Cuban 800 comes in over the desert along the runway
-- line (heading ~285) and is faded out while still airborne (58 m at its lowest), so the touchdown is never shown and a
-- guessed path cannot meet the ground; both shots ride on the plane. The player then walks the last steps to arrive.
-- First-pass coordinates: calibrate in game with /mc_pose and /mc_point (Config.Debug).
do
    Cutscenes = Cutscenes or {}

    Cutscenes.sandy = {
        title = 'cutscene.sandy.title',
        ms = 20000,
        arrive = vec4(1693.0242, 3300.9121, 41.5671, 105.7606),
        stream = vec3(1450.0, 3170.0, 41.0),
        actors = {
            plane = { type = 'vehicle', model = 'cuban800', at = vec4(700.0, 2962.0, 220.0, 285.0), driver = { model = 's_m_m_pilot_01' }, frozen = true, gear = 0, lod = 3000 },
            me = { type = 'player', hidden = true },
        },
        steps = {
            { t = 0, path = { actor = 'plane', ms = 13000, ease = 'linear', pitch = 3.0, pitchTo = 1.0, points = {
                vec3(700.0, 2962.0, 220.0), vec3(1000.0, 3045.0, 150.0), vec3(1250.0, 3114.0, 100.0), vec3(1450.0, 3169.0, 70.0), vec3(1560.0, 3199.0, 58.0),
            } } },
            { t = 0, follow = { actor = 'plane', offset = vec3(-10.0, -22.0, 5.0), look = vec3(0.0, 8.0, 0.0), fov = 45.0 } },
            { t = 1500, title = { key = 'cutscene.sandy.title' } },
            { t = 4500, subtitle = { key = 'cutscene.sandy.line1', ms = 3500 } },
            { t = 6500, sound = { sfx = 'whoosh' } },
            { t = 6500, follow = { actor = 'plane', offset = vec3(14.0, 18.0, -2.0), look = vec3(0.0, 0.0, 0.0), fov = 38.0 } },
            { t = 11000, fade = { out = 600 } },
            { t = 11700, place = { actor = 'me', at = vec4(1696.3926, 3301.8628, 41.5671, 105.7606), visible = true } },
            { t = 11700, prop = { ped = 'me', model = 'prop_ld_suitcase_01', bone = 57005, offset = vec3(0.36, 0.0, -0.02), rot = vec3(0.0, 266.0, 80.0) } },
            { t = 11800, follow = { actor = 'me', offset = vec3(1.6, 3.4, 0.6), look = vec3(0.0, 0.0, 0.3), fov = 38.0 } },
            { t = 12400, fade = { ['in'] = 700 } },
            { t = 12500, walk = { ped = 'me', to = vec4(1693.0242, 3300.9121, 41.5671, 105.7606), speed = 1.0, timeout = 6000 } },
            { t = 13500, subtitle = { key = 'cutscene.sandy.line2', ms = 3500 } },
            { t = 18000, done = { blend = 1500 } },
        },
    }
end
