-- Handling layers: base, tuning parts, wear.

Tuning = {}

Tuning.fields = {
    'fInitialDriveForce', 'fInitialDriveMaxFlatVel', 'fDriveBiasFront', 'fTractionCurveMax', 'fTractionCurveMin',
    'fTractionLossMult', 'fLowSpeedTractionLossMult', 'fBrakeForce', 'fClutchChangeRateScaleUpShift',
    'fClutchChangeRateScaleDownShift', 'fSteeringLock', 'fSuspensionForce',
}

function Tuning.compute(base, picks, parts, wear)
    local out = {}
    for _, field in ipairs(Tuning.fields) do out[field] = base[field] end
    for group, id in pairs(picks or {}) do
        local part = parts[group] and parts[group][id]
        if part then
            for field, v in pairs(part.set or {}) do out[field] = v end
            for field, v in pairs(part.add or {}) do out[field] = (out[field] or 0) + v end
            for field, v in pairs(part.mult or {}) do out[field] = (out[field] or 0) * v end
        end
    end
    wear = wear or {}
    local function scale(health) return 0.7 + 0.3 * math.min(math.max(health or 1, 0), 1) end
    if out.fTractionCurveMax then out.fTractionCurveMax = out.fTractionCurveMax * scale(wear.tyres) end
    if out.fTractionCurveMin then out.fTractionCurveMin = out.fTractionCurveMin * scale(wear.tyres) end
    if out.fBrakeForce then out.fBrakeForce = out.fBrakeForce * scale(wear.brakes) end
    if out.fClutchChangeRateScaleUpShift then out.fClutchChangeRateScaleUpShift = out.fClutchChangeRateScaleUpShift * scale(wear.clutch) end
    if out.fInitialDriveForce then out.fInitialDriveForce = out.fInitialDriveForce * scale(wear.engine) end
    for field, v in pairs(out) do out[field] = math.max(v, 0.0) end
    return out
end

function Tuning.allowed(part, model, electric, hash)
    hash = hash or joaat
    for _, name in ipairs(part.deny or {}) do
        if hash(name) == model then return false end
    end
    if part.combustion then
        for _, name in ipairs(electric or {}) do
            if hash(name) == model then return false end
        end
    end
    return true
end

function Tuning.sound(picks, parts)
    local id = picks and picks.engine
    local part = id and parts.engine and parts.engine[id]
    return part and part.sound or nil
end
