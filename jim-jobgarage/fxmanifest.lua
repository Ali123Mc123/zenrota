shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
name "Jim-JobGarage"
author "Jimathy"
version "2.0.02"
description "Job Vehicle Script"
fx_version "cerulean"
game "gta5"
lua54 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
    'locales/*.lua*',
    'config.lua',

    --Jim Bridge - https://github.com/jimathy/jim-bridge
    '@jim_bridge/starter.lua',

    'shared/*.lua',
}

client_scripts {
    'client.lua',
}

server_script {
    'server.lua',
}
dependencies {
    'jim_bridge',
    'ox_lib'
}








