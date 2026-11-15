shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_dispatch'
author 'Daddy Studio'
description 'Dispatch: calls, units, panic, the desk and 911 for police and EMS, each player setting up their own alerts'
version '0.1.0'

dependencies { 'ox_lib', 'oxmysql' }

-- Scripts written for these dispatches find this resource under their names (exports and events). Never run them
-- together with this one.
provide 'tgiann-policealert'
provide 'ps-dispatch'
provide 'glxs-dispatch'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config/cfg_main.lua',
    'config/cfg_alerts.lua',
    'config/cfg_detect.lua',
    'locales/*.lua',
    'shared/sh_core.lua',
    'bridge/init.lua',
    'bridge/framework.lua',
}

client_scripts {
    'bridge/notify.lua',
    'bridge/minigames.lua',
    'bridge/radio.lua',
    'client/cl_main.lua',
    'client/cl_context.lua',
    'client/cl_sound.lua',
    'client/cl_calls.lua',
    'client/cl_units.lua',
    'client/cl_detect.lua',
    'client/cl_citizen.lua',
    'client/cl_desk.lua',
    'client/cl_operator.lua',
    'client/cl_compat.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'bridge/inventory.lua',
    'server/sv_main.lua',
    'server/sv_staff.lua',
    'server/sv_units.lua',
    'server/sv_calls.lua',
    'server/sv_desk.lua',
    'server/sv_citizen.lua',
    'server/sv_log.lua',
    'server/sv_compat.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'sounds/*',
}

-- Readable in the escrow build too: the config files, the texts and every bridge file.
escrow_ignore {
    'config/*.lua',
    'locales/*.lua',
    'bridge/*.lua',
}
