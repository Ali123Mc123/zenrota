shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_election'
author 'Daddy Studio'
description 'Election: offices, candidates, ballot stations and secret votes'
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
    'server/store.lua',
    'server/api.lua',
    'server/flow.lua',
    'server/booth.lua',
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
