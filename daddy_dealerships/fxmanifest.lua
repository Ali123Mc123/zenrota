shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_dealerships'
author 'Daddy Studio'
description 'Dealerships: the cars stand in a row in a showroom hall, the price lies on the floor; takes the place of jg-dealerships'
version '0.2.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_showroom' }

-- Scripts written for jg-dealerships find this resource under that name (its tables and columns). Never run both.
provide 'jg-dealerships'

shared_scripts {
    '@ox_lib/init.lua',
    'config/cfg_main.lua',
    'config/cfg_locations.lua',
    'locales/*.lua',
    'shared/sh_core.lua',
    'bridge/init.lua',
    'bridge/framework.lua',
}

client_scripts {
    'bridge/vehicle.lua',
    'bridge/interact.lua',
    'bridge/world.lua',
    'client/cl_main.lua',
    'client/cl_used.lua',
    'client/cl_hall.lua',
    'client/cl_buy.lua',
    'client/cl_finance.lua',
    'client/cl_drive.lua',
    'client/cl_display.lua',
    'client/cl_manage.lua',
    'client/cl_sale.lua',
    'client/cl_admin.lua',
    'client/cl_photos.lua',
    'client/cl_sell.lua',
    'client/cl_zones.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server/cfg_server.lua',
    'bridge/society.lua',
    'packages/logs/locales/*.lua',
    'packages/logs/server.lua',
    'server/sv_logs.lua',
    'server/sv_till.lua',
    'server/sv_settings.lua',
    'server/sv_main.lua',
    'server/sv_staff.lua',
    'server/sv_finance.lua',
    'server/sv_coupons.lua',
    'server/sv_campaigns.lua',
    'server/sv_used.lua',
    'server/sv_drive.lua',
    'server/sv_display.lua',
    'server/sv_manage.lua',
    'server/sv_sale.lua',
    'server/sv_refunds.lua',
    'server/sv_admin.lua',
    'server/sv_photos.lua',
    'server/sv_sell.lua',
    'server/sv_room.lua',
    'server/sv_buy.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'images/*',
}

-- Readable in the escrow build too: the config files, the texts and every bridge file.
escrow_ignore {
    'config/*.lua',
    'config/server/*.lua',
    'locales/*.lua',
    'bridge/*.lua',
}
