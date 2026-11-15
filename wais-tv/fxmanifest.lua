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
version '1.0.4'
scriptname 'wais-tv'
description 'A custom television script with YouTube, Kick, Twitch integration and more for FiveM.'

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
    'bridge/esx/client.lua',
    'bridge/qb/client.lua',
    'client/client.lua',
    'client/tv.lua',
    'client/placement.lua',
    'client/arbiter.lua',
}

server_scripts {
    'config_sv.lua',
    'bridge/editable/server.lua',
    'bridge/esx/server.lua',
    'bridge/qb/server.lua',
    'server/server.lua',
    'server/tv.lua',
}

escrow_ignore {
    'config.lua',
    'config_sv.lua',
    'locales/*.lua',
    'bridge/editable/*.lua',
    'client/placement.lua',
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
    'web/public/locales/*.json',
}
dependency '/assetpacks'