EmsMechanism = {}

function EmsMechanism.Phase(state, time)
    if not state then return 0 end
    local duration = state.durationMs or 0
    if duration <= 0 then return state.targetPhase end
    local progress = math.max(0, math.min(1, (time - state.startedAt) / duration))
    return state.fromPhase + (state.targetPhase - state.fromPhase) * progress
end

function EmsMechanism.Transition(previous, mode, time, duration)
    local target = mode == 'carried' and 1 or 0
    if previous and previous.targetPhase == target then return previous end
    local phase = previous and EmsMechanism.Phase(previous, time) or target
    return {
        id = previous and previous.id + 1 or 1,
        fromPhase = phase,
        targetPhase = target,
        startedAt = time,
        durationMs = math.abs(target - phase) * duration,
    }
end
