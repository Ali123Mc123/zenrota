shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_studentpad'
author 'Daddy Studio'
description 'DaddyOS Student Tablet: timetable, courses, grades and school life'
version '2.0.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib', 'daddy_college' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/school.lua',
    'server/external.lua', -- apps other resources add
    'server/apps/*.lua', -- one file per app with its own logic
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'install/**/*.lua',
}
