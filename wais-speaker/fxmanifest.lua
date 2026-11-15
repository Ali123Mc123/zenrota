shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
-- Author: Ayazwai <https://ayazwai.dev>
-- Github: https://github.com/ayazwai
-- Discord: https://discord.gg/0resmon
-- LinkendIn: https://www.linkedin.com/in/ayaz-ekrem-770305212/

use_experimental_fxv2_oal 'yes'
fx_version 'bodacious'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]]--

author 'Ayazwai'
version '1.0.9'
scriptname 'wais-speaker'
description 'A custom 3D sound/speaker/boombox/carplay system for FiveM with multiple framework support.'

--[[ Resource Information ]]--

shared_scripts {
    'config.lua',
    'locales/*.lua',
    'bridge/framework.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'bridge/editable/utils.lua',
    'bridge/editable/client.lua',
    'client/client.lua',
    'client/speaker.lua',
    'client/boombox.lua',
}

server_scripts {
    'config_sv.lua',
    '@mysql-async/lib/MySQL.lua',
    'bridge/editable/server.lua',
    'server/server.lua',
    'server/speaker.lua',
    'server/boombox.lua',
}

escrow_ignore {
    'config.lua',
    'config_sv.lua',
    'locales/*.lua',
    'bridge/editable/*.lua',
}

dependencys {
    'ox_lib',
}

ui_page "web/dist/index.html"
files {
    'web/dist/*.js',
    'web/dist/index.html',

    'web/public/*.json',
    'web/public/**/*.png',
    'web/public/css/*.*',
    'web/public/fonts/*.*',
    'web/public/sounds/*.*',
    'web/public/locales/*.json',
}
    
data_file 'DLC_ITYP_REQUEST' 'stream/qua_b_speakers.ytyp'
dependency '/assetpacks'