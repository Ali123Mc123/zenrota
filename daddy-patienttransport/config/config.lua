Config = Config or {}

Config.Language = 'tr'                  -- 'en' or 'tr', see locales/
Config.Framework = 'auto'               -- 'auto', 'qbx', 'qb' or 'esx'

Config.JobName = 'ambulance'            -- job allowed to use the equipment, or a list: { 'ambulance', 'doctor' }
Config.RequireOnDuty = true             -- Qbox/QBCore only, ESX has no duty state

Config.EnableTestCommands = false       -- /testped and /deltestped spawn a local injured NPC to practise with
Config.TestBypassJob = false            -- test only: skips the job check for everyone, only works while EnableTestCommands is true

-- Optional hooks, leave nil for the built-in behaviour.
-- Client: return true when the local player is downed (custom medical script).
Config.IsDowned = nil                   -- function() return exports.my_medical:IsDead() end
-- Server: give the wheelchair keys to a player (default fires 'vehiclekeys:client:SetOwner').
Config.GiveKeys = nil                   -- function(target, vehicle) end
