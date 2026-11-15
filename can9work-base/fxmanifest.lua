shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'Can9Work'
description 'Can9Work Base - Modular Base System'
version '2.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    'Settings.lua',
    'core/shared/lib.lua',
    'modules/exchange/Settings.lua',
    'modules/eventbox/Settings.lua',
    'modules/vehicleHistory/Settings.lua',
    'modules/licenseTransfer/Settings.lua',
    'modules/phoneAdmin/Settings.lua',
    '@qbx_core/modules/lib.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'modules/**/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'core/server/player.lua',
    'core/server/discord.lua',
    'server/main.lua',
    'modules/**/Settings.lua',
    'modules/**/serverFunctions.lua',
    'modules/**/server.lua'
}

ui_page 'html/resolution.html'

files {
    'html/resolution.html',
}

dependencies {
    '/onesync'
}






