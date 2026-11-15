shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version "cerulean"
games { "gta5" }

description "can9work | Character Delete"
author "can9work"
version "1.0.0"
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "Settings.lua"
}

client_script "client/*.lua"
server_script { "server/*.lua", "@oxmysql/lib/MySQL.lua" }








