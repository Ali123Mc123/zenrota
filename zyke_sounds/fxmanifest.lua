shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version "cerulean"
game "gta5"
lua54 "yes"
author "https://discord.zykeresources.com"
version "0.6.0"

ui_page "nui/index.html"

files {
    "nui/**/*",
    "nui/sounds/**/*",
    "locales/*.lua"
}

shared_script "@zyke_lib/imports.lua"

shared_scripts {
    "shared/config.lua"
}

client_scripts {
    "client/main.lua",
    "client/functions.lua",
    "client/eventhandler.lua",
    "client/menu.lua",
    "client/debug.lua",
}

server_scripts {
    "server/sound_scanner.js",
    "server/functions.lua",
    "server/eventhandler.lua"
}

dependency "zyke_lib"