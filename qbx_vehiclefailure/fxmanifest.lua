shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent'
fx_version 'cerulean'
game 'gta5'
description 'qbx_vehiclefailure'
repository 'https://github.com/Qbox-project/qbx_vehiclefailure'
version '1.0.0'
ox_lib 'locale'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}
client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}
files {
    'locales/*.json'
}
server_script 'server/main.lua'
lua54 'yes'
use_experimental_fxv2_oal 'yes'







