shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'ONX'
description 'WiseGuy Emergency Vehicles Pack Shared Mods'
version '3.0.1'
lua54 'yes'

data_file 'VEHICLE_LAYOUTS_FILE' 'data/vehiclelayouts.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_pol.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_ems.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_fire.meta'
data_file 'CARCOLS_FILE' 'data/carcols_sirens.meta'
data_file 'CARCOLS_FILE' 'data/carcols_sirens_ems.meta'

files {
  'data/*.meta'
}

client_script 'data/vehicle_names.lua'

escrow_ignore {
  'data/*.meta',
  'data/*.lua'
}

server_scripts {
  'version.lua',
}
dependency '/assetpacks'