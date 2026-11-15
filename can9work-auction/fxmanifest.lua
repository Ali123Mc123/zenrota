shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'can9work'
description 'can9work | Advanced Auction & Consortium System'
version '1.0.0'

ui_page 'resources/dist/index.html'

files {
    'resources/dist/index.html',
    'resources/dist/assets/**/*',
    'resources/dist/**/*',
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    'Settings.lua',
    'locales/loader.lua'
}

client_scripts {
    'client/main.lua',
    'client/npc.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/sites.lua',
    'server/npc.lua',
    'server/market.lua',
    'server/main.lua',
    'server/panel.lua',
    'server/admin.lua'
}

dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_inventory',
    'ox_target'
}

lua54 'yes'
