shared_script '@FeloxAC/modules/include/guard_runtime.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_feloxac'
description 'FeloxAC <-> eadmin_panel köprüsü: oyuncu menüsü butonları, Bans sayfasına FeloxAC banları. Sadece bu sunucuda durur, repoya girmez.'
version '1.0.0'

server_scripts {
    'config.lua',
    'server/webapi.lua',
    'server/main.lua',
}

dependency 'FeloxAC'
