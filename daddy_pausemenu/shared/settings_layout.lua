-- How the settings screen shows GTA's rows: as GTA does. GTA's tabs in its order are the sections, each tab keeps GTA's
-- row order, and a header GTA shows (Voice Chat's Listening, Key Bindings' sections) starts a group. The layout only adds
-- rows GTA lacks, says where they go, and hides what an RP server does not use. Hand-edited; the catalog stays generated.
PMSettings = PMSettings or {}

-- Rows the layout adds to GTA's catalog: `first` goes to the top of its tab, `after` right below that row.
PMSettings.EXTRA = {
    -- Graphics preset: picking one writes pending edits for the rows in PRESETS (Apply runs them); 4 = Custom.
    { id = 'gfx_preset', tab = 'graphics', kind = 'list', widget = 'seg', cls = 'R', min = 0, max = 4, list = 'gfx_preset', first = true },
    -- FiveM's Extended Texture Budget, where GTA lists it: the stereo convergence slider (pref 64) re-labelled
    -- GFX_BUDGET, its value kept in the vid_budgetScale convar (readable, the driver checks every change). 0..20.
    { id = 'gfx_texture_budget', tab = 'graphics', kind = 'slider', widget = 'sld', cls = 'G', convar = 'vid_budgetScale', uid = 64, min = 0, max = 20, after = 'gfx_dist_scale' },
}

-- GTA tabs that never show: the Rockstar Editor.
PMSettings.DROP_TAB = { editor = true }
-- GTA's blank separators (Graphics, build 3258): a group without a title starts at these rows. The preset is ours and
-- stands alone; a header that is no title (Advanced Graphics' performance warning) starts one too.
PMSettings.BREAKS = { gfx_vid_override = true, gfx_fxaa = true, gfx_city_density = true, gfx_texture_budget = true }
PMSettings.UNTITLED = { agfx_warning = true }
-- The Key Bindings header the server's own keys (RegisterKeyMapping) go under, as in GTA's FiveM section.
PMSettings.FIVEM_GROUP = 'keys_cfx'

-- Hidden unless Config.Settings.Show lists them: rows that do nothing on an RP server (Self Radio, submarines, story
-- characters, GTA Online chat and vehicles, a language GTA never writes).
PMSettings.HIDE_DEFAULT = {
    radio_station = true, ur_playmode = true, ur_autoscan = true, mouse_sub = true, mouse_sub_scale = true, invert_mouse_sub = true,
    big_radar_names = true, current_language = true, gfx_dxversion = true,
    key_special_ability_pc = true, key_character_wheel = true, key_select_character_michael = true, key_select_character_franklin = true,
    key_select_character_trevor = true, key_select_character_multiplayer = true, key_frontend_social_club_secondary = true,
    key_mp_text_chat_all = true, key_mp_text_chat_team = true, key_eat_snack = true, key_use_armor = true, key_drop_weapon = true,
    key_drop_ammo = true, key_veh_slowmo_up_only = true, key_veh_slowmo_down_only = true, key_veh_next_radio_track = true,
    key_veh_prev_radio_track = true, key_fivem = true,
}
-- Whole GTA key sections hidden the same way.
PMSettings.HIDE_KEY_SECTIONS = { veh_online = true, sub = true }

-- Graphics presets (Low, Medium, High, Ultra): option indices of the catalog lists. Only rows that differ are edited.
PMSettings.PRESET_ROWS = {
    'gfx_texture_quality', 'gfx_shader_quality', 'gfx_shadow_quality', 'gfx_reflection_quality', 'gfx_reflection_msaa', 'gfx_water_quality',
    'gfx_particles_quality', 'gfx_grass_quality', 'gfx_shadow_softness', 'gfx_post_fx', 'gfx_msaa', 'gfx_fxaa', 'gfx_anisotropic_filtering',
    'gfx_ambient_occlusion', 'gfx_tessellation', 'gfx_city_density', 'gfx_pop_variety', 'gfx_dist_scale', 'adv_gfx_long_shadows',
    'adv_gfx_ultra_shadows', 'adv_gfx_hd_flight', 'adv_gfx_max_lod', 'adv_gfx_shadows_dist_mult',
}
PMSettings.PRESETS = {
    { 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 3, 3, 2, 0, 0, 0, 0, 0 },
    { 1, 1, 2, 1, 0, 1, 1, 1, 1, 1, 0, 1, 3, 1, 1, 6, 6, 5, 0, 0, 0, 0, 0 },
    { 2, 2, 3, 2, 0, 2, 2, 2, 2, 2, 1, 1, 4, 2, 2, 8, 8, 8, 0, 0, 0, 0, 0 },
    { 2, 2, 3, 3, 2, 2, 2, 3, 3, 3, 2, 0, 4, 2, 3, 10, 10, 10, 1, 1, 1, 5, 5 },
}
-- Restore defaults on Graphics and Advanced Graphics: the High preset (GTA keeps no defaults for these rows).
PMSettings.GRAPHICS_DEFAULT = 3
