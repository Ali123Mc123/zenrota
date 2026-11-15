shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
use_experimental_fxv2_oal 'yes'
fx_version 'bodacious'
lua54 'yes'
game 'gta5'

author 'Ayazwai'
version '1.0.1'
scriptname 'wais-primehud'
description 'FiveM hud with customizable, advanced user interface and features. (PrimeHUD)'

shared_scripts {
    'config.lua',
    'locales/*.lua',
    'bridge/editable/location.lua',
    'bridge/editable/weapons.lua',
    'bridge/editable/postal.lua',
    'bridge/vrp/proxy.lua',
    'bridge/framework.lua',
    '@ox_lib/init.lua',
    'bridge/speaker.lua',
}

client_scripts {
    'bridge/editable/belt.lua',
    'bridge/editable/client.lua',
    'bridge/esx/client.lua',
    'bridge/qb/client.lua',
    'bridge/vrp/client.lua',
    'client/client.lua',
    'bridge/editable/debug.lua',
}

server_scripts {
    'bridge/editable/server.lua',
    'bridge/esx/server.lua',
    'bridge/qb/server.lua',
    'bridge/vrp/server.lua',
    'server/server.lua',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'bridge/editable/*.lua',
    'bridge/vrp/*.lua',
}

dependencys {
    'ox_lib',
}

ui_page "web/dist/index.html"
files {
    'web/dist/*.js',
    'web/dist/*.css',
    'web/dist/index.html',
    'web/public/*.json',
    'web/public/fonts/*.*',
    'web/public/images/**/*',
    'web/public/locales/*.json',
    'web/public/sounds/*.ogg',
    'masks/*.png',
    'bridge/vrp/client_ext.lua',
}

dependency '/assetpacks'