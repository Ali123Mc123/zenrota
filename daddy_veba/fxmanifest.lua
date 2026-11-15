shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_veba'
author 'Daddy Studio'
description 'One-day plague event: staff rats bite, the sickness grows in stages, the infirmary cures it'
version '1.0.0'

dependencies { 'ox_lib', 'daddy_lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config/main.lua',
    'locales/*.lua',
}

client_scripts {
    'client/effects.lua',
    'client/rats.lua',
    'client/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/sounds/*',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}
