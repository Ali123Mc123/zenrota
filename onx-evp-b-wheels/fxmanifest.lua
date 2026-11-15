shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'ONX'
description 'WiseGuy Emergency Vehicles Pack'
version '3.0.0'
lua54 'yes'

data_file 'CARCOLS_FILE' 'data/carcols.meta'

files {
  'data/*.meta'
}

client_script 'data/vehicle_names.lua'

escrow_ignore {
  'data/*.lua',
}

server_scripts {
  'version.lua',
}

dependency '/assetpacks'