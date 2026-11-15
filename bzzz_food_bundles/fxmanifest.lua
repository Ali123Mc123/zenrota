--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'bzzz_food_bundles'
version      '1.7.1'
description  'Food bundles 7'
author       'BzZz'

this_is_a_map 'yes'


--[[ Manifest ]]--
shared_scripts {
}

client_scripts {
}

server_scripts {
}

escrow_ignore {
	'stream/free/**/*.ydr',
	'stream/paid/bzzz_popcorn/*.ydr',	
	'stream/paid/bzzz_popcorn/*.yft',	
	'stream/paid/bzzz_dinomeal/*.ydr',
	'stream/paid/bzzz_beer_machine/*.ydr',	
	'stream/paid/bzzz_mushrooms_food/*.ydr',		
	'stream/paid/bzzz_uwuprops/*.ydr',		
	'stream/paid/bzzz_bowlfood/*.ydr',	
	'stream/paid/bzzz_cotton_candy/*.ydr',
	'stream/paid/bzzz_popsicles/*.ydr',
	'stream/paid/bzzz_chips/*.ydr',
	'stream/paid/bzzz_beer_machine/*.ydr',
	'stream/paid/bzzz_mixfood/*.ydr',

}

dependencies {

}



data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/**/**/*.ytyp'

files {
    'stream/*.ytyp',
    'stream/**/**/*.ytyp',	
}



dependency '/assetpacks'