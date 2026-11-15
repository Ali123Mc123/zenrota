--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'
this_is_a_map 'yes'
--[[ Resource Information ]]--
name         'bzzz_sunflowers'
version      '2.1.0'
description  'Sunflowers'
author       'BzZz'
--[[ Manifest ]]--
shared_scripts {
}
client_scripts {
}
server_scripts {
}
escrow_ignore {
        'stream/*.ydr'
}
dependencies {
}
data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
files {
    'stream/*.ytyp',
}
dependency '/assetpacks'

