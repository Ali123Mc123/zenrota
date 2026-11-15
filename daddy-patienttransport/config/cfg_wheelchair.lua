Config = Config or {}

Config.Wheelchair = {
    serverVehicleType = 'automobile', -- server spawn type, keep 'automobile'
    model = 'dd_wheelchair_black',    -- color spawned from the item, one of the models below
    models = { 'dd_wheelchair', 'dd_wheelchair_black', 'dd_wheelchair_burgundy', 'dd_wheelchair_green', 'dd_wheelchair_grey' },
    pickupDistance = 2.5,             -- distance to start pushing (m)
    interactDistance = 3.0,           -- target distance on the wheelchair (m)
    deleteDistance = 3.0,             -- /delwheelchair search distance (m)
    dropKeybind = 'G',                -- key to let go while pushing
    lockable = true,                  -- brakes: a locked wheelchair cannot be driven
    lockNotifyCooldown = 3000,        -- delay between "brakes on" warnings (ms)
    enableCommands = false,           -- /wheelchair and /delwheelchair for EMS
    enableItem = true,                -- use the item to unfold a wheelchair
    item = 'tsandalye',              -- item name
    itemSpawnDistance = 1.5,          -- how far in front the wheelchair unfolds (m)
    permissions = {
        enabled = true,               -- EMS can give players permanent brake and inventory access
        command = 'sandalyeizin',     -- command that opens the access menu (DaddyRP: Turkish)
        grantDistance = 5.0,          -- max distance to the player getting access (m)
        rateLimitMs = 750,
        stateKey = 'daddyPT:wheelchairAccess',
        kvpKey = 'daddyPT:wheelchairPermissions:v1',
    },
}
