shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'

author 'Daddy Fakeplate'
description 'Modern QBX & OxLib Fakeplate System'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

exports {
    'useFakePlate',
    'usePlateRestoreKit',
    'GetOriginalPlate',
    'GetFakePlate'
}




