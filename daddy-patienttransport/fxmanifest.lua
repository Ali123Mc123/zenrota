shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy-patienttransport'
author 'Daddy Studios'
description 'Stretcher and wheelchair patient transport for EMS'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config/config.lua',
    'config/cfg_sync.lua',
    'config/cfg_stretcher.lua',
    'config/cfg_wheelchair.lua',
    'bridge/shared.lua',
    'shared/utils.lua',
    'shared/models.lua',
    'shared/mechanism.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/permissions.lua',
    'client/sync_manager.lua',
    'client/stretcher_mechanism.lua',
    'client/stretcher.lua',
    'client/wheelchair.lua',
    'client/test.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/permissions.lua',
    'server/sync_manager.lua',
    'server/stretcher.lua',
    'server/wheelchair.lua',
}

dependencies {
    '/onesync',
    'ox_lib',
    'daddy-patienttransport-props',
}

-- Asset Escrow: every shipped file is listed so the open-source edition is never encrypted.
escrow_ignore {
    'CHANGELOG.md',
    'README.md',
    'bridge/client.lua',
    'bridge/server.lua',
    'bridge/shared.lua',
    'client/permissions.lua',
    'client/stretcher.lua',
    'client/stretcher_mechanism.lua',
    'client/sync_manager.lua',
    'client/test.lua',
    'client/wheelchair.lua',
    'config/cfg_stretcher.lua',
    'config/cfg_sync.lua',
    'config/cfg_wheelchair.lua',
    'config/config.lua',
    'install/images/stretcher.png',
    'install/images/wheelchair.png',
    'install/items.md',
    'locales/en.lua',
    'locales/tr.lua',
    'server/permissions.lua',
    'server/stretcher.lua',
    'server/sync_manager.lua',
    'server/wheelchair.lua',
    'shared/mechanism.lua',
    'shared/models.lua',
    'shared/utils.lua',
}
