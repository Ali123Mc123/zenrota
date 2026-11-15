shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version '1.3.0'

dependencies {
    "ox_lib",
    "tgiann-core",
    "tgiann-phone-accessories-assets",
    "tgiann-media-lib",
}

ui_page "ui/build/index.html"

files {
    "ui/build/**.*",
    "ui/app/**.*",
}

escrow_ignore {
    "client/editable.lua",
    "configs/*.lua",
    "languages/*.lua",
    "server/editable.lua",
    "shared/type.lua",
}

shared_scripts {
    "@ox_lib/init.lua",
    "configs/config.lua",
    "configs/configCatalog.lua",
    "configs/configPlacement.lua",
    "configs/configApp.lua",
    "languages/*.lua",
    "shared/main.lua",
    "shared/catalog.lua",
    "shared/custom.lua",
}

client_scripts {
    "client/utilty/*.lua",
    "client/classes/phoneRig.lua",
    "client/classes/editorHistory.lua",
    "client/classes/editor.lua",
    "client/editable.lua",
    "client/main.lua",
    "client/editorNui.lua",
    "client/stores.lua",
    "client/handPhones.lua",
    "client/app/hosts.lua",
    "client/app/bridge.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@tgiann-core/server/databaseCreator/main.lua",
    "server/classes/*.lua",
    "server/editable.lua",
    "server/database.lua",
    "server/main.lua",
    "server/phones.lua",
    "server/handState.lua",
    "server/editor.lua",
    "server/savedDesigns.lua",
    "server/collection.lua",
    "server/app/main.lua",
    "server/app/hosts.lua",
    "server/app/accounts.lua",
    "server/app/social.lua",
    "server/app/casely.lua",
}

dependency '/assetpacks'