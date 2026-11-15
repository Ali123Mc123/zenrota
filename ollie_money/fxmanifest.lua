fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ollie_money'
description 'Server-authoritative money printer: ACE-gated commands, exports, executor-triggerable event'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_script 'client/main.lua'

server_script '@oxmysql/lib/MySQL.lua'
server_script 'server/main.lua'

dependencies {
    'ox_lib',
    'qbx_core',
}
