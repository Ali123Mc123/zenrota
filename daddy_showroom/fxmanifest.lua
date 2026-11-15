shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
fac_guard_flags 'clientEntity'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
this_is_a_map 'yes'

name 'daddy_showroom'
author 'Daddy Studio'
description 'Dealership row hall: a closed showroom built for the camera, five identical bays, its own dim lights'
version '0.1.1'

-- The hall's numbers (place, bays, camera) come from tools/mlo/showroom.json through tools/mlo/build.mjs.
shared_script 'shared/hall.lua'
client_scripts { 'client/hall.lua', 'client/preview.lua' }

files { 'data/dd_showroom_timecycle.xml' }

-- The ytyp is no DLC_ITYP_REQUEST: stream/dd_showroom_manifest.ymf brings it in with the ymap as interior data.
data_file 'TIMECYCLEMOD_FILE' 'data/dd_showroom_timecycle.xml'
