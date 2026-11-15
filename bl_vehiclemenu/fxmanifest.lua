shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent,clientNative'
fx_version 'cerulean'
game 'gta5'
author 'Byte Labs'
version '1.0.0'
description 'Byte Labs Vehicle Menu'
repository 'https://github.com/Byte-Labs-Project/bl_vehiclemenu'
lua54 'yes'
ui_page 'build/index.html'
shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'shared/modules/*.lua',
}
client_scripts {
    'client/*.lua',
    'client/modules/*.lua',
}
files {
    'build/index.html',
    'build/index.css',
    'build/index.js',
    'build/*.woff2',
}


