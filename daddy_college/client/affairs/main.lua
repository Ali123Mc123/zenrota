-- Student Affairs on the client: the clerks at the desks, the talk with its camera and the panels in it.
if not Core.ModuleEnabled('affairs') then return end

local cfg = Config.Affairs
local t = DL.locale.t
local VIEW = 'affairs.dialog'
local lastLine = {}

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:affairs:' .. name, false, data))
end

-- A line from the clerk's pool for the key, never the same one twice in a row.
local function line(key)
    local pool = ((DL.locale.table().affairs or {}).lines or {})[key]
    if type(pool) ~= 'table' or #pool == 0 then return '' end
    local pick
    for _ = 1, 5 do
        pick = pool[math.random(#pool)]
        if pick ~= lastLine[key] then break end
    end
    lastLine[key] = pick
    return pick
end

-- A translator may drop a %s; the line is then shown as it is.
local function lineWith(key, ...)
    local text = line(key)
    local done, out = pcall(string.format, text, ...)
    return done and out or text
end

-- Camera ---------------------------------------------------------------------------------------------
-- It looks at the clerk's head; with a panel open it moves aside so the panel has room.

local camera = { cam = nil, ped = nil, mode = nil }

local function frame(ped, mode)
    local c = cfg.Camera
    local side = mode == 'panel' and c.SideOffset or 0.0
    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
    local from = GetOffsetFromEntityInWorldCoords(ped, side, c.Distance, 0.0)
    local at = GetOffsetFromEntityInWorldCoords(ped, side, 0.0, 0.0)
    return vector3(from.x, from.y, head.z + c.ZOffset), vector3(at.x, at.y, head.z)
end

local function newCam(ped, mode)
    local from, at = frame(ped, mode)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamCoord(cam, from.x, from.y, from.z)
    PointCamAtCoord(cam, at.x, at.y, at.z)
    SetCamFov(cam, cfg.Camera.Fov)
    return cam
end

local function focus(ped)
    camera.cam, camera.ped, camera.mode = newCam(ped, 'dialogue'), ped, 'dialogue'
    SetCamActive(camera.cam, true)
    RenderScriptCams(true, true, cfg.Camera.TransitionMs, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
end

-- Slides between the talk and a panel, as long as the view's own move.
local function shift(mode)
    if not camera.cam or camera.mode == mode or not DoesEntityExist(camera.ped) then return end
    local previous, nextCam = camera.cam, newCam(camera.ped, mode)
    SetCamActiveWithInterp(nextCam, previous, cfg.Camera.TransitionMs, 1, 1)
    camera.cam, camera.mode = nextCam, mode
    SetTimeout(cfg.Camera.TransitionMs + 100, function() pcall(function() exports['FeloxAC']:destroyCam(previous) end) --[[FeloxAC:auto]] DestroyCam(previous, false) end)
end

local function release(instant)
    local cam = camera.cam
    camera.cam, camera.ped, camera.mode = nil, nil, nil
    if not cam then return end
    RenderScriptCams(false, not instant, instant and 0 or cfg.Camera.ReleaseMs, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
    if instant then return DestroyCam(cam, false) end
    SetTimeout(cfg.Camera.ReleaseMs + 50, function() pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]] DestroyCam(cam, false) end)
end

Core.Nui.OnClose(VIEW, function() release(false) end)

-- The talk ----------------------------------------------------------------------------------------

local function openDialog(ped)
    if Core.Nui.IsOpen() or not ped or not DoesEntityExist(ped) then return end
    local session = call('open')
    if not session.ok then return Core.HandleResult(session, 'affairs') end
    focus(ped)
    TaskTurnPedToFaceEntity(cache.ped, ped, 1500)
    Core.Nui.Open(VIEW, {
        npcName = t('affairs.npc_name'), greeting = line(session.isStudent and 'greet_student' or 'greet'),
        actions = session.canSelfEnroll and {} or Core.Affairs.Visible(session), canSelfEnroll = session.canSelfEnroll,
        club = session.club, memberClub = session.memberClub, permitStatus = session.permitStatus,
    })
end

-- A clerk stands at every desk.
local function syncDesks()
    local defs = {}
    for _, desk in ipairs(Core.World.entities({ kind = 'affairs_desk' })) do
        local uid = 'affairs:' .. desk.uid
        defs[#defs + 1] = {
            uid = uid, label = desk.label, coords = desk.coords, revision = desk.revision, presentation = 'ped',
            model = (desk.model or '') ~= '' and desk.model or cfg.Model, scenario = (desk.scenario or '') ~= '' and desk.scenario or cfg.Scenario,
            distance = cfg.TalkDistance,
            options = { {
                name = 'affairs_talk', label = t('affairs.target_talk'), icon = 'fa-solid fa-comments', distance = cfg.TalkDistance,
                canInteract = function() return not Core.Nui.IsOpen() and not IsPedInAnyVehicle(cache.ped, false) end,
                onSelect = function() CreateThread(function() openDialog(Core.World.anchors.entity(uid)) end) end,
            } },
        }
    end
    Core.World.anchors.sync('affairs', defs)
end

Core.World.subscribe(syncDesks)

-- The view's calls -------------------------------------------------------------------------------

-- An option that runs elsewhere closes the talk first, so two cameras never stack.
Core.Nui.SafeCallback('affairs:select', function(data)
    local action = Core.Affairs.GetAction(data.id or '')
    if not action or not action.run then return { ok = false, error = 'not_found' } end
    Core.Nui.Close()
    SetTimeout(cfg.Camera.ReleaseMs, function()
        local done, err = pcall(action.run)
        if not done then print(('^1[daddy_college] affairs %s: %s^7'):format(data.id, err)) end
    end)
    return { ok = true }
end)

Core.Nui.SafeCallback('affairs:camMode', function(data)
    shift(data.mode == 'panel' and 'panel' or 'dialogue')
    return { ok = true }
end)

Core.Nui.SafeCallback('affairs:line', function(data)
    return { ok = true, data = { text = line(data.key or 'greet') } }
end)

-- The clerk tells the result; the options change with the new job.
Core.Nui.SafeCallback('affairs:selfEnroll', function()
    local result = call('selfEnroll')
    if not result.ok then return result end
    result.data.npcLine = result.className and lineWith('enroll_ok', result.studentNumber, result.className) or lineWith('enroll_ok_noclass', result.studentNumber)
    result.data.actions = Core.Affairs.Visible({ isStudent = true })
    return result
end, 25000)

for _, name in ipairs({ 'clubRoster', 'clubSearch', 'clubAdd', 'clubRemove', 'clubSetMemberRank', 'clubManageRanks', 'leaveClub' }) do
    Core.Nui.SafeCallback('affairs:' .. name, function(data) return call(name, data) end)
end

-- Panels that show other modules' data.
local PANELS = {
    leaderboard = 'daddy_college:classpoints:houseDesk', -- the house standings and the discipline table
    examResults = 'daddy_college:exam:myGrades',
    permitState = 'daddy_college:security:myPermitRequest',
    permitRequest = 'daddy_college:security:requestPermit',
    permitCancel = 'daddy_college:security:cancelPermitRequest',
}

for name, target in pairs(PANELS) do
    Core.Nui.SafeCallback('affairs:' .. name, function(data)
        return Core.NormalizeResult(lib.callback.await(target, false, data))
    end)
end

-- The student tablet, when the server sells it.
Core.Affairs.RegisterAction('affairs:buyTablet', {
    order = 10, icon = 'fa-solid fa-tablet-screen-button', label = 'affairs.action_buy_tablet',
    visible = function(context) return context.tabletPrice ~= nil end,
    run = function()
        local result = call('buyTablet')
        if result.ok then return end
        if result.error == 'not_enough_money' then return Core.NotifyL('affairs.not_enough_money', 'error', result.price) end
        Core.HandleResult(result, 'affairs')
    end,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then release(true) end
end)
