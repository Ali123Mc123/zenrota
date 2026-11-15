shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_gangs'
description 'Gangs: members, ranks, vault, stash, levels, diplomacy and wars'
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
    'config/levels.lua',
    'config/ranks.lua',
    'config/weapons.lua',
    'locales/*.lua',
    'shared/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/framework/esx.lua',
    'bridge/framework/qb.lua',
    'bridge/framework/qbox.lua',
    'bridge/framework/standalone.lua',
    'bridge/bank/internal.lua',
    'bridge/bank/custom.lua',
    'bridge/stash/ox.lua',
    'bridge/stash/qb.lua',
    'bridge/stash/qs.lua',
    'bridge/stash/custom.lua',
    'bridge/init.lua',
    'server/core/schema.lua',
    'server/core/migrate.lua',
    'server/core/lock.lua',
    'server/core/ratelimit.lua',
    'server/core/logs.lua',
    'server/core/cache.lua',
    'server/core/callbacks.lua',
    'server/core/scheduler.lua',
    'server/modules/gangs.lua',
    'server/modules/members.lua',
    'server/modules/ranks.lua',
    'server/modules/vault.lua',
    'server/modules/stash.lua',
    'server/modules/levels.lua',
    'server/modules/diplomacy.lua',
    'server/modules/wars.lua',
    'server/modules/social.lua',
    'server/modules/zones.lua',
    'server/modules/admin.lua',
    'server/exports.lua',
    'server/main.lua',
    'server/version.lua',
}

client_scripts {
    'client/main.lua',
    'client/access.lua',
    'client/kills.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
}

escrow_ignore {
    'config.lua',
    'config/*.lua',
    'locales/*.lua',
    'bridge/bank/custom.lua',
    'bridge/stash/custom.lua',
    'server/version.lua',
}
