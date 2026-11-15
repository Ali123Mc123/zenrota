function GetAddictionLevelThreshold(amount)
    local cfg = Settings.Thresholds
    if amount >= cfg.Critical then return cfg.Critical
    elseif amount >= cfg.High then return cfg.High
    elseif amount >= cfg.Medium then return cfg.Medium
    elseif amount >= cfg.Low then return cfg.Low
    else return 0
    end
end

function GetLevelName(amount)
    local cfg = Settings.Thresholds
    if amount >= cfg.Critical then return 'critical'
    elseif amount >= cfg.High then return 'high'
    elseif amount >= cfg.Medium then return 'medium'
    elseif amount >= cfg.Low then return 'low'
    else return 'none'
    end
end

function GetLevelText(amount)
    local level = GetLevelName(amount)
    if level == 'none' then return locale('level_none') end
    return locale('level_' .. level)
end

function GetLevelColor(amount)
    if amount >= 100 then return 'red'
    elseif amount >= 75 then return 'orange'
    elseif amount >= 50 then return 'yellow'
    elseif amount >= 25 then return 'blue'
    else return 'green'
    end
end
