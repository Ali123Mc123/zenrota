--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'
this_is_a_map 'yes'
--[[ Resource Information ]]--
name         'bzzz_all_free_props'
version      '1.3.0'
description  'Bzzz - All free props'
author       'BzZz'
--[[ Manifest ]]--
shared_scripts {
}
client_scripts {
}
server_scripts {
}
dependencies {
}
escrow_ignore {
        'stream/*.ydr',
        'stream/*.ycd',
        'stream/*.ytd',
        'stream/*.yft',
        'stream/*/*.ydr',
        'stream/*/*.ycd',
        'stream/*/*.ytd',
        'stream/*/*.yft',
        'stream/*/*/*.ydr',
        'stream/*/*/*.ycd',
        'stream/*/*/*.ytd',
        'stream/*/*/*.yft',
        'stream/*/*/*/*.ydr',
        'stream/*/*/*/*.ycd',
        'stream/*/*/*/*.ytd',
        'stream/*/*/*/*.yft',   
        'data/*.lua',
        'data/*/*.lua',
        'data/*/*/*.lua',
}
files {
    'stream/*.ytyp',
    'stream/**/*.ytyp', 
    'stream/**/**/*.ytyp',              
    'stream/**/**/**/*.ytyp',   
}
-- ** zaten tum alt klasorleri kapsar; ust uste binen kaliplar her ytyp'yi 3 kez yukleyip archetype havuzunu dolduruyordu
data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
dependency '/assetpacks'

