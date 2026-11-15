Config = {}
Config.Framework = {
    ["Framework"] = "auto", -- [[LEAVE AUTO]] auto, esx, qbcore or qbox
    ["ResourceName"] = "auto", -- [[LEAVE AUTO]] auto, es_extended or qb-core or your resource name. If you using qbx you should write qb-core
    ["SharedEvent"] = "" -- Event name for old cores.
}

Config.Language = "tr" -- ar, cz, ro, it, fr, de, tr
Config.ShowDebug = false -- Show debug messages
Config.AdminMenu = {
    ["command"] = "tvadmin", -- Command to open the admin menu
    ["ace"] = "group.admin" -- ACE permission for the admin menu
}
Config.TvCommand = {
    ["command"] = "tv", -- This allows you to open the menu on your TV.
    ["suggestion"] = "Bu komut ile yakındaki TV'yi açıp kapayabilirsin" -- Command suggestion for the tv command
}
Config.DeleteTvWhenOwnerQuit = false --[[
    ⚠️⚠️⚠️
    Its recommended to keep it true, if you set it to false, when the owner of the TV leaves the game, 
    the TV will remain in the world and other players can use it. 
    
    If you set it to true, when the owner of the TV leaves the game,
     the TV will be deleted from the world.
]]
Config.SyncCheck = true --[[
    ⚠️⚠️⚠️
    This variable belongs to the code structure that checks whether the video is progressing as it should, in sync with other people.
    The reasons I use this are as follows:
        - When the game is minimized, the CPU freezes all game-related processes for a certain number of seconds or minutes. 
            > This suspends the game's processes. When the player returns to the game, they will hear the videos behind schedule by the duration of the freeze compared to other players. 
        - Players experiencing occasional freezes or lag will hear the video delayed by the duration of the game's lag. 
    This way, the remaining users will move back to the current second.
    
    
    💢💢💢
    If you set it to `false`, when these conditions occur, the user's video will lag behind the others (by the amount of time it freezes or stutters). 
    Therefore, it will not be synchronized, and when the video ends at the expected second, it will suddenly cut off. 
]]

