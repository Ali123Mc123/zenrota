-- The phone in the hand: one state, one mode drawn from it and one way between modes. Opening, calls, the camera and
-- turning sideways only change the state (Pose.set); this file plays the clips and keeps the prop.
Pose = {}
local RESOURCE = GetCurrentResourceName()

local S = { open = false, call = false, ear = false, camera = false, selfie = false, landscape = false }

-- The prop is the case colour the player chose (Settings > Display: stream/daddy_phone_<colour>), kept on this machine.
local frame = GetResourceKvpString('frame')
local warned
local function propModel()
    local name = Config.Prop.ByFrame and Config.Prop.ByFrame .. (frame or 'silver')
    if name and IsModelInCdimage(joaat(name)) then return joaat(name) end
    if name and not warned then
        warned = true
        print(('[%s] %s is not in the game, the phone in the hand is %s'):format(RESOURCE, name, Config.Prop.Model))
    end
    return joaat(Config.Prop.Model)
end

-- A clip's length (0: the dictionary lacks it), asked once each with the dictionary loaded.
local lengths = {}
local function lengthOf(dict, clip)
    local key = dict .. '/' .. clip
    if not lengths[key] then lengths[key] = GetAnimDuration(dict, clip) end
    return lengths[key]
end
local function has(dict, clip) return lengthOf(dict, clip) > 0.0 end
local function load(dict) return pcall(lib.requestAnimDict, dict, 2000) end

-- The modes. The phone is always in the right hand; landscape is reading turned on its side.
local CLIPS = {
    read = 'cellphone_text_read_base',
    call = 'cellphone_call_listen_base',
    back = 'cellphone_photo_idle',
    selfie = 'selfie',
}
-- The clip between two modes ('from>to'), played once before the mode's own loop.
local VIA = {
    ['hidden>read'] = 'cellphone_text_in',
    ['hidden>call'] = 'cellphone_call_in',
    ['read>call'] = 'cellphone_text_to_call',
    ['call>read'] = 'cellphone_call_to_text',
}
local OUT = { call = 'cellphone_call_out' } -- the rest lower with cellphone_text_out

-- The dictionary for a clip: in a car the car's set; a woman's own set where it has the clip, else the man's.
local function dictFor(clip)
    local ped = PlayerPedId()
    if clip == CLIPS.selfie then return 'cellphone@self' end
    if IsPedInAnyVehicle(ped, false) then return 'anim@cellphone@in_car@ps' end
    if not IsPedMale(ped) and load('cellphone@female') and has('cellphone@female', clip) then return 'cellphone@female' end
    return 'cellphone@'
end

-- The mode the state asks for. The camera holds the phone up only on foot.
local function derive()
    if S.open then
        if S.camera and not IsPedInAnyVehicle(PlayerPedId(), false) then return S.selfie and 'selfie' or 'back' end
        return (S.call and S.ear) and 'call' or 'read'
    end
    return (S.call and Config.Calls.EarWhenClosed) and 'call' or 'hidden'
end

local mode, rev, settled = 'hidden', 0, 0 -- the mode, its revision, the revision whose clip is playing
local cur = { dict = '', clip = '' }
local prop

local function rot() return (mode == 'read' and S.landscape) and 90.0 or 0.0 end

local function attach()
    local ped = PlayerPedId()
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, Config.Prop.Bone), 0.0, 0.0, 0.0, 0.0, rot(), 0.0, true, true, false, true, 1, true)
end

local function makeProp()
    if prop and DoesEntityExist(prop) then return end
    local model = propModel()
    if not pcall(lib.requestModel, model, 2000) or mode == 'hidden' or (prop and DoesEntityExist(prop)) then return end
    local c = GetEntityCoords(PlayerPedId())
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    prop = CreateObject(model, c.x, c.y, c.z, true, true, false)
    attach()
    SetModelAsNoLongerNeeded(model)
end

local function dropProp()
    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    prop = nil
end

local function playing(dict, clip, flag, blend)
    TaskPlayAnim(PlayerPedId(), dict, clip, blend, -blend, -1, flag, 0, false, false, false)
    cur.dict, cur.clip = dict, clip
end

-- Into a mode: its way in (when the table has one), then its loop. A newer revision ends what this one still had to do.
local function enter(from, to, mine)
    local clip = CLIPS[to]
    local dict = dictFor(clip)
    if not load(dict) or rev ~= mine then return end
    if not has(dict, clip) then clip, dict = CLIPS.read, dictFor(CLIPS.read) end
    if not load(dict) or rev ~= mine then return end
    makeProp()
    if prop then attach() end
    local via = VIA[from .. '>' .. to]
    if via and has(dict, via) then
        playing(dict, via, 50, 4.0)
        Wait(math.max(0, math.floor(lengthOf(dict, via) * 1000) - 150))
        if rev ~= mine then return end
        playing(dict, clip, 49, 2.0)
    else
        playing(dict, clip, 49, 4.0)
    end
    settled = mine
