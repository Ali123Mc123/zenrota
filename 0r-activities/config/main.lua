ActivitiesConfig = ActivitySettings.resolve('main', {
    language = 'tr', -- 'en', 'tr', 'de', 'es', 'fr', 'it', 'nl', 'pl', 'pt-br' or 'ru'. Unknown values fall back to 'en'.
    debug = false, -- true: all activity logs; false: use activity debug settings.
    payment = { -- Used by every paid activity and the activity shop.
        method = 'cash', -- 'cash': takes the money item below from the inventory. 'bank': takes it from the bank account.
        cashItem = 'money', -- Your inventory money item name, e.g. 'money' or 'cash'. Used only with method = 'cash'.
        -- QB-Core without ox_inventory has no money item: there the cash account is used.
    },
    synchronization = {
        rideableItemDistance = 180.0, -- Observer distance for ground gear, trucks, canoe, surf/paddle and standalone floats.
        batchVisualSnapshots = true,
        snapshotBatchMilliseconds = 50,
        scopeRideBroadcasts = true,
        scopeActivityBroadcasts = true,
    },
    debugOptions = {
        snapshotMilliseconds = 2000, -- Server entity snapshots while setup is pending.
        placementWatchMilliseconds = 6000, -- Brief client watch after seating or attachment.
        entityWatchMilliseconds = 10000,
        maxLinesPerSecond = 80, -- Per-side console limit; suppressed lines are counted.
        forwardToClients = true, -- Include server diagnostics in participants' F8 logs.
    },

    framework = {
        system = 'auto' -- 'auto', 'qbx', 'qb', 'esx', 'ox', 'nd', 'none'
        -- Auto: qbx_core > qb-core > es_extended > ox_core > ND_Core.
    },
    inventory = {
        system = 'auto' -- 'auto', 'framework', 'none', or an inventory resource listed below.
        -- 'ox_inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'tgiann-inventory',
        -- 'origen_inventory', 'codem-inventory', 'core_inventory', 'one_inventory', 'jpr-inventory'.
        -- Auto uses an available inventory, then the selected QB/Qbox/ESX framework inventory.
        -- Manual selection never switches inventories; the selected resource must be running.
    },
    vehicleKeys = {
        system = 'auto' -- 'auto', 'none', or a vehicle key resource listed below.
        -- 'qbx_vehiclekeys', 'qb-vehiclekeys', 'qs-vehiclekeys', 'Renewed-Vehiclekeys',
        -- 'MrNewbVehicleKeys', 'wasabi_carlock', 'mk_vehiclekeys', 'mVehicle', 't1ger_keys',
        -- 'F_RealCarKeysSystem', 'jaksams_VehiclesKeys', 'cd_garage', 'okokGarage'.
        -- Manual selection uses only the selected vehicle key system.
    },
    fuel = {
        system = 'auto', -- 'auto', 'native', 'custom', or one of the resources below.
        -- Auto: ox_fuel > lc_fuel > cdn-fuel > ps-fuel > lj-fuel > qb-fuel > LegacyFuel.
        -- Applied at vehicle setup/reset; normal fuel consumption continues.
        custom = function(vehicle, level) -- Used only with system = 'custom'; level is 100 for a full tank.
            -- Paste your fuel script's client code here. Choose one example or use your own:
            -- exports['bazufix-fuel']:SetFuel(vehicle, level)
            -- ox_fuel example:
            -- Entity(vehicle).state:set('fuel', level, true)
        end,
    },

    interaction = 'target', -- Use target interactions or text prompts.
    target = {
        system = 'auto', -- 'auto', 'ox' (ox_target), 'qb' (qb-target).
        distance = 2.5,
    },
    textUi = {
        position = 'left-center' -- Ox Lib TextUI: 'left-center', 'right-center', 'top-center', 'bottom-center'.
    },
    notification = {
        system = 'auto', -- 'auto', 'ox' (ox_lib), 'esx' (es_extended), 'qb' (qb-core).
        -- Auto tries Ox Lib, QB-Core, then ESX; notification selection is independent of the framework.
        -- If a manual notify selection is unavailable, another running notification system is used.
        title = false, -- false uses the localized default title; set a string to override it.
        defaultType = 'info', -- 'info', 'success', 'error', 'warning'; QB/ESX display warnings as regular notifications.
        durationMilliseconds = 4500, -- Notification display duration in milliseconds.
        position = 'top-right' -- Ox Lib / current ESX position; QB-Core uses its own default.
    },

    editorPermissions = { -- Admin access for the three location editors.
        enabled = true, -- false disables /bungeenew, /ziplinenew and /aquanew.
        useFrameworkPermissions = true, -- false checks only the ACE permissions configured below.
        aceGroups = { 'admin', 'god' },
        qbPermissions = { 'god', 'admin' }, -- QB-Core / Qbox permission groups.
        esxGroups = { 'owner', 'admin', 'superadmin' },
        commands = {
            bungeenew = { enabled = true, ace = 'command.bungeenew' },
            ziplinenew = { enabled = true, ace = 'command.ziplinenew' },
            aquanew = { enabled = true, ace = 'command.aquanew' }
        }
    },

    multiplayer = {
        selectionRadius = 8.0,
        invitationMilliseconds = 20000,
    },
    raceDrift = { enabled = true },
    -- true: towed surfboards, floats and parasailers hang on a real rope: they trail behind the boat, swing out
    -- in turns, get pulled when the boat speeds up and the rope sags when it slows down. false: fixed behind the boat.
    towPhysics = {
        enabled = true,
        spacing = { float = 2.4, parasail = 8.4 },
    },
})
