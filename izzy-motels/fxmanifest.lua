shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author 'MustafaAta'
description 'izzy-motels'

lua54 'yes'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'editable/config.lua'
}

client_scripts {
    'client/*.lua',
    'editable/c_mugshot.lua',
    'editable/c_framework.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'editable/s_framework.lua',
    'server/*.lua'
}

files {
    'html/img/*.png',
    'html/fonts/*.woff2',
    'html/css/*.css',
    'html/js/**/*',
    'html/index.html',
}

ui_page 'html/index.html'

escrow_ignore {
    '**/**',
}

dependencies {
    'ox_lib',
    'oxmysql'
}

lua54 'yes'
dependency '/assetpacks'








