shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
games { 'gta5' }

fx_version 'cerulean'

description 'Define zones of different shapes and test whether a point is inside or outside of the zone'
version '2.6.2'

client_scripts {
  'client.lua',
  'BoxZone.lua',
  'EntityZone.lua',
  'CircleZone.lua',
  'ComboZone.lua',
  'creation/client/*.lua'
}

server_scripts {
  'creation/server/*.lua',
  'server.lua'
}








