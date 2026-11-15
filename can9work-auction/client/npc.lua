-- Isletme NPC'leri: oyuncu yaklasinca dogar, uzaklasinca silinir; ihale secenegi ox_target ile eklenir.

local PED = Settings.SitePed
local points = {}

local function Despawn(point)
    if point.ped and DoesEntityExist(point.ped) then
        exports.ox_target:removeLocalEntity(point.ped)
        DeleteEntity(point.ped)
    end
    point.ped = nil
end

local function Spawn(point)
    if point.ped or point.spawning then return end
    point.spawning = true
    local model = joaat(PED.model)
    local loaded = lib.requestModel(model, 10000)
    point.spawning = false
    if not loaded then return end
    -- Oyuncu model yuklenirken uzaklasmis olabilir.
    if not point.inside then return SetModelAsNoLongerNeeded(model) end

    local c = point.site.ped
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, model, c.x, c.y, c.z - 1.0, c.w, false, true)
    SetModelAsNoLongerNeeded(model)
    if not DoesEntityExist(ped) then return end

    SetEntityHeading(ped, c.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    if PED.scenario then TaskStartScenarioInPlace(ped, PED.scenario, 0, true) end
    point.ped = ped

    local site = point.site
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'can9work_auction_site',
            icon = 'fas fa-gavel',
            label = ('İhale · %s'):format(site.label),
            distance = 2.5,
            onSelect = function()
                can9work.UI:OpenSite(point.site)
            end
        }
    })
end

-- Yeni listeyle NPC noktalarini esitler: yeri degismeyen NPC yerinde kalir (sadece bilgisi guncellenir).
local function Build(sites)
    local keep = {}
    for _, site in ipairs(sites or {}) do keep[site.id] = site end

    local nextPoints = {}
    for i = 1, #points do
        local point = points[i]
        local site = keep[point.site.id]
        local c = point.site.ped
        if site and site.ped.x == c.x and site.ped.y == c.y and site.ped.z == c.z and site.ped.w == c.w then
            point.site = site
            keep[site.id] = nil
            nextPoints[#nextPoints + 1] = point
        else
            Despawn(point)
            point:remove()
        end
    end

    for _, site in pairs(keep) do
        local point = lib.points.new({ coords = vec3(site.ped.x, site.ped.y, site.ped.z), distance = PED.distance, site = site })
        function point:onEnter()
            self.inside = true
            CreateThread(function() Spawn(self) end)
        end
        function point:onExit() self.inside = false; Despawn(self) end
        nextPoints[#nextPoints + 1] = point
    end
    points = nextPoints
end

RegisterNetEvent('can9work-auction/client/sites', Build)

CreateThread(function()
    Build(lib.callback.await('can9work-auction/server/getSites', false))
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for i = 1, #points do Despawn(points[i]) end
end)

-- Admin yerlestirme menusu (/ihalenpc)

local OpenNpcMenu

-- where: reddedilen yerlestirmede isletmenin gercek yeri; haritada isaretlenir.
local function Notify(ok, message, where)
    if not ok and type(where) == 'table' and where.x and where.y then
        SetNewWaypoint(where.x + 0.0, where.y + 0.0)
        message = message .. ' Gerçek yeri haritada işaretlendi.'
    end
    lib.notify({ title = 'İhale NPC', description = message, type = ok and 'success' or 'error' })
end

local function OpenSiteMenu(site, kind)
    local options = {
        {
            title = 'Bulunduğum yere koy',
            description = 'NPC tam durduğun yerde, baktığın yöne dönük durur.',
            icon = 'fas fa-location-dot',
            onSelect = function()
                Notify(lib.callback.await('can9work-auction/server/placeSitePed', false, site.business_id))
                OpenNpcMenu(kind)
            end
        }
    }

    if site.ped then
        options[#options + 1] = {
            title = 'NPC\'ye ışınlan',
            icon = 'fas fa-person-walking-arrow-right',
            onSelect = function()
                -- NPC'nin 1.2 m onune, ona donuk.
                local c = site.ped
                local rad = math.rad(c.w)
                pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                SetEntityCoords(cache.ped, c.x - math.sin(rad) * 1.2, c.y + math.cos(rad) * 1.2, c.z - 1.0, false, false, false, false)
                SetEntityHeading(cache.ped, (c.w + 180.0) % 360.0)
            end
        }
        options[#options + 1] = {
            title = 'NPC\'yi kaldır',
            icon = 'fas fa-trash',
            onSelect = function()
                Notify(lib.callback.await('can9work-auction/server/removeSitePed', false, site.business_id))
                OpenNpcMenu(kind)
            end
        }
    end

    lib.registerContext({ id = 'can9work_auction_npc_site', title = site.label, menu = 'can9work_auction_npc_kind', options = options })
    lib.showContext('can9work_auction_npc_site')
end

-- kind verilirse o tipin isletmeleri, verilmezse tipler listelenir.
OpenNpcMenu = function(kind)
    local sites = lib.callback.await('can9work-auction/server/adminSites', false)
    if not sites then return Notify(false, 'Yetkin yok.') end

    local byKind, order = {}, {}
    for i = 1, #sites do
        local t = sites[i].type
        if not byKind[t] then byKind[t] = {}; order[#order + 1] = t end
        byKind[t][#byKind[t] + 1] = sites[i]
    end
    table.sort(order)

    local kinds = {
        {
            title = 'Bulunduğum işletmeye koy',
            description = 'Numara seçmeden: NPC durduğun yere en yakın işletmenin görevlisi olur.',
            icon = 'fas fa-location-crosshairs',
            onSelect = function()
                Notify(lib.callback.await('can9work-auction/server/placeNearestPed', false))
                OpenNpcMenu()
            end
        }
    }
    for _, t in ipairs(order) do
        local placed = 0
        for _, site in ipairs(byKind[t]) do if site.ped then placed = placed + 1 end end
        local license = Settings.BusinessLicenses[t]
        kinds[#kinds + 1] = {
            title = license and license.short or t,
            description = ('%d / %d yerleştirildi'):format(placed, #byKind[t]),
            progress = math.floor(placed / #byKind[t] * 100),
            colorScheme = 'red',
            arrow = true,
            onSelect = function() OpenNpcMenu(t) end
        }
    end
    lib.registerContext({ id = 'can9work_auction_npc', title = 'İhale NPC\'leri', options = kinds })

    if not kind or not byKind[kind] then return lib.showContext('can9work_auction_npc') end

    local list = {}
    for _, site in ipairs(byKind[kind]) do
        list[#list + 1] = {
            title = site.label,
            description = site.business_id .. (site.ped and ' · yerleştirildi' or ' · NPC yok'),
            icon = site.ped and 'fas fa-check' or 'fas fa-circle-dot',
            iconColor = site.ped and '#3fbf6f' or nil,
            arrow = true,
            onSelect = function() OpenSiteMenu(site, kind) end
        }
    end
    lib.registerContext({ id = 'can9work_auction_npc_kind', title = (Settings.BusinessLicenses[kind] or {}).short or kind, menu = 'can9work_auction_npc', options = list })
    lib.showContext('can9work_auction_npc_kind')
end

RegisterNetEvent('can9work-auction/client/npcMenu', function() OpenNpcMenu() end)
