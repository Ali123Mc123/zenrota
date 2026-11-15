shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "Savana Scripts"
description 'savana.tebex.io'

shared_script {
        '@ox_lib/init.lua',
        "config.lua"
}

ui_page {
        'html/index.html'
}

files {
    'html/**/**.**'
}

client_scripts {
        'utils/client.lua',
        'utils/mugshot.lua',
        'client/*.lua',
}

server_scripts {
        '@oxmysql/lib/MySQL.lua',
        'utils/server.lua',
        'server/*.lua',
}

escrow_ignore {
        'client/*.lua',
        'server/*.lua',
    'config.lua',
        'utils/*.lua'
}

dependencies {
    'ox_lib'
}

exports {
    'openMenu',
        'openDashboard'
}

dependency '/assetpacks'







