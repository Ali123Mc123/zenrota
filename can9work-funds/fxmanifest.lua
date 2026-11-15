shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'can9work'
description 'can9work Money | Company'
version '1.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    'Settings.lua',
    'modules/framework/_default/*.lua',
    'modules/framework/qb-core/*.lua',
    'modules/framework/qbx_core/*.lua',
    'modules/framework/es_extended/*.lua',
}

client_scripts {
    'modules/**/**/client.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/**/**/server.lua',
    'server/logs.lua',
    'server/main.lua',
}

dependencies {
    '/onesync',
    'ox_lib'
}








