local polePoints = {}
local poleProps = {}
local modelTargs = {}
local isDancing = false
local currentScene = nil
local Config = require 'config.config'

-- DaddyRP: a College student needs the dancer certificate to pole dance (daddy_college config/integrations.lua PoleDance).
local function OpenDanceMenu()
    if GetResourceState('daddy_college') == 'started' then
        local ok, allowed = pcall(function() return exports.daddy_college:PoleDanceAllowed() end)
        if ok and allowed == false then return end
    end
    lib.showContext('dance_menu')
end

local function StopDancing()
    if not isDancing and not currentScene then return end
    isDancing = false
    if currentScene then
        NetworkStopSynchronisedScene(currentScene)
        currentScene = nil
    end
    ClearPedTasks(cache.ped)
end

lib.registerContext({
    id = 'dance_menu',
    title = 'Dansını Seç',
    options = {
        { title = 'Dans Seçenekleri' }, {
            title = 'Dansı Bitir',
            icon = 'times',
            onSelect = function()
                StopDancing()
            end,
        }, {
            title = 'Direk Dansı #1',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = { dance = 1 }
        }, {
            title = 'Direk Dansı #2',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = { dance = 2 }
        }, {
            title = 'Direk Dansı #3',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = { dance = 3 }
        }, {
            title = 'Kucak Dansı #1',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 1,
                anim = 'lap_dance_girl',
                dict = 'mp_safehouse'
            }
        }, {
            title = 'Kucak Dansı #2',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 2,
                anim = 'priv_dance_idle',
                dict = 'mini@strip_club@private_dance@idle'
            }
        }, {
            title = 'Kucak Dansı #3',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 3,
                anim = 'priv_dance_p1',
                dict = 'mini@strip_club@private_dance@part1'
            }
        }, {
            title = 'Kucak Dansı #4',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 4,
                anim = 'priv_dance_p2',
                dict = 'mini@strip_club@private_dance@part2'
            }
        }, {
            title = 'Kucak Dansı #5',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 5,
                anim = 'priv_dance_p3',
                dict = 'mini@strip_club@private_dance@part3'
            }
        }, {
            title = 'Kucak Dansı #6',
            icon = 'shoe-prints',
            event = 'bm_dance:start',
            args = {
                lapdance = 6,
                anim = 'yacht_ld_f',
                dict = 'oddjobs@assassinate@multi@yachttarget@lapdance'
            }
        }
    }
})

lib.addKeybind({
    name = 'cancelpoledance',
    description = 'Direk Dansını Bitir',
    defaultKey = 'x',
    onReleased = function(self)
        StopDancing()
    end
})

local function StartRay()
    lib.showTextUI('[E] kopyala  \n[DEL] iptal')
    while true do
        local _, _, endCoords, _, _ = lib.raycast.cam(1, 4, 10)
        DrawMarker(21, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255,
            255, 255, false, true, 0, false, false, false, false)
        if IsControlJustPressed(0, 38) or IsControlJustReleased(0, 38) then
            lib.hideTextUI()
            return endCoords
        elseif IsControlJustPressed(0, 178) or IsControlJustReleased(0, 178) then
            lib.hideTextUI()
            return nil
        end
        Wait(0)
    end
end

local function DestroyTargets()
    for _, pole in ipairs(polePoints) do
        if Config.Target == 'ox' then
            -- polePoints lib.points nesnelerini de tutuyor; sadece zone id'lerini sil
            if type(pole) == 'number' then
                exports.ox_target:removeZone(pole)
            elseif type(pole) == 'table' and pole.remove then
                pole:remove()
            end
            if Config.UseModels then
                for _, v in pairs(modelTargs) do
                    exports.ox_target:removeModel('prop_strip_pole_01', v)
                end
            end
        elseif Config.Target == 'qb' then
            exports['qb-target']:RemoveZone(pole)
        elseif Config.Target == 'lib' then
            pole:remove()
        end
    end
    for _, pole in ipairs(poleProps) do
        if DoesEntityExist(pole) then
            DeleteObject(pole)
            DeleteEntity(pole)
        end
    end
    -- Tabloları sıfırla, bir sonraki CreateTargets'ta eski referanslar kalmasın
    polePoints = {}
    poleProps = {}
    modelTargs = {}
end

