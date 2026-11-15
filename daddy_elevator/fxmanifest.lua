shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEvent,clientNative'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_elevator'
author 'Daddy Roleplay'
description 'Elevators: a stop on every floor, a floor menu, fade and ride'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
}
