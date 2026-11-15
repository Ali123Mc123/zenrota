-- Post-3095 GTA cars as add-ons (made by tools/cars/stream-dlc.mjs, daddy-suite; plan docs/cars/STREAM-3095.md)
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'krypton-car-stream'
author 'Krypton'
version '0.1.0'

-- after the stock handling, so these entries win over its copies of the same cars
dependency 'krypton-car-handling'

files {
  'data/astrale/vehicles.meta',
  'data/astrale/carcols.meta',
  'data/astrale/carvariations.meta',
  'data/astrale/handling.meta',
  'data/astrale/vehiclelayouts.meta',
  'data/banshee3/vehicles.meta',
  'data/banshee3/carcols.meta',
  'data/banshee3/carvariations.meta',
  'data/banshee3/handling.meta',
  'data/banshee3/vehiclelayouts.meta',
  'data/cartuccia/vehicles.meta',
  'data/cartuccia/carcols.meta',
  'data/cartuccia/carvariations.meta',
  'data/cartuccia/handling.meta',
  'data/cartuccia/vehiclelayouts.meta',
  'data/castigator/vehicles.meta',
  'data/castigator/carcols.meta',
  'data/castigator/carvariations.meta',
  'data/castigator/handling.meta',
  'data/castigator/vehiclelayouts.meta',
  'data/chavosv6/vehicles.meta',
  'data/chavosv6/carcols.meta',
  'data/chavosv6/carvariations.meta',
  'data/chavosv6/handling.meta',
  'data/chavosv6/vehiclelayouts.meta',
  'data/cheetah3/vehicles.meta',
  'data/cheetah3/carcols.meta',
  'data/cheetah3/carvariations.meta',
  'data/cheetah3/handling.meta',
  'data/cheetah3/vehiclelayouts.meta',
  'data/coquette5/vehicles.meta',
  'data/coquette5/carcols.meta',
  'data/coquette5/carvariations.meta',
  'data/coquette5/handling.meta',
  'data/coquette5/vehiclelayouts.meta',
  'data/coquette6/vehicles.meta',
  'data/coquette6/carcols.meta',
  'data/coquette6/carvariations.meta',
  'data/coquette6/handling.meta',
  'data/coquette6/vehiclelayouts.meta',
  'data/dominator10/vehicles.meta',
  'data/dominator10/carcols.meta',
  'data/dominator10/carvariations.meta',
  'data/dominator10/handling.meta',
  'data/dominator10/vehiclelayouts.meta',
  'data/envisage/vehicles.meta',
  'data/envisage/carcols.meta',
  'data/envisage/carvariations.meta',
  'data/envisage/handling.meta',
  'data/envisage/vehiclelayouts.meta',
  'data/estride/vehicles.meta',
  'data/estride/carcols.meta',
  'data/estride/carvariations.meta',
  'data/estride/handling.meta',
  'data/estride/vehiclelayouts.meta',
  'data/eurosx32/vehicles.meta',
  'data/eurosx32/carcols.meta',
  'data/eurosx32/carvariations.meta',
  'data/eurosx32/handling.meta',
  'data/eurosx32/vehiclelayouts.meta',
  'data/everon3/vehicles.meta',
  'data/everon3/carcols.meta',
  'data/everon3/carvariations.meta',
  'data/everon3/handling.meta',
  'data/everon3/vehiclelayouts.meta',
  'data/firebolt/vehicles.meta',
  'data/firebolt/carcols.meta',
  'data/firebolt/carvariations.meta',
  'data/firebolt/handling.meta',
  'data/firebolt/vehiclelayouts.meta',
  'data/fmj2/vehicles.meta',
  'data/fmj2/carcols.meta',
  'data/fmj2/carvariations.meta',
  'data/fmj2/handling.meta',
  'data/fmj2/vehiclelayouts.meta',
  'data/gt750/vehicles.meta',
  'data/gt750/carcols.meta',
  'data/gt750/carvariations.meta',
  'data/gt750/handling.meta',
  'data/gt750/vehiclelayouts.meta',
  'data/hardy/vehicles.meta',
  'data/hardy/carcols.meta',
  'data/hardy/carvariations.meta',
  'data/hardy/handling.meta',
  'data/hardy/vehiclelayouts.meta',
  'data/horus/vehicles.meta',
  'data/horus/carcols.meta',
  'data/horus/carvariations.meta',
  'data/horus/handling.meta',
  'data/horus/vehiclelayouts.meta',
  'data/itali2/vehicles.meta',
  'data/itali2/carcols.meta',
  'data/itali2/carvariations.meta',
  'data/itali2/handling.meta',
  'data/itali2/vehiclelayouts.meta',
  'data/jester5/vehicles.meta',
  'data/jester5/carcols.meta',
  'data/jester5/carvariations.meta',
  'data/jester5/handling.meta',
  'data/jester5/vehiclelayouts.meta',
  'data/l352/vehicles.meta',
  'data/l352/carcols.meta',
  'data/l352/carvariations.meta',
  'data/l352/handling.meta',
  'data/l352/vehiclelayouts.meta',
  'data/lrcgt/vehicles.meta',
  'data/lrcgt/carcols.meta',
  'data/lrcgt/carvariations.meta',
  'data/lrcgt/handling.meta',
  'data/lrcgt/vehiclelayouts.meta',
  'data/luiva/vehicles.meta',
  'data/luiva/carcols.meta',
  'data/luiva/carvariations.meta',
  'data/luiva/handling.meta',
  'data/luiva/vehiclelayouts.meta',
  'data/merula/vehicles.meta',
  'data/merula/carcols.meta',
  'data/merula/carvariations.meta',
  'data/merula/handling.meta',
  'data/merula/vehiclelayouts.meta',
  'data/minimus/vehicles.meta',
  'data/minimus/carcols.meta',
  'data/minimus/carvariations.meta',
  'data/minimus/handling.meta',
  'data/minimus/vehiclelayouts.meta',
  'data/niobe/vehicles.meta',
  'data/niobe/carcols.meta',
  'data/niobe/carvariations.meta',
  'data/niobe/handling.meta',
  'data/niobe/vehiclelayouts.meta',
  'data/paragon3/vehicles.meta',
  'data/paragon3/carcols.meta',
  'data/paragon3/carvariations.meta',
  'data/paragon3/handling.meta',
  'data/paragon3/vehiclelayouts.meta',
  'data/pipistrello/vehicles.meta',
  'data/pipistrello/carcols.meta',
  'data/pipistrello/carvariations.meta',
  'data/pipistrello/handling.meta',
  'data/pipistrello/vehiclelayouts.meta',
  'data/rapidgt4/vehicles.meta',
  'data/rapidgt4/carcols.meta',
  'data/rapidgt4/carvariations.meta',
  'data/rapidgt4/handling.meta',
  'data/rapidgt4/vehiclelayouts.meta',
  'data/sentinel5/vehicles.meta',
  'data/sentinel5/carcols.meta',
  'data/sentinel5/carvariations.meta',
  'data/sentinel5/handling.meta',
  'data/sentinel5/vehiclelayouts.meta',
  'data/sentinel6/vehicles.meta',
  'data/sentinel6/carcols.meta',
  'data/sentinel6/carvariations.meta',
  'data/sentinel6/handling.meta',
  'data/sentinel6/vehiclelayouts.meta',
  'data/suzume/vehicles.meta',
  'data/suzume/carcols.meta',
  'data/suzume/carvariations.meta',
  'data/suzume/handling.meta',
  'data/suzume/vehiclelayouts.meta',
  'data/tampa4/vehicles.meta',
  'data/tampa4/carcols.meta',
  'data/tampa4/carvariations.meta',
  'data/tampa4/handling.meta',
  'data/tampa4/vehiclelayouts.meta',
  'data/uranus/vehicles.meta',
  'data/uranus/carcols.meta',
  'data/uranus/carvariations.meta',
  'data/uranus/handling.meta',
  'data/uranus/vehiclelayouts.meta',
  'data/velenogt/vehicles.meta',
  'data/velenogt/carcols.meta',
  'data/velenogt/carvariations.meta',
  'data/velenogt/handling.meta',
  'data/velenogt/vehiclelayouts.meta',
  'data/vorschlaghammer/vehicles.meta',
  'data/vorschlaghammer/carcols.meta',
  'data/vorschlaghammer/carvariations.meta',
  'data/vorschlaghammer/handling.meta',
  'data/vorschlaghammer/vehiclelayouts.meta',
  'data/warden/vehicles.meta',
  'data/warden/carcols.meta',
  'data/warden/carvariations.meta',
  'data/warden/handling.meta',
  'data/warden/vehiclelayouts.meta',
  'data/woodlander/vehicles.meta',
  'data/woodlander/carcols.meta',
  'data/woodlander/carvariations.meta',
  'data/woodlander/handling.meta',
  'data/woodlander/vehiclelayouts.meta',
  'data/xtreme/vehicles.meta',
  'data/xtreme/carcols.meta',
  'data/xtreme/carvariations.meta',
  'data/xtreme/handling.meta',
  'data/xtreme/vehiclelayouts.meta',
  'data/yosemite1500/vehicles.meta',
  'data/yosemite1500/carcols.meta',
  'data/yosemite1500/carvariations.meta',
  'data/yosemite1500/handling.meta',
  'data/yosemite1500/vehiclelayouts.meta',
  'audio/astrale_game.dat151.rel',
  'audio/astrale_sounds.dat54.rel',
  'audio/banshee3_game.dat151.rel',
  'audio/banshee3_sounds.dat54.rel',
  'audio/cartuccia_game.dat151.rel',
  'audio/castigator_game.dat151.rel',
  'audio/castigator_sounds.dat54.rel',
  'audio/chavosv6_game.dat151.rel',
  'audio/chavosv6_sounds.dat54.rel',
  'audio/cheetah3_game.dat151.rel',
  'audio/coquette5_game.dat151.rel',
  'audio/coquette5_sounds.dat54.rel',
  'audio/coquette6_game.dat151.rel',
  'audio/dominator10_game.dat151.rel',
  'audio/dominator10_sounds.dat54.rel',
  'audio/envisage_game.dat151.rel',
  'audio/envisage_sounds.dat54.rel',
  'audio/estride_game.dat151.rel',
  'audio/eurosx32_game.dat151.rel',
  'audio/eurosx32_sounds.dat54.rel',
  'audio/everon3_game.dat151.rel',
  'audio/everon3_sounds.dat54.rel',
  'audio/firebolt_game.dat151.rel',
  'audio/firebolt_sounds.dat54.rel',
  'audio/fmj2_game.dat151.rel',
  'audio/fmj2_sounds.dat54.rel',
  'audio/gt750_game.dat151.rel',
  'audio/gt750_sounds.dat54.rel',
  'audio/hardy_game.dat151.rel',
  'audio/hardy_sounds.dat54.rel',
  'audio/horus_game.dat151.rel',
  'audio/horus_sounds.dat54.rel',
  'audio/itali2_game.dat151.rel',
  'audio/jester5_game.dat151.rel',
  'audio/jester5_sounds.dat54.rel',
  'audio/l352_game.dat151.rel',
  'audio/lrcgt_game.dat151.rel',
  'audio/luiva_game.dat151.rel',
  'audio/merula_game.dat151.rel',
  'audio/minimus_game.dat151.rel',
  'audio/minimus_sounds.dat54.rel',
  'audio/niobe_game.dat151.rel',
  'audio/niobe_sounds.dat54.rel',
  'audio/paragon3_game.dat151.rel',
  'audio/paragon3_sounds.dat54.rel',
  'audio/pipistrello_game.dat151.rel',
  'audio/pipistrello_sounds.dat54.rel',
  'audio/rapidgt4_game.dat151.rel',
  'audio/sentinel5_game.dat151.rel',
  'audio/sentinel6_game.dat151.rel',
  'audio/sentinel6_sounds.dat54.rel',
  'audio/suzume_game.dat151.rel',
  'audio/suzume_sounds.dat54.rel',
  'audio/tampa4_game.dat151.rel',
  'audio/uranus_game.dat151.rel',
  'audio/velenogt_game.dat151.rel',
  'audio/velenogt_sounds.dat54.rel',
  'audio/vorschlaghammer_game.dat151.rel',
  'audio/vorschlaghammer_sounds.dat54.rel',
  'audio/warden_game.dat151.rel',
  'audio/warden_sounds.dat54.rel',
  'audio/woodlander_game.dat151.rel',
  'audio/woodlander_sounds.dat54.rel',
  'audio/xtreme_game.dat151.rel',
  'audio/yosemite1500_game.dat151.rel',
  'audio/yosemite1500_sounds.dat54.rel',
  'audio/sfx/dlc_24-1/*.awc',
  'audio/sfx/dlc_25-1/*.awc',
}

