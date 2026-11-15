-- Optional: lets the pause map show the names OTHER resources give their blips (no native can read a blip's name).
-- Add it as the FIRST client script of that resource's fxmanifest:   client_script '@daddy_pausemenu/shim/blipnames.lua'
-- Natives are per-resource globals in Lua, so wrapping them here only touches the resource that loads this file.
-- Lua resources only; names set through N_0x... aliases or Citizen.InvokeNative are not seen.
if GetCurrentResourceName() == 'daddy_pausemenu' then return end

local EVENT = 'daddy_pausemenu:map:blipName'
local pendingKey, parts = nil, {}
local known = {} -- [blip] = { text, key }, sent again when the pause menu restarts

-- Read every original first: the lazy native loader also defines aliases, and must not undo our wrappers later.
local rawBegin = BeginTextCommandSetBlipName
local rawEnd = EndTextCommandSetBlipName
local rawPlayerName = AddTextComponentSubstringPlayerName -- AddTextComponentString is an alias
local rawTextLabel = AddTextComponentSubstringTextLabel
local rawInteger = AddTextComponentInteger
local rawFromFile = SetBlipNameFromTextFile
local rawToPlayer = SetBlipNameToPlayerName

local function resolve()
    if pendingKey == nil or pendingKey == 'STRING' then return table.concat(parts) end
    -- A label key (AddTextEntry) with ~a~ / ~1~ slots filled in order.
    local i = 0
    local fill = function()
        i = i + 1
        return parts[i] or ''
    end
    return (GetLabelText(pendingKey):gsub('~a~', fill):gsub('~1~', fill))
end

local function notify(blip, text, key)
    known[blip] = { text, key }
    TriggerEvent(EVENT, blip, text, key)
end

AddEventHandler('daddy_pausemenu:map:collectBlipNames', function()
    for blip, v in pairs(known) do
        if DoesBlipExist(blip) then
            TriggerEvent(EVENT, blip, v[1], v[2])
        else
            known[blip] = nil
        end
    end
end)

BeginTextCommandSetBlipName = function(label)
    pendingKey, parts = label, {}
    return rawBegin(label)
end

AddTextComponentSubstringPlayerName = function(text)
    if pendingKey ~= nil then parts[#parts + 1] = tostring(text) end
    return rawPlayerName(text)
end
AddTextComponentString = AddTextComponentSubstringPlayerName

AddTextComponentSubstringTextLabel = function(label)
    if pendingKey ~= nil then parts[#parts + 1] = GetLabelText(label) end
    return rawTextLabel(label)
end

AddTextComponentInteger = function(value)
    if pendingKey ~= nil then parts[#parts + 1] = tostring(value) end
    return rawInteger(value)
end

EndTextCommandSetBlipName = function(blip)
    local result = rawEnd(blip)
    if pendingKey ~= nil then notify(blip, resolve(), pendingKey) end
    pendingKey, parts = nil, {}
    return result
end

-- A removed blip's name goes with it: GTA hands its handle to the next new blip (of any resource).
local rawRemove = RemoveBlip
RemoveBlip = function(blip)
    if known[blip] then
        known[blip] = nil
        TriggerEvent(EVENT, blip, nil, nil)
    end
    return rawRemove(blip)
end

SetBlipNameFromTextFile = function(blip, gxt)
    notify(blip, GetLabelText(gxt), gxt)
    return rawFromFile(blip, gxt)
end

SetBlipNameToPlayerName = function(blip, player)
    notify(blip, GetPlayerName(player), 'PLAYER')
    return rawToPlayer(blip, player)
end