Config.UsableItems = {
    --[[
        DISTANCE (per item): how far away (in meters) the TV can be seen, heard and controlled from.
        The number after "max:" is the game's own render distance of that prop, going higher than that makes no sense.
        Lower it if you want the sound to fade out closer to the TV. It also applies to the default / static TVs placed from the admin menu.
    ]]
    ["tv_crt_classic"] = {
        ["model"] = "prop_tv_01",
        ["screen"] = "tvscreen",
        ["label"] = "Klasik CRT Televizyon [12m]",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_crt_old"] = {
        ["model"] = "prop_tv_03",
        ["screen"] = "tvscreen",
        ["label"] = "Eski CRT Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_crt_wood"] = {
        ["model"] = "prop_tv_06",
        ["screen"] = "tvscreen",
        ["label"] = "Ahşap CRT Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_small"] = {
        ["model"] = "prop_tv_flat_03b",
        ["screen"] = "tvscreen",
        ["label"] = "Küçük Düz Ekran Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_cinema"] = {
        ["model"] = "vw_prop_vw_cinema_tv_01",
        ["screen"] = "tvscreen",
        ["build"] = 1604,
        ["label"] = "Sinema Televizyonu [15m]",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_smash"] = {
        ["model"] = "des_tvsmash_start",
        ["screen"] = "tvscreen",
        ["label"] = "Kırık Televizyon [15m]",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_flat_overlay"] = {
        ["model"] = "prop_flatscreen_overlay",
        ["screen"] = "tvscreen",
        ["label"] = "Düz Ekran Overlay Televizyon [12m]",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_laptop"] = {
        ["model"] = "prop_laptop_lester2",
        ["screen"] = "tvscreen",
        ["label"] = "Laptop Ekranı [12m]",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_trevor"] = {
        ["model"] = "prop_trev_tv_01",
        ["screen"] = "tvscreen",
        ["label"] = "Trevor Televizyonu [14m]",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_vintage"] = {
        ["model"] = "prop_tv_02",
        ["screen"] = "tvscreen",
        ["label"] = "Vintage Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_crt_overlay"] = {
        ["model"] = "prop_tv_03_overlay",
        ["screen"] = "tvscreen",
        ["label"] = "CRT Overlay Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_classic"] = {
        ["model"] = "prop_tv_flat_01",
        ["screen"] = "tvscreen",
        ["label"] = "Klasik Düz Ekran Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_screen"] = {
        ["model"] = "prop_tv_flat_01_screen",
        ["screen"] = "tvscreen",
        ["label"] = "Düz Ekran Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_medium"] = {
        ["model"] = "prop_tv_flat_02",
        ["screen"] = "tvscreen",
        ["label"] = "Orta Boy Düz Ekran Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_medium2"] = {
        ["model"] = "prop_tv_flat_02b",
        ["screen"] = "tvscreen",
        ["label"] = "Orta Boy Düz Ekran Televizyon 2 [12m]",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_flat_modern"] = {
        ["model"] = "prop_tv_flat_03",
        ["screen"] = "tvscreen",
        ["label"] = "Modern Düz Ekran Televizyon [11m]",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_flat_premium"] = {
        ["model"] = "prop_tv_flat_michael",
        ["screen"] = "tvscreen",
        ["label"] = "Premium Düz Ekran Televizyon [13m]",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_monitor_large"] = {
        ["model"] = "prop_monitor_w_large",
        ["screen"] = "tvscreen",
        ["label"] = "Büyük Monitör [13m]",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_cinema_big"] = {
        ["model"] = "v_ilev_cin_screen",
        ["screen"] = "cinscreen",
        ["label"] = "Büyük Sinema Ekranı [12m]",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_apa_mp_h_str_avunitl_01_b"] = {
        ["model"] = "apa_mp_h_str_avunitl_01_b",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunitl 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_apa_mp_h_str_avunitl_04"] = {
        ["model"] = "apa_mp_h_str_avunitl_04",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunitl 04",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_apa_mp_h_str_avunitm_01"] = {
        ["model"] = "apa_mp_h_str_avunitm_01",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunitm 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_apa_mp_h_str_avunitm_03"] = {
        ["model"] = "apa_mp_h_str_avunitm_03",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunitm 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_apa_mp_h_str_avunits_01"] = {
        ["model"] = "apa_mp_h_str_avunits_01",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunits 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_apa_mp_h_str_avunits_04"] = {
        ["model"] = "apa_mp_h_str_avunits_04",
        ["screen"] = "tvscreen",
        ["label"] = "Apartment Avunits 04",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_ba_battle_club_computer_01"] = {
        ["model"] = "ba_prop_battle_club_computer_01",
        ["screen"] = "club_computer",
        ["label"] = "Nightclub Battle Club Computer 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_ba_battle_club_computer_02"] = {
        ["model"] = "ba_prop_battle_club_computer_02",
        ["screen"] = "club_computer_02",
        ["label"] = "Nightclub Battle Club Computer 02",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_ba_battle_club_screen"] = {
        ["model"] = "ba_prop_battle_club_screen",
        ["screen"] = "Club_Projector",
        ["label"] = "Nightclub Battle Club Screen",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ba_battle_club_screen_02"] = {
        ["model"] = "ba_prop_battle_club_screen_02",
        ["screen"] = "Club_TV",
        ["label"] = "Nightclub Battle Club Screen 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ba_battle_club_screen_03"] = {
        ["model"] = "ba_prop_battle_club_screen_03",
        ["screen"] = "Club_TV",
        ["label"] = "Nightclub Battle Club Screen 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ba_battle_pbus_screen"] = {
        ["model"] = "ba_prop_battle_pbus_screen",
        ["screen"] = "pbus_screen",
        ["label"] = "Nightclub Battle PBUS Screen",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ba_club_laptop_dj"] = {
        ["model"] = "ba_prop_club_laptop_dj",
        ["screen"] = "laptop_dj",
        ["label"] = "Nightclub Club Laptop DJ",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_ba_club_laptop_dj_02"] = {
        ["model"] = "ba_prop_club_laptop_dj_02",
        ["screen"] = "laptop_dj_02",
        ["label"] = "Nightclub Club Laptop DJ 02",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_ba_club_screens_01"] = {
        ["model"] = "ba_prop_club_screens_01",
        ["screen"] = "Club_Projector",
        ["label"] = "Nightclub Club Screens 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ba_club_screens_02"] = {
        ["model"] = "ba_prop_club_screens_02",
        ["screen"] = "Club_Projector",
        ["label"] = "Nightclub Club Screens 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_bkr_clubhouse_laptop_01a"] = {
        ["model"] = "bkr_prop_clubhouse_laptop_01a",
        ["screen"] = "prop_clubhouse_laptop_01a",
        ["label"] = "Biker Clubhouse Laptop 01A",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_bkr_clubhouse_laptop_01b"] = {
        ["model"] = "bkr_prop_clubhouse_laptop_01b",
        ["screen"] = "prop_clubhouse_laptop_square_01a",
        ["label"] = "Biker Clubhouse Laptop 01B",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_ch_casino_videowall"] = {
        ["model"] = "ch_prop_casino_videowall",
        ["screen"] = "casinoscreen_01",
        ["build"] = 1604,
        ["label"] = "Casino Videowall",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_ch_tv_rt_01a"] = {
        ["model"] = "ch_prop_ch_tv_rt_01a",
        ["screen"] = "ch_tv_rt_01a",
        ["build"] = 1604,
        ["label"] = "Casino TV Rt 01A",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_ex_tv_flat_01"] = {
        ["model"] = "ex_prop_ex_tv_flat_01",
        ["screen"] = "ex_tvscreen",
        ["label"] = "Executive TV Flat 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_ex_monitor_01_ex"] = {
        ["model"] = "ex_prop_monitor_01_ex",
        ["screen"] = "prop_ex_computer_screen",
        ["label"] = "Executive Monitor 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_gr_laptop_01a"] = {
        ["model"] = "gr_prop_gr_laptop_01a",
        ["screen"] = "gr_bunker_laptop_01a",
        ["label"] = "Bunker Laptop 01A",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_gr_laptop_01b"] = {
        ["model"] = "gr_prop_gr_laptop_01b",
        ["screen"] = "gr_bunker_laptop_sq_01a",
        ["label"] = "Bunker Laptop 01B",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_gr_trailer_monitor_01"] = {
        ["model"] = "gr_prop_gr_trailer_monitor_01",
        ["screen"] = "gr_trailer_monitor_01",
        ["label"] = "Bunker Trailer Monitor 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_gr_trailer_monitor_02"] = {
        ["model"] = "gr_prop_gr_trailer_monitor_02",
        ["screen"] = "gr_trailer_monitor_02",
        ["label"] = "Bunker Trailer Monitor 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_gr_trailer_monitor_03"] = {
        ["model"] = "gr_prop_gr_trailer_monitor_03",
        ["screen"] = "gr_trailer_monitor_03",
        ["label"] = "Bunker Trailer Monitor 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_gr_trailer_tv"] = {
        ["model"] = "gr_prop_gr_trailer_tv",
        ["screen"] = "gr_trailertv_01",
        ["label"] = "Bunker Trailer TV",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_gr_trailer_tv_02"] = {
        ["model"] = "gr_prop_gr_trailer_tv_02",
        ["screen"] = "gr_trailertv_02",
        ["label"] = "Bunker Trailer TV 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_h4_battle_club_computer_01"] = {
        ["model"] = "h4_prop_battle_club_computer_01",
        ["screen"] = "club_computer",
        ["build"] = 2189,
        ["label"] = "Island Battle Club Computer 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_h4_battle_club_computer_02"] = {
        ["model"] = "h4_prop_battle_club_computer_02",
        ["screen"] = "club_computer_02",
        ["build"] = 2189,
        ["label"] = "Island Battle Club Computer 02",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_h4_battle_club_screen"] = {
        ["model"] = "h4_prop_battle_club_screen",
        ["screen"] = "club_projector",
        ["build"] = 2189,
        ["label"] = "Island Battle Club Screen",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_h4_battle_club_screen_02"] = {
        ["model"] = "h4_prop_battle_club_screen_02",
        ["screen"] = "Club_TV",
        ["build"] = 2189,
        ["label"] = "Island Battle Club Screen 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_h4_battle_club_screen_03"] = {
        ["model"] = "h4_prop_battle_club_screen_03",
        ["screen"] = "Club_TV",
        ["build"] = 2189,
        ["label"] = "Island Battle Club Screen 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_h4_club_laptop_dj"] = {
        ["model"] = "h4_prop_club_laptop_dj",
        ["screen"] = "laptop_dj",
        ["build"] = 2189,
        ["label"] = "Island Club Laptop DJ",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_h4_club_laptop_dj_02"] = {
        ["model"] = "h4_prop_club_laptop_dj_02",
        ["screen"] = "laptop_dj_02",
        ["build"] = 2189,
        ["label"] = "Island Club Laptop DJ 02",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_h4_club_screens_01"] = {
        ["model"] = "h4_prop_club_screens_01",
        ["screen"] = "club_projector",
        ["build"] = 2189,
        ["label"] = "Island Club Screens 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_h4_club_screens_02"] = {
        ["model"] = "h4_prop_club_screens_02",
        ["screen"] = "club_projector",
        ["build"] = 2189,
        ["label"] = "Island Club Screens 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_hei_bank_heist_laptop"] = {
        ["model"] = "hei_bank_heist_laptop",
        ["screen"] = "tvscreen",
        ["label"] = "Heist Bank Heist Laptop",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_hei_heist_str_avunitl_03"] = {
        ["model"] = "hei_heist_str_avunitl_03",
        ["screen"] = "tvscreen",
        ["label"] = "Heist Avunitl 03",
        ["distance"] = 13.0 -- max: 50
    },
    ["tv_hei_dlc_tablet"] = {
        ["model"] = "hei_prop_dlc_tablet",
        ["screen"] = "tablet",
        ["label"] = "Heist Dlc Tablet",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_hei_monitor_overlay"] = {
        ["model"] = "hei_prop_hei_monitor_overlay",
        ["screen"] = "hei_mon",
        ["label"] = "Heist Monitor Overlay",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_hei_hst_laptop"] = {
        ["model"] = "hei_prop_hst_laptop",
        ["screen"] = "tvscreen",
        ["label"] = "Heist Hst Laptop",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_imp_impexp_lappy_01a"] = {
        ["model"] = "imp_prop_impexp_lappy_01a",
        ["screen"] = "prop_impexp_lappy_01a",
        ["label"] = "Import Impexp Lappy 01A",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_m31_screen_rt_01a"] = {
        ["model"] = "m23_1_prop_m31_screen_rt_01a",
        ["screen"] = "m31_screen_rt_01a",
        ["build"] = 2944,
        ["label"] = "Mission M31 Screen Rt 01A",
        ["distance"] = 17.0 -- max: 150
    },
    ["tv_m31_screen_rt_01b"] = {
        ["model"] = "m23_1_prop_m31_screen_rt_01b",
        ["screen"] = "m31_screen_rt_01b",
        ["build"] = 2944,
        ["label"] = "Mission M31 Screen Rt 01B",
        ["distance"] = 17.0 -- max: 150
    },
    ["tv_m31_screen_rt_01c"] = {
        ["model"] = "m23_1_prop_m31_screen_rt_01c",
        ["screen"] = "m31_screen_rt_01c",
        ["build"] = 2944,
        ["label"] = "Mission M31 Screen Rt 01C",
        ["distance"] = 17.0 -- max: 150
    },
    ["tv_m31_screen_rt_01d"] = {
        ["model"] = "m23_1_prop_m31_screen_rt_01d",
        ["screen"] = "m31_screen_rt_01d",
        ["build"] = 2944,
        ["label"] = "Mission M31 Screen Rt 01D",
        ["distance"] = 17.0 -- max: 150
    },
    ["tv_m32_crt_mon_01a"] = {
        ["model"] = "m23_2_prop_m32_crt_mon_01a",
        ["screen"] = "m32_crtscreen_01a",
        ["build"] = 3095,
        ["label"] = "Mission M32 CRT Mon 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_m32_desktop_01a"] = {
        ["model"] = "m23_2_prop_m32_desktop_01a",
        ["screen"] = "m32_desktop_01a",
        ["build"] = 3095,
        ["label"] = "Mission M32 Desktop 01A",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_m41_monitor_01a"] = {
        ["model"] = "m24_1_prop_m41_monitor_01a",
        ["screen"] = "prop_m41_monitor_01a",
        ["build"] = 3258,
        ["label"] = "Mission M41 Monitor 01A",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_m42_monitor_w_large"] = {
        ["model"] = "m24_2_prop_m42_monitor_w_large",
        ["screen"] = "tvscreen",
        ["build"] = 3407,
        ["label"] = "Mission M42 Monitor W Large",
        ["distance"] = 19.0 -- max: 300
    },
    ["tv_m42_rt_screen"] = {
        ["model"] = "m24_2_prop_m42_rt_screen",
        ["screen"] = "m242_screen_02x",
        ["build"] = 3407,
        ["label"] = "Mission M42 Rt Screen",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_m51_laptop_01a"] = {
        ["model"] = "m25_1_prop_m51_laptop_01a",
        ["screen"] = "m51_laptop_01a",
        ["build"] = 3570,
        ["label"] = "Mission M51 Laptop 01A",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_m51_laptop_01b"] = {
        ["model"] = "m25_1_prop_m51_laptop_01b",
        ["screen"] = "m51_laptop_01b",
        ["build"] = 3570,
        ["label"] = "Mission M51 Laptop 01B",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_m51_laptop_01c"] = {
        ["model"] = "m25_1_prop_m51_laptop_01c",
        ["screen"] = "m51_laptop_01c",
        ["build"] = 3570,
        ["label"] = "Mission M51 Laptop 01C",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_m51_monitor_w_large"] = {
        ["model"] = "m25_1_prop_m51_monitor_w_large",
        ["screen"] = "m51_monitor_w_large",
        ["build"] = 3570,
        ["label"] = "Mission M51 Monitor W Large",
        ["distance"] = 19.0 -- max: 300
    },
    ["tv_m52_mansioncinescreen"] = {
        ["model"] = "m25_2_prop_m52_mansioncinescreen",
        ["screen"] = "prop_m52_cinescreen",
        ["build"] = 3751,
        ["label"] = "Mission M52 Mansioncinescreen",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_m52_mansiontv"] = {
        ["model"] = "m25_2_prop_m52_mansiontv",
        ["screen"] = "prop_m52_mansiontv",
        ["build"] = 3751,
        ["label"] = "Mission M52 Mansiontv",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_m52_monitor_01a"] = {
        ["model"] = "m25_2_prop_m52_monitor_01a",
        ["screen"] = "prop_m52_monitor_01a",
        ["build"] = 3751,
        ["label"] = "Mission M52 Monitor 01A",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_m61_desktop_01a"] = {
        ["model"] = "m26_1_prop_m61_desktop_01a",
        ["screen"] = "prop_m61_desktop_01a",
        ["build"] = 3889,
        ["label"] = "Mission M61 Desktop 01A",
        ["distance"] = 19.0 -- max: 300
    },
    ["tv_p_laptop_02_s"] = {
        ["model"] = "p_laptop_02_s",
        ["screen"] = "tvscreen",
        ["label"] = "P Laptop 02 S",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_big_cin_screen"] = {
        ["model"] = "prop_big_cin_screen",
        ["screen"] = "cinscreen",
        ["label"] = "Big Cin Screen",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_cs_tv_stand"] = {
        ["model"] = "prop_cs_tv_stand",
        ["screen"] = "tvscreen",
        ["label"] = "Cs TV Stand",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_huge_display_01"] = {
        ["model"] = "prop_huge_display_01",
        ["screen"] = "Big_Disp",
        ["label"] = "Huge Display 01",
        ["distance"] = 18.0 -- max: 249
    },
    ["tv_huge_display_02"] = {
        ["model"] = "prop_huge_display_02",
        ["screen"] = "Big_Disp",
        ["label"] = "Huge Display 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_monitor_01b"] = {
        ["model"] = "prop_monitor_01b",
        ["screen"] = "tvscreen",
        ["label"] = "Monitor 01B",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_monitor_02"] = {
        ["model"] = "prop_monitor_02",
        ["screen"] = "tvscreen",
        ["label"] = "Monitor 02",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_projector_overlay"] = {
        ["model"] = "prop_projector_overlay",
        ["screen"] = "big_disp2",
        ["label"] = "Projector Overlay",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_04"] = {
        ["model"] = "prop_tv_04",
        ["screen"] = "tvscreen",
        ["label"] = "TV 04",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_test"] = {
        ["model"] = "prop_tv_test",
        ["screen"] = "tvscreen",
        ["label"] = "TV Test",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_sf_engineer_screen_01a"] = {
        ["model"] = "sf_prop_sf_engineer_screen_01a",
        ["screen"] = "engineerscreen",
        ["build"] = 2545,
        ["label"] = "Studio Engineer Screen 01A",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_sf_monitor_b_02b"] = {
        ["model"] = "sf_prop_sf_monitor_b_02b",
        ["screen"] = "monitor_b_02b",
        ["build"] = 2545,
        ["label"] = "Studio Monitor 02B",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_sf_monitor_stu_01a"] = {
        ["model"] = "sf_prop_sf_monitor_stu_01a",
        ["screen"] = "monitor_stu_01a",
        ["build"] = 2545,
        ["label"] = "Studio Monitor Stu 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_sf_s_scrn_01a"] = {
        ["model"] = "sf_prop_sf_s_scrn_01a",
        ["screen"] = "s_scrn_01a",
        ["build"] = 2545,
        ["label"] = "Studio S Scrn 01A",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_sf_scr_m_lrg_01a"] = {
        ["model"] = "sf_prop_sf_scr_m_lrg_01a",
        ["screen"] = "scr_m_lrg_01a",
        ["build"] = 2545,
        ["label"] = "Studio SCR M Lrg 01A",
        ["distance"] = 13.0 -- max: 50
    },
    ["tv_sf_scr_m_lrg_01b"] = {
        ["model"] = "sf_prop_sf_scr_m_lrg_01b",
        ["screen"] = "scr_m_lrg_01b",
        ["build"] = 2545,
        ["label"] = "Studio SCR M Lrg 01B",
        ["distance"] = 13.0 -- max: 50
    },
    ["tv_sf_scr_m_lrg_01c"] = {
        ["model"] = "sf_prop_sf_scr_m_lrg_01c",
        ["screen"] = "scr_m_lrg_01c",
        ["build"] = 2545,
        ["label"] = "Studio SCR M Lrg 01C",
        ["distance"] = 13.0 -- max: 50
    },
    ["tv_sf_scrn_ppp_01a"] = {
        ["model"] = "sf_prop_sf_scrn_ppp_01a",
        ["screen"] = "scrn_ppp_01a",
        ["build"] = 2545,
        ["label"] = "Studio Scrn PPP 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_sf_scrn_tr_01a"] = {
        ["model"] = "sf_prop_sf_scrn_tr_01a",
        ["screen"] = "scrn_tr_01a",
        ["build"] = 2545,
        ["label"] = "Studio Scrn 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_sf_tv_flat_scr_01a"] = {
        ["model"] = "sf_prop_sf_tv_flat_scr_01a",
        ["screen"] = "tv_flat_scr_01a",
        ["build"] = 2545,
        ["label"] = "Studio TV Flat SCR 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_sm_smug_monitor_01"] = {
        ["model"] = "sm_prop_smug_monitor_01",
        ["screen"] = "smug_monitor_01",
        ["label"] = "Smuggler Smug Monitor 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_sm_smug_tv_flat_01"] = {
        ["model"] = "sm_prop_smug_tv_flat_01",
        ["screen"] = "tv_flat_01",
        ["label"] = "Smuggler Smug TV Flat 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_tr_laptop_jimmy"] = {
        ["model"] = "tr_prop_tr_laptop_jimmy",
        ["screen"] = "prop_tr_laptop_jimmy",
        ["build"] = 2372,
        ["label"] = "Tuner Laptop Jimmy",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_tr_monitor_01a"] = {
        ["model"] = "tr_prop_tr_monitor_01a",
        ["screen"] = "prop_tr_monitor_01a",
        ["build"] = 2372,
        ["label"] = "Tuner Monitor 01A",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_tr_monitor_01b"] = {
        ["model"] = "tr_prop_tr_monitor_01b",
        ["screen"] = "prop_tr_monitor_01b",
        ["build"] = 2372,
        ["label"] = "Tuner Monitor 01B",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_v_lest_bigscreen"] = {
        ["model"] = "v_ilev_lest_bigscreen",
        ["screen"] = "tvscreen",
        ["label"] = "V Lest Bigscreen",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_v_mm_screen"] = {
        ["model"] = "v_ilev_mm_screen",
        ["screen"] = "big_disp",
        ["label"] = "V Mm Screen",
        ["distance"] = 10.0 -- max: 15
    },
    ["tv_v_mm_screen2"] = {
        ["model"] = "v_ilev_mm_screen2",
        ["screen"] = "tvscreen",
        ["label"] = "V Mm Screen2",
        ["distance"] = 10.0 -- max: 15
    },
    ["tv_vw_monitor_01"] = {
        ["model"] = "vw_prop_vw_monitor_01",
        ["screen"] = "prop_ex_computer_screen",
        ["build"] = 1604,
        ["label"] = "Casino Monitor 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_vw_tv_rt_01a"] = {
        ["model"] = "vw_prop_vw_tv_rt_01a",
        ["screen"] = "tv_rt_01a",
        ["build"] = 1604,
        ["label"] = "Casino TV Rt 01A",
        ["distance"] = 11.0 -- max: 20
    },
    ["tv_xm_x17_computer_01"] = {
        ["model"] = "xm_prop_x17_computer_01",
        ["screen"] = "smug_monitor_01",
        ["label"] = "Doomsday X17 Computer 01",
        ["distance"] = 14.0 -- max: 60
    },
    ["tv_xm_x17_computer_02"] = {
        ["model"] = "xm_prop_x17_computer_02",
        ["screen"] = "monitor_02",
        ["label"] = "Doomsday X17 Computer 02",
        ["distance"] = 13.0 -- max: 40
    },
    ["tv_xm_x17_screens_02a_01"] = {
        ["model"] = "xm_prop_x17_screens_02a_01",
        ["screen"] = "prop_x17_8scrn_01",
        ["label"] = "Doomsday X17 Screens 02A 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_02"] = {
        ["model"] = "xm_prop_x17_screens_02a_02",
        ["screen"] = "prop_x17_8scrn_02",
        ["label"] = "Doomsday X17 Screens 02A 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_03"] = {
        ["model"] = "xm_prop_x17_screens_02a_03",
        ["screen"] = "prop_x17_8scrn_03",
        ["label"] = "Doomsday X17 Screens 02A 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_04"] = {
        ["model"] = "xm_prop_x17_screens_02a_04",
        ["screen"] = "prop_x17_8scrn_04",
        ["label"] = "Doomsday X17 Screens 02A 04",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_05"] = {
        ["model"] = "xm_prop_x17_screens_02a_05",
        ["screen"] = "prop_x17_8scrn_05",
        ["label"] = "Doomsday X17 Screens 02A 05",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_06"] = {
        ["model"] = "xm_prop_x17_screens_02a_06",
        ["screen"] = "prop_x17_8scrn_06",
        ["label"] = "Doomsday X17 Screens 02A 06",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_07"] = {
        ["model"] = "xm_prop_x17_screens_02a_07",
        ["screen"] = "prop_x17_8scrn_07",
        ["label"] = "Doomsday X17 Screens 02A 07",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_screens_02a_08"] = {
        ["model"] = "xm_prop_x17_screens_02a_08",
        ["screen"] = "prop_x17_8scrn_08",
        ["label"] = "Doomsday X17 Screens 02A 08",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_ceiling_scn_01"] = {
        ["model"] = "xm_prop_x17_tv_ceiling_scn_01",
        ["screen"] = "prop_x17_tv_ceil_scn_01",
        ["label"] = "Doomsday X17 TV Ceiling Scn 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_ceiling_scn_02"] = {
        ["model"] = "xm_prop_x17_tv_ceiling_scn_02",
        ["screen"] = "prop_x17_tv_ceil_scn_02",
        ["label"] = "Doomsday X17 TV Ceiling Scn 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_flat_01"] = {
        ["model"] = "xm_prop_x17_tv_flat_01",
        ["screen"] = "tv_flat_01",
        ["label"] = "Doomsday X17 TV Flat 01",
        ["distance"] = 12.0 -- max: 30
    },
    ["tv_xm_x17_tv_scrn_01"] = {
        ["model"] = "xm_prop_x17_tv_scrn_01",
        ["screen"] = "prop_x17_tv_scrn_01",
        ["label"] = "Doomsday X17 TV Scrn 01",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_02"] = {
        ["model"] = "xm_prop_x17_tv_scrn_02",
        ["screen"] = "prop_x17_tv_scrn_02",
        ["label"] = "Doomsday X17 TV Scrn 02",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_03"] = {
        ["model"] = "xm_prop_x17_tv_scrn_03",
        ["screen"] = "prop_x17_tv_scrn_03",
        ["label"] = "Doomsday X17 TV Scrn 03",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_04"] = {
        ["model"] = "xm_prop_x17_tv_scrn_04",
        ["screen"] = "prop_x17_tv_scrn_04",
        ["label"] = "Doomsday X17 TV Scrn 04",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_05"] = {
        ["model"] = "xm_prop_x17_tv_scrn_05",
        ["screen"] = "prop_x17_tv_scrn_05",
        ["label"] = "Doomsday X17 TV Scrn 05",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_06"] = {
        ["model"] = "xm_prop_x17_tv_scrn_06",
        ["screen"] = "prop_x17_tv_scrn_06",
        ["label"] = "Doomsday X17 TV Scrn 06",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_07"] = {
        ["model"] = "xm_prop_x17_tv_scrn_07",
        ["screen"] = "prop_x17_tv_scrn_07",
        ["label"] = "Doomsday X17 TV Scrn 07",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_08"] = {
        ["model"] = "xm_prop_x17_tv_scrn_08",
        ["screen"] = "prop_x17_tv_scrn_08",
        ["label"] = "Doomsday X17 TV Scrn 08",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_09"] = {
        ["model"] = "xm_prop_x17_tv_scrn_09",
        ["screen"] = "prop_x17_tv_scrn_09",
        ["label"] = "Doomsday X17 TV Scrn 09",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_10"] = {
        ["model"] = "xm_prop_x17_tv_scrn_10",
        ["screen"] = "prop_x17_tv_scrn_10",
        ["label"] = "Doomsday X17 TV Scrn 10",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_11"] = {
        ["model"] = "xm_prop_x17_tv_scrn_11",
        ["screen"] = "prop_x17_tv_scrn_11",
        ["label"] = "Doomsday X17 TV Scrn 11",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_12"] = {
        ["model"] = "xm_prop_x17_tv_scrn_12",
        ["screen"] = "prop_x17_tv_scrn_12",
        ["label"] = "Doomsday X17 TV Scrn 12",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_13"] = {
        ["model"] = "xm_prop_x17_tv_scrn_13",
        ["screen"] = "prop_x17_tv_scrn_13",
        ["label"] = "Doomsday X17 TV Scrn 13",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_14"] = {
        ["model"] = "xm_prop_x17_tv_scrn_14",
        ["screen"] = "prop_x17_tv_scrn_14",
        ["label"] = "Doomsday X17 TV Scrn 14",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_15"] = {
        ["model"] = "xm_prop_x17_tv_scrn_15",
        ["screen"] = "prop_x17_tv_scrn_15",
        ["label"] = "Doomsday X17 TV Scrn 15",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_16"] = {
        ["model"] = "xm_prop_x17_tv_scrn_16",
        ["screen"] = "prop_x17_tv_scrn_16",
        ["label"] = "Doomsday X17 TV Scrn 16",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_17"] = {
        ["model"] = "xm_prop_x17_tv_scrn_17",
        ["screen"] = "prop_x17_tv_scrn_17",
        ["label"] = "Doomsday X17 TV Scrn 17",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_18"] = {
        ["model"] = "xm_prop_x17_tv_scrn_18",
        ["screen"] = "prop_x17_tv_scrn_18",
        ["label"] = "Doomsday X17 TV Scrn 18",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_scrn_19"] = {
        ["model"] = "xm_prop_x17_tv_scrn_19",
        ["screen"] = "prop_x17_tv_scrn_19",
        ["label"] = "Doomsday X17 TV Scrn 19",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17_tv_stand_01a"] = {
        ["model"] = "xm_prop_x17_tv_stand_01a",
        ["screen"] = "tvstand_screen",
        ["label"] = "Doomsday X17 TV Stand 01A",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xm_x17dlc_monitor_wall_01a"] = {
        ["model"] = "xm_prop_x17dlc_monitor_wall_01a",
        ["screen"] = "prop_x17dlc_monitor_wall_01a",
        ["label"] = "Doomsday X17dlc Monitor Wall 01A",
        ["distance"] = 17.0 -- max: 199
    },
    ["tv_xm_screen_1"] = {
        ["model"] = "xm_screen_1",
        ["screen"] = "prop_x17_tv_ceiling_01",
        ["label"] = "Doomsday Screen 1",
        ["distance"] = 15.0 -- max: 100
    },
    ["tv_xs_arena_bigscreen_01"] = {
        ["model"] = "xs_prop_arena_bigscreen_01",
        ["screen"] = "bigscreen_01",
        ["build"] = 1604,
        ["label"] = "Arena Bigscreen 01",
        ["distance"] = 20.0 -- max: 500
    },
    ["tv_xs_arena_screen_tv_01"] = {
        ["model"] = "xs_prop_arena_screen_tv_01",
        ["screen"] = "screen_tv_01",
        ["build"] = 1604,
        ["label"] = "Arena Screen TV 01",
        ["distance"] = 15.0 -- max: 100
    },
}

