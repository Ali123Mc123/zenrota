-- The setup panel on the client: the shared catalog panel on College's own view manager.
if not Core.ModuleEnabled('admin') then return end

World.panel({
    view = 'admin.panel', calls = { 'saveSetting' }, maxPoints = Config.Admin.MaxZonePoints, reach = Config.Admin.PlacementReach, zoneReach = Config.Admin.ZoneReach,
    -- practical stations measure where they go (client/practicals/survey.lua); one on a map table shows no body
    preview = function(...) return Core.PracticalSurvey and Core.PracticalSurvey.preview(...) end,
    model = function(row) if type(row.settings) == 'table' and row.settings.mode == 'map' then return false end end,
    nui = {
        isOpen = Core.Nui.IsOpen, send = Core.Nui.Send, suspend = Core.Nui.Suspend, resume = Core.Nui.Resume, onClose = Core.Nui.OnClose,
        result = Core.NormalizeResult, notify = function(key, kind) Core.NotifyL(key, kind) end,
        open = function(view, payload) Core.Nui.Open(view, payload, { failsafe = false }) end,
    },
})
