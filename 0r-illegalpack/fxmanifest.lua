shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'

fx_version 'cerulean'
lua54 'yes'
game 'gta5'
name '0r-illegalpack'
author '0resmon & alikoc.dev'
version '1.1.0'
description 'Illegal Job Pack | alikoc.dev'

shared_scripts {
        '@ox_lib/init.lua',
        '@qbx_core/modules/lib.lua',
        'config.lua',
        'shared/init.lua',
}

files {
        'locales/*.json',
        'modules/**/client.lua',
        'modules/bridge/init.lua',
        'escrow/**/config.lua',
        'ui/build/index.html',
        'ui/build/**/*',
        'stream/horoz_cage.ytyp',
}

client_scripts {
        'client.lua',
        'escrow/jobs/client_index.lua',
        'escrow/**/client.lua',
        'shared/client_debug.lua',
}

server_scripts {
        '@oxmysql/lib/MySQL.lua',
        'server.lua',
        'escrow/jobs/server_index.lua',
        'escrow/**/server.lua',
}

ui_page 'ui/build/index.html'

data_file 'DLC_ITYP_REQUEST' 'stream/horoz_cage.ytyp'

dependencies { 'ox_lib', 'oxmysql', '0r_lib' }

escrow_ignore "**/*.lua"
dependency '/assetpacks'






