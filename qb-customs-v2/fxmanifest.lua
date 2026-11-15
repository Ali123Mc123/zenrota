shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version 'cerulean'
game 'gta5'
ui_page 'html/index.html'
files {
    'html/index.html',
    'html/assets/**/*',
    'html/sounds/**/*',
    'locales/**/*'
}
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/locations.lua',
}
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/cl_ui.lua',
    'client/cl_bennys.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_bennys.lua'
}
lua54 'yes'








