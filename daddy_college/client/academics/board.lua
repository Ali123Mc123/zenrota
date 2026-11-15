-- The Student of the Week board: a prop at every 'week_board' spot that opens the pinned photo and the weeks before.
-- The week's student has their photo taken here when the server asks.
if Config.Modules.academics == false or not Config.Academics then return end

local cfg = Config.Academics.StudentOfWeekBoard or {}
local t = DL.locale.t

local function open()
    if Core.Nui.IsOpen() then return end
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:academics:weekBoard', false, {}))
    if not result.ok then return Core.HandleResult(result, 'academics') end
    Core.Nui.Open('academics.board', result.data)
end

local function sync()
    local defs = {}
    for _, spot in ipairs(Core.World.entities({ kind = 'week_board' })) do
        defs[#defs + 1] = {
            uid = 'weekboard:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision, presentation = 'prop',
            model = (spot.model or '') ~= '' and spot.model or cfg.Model or 'prop_cork_board', streamDistance = spot.streamDistance,
            distance = spot.interactDistance or cfg.Distance or 2.0,
            options = { {
                name = 'week_board', label = t('academics.board_look'), icon = 'fa-solid fa-star', distance = spot.interactDistance or cfg.Distance or 2.0,
                canInteract = function() return not Core.Nui.IsOpen() end,
                onSelect = function() CreateThread(open) end,
            }, {
                name = 'week_awards', label = t('awards.board_vote'), icon = 'fa-solid fa-check-to-slot', distance = spot.interactDistance or cfg.Distance or 2.0,
                canInteract = function() return Core.OpenAwards ~= nil and not Core.Nui.IsOpen() end,
                onSelect = function() CreateThread(Core.OpenAwards) end,
            } },
        }
    end
    Core.World.anchors.sync('weekboard', defs)
end

Core.World.subscribe(sync)

-- The server asks the week's student for a head shot (daddy_lib mugshot; nothing when MugShotBase64 is not running).
RegisterNetEvent('daddy_college:academics:photo', function(week, kind)
    local photo = DL.mugshot.capture(cache.ped, cfg.PhotoMaxBytes)
    if photo then TriggerServerEvent('daddy_college:academics:photo', week, photo, kind) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('weekboard') end
end)
