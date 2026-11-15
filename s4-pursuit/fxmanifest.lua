shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author '0Resmon'
description 'S4 Pursuit'
version '1.2.0'

lua54 'yes'

client_scripts {

    'config.lua',

    'client.lua'
}

server_scripts {
    'config.lua',
    'framework.lua',
    'server.lua'
}
shared_script '@ox_lib/init.lua'
dependency 'ox_lib'

escrow_ignore {
    'config.lua', 'client.lua', 'server.lua'
}

dependency '/assetpacks'








