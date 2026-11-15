shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent'
fx_version "cerulean"
game "gta5"
lua54 'yes'
author ".vincyxir"
description "menu for boosting fps"
version "1.0.1"
shared_scripts {
        '@ox_lib/init.lua',
        'config.lua'
}
client_scripts {
        'client/client.lua',
}
dependencies {
        'ox_lib',
}








