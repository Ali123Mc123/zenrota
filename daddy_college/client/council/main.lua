-- The student council's members for the principal or an admin (the command): list, add, change a rank, remove.
-- The server checks the right on every call.
if not Config.Council or not Config.Council.Enabled then return end

local t = DL.locale.t

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:council:' .. name, false, data))
end

local open

local function rankOptions(ranks)
    local out = {}
    for i, r in ipairs(ranks) do out[i] = { value = r.key, label = r.label } end
    return out
end

local function add(ranks)
    local input = lib.inputDialog(t('council.add_title'), {
        { type = 'input', label = t('council.add_target'), description = t('council.add_target_hint'), required = true },
        { type = 'select', label = t('council.rank'), options = rankOptions(ranks), default = ranks[#ranks] and ranks[#ranks].key, required = true },
    })
    if not input then return open() end
    local result = call('set', { target = input[1], rank = input[2] })
    if result.ok then Core.NotifyL('council.added', 'success', result.name or '') else Core.HandleResult(result, 'council') end
    open()
end

local function member(m, ranks)
    lib.registerContext({
        id = 'daddy_college_council_member', title = m.name, menu = 'daddy_college_council',
        options = {
            { title = t('council.change_rank'), description = m.label, icon = 'ranking-star', onSelect = function()
                local input = lib.inputDialog(m.name, { { type = 'select', label = t('council.rank'), options = rankOptions(ranks), default = m.rank, required = true } })
                if input then
                    local result = call('set', { target = m.citizenid, rank = input[1] })
                    if not result.ok then Core.HandleResult(result, 'council') end
                end
                open()
            end },
            { title = t('council.remove'), icon = 'user-minus', onSelect = function()
                if lib.alertDialog({ header = m.name, content = t('council.remove_confirm'), centered = true, cancel = true }) == 'confirm' then
                    local result = call('remove', { citizenid = m.citizenid })
                    if result.ok then Core.NotifyL('council.removed', 'success') else Core.HandleResult(result, 'council') end
                end
                open()
            end },
        },
    })
    lib.showContext('daddy_college_council_member')
end

open = function()
    local result = call('list')
    if not result.ok then return Core.HandleResult(result, 'council') end
    local options = { { title = t('council.add'), icon = 'user-plus', onSelect = function() add(result.ranks) end } }
    for _, m in ipairs(result.members or {}) do
        options[#options + 1] = { title = m.name, description = m.label, icon = 'scale-balanced', arrow = true, onSelect = function() member(m, result.ranks) end }
    end
    if #(result.members or {}) == 0 then options[#options + 1] = { title = t('council.empty'), disabled = true } end
    lib.registerContext({ id = 'daddy_college_council', title = t('council.title'), options = options })
    lib.showContext('daddy_college_council')
end

RegisterNetEvent('daddy_college:council:manage', function() open() end)
