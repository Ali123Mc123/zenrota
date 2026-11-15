shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version "cerulean"
game "gta5"
lua54 "yes"
use_experimental_fxv2_oal "yes"
author "yiruzu"
description "Cloud Resources - Shop"
version "3.0.1"
support "https://discord.gg/jAnEnyGBef"
documentation "https://docs.cloud-resources.eu/"
repository "https://github.com/cloud-resources/cloud-shop"
dependencies { "ox_lib" }
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    "@ox_lib/init.lua",
    "shared/utils/*.lua",
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "bridge/server/*.lua",
    "server/utils/*.lua",
    "server/modules/*.lua",
    "server/*.lua",
}
client_scripts {
    "bridge/client/*.lua",
    "client/utils/*.lua",
    "client/main.lua",
}
files {
    "web/dist/**/*",
    "config/*.lua",
    "locales/*.json",
    "client/modules/*.lua",
}
ui_page { "web/dist/index.html" }








