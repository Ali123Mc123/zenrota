if not Config.ShowDebug then return end

local context = GetHudDebugContext()
local minimapState, locationFeed, viewFeed, damageFeed = context.minimapState, context.locationFeed, context.viewFeed, context.damageFeed
local hideAbleElements, directions = context.hideAbleElements, context.directions

local function form()
    return GetHudDebugContext().form
end

local hudStress = { active = false, stop = false, report = nil }
local STRESS_PHASE_MS = 6000
local STRESS_PHASES = { "car", "boat", "plane", "heli", "bike", "moto" }
local STRESS_STATUS = {
    { type = "UPDATE_PLAYER_STATUS", health = 100, armour = 100, hunger = 100, thirst = 100, stamina = 100, stress = 0, inwater = false },
    { type = "UPDATE_PLAYER_STATUS", health = 35, armour = 60, hunger = 70, thirst = 55, stamina = 80, stress = 30, inwater = false },
    { type = "UPDATE_PLAYER_STATUS", health = 80, armour = 0, hunger = 60, thirst = 50, stamina = 70, stress = 10, inwater = false },
    { type = "UPDATE_PLAYER_STATUS", health = 70, armour = 40, hunger = 0, thirst = 45, stamina = 60, stress = 40, inwater = false },
    { type = "UPDATE_PLAYER_STATUS", health = 25, armour = 0, hunger = 0, thirst = 0, stamina = 30, stress = 70, inwater = false },
    { type = "UPDATE_PLAYER_STATUS", health = 90, armour = 20, hunger = 80, thirst = 80, stamina = 55, stress = 15, inwater = true },
    { type = "UPDATE_PLAYER_STATUS", health = 5, armour = 0, hunger = 8, thirst = 6, stamina = 4, stress = 95, inwater = false },
}
local STRESS_WEAPONS = {
    { name = "Pistol", hash = 453432689, ammo = 12, clip = 84, image = "WEAPON_PISTOL" },
    { name = "Combat PDW Mk II", hash = -1074790547, ammo = 30, clip = 120, image = "WEAPON_ASSAULTRIFLE" },
    { name = "Knife", hash = -1716189206, ammo = 0, clip = 0, image = "WEAPON_KNIFE" },
    { name = "Fist", hash = -1569615261, ammo = 0, clip = 0 },
}
local STRESS_STREETS = { "Vinewood Blvd", "Mirror Park Boulevard", "Del Perro Freeway", "Great Ocean Highway Near Chumash", "Alta St" }
local STRESS_VOICE = { { mic = false, radio = false }, { mic = true, radio = false }, { mic = true, radio = true }, { mic = false, radio = false, muted = true }, { mic = true, radio = false, megaphone = true } }

RegisterNetEvent('wais:primehud:client:perfSaved', function(file)
    Config.Debug(("[wais-primehud] report saved: %s"):format(file or "FAILED (needs an admin group from Config.ApplyToAll, ShowDebug on the server, and the perf folder)"))
end)

RegisterNUICallback('stressReport', function(data, cb)
    if hudStress.active and type(data) == "table" then hudStress.report = data.report end
    cb("ok")
end)

function mapStyleTest(id, method)
    Player.customizations.mapStyle = id
    minimapState.styleKey = nil
    applyMapStyle()

    if method == "big" then
        refreshMinimap()
    elseif method == "pause" then
        ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MAP"), false, -1)
        Wait(1500)
        SetFrontendActive(false)
    elseif method == "zoom" then
        SetRadarZoom(1)
        Wait(150)
        SetRadarZoom(0)
    elseif method == "hide" then
        DisplayRadar(false)
        Wait(300)
        DisplayRadar(true)
    end
end

