shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author 'Retro Store'
description 'In-Game Interior Entity Set Manager and Editor'
version '0.1.1'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/img/*'
}

shared_scripts {
    'config.lua',
    'locales.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependency '/assetpacks'