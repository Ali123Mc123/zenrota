shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'can9work'
description 'Police Vehicle Stash'

shared_scripts {
    '@ox_lib/init.lua',
    'Settings.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'qbx_core',
    'ox_inventory'
}








