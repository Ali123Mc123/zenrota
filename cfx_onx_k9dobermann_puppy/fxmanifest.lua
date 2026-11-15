shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'ONX'
contributors 'Momo, CanisterDog'
description 'Dobermann puppy ped'
version '1.0.0'
lua54 'yes'

server_scripts {
  'version.lua',
}

files {
    'peds.meta',
}

data_file 'PED_METADATA_FILE' 'peds.meta'


dependency '/assetpacks'