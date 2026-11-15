shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
client_script '@FeloxAC/modules/include/inGuard.lua'
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'ox_inventory'
author 'Overextended - Redesigned by { .kozylol }'
version '2.45.0'
repository 'https://github.com/communityox/ox_inventory'
description 'Slot-based inventory with item metadata support'
dependencies {
    '/server:6116',
    '/onesync',
    'oxmysql',
    'ox_lib',
}
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'
ox_libs {
    'locale',
    'table',
    'math',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua',
    's_utils.lua'
}
client_scripts {
    'init.lua',
    'cl_utils.lua'
}
ui_page 'web/build/index.html'
files {
    'client.lua',
    'server.lua',
    'locales/*.json',
    'web/build/index.html',
    'web/build/assets/*.js',
    'web/build/assets/*.css',
    'web/images/*.png',
    'web/sounds/*.ogg',
    'web/sounds/*.mp3',
    'modules/**/shared.lua',
    'modules/**/client.lua',
    'modules/bridge/**/client.lua',
    'data/*.lua',
}
escrow_ignore {
    'client.lua',
    'config.lua',
    'init.lua',
    'server.lua',
    'setup/*.lua',
    'modules/**/*.lua',
    'modules/**/**/*.lua',
    'data/*.lua',
    'install/*.lua',
}
dependency '/assetpacks'

