shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version '1.10.0'

dependencies {
    "ox_lib",
    "tgiann-core",
    "tgiann-media-lib",
}

escrow_ignore {
    "configs/*.lua",
    "languages/*.lua",
    "client/editable.lua",
    "server/editable.lua",
    "shared/type.lua",
}

ui_page 'ui/build/index.html'

files {
    'ui/build/**.*',
}

shared_scripts {
    '@ox_lib/init.lua',
    "configs/config.lua",
    "languages/*.lua",
    "shared/*.lua",
}

client_scripts {
    "@tgiann-core/client/animHook.lua",
    "client/*.lua",
}

server_scripts {
    "server/*.lua",
}

dependency '/assetpacks'