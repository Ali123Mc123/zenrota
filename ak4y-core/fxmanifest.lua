shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 "yes"

version '1.0.2'

ui_page 'minigame/html/index.html'

files {
    'minigame/html/index.html',
    'minigame/html/*.js',
    'minigame/html/*.css',
}

client_scripts { 
    'inventories/**/client.lua',
    'notification.lua',
    'playerLoaded.lua',
    'mugshot.lua',
    'target.lua',
    'clothing/**/client.lua',
    'minigame/client/client.lua',
    'framework/**/client.lua',
    'functions/client.lua',
    'callback/client.lua',
    'interaction/client.lua',
    'deadControl.lua'
}

server_scripts {
    'serverconfig.lua',
    '@oxmysql/lib/MySQL.lua',
    'framework/**/server.lua',
    'inventories/**/server.lua',
    'functions/server.lua',
    'exports/server.lua',
    'callback/server.lua',
    'deadControlServer.lua'
}

shared_scripts {
    'config.lua',
    'inventories/shared.lua'
}

escrow_ignore {
    'inventories/**/client.lua',
    'notification.lua',
    'playerLoaded.lua',
    'mugshot.lua',
    'target.lua',
    'clothing/**/client.lua',
    'minigame/client/client.lua',
    'framework/**/client.lua',
    'functions/client.lua',
    'callback/client.lua',
    'interaction/client.lua',
    'deadControl.lua',

    'serverconfig.lua',
    '@oxmysql/lib/MySQL.lua',
    'framework/**/server.lua',
    'inventories/**/server.lua',
    'functions/server.lua',
    'exports/server.lua',
    'callback/server.lua',
    'deadControlServer.lua',
    
    'config.lua',
    'inventories/shared.lua'
}
dependency '/assetpacks'