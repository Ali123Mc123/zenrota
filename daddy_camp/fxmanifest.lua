shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_camp'
author 'Daddy Studio'
description 'Daddy Camp: tents, campfires, lights in the hand and camp cooking anywhere'
version '1.1.2'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/*.lua',
}

client_scripts {
    'client/main.lua',
    'client/effects.lua',
    'client/options.lua',
    'client/place.lua',
    'client/hand.lua',
    'client/rest.lua',
    'client/cook.lua',
    'client/shop.lua',
    'client/tune.lua',
    'client/admin.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/actions.lua',
    'server/cook.lua',
    'server/admin.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
}
