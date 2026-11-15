shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author 'NeoniX'
description 'Los Santos Tuners AfterLife'
version '2.0.2'

lua54 'yes'
this_is_a_map 'yes'

data_file 'TIMECYCLEMOD_FILE' 'neox_timecycle_lstuners.xml'
data_file 'AUDIO_GAMEDATA' 'stream/audio/ACEFA9EC_game.dat'
data_file 'AUDIO_GAMEDATA' 'stream/audio/336BF38F_game.dat'
data_file 'AUDIO_GAMEDATA' 'stream/audio/BEFD44E9_game.dat'
data_file 'AUDIO_GAMEDATA' 'stream/audio/lstuners_door_game.dat'
data_file 'DLC_ITYP_REQUEST' 'imp_prop_impexp_garage_equipment.ytyp'
data_file 'DLC_ITYP_REQUEST' 'imp_impexp_intwaremed.ytyp'
data_file 'DLC_ITYP_REQUEST' 'm23_2_mp2023_02_dlc_int_4.ytyp'
data_file 'DLC_ITYP_REQUEST' 'int_corporate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'sf_dlc_int_01_sec.ytyp'
data_file 'DLC_ITYP_REQUEST' 'xm_x17dlc_int_02.ytyp'
data_file 'DLC_ITYP_REQUEST' 'int_services.ytyp'
data_file 'DLC_ITYP_REQUEST' 'v_int_16.ytyp'
data_file 'DLC_ITYP_REQUEST' 'v_int_34.ytyp'
data_file 'DLC_ITYP_REQUEST' 'bkr_biker_dlc_int_ware03.ytyp'
data_file 'DLC_ITYP_REQUEST' 'xm3_dlc_int_03_xm3.ytyp'

dependency '/assetpacks'

files {
    'neox_timecycle_lstuners.xml',
    'stream/audio/ACEFA9EC_game.dat151.rel',
    'stream/audio/336BF38F_game.dat151.rel',
    'stream/audio/BEFD44E9_game.dat151.rel',
    'stream/audio/lstuners_door_game.dat151.rel',
}

client_script {
    'data/lstuners_entityset_mods.lua',
    'data/client.lua',
    'data/config.lua',
}

shared_scripts {
    'data/config.lua',
}

dependencies {
    '/server:4960',
    '/gameBuild:2189',
}

escrow_ignore {
    'data/config.lua',
    'data/lstuners_entityset_mods.lua',
    'stream/[vanilla]/*.ydr',
    'stream/[vanilla]/*.ybn',
    'stream/[vanilla]/*.ymap',
    'stream/[vanilla]/*.ydd',
    'stream/[lstuners]/[interior]/unlocked_props/*.ydr',
    'stream/[lstuners]/[exterior]/unlocked_props/*.ydr',
}
dependency '/assetpacks'








