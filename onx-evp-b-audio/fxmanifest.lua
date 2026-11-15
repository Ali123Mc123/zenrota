shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'ONX'
description 'WiseGuy Emergency Vehicles Pack Audio'
version '3.0.0'
lua54 'yes'

data_file 'AUDIO_GAMEDATA' 'audioconfig/onxevp_game.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/onxevpems_game.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/onxevpfire_game.dat'

files {
   'audioconfig/*.dat10',
   'audioconfig/*.dat10.rel',
   'audioconfig/*.dat16',
   'audioconfig/*.dat16.rel',
   'audioconfig/*.dat151',
   'audioconfig/*.dat151.rel',
   'audioconfig/*.dat54',
   'audioconfig/*.dat54.rel',
   'sfx/**/*.awc',
}

escrow_ignore {
  'data/*.meta',
  'data/*.lua'
}

server_scripts {
  'version.lua',
}
dependency '/assetpacks'