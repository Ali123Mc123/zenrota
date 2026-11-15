shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'zPug'
description 'Robbery Creator'
version '2.1.2'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    'config/config-framework.lua',
    'config/config.lua',
    'config/config-minigames.lua',
    'config/config-translation.lua',
}
server_scripts {    
    '@oxmysql/lib/MySQL.lua',
    'server/sv_banktruck.lua',
    'server/sv_sellitems.lua',
    'server/sv_atm.lua',
    'server/sv_pettycrimes.lua',
    'server/sv_houserobbery.lua',
    'server/sv_robberyintel.lua',
    'server/sv_robberylogs.lua',
    'server/server.lua',
    'server/sv_open.lua',
    'server/sv_community.lua',
}
client_scripts { 
    'client/*.lua',
    '@ox_lib/init.lua',
}

ui_page 'html/index.html'
files {
    'config/config-minigames.lua',
    'html/index.html',
    'html/tablet-translation.js',
    'html/app.js',
    'html/petty-crimes.js',
    'html/house-robbery.js',
    'html/style.css',
    'html/community.js',
    'html/community.css',
    'preset-info/*.json',
    'preset-info/mainrobbery-presets/*.json',
    'preset-info/house-presets/*.json',
    'preset-info/pettycrime-presets/*.json',
    'preset-info/banktruck-presets/*.json',
    'preset-info/atm-presets/*.json',
    'preset-info/sellitem-presets/*.json',
}

escrow_ignore {
    'config/config-translation.lua',
    'config/config-framework.lua',
    'config/config-minigames.lua',
    'config/config.lua',
    'server/sv_sellitems.lua',
    'server/sv_banktruck.lua',
    'server/sv_robberyintel.lua',
    'server/sv_open.lua',
    'server/sv_community.lua',
    'client/open.lua',
    'client/atm.lua',
    'client/sellitems.lua',
    'client/banktruck.lua',
    'html/index.html',
}

dependency '/assetpacks'