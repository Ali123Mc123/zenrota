shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version 'cerulean'
game 'gta5'

client_scripts {
        'client/main.lua'
}

server_scripts {
        'server/main.lua',
}

shared_scripts {
        "@ox_lib/init.lua"
}

lua54 'yes'








