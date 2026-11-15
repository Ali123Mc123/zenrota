shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'

author 'Krypton'
description 'Daddy Loading Screen'
version '1.1.0'

loadscreen 'web/index.html'
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

ui_page 'web/admin/index.html'

server_scripts {
    'config.lua',
    'locales/*.lua',
    'server.lua',
}
client_scripts {
    'client.lua'
}

files {
    'web/index.html',
    'web/admin/index.html',
    'web/build/*',
    'config.json',
    'web/image/*.png',
    'web/image/*.jpg',
    'web/image/*.webp',
    'web/music/*.mp3',
    'web/music/*.ogg',
    'web/video/*.mp4',
    'web/video/*.webm',
    'web/font/*.otf',
    'web/font/*.ttf',
    'web/font/*.css',
}




