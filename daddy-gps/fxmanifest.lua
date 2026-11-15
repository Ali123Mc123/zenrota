shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy-gps'
author 'DaddyV1'
description 'Advanced GPS Tracking System for Law Enforcement & EMS'
version '1.0.0'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/**/*',
    'locales/*.json',
}

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/framework.lua',
    'shared/config.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_editable.lua',
    'client/cl_ui.lua',
    'client/cl_blip_utils.lua',
    'client/cl_blip_render.lua',
    'client/cl_blip_events.lua',
    'client/cl_water.lua',
    'client/cl_signal.lua',
}

dependencies {
    'ox_lib',
}

client_exports {
    'GetCallsign',
    'CalculateSignalStrength',
    'GetGpsState',
    'open',
}

server_scripts {
    'server/sv_main.lua',
    'server/sv_editable.lua',
    'server/version_check.lua',
}

escrow_ignore {
    'shared/**',
    'client/cl_editable.lua',
    'server/sv_editable.lua',
    'locales/**',
    'web/**/*',
    'README.md',
}








