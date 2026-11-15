shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy-marketplace'
author 'Daddy Studios'
description 'Daddy Marketplace - Advanced Item Marketplace & Auction System'
version '1.0.0'

dependencies {
    '/server:5104',
    'oxmysql',
}

-- Shared (client + server)
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    'config.lua',
    'modules/locale/shared.lua',
    'locales/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    -- Framework & inventory bridges
    'modules/framework/bridge.lua',
    'modules/framework/qb.lua',
    'modules/framework/qbx.lua',
    'modules/framework/esx.lua',
    'modules/inventory/bridge.lua',

    -- Shared Discord log look
    'packages/logs/locales/*.lua',
    'packages/logs/server.lua',

    -- Core
    'server/database.lua',
    'server/discord.lua',
    'server/main.lua',
    'server/listings.lua',
    'server/auctions.lua',
    'server/offers.lua',
    'server/buyorders.lua',
    'server/admin.lua',
    'server/validate.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

