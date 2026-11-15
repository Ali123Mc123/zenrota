shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
name 'qbx_policejob'
description 'Police system for Qbox'
repository 'https://github.com/Qbox-project/qbx_policejob'
version '1.0.0'
ox_lib 'locale'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
ui_page 'html/index.html'
files {
    'html/index.html',
    'html/jquery.min.js',
    'html/vue.min.js',
    'html/script.js',
    'html/fingerprint.png',
    'html/main.css',
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}
lua54 'yes'
use_experimental_fxv2_oal 'yes'


