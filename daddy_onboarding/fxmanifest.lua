shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_onboarding'
author 'Daddy Studio'
description 'Daddy Onboarding: civilian, student or teacher at character start, and the class ceremony for new students'
version '2.1.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib', 'daddy_college' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'shared/classes.lua',
}

client_scripts {
    'client/camera.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/questions.lua',
    'server/sorting.lua',
    'server/state.lua',
    'server/roles.lua',
    'server/starter.lua',
    'server/quiz.lua',
    'server/commands.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
}
