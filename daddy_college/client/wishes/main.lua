-- Wish trees on the client: the trees and boards at their spots, and the cards on them for players nearby.
-- A tree's cards are asked for when the player comes close and let go when they walk away; no text comes here.
if not Core.ModuleEnabled('wishes') or not Core.ModuleEnabled('notes') or not Config.Wishes then return end

local cfg = Config.Wishes
local range = cfg.StreamDistance or 40.0
local trees, loaded, loading = {}, {}, {} -- uid -> spot; uid -> { [id] = pose }; uid -> true

WishClient = { trees = trees, loaded = loaded }

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:wishes:' .. name, false, data))
end
WishClient.call = call

local function firstModel(names)
    for _, name in ipairs(names or {}) do
        if IsModelInCdimage(joaat(name)) then return name end
    end
end

local treeModels = {}
for _, tree in ipairs(cfg.Trees or {}) do treeModels[#treeModels + 1] = tree.model end

-- The card model of a kind and colour: the first of its list the game has, %s standing for the colour.
local cardModels = {}
local function cardModel(kind, color)
    local key = kind .. ':' .. (color or '')
    if cardModels[key] == nil then
        local names = {}
        for i, name in ipairs(cfg.Cards[kind == 'wish_board' and 'board' or 'tree'] or {}) do names[i] = name:format(color or '') end
        cardModels[key] = firstModel(names) or false
    end
    return cardModels[key] or nil
end
WishClient.cardModel = cardModel

-- Target options of a tree; the hanging and reading file fills them in.
function WishClient.options(_) return {} end

-- Trees and boards --------------------------------------------------------------------------------------

local function treeAnchor(spot)
    local model = (spot.model or '') ~= '' and spot.model or firstModel(spot.kind == 'wish_board' and cfg.Boards or treeModels)
    return { uid = 'wish:tree:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision,
        presentation = model and 'prop' or 'point', model = model, streamDistance = math.max(spot.streamDistance or 0.0, range + 20.0),
        distance = cfg.TargetDistance, options = WishClient.options(spot),
        targetSphere = spot.kind == 'wish_tree' and cfg.TargetSphere or nil }
end

local function sync()
    local defs = {}
    for uid in pairs(trees) do trees[uid] = nil end
    for _, kind in ipairs({ 'wish_tree', 'wish_board' }) do
        for _, spot in ipairs(Core.World.entities({ kind = kind })) do
            trees[spot.uid] = spot
            defs[#defs + 1] = treeAnchor(spot)
        end
    end
    Core.World.anchors.sync('wishes', defs)
    for uid in pairs(loaded) do
        if not trees[uid] then Core.World.anchors.clear('wishes:' .. uid) loaded[uid] = nil end
    end
end
WishClient.sync = sync
Core.World.subscribe(sync)

-- Cards ----------------------------------------------------------------------------------------------------

-- A card hanging where the server put it, turned to its place, in its colour's model.
local function cardAnchor(spot, card)
    local model = cardModel(spot.kind, card.color)
    if not model then return nil end
    return {
        uid = 'wish:card:' .. card.id, presentation = 'prop', model = model, revision = 1, streamDistance = range, exact = true,
        coords = { x = card.x, y = card.y, z = card.z, w = card.h },
        onSpawn = function(_, entity)
            if not entity then return end
            SetEntityCollision(entity, false, false)
            SetEntityRotation(entity, 0.0, (card.tilt or 0) + 0.0, (card.h or 0.0) + 0.0, 2, true)
        end,
    }
end

local function showTree(uid, cards)
    local spot = trees[uid]
    if not spot then return end
    local defs, posed = {}, {}
    for _, card in ipairs(cards or {}) do
        posed[card.id] = card
        defs[#defs + 1] = cardAnchor(spot, card)
    end
    loaded[uid] = posed
    Core.World.anchors.sync('wishes:' .. uid, defs)
end

local function forget(uid)
    Core.World.anchors.clear('wishes:' .. uid)
    loaded[uid] = nil
end

-- Near a tree its cards are asked for once; walking away lets them go.
CreateThread(function()
    while true do
        local here, near = GetEntityCoords(cache.ped), false
        for uid, spot in pairs(trees) do
            local c = spot.coords
            local d = #(here - vector3(c.x, c.y, c.z))
            if d <= range then
                near = true
                if not loaded[uid] and not loading[uid] then
                    loading[uid] = true
                    local result = call('tree', { uid = uid })
                    loading[uid] = nil
                    if result.ok and trees[uid] then showTree(uid, result.cards) end
                end
            elseif loaded[uid] and d > range + 15.0 then
                forget(uid)
            end
        end
        Wait(near and 500 or 1500)
    end
end)

-- A card hung or taken down: the tree's set is shown again so the anchors stay in its namespace.
local function changed(uid, id, card)
    local posed = loaded[uid]
    if not posed or not id then return end
    posed[id] = card
    local list = {}
    for _, one in pairs(posed) do list[#list + 1] = one end
    showTree(uid, list)
end

RegisterNetEvent('daddy_college:wishes:hung', function(data) changed(data.tree, data.id, data) end)
RegisterNetEvent('daddy_college:wishes:removed', function(data) changed(data.tree, data.id, nil) end)

RegisterNetEvent('daddy_college:wishes:tree', function(data)
    if loaded[data.tree] then showTree(data.tree, data.cards) end
end)

-- Wish night -----------------------------------------------------------------------------------------------------

-- Every card of a tree rises a few metres, sways and fades, with the release effect at the start and the end.
RegisterNetEvent('daddy_college:wishes:release', function(data)
    local spot = trees[data.tree]
    if not spot then return end
    forget(data.tree)
    local fx = cfg.Release or {}
    local seconds = fx.RiseSeconds or 6
    local hasFx = fx.Asset and pcall(lib.requestNamedPtfxAsset, fx.Asset, 3000)
    local function burst(x, y, z)
        if not hasFx then return end
        UseParticleFxAsset(fx.Asset)
        StartParticleFxNonLoopedAtCoord(fx.Effect, x, y, z, 0.0, 0.0, 0.0, fx.Scale or 0.25, false, false, false)
    end
    for i, card in ipairs(data.cards or {}) do
        local model = cardModel(spot.kind, card.color)
        if model and pcall(lib.requestModel, model, 3000) then
            CreateThread(function()
                Wait(i * 120)
                pcall(function() exports['FeloxAC']:CreateObject(joaat(model)) end) --[[FeloxAC:auto]]
                local object = CreateObjectNoOffset(joaat(model), card.x, card.y, card.z, false, false, false)
                SetEntityCollision(object, false, false)
                SetEntityRotation(object, 0.0, (card.tilt or 0) + 0.0, (card.h or 0.0) + 0.0, 2, true)
                burst(card.x, card.y, card.z)
                local start, phase = GetGameTimer(), math.random() * 6.28
                while GetGameTimer() - start < seconds * 1000 do
                    local t = (GetGameTimer() - start) / (seconds * 1000)
                    local sway = math.sin(phase + t * 9.0) * 0.35 * t
                    SetEntityCoordsNoOffset(object, card.x + sway, card.y + sway * 0.6, card.z + t * t * 9.0, false, false, false)
                    SetEntityHeading(object, (card.h or 0.0) + t * 220.0)
                    SetEntityAlpha(object, math.floor(255 * (1.0 - t * t)), false)
                    Wait(0)
                end
                local at = GetEntityCoords(object)
                burst(at.x, at.y, at.z)
                DeleteObject(object)
                SetModelAsNoLongerNeeded(joaat(model))
            end)
        end
    end
    SetTimeout((seconds + 2) * 1000 + #(data.cards or {}) * 120, function()
        if hasFx then RemoveNamedPtfxAsset(fx.Asset) end
    end)
end)
