shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Prodigy Studios"
version "1.0.1"

shared_scripts {
    "@ox_lib/init.lua",
    "@prp-bridge/import.lua",
    "init.lua"
}

files {
    "locales/*.json",
    "ui/**/*",
    'stream/*.ytyp',
}

ui_page "ui/index.html"

client_scripts {
    "client/*"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/*"
}

escrow_ignore {
    "server/**/*.lua",
    "config.lua",
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
dependency '/assetpacks'



