shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
-- =============================================================================
-- Krypton Farming - FX Manifest
-- FiveM Resource Manifest
-- =============================================================================

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Krypton3D'
description 'Advanced Farming System with Modern UI'
version '1.0.0'

-- UI Page
ui_page 'web/dist/index.html'

-- Shared Scripts (Config, Locales, Bridges - load order matters)
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    -- Config files
    'config/cfg_main.lua',
    'config/cfg_items.lua',
    'config/cfg_admin.lua',
    'config/cfg_dialogue.lua',

    -- Locales
    'locales/*.lua',

    -- Framework Bridge
    'modules/framework/bridge.lua',
    'modules/framework/qbx.lua',
    'modules/framework/qb.lua',
    'modules/framework/esx.lua',

    -- Inventory Bridge
    'modules/inventory/bridge.lua',
}

-- Client Scripts
client_scripts {
    'client/cl_main.lua',
    'modules/target/_default/client.lua',
    'modules/target/qb-target/client.lua',
    'modules/target/sleepless_interact/client.lua',
    'modules/target/ox_target/client.lua',
    'client/cl_npc.lua',
    'client/ui/cl_ui_camera.lua',
    'client/ui/cl_ui_invites.lua',
    'client/ui/cl_ui_nui.lua',
    'client/job/cl_job_progress.lua',
    'client/job/cl_job_zones.lua',
    'client/job/cl_job_lifecycle.lua',
    'client/vehicle/cl_vehicle_spawn.lua',
    'client/vehicle/cl_vehicle_equipment.lua',
    'client/harvest/cl_harvest_targets.lua',
    'client/harvest/cl_harvest_spots.lua',
    'client/harvest/cl_harvest_loop.lua',
    'client/harvest/cl_harvest_minigame.lua',
    'client/harvest/cl_harvest_actions.lua',
    'client/harvest/cl_harvest_anim.lua',
    'client/livestock/cl_livestock.lua',
    'client/cl_clothing.lua',
    'client/debug/cl_debug_visuals.lua',
    'client/debug/cl_debug_commands.lua',
    'client/debug/cl_debug_prop_editor.lua',
    'client/debug/cl_debug_prop_tester.lua',
    'client/debug/cl_vehicle_calibration.lua',
    'client/admin/cl_admin_draw.lua',
    'client/admin/cl_admin_wizard.lua',
    'client/admin/cl_admin_panel.lua',
}

-- Server Scripts
server_scripts {
    'config/cfg_server.lua',
    '@oxmysql/lib/MySQL.lua',
    'modules/database/server.lua',
    'server/integrations/sv_webhook.lua',
    'server/core/sv_helpers.lua',
    'server/core/sv_state.lua',
    'server/core/sv_locks.lua',
    'server/core/sv_farm_slots.lua',
    'server/job/sv_livestock_spawn.lua',
    'server/lifecycle/sv_player.lua',
    'server/lifecycle/sv_ui_data.lua',
    'server/lifecycle/sv_cleanup.lua',
    'server/vehicle/sv_vehicle_spawn.lua',
    'server/vehicle/sv_vehicle_equipment.lua',
    'server/job/sv_job_start.lua',
    'server/job/sv_job_harvest.lua',
    'server/job/sv_job_phase.lua',
    'server/job/sv_job_livestock.lua',
    'server/npc/sv_npc_dialogue.lua',
    'server/job/sv_job_finish.lua',
    'server/job/sv_skills.lua',
    'server/group/sv_group.lua',
    'server/integrations/sv_clothing.lua',
    'server/admin/sv_admin_data.lua',
    'server/admin/sv_admin_farms.lua',
    'server/admin/sv_admin_spots.lua',
}

-- Files (NUI Assets)
files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'web/dist/assets/fields/*.webp',
    'web/dist/vite.svg',
}

-- Dependencies
dependencies {
    'oxmysql',
}








