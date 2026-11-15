shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
--
fx_version 'cerulean'
game 'gta5'
description 'QBX_Pawnshop'
repository 'https://github.com/Qbox-project/qbx_pawnshop'
version '1.0.0'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
}
client_scripts {
    'client/main.lua',
    'client/admin.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/admin.lua',
}
files {
    'config/client.lua',
    'config/shared.lua',
    'locales/*.json'
}
lua54 'yes'
use_experimental_fxv2_oal 'yes'
ox_lib 'locale'








