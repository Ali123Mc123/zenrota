-- Test kit menu (/collegetest, Config.TestKit): one ox_lib menu per system; each button runs the server action and the
-- menu opens again, so a feature can be tried over and over. The server checks the admin on every action.
if Config.TestKit ~= true then return end

local t = DL.locale.t

local function run(action, data, back)
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:testkit:' .. action, false, data or {}))
    if result.ok then
        for line in tostring(result.message or ''):gmatch('[^\n]+') do
            print('[collegetest] ' .. line)
            Core.Notify(line, 'success')
        end
    else
        Core.HandleResult(result, 'testkit')
    end
    if back then lib.showContext(back) end
end

local function button(key, action, data, back, icon)
    return { title = t('testkit.' .. key), description = t('testkit.' .. key .. '_hint'), icon = icon,
        onSelect = function() CreateThread(function() run(action, data, back) end) end }
end

local function menu(id, items)
    lib.registerContext({ id = id, title = t('testkit.menu_' .. id:gsub('^testkit_', '')), menu = id ~= 'testkit' and 'testkit' or nil, options = items })
end

-- The nearest table's state from the server, and which stand props the game has (daddy_schoolprops started or not).
function ClubTestStatus()
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:testkit:clubStatus', false, {}))
    if not result.ok then Core.HandleResult(result, 'testkit') return lib.showContext('testkit_club') end
    local m = (Config.Affairs.Club.Table or {}).Models or {}
    local has = IsModelInCdimage(joaat('daddy_school_club_table_bare'))
    local lines = {}
    for line in tostring(result.message or ''):gmatch('[^\n]+') do lines[#lines + 1] = line end
    lines[#lines + 1] = has and t('testkit.club_status_props') or t('testkit.club_status_noprops')
    for _, line in ipairs(lines) do print('[collegetest] ' .. line) end
    lib.alertDialog({ header = t('testkit.club_status'), content = table.concat(lines, '  \n'), centered = true })
    lib.showContext('testkit_club')
end

-- Every club as a button that runs one action with it (bind to the table, become its officer).
function ClubTestPick(action, titleKey)
    local result = Core.NormalizeResult(lib.callback.await('daddy_college:testkit:clubList', false, {}))
    if not result.ok then Core.HandleResult(result, 'testkit') return lib.showContext('testkit_club') end
    local items = {}
    for _, name in ipairs(result.clubs or {}) do
        items[#items + 1] = { title = name, icon = 'fa-solid fa-flag', onSelect = function() CreateThread(function() run(action, { club = name }, 'testkit_club') end) end }
    end
    if #items == 0 then items[1] = { title = t('testkit.club_none'), description = t('testkit.club_none_hint'), disabled = true } end
    lib.registerContext({ id = 'testkit_club_pick', title = t(titleKey), menu = 'testkit_club', options = items })
    lib.showContext('testkit_club_pick')
end

local function build()
    local roles = {}
    for _, role in ipairs({ 'student', 'teacher', 'principal', 'security', 'janitor', 'canteen', 'driver' }) do
        if Config.Roles.Hire and Config.Roles.Hire[role] then roles[#roles + 1] = button('role_' .. role, 'role', { role = role }, 'testkit_role', 'fa-solid fa-id-badge') end
    end
    menu('testkit_role', roles)

    menu('testkit_wish', {
        button('wish_fill', 'wishFill', nil, 'testkit_wish', 'fa-solid fa-tree'),
        button('wish_clear', 'wishClear', nil, 'testkit_wish', 'fa-solid fa-broom'),
        button('wish_night', 'wishNight', nil, 'testkit_wish', 'fa-solid fa-wand-sparkles'),
        button('wish_places', 'wishPlaces', nil, 'testkit_wish', 'fa-solid fa-location-dot'),
    })

    -- Club tables, in the order a test goes: status, bind a club, become its officer, open, close.
    local tcfg = Config.Affairs.Club.Table or {}
    local club = {
        { title = t('testkit.club_status'), description = t('testkit.club_status_hint'), icon = 'fa-solid fa-circle-info',
            onSelect = function() CreateThread(function() ClubTestStatus() end) end },
        { title = t('testkit.club_be_officer'), description = t('testkit.club_be_officer_hint'), icon = 'fa-solid fa-user-tie', arrow = true,
            onSelect = function() CreateThread(function() ClubTestPick('clubOfficer', 'testkit.club_be_officer') end) end },
        { title = t('testkit.club_bind'), description = t('testkit.club_bind_hint'), icon = 'fa-solid fa-link', arrow = true,
            onSelect = function() CreateThread(function() ClubTestPick('clubBind', 'testkit.club_bind') end) end },
        button('club_unbind', 'clubUnbind', nil, 'testkit_club', 'fa-solid fa-people-roof'),
        button('club_sample', 'clubSampleInterest', nil, 'testkit_club', 'fa-solid fa-users'),
    }
    local colors = {}
    for name in pairs(tcfg.ClothColors or {}) do colors[#colors + 1] = name end
    table.sort(colors)
    for _, name in ipairs(colors) do
        club[#club + 1] = { title = t('testkit.club_open', t('testkit.color_' .. name)), description = t('testkit.club_open_hint'), icon = 'fa-solid fa-flag',
            onSelect = function() CreateThread(function() run('clubOpen', { color = name }, 'testkit_club') end) end }
    end
    -- Sample logos (web/public/testlogos) on the nearest table's banner and cloth; it keeps the colour it is open in.
    local logos = {}
    for _, name in ipairs({ 'direction', 'sharpness', 'bars', 'transparent', 'photo', 'biggest', 'levels' }) do
        logos[#logos + 1] = { title = t('testkit.logo_' .. name), icon = 'fa-solid fa-image',
            onSelect = function() CreateThread(function() run('clubOpen', { logo = name }, 'testkit_club_logo') end) end }
    end
    lib.registerContext({ id = 'testkit_club_logo', title = t('testkit.club_logo'), menu = 'testkit_club', options = logos })
    club[#club + 1] = { title = t('testkit.club_logo'), description = t('testkit.club_logo_hint'), icon = 'fa-solid fa-image', menu = 'testkit_club_logo', arrow = true }
    club[#club + 1] = button('club_close', 'clubClose', nil, 'testkit_club', 'fa-solid fa-table')
    club[#club + 1] = button('club_close_all', 'clubClose', { all = true }, 'testkit_club', 'fa-solid fa-ban')
    menu('testkit_club', club)

    menu('testkit_janitor', {
        button('janitor_flood', 'janitor', { kind = 'flood' }, 'testkit_janitor', 'fa-solid fa-water'),
        button('janitor_power', 'janitor', { kind = 'power' }, 'testkit_janitor', 'fa-solid fa-bolt'),
        button('janitor_rat', 'janitor', { kind = 'rat' }, 'testkit_janitor', 'fa-solid fa-otter'),
        button('janitor_lawn', 'janitor', { kind = 'lawn' }, 'testkit_janitor', 'fa-solid fa-seedling'),
        button('janitor_close', 'janitorClose', nil, 'testkit_janitor', 'fa-solid fa-ban'),
    })

    menu('testkit_detention', {
        button('detention_give', 'detention', { minutes = 10, jobs = 3 }, 'testkit_detention', 'fa-solid fa-gavel'),
        button('detention_end', 'detentionEnd', nil, 'testkit_detention', 'fa-solid fa-unlock'),
    })

    menu('testkit_lesson', {
        button('lesson_start', 'lesson', nil, 'testkit_lesson', 'fa-solid fa-chalkboard-user'),
        button('lesson_me', 'lessonMe', nil, 'testkit_lesson', 'fa-solid fa-user-graduate'),
        button('quiz_bool', 'quizAsk', { kind = 'bool' }, 'testkit_lesson', 'fa-solid fa-circle-question'),
        button('quiz_single', 'quizAsk', { kind = 'single' }, 'testkit_lesson', 'fa-solid fa-list-ol'),
        button('quiz_open', 'quizAsk', { kind = 'open' }, 'testkit_lesson', 'fa-solid fa-pen'),
        button('lesson_end', 'lessonEnd', nil, 'testkit_lesson', 'fa-solid fa-bell'),
    })

    menu('testkit_cert', {
        button('cert_give', 'certGive', nil, 'testkit_cert', 'fa-solid fa-award'),
    })

    local sub = function(key, icon) return { title = t('testkit.menu_' .. key), description = t('testkit.menu_' .. key .. '_hint'), icon = icon, menu = 'testkit_' .. key, arrow = true } end
    menu('testkit', {
        sub('role', 'fa-solid fa-id-badge'),
        button('items', 'items', nil, 'testkit', 'fa-solid fa-box-open'),
        sub('wish', 'fa-solid fa-tree'),
        sub('club', 'fa-solid fa-flag'),
        sub('janitor', 'fa-solid fa-broom'),
        sub('detention', 'fa-solid fa-gavel'),
        sub('lesson', 'fa-solid fa-chalkboard-user'),
        button('paper', 'paper', nil, 'testkit', 'fa-solid fa-newspaper'),
        sub('cert', 'fa-solid fa-award'),
    })
end

RegisterCommand((Config.TestKitCommand or 'collegetest'), function()
    build()
    lib.showContext('testkit')
end, false)
