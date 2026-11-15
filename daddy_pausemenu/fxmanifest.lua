shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_pausemenu'
author 'Daddy Studio'
description 'Pause Menu: replaces GTA pause menu with map, stats, game settings, photo mode and the player card'
version '0.0.1'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

-- Both sides: the core data and the stats catalog (server/stats uses PMStats). The rest of shared/ is client-only data,
-- listed below, so the server does not parse it.
shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/core.lua',
    'shared/stats_def.lua',
}

-- Client-only data first (client/settings reads PMSettings.ROWS as it loads), then the core (it defines PM), then one
-- folder per module. FXServer globs only the last path part: list each folder.
client_scripts {
    'shared/map_categories.lua',
    'shared/photo_data.lua',
    'shared/settings_catalog.lua',
    'shared/settings_check.lua',
    'shared/settings_layout.lua',
    'client/main.lua',
    'client/core/*.lua',
    'client/settings/*.lua',
    'client/driver/*.lua',
    'client/stats/*.lua',
    'client/map/*.lua',
    'client/photo/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/core/*.lua',
    'server/stats/*.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'shim/blipnames.lua', -- loaded by other resources: client_script '@daddy_pausemenu/shim/blipnames.lua'
}
-- stream/daddy_dxr*.gfx: the graphics settings reader GTA's settings menu loads by name (client/driver/read.lua), 16
-- copies because GTA takes each name once per game session; built by tools/pausemenu/dxr/build.mjs.

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'shim/blipnames.lua',
}
