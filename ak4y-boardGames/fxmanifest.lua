shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

version '1.0.9'

shared_script 'shared/config.lua'
shared_script 'locales/*.lua'

client_script 'client/cl_global_stats.lua'
server_script 'shared/serverConfig.lua'
server_script 'server/global_stats.lua'

shared_script 'shared/colorMatch/config.lua'
client_script 'client/eno/client.lua'
server_script 'server/eno/server.lua'

shared_script 'shared/armwrestling/config.lua'
client_script 'client/armwrestling/client.lua'
server_script 'server/armwrestling/server.lua'

shared_script 'shared/checkers/config.lua'
client_script 'client/checkers/client.lua'
server_script 'server/checkers/server.lua'

shared_script 'shared/chess/config.lua'
client_script 'client/chess/client.lua'
server_script 'server/chess/server.lua'

shared_script 'shared/whoAmI/config.lua'
client_script 'client/guessWho/client.lua'
server_script 'server/guessWho/server.lua'

shared_script 'shared/towerBlocks/config.lua'
client_script 'client/jengo/client.lua'
client_script 'client/jengo/client_gameplay.lua'
server_script 'server/jengo/server.lua'

shared_script 'shared/rodeo/config.lua'
client_script 'client/rodeo/client.lua'
server_script 'server/rodeo/server.lua'

shared_script 'shared/basketball/config.lua'
client_script 'client/basketball/client.lua'
server_script 'server/basketball/server.lua'

shared_script 'shared/boxmachine/config.lua'
client_script 'client/boxmachine/client.lua'
server_script 'server/boxmachine/server.lua'

shared_script 'shared/santosTycoon/config.lua'
client_script 'client/santosPoly/client.lua'
server_script 'server/santosPoly/server.lua'

client_script 'client/truthOrDare/client.lua'
server_script 'server/truthOrDare/server.lua'

shared_script 'shared/fourInLine/shared.lua'
client_script 'client/connect4/client.lua'
server_script 'server/connect4/server.lua'

shared_script 'shared/xox/config.lua'
client_script 'client/xox/client.lua'
server_script 'server/xox/server.lua'


client_script 'editable/cl_utils.lua'
server_script 'editable/sv_utils.lua'

ui_page 'ui/index.html'

files {
    'ui/*.html',
    'ui/style.css',
    'ui/script.js',
    'ui/audio/*.mp3',
    'ui/*.png',
    'ui/cards/*.png',
    'ui/basketball/score_counter.html',
    'ui/boxmachine/score_counter.html',
    'ui/boxmachine/skill_bar.html',
    'ui/boxmachine/punchSound.ogg',
    'ui/boxmachine/punchSound.mp3'
}

escrow_ignore {
    'shared/config.lua',
    'locales/*.lua',
    'shared/serverConfig.lua',
    'editable/cl_utils.lua',
    'editable/sv_utils.lua',
    'shared/colorMatch/config.lua',
    'shared/armwrestling/config.lua',
    'shared/checkers/config.lua',
    'shared/chess/config.lua',
    'shared/whoAmI/config.lua',
    'shared/towerBlocks/config.lua',
    'shared/rodeo/config.lua',
    'shared/basketball/config.lua',
    'shared/boxmachine/config.lua',
    'shared/santosTycoon/config.lua',
    'shared/fourInLine/shared.lua',
    'shared/xox/config.lua'
}

dependency 'ak4y-core'
dependency '/assetpacks'