shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_lockers'
author 'Daddy Studio'
description 'Daddy Lockers: rentable lockers with PINs, name plates and a lost-and-found'
version '1.2.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib', 'daddy_college' }

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'packages/kit/locales/*.lua',
}

client_scripts {
    'packages/world/client.lua',
    'packages/world/draw.lua',
    'packages/world/shapes.lua',
    'packages/world/cursor.lua',
    'packages/world/placement.lua',
    'packages/world/editor.lua',
    'packages/kit/nui.lua',
    'client/main.lua',
    'client/notes.lua',
    'client/owner.lua',
    'client/nameplates.lua',
    'client/admin.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'packages/world/server.lua',
    'migrations/*.lua',
    'server/state.lua',
    'server/storage.lua',
    'server/rentals.lua',
    'server/extras.lua',
    'server/admin.lua',
    'server/grants.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/nameplate.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'packages/kit/locales/*.lua',
}