end

-- Back in the pocket: the hand lowers it and the phone goes partway down, not before.
local function lower(from, mine)
    local out = OUT[from] or 'cellphone_text_out'
    local dict = (cur.dict ~= '' and cur.dict ~= 'cellphone@self') and cur.dict or dictFor(out)
    if not (HasAnimDictLoaded(dict) and has(dict, out)) then dict = 'cellphone@' end
    local was = cur
    cur = { dict = '', clip = '' }
    if not (load(dict) and has(dict, out)) then
        dropProp()
        if was.clip ~= '' then StopAnimTask(PlayerPedId(), was.dict, was.clip, 2.0) end
        return
    end
    if rev ~= mine then return end
    playing(dict, out, 50, 4.0)
    cur = { dict = '', clip = '' }
    local ms = math.floor(lengthOf(dict, out) * 1000)
    Wait(math.floor(ms * 0.55))
    if rev ~= mine then return end
    dropProp()
    Wait(ms - math.floor(ms * 0.55))
    if rev ~= mine then return end
    StopAnimTask(PlayerPedId(), dict, out, 2.0)
    settled = mine
end

local watching = false
local watch

-- Moves to the mode the state asks for; the same mode only turns the phone in the hand.
local function apply(force)
    local want = derive()
    if want == mode and not force then
        if prop and DoesEntityExist(prop) then attach() end
        return
    end
    local from = force and 'hidden' or mode
    mode, rev = want, rev + 1
    local mine = rev
    CreateThread(function()
        if want == 'hidden' then lower(from, mine) else enter(from, want, mine) end
    end)
    if want ~= 'hidden' and not watching then watch() end
end

-- While the phone is in a hand: a car door, a fall or another task took the hands, or the prop went, and it comes back;
-- getting into a car turns the camera hold back into reading. Dying ends a call with the phone away (Config.Calls.EndOnDeath).
function watch()
    watching = true
    CreateThread(function()
        while mode ~= 'hidden' do
            Wait(500)
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
                if not S.open and S.call and Config.Calls.EndOnDeath then TriggerEvent(RESOURCE .. ':callDied') end
            elseif mode ~= 'hidden' and settled == rev and not IsPedRagdoll(ped) and not IsPedGettingIntoAVehicle(ped) and not GetIsTaskActive(ped, 2) then
                if derive() ~= mode then
                    apply()
                elseif cur.dict ~= dictFor(cur.clip) or not IsEntityPlayingAnim(ped, cur.dict, cur.clip, 3) then
                    apply(true)
                elseif not prop or not DoesEntityExist(prop) then
                    makeProp()
                elseif not IsEntityAttachedToEntity(prop, ped) then
                    attach()
                end
            end
        end
        watching = false
    end)
end

-- Changes the state: Pose.set('call', true) or Pose.set({ camera = true, selfie = false }).
function Pose.set(key, value)
    if type(key) == 'table' then
        for k, v in pairs(key) do S[k] = v end
    else
        S[key] = value
    end
    if not S.call then S.ear = false end
    apply()
end

function Pose.get(key) return S[key] end
function Pose.mode() return mode end
function Pose.prop() return prop end

-- A new case colour: a phone in the hand becomes the new one.
function Pose.frame(value)
    if type(value) ~= 'string' or not value:match('^%l+$') or value == frame then return end
    frame = value
    SetResourceKvp('frame', value)
    if prop and DoesEntityExist(prop) then
        dropProp()
        makeProp()
    end
end

-- The one clean-up: no clip, no prop, nothing waiting. Phone props left on the player (a stuck one) go too.
function Pose.clear()
    rev, mode, settled = rev + 1, 'hidden', rev + 1
    local ped = PlayerPedId()
    if cur.clip ~= '' then StopAnimTask(ped, cur.dict, cur.clip, 2.0) end
    cur = { dict = '', clip = '' }
    dropProp()
    local models = { [propModel()] = true, [joaat(Config.Prop.Model)] = true }
    for _, obj in ipairs(GetGamePool('CObject')) do
        if models[GetEntityModel(obj)] and IsEntityAttachedToEntity(obj, ped) then DeleteEntity(obj) end
    end
    ClearPedSecondaryTask(ped)
    TaskClearLookAt(ped)
end

-- The player's way out of a phone stuck in the hand or a frozen pose: the phone goes away and the hands are freed.
if Config.Fix and Config.Fix.Command ~= '' then
    RegisterCommand(Config.Fix.Command, function()
        if PhoneUI and PhoneUI.open then PhoneUI.close() end
        if Camera and Camera.on then Camera.stop(true) end
        S.open, S.camera, S.ear, S.landscape = false, false, false, false
        Pose.clear()
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
        lib.notify({ description = DL.locale.t('notify.phone_fixed'), type = 'success' })
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. Config.Fix.Command, DL.locale.t('command.fix'))
end

AddEventHandler('onResourceStop', function(resource)
    if resource == RESOURCE then dropProp() end
end)
