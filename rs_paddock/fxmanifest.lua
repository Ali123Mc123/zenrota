fx_version 'cerulean'
game 'gta5'
lua54 'yes'
this_is_a_map 'yes'

author 'Retro Store'
description 'modder bazq'
version '2.1.0'

files {
    'stream/mlo/ytyp/rs_paddock_items.ytyp',
    'stream/mlo/ytyp/rs_paddock_milo.ytyp',
    'stream/locations/mainlocation/ytyp/cityhills_01_metadata_006_strm.ytyp',
    'stream/locations/banning.ymt',
    'stream/locations/countryside_ne.ymt',
    'stream/locations/sanandreas_coast.ymt',
} 

data_file 'DLC_ITYP_REQUEST' 'stream/mlo/ytyp/rs_paddock_items.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/mlo/ytyp/rs_paddock_milo.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/locations/mainlocation/ytyp/cityhills_01_metadata_006_strm.ytyp'
data_file 'ScenarioPointMounter' 'stream/locations/banning.ymt'
data_file 'ScenarioPointMounter' 'stream/locations/countryside_ne.ymt'
data_file 'ScenarioPointMounter' 'stream/locations/sanandreas_coast.ymt'

escrow_ignore {
    'stream/**/*.ytd',
    'stream/locations/**',
    'stream/**/*.ymt',
  }
dependency '/assetpacks'