shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
author "snakewiz & iLLeniumStudios"
description "A flexible player customization script for FiveM servers."
repository "https://github.com/iLLeniumStudios/illenium-appearance"
version "v5.7.0"
lua54 "yes"
client_exports {
  "setPedAppearance",
  "getPedAppearance",
  "setPlayerAppearance",
  "getPedComponents",
  "getPedProps",
  "getPedHeadBlend",
  "getPedFaceFeatures",
  "getPedHeadOverlays",
  "getPedHair",
  "setPlayerModel",
  "setPedHeadBlend",
  "setPedFaceFeatures",
  "setPedHeadOverlays",
  "setPedHair",
  "setPedEyeColor",
  "setPedComponent",
  "setPedComponents",
  "setPedProp",
  "setPedProps",
  "setPedTattoos",
  "getPedTattoos",
  "startPlayerCustomization"
}
-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
  "@ox_lib/init.lua",
  "shared/config.lua",
  "shared/blacklist.lua",
  "shared/peds.lua",
  "shared/tattoos.lua",
  "shared/theme.lua",
  "shared/pedmodels.lua",
  "shared/framework/framework.lua",
  "shared/framework/esx/util.lua",
  "locales/locales.lua",
  "locales/ar.lua",
  "locales/bg.lua",
  "locales/cs.lua",
  "locales/de.lua",
  "locales/en.lua",
  "locales/es-ES.lua",
  "locales/fr.lua",
  "locales/hu.lua",
  "locales/id.lua",
  "locales/it.lua",
  "locales/nl.lua",
  "locales/pt-BR.lua",
  "locales/ro-RO.lua",
  "locales/tr.lua",
  "locales/ui_rework.lua",
  "locales/zh-CN.lua",
  "locales/zh-TW.lua"
}
client_scripts {
  "game/constants.lua",
  "game/util.lua",
  "game/customization.lua",
  "game/nui.lua",
  "client/outfits.lua",
  "client/common.lua",
  "client/zones.lua",
  "client/framework/framework.lua",
  "client/framework/qb/compatibility.lua",
  "client/framework/qb/main.lua",
  "client/framework/qb/migrate.lua",
  "client/framework/esx/compatibility.lua",
  "client/framework/esx/main.lua",
  "client/framework/ox/main.lua",
  "client/target/target.lua",
  "client/target/qb.lua",
  "client/target/ox.lua",
  "client/management/management.lua",
  "client/management/common.lua",
  "client/management/qb.lua",
  "client/management/qbx.lua",
  "client/management/esx.lua",
  "client/radial/radial.lua",
  "client/radial/qb.lua",
  "client/radial/ox.lua",
  "client/stats.lua",
  "client/defaults.lua",
  -- "client/blips.lua",
  "client/props.lua",
  "client/client.lua",
  "client/peds.lua",
  "client/photostudio.lua",
}
server_scripts {
  "@oxmysql/lib/MySQL.lua",
  "server/database/database.lua",
  "server/database/jobgrades.lua",
  "server/database/managementoutfits.lua",
  "server/database/playeroutfitcodes.lua",
  "server/database/playeroutfits.lua",
  "server/database/players.lua",
  "server/database/playerskins.lua",
  "server/database/users.lua",
  "server/framework/qb/main.lua",
  "server/framework/qb/migrate.lua",
  "server/framework/esx/main.lua",
  "server/framework/esx/migrate.lua",
  "server/framework/esx/callbacks.lua",
  "server/framework/esx/management.lua",
  "server/framework/ox/main.lua",
  "server/util.lua",
  "server/server.lua",
  "server/permissions.lua",
  "server/database/playerpeds.lua",
  "server/peds.lua",
  "server/photostudio.lua",
  "server/pictures.js"
}
files {
  "web/dist/index.html",
  "web/dist/bundle/*",
  "data/mp_m_freemode_01_mp_m_illenium_studio_shop.meta",
  "data/mp_f_freemode_01_mp_f_illenium_studio_shop.meta"
}
ui_page "web/dist/index.html"

-- the photo studio's empty head (stream/): a clothing collection of its own that nobody can wear, since the editor
-- never offers component 0 and setPedComponent skips it on freemode peds; it loads when a player joins
data_file "SHOP_PED_APPAREL_META_FILE" "data/mp_m_freemode_01_mp_m_illenium_studio_shop.meta"
data_file "SHOP_PED_APPAREL_META_FILE" "data/mp_f_freemode_01_mp_f_illenium_studio_shop.meta"


