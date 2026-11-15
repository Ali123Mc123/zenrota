-- Writing at a desk: seated on a Campus Life chair marked as a desk, [N] opens the notebook lying on the desk instead
-- of in hand, with the camera looking down at it. Standing up closes it.
if Config.Modules.notes == false or not (Config.Notes.Desk or {}).Enabled then return end

local cfg = Config.Notes.Desk
local t = DL.locale.t
local open, prop, cam = false, nil, nil

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:notes:' .. name, false, data or {}))
end

local function atDesk() return LocalPlayer.state.campusDesk == true end

-- The closed notebook in front of the seated student.
local function place()
    local model = joaat(cfg.Prop)
    if not pcall(lib.requestModel, model, 2000) then return end
    local at = GetOffsetFromEntityInWorldCoords(cache.ped, cfg.PropOffset.x, cfg.PropOffset.y, cfg.PropOffset.z)
    pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
    prop = CreateObject(model, at.x, at.y, at.z, false, false, false)
    SetEntityHeading(prop, GetEntityHeading(cache.ped))
    SetEntityCollision(prop, false, false)
    FreezeEntityPosition(prop, true)
    SetModelAsNoLongerNeeded(model)
end

-- Over the shoulder, looking down at the desk.
local function lookDown()
    local c = cfg.Camera
    if not c.Enabled then return end
    local at = GetOffsetFromEntityInWorldCoords(cache.ped, c.Offset.x, c.Offset.y, c.Offset.z)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', at.x, at.y, at.z, c.Pitch, 0.0, GetEntityHeading(cache.ped), c.Fov, false, 0)
    pcall(function() exports['FeloxAC']:createCam(cam) end) --[[FeloxAC:auto]]
    SetCamActive(cam, true)
    RenderScriptCams(true, true, c.EaseMs, true, false)
    if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:showHud() end
end

local function cleanup()
    open = false
    if cam then
        RenderScriptCams(false, true, cfg.Camera.EaseMs, true, false)
        if GetResourceState('wais-primehud') == 'started' then exports['wais-primehud']:hideHud() end
        pcall(function() exports['FeloxAC']:destroyCam(cam) end) --[[FeloxAC:auto]]
        DestroyCam(cam, false)
        cam = nil
    end
    if prop and DoesEntityExist(prop) then DeleteEntity(prop) end
    prop = nil
end

local function openAtDesk()
    if open or Core.Nui.IsOpen() or not atDesk() then return end
    local result = call('deskOpen')
    if not result.ok then return Core.HandleResult(result, 'notes') end
    open = true
    place()
    lookDown()
    Core.Nui.Open('notes.editor', result)
    -- Standing up or dying closes the notebook (it saves as it closes).
    CreateThread(function()
        while open do
            if not atDesk() or IsEntityDead(cache.ped) then
                Core.Nui.Close()
                break
            end
            Wait(250)
        end
    end)
end

AddEventHandler('daddy_college:notes:closed', function()
    if open then cleanup() end
end)

-- The loose sheet kept as a page.
Core.Nui.SafeCallback('notes:deskKeep', function(data)
    local result = call('deskKeep', data)
    if not result.ok then Core.HandleResult(result, 'notes') end
    return result
end)

-- The hint while seated at a desk, and its key.
CreateThread(function()
    local shown = false
    while true do
        local ready = atDesk() and not open and not Core.Nui.IsOpen()
        if ready ~= shown then
            shown = ready
            Core.Prompt('desk_notebook', ready and { id = 'desk_notebook', title = t('notes.desk_title'),
                keys = { { keys = { Core.KeyName(cfg.Key) }, label = t('notes.desk_open') } } } or nil)
        end
        if ready then
            if IsControlJustPressed(0, cfg.Key) then CreateThread(openAtDesk) end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    if open then cleanup() end
    Core.Prompt('desk_notebook', nil)
end)
