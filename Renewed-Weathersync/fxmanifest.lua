shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_fxv2_oal 'yes'
name 'Renewed Weather Sync'
author 'FjamZoo - Renewed Scripts'
version '1.1.8'
shared_scripts {
    '@ox_lib/init.lua',
}
client_scripts {
    'client/*.lua',
    'compatability/**/client.lua',
}
server_scripts {
    'server/time.lua',
    'server/weather.lua',
    'compatability/**/server.lua',
}
provide 'qb-weathersync'
provide 'cd_easytime'








