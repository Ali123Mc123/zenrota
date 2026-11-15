shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_campuslife'
author 'Daddy Studio'
description 'Daddy Campus Life: canteen, student shop, vending machines, infirmary, chairs, floor plans, the gym and janitors'
version '1.3.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib', 'daddy_college' }

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'config/*.lua',
    'locales/*.lua',
    'packages/kit/locales/*.lua',
    'packages/chores/shared.lua',
}

client_scripts {
    'packages/world/client.lua',
    'packages/world/draw.lua',
    'packages/world/shapes.lua',
    'packages/world/cursor.lua',
    'packages/world/placement.lua',
    'packages/world/editor.lua',
    'packages/world/worldedit.lua',
    'packages/world/panel.lua',
    'packages/chores/tools.lua',
    'packages/chores/client.lua',
    'packages/kit/nui.lua',
    'client/main.lua',
    'client/canteen.lua',
    'client/shop.lua',
    'client/nurse.lua',
    'client/chairs.lua',
    'client/floors.lua',
    'client/admin.lua',
    'client/janitor/main.lua',
    'client/janitor/flood.lua',
    'client/janitor/power.lua',
    'client/janitor/rat.lua',
    'client/janitor/lawn.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'packages/world/server.lua',
    'packages/world/admin.lua',
    'packages/chores/server.lua',
    'packages/chores/minigame.lua',
    'migrations/*.lua',
    'server/state.lua',
    'server/shop/core.lua',
    'server/shop/places.lua',
    'server/shop/self.lua',
    'server/shop/staff.lua',
    'server/shop/stock.lua',
    'server/shop/phone.lua',
    'server/canteen.lua',
    'server/vending.lua',
    'server/nurse.lua',
    'server/chairs.lua',
    'server/admin.lua',
    'server/janitor/rules.lua',
    'server/janitor/state.lua',
    'server/janitor/panel.lua',
    'server/janitor/flood.lua',
    'server/janitor/power.lua',
    'server/janitor/rat.lua',
    'server/janitor/lawn.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'floors/*',
}

escrow_ignore {
    'config.lua',
    'config/*.lua',
    'locales/*.lua',
    'packages/kit/locales/*.lua',
}
