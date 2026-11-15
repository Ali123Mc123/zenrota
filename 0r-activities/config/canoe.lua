CanoeConfig = ActivitySettings.resolve('canoe', {
    debug = false, -- true: logs for this activity only.
    item = 'canoe', -- Inventory item name. If you change it, rename the item in your inventory too.
    maxSpeed = 6.5, -- Maximum paddling speed in m/s.
    passengerJoinRadius = 2.25,
})
