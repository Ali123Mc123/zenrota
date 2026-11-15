shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author 'Izzy'
description 'Izzy'

this_is_a_map 'yes'

lua54 'yes'

data_file 'TIMECYCLEMOD_FILE' 'qua_luxemotel_timecycle.xml'

client_script {
    "qua_luxemotel_ipls.lua",
}

files {
    'qua_luxemotel_timecycle.xml'
}
dependency '/assetpacks'








