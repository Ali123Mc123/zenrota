shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
this_is_a_map 'yes'


escrow_ignore {
    'fxmanifest.lua',
    'kivo_fleecaclient.lua',
    'kivo_fleeca_screens.ytd'
}

files {
    'audio/kivo_doors_game.dat151.rel',
}

client_script {
    "kivo_fleecaclient.lua"
}

data_file 'AUDIO_GAMEDATA' 'audio/kivo_doors_game.dat'

author 'KivoMaps'
description 'Kivo Fleeca_Banks'
version '1.1'

dependency '/assetpacks'








