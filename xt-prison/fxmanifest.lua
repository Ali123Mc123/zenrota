shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'xT Development'
description 'Prison for QB, QBX, OX, ND, & ESX'
repository 'https://github.com/xT-Development/xt-prison'
version '1.4.5'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts { '@ox_lib/init.lua' }

client_scripts {
    'bridge/client/*.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/compat/server.lua',
    'bridge/server/*.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'locales/*.json',
    'configs/*.lua',
    'modules/client/*.lua',
    'bridge/compat/client.lua',
    'bridge/compat/resources.lua',
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*.woff2'
}

ox_libs { 'locale' }








