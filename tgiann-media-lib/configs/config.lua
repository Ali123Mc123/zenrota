tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()

config.langs = {}

-- Settings live in two files next to this one:
--   config.lua                general settings, photo studio and photo quality
--   configStorageServer.lua   SERVER ONLY: where every script stores its photos and videos (FiveM Stats, local folder, Fivemanage, Discord or your own service)
-- This resource takes and stores the photos of tgiann-housing, tgiann-motel and other tgiann scripts
-- Language comes from the tgiann-core config

-- Chat commands
---@type MediaConfigCommands
config.mediaCommands = {
    migrate = "mediaphotostofivemanage", -- Moves the images/ photos of every script to Fivemanage (admins or console)
}

-- Who can take, upload and manage photos
---@type MediaConfigAdmin
config.admin = {
    ace = "command", -- ACE permission needed for the photo tools
}

-- Catalog photo studio: furniture photos (green screen, cut out) and shell model photos (you frame them yourself)
---@type MediaConfigStudio
config.studio = {
    position = vector3(0.0, 0.0, 300.0),        -- Studio point, high in the sky with nothing around
    weather = "EXTRASUNNY",                     -- Weather during the studio shoot
    hour = 14,                                  -- Hour of the day during the studio shoot
    minute = 0,                                 -- Minute of the day during the studio shoot
    imageSize = 300,                            -- Size of a furniture photo in pixels (square)
    webpQuality = 80,                           -- WebP quality of furniture photos (1-100, higher = sharper and bigger files)
    outlineSize = 3,                            -- Black outline around the furniture in pixels (0 = no outline)
    applyDelay = 150,                           -- Wait after a prop spawns before its photo is taken (ms), raise it on slow PCs
    cameraDistanceMultiplier = 1.15,            -- Extra space around the prop in the photo (1.0 = the prop fills the whole photo)
    greenScreen = { r = 0, g = 255, b = 0 },    -- Green screen color behind the props, it is cut out of the photo
    shellBackdrop = { r = 70, g = 70, b = 70 }, -- Backdrop color around a shell during the shell model shoot (stays in the photo)
    shellModelWidth = 640,                      -- Width of a shell model photo in pixels
}

-- Vehicle pictures: every vehicle is shot on the green screen, cut out and saved as <model>.webp where
-- configs/configStorageServer.lua says for the script that shoots them (tgiann-vehicleshop). With provider "server"
-- they go into the folder of tgiann-core config.vehicleImages (server.cfg needs: add_filesystem_permission tgiann-media-lib write tgiann-vehicle-images)
---@type MediaConfigVehicleShoot
config.vehicleShoot = {
    imageSize = 512,                -- Size of a picture in pixels (square, the vehicle is fitted into it)
    webpQuality = 85,               -- WebP quality (1-100, higher = sharper and bigger files)
    outlineSize = 0,                -- Black outline around the vehicle in pixels (0 = no outline)
    applyDelay = 600,               -- Wait after a vehicle spawns before its picture is taken (ms), raise it on slow PCs
    fov = 40,                       -- Camera field of view (lower = flatter, less distorted look)
    cameraDistanceMultiplier = 1.0, -- Extra space around the vehicle (1.0 = it fills the picture)
}

-- Animated clips shot on the green screen (tgiann-emotes previews), saved as animated WebP
---@type MediaConfigClip
config.clip = {
    fps = 12,         -- Frames per second (higher = smoother and bigger files)
    maxSize = 256,    -- Longest side of a clip in pixels
    webpQuality = 60, -- WebP quality of every frame (1-100, higher = sharper and bigger files)
    shadowSize = 4,   -- Soft black shadow around the cut out subject in pixels (0 = no shadow)
}

-- Gallery photos (shells, rooms, interiors, houses): the big pictures players see, kept sharp on purpose
---@type MediaConfigPhoto
config.photo = {
    width = 1920,     -- Width of the photos in pixels (the game view is only scaled down to it, never up)
    quality = 100,    -- WebP quality of the photos (1-100, higher = sharper and bigger files)
    maxSizeKb = 2000, -- Largest photo file in KB (max 3000); a busier shot is saved a little softer to fit, players download every photo they open
}