Config.DefaultScreen = "tvscreen"
Config.ModelScreens, Config.ModelData = {}, {}
for _, data in pairs(Config.UsableItems) do
    if data.model ~= nil then
        local hash = joaat(data.model)
        Config.ModelData[hash] = data
        if data.screen ~= nil and data.screen ~= "" then
            Config.ModelScreens[hash] = data.screen
        end
    end
end

Config.DefaultDistance = 12.0 -- DaddyRP: 30 -> 12 (TV mesafeleri en fazla 20 m olacak sekilde olceklendi)
Config.MaxDistance = 20.0 -- DaddyRP: hicbir TV 20 m'den uzaktan gorulup duyulamaz

-- Distance of a TV model, taken from Config.UsableItems. `fallback` (e.g. the game's LOD distance or a value saved in
-- tvs.json) is only used when the model has no usable distance in the config, so a broken / old config never yields nil.
Config.GetDistance = function(model, fallback)
    if type(model) == "string" then model = joaat(model) end
    local data = Config.ModelData[model]
    local value = data ~= nil and tonumber(data.distance) or nil
    if value ~= nil and value > 0 then return math.min(value, Config.MaxDistance) + 0.0 end

    value = tonumber(fallback)
    if value ~= nil and value > 0 then return math.min(value, Config.MaxDistance) + 0.0 end
    return Config.DefaultDistance
