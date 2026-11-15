-- The panel (/campusadmin): places from World.panel, and the canteen items.
World.panel({ view = 'campus.admin', calls = { 'canteenItems', 'saveCanteenItem', 'removeCanteenItem', 'canteenStarter' }, reach = Config.Admin.PlacementReach })
