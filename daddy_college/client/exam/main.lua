-- Exams on the client: the teacher's panel, writing a paper with a notepad in hand, and own results.
-- The client never sees the answer key; the timer here is only for show.
if not Core.ModuleEnabled('exam') then return end

local cfg = Config.Exam
local look = cfg.Presentation
local t = DL.locale.t
local active
local Exams = {}
Core.Exams = Exams

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:exam:' .. name, false, data))
end

-- Opens a view with a server answer; errors become notices.
local function open(view, name, data, opts)
    local result = lib.callback.await('daddy_college:exam:' .. name, false, data)
    if not result or result.ok == false then return Core.HandleResult(Core.NormalizeResult(result), 'exam') end
    Core.Nui.Open(view, result, opts)
    return result
end

function Exams.openPanel() if Core.OpenTablet then Core.OpenTablet('exam') end end

-- Panel calls go straight through; the server checks each one. Reads stay quiet, changes say why they failed.
local QUIET = { 'getExamQuestions', 'getQuestions', 'getQuestion', 'getSubmission', 'getManualGradingQueue', 'getResults', 'getSessions',
    'getSessionRoster', 'getAllResults', 'approveSubmission', 'collectPaper', 'voidSubmission', 'deleteQuestion' }
local LOUD = { 'saveExam', 'deleteExam', 'saveQuestion', 'gradeManualBatch', 'grade', 'createSession', 'startSession', 'endSession',
    'approveSession', 'print', 'distribute', 'void' }

for _, name in ipairs(QUIET) do
    Core.Nui.SafeCallback('exam:' .. name, function(data) return call(name, data) end)
end
for _, name in ipairs(LOUD) do
    Core.Nui.SafeCallback('exam:' .. name, function(data)
        local result = call(name, data)
        if not result.ok then Core.HandleResult(result, 'exam') end
        return result
    end)
end
Core.Nui.SafeCallback('exam:getPanel', function() return call('getPanel') end)

-- Writing a paper ------------------------------------------------------------------------------------

local function blocked()
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) then return 'exam.presentation_vehicle' end
    if IsEntityDead(ped) or IsPedFatallyInjured(ped) then return 'exam.presentation_dead' end
    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) then return 'exam.presentation_swim' end
    if IsPedRagdoll(ped) or IsPedFalling(ped) then return 'exam.presentation_unstable' end
end

local function startExam(paperId)
    local reason = blocked()
    if reason then return Core.NotifyL(reason, 'error') end
    local result = lib.callback.await('daddy_college:exam:start', false, { paperId = paperId })
    if not result or result.ok == false then return Core.HandleResult(Core.NormalizeResult(result), 'exam') end
    active = result.submissionId
    result.presentation = look.Nui or {}
    local left = math.floor(result.remaining)
    if result.resumed then
        Core.NotifyL('exam.resumed', 'inform', ('%02d:%02d'):format(left // 60, left % 60))
    else
        Core.NotifyL('exam.started', 'inform', left // 60)
    end
    Core.Hold(look)
    -- Escape does not close a paper; handing in and leaving happen in the view.
    Core.Nui.Open('exam.solve', result, { failsafe = false })
end

RegisterNetEvent('daddy_college:exam:usePaper', function(paperId)
    CreateThread(function()
        if not paperId then return Core.NotifyL('exam.paper_invalid', 'error') end
        startExam(paperId)
    end)
end)

-- Time is up or the teacher ended it: the answers lock and the paper closes.
RegisterNetEvent('daddy_college:exam:sessionEnded', function()
    if not active then return end
    active = nil
    Core.Nui.Send('exam:locked', {})
    SetTimeout(1200, Core.Nui.Close)
end)

-- A teacher reads a paper they collected.
RegisterNetEvent('daddy_college:exam:readPaper', function(paperId)
    CreateThread(function() open('exam.read', 'readPaper', { paperId = paperId }) end)
end)

Core.Nui.SafeCallback('exam:autosave', function(data)
    return call('autosave', { submissionId = active, answers = data.answers })
end)

Core.Nui.SafeCallback('exam:submit', function(data)
    local result = call('submit', { submissionId = active, answers = data.answers })
    active = nil
    if not result.ok then Core.HandleResult(result, 'exam') end
    SetTimeout(0, Core.Nui.Close)
    return result
end)

-- Leaving midway: the paper does not come back and the deadline keeps running.
RegisterNUICallback('exam:abandon', function(_, cb)
    cb({ ok = true, data = {} })
    active = nil
    Core.Nui.Close()
end)

Core.Nui.OnClose('exam.solve', function()
    active = nil
    Core.Unhold()
end)

-- Own results: the report card, as the office hands it over.
function Exams.openResults()
    local result = lib.callback.await('daddy_college:exam:myGrades', false)
    if not result or result.ok == false then return Core.HandleResult(Core.NormalizeResult(result), 'exam') end
    if #result.rows == 0 and #result.pending == 0 then return Core.NotifyL('exam.no_results', 'inform') end
    Core.Nui.Open('exam.results', result)
end

Core.Command(cfg.Commands.panel, Exams.openPanel)
Core.Command(cfg.Commands.results, Exams.openResults)

-- At the Student Affairs desk the results open in a panel of the talk.
Core.Affairs.RegisterAction('exam:results', { order = 40, icon = 'fa-solid fa-file-signature', label = 'exam.target_results', panel = true,
    visible = function(context) return context.isStudent == true end })
