shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_arcadepad'
author 'Daddy Studio'
description 'Arcade Pad: multiplayer party games on a handheld'
version '1.0.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/text.lua',
    'server/rooms.lua',
    'server/games/*.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'install/**/*.lua',
}
