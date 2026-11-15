shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent'


fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy-voicevolume'
author 'Daddy Development'
description 'pma-voice uyumlu, kisi bazli yakin oyuncu ses seviyesi ayari (NUI)'
version '1.0.0'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/voice.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'pma-voice',
    'ox_lib',
    'qbx_core',
}
