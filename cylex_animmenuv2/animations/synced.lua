if not Config.Animations then Config.Animations = {} end
Config.Animations['synced'] = {
    {
        category = "synced",
        id = "elsikisma",
        label = "El Sıkısma",
        sender = { dict = "mp_ped_interaction", anim = "handshake_guy_a" },
        receiver = { dict = "mp_ped_interaction", anim = "handshake_guy_b" },
        flag = 0,
    },
    {
        category = "synced",
        id = "beyzbol",
        label = "beyzbol",
        sender = { dict = "anim@arena@celeb@flat@paired@no_props@", anim = "baseball_a_player_a" },
        receiver = { dict = "anim@arena@celeb@flat@paired@no_props@", anim = "baseball_a_player_b" },
        flag = 0,
    },
    {
        category = "synced",
        id = "cpr",
        label = "Kalp Masajı",
        sender = { dict = "missheistfbi3b_ig8_2", anim = "cpr_loop_paramedic" },
        receiver = { dict = "missheistfbi3b_ig8_2", anim = "cpr_loop_victim" },
        flag = 1,
    },
    {
        category = "synced",
        id = "kafaatma",
        label = "Kafa Atma",
        sender = { dict = "missfinale_b_ig_5", anim = "hold_michael_headbut_fra" },
        receiver = { dict = "missfinale_b_ig_5", anim = "hold_michael_headbut_mic" },
        flag = 0,
    },
    {
        category = "synced",
        id = "elsikisma",
        label = "El Sıkısma",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@f_f_manly_handshake",
            anim = "manly_handshake_left"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@f_f_manly_handshake",
            anim = "manly_handshake_right"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kardeskucakla",
        label = "Kardeş kucaklaşması",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_bro_hug",
            anim = "bro_hug_right"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_bro_hug",
            anim = "bro_hug_left"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kutlama",
        label = "kutlama",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@f_f_backslap",
            anim = "backslap_right"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@f_f_backslap",
            anim = "backslap_left"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kutlama",
        label = "kutlama",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_backslap",
            anim = "backslap_left"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_backslap",
            anim = "backslap_right"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "yumrukyumruga",
        label = "yumruk yumruğa",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_fist_bump",
            anim = "fist_bump_left"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_fist_bump",
            anim = "fist_bump_right"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "beslik",
        label = "Çak bir beşlik",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_high_five",
            anim = "high_five_right"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_high_five",
            anim = "high_five_left"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "bravo",
        label = "Bravo",
        sender = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_sarcastic",
            anim = "sarcastic_left"
        },
        receiver = {
            dict = "anim@mp_player_intcelebrationpaired@m_m_sarcastic",
            anim = "sarcastic_right"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kazanankaybeden",
        label = "Kazanan&Kaybeden",
        sender = { dict = "mini@dartsoutro", anim = "darts_outro_01_guy1" },
        receiver = { dict = "mini@dartsoutro", anim = "darts_outro_01_guy2" },
        flag = 0
    },
    {
        category = "synced",
        id = "kazanankaybeden2",
        label = "Kazanan&Kaybeden",
        sender = { dict = "mini@dartsoutro", anim = "darts_outro_02_guy1" },
        receiver = { dict = "mini@dartsoutro", anim = "darts_outro_02_guy2" },
        flag = 0
    },
    {
        category = "synced",
        id = "kazanankaybeden3",
        label = "Kazanan&Kaybeden",
        sender = { dict = "mini@dartsoutro", anim = "darts_outro_03_guy1" },
        receiver = { dict = "mini@dartsoutro", anim = "darts_outro_03_guy2" },
        flag = 0
    },
    {
        category = "synced",
        id = "eltutma",
        label = "El Tutma",
        sender = { dict = "misscarsteal2chad_goodbye", anim = "chad_idle_chad" },
        receiver = {
            dict = "misscarsteal2chad_goodbye",
            anim = "chad_idle_girl"
        },
        flag = 1
    },
    {
        category = "synced",
        id = "kucakla",
        label = "Kucaklama",
        sender = {
            dict = "misscarsteal2chad_goodbye",
            anim = "chad_armsaround_chad"
        },
        receiver = {
            dict = "misscarsteal2chad_goodbye",
            anim = "chad_armsaround_girl"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kucakla2",
        label = "Kucaklama2",
        sender = { dict = "misscarsteal2chad_goodbye", anim = "chad_dip_chad" },
        receiver = {
            dict = "misscarsteal2chad_goodbye",
            anim = "chad_dip_girl"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "kavga",
        label = "kavga",
        sender = {
            dict = "misschinese1leadinoutchinese_1_int",
            anim = "husb_leadin_action"
        },
        receiver = {
            dict = "misschinese1leadinoutchinese_1_int",
            anim = "russ_leadin_action"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "116",
        label = "Handshake",
        sender = { dict = "mp_ped_interaction", anim = "handshake_guy_a" },
        receiver = { dict = "mp_ped_interaction", anim = "handshake_guy_b" },
        flag = 0
    },
    {
        category = "synced",
        id = "cakbeslik2",
        label = "Çak bir beşlik 2",
        sender = { dict = "mp_ped_interaction", anim = "highfive_guy_a" },
        receiver = { dict = "mp_ped_interaction", anim = "highfive_guy_b" },
        flag = 0
    },
    {
        category = "synced",
        id = "sarilmak",
        label = "Sarılmak",
        sender = { dict = "mp_ped_interaction", anim = "hugs_guy_a" },
        receiver = { dict = "mp_ped_interaction", anim = "hugs_guy_b" },
        flag = 0
    },
    {
        category = "synced",
        id = "opucuk",
        label = "Öpücük",
        sender = { dict = "mp_ped_interaction", anim = "kisses_guy_a" },
        receiver = { dict = "mp_ped_interaction", anim = "kisses_guy_b" },
        flag = 0
    },
    {
        category = "synced",
        id = "insankalkani",
        label = "İnsan Kalkanı",
        sender = {
            dict = "missprologueig_4@hold_head_base",
            anim = "hold_head_loop_base_guard"
        },
        receiver = {
            dict = "missprologueig_4@hold_head_base",
            anim = "hold_head_loop_base_player0"
        },
        flag = 1
    },
    {
        category = "synced",
        id = "207",
        label = "Gangster tarafından itildi",
        sender = {
            dict = "switch@franklin@gang_taunt_p6",
            anim = "exit_franklin"
        },
        receiver = {
            dict = "switch@franklin@gang_taunt_p6",
            anim = "exit_gang1"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "rahatlık",
        label = "Diz çökerken rahatlık",
        sender = {
            dict = "random@rescue_hostage",
            anim = "bystander_helping_girl_loop"
        },
        receiver = {
            dict = "random@rescue_hostage",
            anim = "girl_helping_girl_loop"
        },
        flag = 1
    },
    {
        category = "synced",
        id = "eltutma2",
        label = "El Tutma 2",
        sender = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_thedesertissobeautiful_trevor"
        },
        receiver = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_thedesertissobeautiful_patricia"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "eltutma3",
        label = "El Tutma 3",
        sender = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_thedontknowwhy_trevor"
        },
        receiver = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_thedontknowwhy_patricia"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "eltutma4",
        label = "El Tutma 4",
        sender = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_therearejustsomemoments_trevor"
        },
        receiver = {
            dict = "timetable@trevor@ig_1",
            anim = "ig_1_therearejustsomemoments_patricia"
        },
        flag = 0
    },
    {
        category = "synced",
        id = "nakavt",
        label = "Nakavt",
        sender = { dict = "friends@frf@ig_2", anim = "knockout_fra" },
        receiver = { dict = "friends@frf@ig_2", anim = "knockout_plyr" },
        flag = 0
    },
    {
        category = "synced",
        id = "nakavt2",
        label = "Nakavt 2",
        sender = { dict = "friends@frm@ig_2", anim = "knockout_mic" },
        receiver = { dict = "friends@frm@ig_2", anim = "knockout_player" },
        flag = 0
    },
    {
        category = "synced",
        id = "nakavt3",
        label = "Nakavt 3",
        sender = { dict = "friends@frt@ig_2", anim = "knockout_trevor" },
        receiver = { dict = "friends@frt@ig_2", anim = "knockout_player" },
        flag = 0
    },
    {
        category = "synced",
        id = "bosta",
        label = "bosta",
        sender = { dict = "misstrvram_3", anim = "mexicans_idle_a" },
        receiver = { dict = "misstrvram_3", anim = "mexicans_idle_b" },
        flag = 0
    }
}