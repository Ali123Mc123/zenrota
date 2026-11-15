---@meta

-- CONFIG TYPES -------------------------------------------------------------

---@class AnimPosPhotoCamToggleName
---@field active boolean
---@field name string

---@class AnimPosPhotoCamHeadText
---@field active boolean
---@field cd number
---@field showTime number
---@field dist number

---@class AnimPosPhotoCamCanOpen
---@field damage { active: boolean, time: number }
---@field handWeapon boolean

---@class AnimPosConfig
---@field active boolean
---@field command AnimPosPhotoCamToggleName
---@field key AnimPosPhotoCamToggleName
---@field maxDistance { xy: number, z: number }
---@field cameraMaxDistance number
---@field abuseControl boolean
---@field playerOpacity { active: boolean, opacity: number }
---@field headText AnimPosPhotoCamHeadText
---@field destroyAnimPosKeys number[]

---@class PhotoCamFilter
---@field label string
---@field source string|false

---@class PhotoCamPolaroidConfig
---@field active boolean
---@field name string
---@field needItem AnimPosPhotoCamToggleName

---@class PhotoCamConfig
---@field active boolean
---@field command AnimPosPhotoCamToggleName
---@field key AnimPosPhotoCamToggleName
---@field item AnimPosPhotoCamToggleName
---@field polaroidImageItem PhotoCamPolaroidConfig
---@field camSetting { distance: number, zoom: number, minZoom: number, maxZoom: number, height: number, lookButton: "left"|"right"|"both", move: { active: boolean, maxDistance: number } }
---@field canOpen AnimPosPhotoCamCanOpen
---@field headText AnimPosPhotoCamHeadText
---@field filterList PhotoCamFilter[]

---@class FreeCamConfig
---@field active boolean
---@field key { name: string, second: number }
---@field canOpen AnimPosPhotoCamCanOpen
---@field camSetting { yOffset: number, zOffset: number, maxDistance: number }
---@field hiddenClose { active: boolean, seconds: number }
---@field headText AnimPosPhotoCamHeadText

-- RUNTIME TYPES ------------------------------------------------------------

---Light in the character's space: x right, y front, height above the ped origin (meters)
---@class PhotoCamLight
---@field active boolean
---@field x number
---@field y number
---@field height number
---@field aimAuto boolean beam follows the chest bone
---@field yaw number degrees clockwise from the character's front (manual aim)
---@field tilt number degrees below the horizon (manual aim)
---@field brightness number
---@field spread number cone size passed to DrawSpotLight radius
---@field softness number 0-100, drives roundness and falloff
---@field color integer[]

---@class PhotoCamShotResult
---@field ok boolean
---@field url? string
---@field errKey? string
---@field errArgs? any[]
