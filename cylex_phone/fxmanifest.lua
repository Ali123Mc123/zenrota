shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Cylex Phone - A FiveM phone resource by discord.gg/cylexstore'

version '1.375'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

client_scripts {
    'locales/*.lua',
    'editable/cl_config.lua',
    'editable/autodetect.lua',
    'editable/hacker_config.lua',
    'editable/racing_config.lua',
    'editable/music_config.lua',
    'editable/frogeats_config.lua',
    'editable/cl_functions.lua',
    'editable/frameworks/client/**/*.lua',
    'editable/components/*.lua',

    'client/cl_cloudsync.lua',
}

server_scripts {

    'locales/*.lua',
    'editable/cl_config.lua',
    'editable/autodetect.lua',
    'editable/hacker_config.lua',
    'editable/sv_config.lua',
    'editable/music_config.lua',
    'editable/frogeats_config.lua',
    'editable/frameworks/server/**/*.lua',

    'server/sv_cloudsync.lua',
}

ui_page 'html/index.html'

files {
    'html/*.html',

    'html/music-dui/*.html',
    'html/music-dui/*.js',

    -- fonts
    'html/fonts/*.eot',
    'html/fonts/*.ttf',
    'html/fonts/*.otf',
    'html/fonts/**/*.woff',
    'html/images/**/*',
    'html/assets/*.css',
    'html/js/*.js',
}

escrow_ignore { 
    'editable/*.lua', 
    'editable/components/*.lua',
    'editable/frameworks/client/**/*.lua',
    'editable/frameworks/server/**/*.lua',
    'client/cl_cloudsync.lua',
    'server/sv_cloudsync.lua',
    'locales/*.lua' 
}
dependency '/assetpacks'