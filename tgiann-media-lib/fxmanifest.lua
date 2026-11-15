shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version '1.5.1'
author 'TGIANN'

dependencies {
    "ox_lib",
    "tgiann-core",
}

ui_page "ui/build/index.html"

files {
    "ui/build/**.*",
}

escrow_ignore {
    "client/editable.lua",
    "server/editable.lua",
    "server/storageCustom.lua",
    "configs/*.lua",
    "languages/*.lua",
    "shared/type.lua",
}

shared_scripts {
    "@ox_lib/init.lua",
    "@tgiann-core/shared/functions/export.lua",
    "configs/config.lua",
    "languages/*.lua",
    "shared/*.lua",
}

client_scripts {
    "client/main.lua",
    "client/editable.lua",
    "client/utilty/*.lua",
    "client/classes/*.lua",
    "client/gameRender.lua",
    "client/photo.lua",
    "client/catalogShoot.lua",
    "client/vehicleShoot.lua",
    "client/manager.lua",
}

server_scripts {
    "configs/configStorageServer.lua",
    "server/main.lua",
    "server/editable.lua",
    "server/storageCustom.lua",
    "server/utilty/*.lua",
    "server/storage.lua",
    "server/owners.lua",
    "server/photos.lua",
    "server/studio.lua",
    "server/resourceImages.lua",
    "server/vehiclePhotos.lua",
    "server/media.lua",
    "server/upload.js",
    "server/migration.lua",
}

dependency '/assetpacks'