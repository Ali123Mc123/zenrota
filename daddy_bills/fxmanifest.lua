shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_bills'
description 'Bills, fines and receipts on a tablet'
version '0.0.1'

dependencies {
    'ox_lib',
    'oxmysql',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/framework/esx.lua',
    'bridge/framework/qb.lua',
    'bridge/framework/qbox.lua',
    'bridge/framework/standalone.lua',
    'bridge/society/esx.lua',
    'bridge/society/qb.lua',
    'bridge/society/custom.lua',
    'bridge/init.lua',
    'server/core/schema.lua',
    'server/core/migrate.lua',
    'server/core/lock.lua',
    'server/core/ratelimit.lua',
    'server/core/callbacks.lua',
    'server/bills.lua',
    'server/jobs.lua',
    'server/logs.lua',
    'server/scheduler.lua',
    'server/actions.lua',
    'server/admin.lua',
    'server/boss.lua',
    'server/templates.lua',
    'server/receipts.lua',
    'server/reports.lua',
    'server/exports.lua',
    'bridge/compat/common.lua',
    'bridge/compat/esx_billing.lua',
    'bridge/compat/okokBilling.lua',
    'server/import.lua',
    'bridge/phone/daddy_studentphone.lua', -- DaddyRP
    'server/checks.lua',
    'server/main.lua',
    'server/version.lua',
}

client_scripts {
    'client/main.lua',
}

-- other scripts keep calling exports.esx_billing and its events, remove esx_billing from server.cfg
provide 'esx_billing'
provide 'okokBilling'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'bridge/society/custom.lua',
    'server/version.lua',
}
