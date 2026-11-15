shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
shared_script '@ox_lib/init.lua'
--
fx_version 'cerulean'
game 'gta5'
client_scripts {
    'config.lua',
    'client/main.lua'
}
server_scripts {
    'config.lua',
    'server/main.lua'
}








