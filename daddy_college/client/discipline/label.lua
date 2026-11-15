-- Over a student serving public detention: a small "Detention 3/8" the players near see (Public.Label).
-- The server sets the replicated state; this only looks at players close by, twice a second, and draws them.
if not Core.ModuleEnabled('discipline') or not Config.Discipline.Public.Label then return end

local reach = Config.Discipline.Public.LabelDistance
local t = DL.locale.t
local shown = {} -- { ped, text }

local function text3d(coords, text)
    SetTextScale(0.0, 0.32)
    SetTextFont(4)
    SetTextColour(255, 205, 195, 220)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

CreateThread(function()
    while true do
        if not Core.OnCampus() then
            shown = {}
            Wait(2000)
        else
            local here, list = GetEntityCoords(cache.ped), {}
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if ped ~= cache.ped and #(GetEntityCoords(ped) - here) <= reach then
                    local state = Player(GetPlayerServerId(player)).state.collegeDetention
                    if state then list[#list + 1] = { ped = ped, text = t('discipline.label', state.done, state.total) } end
                end
            end
            shown = list
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        if #shown == 0 then
            Wait(500)
        else
            for _, row in ipairs(shown) do
                if DoesEntityExist(row.ped) then text3d(GetPedBoneCoords(row.ped, 31086, 0.0, 0.0, 0.0) + vector3(0.0, 0.0, 0.38), row.text) end
            end
            Wait(0)
        end
    end
end)
