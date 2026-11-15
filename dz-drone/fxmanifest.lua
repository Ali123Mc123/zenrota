shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
shared_script '@ox_lib/init.lua'
game 'gta5'

author 'Danzo'
description 'Advanced Drone - Made by Danzo - Discord: https://discord.gg/8nFqCR4xVC'
version '1.1.5'

shared_script "config.lua"

client_scripts {
        'client/functions.lua',
        'client/client.lua',
}

server_scripts {
        '@mysql-async/lib/MySQL.lua',
        '@oxmysql/lib/MySQL.lua',
        'server/server.lua',
}

escrow_ignore {
        'config.lua',
        'client/client.lua',
        'server/server.lua',
        'stream/ch_prop_casino_drone_02a.yft',
}

ui_page 'html/index.html'

files {
        'html/**/**',
}

lua54 'yes'
dependency '/assetpacks'








