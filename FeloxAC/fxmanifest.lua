fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '4.1.112'
author 'FeloxAC'
description 'FeloxAC Anti-Cheat System'

ui_page 'web/ui.html'

shared_scripts {
    "shared/include.lua",

}

client_scripts {
    "client/bootstrap.lua",
    "client/ai_module.lua",

}

server_scripts {
    "server/main.lua",
    "server/ai_module.lua",
    "server/filewriter.js",
    "server/webhookMedia.js",
    "server/ws.js",
    "server/wsClient.js",
}

files {
    "web/ui.html",
    "web/ui.js",
    "web/i18n.js",
    "web/recorderPolicy.js",
    "web/recorder.js",
    "web/ui.css",
    "web/instrument-sans-latin.woff2",
    "web/instrument-sans-latin-ext.woff2",
    "modules/include/shared.lua",
    "modules/include/client.lua",
    "modules/include/server.lua",
    "modules/include/guard_runtime.lua",
    "modules/include/client_guard.lua",
    "modules/include/server_guard.lua",
    "modules/include/weaponGuard.lua",
    "modules/include/server_entity_guard.lua",
    "modules/include/inGuard.lua",
    "modules/include/txadmin_monitor_guard.lua",
    "modules/include/client_entity_guard.lua",
    "shared/eventRegistry.lua",
}

dependencies {
    "/server:14317",
    "/onesync",
}

escrow_ignore {
    "modules/include/shared.lua",
    "modules/include/client.lua",
    "modules/include/server.lua",
    "modules/include/guard_runtime.lua",
    "modules/include/client_guard.lua",
    "modules/include/server_guard.lua",
    "modules/include/weaponGuard.lua",
    "modules/include/server_entity_guard.lua",
    "modules/include/inGuard.lua",
    "modules/include/txadmin_monitor_guard.lua",
    "modules/include/client_entity_guard.lua",
    "shared/eventRegistry.lua",
}
