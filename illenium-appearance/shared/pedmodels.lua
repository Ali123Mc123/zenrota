-- ═══════════════════════════════════════════════════════════════════════════════
--  Ped Modülü — Ped Kataloğu
--  Admin ped verirken kullanılacak kategorize edilmiş ped listesi
--  Config.CustomPeds tablosuna sunucuya özel (stream) pedlerinizi ekleyebilirsiniz
-- ═══════════════════════════════════════════════════════════════════════════════

Config.PedCatalog = {
    -- ═══════════════════════════════════════
    --  Hayvanlar
    -- ═══════════════════════════════════════
    {
        label = "Hayvanlar",
        icon = "paw",
        peds = {
            { model = "a_c_cat_01",        label = "Kedi" },
            { model = "a_c_husky",         label = "Husky" },
            { model = "a_c_rottweiler",    label = "Rottweiler" },
            { model = "a_c_shepherd",      label = "Alman Kurdu" },
            { model = "a_c_poodle",        label = "Kaniş" },
            { model = "a_c_retriever",     label = "Golden Retriever" },
            { model = "a_c_westy",         label = "Terrier" },
            { model = "a_c_pug",           label = "Pug" },
            { model = "a_c_rabbit_02",     label = "Tavşan" },
            { model = "a_c_deer",          label = "Geyik" },
            { model = "a_c_boar_02",       label = "Yaban Domuzu" },
            { model = "a_c_coyote",        label = "Çakal" },
            { model = "a_c_mtlion",        label = "Dağ Aslanı" },
            { model = "a_c_panther",       label = "Panter" },
            { model = "a_c_pig",           label = "Domuz" },
            { model = "a_c_cow",           label = "İnek" },
            { model = "a_c_hen",           label = "Tavuk" },
            { model = "a_c_chickenhawk",   label = "Şahin" },
            { model = "a_c_crow",          label = "Karga" },
            { model = "a_c_seagull",       label = "Martı" },
            { model = "a_c_pigeon",        label = "Güvercin" },
            { model = "a_c_cormorant",     label = "Karabatak" },
            { model = "a_c_dolphin",       label = "Yunus" },
            { model = "a_c_fish",          label = "Balık" },
            { model = "a_c_sharkhammer",   label = "Çekiç Köpekbalığı" },
            { model = "a_c_sharktiger",    label = "Kaplan Köpekbalığı" },
            { model = "a_c_killerwhale",   label = "Katil Balina" },
            { model = "a_c_stingray",      label = "Vatoz" },
            { model = "a_c_rat",           label = "Fare" },
            { model = "a_c_chimp",         label = "Şempanze" },
            { model = "a_c_rhesus",        label = "Maymun" },
        }
    },

    -- ═══════════════════════════════════════
    --  Acil Servisler
    -- ═══════════════════════════════════════
    {
        label = "Acil Servisler",
        icon = "shield-halved",
        peds = {
            { model = "s_m_y_cop_01",       label = "Polis (Erkek)" },
            { model = "s_f_y_cop_01",       label = "Polis (Kadın)" },
            { model = "s_m_y_sheriff_01",   label = "Şerif" },
            { model = "s_m_y_hwaycop_01",   label = "Otoyol Polisi" },
            { model = "s_m_y_swat_01",      label = "SWAT" },
            { model = "s_m_m_paramedic_01", label = "Paramedik" },
            { model = "s_m_y_fireman_01",   label = "İtfaiyeci" },
            { model = "s_m_m_doctor_01",    label = "Doktor" },
            { model = "s_m_m_security_01",  label = "Güvenlik" },
            { model = "s_m_m_highsec_01",   label = "Özel Güvenlik" },
            { model = "s_m_m_highsec_02",   label = "Özel Güvenlik 2" },
            { model = "s_m_y_ranger_01",    label = "Orman Muhafızı" },
            { model = "s_m_m_prisguard_01", label = "Cezaevi Gardiyanı" },
            { model = "s_m_y_uscg_01",      label = "Sahil Güvenlik" },
            { model = "csb_reporter",       label = "Muhabir" },
        }
    },

    -- ═══════════════════════════════════════
    --  Askeri
    -- ═══════════════════════════════════════
    {
        label = "Askeri",
        icon = "helmet",
        peds = {
            { model = "s_m_y_marine_01",    label = "Deniz Piyadesi 1" },
            { model = "s_m_y_marine_02",    label = "Deniz Piyadesi 2" },
            { model = "s_m_y_marine_03",    label = "Deniz Piyadesi 3" },
            { model = "s_m_m_marine_01",    label = "Deniz Subayı" },
            { model = "s_m_m_marine_02",    label = "Deniz Subayı 2" },
            { model = "s_m_y_armymech_01",  label = "Askeri Teknisyen" },
            { model = "s_m_m_pilot_01",     label = "Pilot" },
            { model = "s_m_m_pilot_02",     label = "Pilot 2" },
        }
    },

    -- ═══════════════════════════════════════
    --  İş & Meslek
    -- ═══════════════════════════════════════
    {
        label = "İş & Meslek",
        icon = "briefcase",
        peds = {
            { model = "s_m_m_hairdress_01",  label = "Berber" },
            { model = "s_m_y_chef_01",       label = "Aşçı" },
            { model = "s_m_y_construct_01",  label = "İnşaat İşçisi 1" },
            { model = "s_m_y_construct_02",  label = "İnşaat İşçisi 2" },
            { model = "s_m_m_gardener_01",   label = "Bahçıvan" },
            { model = "s_m_y_garbage",       label = "Çöpçü" },
            { model = "s_m_m_trucker_01",    label = "Tır Şoförü" },
            { model = "s_m_y_busboy_01",     label = "Garson" },
            { model = "s_m_m_janitor",       label = "Temizlikçi" },
            { model = "s_m_y_dockwork_01",   label = "Liman İşçisi" },
            { model = "s_m_y_ammucity_01",   label = "Silah Satıcısı" },
            { model = "s_m_m_lifeinvad_01",  label = "Ofis Çalışanı" },
            { model = "s_m_m_scientist_01",  label = "Bilim İnsanı" },
            { model = "s_m_y_clown_01",      label = "Palyaço" },
            { model = "s_m_y_mime",          label = "Mim" },
            { model = "u_m_y_tattoo_01",     label = "Dövmeci" },
            { model = "s_f_y_shop_mid",      label = "Mağaza Çalışanı (K)" },
            { model = "s_f_y_shop_low",      label = "Mağaza Çalışanı 2 (K)" },
            { model = "s_m_y_valet_01",      label = "Vale" },
            { model = "s_m_y_waiter_01",     label = "Garson" },
            { model = "s_m_y_dealer_01",     label = "Satıcı" },
        }
    },

    -- ═══════════════════════════════════════
    --  Sokak & Gang
    -- ═══════════════════════════════════════
    {
        label = "Sokak & Gang",
        icon = "skull",
        peds = {
            { model = "g_m_y_famca_01",     label = "Families 1" },
            { model = "g_m_y_famdnf_01",    label = "Families 2" },
            { model = "g_m_y_famfor_01",     label = "Families 3" },
            { model = "g_f_y_families_01",   label = "Families (K)" },
            { model = "g_m_y_ballasout_01",  label = "Ballas 1" },
            { model = "g_m_y_ballaeast_01",  label = "Ballas 2" },
            { model = "g_f_y_ballas_01",     label = "Ballas (K)" },
            { model = "g_m_y_lost_01",       label = "Lost MC 1" },
            { model = "g_m_y_lost_02",       label = "Lost MC 2" },
            { model = "g_m_y_lost_03",       label = "Lost MC 3" },
            { model = "g_f_y_lost_01",       label = "Lost MC (K)" },
            { model = "g_m_y_mexgoon_01",    label = "Meksika Çetesi 1" },
            { model = "g_m_y_mexgoon_02",    label = "Meksika Çetesi 2" },
            { model = "g_m_y_mexgoon_03",    label = "Meksika Çetesi 3" },
            { model = "g_m_y_salvaboss_01",  label = "Salvadorlu Lider" },
            { model = "g_m_y_salvagoon_01",  label = "Salvadorlu Gangster 1" },
            { model = "g_m_y_salvagoon_02",  label = "Salvadorlu Gangster 2" },
            { model = "g_m_y_salvagoon_03",  label = "Salvadorlu Gangster 3" },
            { model = "g_m_y_strpunk_01",    label = "Sokak Punkçı 1" },
            { model = "g_m_y_strpunk_02",    label = "Sokak Punkçı 2" },
            { model = "g_m_y_korean_01",     label = "Koreli Gangster 1" },
            { model = "g_m_y_korean_02",     label = "Koreli Gangster 2" },
            { model = "g_m_y_korlieut_01",   label = "Koreli Teğmen" },
            { model = "g_m_m_armboss_01",    label = "Ermeni Patron" },
            { model = "g_m_m_armgoon_01",    label = "Ermeni Gangster" },
            { model = "g_m_m_armlieut_01",   label = "Ermeni Teğmen" },
            { model = "g_m_m_chigoon_01",    label = "Çinli Gangster 1" },
            { model = "g_m_m_chigoon_02",    label = "Çinli Gangster 2" },
            { model = "g_m_m_chiboss_01",    label = "Çinli Patron" },
        }
    },

    -- ═══════════════════════════════════════
    --  Siviller (Erkek)
    -- ═══════════════════════════════════════
    {
        label = "Siviller (Erkek)",
        icon = "person",
        peds = {
            { model = "a_m_y_hipster_01",    label = "Hipster 1" },
            { model = "a_m_y_hipster_02",    label = "Hipster 2" },
            { model = "a_m_y_hipster_03",    label = "Hipster 3" },
            { model = "a_m_y_skater_01",     label = "Kaykay Sürücüsü 1" },
            { model = "a_m_y_skater_02",     label = "Kaykay Sürücüsü 2" },
            { model = "a_m_y_surfer_01",     label = "Sörfçü" },
            { model = "a_m_y_beach_01",      label = "Plajcı" },
            { model = "a_m_y_beach_02",      label = "Plajcı 2" },
            { model = "a_m_y_business_01",   label = "İş Adamı 1" },
            { model = "a_m_y_business_02",   label = "İş Adamı 2" },
            { model = "a_m_y_business_03",   label = "İş Adamı 3" },
            { model = "a_m_m_bevhills_01",   label = "Beverly Hills 1" },
            { model = "a_m_m_bevhills_02",   label = "Beverly Hills 2" },
            { model = "a_m_y_vinewood_01",   label = "Vinewood 1" },
            { model = "a_m_y_vinewood_02",   label = "Vinewood 2" },
            { model = "a_m_y_vinewood_03",   label = "Vinewood 3" },
            { model = "a_m_y_vinewood_04",   label = "Vinewood 4" },
            { model = "a_m_y_musclbeac_01",  label = "Kasçı 1" },
            { model = "a_m_y_musclbeac_02",  label = "Kasçı 2" },
            { model = "a_m_m_farmer_01",     label = "Çiftçi" },
            { model = "a_m_m_hillbilly_01",  label = "Köylü 1" },
            { model = "a_m_m_hillbilly_02",  label = "Köylü 2" },
            { model = "a_m_m_tramp_01",      label = "Evsiz 1" },
            { model = "a_m_m_trampbeac_01",  label = "Evsiz 2" },
            { model = "a_m_o_tramp_01",      label = "Yaşlı Evsiz" },
            { model = "a_m_y_runner_01",     label = "Koşucu 1" },
            { model = "a_m_y_runner_02",     label = "Koşucu 2" },
            { model = "a_m_y_cyclist_01",    label = "Bisikletçi" },
            { model = "a_m_y_golfer_01",     label = "Golfçü" },
            { model = "a_m_y_dhill_01",      label = "Dağ Bisikletçisi" },
        }
    },

    -- ═══════════════════════════════════════
    --  Siviller (Kadın)
    -- ═══════════════════════════════════════
    {
        label = "Siviller (Kadın)",
        icon = "person-dress",
        peds = {
            { model = "a_f_y_hipster_01",    label = "Hipster 1" },
            { model = "a_f_y_hipster_02",    label = "Hipster 2" },
            { model = "a_f_y_hipster_03",    label = "Hipster 3" },
            { model = "a_f_y_hipster_04",    label = "Hipster 4" },
            { model = "a_f_y_beach_01",      label = "Plajcı 1" },
            { model = "a_f_y_beach_02",      label = "Plajcı 2" },
            { model = "a_f_y_business_01",   label = "İş Kadını 1" },
            { model = "a_f_y_business_02",   label = "İş Kadını 2" },
            { model = "a_f_y_business_03",   label = "İş Kadını 3" },
            { model = "a_f_y_business_04",   label = "İş Kadını 4" },
            { model = "a_f_m_bevhills_01",   label = "Beverly Hills 1" },
            { model = "a_f_m_bevhills_02",   label = "Beverly Hills 2" },
            { model = "a_f_y_vinewood_01",   label = "Vinewood 1" },
            { model = "a_f_y_vinewood_02",   label = "Vinewood 2" },
            { model = "a_f_y_vinewood_03",   label = "Vinewood 3" },
            { model = "a_f_y_vinewood_04",   label = "Vinewood 4" },
            { model = "a_f_y_fitness_01",    label = "Fitness 1" },
            { model = "a_f_y_fitness_02",    label = "Fitness 2" },
            { model = "a_f_y_runner_01",     label = "Koşucu" },
            { model = "a_f_y_golfer_01",     label = "Golfçü" },
            { model = "a_f_y_tourist_01",    label = "Turist 1" },
            { model = "a_f_y_tourist_02",    label = "Turist 2" },
            { model = "a_f_y_skater_01",     label = "Kaykay Sürücüsü" },
            { model = "a_f_y_scdressy_01",   label = "Şık Kadın" },
            { model = "a_f_y_clubcust_01",   label = "Kulüp Müşterisi" },
            { model = "a_f_y_clubcust_02",   label = "Kulüp Müşterisi 2" },
            { model = "a_f_y_clubcust_03",   label = "Kulüp Müşterisi 3" },
        }
    },

    -- ═══════════════════════════════════════
    --  Hikaye Karakterleri
    -- ═══════════════════════════════════════
    {
        label = "Hikaye Karakterleri",
        icon = "star",
        peds = {
            { model = "player_zero",         label = "Michael De Santa" },
            { model = "player_one",          label = "Franklin Clinton" },
            { model = "player_two",          label = "Trevor Philips" },
            { model = "ig_amanda",           label = "Amanda De Santa" },
            { model = "ig_jimmydisanto",     label = "Jimmy De Santa" },
            { model = "ig_tracydisanto",     label = "Tracey De Santa" },
            { model = "ig_lamar",            label = "Lamar Davis" },
            { model = "ig_wade",             label = "Wade Hebert" },
            { model = "ig_stretch",          label = "Stretch" },
            { model = "ig_roccopelosi",      label = "Rocco Pelosi" },
            { model = "ig_chengsr",          label = "Wei Cheng" },
            { model = "ig_devin",            label = "Devin Weston" },
            { model = "ig_solomon",          label = "Solomon Richards" },
            { model = "ig_drfriedlander",    label = "Dr. Friedlander" },
            { model = "ig_fbisuit_01",       label = "FIB Ajanı" },
            { model = "ig_chef",             label = "Chef (Trevor)" },
            { model = "ig_nervousron",       label = "Nervous Ron" },
            { model = "ig_floyd",            label = "Floyd" },
            { model = "ig_taocheng",         label = "Tao Cheng" },
            { model = "ig_paige",            label = "Paige Harris" },
            { model = "ig_lestercrest",      label = "Lester Crest" },
            { model = "ig_lifeinvad_01",     label = "Jay Norris" },
        }
    },

    -- ═══════════════════════════════════════
    --  Eğlence & Özel
    -- ═══════════════════════════════════════
    {
        label = "Eğlence & Özel",
        icon = "face-laugh",
        peds = {
            { model = "s_m_y_clown_01",      label = "Palyaço" },
            { model = "s_m_y_mime",           label = "Mim Sanatçısı" },
            { model = "u_m_y_imporage",      label = "İmpersonator" },
            { model = "u_m_y_juggernaut_01", label = "Juggernaut" },
            { model = "u_m_y_zombie_01",     label = "Zombi" },
            { model = "u_m_y_corpse_01",     label = "Ceset" },
            { model = "u_m_y_militarybum",   label = "Askeri Evsiz" },
            { model = "u_m_y_proldriver_01", label = "Yarış Pilotu" },
            { model = "u_m_y_prisoner_01",   label = "Mahkum" },
            { model = "u_m_m_jesus_01",      label = "İsa" },
            { model = "u_m_y_baygor",        label = "Baygor" },
            { model = "u_m_y_burgerdrug_01", label = "Burger Shot Çalışanı" },
            { model = "u_f_y_bikerchic",     label = "Biker Kız" },
            { model = "u_f_y_comjane",       label = "Jane" },
            { model = "u_f_y_corpse_01",     label = "Ceset (K)" },
            { model = "u_f_y_princess",      label = "Prenses" },
            { model = "u_f_y_poppymich",     label = "Poppy" },
            { model = "s_m_m_movprem_01",    label = "Film Yıldızı" },
            { model = "a_m_m_stlat_02",      label = "Noel Baba Kıyafetli" },
        }
    },
}

-- ═══════════════════════════════════════════════════════════════════════════════
--  Custom Pedler — Sunucuya özel stream pedlerinizi buraya ekleyin
--  { model = "stream_ped_model", label = "Görünen İsim" }
-- ═══════════════════════════════════════════════════════════════════════════════

Config.CustomPeds = {
    -- Örnek:
    -- { model = "my_custom_ped", label = "Özel Karakter" },
}
