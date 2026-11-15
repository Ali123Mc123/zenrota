shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_garages'
author 'Daddy Studio'
description 'Garages: a cinematic garage with impound, transfers, shared keys and job fleets; takes the place of jg-advancedgarages'
version '0.1.0'

dependencies { 'ox_lib', 'oxmysql' }

-- Scripts written for jg-advancedgarages find this resource under that name (its exports, events and columns).
-- Never run both.
provide 'jg-advancedgarages'

shared_scripts {
    '@ox_lib/init.lua',
    'config/cfg_main.lua',
    'config/cfg_garages.lua',
    'shared/sh_defaults.lua',
    'locales/*.lua',
    'shared/sh_core.lua',
    'bridge/init.lua',
    'bridge/framework.lua',
}

client_scripts {
    'bridge/vehicle.lua',
    'bridge/interact.lua',
    'client/cl_main.lua',
    'client/cl_vehicle.lua',
    'client/cl_director.lua',
    'client/cl_showroom.lua',
    'client/cl_garage.lua',
    'client/cl_impound.lua',
    'client/cl_zones.lua',
    'client/cl_interior.lua',
    'client/cl_private.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'packages/logs/locales/*.lua',
    'packages/logs/server.lua',
    'server/sv_main.lua',
    'server/sv_garages.lua',
    'bridge/society.lua',
    'bridge/business.lua',
    'bridge/phone.lua',
    'server/sv_vehicles.lua',
    'server/sv_impound.lua',
    'server/sv_transfer.lua',
    'server/sv_business.lua',
    'server/sv_jobs.lua',
    'server/sv_admin.lua',
    'server/sv_private.lua',
    'server/sv_interior.lua',
    'server/sv_compat.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'images/*',
}

-- Readable in the escrow build too: the config files, the texts and every bridge file.
escrow_ignore {
    'config/*.lua',
    'locales/*.lua',
    'bridge/*.lua',
}
