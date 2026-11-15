Config = {}

-- Healthy samples to compare crashes with: every client, every Every seconds, sends one with this chance.
-- 500 players, 600 s, 0.05 = about 150 samples an hour.
Config.Sample = { Every = 600, Chance = 0.05 }

-- What counts as "around": radius in metres.
Config.Near = { Players = 30.0, Crowd = 100.0, Vehicles = 30.0, Music = 30.0, Screens = 40.0 }

-- World objects that play media in the main UI or a DUI (wais-speaker boomboxes, wais-tv screens).
Config.Boombox = { 'qua_b_speaker_a', 'qua_b_speaker_b', 'qua_b_speaker_c', 'qua_b_speaker_d', 'qua_b_speaker_e', 'qua_b_speaker_f' }
Config.Screens = {
    'des_tvsmash_start', 'prop_flatscreen_overlay', 'prop_laptop_lester2', 'prop_monitor_w_large', 'prop_trev_tv_01',
    'prop_tv_01', 'prop_tv_02', 'prop_tv_03', 'prop_tv_03_overlay', 'prop_tv_06', 'prop_tv_flat_01', 'prop_tv_flat_01_screen',
    'prop_tv_flat_02', 'prop_tv_flat_02b', 'prop_tv_flat_03', 'prop_tv_flat_03b', 'prop_tv_flat_michael', 'v_ilev_cin_screen',
    'vw_prop_vw_cinema_tv_01',
}

-- Server: reports kept in memory for /uicrash, report files kept this many days (the Discord webhook is in config_sv.lua).
Config.Keep = { Crashes = 2000, Samples = 6000, Days = 7 }
