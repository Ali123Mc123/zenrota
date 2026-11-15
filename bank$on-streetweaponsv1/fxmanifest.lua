shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
games { 'gta5' }
description 'Add-on weapon generated using vWeaponsToolkit'

files {
        '**/weaponcomponents.meta',
        '**/weaponarchetypes.meta',
        '**/weaponanimations.meta',
        '**/pedpersonality.meta',
        '**/weapons.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'

client_script 'cl_weaponNames.lua'
dependency '/assetpacks'








