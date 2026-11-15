shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
author 'KilluaZoldyck#0099'
games {'gta5'}
description 'Gta V Weapon Police TASERGUN'
version '1.0.0'
this_is_a_map 'no'
lua54 'yes'

escrow_ignore {
        'weapon_name.lua',
        'EXTRA_FILES/**.*'
}

files {
        'meta/pedpersonality.meta',
        'meta/weaponanimations.meta',
        'meta/weaponarchetypes.meta',
        'meta/weapons.meta',
}

data_file 'PED_PERSONALITY_FILE' 'meta/pedpersonality.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'meta/weaponanimations.meta'
data_file 'WEAPON_METADATA_FILE' 'meta/weaponarchetypes.meta'
data_file 'WEAPONINFO_FILE' 'meta/weapons.meta'

client_script 'weapon_name.lua'
dependency '/assetpacks'




