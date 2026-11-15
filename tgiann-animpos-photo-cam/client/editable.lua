local tgiannEmotes = GetResourceState("tgiann-emotes") ~= "missing"
local rpemotesReborn = GetResourceState("rpemotes-reborn") ~= "missing"
local cdevEmoteMenu = GetResourceState("cdev_emotemenu") ~= "missing"
local rdAnimations = GetResourceState("rd-animations") ~= "missing"
local cylexAnimMenuV2 = GetResourceState("cylex_animmenuv2") ~= "missing"
local rAnimations = GetResourceState("r_animations") ~= "missing"

if not (tgiannEmotes or rpemotesReborn or cdevEmoteMenu or rdAnimations or cylexAnimMenuV2 or rAnimations) then
    print("There is no emote menu resource found. Script work without emote menu.")
end

-- Foto kamera (F6) ve V free kamera: hasar alınca/verince bekleme. Kalan süreyi saniye olarak gösterir, en fazla 30 sn.
local damagedAt = 0
AddEventHandler("gameEventTriggered", function(name, args)
    if name ~= "CEventNetworkEntityDamage" then return end
    local ped = PlayerPedId()
    if args[1] == ped or args[2] == ped then damagedAt = GetGameTimer() end
end)

local function damageWait(timer, langKey)
    if not (timer and timer.active) or damagedAt == 0 then return end
    local total = math.min(tonumber(timer.seconds) or 30, 30)
    local left = math.ceil((damagedAt + total * 1000 - GetGameTimer()) / 1000)
    if left > 0 then return t(langKey):format(left, total) end
end

--- @return boolean, string @true, send error notification message
function EditableCanOpenPhotoCam()
    local msg = damageWait(config.photoCam.damageTimer, "PHOTO_CAM_CANT_OPEN_DAMAGED_TIME")
    if msg then return false, msg end
    return true, t("PHOTO_CAM_CANT_OPEN_MENU_EDITABLE")
end

--- @return boolean, string @true, send error notification message
function EditableCanOpenFreeCam()
    local msg = damageWait(config.freeCam.damageTimer, "FREE_CAM_CANT_OPEN_DAMAGED_TIME")
    if msg then return false, msg end
    return true, t("FREE_CAM_CANT_OPEN_MENU_EDITABLE")
end

