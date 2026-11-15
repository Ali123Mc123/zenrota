shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"

lua54 "yes"
shared_script "@ox_lib/init.lua"

author "Prodigy Studios"
version "1.0.0"

files {
    "dui/dist/**/*",
}

client_scripts {
    "client.lua",
}

escrow_ignore {
    "server/**/*.lua",
    "config/**/*.lua",
    "shared/**/*.lua",
}

dependency '/assetpacks'



