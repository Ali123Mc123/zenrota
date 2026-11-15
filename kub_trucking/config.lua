lib.locale()
Config = {}

Config.Keysystem = 'AUTO'
--Progressbars in ms. ( 5000ms = 5s)
Config.FreightDeliveryProgressBarTime = 5000
Config.QuickDeliveryProgressBarTime = 5000
Config.QuickJobEndProgressBar = 5000
Config.IsProgressBar = true -- If set to false will use progress circle instead of progress bar
--Notification position
Config.NotificationPosition = "center-right" -- 'top' or 'top-right' or 'top-left' or 'bottom' or 'bottom-right' or 'bottom-left' or 'center-right' or 'center-left'
--Quick delivery job unload and return vehicle range
Config.DeliveryPointRange = 10
Config.ReturnVehiclePointRange = 10
--In meters how close does the player have to be for the job vehicle to spawn
Config.VehicleSpawnRange = 150
--Ground Markers
Config.GroundMarkerRange = 100
Config.GroundMarkerHeight = 2
Config.QuickJobMarker = {type = 30, red = 191, green = 191, blue = 191, alpha = 150}
--Is vehicle outline enabled?
Config.VehicleOutlineEnabled = true
Config.VehicleOutLineColor = {223,223,223,125}
--Trailer parking difficulty
Config.TrailerParkingDifficulty = 2 -- 1 = Easy, 2 = Normal, 3 = Hard
--Blip colors -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
Config.BlipColor = 26
Config.RouteColor = 26
--Blip sprites -- https://docs.fivem.net/docs/game-references/blips/
Config.BlipFreightStart = 479
Config.BlipFreightDeliver = 473
Config.BlipQuickVehicle = 477
Config.BlipQuickDelivery = 479
