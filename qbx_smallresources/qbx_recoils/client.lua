local recoils = require 'qbx_recoils.config'
local lastShot = 0

local bypassWeapons = {
    [`WEAPON_357SNUB`] = true,
    [`WEAPON_SCORPIONX9`] = true,
    [`WEAPON_SHOTGUN_CHROMIUM`] = true,
}

local function isKokoActive(wep)
    if bypassWeapons[wep] then return false end
    return LocalPlayer.state.kokoActive == true
end

local recoilPitchAdded = 0

local function applyRecoil(wep)
    if isKokoActive(wep) then return end
    if not recoils[wep] or recoils[wep] == 0 then return end

    local recoil = recoils[wep]

    ShakeGameplayCam("HAND_SHAKE", math.min(recoil * 0.05, 0.3))
    SetTimeout(80, function()
        StopGameplayCamShaking(true)
    end)

    local pitchRange = (math.random() * 0.3 + 0.5) * recoil
    local headingRange = (math.random() - 0.5) * (recoil * 1.4)

    recoilPitchAdded = recoilPitchAdded + pitchRange

    local steps = 2
    CreateThread(function()
        for i = 1, steps do
            local p = GetGameplayCamRelativePitch()
            local h = GetGameplayCamRelativeHeading()
            SetGameplayCamRelativePitch(p + (pitchRange / steps), 1.2)
            SetGameplayCamRelativeHeading(h + (headingRange / steps))
            Wait(0)
        end
    end)
end

-- One loop at most, and only while a weapon with a recoil value is in hand. lib.onCache('weapon') fires on every
-- switch; it used to start a new Wait(0) loop each time while the previous one (alive as long as any weapon was
-- held) kept going, so a few switches left several loops running. Melee weapons, the extinguisher and weapons
-- without a recoil entry need no loop at all.
local looping = false

local function hasRecoil(weapon)
    return weapon and recoils[weapon] and recoils[weapon] ~= 0
end

local function recoilLoop()
    if looping then return end
    looping = true
    CreateThread(function()
        local IsPedShooting, IsPedDoingDriveby = IsPedShooting, IsPedDoingDriveby
        while hasRecoil(cache.weapon) or recoilPitchAdded > 0.01 do
            local ped = cache.ped

            if cache.weapon and IsPedShooting(ped) and not IsPedDoingDriveby(ped) then
                local now = GetGameTimer()

                if now - lastShot > 50 then
                    lastShot = now
                    local _, wep = GetCurrentPedWeapon(ped, true)
                    applyRecoil(wep)
                end
            elseif recoilPitchAdded > 0.01 then
                local p = GetGameplayCamRelativePitch()
                local recoveryStep = math.max(recoilPitchAdded * 0.12, 0.05)
                recoveryStep = math.min(recoveryStep, recoilPitchAdded)
                SetGameplayCamRelativePitch(p - recoveryStep, 1.2)
                recoilPitchAdded = recoilPitchAdded - recoveryStep
            else
                recoilPitchAdded = 0
            end
            Wait(0)
        end
        recoilPitchAdded = 0
        looping = false
    end)
end

lib.onCache('weapon', function(weapon)
    if hasRecoil(weapon) then recoilLoop() end
end)
