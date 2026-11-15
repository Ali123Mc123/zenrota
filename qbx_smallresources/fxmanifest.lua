shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
name 'qbx_smallresources'
description 'Collection of small scripts'
repository 'https://github.com/Qbox-project/qbx_smallresources'
version '0.2.0'
ox_lib 'locale'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua'
}
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    '**/client.lua'
}

server_script '**/server.lua'
files {
    'locales/*.json',
    '**/config.json',
    '**/config.lua'
}
dependencies {
    'ox_lib',
    'qbx_core'
}
lua54 'yes'
use_experimental_fxv2_oal 'yes'








