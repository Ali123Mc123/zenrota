---@alias MediaCatalogKind "furniture"|"shellmodel"
---@alias MediaShootMode "missing"|"all"|"one"
---@alias MediaStorageProvider "server"|"fivemstats"|"fivemanage"|"discord"|"custom"

-- CONFIG TYPES -------------------------------------------------------------

---@class MediaConfigCommands
---@field migrate string

---@class MediaConfigAdmin
---@field ace string

---@class MediaColor
---@field r integer
---@field g integer
---@field b integer

---@class MediaConfigStudio
---@field position vector3
---@field weather string
---@field hour integer
---@field minute integer
---@field imageSize integer
---@field webpQuality integer
---@field outlineSize integer
---@field applyDelay integer
---@field cameraDistanceMultiplier number
---@field greenScreen MediaColor
---@field shellBackdrop MediaColor
---@field shellModelWidth integer

---@class MediaConfigVehicleShoot
---@field imageSize integer
---@field webpQuality integer
---@field outlineSize integer
---@field applyDelay integer
---@field fov number
---@field cameraDistanceMultiplier number

---@class MediaVehicleShootOptions
---@field mode? MediaShootMode   "missing" when nil
---@field models? string[]       the vehicles to shoot ("missing" / "all")
---@field model? string          the model of mode "one"
---@field imageBase? string      where the caller shows uploaded pictures (<imageBase><model>.webp), lets "missing" check uploads

---@class MediaConfigClip
---@field fps integer
---@field maxSize integer        longest side in pixels
---@field webpQuality integer    1-100
---@field shadowSize integer     0 = no shadow

---@class MediaClipOptions
---@field duration integer       ms
---@field fps? integer
---@field maxSize? integer
---@field webpQuality? integer   1-100
---@field shadowSize? integer
---@field tint? MediaColor clay look: the subject is repainted in this colour, its brightness kept as shading
---@field area? { x: number, y: number, width: number, height: number } pictured part of the screen (0-1)

---@class MediaConfigPhoto
---@field width integer
---@field quality integer        webp quality 1-100
---@field maxSizeKb integer      file size limit, the quality and then the width drop to fit

---@class MediaConfigFivemanage
---@field apiKey string

---@class MediaConfigDiscord
---@field webhook string

--- Storage of one script
---@class MediaScriptStorage
---@field provider MediaStorageProvider
---@field path string              folder in FiveM Stats, Fivemanage or the custom service ("" = root)

---@class MediaConfigStorage server only (configs/configStorageServer.lua)
---@field fivemanage MediaConfigFivemanage
---@field discord MediaConfigDiscord
---@field default MediaScriptStorage scripts not listed in `scripts`
---@field scripts table<string, MediaScriptStorage> resource name -> its storage

-- EXPORT TYPES ---------------------------------------------------------------

---@class MediaTakePhotoOptions
---@field hideSubjects? boolean  hide every ped and occupied vehicle for this client while the frame is taken
---@field width? integer         config.photo.width when nil
---@field quality? integer       1-100, config.photo.quality when nil
---@field maxSizeKb? integer     config.photo.maxSizeKb when nil

---@class MediaPlayerPhotoOptions
---@field width? integer         config.photo.width when nil
---@field quality? integer       1-100, config.photo.quality when nil
---@field maxSizeKb? integer     config.photo.maxSizeKb when nil
---@field hideSubjects? boolean  hide every ped and occupied vehicle for that player while the frame is taken

---@class MediaShootOptions
---@field kind MediaCatalogKind
---@field mode? MediaShootMode   "missing" when nil
---@field models? string[]       every model of the catalog ("missing" / "all")
---@field model? string          the model of mode "one"

---@class MediaCatalogItem
---@field model string
---@field label? string

---@class MediaCatalogCategory
---@field key string|integer
---@field label? string
---@field items MediaCatalogItem[]

---@class MediaManagerCatalog
---@field kind MediaCatalogKind
---@field label? string          tab name, the default one of the kind when nil
---@field categories MediaCatalogCategory[]

---@class MediaManagerOptions
---@field title? string          shown under the window brand (e.g. "tgiann-housing")
---@field catalogs MediaManagerCatalog[]
---@field onClose? function      runs when the admin closes the window

---@class MediaPhotoOwner server side handlers of a script that keeps photo refs
---@field getRefs fun(): string[]                   every photo path or URL the script uses
---@field replaceRef fun(old: string, new: string)  swap a ref in the script data (move to Fivemanage)

-- INTERNAL -------------------------------------------------------------------

---@class MediaClientState
---@field uiLoaded boolean
---@field uiFocused boolean
---@field busy boolean           a studio shoot runs
---@field lumiColor? table

---@class MediaStudioSphere
---@field center vector3
---@field size number
---@field color MediaColor

---@class MediaManagerSession
---@field resource string
---@field catalogs MediaManagerCatalog[]
---@field onClose? function

---@class MediaMigration
---@field stage "idle"|"scan"|"upload"|"done"
---@field total integer photos to move
---@field done integer photos handled (moved or failed)
---@field moved integer
---@field failed integer
---@field unused integer images/ files no script uses (left in place)
---@field current? string photo being uploaded
