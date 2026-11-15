shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
author 'Fuzion'
description 'A rental system for FiveM'
version 'v1.0.2'
ox_lib 'locale'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua',
}
client_scripts {
    'client/main.lua',
}
server_scripts {
    'server/main.lua'
}
files {
    'locales/*.json',
    'web/images/*.png',
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/fonts/*.woff2',
}
ui_page 'web/index.html'
lua54 'yes'








