-- A character without a role does not get into the city: the role choice, the class ceremony for students, then the
-- spawn of its role. A multichar can run it right after a character is made (exports.daddy_onboarding:Run(opts)); without
-- one, the gate opens on its own once the character has loaded.
local t = DL.locale.t

local running = false
local testing = false -- /torentest: nothing is saved
local quizOwed = false -- the ceremony point shows only while this character still owes it
local waiting -- the promise the NUI resolves

local function send(action, data) SendNUIMessage({ action = action, data = data }) end

local function settle(value)
    if not waiting then return end
    local p = waiting
    waiting = nil
    p:resolve(value)
end

local function await(view, payload)
    waiting = promise.new()
    SendNUIMessage({ action = 'open', view = view, payload = payload, locale = DL.locale.table(), language = DL.locale.language() })
    return Citizen.Await(waiting)
end

-- Frozen and hidden while the forms are up; the campus camera (if any) or a black screen behind them.
local function hold(on)
    local ped = cache.ped
    FreezeEntityPosition(ped, on)
    pcall(function() exports['FeloxAC']:isInvincible(on) end) --[[FeloxAC:auto]]
    SetEntityInvincible(ped, on)
    pcall(function() exports['FeloxAC']:isVisible(not on) end) --[[FeloxAC:auto]]
    SetEntityVisible(ped, not on, false)
    DisplayRadar(not on)
    if on then
        DoScreenFadeOut(400)
        while not IsScreenFadedOut() do Wait(0) end
        local scene = Camera.start() and 'camera' or 'desk'
        if scene == 'camera' then DoScreenFadeIn(800) end
        return scene
    end
    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do Wait(0) end
    Camera.stop()
end

-- Back into the game: moved while the screen is dark, then faded in.
local function release(coords)
    hold(false)
    if coords then
        local ped = cache.ped
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, coords.w or 0.0)
        local timeout = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do Wait(0) end
    end
    DoScreenFadeIn(800)
end

local function close()
    SetNuiFocus(false, false)
    send('close')
end

-- The ceremony's data: the drawn set from the server plus the face for the ID card, taken before the ped hides.
local function ceremony(photo, scene, event)
    local data = lib.callback.await('daddy_onboarding:' .. event, false)
    if type(data) ~= 'table' or not data.questions then return nil end
    data.classes, data.photo, data.scene = Classes, photo, scene
    return await('ceremony', data)
end

-- Returns the role. Returns at once when there is nothing to choose or answer.
-- opts.noSpawn: the player stays where they are (a multichar already placed them).
local function run(opts)
    if running then return nil end
    local state = lib.callback.await('daddy_onboarding:state', false)
    -- The server answers { ok = false } while it is still starting; ask again rather than let the character through.
    for _ = 1, 20 do
        if type(state) ~= 'table' or state.ok ~= false then break end
        Wait(3000)
        state = lib.callback.await('daddy_onboarding:state', false)
    end
    quizOwed = type(state) == 'table' and state.needsQuiz == true
    if type(state) ~= 'table' or (not state.needsRole and not state.needsQuiz) then return type(state) == 'table' and state.role or nil end
    running = true
    local photo = DL.mugshot.capture(cache.ped)
    local scene = hold(true)
    SetNuiFocus(true, true)

    local role, className = state.role, nil
    if state.needsRole then
        role = await('roles', { cards = lib.callback.await('daddy_onboarding:roles', false), scene = scene })
        if not running then return nil end -- the character logged out meanwhile
    end
    if role == 'student' then
        className = ceremony(photo, scene, 'questions')
        if not running then return nil end
        quizOwed = className == nil
    else
        Wait(2200) -- the welcome line on the NUI
    end

    close()
    local noSpawn = type(opts) == 'table' and opts.noSpawn == true
    release(not noSpawn and Config.Spawns[role] or nil)
    running = false
    if role == 'student' and className then
        lib.notify({ description = t('notify.student', className), type = 'success' })
    elseif role then
        lib.notify({ description = t('notify.' .. role), type = 'success' })
    end
    return role
end

exports('Run', run)
exports('IsRunning', function() return running end)

-- /torentest: the same screens and sums; no role, job or class changes and no spawn.
RegisterNetEvent('daddy_onboarding:test', function(screen)
    if running then return end
    running, testing = true, true
    local photo = DL.mugshot.capture(cache.ped)
    local scene = hold(true)
    SetNuiFocus(true, true)
    local role = 'student'
    if screen == 'roles' then
        role = await('roles', { cards = lib.callback.await('daddy_onboarding:roles', false), scene = scene, test = true })
    end
    if running and role == 'student' then
        ceremony(photo, scene, 'testQuestions')
    elseif running then
        Wait(2200)
    end
    if running then
        close()
        release(nil)
    end
    running, testing = false, false
end)

-- NUI ------------------------------------------------------------------------------------------------------

RegisterNUICallback('chooseRole', function(data, cb)
    local role = type(data) == 'table' and data.role or nil
    local result = testing and { ok = Config.Roles[role] ~= nil, role = role }
        or lib.callback.await('daddy_onboarding:choose', false, role)
    cb(result or { ok = false, error = t('errors.generic') })
    if type(result) == 'table' and result.ok then settle(result.role) end
end)

RegisterNUICallback('refreshRoles', function(_, cb)
    cb(lib.callback.await('daddy_onboarding:roles', false) or {})
end)

