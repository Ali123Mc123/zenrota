-- The card wallet on the client: a withdraw option on every ATM, and the ATMs placed on campus.
if not Core.ModuleEnabled('cardpay') then return end

local cfg = Config.CardPay
local t = DL.locale.t

local function withdraw()
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:cardpay:withdraw', false))
    if not result.ok then return Core.HandleResult(result, 'cardpay') end
    Core.NotifyL('cardpay.withdrawn', 'success', result.amount)
end

-- Only a hint: the server decides whose wallet it is.
local function free() return not IsEntityDead(cache.ped) and not IsPedInAnyVehicle(cache.ped, false) end

local OPTIONS = {
    { label = t('cardpay.target_scholarship'), icon = 'fa-solid fa-graduation-cap', onSelect = withdraw,
        canInteract = function() return Core.IsStudent() and free() end },
    { label = t('cardpay.target_salary'), icon = 'fa-solid fa-money-bill-wave', onSelect = withdraw,
        canInteract = function() return Core.IsTeacher() and not Core.IsStudent() and free() end },
}

local function modelOf(spot) return (spot.model or '') ~= '' and spot.model or cfg.ATMModels[1] end

-- The placed ATMs stand as props; every ATM model, the map's own too, gets the option.
local function sync()
    local models, seen, defs = {}, {}, {}
    local function addModel(model)
        if not seen[model] then seen[model], models[#models + 1] = true, model end
    end
    for _, model in ipairs(cfg.ATMModels) do addModel(model) end
    for _, spot in ipairs(Core.World.entities({ kind = 'cardpay_atm' })) do
        addModel(modelOf(spot))
        defs[#defs + 1] = { uid = 'cardpay:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision,
            presentation = 'prop', model = modelOf(spot), streamDistance = spot.streamDistance }
    end
    Core.World.anchors.sync('cardpay', defs)
    DL.target.addModels('cardpay_atm', { models = models, distance = cfg.TargetDistance, options = OPTIONS })
end

Core.World.subscribe(sync)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('cardpay') end
end)
