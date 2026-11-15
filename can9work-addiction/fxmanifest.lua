shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version "cerulean"
games { "gta5" }

description "can9work | Addiction System"
author "can9work"
version "1.0.0"
lua54 "yes"

dependencies {
    'ox_lib',
    'ox_inventory',
    'oxmysql'
}

shared_scripts {
    "@ox_lib/init.lua",
    "Settings.lua",
    "init.lua"
}

client_scripts {
    "client/functions/*.lua",
    "client/*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/functions/*.lua",
    "server/*.lua"
}

ui_page 'html/index.html'

files {
    'locales/*.json',
    'html/index.html',
    'html/sounds/*'
}








