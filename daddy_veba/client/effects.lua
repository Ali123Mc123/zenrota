-- What the sick player feels: pale and coughing at stage 2, dizzy and limping at stage 3. The tint uses the extra
-- timecycle layer, so filters and weather of other scripts neither hide it nor get wiped by it. Stage 0 undoes all.
Effects = {}

local fx = Config.Effects
local stage, tinted, walking, loopOn = 0, false, false, false
local ownWalk -- the walk style the player chose in the emote menu, given back when the limp ends

local function canAnimate(ped)
    local st = LocalPlayer.state
    return not (IsPedInAnyVehicle(ped, true) or IsPedRagdoll(ped) or IsPedFalling(ped) or IsPedSwimming(ped)
        or IsEntityDead(ped) or IsPedCuffed(ped) or st.isDead or st.dead or st.invBusy or st.isCuffed)
end

local function tint(look)
    if look then
        SetExtraTimecycleModifier(look.name)
        SetExtraTimecycleModifierStrength(look.strength)
        tinted = true
    elseif tinted then
        ClearExtraTimecycleModifier()
        tinted = false
    end
end

if fx.WalkStyle then
    RegisterNetEvent(fx.WalkStyle.changed, function(style) ownWalk = style end)
end

local function walk(on)
    local ped = PlayerPedId()
    if on then
        local set = IsPedMale(ped) and fx.Walk.m or fx.Walk.f
        if lib.requestAnimSet(set, 5000) then SetPedMovementClipset(ped, set, 1.0) end
        walking = true
    elseif walking then
        walking = false
        ResetPedMovementClipset(ped, 1.0)
        if fx.WalkStyle and ownWalk then TriggerEvent(fx.WalkStyle.set, ownWalk) end
    end
end

local function stopShake()
    if IsGameplayCamShaking() then StopGameplayCamShaking(true) end
end

-- Stage 3: no sprint or jump each frame, the limp kept on (a revive gives a new ped), a dizzy spell now and then.
local function heavyLoop()
    if loopOn then return end
    loopOn = true
    CreateThread(function()
        local nextWalk, nextSpell, spellEnds = 0, GetGameTimer() + fx.Spell.every * 1000, nil
        while stage == 3 do
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            local now = GetGameTimer()
            if now > nextWalk then
                nextWalk = now + 10000
                walk(true)
            end
            if now > nextSpell then
                nextSpell = now + fx.Spell.every * 1000
                spellEnds = now + fx.Spell.seconds * 1000
                ShakeGameplayCam(fx.Spell.name, fx.Spell.amount)
            elseif spellEnds and now > spellEnds then
                spellEnds = nil
                StopGameplayCamShaking(false)
            end
            Wait(0)
        end
        loopOn = false
    end)
end

function Effects.stage() return stage end

function Effects.set(value)
    stage = tonumber(value) or 0
    tint(stage == 2 and fx.Pale or stage == 3 and fx.Dizzy or nil)
    if stage == 3 then return heavyLoop() end
    walk(false)
    stopShake()
    if stage == 0 then
        local ped = PlayerPedId()
        if IsEntityPlayingAnim(ped, fx.Cough.dict, fx.Cough.clip, 3) then StopAnimTask(ped, fx.Cough.dict, fx.Cough.clip, 2.0) end
    end
end

-- A cough sound: full for the one coughing, fading out with distance for the players around.
local function sound(volume)
    SendNUIMessage({ action = 'cough', file = fx.Cough.Sounds[math.random(#fx.Cough.Sounds)], volume = volume })
end

function Effects.cough()
    local ped = PlayerPedId()
    if stage < 2 then return end
    sound(fx.Cough.Volume)
    ShakeGameplayCam('JOLT_SHAKE', 0.2)
    if not canAnimate(ped) or not lib.requestAnimDict(fx.Cough.dict, 3000) then return end
    TaskPlayAnim(ped, fx.Cough.dict, fx.Cough.clip, 4.0, -4.0, fx.Cough.ms, 48, 0, false, false, false) -- upper body, on top of an emote
    RemoveAnimDict(fx.Cough.dict)
end

function Effects.heard(serverId)
    local player = GetPlayerFromServerId(serverId)
    if player == -1 then return end
    local d = #(GetEntityCoords(GetPlayerPed(player)) - GetEntityCoords(PlayerPedId()))
    if d < fx.Cough.Hear then sound(fx.Cough.Volume * (1.0 - d / fx.Cough.Hear)) end
end

function Effects.bitten()
    ShakeGameplayCam(fx.Bite.name, fx.Bite.amount)
end

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then Effects.set(0) end
end)
