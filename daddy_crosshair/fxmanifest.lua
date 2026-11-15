shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_crosshair'
author 'DADDYRP'
description 'DaddyRP sade nisangah (RP surumu)'
version '1.0.0'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'locales/*.json',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'settings/shared.lua',
    'shared/init.lua',
}

dependency 'daddy_lib'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}
