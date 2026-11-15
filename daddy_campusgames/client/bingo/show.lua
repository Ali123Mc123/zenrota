-- The show around a bingo night on this client: a notepad and a pencil in the hands of everyone whose cards are up (a
-- player state bag only the server sets), a little writing on each mark, the winners' celebration and confetti, the
-- short camera on the winners the server sends to the night's players, and the night's closing list. Nothing here
-- starts by itself: each part answers a message or a state bag from the server.
local cfg = Config.Bingo
local PAD = 'daddy_campusgames:pad'
local HEAD = 31086 -- SKEL_Head

-- Config.Bingo.Show with these defaults, so an older config still runs.
local DEFAULT = {
    Pad = {
        Anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base' },
        Write = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', ms = 1800 },
        Props = {
            { model = 'prop_notepad_01', bone = 18905, pos = vec3(0.1, 0.02, 0.05), rot = vec3(10.0, 0.0, 0.0) },
            { model = 'prop_pencil_01', bone = 58866, pos = vec3(0.11, -0.02, 0.001), rot = vec3(-120.0, 0.0, 0.0) },
        },
        Range = 40.0,
    },
    Near = true,
    Cheers = {
        { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'cheer_a_1st' },
        { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'fist_pump_a_1st' },
        { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'hands_air_b_1st' },
        { dict = 'anim@arena@celeb@podium@no_prop@', clip = 'hands_air_c_1st' },
    },
    CheerMs = 4500,
    Confetti = { asset = 'scr_xs_celebration', name = 'scr_xs_confetti_burst', scale = 1.0, bursts = 2 },
    Cinema = { Enabled = true, ShotSeconds = 3.2, MaxShots = 3, From = 3.4, To = 2.3, Fov = 38.0, Skip = { control = 202, label = 'BACKSPACE' } },
    IntroSeconds = 8,
    Outro = true, OutroSeconds = 12,
}
local function opt(key)
    local own = cfg.Show and cfg.Show[key]
    if own == nil then return DEFAULT[key] end
    return own
end

BingoShow = {}

local function loadAnim(dict) return pcall(lib.requestAnimDict, dict, 1500) end
local function alive(ped) return ped and DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPedInAnyVehicle(ped, false) end

-- Notepads ---------------------------------------------------------------------------------------------------------

local holders = {} -- [server id] = hall: cards up, as the server set it
local drawn = {}   -- [server id] = { ped, props }: the notepads this client attached
local mine = { want = false, busyTill = 0 }
local looping = false

local function unprop(id)
    local d = drawn[id]
    if not d then return end
    for _, entity in ipairs(d.props) do
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end
    drawn[id] = nil
end

