-- Head shots through MugShotBase64 when it runs; nil otherwise.
local mugshot = {}
local RESOURCE = 'MugShotBase64'

function mugshot.available()
    return GetResourceState(RESOURCE) == 'started'
end

-- A PNG data URL of the ped's face, at most maxBytes long.
function mugshot.capture(ped, maxBytes)
    if not mugshot.available() then return nil end
    local ok, photo = pcall(function() return exports[RESOURCE]:GetMugShotBase64(ped or PlayerPedId(), false) end)
    if ok and type(photo) == 'string' and photo:sub(1, 22) == 'data:image/png;base64,' and #photo <= (maxBytes or 400000) then return photo end
end

return mugshot
