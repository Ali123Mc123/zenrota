UtilityVehiclesConfigs = ActivitySettings.resolveItems('utility_vehicles', {
    -- DaddyRP: el arabasi (flatbed_hand_truck) kaldirildi
    rub_trolley = {
        item = 'rub_trolley', -- Inventory item name. If you change it, rename the item in your inventory too.
        label = ActivityLocale.shopping_cart(),
        targetDistance = 3.0,
        movement = { maxSpeed = 16.0, sprintMaxSpeed = 20.0 }, -- Normal and sprint speed limits in m/s.
    },
})
