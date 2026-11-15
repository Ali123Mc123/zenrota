-- One way to reach every point of the resource (objects, entrances, doors, crates). Config.Interaction.Mode picks how:
-- a target system, the ox_lib text box, floating 3D text or the help box of GTA. Prompts only run near a point.
Venue.Interact = {}

local mode
local active, shown
local counter = 0
local keybind

local function started(name) return GetResourceState(name) == 'started' end

local function resolve()
    local wanted = Config.Interaction.Mode
    if wanted == 'auto' or wanted == 'target' then
        if started('ox_target') then return 'ox' end
        if started('qb-target') then return 'qb' end
        return 'textui'
    end
    if wanted == '3dtext' or wanted == 'help' then return wanted end
    return 'textui'
end

local function key() return keybind and keybind:getCurrentKey() or Config.Interaction.Key end

local function text3d(at, text)
    SetDrawOrigin(at.x, at.y, at.z, 0)
    SetTextScale(0.34, 0.34)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function help(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(('~%s~ %s'):format(('INPUT_%X'):format(joaat('+daddy_venue_use') | 0x80000000), text))
    EndTextCommandDisplayHelp(0, false, false, -1)
end

local function hide(entry)
    if shown == entry then
        lib.hideTextUI()
        shown = nil
    end
end

local function prompt(opts)
    local entry = { opts = opts }
    local range = opts.distance or Config.Interaction.Distance
    local function allowed() return not opts.canInteract or opts.canInteract() end

    entry.point = lib.points.new({
        coords = opts.coords, distance = range + 4.0,
        nearby = function(self)
            if opts.marker and allowed() then opts.marker() end
            local close = self.currentDistance <= range and allowed()
            if close and (not active or active == entry or self.currentDistance < active.distance) then
                if active and active ~= entry then hide(active) end
                active, entry.distance = entry, self.currentDistance
            elseif not close and active == entry then
                active = nil
            end

            if mode == '3dtext' then
                if allowed() and self.currentDistance <= range + 2.5 then
                    text3d(opts.coords + vec3(0.0, 0.0, opts.lift or 0.5), active == entry and ('~g~[%s]~w~ %s'):format(key(), opts.label) or opts.label)
                end
            elseif mode == 'help' then
                if active == entry then help(opts.label) end
            elseif active == entry then
                if shown ~= entry then lib.showTextUI(('[%s] %s'):format(key(), opts.label)) shown = entry end
            else
                hide(entry)
            end
        end,
        onExit = function()
            if active == entry then active = nil end
            hide(entry)
        end,
    })

    return {
        remove = function()
            entry.point:remove()
            if active == entry then active = nil end
            hide(entry)
        end,
    }
end

-- opts: coords, label, icon, onSelect, canInteract?, distance?, marker?, lift?
function Venue.Interact.add(opts)
    mode = mode or resolve()
    counter = counter + 1
    local range = opts.distance or Config.Interaction.Distance

    if mode == 'ox' then
        local zone = exports.ox_target:addSphereZone({
            coords = opts.coords, radius = 0.8,
            options = { {
                name = 'daddy_venue_' .. counter, icon = 'fa-solid ' .. (opts.icon or 'fa-hand'), label = opts.label, distance = range + 0.5,
                canInteract = opts.canInteract and function() return opts.canInteract() end or nil,
                onSelect = function() opts.onSelect() end,
            } },
        })
        return { remove = function() exports.ox_target:removeZone(zone) end }
    elseif mode == 'qb' then
        local name = 'daddy_venue_' .. counter
        exports['qb-target']:AddCircleZone(name, opts.coords, 0.8, { name = name, useZ = true, debugPoly = false }, {
            options = { {
                icon = 'fa-solid ' .. (opts.icon or 'fa-hand'), label = opts.label,
                canInteract = opts.canInteract and function() return opts.canInteract() end or nil,
                action = function() opts.onSelect() end,
            } },
            distance = range + 0.5,
        })
        return { remove = function() exports['qb-target']:RemoveZone(name) end }
    end
    return prompt(opts)
end

-- markers are part of the prompt styles only, a target shows its own eye
function Venue.Interact.usesTarget()
    mode = mode or resolve()
    return mode == 'ox' or mode == 'qb'
end

keybind = lib.addKeybind({
    name = 'daddy_venue_use', description = L('key_use'), defaultKey = Config.Interaction.Key,
    onPressed = function()
        if active then active.opts.onSelect() end
    end,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and shown then lib.hideTextUI() end
end)