-- An export of a stopped/restarted emote resource throws: never let that break the photo cam or animpos.
local function try(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

--- @return boolean @true, if player is playing animation
function IsPlayingAnim()
    local playing
    if tgiannEmotes then
        playing = try(function() return exports["tgiann-emotes"]:GetCurrentEmote() ~= nil end)
    elseif rpemotesReborn then
        playing = try(function() return exports["rpemotes-reborn"]:IsPlayerInAnim() end)
    elseif cdevEmoteMenu then
        playing = try(function() return exports["cdev_emotemenu"]:isAnimRunning() end)
    elseif rdAnimations then
        playing = try(function() return exports["rd-animations"]:IsPlayingAnimation() end)
    elseif cylexAnimMenuV2 then
        -- getCurrentEmote returns the emote itself (a table/string, false when none), not a boolean
        playing = try(function()
            local api = exports["cylex_animmenuv2"]
            return (api:getCurrentEmote() or api:isEmotePlaying()) and true or false
        end)
    elseif rAnimations then
        playing = try(function() return exports["r_animations"]:IsPlayingAnimation() end)
    else
        return true
    end
    if playing then return true end
    -- A pose started some other way (/e of another script, a scenario, tgiann-core's anim report) still counts
    local ped = PlayerPedId()
    if IsPedUsingAnyScenario(ped) then return true end
    return type(LocalPlayer.state.tgiannAnim) == "table"
end

function OnAnimPosOpen()
    -- Your code here
end

function OnAnimPosClose()
    -- Your code here
end

-- F6 photo cam: every other UI goes away while the camera is up and comes back when it closes. (The stock hook only
-- fired "tgiann-lumihud:ui", and lumihud is not on this server, so nothing was hidden.)
-- wais-primehud: in this build its export pair works the other way round (showHud hides, hideHud shows; see
-- daddy_multichar/shared/sh_defaults.lua), so each export is called for the opposite of its name.
local HUDS = {
    { resource = "wais-primehud", hide = "showHud", show = "hideHud" },
}
local hiders = {} -- photo cam and free cam can overlap (V inside F6): the HUD comes back when the last one closes

local function anyHider()
    return next(hiders) ~= nil
end

local function setHuds(visible)
    for _, hud in ipairs(HUDS) do
        if GetResourceState(hud.resource) == "started" then
            local fn = visible and hud.show or hud.hide
            local ok, err = pcall(function() exports[hud.resource][fn](exports[hud.resource]) end)
            if not ok then print(("^3[tgiann-animpos-photo-cam] %s:%s failed: %s^7"):format(hud.resource, fn, tostring(err))) end
        end
    end
    TriggerEvent("tgiann-lumihud:ui", visible) -- the stock hook, harmless without lumihud
end

---@param who "photo"|"free"
local function hideUis(who)
    local was = anyHider()
    hiders[who] = true
    if was then return end
    setHuds(false)
    CreateThread(function()
        while anyHider() do
            HideHudAndRadarThisFrame() -- GTA HUD and minimap
            ThefeedHideThisFrame()     -- GTA notifications feed
            Wait(0)
        end
    end)
end

---@param who "photo"|"free"
local function showUis(who)
    if not hiders[who] then return end
    hiders[who] = nil
    if anyHider() then return end
    setHuds(true)
end

-- um-chat typing dots ("...") stay out of photos and free cam:
-- um-chat skips drawing while LocalPlayer.state.inCameraMode is set (and while any script camera renders).
local cams = {}
local function setCameraMode(who, on)
    cams[who] = on or nil
    LocalPlayer.state:set("inCameraMode", next(cams) ~= nil, false)
end

AddEventHandler("onResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    if next(cams) then
        cams = {}
        LocalPlayer.state:set("inCameraMode", false, false)
    end
    if not anyHider() then return end
    hiders = {}
    setHuds(true)
end)

function OnPhotoCamOpen()
    setCameraMode("photo", true)
    hideUis("photo")
end

function OnPhotoCamClose()
    setCameraMode("photo", false)
    showUis("photo")
end

-- V free cam (held for a quick look) keeps the HUD as before; to hide it there too: hideUis("free") / showUis("free")
function OnFreeCamOpen()
    setCameraMode("free", true)
    TriggerEvent("tgiann-lumihud:ui", false)
end

function OnFreeCamClose()
    setCameraMode("free", false)
    TriggerEvent("tgiann-lumihud:ui", true)
end

-- The photo goes straight from this game to Fivemanage through the one-time address the server got (server/editable.lua
-- GetScreenShot): the full-size picture never crosses the FiveM connection. Returns the photo's https URL, or nil.
-- Every shot needs its own upload address: one used before is refused (server/editable.lua also refuses a URL it
-- already handed out and asks again), so a shot can never be saved under the first photo's URL.
local usedUploads = {}
local busy = false

lib.callback.register("tgiann-animpos-photo-cam:uploadPhoto", function(uploadUrl)
    if type(uploadUrl) ~= "string" or not uploadUrl:match("^https://") then return nil end
    if usedUploads[uploadUrl] then
        print("^3[tgiann-animpos-photo-cam] The server sent an upload address that was already used, refused^7")
        return nil
    end
    if busy then return nil end -- one shot at a time: two answers must never cross
    if GetResourceState("screenshot-basic") ~= "started" then return nil end
    usedUploads[uploadUrl] = true
    busy = true
    local p, settled = promise.new(), false
    local function settle(url)
        if settled then return end
        settled = true
        busy = false
        p:resolve(url)
    end
    exports["screenshot-basic"]:requestScreenshotUpload(uploadUrl, "file", { encoding = "webp", quality = 0.92 }, function(body)
        local ok, data = pcall(json.decode, body or "")
        data = ok and type(data) == "table" and data or {}
        local url = (type(data.data) == "table" and data.data.url) or data.url
        if type(url) ~= "string" then
            print(("[tgiann-animpos-photo-cam] Fivemanage answered: %s"):format(tostring(body):sub(1, 200)))
            return settle(nil)
        end
        lib.setClipboard(url) -- the page copies it too; ox_lib's copy also works when the page's own copy is refused
        settle(url)
    end)
    SetTimeout(30000, function() settle(nil) end) -- no answer: the server falls back to tgiann-media-lib
    return Citizen.Await(p)
end)