end

for item, data in pairs(Config.UsableItems) do
    if data.distance ~= nil and (tonumber(data.distance) == nil or tonumber(data.distance) <= 0) then
        print(("^3[wais-tv] Config.UsableItems['%s'].distance is invalid (%s), the game's own distance will be used for it.^0"):format(item, tostring(data.distance)))
        data.distance = nil
    end
end

Config.GetScreenName = function(model, screen)
    if screen ~= nil and screen ~= "" then return screen end
    if type(model) == "string" then model = joaat(model) end
    return Config.ModelScreens[model] or Config.DefaultScreen
end

Config.ScreenArbiter = {
    --[[
        SCREEN ARBITER - in plain words:
        The game can only show ONE TV's picture at a time (there is a single browser behind it).
        When 2 or more TVs with a video are in range, this decides which TV gets the picture.
        A TV wins by being the closest to the player, and gets a bonus when the player is looking at it.
        The TV you have the menu open on always wins.
        To stop the picture from jumping around, another TV must be clearly better and the current one
        must have had the screen for a few seconds first.
        Set "enabled" to false to go back to the old behavior (first TV in range keeps the screen).
    ]]

    ["enabled"] = true,
    ["interval"] = 500, -- ms between checks while 2 or more TVs are in range
    ["switchMargin"] = 3.0, -- a TV must score this many meters better than the active one to take over
    ["minDwell"] = 4000, -- ms the active TV keeps the screen before another one can take over
    ["viewBonus"] = 6.0, -- meters subtracted from the score of a TV the player is looking at
    ["viewDot"] = 0.8, -- how centered the TV must be on screen to count as looked at (1.0 = exact center)
}

