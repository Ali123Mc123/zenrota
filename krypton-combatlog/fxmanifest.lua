shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Krypton'
description 'Advanced Combat Log Detection System'
version '2.0.0'
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}
client_scripts {
    'client/framework.lua',
    'client/main.lua',
}
server_scripts {
    'server/framework.lua',
    'server/discord.lua',
    'server/main.lua',
}
ui_page 'web/index.html'
files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'locales/en.json',
    'locales/tr.json',
}
ensure 'ox_lib'
dependencies { 'ox_lib' }
-- Optional: ox_target or qb-target for ped display mode interaction
-- provide 'ox_target' -- Uncomment if you want to ensure ox_target loads first