RegisterNUICallback('submitQuiz', function(data, cb)
    local answers = type(data) == 'table' and type(data.answers) == 'table' and data.answers or {}
    cb(lib.callback.await(testing and 'daddy_onboarding:testSubmit' or 'daddy_onboarding:submit', false, answers) or { ok = false, error = t('errors.generic') })
end)

RegisterNUICallback('finish', function(data, cb)
    cb({ ok = true })
    settle(type(data) == 'table' and data.class or nil)
end)

-- The gate ---------------------------------------------------------------------------------------------------
-- A new character may still be in the apartment or clothing screens; those finish first.

local function calm()
    local quiet, deadline = 0, GetGameTimer() + 15 * 60000
    while quiet < 3 and GetGameTimer() < deadline do
        Wait(500)
        if IsNuiFocused() or not IsScreenFadedIn() or IsPauseMenuActive() then quiet = 0 else quiet = quiet + 1 end
    end
end

-- A multichar that is still placing the character runs us itself (Run with noSpawn).
local function multicharBusy()
    -- Multichar runs on its own now; older installs still register with the lib.
    local res = DL.product.resource('multichar') or (GetResourceState('daddy_multichar') == 'started' and 'daddy_multichar' or nil)
    if not res then return false end
    local ok, active = pcall(function() return exports[res]:IsActive() end)
    return ok and active == true
end

-- Waits out a busy multichar (it runs us itself only for a new character), then asks the server.
local gating = false
local function gate()
    if running or gating then return end
    gating = true
    CreateThread(function()
        local deadline = GetGameTimer() + 15 * 60000
        while multicharBusy() and GetGameTimer() < deadline do Wait(1000) end
        if multicharBusy() then gating = false return end -- still choosing; the next load asks again
        calm()
        gating = false
        if not running then run() end
    end)
end

DL.fw.onLoaded(gate)
RegisterNetEvent('daddy_onboarding:run', gate)

-- The ceremony point at school: a way in when the ceremony did not open on its own.
CreateThread(function()
    local point = Config.QuizPoint
    if type(point) ~= 'table' or not point.Coords then return end
    DL.target.addSphere('quiz', {
        coords = point.Coords, radius = point.Radius or 1.2,
        options = { {
            label = t('target.quiz'), icon = 'fa-solid fa-graduation-cap',
            canInteract = function() return quizOwed and not running end,
            onSelect = function() CreateThread(function() run({ noSpawn = true }) end) end,
        } },
    })
end)

-- The same ceremony at Student Affairs (College), offered only while this character still owes it.
exports('QuizOwed', function() return quizOwed and not running end)

-- Became a student outside the role screen: the ceremony is now owed.
RegisterNetEvent('daddy_onboarding:quizOwed', function()
    quizOwed = true
    lib.notify({ description = t('notify.quiz_owed'), type = 'inform', duration = 10000 })
end)

local function offerQuiz()
    local college = DL.product.resource('college')
    if not college then return end
    pcall(function()
        exports[college]:RegisterAffairsAction('quiz', { text = t('target.quiz'), icon = 'fa-solid fa-graduation-cap', order = 5, event = 'daddy_onboarding:quiz', shown = 'QuizOwed' })
    end)
end

AddEventHandler('daddy_onboarding:quiz', function()
    if quizOwed and not running then CreateThread(function() run({ noSpawn = true }) end) end
end)

-- Starting items (Config.StarterKit): offered at Student Affairs while this character is owed them.
local starterOwed = false
exports('StarterOwed', function() return starterOwed end)

local function askStarter()
    if not (Config.StarterKit and Config.StarterKit.Enabled) then return end
    local state = lib.callback.await('daddy_onboarding:starter:owed', false)
    starterOwed = type(state) == 'table' and state.owed == true
end

local function offerStarter()
    local college = DL.product.resource('college')
    if not college or not (Config.StarterKit and Config.StarterKit.Enabled) then return end
    pcall(function()
        exports[college]:RegisterAffairsAction('starter', { text = t('target.starter'), icon = 'fa-solid fa-box-open', order = 6, event = 'daddy_onboarding:starter', shown = 'StarterOwed' })
    end)
    CreateThread(askStarter)
end

AddEventHandler('daddy_onboarding:starter', function()
    CreateThread(function()
        local result = lib.callback.await('daddy_onboarding:starter:take', false)
        local ok = type(result) == 'table' and result.ok == true
        if ok then starterOwed = false end
        lib.notify({ description = type(result) == 'table' and (result.text or result.error) or t('errors.generic'), type = ok and 'success' or 'error' })
    end)
end)

DL.fw.onLoaded(function() SetTimeout(5000, askStarter) end)
AddEventHandler('daddy_college:rolesChanged', function() SetTimeout(1500, askStarter) end) -- a new school job may be owed the kit

-- Offered again whenever College starts, as it forgets options of other products then.
AddEventHandler('onClientResourceStart', function(resource)
    local college = (GlobalState['daddy_lib:products'] or {}).college
    if resource == college or resource == GetCurrentResourceName() then
        SetTimeout(1500, offerQuiz)
        SetTimeout(1600, offerStarter)
    end
end)

DL.fw.onUnloaded(function()
    quizOwed, starterOwed = false, false
    if not running then return end
    running, testing = false, false
    close()
    Camera.stop()
    settle(nil)
end)

-- A restart while playing checks the gate again.
CreateThread(function()
    if DL.fw.isLoggedIn() then gate() end
end)
