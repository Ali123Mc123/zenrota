shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
games { 'gta5' }

author 'Savana Scripts'
description 'savana.tebex.io'
version '1.0.1'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'editable/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'editable/s_framework.lua',
    'server/*.lua'
}

client_scripts {
    'editable/c_framework.lua',
    'editable/c_fuel.lua',
    'client/*.lua'
}

files {
    'html/index.html',
    'html/css/*.css',
    'html/img/*.png',
    'html/js/*.js',
    'html/font/*.woff2',
}

ui_page 'html/index.html'

dependencies {
    'ox_lib',
    'oxmysql'
}

exports {
    'GetFuel',
    'SetFuel'
}

lua54 'yes'

escrow_ignore {
    'editable/*.lua',
    'client/*.lua',
    'server/*.lua'
}
dependency '/assetpacks'








