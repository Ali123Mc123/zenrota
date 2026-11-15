local tgiann_skillbar = GetResourceState("tgiann-skillbar") == "started"

tgiCore.skillCheck = function(time)
    -- ai-core: ai-lib's skill check, tgiann-skillbar's time window as its difficulty
    if config.framework == "aicore" then return AiLib.skillCheck(time < 2000 and "hard" or time < 5000 and "medium" or "easy") end
    if tgiann_skillbar then
        return exports["tgiann-skillbar"]:taskBar(time, true)
    end

    local dif = "easy"
    if time < 2000 then
        dif = "hard"
    elseif time < 5000 then
        dif = "medium"
    end
    return lib.skillCheck({ dif })
end