-- The notepad and the pencil in a holder's hands (on this client only; every client draws its own).
local function prop(id, ped)
    unprop(id)
    local d, c = { ped = ped, props = {} }, GetEntityCoords(ped)
    for _, p in ipairs(opt('Pad').Props) do
        local hash = joaat(p.model)
        if IsModelInCdimage(hash) and pcall(lib.requestModel, hash, 2000) then
            pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
            local entity = CreateObject(hash, c.x, c.y, c.z - 3.0, false, false, false)
            SetEntityCollision(entity, false, false)
            AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, p.bone), p.pos.x, p.pos.y, p.pos.z, p.rot.x, p.rot.y, p.rot.z, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(hash)
            d.props[#d.props + 1] = entity
        end
    end
    drawn[id] = d
end

local function whole(d)
    for _, entity in ipairs(d.props) do
        if not DoesEntityExist(entity) then return false end
    end
    return true
end

local function stopOwn()
    local pad = opt('Pad')
    StopAnimTask(cache.ped, pad.Anim.dict, pad.Anim.clip, 2.0)
    StopAnimTask(cache.ped, pad.Write.dict, pad.Write.clip, 2.0)
end

-- My own pose while my card is up (the game syncs a ped's animation to everyone).
local function ownPose()
    if GetGameTimer() < mine.busyTill or not alive(cache.ped) then return end
    local a = opt('Pad').Anim
    if not IsEntityPlayingAnim(cache.ped, a.dict, a.clip, 3) and loadAnim(a.dict) then
        TaskPlayAnim(cache.ped, a.dict, a.clip, 3.0, 3.0, -1, 49, 0.0, false, false, false)
    end
end

-- Twice a second while anyone holds a card up: the notepads near me follow their peds, mine follows my pose.
local function loop()
    if looping then return end
    looping = true
    CreateThread(function()
        while next(holders) or next(drawn) do
            local me, range = GetEntityCoords(cache.ped), opt('Pad').Range
            for id in pairs(drawn) do
                if not holders[id] then unprop(id) end
            end
            for id in pairs(holders) do
                local ped = Games.pedOf(id)
                if not alive(ped) or #(GetEntityCoords(ped) - me) > range then
                    unprop(id)
                elseif not drawn[id] or drawn[id].ped ~= ped or not whole(drawn[id]) then
                    prop(id, ped)
                end
            end
            if holders[cache.serverId] then ownPose() end
            Wait(500)
        end
        looping = false
    end)
end

local function hold(id, hall)
    if holders[id] == hall then return end
    holders[id] = hall
    if id == cache.serverId and not hall then stopOwn() end
    loop()
end

AddStateBagChangeHandler(PAD, nil, function(bag, _, value)
    local player = GetPlayerFromStateBagName(bag)
    if not player or player == 0 then return end
    hold(GetPlayerServerId(player), type(value) == 'string' and value or nil)
end)

-- Players who come into range with their card already up (the handler only hears changes).
CreateThread(function()
    while true do
        local inside = BingoHall and BingoHall.inside()
        local seen = {}
        if inside then
            for _, player in ipairs(GetActivePlayers()) do
                local id = GetPlayerServerId(player)
                local value = Player(id).state[PAD]
                seen[id] = true
                hold(id, type(value) == 'string' and value or nil)
            end
        end
        -- gone or out of range: no notepad left for them
        for id in pairs(holders) do
            if not seen[id] and (inside or id ~= cache.serverId) then hold(id, nil) end
        end
        Wait(inside and 1500 or 3000)
    end
end)

-- The cards up or away: the server sets the state bag (it checks the hall and the cards).
function BingoShow.cards(on, hall)
    on = on == true and alive(cache.ped)
    if mine.want == on then return end
    mine.want = on
    CreateThread(function()
        local result = Games.call('bingo:pad', { hall = hall, on = on })
        if on and not (result and result.ok) and mine.want then mine.want = false end
    end)
end

-- A mark on the card: a short stroke of the pencil.
function BingoShow.write()
    local w = opt('Pad').Write
    if not holders[cache.serverId] or GetGameTimer() < mine.busyTill or not alive(cache.ped) or not loadAnim(w.dict) then return end
    mine.busyTill = GetGameTimer() + w.ms
    TaskPlayAnim(cache.ped, w.dict, w.clip, 3.0, 3.0, w.ms, 49, 0.0, false, false, false)
end

-- Winners -------------------------------------------------------------------------------------------------------------

-- Confetti over a winner near me (every client in the hall plays its own).
local function confetti(id)
    local ped = Games.pedOf(id)
    if not ped or not DoesEntityExist(ped) or #(GetEntityCoords(ped) - GetEntityCoords(cache.ped)) > 60.0 then return end
    local c = opt('Confetti')
    CreateThread(function()
        if not pcall(lib.requestNamedPtfxAsset, c.asset, 2000) then return end
        for _ = 1, c.bursts or 1 do
            if not DoesEntityExist(ped) then return end
            local p = GetEntityCoords(ped)
            UseParticleFxAsset(c.asset)
            StartParticleFxNonLoopedAtCoord(c.name, p.x, p.y, p.z + 1.2, 0.0, 0.0, 0.0, c.scale or 1.0, false, false, false)
            Wait(700)
        end
    end)
end

-- My own celebration, the one the server picked.
local function cheer(index)
    local list = opt('Cheers')
    local a = list[index or 1] or list[1]
    if not a or not alive(cache.ped) or not loadAnim(a.dict) then return end
    local ms = opt('CheerMs')
    mine.busyTill = GetGameTimer() + ms
    stopOwn()
    TaskPlayAnim(cache.ped, a.dict, a.clip, 4.0, 4.0, ms, 0, 0.0, false, false, false)
end

-- A prize won: winners in the hall celebrate, confetti goes up over each. here: I stand in that hall.
function BingoShow.won(winners, here)
    local bursts = 0
    for _, w in ipairs(winners or {}) do
        if w.id then
            if w.id == cache.serverId and here then
                if BingoHall then BingoHall.away() end
                cheer(w.cheer)
            end
            -- a big tie: confetti over the first few only
            if bursts < 6 then
                bursts = bursts + 1
                confetti(w.id)
            end
        end
    end
end

-- The camera on the winners --------------------------------------------------------------------------------------------

local scene, queue = nil, {} -- scene: what the overlay shows now; queue: scenes waiting their turn
local cams, faded = {}, false

local function norm(v)
    local l = #v
    return l > 0.001 and v / l or v
end

local function open(from, to)
    local probe = StartExpensiveSynchronousShapeTestLosProbe(from.x, from.y, from.z, to.x, to.y, to.z, 1 + 16, 0, 4)
    local _, hit = GetShapeTestResult(probe)
    return hit ~= 1 and hit ~= true
end

-- Where the camera starts and ends for a ped: in front and a little to one side, the first side with a clear view.
local function framing(ped, c)
    local head = GetPedBoneCoords(ped, HEAD, 0.0, 0.0, 0.0)
    local f = GetEntityForwardVector(ped)
    local right = vector3(f.y, -f.x, 0.0)
    for _, side in ipairs({ 0.45, -0.45, 0.0, 0.9, -0.9 }) do
        local dir = norm(f + right * side)
        local from = head + dir * c.From + vector3(0.0, 0.0, 0.12)
        if open(head + dir * 0.4, from) then return from, head + dir * c.To + vector3(0.0, 0.0, 0.05), head end
    end
    return head + f * 1.5 + vector3(0.0, 0.0, 0.1), head + f * 1.2 + vector3(0.0, 0.0, 0.05), head
end

local function camAt(pos, ped, fov)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, fov, false, 2)
    PointCamAtPedBone(cam, ped, HEAD, 0.0, 0.0, -0.06, true)
    cams[#cams + 1] = cam
    return cam
end

local function watchable() return not IsEntityDead(cache.ped) and not Nui.isOpen() and not IsPauseMenuActive() end

-- One frame of the scene: the game keeps only push-to-talk; the skip key ends it.
local function frame(skip)
    HideHudAndRadarThisFrame()
    DisableAllControlActions(0)
    EnableControlAction(0, 249, true)
    return IsDisabledControlJustPressed(0, skip)
end

-- Holds the scene for ms. -> false once skipped or no longer watchable
local function stay(ms, skip)
    local till = GetGameTimer() + ms
    while GetGameTimer() < till do
        if frame(skip) or not watchable() then return false end
        Wait(0)
    end
    return true
end

local function fade(out)
    if out then
        DoScreenFadeOut(350)
        faded = true
    else
        DoScreenFadeIn(350)
        faded = false
    end
end

-- Back to the game camera, slowly, and nothing of the scene left.
local function finish(ease)
    RenderScriptCams(false, ease > 0, ease, true, false)
    if faded then fade(false) end
    local old = cams
    cams = {}
    SetTimeout(ease + 100, function()
        for _, cam in ipairs(old) do
            if DoesCamExist(cam) then DestroyCam(cam, false) end
        end
    end)
end

local function play(args)
    local c = opt('Cinema')
    local skip = c.Skip and c.Skip.control or 202
    local ms = math.floor((tonumber(args.seconds) or c.ShotSeconds) * 1000)
    local live, current, last, went = false, nil, nil, true
    local shots = type(args.shots) == 'table' and args.shots or {}
    if BingoHall then BingoHall.away() end
    for i, shot in ipairs(shots) do
        local ped = Games.pedOf(shot.id)
        if not went or not watchable() then break end
        if ped and DoesEntityExist(ped) then
            local from, to, head = framing(ped, c)
            scene = { name = shot.name, amount = shot.amount or 0, goal = args.goal, gameNo = args.gameNo, total = args.total,
                more = i == #shots and (args.more or 0) or 0, skip = c.Skip and c.Skip.label or '', n = i }
            if BingoHall then BingoHall.show(true) end
            local close = camAt(to, ped, c.Fov - 3.0)
            if not live then
                local wide = camAt(from, ped, c.Fov)
                SetCamActive(wide, true)
                RenderScriptCams(true, true, 900, true, false)
                SetCamActiveWithInterp(close, wide, ms, 1, 1)
                live = true
            elseif last and #(head - last) > 8.0 then
                -- far apart: a soft dip to black rather than a long pan across the hall
                fade(true)
                went = stay(400, skip)
                local wide = camAt(from, ped, c.Fov)
                SetCamActive(wide, true)
                SetCamActiveWithInterp(close, wide, ms, 1, 1)
                fade(false)
            else
                SetCamActiveWithInterp(close, current, ms + 400, 1, 1)
            end
            current, last = close, head
            went = went and stay(ms, skip)
        end
    end
    scene = nil
    if live then finish(went and 1000 or 700) end
    if BingoHall then BingoHall.show(true) end
end

-- The server's scene for the night's players: one shot per winner, in turn.
function BingoShow.scene(args)
    if type(args) ~= 'table' then return end
    queue[#queue + 1] = args
    if #queue > 1 then return end
    CreateThread(function()
        while queue[1] do
            if watchable() then
                local ok, err = pcall(play, queue[1])
                if not ok then
                    print(('^1[daddy_campusgames] bingo scene: %s^7'):format(err))
                    scene = nil
                    if #cams > 0 then finish(0) end
                    if BingoHall then BingoHall.show(true) end
                end
            end
            table.remove(queue, 1)
        end
    end)
end

function BingoShow.watching() return scene ~= nil end

-- The night's closing list ------------------------------------------------------------------------------------------

local outro

function BingoShow.outro(summary)
    if type(summary) ~= 'table' or not opt('Outro') then return end
    local seconds = opt('OutroSeconds')
    outro = { data = summary, till = GetGameTimer() + seconds * 1000 }
    if BingoHall then BingoHall.show(true) end
    SetTimeout(seconds * 1000 + 100, function()
        if outro and GetGameTimer() >= outro.till then
            outro = nil
            if BingoHall then BingoHall.show(true) end
        end
    end)
end

function BingoShow.outroView() return outro and GetGameTimer() < outro.till and outro.data or nil end

-- What the card overlay adds: the scene's name strip and the settings it reads.
function BingoShow.view() return scene end
function BingoShow.near() return opt('Near') ~= false end
function BingoShow.introMs() return (opt('IntroSeconds') or 0) * 1000 end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for id in pairs(drawn) do unprop(id) end
    if holders[cache.serverId] then stopOwn() end
    if #cams > 0 then
        RenderScriptCams(false, false, 0, true, false)
        for _, cam in ipairs(cams) do
            if DoesCamExist(cam) then DestroyCam(cam, false) end
        end
    end
    if faded then DoScreenFadeIn(0) end
end)
