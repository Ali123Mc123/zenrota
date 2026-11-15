-- Cooking menus, the roasting stick game at the fire and chopping wood on the block.
local roastCfg = Config.Cook.Roast
Cook = { busy = false }

function Cook.menu(id)
    local list = lib.callback.await('daddy_camp:recipes', false, id) or {}
    if #list == 0 then return Client.notify('camp.no_recipes', 'error') end
    local options = {}
    for _, r in ipairs(list) do
        options[#options + 1] = {
            title = r.count > 1 and ('%s x%d'):format(r.label, r.count) or r.label,
            description = Client.t(r.ok and 'camp.recipe_time' or 'camp.recipe_missing', r.seconds),
            disabled = not r.ok, icon = 'fa-solid fa-utensils',
            onSelect = function() if Client.work('camp.work_cook', 2000) then Client.act(id, 'cook', { recipe = r.id }) end end,
        }
    end
    lib.registerContext({ id = 'daddy_camp_cook', title = Client.t('camp.cook_title'), options = options })
    lib.showContext('daddy_camp_cook')
end

function Cook.roastMenu(id)
    local options = {}
    for food in pairs(roastCfg.Foods) do
        options[#options + 1] = { title = Client.t('camp.roast_food.' .. food), icon = 'fa-solid fa-fire', onSelect = function() Cook.roast(id, food) end }
    end
    lib.registerContext({ id = 'daddy_camp_roast', title = Client.t('camp.roast_title'), options = options })
    lib.showContext('daddy_camp_roast')
end

-- The stick turns the food golden, then black: pull it (E) while it is golden.
function Cook.roast(id, food)
    if Cook.busy then return end
    local run = Client.act(id, 'roast', { food = food })
    if type(run) ~= 'table' then return end
    Cook.busy = true
    local ped = PlayerPedId()
    lib.requestAnimDict(roastCfg.Anim.dict)
    TaskPlayAnim(ped, roastCfg.Anim.dict, roastCfg.Anim.clip, 4.0, -4.0, -1, 49, 0, false, false, false)
    local start, stage, prop = GetGameTimer(), 0, nil
    lib.showTextUI(Client.t('camp.roast_help'))
    while true do
        local t = (GetGameTimer() - start) / 1000 / run.seconds
        local now = t < run.window[1] and 1 or t < run.window[2] and 2 or 3
        if now ~= stage then
            stage = now
            if prop then DeleteEntity(prop) end
            prop = Hand.attach(ped, 'roast_stick', run.states[stage])
        end
        if IsControlJustPressed(0, 38) or t > 1.25 or IsPedRagdoll(ped) then break end
        Wait(0)
    end
    lib.hideTextUI()
    lib.callback.await('daddy_camp:pull', false)
    Wait(600)
    if prop then DeleteEntity(prop) end
    StopAnimTask(ped, roastCfg.Anim.dict, roastCfg.Anim.clip, 2.0)
    Cook.busy = false
end

-- Chopping: steps up to the block, the axe comes out, one skill check per swing; a miss leaves the log for another try.
function Cook.chop(id, entity)
    if Cook.busy or not Client.act(id, 'chop_start') then return end
    Cook.busy = true
    local ped, chop = PlayerPedId(), Config.Chop
    local block, me = GetEntityCoords(entity), GetEntityCoords(ped)
    local away = me.xy - block.xy
    local spot = block.xy + (#away > 0.01 and away / #away or vec2(0.0, -1.0)) * chop.Stand
    local face = GetHeadingFromVector_2d(block.x - spot.x, block.y - spot.y)
    TaskGoStraightToCoord(ped, spot.x, spot.y, me.z, 1.0, 3000, face, 0.05)
    local stop = GetGameTimer() + 3000
    while #(GetEntityCoords(ped).xy - spot) > 0.15 and GetGameTimer() < stop do Wait(100) end
    SetEntityHeading(ped, face)
    local axe = Hand.attach(ped, 'axe', 'default')
    lib.requestAnimDict(chop.Anim.dict)
    local ok = true
    for _, level in ipairs(chop.Swings) do
        if not lib.skillCheck(level) then ok = false break end
        TaskPlayAnim(ped, chop.Anim.dict, chop.Anim.clip, 8.0, -8.0, chop.Anim.ms, 0, 0, false, false, false)
        Wait(chop.Anim.ms)
    end
    RemoveAnimDict(chop.Anim.dict)
    if axe then DeleteEntity(axe) end
    ClearPedTasks(ped)
    Client.act(id, 'chop', { ok = ok })
    Cook.busy = false
end
