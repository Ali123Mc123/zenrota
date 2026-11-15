shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent,clientNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_campustour'
author 'Daddy Roleplay'
description 'Admin tour of the College places on the Cayo campus: stop by stop, with a marker on every moved point'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

files {
    'data/points.json',
}

dependencies {
    'ox_lib',
}
