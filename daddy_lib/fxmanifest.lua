shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
node_version '22'

name 'daddy_lib'
author 'Daddy Studio'
description 'Shared library for Daddy Studio resources'
version '1.21.1'

dependencies { 'oxmysql' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config_sv.lua',
    'services/server/*.lua',
    'services/server/*.js',
}

client_scripts {
    'services/client/*.lua',
}

files {
    'init.lua',
    'imports/**/*.lua',
    'locales/*.lua',
}

-- Products read these with LoadResourceFile, so they cannot be encrypted.
escrow_ignore {
    'config_sv.lua',
    'init.lua',
    'imports/**/*.lua',
    'locales/*.lua',
}
