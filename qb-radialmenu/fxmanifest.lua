shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
version '1.1.0'
locales {
    'locales/*.json'
}
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client/utils.lua',
}
client_scripts {
    -- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (F3 > Blip Ac/Kapat isimleri).
    '@daddy_pausemenu/shim/blipnames.lua',
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'client/objects.lua',
    'client/news_objects.lua',
    'client/clothing.lua',
    'client/trunk.lua',
    'client/toggle_blips.lua'
}
server_scripts {
    'server/trunk.lua',
    'server/main.lua',
    'server/news_objects.lua',
}
files {
    'html/index.html',
    'html/css/main.css',
    'html/js/main.js',
    'html/js/RadialMenu.js',
    'locales/en.json',
    'locales/tr.json'
}
ui_page 'html/index.html'
lua54 'yes'