function restoreHudStress(prior)
    local live = GetHudDebugContext()
    locationFeed.heading = prior.heading
    locationFeed.lastHeading = nil
    resetLocationFeed()
    resetWaypointFeed()
    SendNUIMessage({ type = "UPDATE_WAYPOINT", distance = -1 })
    viewFeed.aiming, viewFeed.firstPerson = prior.aiming, prior.firstPerson
    viewFeed.lastAiming, viewFeed.lastFirstPerson = nil, nil
    damageFeed.enabled, damageFeed.headingUntil = prior.damage, 0

    local vehicle = Player.vehicle
    local inVehicle = vehicle.vehicle > 0
    SendNUIMessage({ type = "UPDATE_PLAYER_CAR", vehicle = (inVehicle and not vehicle.isBlacklisted) and vehicle.vehicle or 0 })
    SendNUIMessage({ type = "UPDATE_PLAYER_SEAT", seat = vehicle.seat })
    SendNUIMessage({ type = "UPDATE_BICYCLE", state = inVehicle and vehicle.class == 13, kmh = 0 })
    SendNUIMessage({ type = "UPDATE_MOTORCYCLE", state = inVehicle and vehicle.class == 8 })
    SendNUIMessage({ type = "PAUSE_MENU", state = Player.pausemenu })
    SendNUIMessage({ type = "HIDE_RADAR", state = hideAbleElements.radar })
    SendNUIMessage({ type = "UPDATE_MEGAPHONE", state = live.megaphone })
    SendNUIMessage({ type = "SALTY_MIC_MUTED", state = false })
    SendNUIMessage({ type = "SALTY_SOUND_MUTED", state = false })
    SendNUIMessage({ type = "UPDATE_MIC", state = live.pma and MumbleIsPlayerTalking(Player.pId) or false, radio = Player.voice.radio })
    SendNUIMessage({ type = "TOGGLE_SETTINGS", state = live.settings })
    SendNUIMessage({ type = "TOGGLE_EDITOR_MODE", state = live.editor })
    SendNUIMessage({ type = "TOGGLE_CINEMATIC", cinematic = prior.cinematic })
    SendNUIMessage({ type = "TOGGLE_HUD", state = Player.hudOff == true })
    if not live.carControl then SendNUIMessage({ type = "CLOSE_CAR_CONTROL" }) end
    if Player.vehicle.soundData == nil then SendNUIMessage({ type = "UPDATE_VEHICLE_SOUND_DEFAULT" }) end

    resetMainFeed()
    sendCarhudFlags()
    wFramework.sendMoneyToUI()
    wFramework.sendBankToUI()
    wFramework.sendBlackMoneyToUI()
    InitRadar()
end

local function stressPhaseLine(phase)
    return ("%-16s fps %5.1f  frame avg %5.1f p95 %5.1f p99 %5.1f max %6.1f ms  jank>33 %.0f >50 %.0f >100 %.0f  longtask %.0f (%.0f ms)  loaf %.0f (style+layout %.0f ms)  nodes %s  msg/s %.0f"):format(
        phase.name, phase.fps, phase.frameMs.avg, phase.frameMs.p95, phase.frameMs.p99, phase.frameMs.max,
        phase.jank["over33.4"] or 0, phase.jank.over50 or 0, phase.jank.over100 or 0,
        phase.longTasks.count, phase.longTasks.totalMs, phase.longFrames.count, phase.longFrames.styleLayoutMs,
        phase.nodes and ("%.0f>%.0f"):format(phase.nodes.start, phase.nodes["end"]) or "n/a", phase.messagesPerSecond or 0)
end