data_file 'VEHICLE_LAYOUTS_FILE' 'data/astrale/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/banshee3/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/cartuccia/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/castigator/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/chavosv6/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/cheetah3/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/coquette5/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/coquette6/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/dominator10/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/envisage/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/estride/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/eurosx32/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/everon3/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/firebolt/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/fmj2/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/gt750/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/hardy/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/horus/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/itali2/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/jester5/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/l352/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/lrcgt/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/luiva/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/merula/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/minimus/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/niobe/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/paragon3/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/pipistrello/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/rapidgt4/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/sentinel5/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/sentinel6/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/suzume/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/tampa4/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/uranus/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/velenogt/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/vorschlaghammer/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/warden/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/woodlander/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/xtreme/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/yosemite1500/vehiclelayouts.meta'
data_file 'HANDLING_FILE' 'data/astrale/handling.meta'
data_file 'HANDLING_FILE' 'data/banshee3/handling.meta'
data_file 'HANDLING_FILE' 'data/cartuccia/handling.meta'
data_file 'HANDLING_FILE' 'data/castigator/handling.meta'
data_file 'HANDLING_FILE' 'data/chavosv6/handling.meta'
data_file 'HANDLING_FILE' 'data/cheetah3/handling.meta'
data_file 'HANDLING_FILE' 'data/coquette5/handling.meta'
data_file 'HANDLING_FILE' 'data/coquette6/handling.meta'
data_file 'HANDLING_FILE' 'data/dominator10/handling.meta'
data_file 'HANDLING_FILE' 'data/envisage/handling.meta'
data_file 'HANDLING_FILE' 'data/estride/handling.meta'
data_file 'HANDLING_FILE' 'data/eurosx32/handling.meta'
data_file 'HANDLING_FILE' 'data/everon3/handling.meta'
data_file 'HANDLING_FILE' 'data/firebolt/handling.meta'
data_file 'HANDLING_FILE' 'data/fmj2/handling.meta'
data_file 'HANDLING_FILE' 'data/gt750/handling.meta'
data_file 'HANDLING_FILE' 'data/hardy/handling.meta'
data_file 'HANDLING_FILE' 'data/horus/handling.meta'
data_file 'HANDLING_FILE' 'data/itali2/handling.meta'
data_file 'HANDLING_FILE' 'data/jester5/handling.meta'
data_file 'HANDLING_FILE' 'data/l352/handling.meta'
data_file 'HANDLING_FILE' 'data/lrcgt/handling.meta'
data_file 'HANDLING_FILE' 'data/luiva/handling.meta'
data_file 'HANDLING_FILE' 'data/merula/handling.meta'
data_file 'HANDLING_FILE' 'data/minimus/handling.meta'
data_file 'HANDLING_FILE' 'data/niobe/handling.meta'
data_file 'HANDLING_FILE' 'data/paragon3/handling.meta'
data_file 'HANDLING_FILE' 'data/pipistrello/handling.meta'
data_file 'HANDLING_FILE' 'data/rapidgt4/handling.meta'
data_file 'HANDLING_FILE' 'data/sentinel5/handling.meta'
data_file 'HANDLING_FILE' 'data/sentinel6/handling.meta'
data_file 'HANDLING_FILE' 'data/suzume/handling.meta'
data_file 'HANDLING_FILE' 'data/tampa4/handling.meta'
data_file 'HANDLING_FILE' 'data/uranus/handling.meta'
data_file 'HANDLING_FILE' 'data/velenogt/handling.meta'
data_file 'HANDLING_FILE' 'data/vorschlaghammer/handling.meta'
data_file 'HANDLING_FILE' 'data/warden/handling.meta'
data_file 'HANDLING_FILE' 'data/woodlander/handling.meta'
data_file 'HANDLING_FILE' 'data/xtreme/handling.meta'
data_file 'HANDLING_FILE' 'data/yosemite1500/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/astrale/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/banshee3/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/cartuccia/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/castigator/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/chavosv6/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/cheetah3/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/coquette5/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/coquette6/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/dominator10/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/envisage/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/estride/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/eurosx32/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/everon3/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/firebolt/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/fmj2/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/gt750/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/hardy/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/horus/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/itali2/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/jester5/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/l352/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/lrcgt/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/luiva/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/merula/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/minimus/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/niobe/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/paragon3/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/pipistrello/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/rapidgt4/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/sentinel5/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/sentinel6/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/suzume/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/tampa4/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/uranus/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/velenogt/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vorschlaghammer/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/warden/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/woodlander/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/xtreme/vehicles.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/yosemite1500/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/astrale/carcols.meta'
data_file 'CARCOLS_FILE' 'data/banshee3/carcols.meta'
data_file 'CARCOLS_FILE' 'data/cartuccia/carcols.meta'
data_file 'CARCOLS_FILE' 'data/castigator/carcols.meta'
data_file 'CARCOLS_FILE' 'data/chavosv6/carcols.meta'
data_file 'CARCOLS_FILE' 'data/cheetah3/carcols.meta'
data_file 'CARCOLS_FILE' 'data/coquette5/carcols.meta'
data_file 'CARCOLS_FILE' 'data/coquette6/carcols.meta'
data_file 'CARCOLS_FILE' 'data/dominator10/carcols.meta'
data_file 'CARCOLS_FILE' 'data/envisage/carcols.meta'
data_file 'CARCOLS_FILE' 'data/estride/carcols.meta'
data_file 'CARCOLS_FILE' 'data/eurosx32/carcols.meta'
data_file 'CARCOLS_FILE' 'data/everon3/carcols.meta'
data_file 'CARCOLS_FILE' 'data/firebolt/carcols.meta'
data_file 'CARCOLS_FILE' 'data/fmj2/carcols.meta'
data_file 'CARCOLS_FILE' 'data/gt750/carcols.meta'
data_file 'CARCOLS_FILE' 'data/hardy/carcols.meta'
data_file 'CARCOLS_FILE' 'data/horus/carcols.meta'
data_file 'CARCOLS_FILE' 'data/itali2/carcols.meta'
data_file 'CARCOLS_FILE' 'data/jester5/carcols.meta'
data_file 'CARCOLS_FILE' 'data/l352/carcols.meta'
data_file 'CARCOLS_FILE' 'data/lrcgt/carcols.meta'
data_file 'CARCOLS_FILE' 'data/luiva/carcols.meta'
data_file 'CARCOLS_FILE' 'data/merula/carcols.meta'
data_file 'CARCOLS_FILE' 'data/minimus/carcols.meta'
data_file 'CARCOLS_FILE' 'data/niobe/carcols.meta'
data_file 'CARCOLS_FILE' 'data/paragon3/carcols.meta'
data_file 'CARCOLS_FILE' 'data/pipistrello/carcols.meta'
data_file 'CARCOLS_FILE' 'data/rapidgt4/carcols.meta'
data_file 'CARCOLS_FILE' 'data/sentinel5/carcols.meta'
data_file 'CARCOLS_FILE' 'data/sentinel6/carcols.meta'
data_file 'CARCOLS_FILE' 'data/suzume/carcols.meta'
data_file 'CARCOLS_FILE' 'data/tampa4/carcols.meta'
data_file 'CARCOLS_FILE' 'data/uranus/carcols.meta'
data_file 'CARCOLS_FILE' 'data/velenogt/carcols.meta'
data_file 'CARCOLS_FILE' 'data/vorschlaghammer/carcols.meta'
data_file 'CARCOLS_FILE' 'data/warden/carcols.meta'
data_file 'CARCOLS_FILE' 'data/woodlander/carcols.meta'
data_file 'CARCOLS_FILE' 'data/xtreme/carcols.meta'
data_file 'CARCOLS_FILE' 'data/yosemite1500/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/astrale/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/banshee3/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/cartuccia/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/castigator/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/chavosv6/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/cheetah3/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/coquette5/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/coquette6/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/dominator10/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/envisage/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/estride/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/eurosx32/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/everon3/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/firebolt/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/fmj2/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/gt750/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/hardy/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/horus/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/itali2/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/jester5/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/l352/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/lrcgt/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/luiva/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/merula/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/minimus/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/niobe/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/paragon3/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/pipistrello/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/rapidgt4/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/sentinel5/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/sentinel6/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/suzume/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/tampa4/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/uranus/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/velenogt/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/vorschlaghammer/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/warden/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/woodlander/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/xtreme/carvariations.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/yosemite1500/carvariations.meta'
data_file 'AUDIO_WAVEPACK' 'audio/sfx/dlc_24-1'
data_file 'AUDIO_WAVEPACK' 'audio/sfx/dlc_25-1'
data_file 'AUDIO_SOUNDDATA' 'audio/astrale_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/banshee3_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/castigator_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/chavosv6_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/coquette5_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/dominator10_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/envisage_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/eurosx32_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/everon3_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/firebolt_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/fmj2_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/gt750_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/hardy_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/horus_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/jester5_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/minimus_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/niobe_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/paragon3_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/pipistrello_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/sentinel6_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/suzume_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/velenogt_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/vorschlaghammer_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/warden_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/woodlander_sounds.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/yosemite1500_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audio/astrale_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/banshee3_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/cartuccia_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/castigator_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/chavosv6_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/cheetah3_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/coquette5_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/coquette6_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/dominator10_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/envisage_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/estride_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/eurosx32_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/everon3_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/firebolt_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/fmj2_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/gt750_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/hardy_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/horus_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/itali2_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/jester5_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/l352_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/lrcgt_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/luiva_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/merula_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/minimus_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/niobe_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/paragon3_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/pipistrello_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/rapidgt4_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/sentinel5_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/sentinel6_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/suzume_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/tampa4_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/uranus_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/velenogt_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/vorschlaghammer_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/warden_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/woodlander_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/xtreme_game.dat'
data_file 'AUDIO_GAMEDATA' 'audio/yosemite1500_game.dat'

client_script 'client/names/*.lua'
