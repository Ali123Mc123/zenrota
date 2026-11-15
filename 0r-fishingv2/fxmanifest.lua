shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game { 'gta5' }
lua54 'yes'
author 'vezironi'
description 'Modern, relastic, and fully customizable fishing system for FiveM.'
scriptname '0r-fishingv2'
version '1.0.7'
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
   '@ox_lib/init.lua',
   'config/*.lua',
   'shared/*.lua',
}
client_scripts {
   'modules/**/**/client.lua',
   'client/*.lua',
   'client/tasks/*.lua',
}
server_scripts {
   '@oxmysql/lib/MySQL.lua',
   'modules/**/**/server.lua',
   'server/*.lua',
}
-- escrow_ignore {
--    'config/*.lua',
--    'locales/*.lua',
--    'shared/*.lua',
--    'types/*.lua',
--    'modules/**/**/*.lua',
--    'server/sv_functions.lua',
--    'server/sv_logs.lua',
--    'server/cl_functions.lua',
-- }
escrow_ignore {
   'config/*.lua',
   'locales/*.lua',
   'shared/*.lua',
   'types/*.lua',
   'modules/**/**/*.lua',
   'server/*.lua',
   'client/tasks/*.lua',
   'client/*.lua',
}
files {
   'web/build/*.*',
   'web/build/**/*.*',
   'locales/*.json',
   'stream/0r_fish.ytyp',
}
ui_page 'web/build/index.html'
data_file 'DLC_ITYP_REQUEST' 'stream/0r_fish.ytyp'
dependency '/assetpacks'








