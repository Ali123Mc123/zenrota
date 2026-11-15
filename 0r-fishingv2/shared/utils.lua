local Config <const> = require 'config.main'
Scriptname = '0r-fishingv2'

-- local original_print = print

function Debug(message, ...)
   if Config.Debug then
      local formattedMessage = string.format(message, ...)
      print("[DEBUG] " .. formattedMessage)
   end
end

-- print = function(...)
--    local info = debug.getinfo(2, 'Sl')
--    local source = info.short_src or 'unknown'
--    local line = info.currentline or -1
--    local args = {...}

--    local str = ''
--    for i = 1, #args do
--       str = str .. tostring(args[i]) .. (i < #args and '\t' or '')
--    end

--    local yellow = '^3'
--    local reset = '^0'

--    original_print(string.format('%s[%s:%d]%s %s', yellow, source, line, reset, str))
-- end


local function LoadLocaleFile()
   local path = 'locales/' .. Config.Locale .. '.json'
   local file = LoadResourceFile(GetCurrentResourceName(), path)

   if not file then
      file = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
      print(('Locale file "%s" not found, falling back to default "en".'):format(Config.Locale))
   end

   return file
end

local function LoadLocale()
   local file = LoadLocaleFile()

   if not file or file == '' then
      error('Locale file is empty or not found')
   end

   local success, content = pcall(json.decode, file)

   if not success then
      error(('Failed to decode json from locale file: %s'):format(content))
   end

   if not content['LUA'] then
      error('Missing "LUA" section in locale file')
   end

   return content
end

Locales = LoadLocale()

function _T(key, ...)
   -- Handle nested keys like "LUA.notifications.error.not_enough_money"
   local keys = {}
   for k in string.gmatch(key, "[^%.]+") do
      table.insert(keys, k)
   end

   local current = Locales
   for _, k in ipairs(keys) do
      if current and current[k] then
         current = current[k]
      else
         -- Key not found, return the original key
         return key
      end
   end

   -- If we found a string value, format it with the provided arguments
   if type(current) == "string" then
      return current:format(...)
   end

   -- If we found something else (like a table), return the key
   return key
end

-- Helper function to get all locales for NUI
function GetLocales()
   return Locales
end

function SaveDatabase(data)
   SaveResourceFile(GetCurrentResourceName(), "database/index.json", json.encode(data, { indent = false }), -1)
end

--- GetRandomCoordInCircle()
--- @param centerCoords vector3 - The center coordinates of the circle
--- @param radius number - The radius of the circle (default: 30.0)
--- @return vector3 - Random coordinates within the circle
function GetRandomCoordInCircle(centerCoords, radius)
   radius = radius or 30.0

   -- Generate random angle and distance
   local angle = math.random() * 2 * math.pi
   local distance = math.sqrt(math.random()) * radius

   -- Calculate new coordinates
   local x = centerCoords.x + distance * math.cos(angle)
   local y = centerCoords.y + distance * math.sin(angle)
   local z = centerCoords.z

   return vector3(x, y, z)
end
