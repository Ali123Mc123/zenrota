shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
author 'PazeeeGPT'
description 'Radio Script Selector'
version '1.0.0'
lua54 "yes"
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
client_script 'client.lua'
server_script 'server.lua'
ui_page 'ui/index.html'
files {
    'ui/index.html',
    'ui/script.js',
    'ui/style.css',
    'ui/fonts/archivo-latin-wdth-normal.woff2',
    'ui/fonts/archivo-latin-ext-wdth-normal.woff2',
    'ui/fonts/archivo-latin-wdth-italic.woff2',
    'ui/fonts/archivo-latin-ext-wdth-italic.woff2',
}
dependencies {
    'pma-voice',
    'ox_lib'
}


