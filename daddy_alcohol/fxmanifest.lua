shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_alcohol'
author 'Daddy Roleplay'
description 'Alcohol system with audio effects, drunk driving, and sobering items'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/audio.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
