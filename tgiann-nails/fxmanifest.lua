shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version "1.4.0"

dependencies { "ox_lib", "tgiann-core", "tgiann-nails-assets", "tgiann-media-lib" }

ui_page "ui/build/index.html"

files {
    "ui/build/**.*",
    "data/*.json",
}

escrow_ignore {
    "client/editable.lua",
    "configs/*.lua",
    "languages/*.lua",
    "server/editable.lua",
    "shared/type.lua",
}

shared_scripts {
    "@ox_lib/init.lua",
    "configs/config.lua",
    "configs/configCatalog.lua",
    "configs/configPlacement.lua",
    "languages/*.lua",
    "shared/main.lua",
    "shared/settings.lua",
    "shared/charms.lua",
    "shared/pricing.lua",
    "shared/design.lua",
    "shared/fit.lua",
    "shared/dataFiles.lua",
    "shared/zone.lua",
}

client_scripts {
    "client/utilty/*.lua",
    "client/classes/*.lua",
    "client/editable.lua",
    "client/state.lua",
    "client/main.lua",
    "client/atlas.lua",
    "client/render.lua",
    "client/studio.lua",
    "client/fit.lua",
    "client/catalog.lua",
    "client/dialogs.lua",
    "client/seat.lua",
    "client/handView.lua",
    "client/business.lua",
    "client/photo.lua",
    "client/salon.lua",
    "client/orders.lua",
    "client/items.lua",
    "client/shop.lua",
    "client/damage.lua",
    "client/admin.lua",
    "client/poseTest.lua",
    "client/adminSalons.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@tgiann-core/server/databaseCreator/main.lua",
    "server/editable.lua",
    "server/classes/*.lua",
    "server/main.lua",
    "server/admin.lua",
    "server/settings.lua",
    "server/trend.lua",
    "server/salons.lua",
    "server/arms.lua",
    "server/peds.lua",
    "server/fit.lua",
    "server/promos.lua",
    "server/cityhub.lua",
    "server/photos.lua",
    "server/business.lua",
    "server/duty.lua",
    "server/seats.lua",
    "server/catalog.lua",
    "server/studio.lua",
    "server/saved.lua",
    "server/orders.lua",
    "server/items.lua",
    "server/shop.lua",
    "server/tests.lua",
    "server/damage.lua",
    "server/database.lua",
}

dependency '/assetpacks'