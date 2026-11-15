shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'daddy-queue - Gelismis FiveM Queue Sistemi'
author 'Krypton'
version '1.0.0'

-- Shared (hem server hem client yukler)
shared_scripts {
    'config.lua',
    'config_roles.lua',
    'lang.lua',
}

-- Server scripts (yuklenme sirasi onemli)
server_scripts {
    'config_server.lua',
    'server/sv_utils.lua',
    'server/sv_webhook.lua',
    'server/sv_discord.lua',
    'server/sv_card.lua',
    'server/sv_queue.lua',
    'server/sv_admin.lua',
    'server/sv_init.lua',
}

-- Client scripts
client_scripts {
    'client/cl_init.lua',
}








