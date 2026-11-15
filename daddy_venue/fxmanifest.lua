shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_venue'
description 'Restaurant and business management'
version '0.0.1'

dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql',
}

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/main.lua',
    'shared/permissions.lua',
    'shared/geometry.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/catalog.lua',
    'bridge/framework/esx.lua',
    'bridge/framework/qb.lua',
    'bridge/framework/qbox.lua',
    'bridge/framework/standalone.lua',
    'bridge/bank/internal.lua',
    'bridge/bank/custom.lua',
    'bridge/inventory/ox.lua',
    'bridge/inventory/esx.lua',
    'bridge/inventory/qb.lua',
    'bridge/inventory/others.lua',
    'bridge/inventory/init.lua',
    'bridge/billing/esx_billing.lua',
    'bridge/billing/daddy_bills.lua',
    'bridge/billing/custom.lua',
    'bridge/billing/init.lua',
    'bridge/init.lua',
    'server/core/net.lua',
    'server/core/schema.lua',
    'server/core/migrate.lua',
    'server/core/ratelimit.lua',
    'server/core/lock.lua',
    'server/core/audit.lua',
    'server/core/scheduler.lua',
    'server/core/business.lua',
    'server/core/money.lua',
    'server/core/hooks.lua',
    'server/core/credits.lua',
    'server/core/notices.lua',
    'server/core/features.lua',
    'server/core/callbacks.lua',
    'server/modules/session.lua',
    'server/modules/settings.lua',
    'server/modules/dashboard.lua',
    'server/modules/finance.lua',
    'server/modules/menu.lua',
    'server/modules/stock.lua',
    'server/modules/pricing.lua',
    'server/modules/orders.lua',
    'server/modules/kiosk.lua',
    'server/modules/staff.lua',
    'server/modules/offers.lua',
    'server/modules/schedule.lua',
    'server/modules/hiring.lua',
    'server/modules/promos.lua',
    'server/modules/reviews.lua',
    'server/modules/kitchen.lua',
    'server/modules/delivery.lua',
    'server/modules/places.lua',
    'server/modules/objects.lua',
    'server/modules/packs.lua',
    'server/modules/shells.lua',
    'server/modules/property.lua',
    'server/modules/admin.lua',
    'server/modules/payroll.lua',
    'server/modules/performance.lua',
    'server/modules/setup.lua',
    'server/modules/consume.lua',
    'server/modules/billing.lua',
    'server/main.lua',
    'server/version.lua',
}

client_scripts {
    'client/net.lua',
    'client/main.lua',
    'client/interact.lua',
    'client/points.lua',
    'client/zone.lua',
    'client/places.lua',
    'client/objects.lua',
    'client/station.lua',
    'client/crates.lua',
    'client/display.lua',
    'client/shells.lua',
    'client/build.lua',
    'client/consume.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'dui/display.html',
}

escrow_ignore {
    'config.lua',
    'config/*.lua',
    'locales/*.lua',
    'bridge/bank/custom.lua',
    'bridge/billing/custom.lua',
    'server/version.lua',
}
