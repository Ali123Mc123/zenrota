shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
version '2.0.1'
lua54 'yes'

dependencies {
    'PolyZone',
    'tgiann-core',
}

escrow_ignore {
    "configs/*.lua",
    "server/editable.lua",
    "client/editable.lua",
    "languages/*.lua",
}

client_scripts {
    "@PolyZone/client.lua",
    "configs/*.lua",
    "languages/*.lua",
    "client/*.lua",
}

server_scripts {
    "configs/*.lua",
    "server/*.lua",
}
dependency '/assetpacks'








