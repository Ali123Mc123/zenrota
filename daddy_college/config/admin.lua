-- The setup panel (/collegeadmin): where every College place stands (desks, machines, ATMs, guards, the campus,
-- classrooms, the discipline area) and the scholarship settings. Server admins and the principal open it.
Config.Admin = {
    Command = 'collegeadmin',
    -- An admin joining while the first setup is unfinished is told to open the panel. DaddyRP: off (the College jobs
    -- are not in qbx_core, so it showed at every join).
    SetupReminder = false,
    HistoryPageSize = 25,
    MaxZonePoints = 32,
    PlacementReach = 150.0, -- a spot this far from the admin is refused
    ZoneReach = 400.0,      -- an area's corners may be this far (a whole campus is drawn without walking round it)

    -- What the panel offers for peds and props; a spot may also keep its module's default.
    Models = {
        peds = { 'a_f_y_business_02', 'a_m_y_business_01', 'a_m_m_business_01', 'a_f_y_business_04', 'a_m_y_business_02', 's_m_m_highsec_01', 's_m_m_security_01', 's_f_y_shop_mid' },
        props = { 'ch_prop_casino_slot_08a', 'prop_cork_board', 'prop_atm_01', 'prop_atm_02', 'prop_atm_03', 'prop_fleeca_atm',
            'ch_prop_ch_metal_detector_01a', 'ch_prop_baggage_scanner_01a', 'prop_cleaning_trolly', 'prop_bin_01a',
            'xm_prop_lab_desk_01', 'xm_prop_lab_desk_02', 'prop_yoga_mat_01', 'prop_yoga_mat_02', 'prop_yoga_mat_03',
            'daddy_school_wish_tree', 'prop_tree_birch_05', 'h4_prop_tree_umbrella_sml_01', 'prop_plant_int_03a',
            'prop_table_03', 'prop_table_04', 'prop_rub_table_02', 'prop_picnictable_01' },
    },
    Scenarios = { 'WORLD_HUMAN_CLIPBOARD', 'WORLD_HUMAN_STAND_IMPATIENT', 'WORLD_HUMAN_STAND_MOBILE', 'WORLD_HUMAN_AA_COFFEE', 'WORLD_HUMAN_GUARD_STAND' },
}