local function CreateTargets()
    DestroyTargets()
    if Config.Target == 'ox' then
        if Config.UseModels then
            local modelTarg = exports.ox_target:addModel('prop_strip_pole_01', {
                {
                    label = "Direk Dansı",
                    icon = "fas fa-shoe-prints",
                    distance = 3.0,
                    offsetSize = 2.0,
                    offset = vec3(1.5, 1.5, 1.5),
                    onSelect = function() OpenDanceMenu() end
                }
            })
            modelTargs[#modelTargs + 1] = modelTarg
        end

        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local params = {
                coords = v.position,
                size = vec3(1, 1, 3) or v.size,
                rotation = v.position.w,
                debug = Config.Debug,
                options = {
                    {
                        label = 'Direk Dansı',
                        name = 'Pole' .. k,
                        icon = 'fas fa-shoe-prints',
                        distance = 3.0,
                        groups = nil or v.job,
                        onSelect = function()
                            OpenDanceMenu()
                        end
                    }
                }
            }
            local poleZone = exports.ox_target:addBoxZone(params)
            polePoints[#polePoints + 1] = poleZone
        end
    elseif Config.Target == 'qb' then
        if Config.UseModels then
            exports['qb-target']:AddTargetModel('prop_strip_pole_01', {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Direk Dansı',
                        action = function()
                            OpenDanceMenu()
                        end
                    }
                },
                distance = 1.5
            })
        end
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local poleZone = exports['qb-target']:AddBoxZone('pole' .. k, v.position.xyz, 1.5, 1.5, {
                name = "pole" .. k,
                heading = v.position.w,
                debugPoly = Config.Debug,
                minZ = v.position.z - 2.0,
                maxZ = v.position.z + 2.0
            }, {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Direk Dansı',
                        action = function()
                            OpenDanceMenu()
                        end
                    }
                },
                distance = 2.0
            }
            )
            polePoints[#polePoints + 1] = poleZone
        end
    elseif Config.Target == 'lib' then
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local params = {
                coords = vec3(v.position.x, v.position.y, v.position.z + 1.0),
                size = vec3(1, 1, 1),
                rotation = v.position.w,
                onEnter = function()
                    lib.showTextUI('[E] Dans et')
                end,
                inside = function()
                    if isDancing then
                        lib.showTextUI('[X] Dansı bitir')
                        if IsControlJustPressed(0, 73) then
                            StopDancing()
                            lib.hideTextUI()
                            lib.showTextUI('[E] Dans et')
                        end
                    end
                    if IsControlJustReleased(0, 38) then
                        OpenDanceMenu()
                    end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                debug = Config.Debug,
            }
            local poleZone = lib.zones.box(params)
            polePoints[#polePoints + 1] = poleZone
        end
    end
    -- lib.points nesnelerini de polePoints tablosuna kaydet (dans için gerekli)
    for _, v in ipairs(Config.Poles) do
        local point = lib.points.new({
            coords = v.position,
            distance = 3.0,
        })
        polePoints[#polePoints + 1] = point
    end
end

local function ToConfigFormat(poleConfig)
    local formattedConfig = "{ position = vec4(" ..
        poleConfig.position.x .. "," .. poleConfig.position.y .. "," .. poleConfig.position.z .. ",0.0),"
    if poleConfig.spawn then
        formattedConfig = formattedConfig .. " spawn = true },"
    else
        formattedConfig = formattedConfig .. " },"
    end
    return formattedConfig
end

local function GetClosestPoleCoords()
    local closestPoint = lib.points.getClosestPoint()
    if closestPoint then
        return closestPoint.coords
    end
    local pedCoords = GetEntityCoords(cache.ped)
    local closestDist = 10.0
    local closestCoords = nil
    for _, v in ipairs(Config.Poles) do
        local polePos = v.position.xyz or vec3(v.position.x, v.position.y, v.position.z)
        local dist = #(pedCoords - polePos)
        if dist < closestDist then
            closestDist = dist
            closestCoords = polePos
        end
    end
    return closestCoords
end

RegisterNetEvent('bm_dance:start', function(args)
    StopDancing()

    if args.dance then
        local poleCoords = GetClosestPoleCoords()
        if not poleCoords and args.coords then
            poleCoords = args.coords.xyz or vec3(args.coords.x, args.coords.y, args.coords.z)
        end

        if poleCoords then
            local animDict = 'mini@strip_club@pole_dance@pole_dance' .. args.dance
            local animClip = 'pd_dance_0' .. args.dance

            lib.requestAnimDict(animDict)

            isDancing = true
            currentScene = NetworkCreateSynchronisedScene(
                poleCoords.x + 0.07, poleCoords.y + 0.3, poleCoords.z + 1.15,
                0.0, 0.0, 0.0,
                2,
                false, -- holdLastFrame: false (animasyon bitince son karede donmaması için)
                true,  -- looped: true (sahnenin sürekli dönmesi için)
                1.0,   -- phaseToStopScene (1.0)
                0.0,   -- phaseToStartScene (0.0)
                1.0    -- animSpeed
            )
            NetworkAddPedToSynchronisedScene(
                cache.ped,
                currentScene,
                animDict,
                animClip,
                1.5,
                -4.0,
                65,    -- syncedSceneFlags: 1 (USE_PHYSICS) | 64 (LOOP_WITHIN_SCENE) = 65 (sürekli loop yapması için)
                1,     -- ragdollFlags
                1000.0, -- moverBlendInDelta
                0      -- ikFlags
            )
            NetworkStartSynchronisedScene(currentScene)
        else
            if Config.Debug then print('Yakında direk bulunamadı') end
        end
    elseif args.lapdance then
        lib.requestAnimDict(args.dict)
        TaskPlayAnim(cache.ped, args.dict, args.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
        isDancing = true
    end
end)

RegisterNetEvent('bm_dance:pole', function()
    if not IsPlayerAceAllowed(PlayerId(), 'bostra.admin') then
        lib.notify({ title = 'Dans', description = 'Bu komutu kullanmaya yetkiniz yok.', type = 'error' })
        return
    end
    local polePosition = StartRay()
    if polePosition then
        local poleConfig = {
            position = vec4(polePosition.x, polePosition.y, polePosition.z, 0.0),
            spawn = true,
        }
        Config.Poles[#Config.Poles + 1] = poleConfig
        if Config.Debug then
            print("New pole added to Config.Poles:")
            print(ToConfigFormat(poleConfig))
        end
        lib.setClipboard(ToConfigFormat(poleConfig))
        lib.notify({ title = 'Dans', description = 'Yeni direk panoya kopyalandı', type = 'success' })
        CreateTargets()
    else
        print("Action canceled.")
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    CreateTargets()
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    StopDancing()
    DestroyTargets()
end)

if GetResourceState('qb-core') == 'started' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        Wait(3000)
        CreateTargets()
    end)
end
