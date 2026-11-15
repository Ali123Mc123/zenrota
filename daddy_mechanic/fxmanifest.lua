shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_mechanic'
author 'Daddy Studio'
description 'Mechanic: workshops, repairs and tuning, every price and payment decided on the server'
version '0.1.0'

dependencies { 'ox_lib', 'oxmysql' }

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'locales/*.lua',
    'shared/core.lua',
    'shared/catalog.lua',
    'shared/tuning.lua',
    'bridge/framework.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/props.lua',
    'client/handling.lua',
    'client/main.lua',
    'client/menu.lua',
    'client/install.lua',
    'client/tablet.lua',
    'client/job.lua',
    'client/parts.lua',
    'client/service.lua',
    'client/nitro.lua',
    'client/lights.lua',
    'client/stance.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server.lua',
    'packages/logs/locales/*.lua',
    'packages/logs/server.lua',
    'bridge/server.lua',
    'server/main.lua',
    'server/vehicles.lua',
    'server/shops.lua',
    'server/repair.lua',
    'server/mods.lua',
    'server/orders.lua',
    'server/invoices.lua',
    'server/manage.lua',
    'server/ledger.lua',
    'server/parts.lua',
    'server/kits.lua',
    'server/tuning.lua',
    'server/service.lua',
    'server/nitro.lua',
    'server/lights.lua',
    'server/import.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'data/carcols_gen9.meta',
    'data/carmodcols_gen9.meta',
}

-- Chameleon paints (161-222): the game's gen9 paint list and its colour ramps (stream/vehicle_paint_ramps.ytd).
data_file 'CARCOLS_GEN9_FILE' 'data/carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'data/carmodcols_gen9.meta'

escrow_ignore {
    'config/*.lua',
    'locales/*.lua',
    'bridge/*.lua',
}
