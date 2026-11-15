shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'can9work'
description 'can9work | Grandma'
version '1.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    'Settings.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    '/onesync'
}