function startHudStress(seconds, delay, withUi, withProfile, withMap, withIdle, withHeavy)
    if hudStress.active then return end
    hudStress.active, hudStress.stop, hudStress.report = true, false, nil

    CreateThread(function()
        local debugLog = Config.Debug
        Config.Debug = function() end
        local prior = {
            heading = locationFeed.heading,
            aiming = viewFeed.aiming, firstPerson = viewFeed.firstPerson,
            damage = damageFeed.enabled, cinematic = Player.cinematic,
        }
        local memory = { start = collectgarbage("count"), peak = collectgarbage("count") }
        local sent, ticks, gapMax, gapSum = 0, 0, 0, 0
        local now, started, last = GetGameTimer(), 0, 0
        local nextAt, phase, phaseUntil, phaseIndex = {}, nil, 0, 0
        local cash, bank, black, talking = 1250, 48210, 300, 1

        local function push(message)
            if withIdle then return end
            sent = sent + 1
            SendNUIMessage(message)
        end
        local function due(key, every)
            if now < (nextAt[key] or 0) then return false end
            nextAt[key] = now + every
            return true
        end

        Config.Notification("HUD stress", ("Starting in %ss. Start your recording now. Run /hudstress stop to end early."):format(delay), "info", 5000)
        for i = delay, 1, -1 do
            if hudStress.stop then break end
            debugLog(("[wais-primehud] hudstress starts in %ds"):format(i))
            Wait(1000)
        end

        local ok, err = pcall(function()
            if not hudStress.stop then
                if withProfile then ExecuteCommand(("profiler record %d"):format(seconds * 60)) end
                if not withIdle then
                    locationFeed.heading = true
                    viewFeed.aiming, viewFeed.firstPerson = true, true
                    damageFeed.enabled = Config.DamageIndicator.enabled
                end
                now = GetGameTimer()
                started, last = now, now
                debugLog(("[wais-primehud] hudstress running for %ds"):format(seconds))
                SendNUIMessage({ type = "STRESS_START", ms = seconds * 1000, ui = (withUi or withHeavy) and not withIdle, map = withMap and not withIdle, only = withHeavy and { "settings-heavy" } or nil })

                while not hudStress.stop and now - started < seconds * 1000 do
                    Wait(0)
                    now = GetGameTimer()
                    local gap = now - last
                    last = now
                    ticks, gapSum = ticks + 1, gapSum + gap
                    if gap > gapMax then gapMax = gap end

                    local t = (now - started) / 1000
                    local wave = (math.sin(t * 1.3) + 1) * 0.5

                    if now >= phaseUntil then
                        phaseUntil = now + STRESS_PHASE_MS
                        phase = STRESS_PHASES[phaseIndex % #STRESS_PHASES + 1]
                        phaseIndex = phaseIndex + 1
                        local onFoot = phase == "bike"
                        push({ type = "UPDATE_PLAYER_CAR", vehicle = onFoot and 0 or 1 })
                        push({ type = "UPDATE_PLAYER_SEAT", seat = -1 })
                        push({ type = "UPDATE_BICYCLE", state = phase == "bike", kmh = 0 })
                        push({ type = "UPDATE_MOTORCYCLE", state = phase == "moto" })
                    end

                    if due("car", 16) then
                        push({
                            type = "UPDATE_CAR_STATUS", speed = wave * 60.0, fuel = math.floor(10 + (math.sin(t * 0.4) + 1) * 45),
                            rpm = 0.05 + wave * 0.9, gear = 1 + math.floor(wave * 5), maxGear = 6, belt = math.floor(t) % 4 ~= 0,
                            engine = true, lights = math.floor(t) % 2 == 0, health = 300 + math.floor(wave * 700),
                            heading = math.floor(t * 40) % 360, depth = math.floor(4 + wave * 26), watercraft = phase == "boat",
                            aircraft = phase == "plane" or phase == "heli", attitude = math.floor(math.sin(t * 0.5) * 35), altitude = math.floor(20 + wave * 380),
                        })
                        if phase == "plane" or phase == "heli" then
                            push({ type = "UPDATE_AIRCRAFT", heading = math.floor(t * 40) % 360, pitch = math.floor(math.sin(t * 0.4) * 18), gear = math.floor(t) % 4, helicopter = phase == "heli" })
                        end
                        if phase == "bike" then push({ type = "UPDATE_BICYCLE", state = true, kmh = math.floor(wave * 50) }) end
                    end
                    if due("heading", 16) then push({ type = "UPDATE_HEADING", heading = math.floor(t * 90) % 360 }) end
                    if due("status", 50) then push(STRESS_STATUS[math.floor(t / 0.8) % #STRESS_STATUS + 1]) end
                    if due("mic", 120) then
                        talking = talking % #STRESS_VOICE + 1
                        local voice = STRESS_VOICE[talking]
                        push({ type = "SALTY_MIC_MUTED", state = voice.muted == true })
                        push({ type = "UPDATE_MEGAPHONE", state = voice.megaphone == true })
                        push({ type = "UPDATE_MIC", state = voice.mic, radio = voice.radio })
                    end
                    if due("weapon", 400) then
                        local weapon = STRESS_WEAPONS[math.floor(t) % #STRESS_WEAPONS + 1]
                        push({ type = "UPDATE_PLAYER_WEAPON", name = weapon.name, hash = weapon.hash, ammo = weapon.ammo, clip = weapon.clip, hide = false, image = weapon.image })
                    end
                    if due("time", 250) then push({ type = "UPDATE_TIME", time = (math.floor(t / 3) + 18) % 24, minutes = math.floor(t * 5) % 60 }) end
                    if due("street", 700) then
                        local index = math.floor(t) % #STRESS_STREETS + 1
                        push({ type = "UPDATE_COMPASS", compass = directions[math.floor(t) % 8 + 1], title = STRESS_STREETS[index], subtitle = STRESS_STREETS[(index % #STRESS_STREETS) + 1] })
                        push({ type = "UPDATE_POSTAL", postal = 100 + math.floor(t * 7) % 900 })
                    end
                    if due("waypoint", 100) then
                        local step = math.floor(t / 2) % 8
                        push({ type = "UPDATE_WAYPOINT", distance = step == 7 and -1 or math.floor(wave * 1500), height = math.floor((wave - 0.5) * 160), edge = step < 3 and 0 or step - 2, x = math.floor(wave * 1000), y = 500 })
                    end
                    if due("money", 500) then
                        cash, bank, black = cash + math.random(-900, 1200), bank + math.random(-4000, 6000), black + math.random(-200, 300)
                        push({ type = "SET_PLAYER_CASH", cash = cash })
                        push({ type = "SET_PLAYER_BANK", bank = bank })
                        push({ type = "SET_PLAYER_BLACK_MONEY", money = black })
                    end
                    if due("damage", 350) then push({ type = "DAMAGE_HIT", bearing = math.random(0, 359), heading = math.floor(t * 90) % 360 }) end
                    if due("view", 3500) then push({ type = "UPDATE_VIEW", aiming = math.floor(t / 3.5) % 2 == 0, firstPerson = false }) end
                    if due("pause", 7000) then push({ type = "PAUSE_MENU", state = math.floor(t / 7) % 2 == 0 }) end
                    if due("radar", 5000) then push({ type = "HIDE_RADAR", state = math.floor(t / 5) % 2 == 0 }) end
                    if not withIdle and due("initradar", 3000) then InitRadar() end
                    if not GetHudDebugContext().carControl and due("carcontrol", 500) then
                        local open = math.floor(t / 6) % 2 == 0
                        if due("carcontrolopen", 6000) then push({ type = open and "OPEN_CAR_CONTROL" or "CLOSE_CAR_CONTROL" }) end
                        push({
                            type = "UPDATE_CAR_CONTROL",
                            doors = { ["0"] = math.random() > 0.5, ["1"] = math.random() > 0.5, ["2"] = false, ["3"] = false, ["4"] = math.random() > 0.5, ["5"] = false },
                            seats = { ["-1"] = { usable = true, free = false }, ["0"] = { usable = true, free = true }, ["1"] = { usable = true, free = math.random() > 0.5 } },
                            windows = { ["0"] = math.random() > 0.5, ["1"] = true, ["2"] = false, ["3"] = false },
                        })
                    end
                    if Player.vehicle.soundData == nil and due("music", 1000) then
                        push({ type = "UPDATE_VEHICLE_SOUND", data = { id = "hudstress", url = "", title = "A very long stress track title that should be cut by the widget", cover = "", duration = math.floor(t) % 200, maxDuration = 200, play = true, volume = 0.5 } })
                    end
                    if due("memory", 500) then
                        local kb = collectgarbage("count")
                        if kb > memory.peak then memory.peak = kb end
                    end
                    if withMap and due("maskpause", 7000) then
                        CreateThread(function()
                            setMapMaskActive(false)
                            Wait(600)
                            setMapMaskActive(true)
                        end)
                    end
                end

                if withProfile then ExecuteCommand("profiler saveJSON hudstress-lua-profile.json") end
            end
        end)
        if not ok then
            debugLog(("[wais-primehud] hudstress aborted: %s"):format(err))
            SendNUIMessage({ type = "STRESS_STOP" })
        end

        local waited = 0
        while not hudStress.report and waited < 12000 and started > 0 do
            Wait(100)
            waited = waited + 100
        end

        restoreHudStress(prior)
        Config.Debug = debugLog

        local elapsed = math.max(1, now - started) / 1000
        local screenW, screenH = GetActiveScreenResolution()
        local year, month, day, hour, minute, second = GetLocalTime()
        local full = {
            generated = ("%04d-%02d-%02d %02d:%02d:%02d"):format(year, month, day, hour, minute, second),
            options = {
                seconds = seconds, ui = withUi, map = withMap, profile = withProfile, idle = withIdle, heavy = withHeavy,
                performance = Player.customizations.performance, mapType = Player.customizations.mapType,
                mapStyle = Player.customizations.mapStyle, screen = ("%dx%d"):format(screenW, screenH),
            },
            lua = {
                messages = sent, perSecond = math.floor(sent / elapsed), frames = ticks,
                avgFrameMs = ticks > 0 and gapSum / ticks or 0, longestFrameMs = gapMax,
                memoryKb = { start = memory.start, ["end"] = collectgarbage("count"), peak = memory.peak },
            },
            nui = hudStress.report,
        }
        TriggerServerEvent('wais:primehud:server:perfReport', json.encode(full, { indent = true }))
        hudStress.active, hudStress.stop = false, false

        Config.Debug(("[wais-primehud] hudstress finished: %d messages in %.1fs (%.0f/s), %d frames, avg frame %.1f ms, longest frame %d ms, lua memory %.0f > %.0f KB (peak %.0f). HUD state restored."):format(sent, elapsed, sent / elapsed, ticks, ticks > 0 and gapSum / ticks or 0, gapMax, memory.start, collectgarbage("count"), memory.peak))
        if full.nui then
            Config.Debug("[wais-primehud] CEF " .. stressPhaseLine(full.nui.total))
            for _, phase in ipairs(full.nui.phases) do Config.Debug("[wais-primehud]   " .. stressPhaseLine(phase)) end
            Config.Debug(("[wais-primehud] CEF heap %s MB, long-frame worst: %s"):format(
                full.nui.total.heapMb and ("%.1f>%.1f (max %.1f)"):format(full.nui.total.heapMb.start, full.nui.total.heapMb["end"], full.nui.total.heapMb.max) or "n/a",
                full.nui.total.longFrames.worst[1] and ("%.0f ms %s"):format(full.nui.total.longFrames.worst[1].duration, full.nui.total.longFrames.worst[1].scripts[1] and full.nui.total.longFrames.worst[1].scripts[1].source or "") or "none"))
        else
            Config.Debug("[wais-primehud] CEF report did not arrive (NUI did not answer within 12 s).")
        end
        Config.Notification("HUD stress", "Finished. HUD state restored.", "success", 4000)
    end)
end

function drawMapDebug()
    local target = minimapState.target
    if not target then return end

    local x0 = target.x / target.screenW
    local x1 = (target.x + target.w) / target.screenW
    local y1 = 1.0 - target.bottom / target.screenH
    local y0 = y1 - target.h / target.screenH
    local thickX, thickY = 2.0 / target.screenW, 2.0 / target.screenH

    DrawRect((x0 + x1) / 2, y0, x1 - x0, thickY, 0, 255, 0, 255)
    DrawRect((x0 + x1) / 2, y1, x1 - x0, thickY, 0, 255, 0, 255)
    DrawRect(x0, (y0 + y1) / 2, thickX, y1 - y0, 0, 255, 0, 255)
    DrawRect(x1, (y0 + y1) / 2, thickX, y1 - y0, 0, 255, 0, 255)
end

RegisterCommand('mapsafe', function(_, args)
    Config.MinimapSafeZone.position = tonumber(args[1]) or 0
    Config.MinimapSafeZone.size = tonumber(args[2]) or 0
    refreshMinimap()
end, false)

RegisterCommand('mapprobe', function()
    local width, height = GetActiveScreenResolution()
    Config.Debug(("mapprobe: screen=%dx%d safe=%.5f aspect=%.5f"):format(width, height, GetSafeZoneSize(), GetAspectRatio(false)))
    local variants = {
        { 0.0, 0.0, 0.0, 0.0 },
        { 0.0, 0.0, 1.0, 1.0 },
        { 0.0, 0.0, 0.5, 0.5 },
        { 0.2, 0.3, 0.0, 0.0 },
        { 0.2, 0.3, 0.4, 0.4 },
        { 0.0, 0.0, 0.1406, 0.1762 },
    }
    for i = 1, #variants do
        local v = variants[i]
        SetScriptGfxAlign(76, 66)
        SetScriptGfxAlignParams(v[1], v[2], v[3], v[4])
        local ox, oy = GetScriptGfxPosition(0.0, 0.0)
        local ux, uy = GetScriptGfxPosition(1.0, 1.0)
        local hx, hy = GetScriptGfxPosition(0.5, 0.5)
        ResetScriptGfxAlign()
        Config.Debug(("mapprobe: params=%.4f,%.4f,%.4f,%.4f origin=%.6f,%.6f unit=%.6f,%.6f half=%.6f,%.6f"):format(v[1], v[2], v[3], v[4], ox, oy, ux - ox, uy - oy, hx, hy))
    end
end, false)

local function maskCall(name, asBool, ...)
    BeginScaleformMovieMethod(form(), name)
    for i = 1, select("#", ...) do
        local param = select(i, ...)
        if type(param) == "string" then
            ScaleformMovieMethodAddParamPlayerNameString(param)
        elseif math.type(param) == "float" then
            ScaleformMovieMethodAddParamFloat(param)
        elseif type(param) == "number" then
            ScaleformMovieMethodAddParamInt(param)
        elseif param ~= nil then
            ScaleformMovieMethodAddParamBool(param)
        end
    end
    local result = EndScaleformMovieMethodReturnValue()
    local deadline = GetGameTimer() + 1000
    while not IsScaleformMovieMethodReturnValueReady(result) and GetGameTimer() < deadline do Wait(0) end
    if not IsScaleformMovieMethodReturnValueReady(result) then return "donus yok (metod yok ya da gfx eski)" end
    return asBool and tostring(GetScaleformMovieMethodReturnValueBool(result)) or GetScaleformMovieMethodReturnValueString(result)
end

RegisterCommand('maskshape', function(_, args)
    CreateThread(function()
        if not form() then return Config.Debug("maskshape: MinimapForm yok") end
        Config.Debug("maskshape version:", maskCall("GFX_VERSION"))
        Config.Debug("maskshape set:", maskCall("SET_MASK_SHAPE", false, args[1] or Player.customizations.mapType))
        local info, page = "", 0
        repeat
            local chunk = maskCall("GET_MASK_INFO", false, page)
            if chunk:find("^donus yok") then chunk = "" end
            info = info .. chunk
            page = page + 1
        until chunk == "" or page > 100
        Config.Debug("maskshape info:", info)
    end)
end, false)

RegisterCommand('maskbounds', function(_, args)
    CreateThread(function()
        if not form() then return Config.Debug("maskbounds: MinimapForm yok") end
        local x, y, w, h = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
        if x and y and w and h then
            Config.Debug("maskbounds:", maskCall("SET_MASK_BOUNDS", false, x + 0.0, y + 0.0, w + 0.0, h + 0.0))
        else
            Config.Debug("maskbounds:", maskCall("SET_MASK_BOUNDS", false))
        end
    end)
end, false)

RegisterCommand('masktarget', function(_, args)
    CreateThread(function()
        if not form() or not args[1] then return Config.Debug("masktarget: MinimapForm ya da ad yok") end
        Config.Debug("masktarget:", maskCall("SET_MASK_TARGET", false, args[1], args[2] ~= "0"))
    end)
end, false)

RegisterCommand('maskfill', function(_, args)
    CreateThread(function()
        if not form() then return Config.Debug("maskfill: MinimapForm yok") end
        Config.Debug("maskfill:", maskCall("DEBUG_MASK_FILL", true, args[1] ~= "0"))
    end)
end, false)

RegisterCommand('mapstyle', function(_, args)
    CreateThread(function() mapStyleTest(args[1] or "default", args[2]) end)
end, false)

RegisterCommand('hudstress', function(_, args)
    if args[1] == "stop" then
        hudStress.stop = true
        SendNUIMessage({ type = "STRESS_STOP" })
        return
    end

    local seconds, delay, flags = nil, nil, {}
    for _, argument in ipairs(args) do
        local number = tonumber(argument)
        if number and not seconds then seconds = number
        elseif number then delay = number
        else flags[argument] = true end
    end

    startHudStress(math.floor(math.min(math.max(seconds or 60, 5), 600)), math.floor(math.min(math.max(delay or 5, 0), 30)), flags.ui == true, flags.profile == true, flags.map == true, flags.idle == true, flags.heavy == true)
end, false)

RegisterCommand('mapdebug', function()
    minimapState.debug = not minimapState.debug

    if not minimapState.debug then return end

    CreateThread(function()
        while minimapState.debug do
            drawMapDebug()
            Wait(0)
        end
    end)
end, false)
