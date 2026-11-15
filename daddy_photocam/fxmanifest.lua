shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_photocam'
author 'Daddy Studio'
description 'Photo camera: a free camera (hold V) and photo mode (F6)'
version '1.0.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config/main.lua',
    'locales/*.lua',
}

client_scripts {
    'client/world.lua',
    'client/cam.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/fonts/*.woff2',
}

escrow_ignore {
    'config/*.lua',
    'locales/*.lua',
}
