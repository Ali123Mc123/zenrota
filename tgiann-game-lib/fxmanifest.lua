shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version '1.0.0'

name "tgiann-game-lib"
description "Shared service library for TGIANN tabletop game scripts (sit, seat camera, mini ped, prop, state bag utilities). Modules run inside this resource; consumers fetch per-resource API tables through exports (sitUtilty = exports['tgiann-game-lib']:sitUtilty())."

dependencies {
        "ox_lib",
        "tgiann-core",
}

shared_scripts {
        "@ox_lib/init.lua",
}

client_scripts {
        "client/context.lua",
        "client/stateBag.lua",
        "client/raycast.lua",
        "client/keyHelp.lua",
        "client/prop.lua",
        "client/miniPed.lua",
        "client/cam.lua",
        "client/sit.lua",
        "client/placement.lua",
        "client/interact.lua",
        "client/main.lua",
}

server_scripts {
        "server/main.lua",
}

dependency '/assetpacks'