Config.PlaceOptions = {
    ["timeout"] = 15 * 1000, -- Time to wait for the player to place the TV 
    ["maxDistance"] = 5.0, -- Max distance to place the TV from the player
    ["buttons"] = {
        ["accept"] = "E", -- Button to accept placing the TV
        ["cancel"] = "G", -- Button to cancel placing the TV
        ["snapGround"] = "Z" -- Button to snap the TV to the ground.
    },
    ["offset"] = vector4(1.25, 0.0, 0.0, 0.0), -- Offset from the player when placing the TV (x, y, z, heading)
    ["animations"] = {
        ["dict"] = "anim@heists@load_box", -- Animation dictionary for placing the TV
        ["clip"] = "load_box_1", -- Animation clip for placing the TV
        ["flag"] = 1, -- Animation flag for placing the TV
        ["duration"] = 2.5 * 1000, -- Duration of the animation in milliseconds
    },
}

Config.CameraSettings = {
    ["lookSensitivity"] = 5.0,   -- Mouse rotation speed (higher = camera turns faster)
    ["moveSpeed"] = 7.0,         -- WASD camera movement speed in meters per second
    ["zoomSpeed"] = 2.0,         -- FOV change per mouse-wheel tick
    ["fovOffset"] = 5.0,         -- The freecam starts at the player's gameplay FOV + this value
    ["minFov"] = 5.0,            -- Absolute lower clamp for the FOV (most you can ever zoom in)
    ["maxFov"] = 90.0,           -- Upper clamp for the FOV (most you can ever zoom out)
    ["fitMargin"] = 1.15,        -- Safety multiplier so the TV never touches the screen edges (1.0 = exact fit)
    ["transitionTime"] = 800,    -- Duration (ms) of the blend in/out between the gameplay camera and the freecam
}

