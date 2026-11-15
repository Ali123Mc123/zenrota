shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
--
-- Author: Ayazwai
-- Github: https://github.com/ayazwai
-- Discord: https://discord.gg/YanMPNg8Zn
-- LinkendIn: https://www.linkedin.com/in/ayaz-ekrem-770305212/

use_experimental_fxv2_oal 'yes'
fx_version 'bodacious'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]] --

author 'Ayazwai'
version '1.0.0'
scriptname 'wais-vehiclekey'

--[[ Resource Information ]] --

escrow_ignore {
    'cl_editable.lua',
    'sv_editable.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'cl_editable.lua',
    'client.lua',
}

server_scripts {
    'sv_editable.lua',
    'server.lua',
}

dependencys {
    'ox_lib',
}

provide "qb-vehiclekeys"








