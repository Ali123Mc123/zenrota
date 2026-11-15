local pma = exports["pma-voice"]
local mumble = exports["mumble-voip"]
local toko = exports["tokovoip_script"]
local MumbleIsPlayerTalking = MumbleIsPlayerTalking
local NetworkIsPlayerTalking = NetworkIsPlayerTalking

local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end

    return false
end

table.copy = function(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local watchingSources = {}

RegisterNetEvent("cylex_phone:voice:addToCall", function(callId, src, callerSource)
    AddToCall(callId, src, callerSource)
end)

RegisterNetEvent("cylex_phone:voice:removeFromCall", function(callId, src, callerSource)
    RemoveFromCall(callId, src, callerSource)
end)


function AddToCall(callId, src, callerSource)
    print("Joining call", callId, src, callerSource)

    local success = pcall(function()
        if Config.Voice.Script == "pma" then
            pma:addPlayerToCall(callId)
        elseif Config.Voice.Script == "mumble" then
            mumble:addPlayerToCall(callId)
        elseif Config.Voice.Script == "salty" then
            TriggerServerEvent("phone:voice:addToCall", callId)
        elseif Config.Voice.Script == "toko" then
            toko:addPlayerToRadio(callId)
        elseif Config.Voice.Script == "bs-voice" then
            TriggerEvent("bs:voice:phone:call:start", callerSource, callId)
            TriggerEvent("bs:voice:phone:call:start", src, callId)
            -- TriggerEvent("bs:voice:phone:call:end", 
        end
    end)

    if not success then
        print("error", "Failed to join call (unsupported voice script)")
    end
end

function RemoveFromCall(callId, src, callerSource)
    print("Leaving call", callId, src, callerSource)

    local success = pcall(function()
        if Config.Voice.Script == "pma" then
            pma:removePlayerFromCall()
        elseif Config.Voice.Script == "mumble" then
            mumble:removePlayerFromCall()
        elseif Config.Voice.Script == "salty" then
            TriggerServerEvent("phone:voice:removeFromCall", callId)
        elseif Config.Voice.Script == "toko" then
            toko:removePlayerFromRadio(callId)
        elseif Config.Voice.Script == "bs-voice" then
            TriggerEvent("bs:voice:phone:call:end", callerSource, callId)
            TriggerEvent("bs:voice:phone:call:end", src, callId)
        end
    end)

    if not success then
        print("error", "Failed to leave call (unsupported voice script)")
    end
end

function ToggleSpeaker(enabled)
    if Config.Voice.Script == "salty" then
        TriggerServerEvent("phone:voice:toggleSpeaker", enabled)
    end
end

function IsTalking()
    if Config.Voice.Script == "pma" or Config.Voice.Script == "mumble" or Config.Voice.Script == "bs-voice" then
        return MumbleIsPlayerTalking(PlayerId())
    end

    return NetworkIsPlayerTalking(PlayerId())
end

local function ConvertProximityToUnits(proximity)
    return -0.3045 * proximity^2 + 5.016 * proximity - 2.5919
end

function GetVoiceMaxDistance()
    local proximity = MumbleGetTalkerProximity()

    return ConvertProximityToUnits(proximity)
end

-- This thread is used to send the talking state to the frontend, used to record audio only when talking in-game
CreateThread(function()
    local talking = false

    RegisterNUICallback("isTalking", function(_, cb)
        cb(IsTalking())
    end)

    local function setTalkingData(talking)
        SendNUIMessage({
            action = "setData",
            key = "isTalking",
            type = "set",
            value = talking,
        })
        SendNUIMessage({
            action = "voiceRecord",
            type = "camera:toggleMicrophone",
            data = talking,
        })
    end

    while true do
        Wait(100)

        if IsTalking() and not talking then
            talking = true
            setTalkingData(talking)
        elseif not IsTalking() and talking then
            talking = false
            setTalkingData(talking)
        end
    end
end)