Config.Placement = {
    ["gizmoSize"] = 0.14,        -- Gizmo size as a fraction of the half-screen height (stays the same on screen at any FOV / distance)
    ["pickRadius"] = 0.24,       -- How close the cursor has to be to a gizmo handle to grab it (relative to the gizmo size)
    ["ringSegments"] = 40,       -- Segments per rotation ring (lower = fewer draw calls)
    ["snap"] = true,             -- Rotation snap is on by default (can be toggled in the panel)
    ["rotateSnap"] = 15.0,       -- Rotation snap step in degrees
    ["spinStep"] = 15.0,         -- Mouse wheel / turn button step in degrees while snap is on
    ["spinFine"] = 2.0,          -- Mouse wheel / turn button step in degrees while snap is off
    ["nudgeSteps"] = { 0.01, 0.05, 0.25 }, -- Panel nudge step choices in meters
    ["screenSide"] = -1,         -- Local axis the TV screen faces: -1 = -Y (GTA default), 1 = +Y. Flip it if TVs mount backwards on walls.
    ["floorNormalZ"] = 0.7,      -- A surface counts as floor / ceiling when |normal.z| is at least this, otherwise as a wall
    ["rayDistance"] = 60.0,      -- Max length of the cursor ray in meters
    ["rayFlags"] = 19,           -- Shape test flags for the cursor ray: 1 = world, 2 = vehicles, 16 = objects
}

Config.BlacklistedCoords = {
    --[[
        🚫🚫🚫
        You can add blacklist coordinates so that people cannot place tv's or screens there. 
        Example: { coords = vector3(x, y, z), radius = 10.0 }
    ]]

    { coords = vector3(5347.2, -5253.4, 31.0), radius = 150.0 }, -- Daddy College campus (Cayo, east plateau): the boards show the videos there
    -- { coords = vector3(455.5057, -994.2595, 26.9876), radius = 45.0 }, -- Mission Row Police Department [MRPD]
    -- { coords = vector3(320.7686, -590.9871, 45.0281), radius = 40.0 } -- Pillbox Hill Medical Center [PHMC]
}

Config.Debug = function(...)
    if Config.ShowDebug then
        print(...)
    end
end

Config.Notification = function(title, text, type, time)
    title = title or "Television"
    time = time or 5000

    return lib.notify({
        title = title,
        type = type,
        duration = time,
        description = text,
        iconAnimation = "beatFade",
        position = "top"
    })
end