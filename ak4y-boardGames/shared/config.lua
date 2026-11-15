Config = {}
Config.AdminCommand = "boardGames"

Config.Commands = {
    remove_table = "removeBoardTable",
    stats = "boardgamesStats"
}

Config.locales = {}
Config.Locale = "tr"

function getLocale(game, index, key)
    return Config.locales[Config.Locale][game][index][key]
end

Config.Items = {
    ['boardgame_fourinline'] = {
        name = 'boardgame_fourinline',
        model = 'boardgame_table',
        game = 'connect4',
        price = 0
    },
    ['boardgame_chess'] = {
        name = 'boardgame_chess',
        model = 'boardgame_table',
        game = 'chess',
        price = 0
    },
    ['boardgame_checkers'] = {
        name = 'boardgame_checkers',
        model = 'boardgame_table',
        game = 'checkers',
        price = 0
    },
    ['boardgame_towerblocks'] = {
        name = 'boardgame_towerblocks',
        model = 'boardgame_table',
        game = 'jengo',
        price = 0
    },
    ['boardgame_armwrestling'] = {
        name = 'boardgame_armwrestling',
        model = 'prop_arm_wrestle_01',
        game = 'armwrestling',
        price = 0
    },
    ['boardgame_truthordare'] = {
        name = 'boardgame_truthordare',
        model = 'prop_amb_beer_bottle',
        game = 'truthordare'
    },
    ['boardgame_santostycoon'] = {
        name = 'boardgame_santostycoon',
        model = 'bkr_prop_fakeid_table',
        game = 'santosPoly',
        price = 0
    },
    ['boardgame_colormatch'] = {
        name = 'boardgame_colormatch',
        model = 'boardgame_table',
        game = 'eno',
        price = 0
    },
    ['boardgame_whoami'] = {
        name = 'boardgame_whoami',
        model = 'guesswho_prop',
        game = 'guessWho'
    },
    ['boardgame_rodeo'] = {
        name = 'boardgame_rodeo',
        model = 'rodeo_stand',
        game = 'rodeo',
        price = 0
    },
    ['boardgame_xox'] = {
        name = 'boardgame_xox',
        model = 'boardgame_table',
        game = 'xox',
        price = 0
    },
    ['boardgame_basketball'] = {
        name = 'boardgame_basketball',
        model = 'ak4y-gc-bbolmachine',
        game = 'basketball',
        price = 0
    },
    ['boardgame_boxmachine'] = {
        name = 'boardgame_boxmachine',
        model = 'aura-gc-boxing',
        game = 'boxmachine',
        price = 0
    }
}

Config.SeasonSettings = {
    DurationDays = 30 -- Season length in days
}

--You can adjust on locales.
Config.TruthOrDare = {
    TruthQuestions = {
        "truth_1", "truth_2", "truth_3", "truth_4", "truth_5",
        "truth_6", "truth_7", "truth_8", "truth_9", "truth_10",
        "truth_11", "truth_12", "truth_13", "truth_14", "truth_15"
    },
    DareTasks = {
        "dare_1", "dare_2", "dare_3", "dare_4", "dare_5",
        "dare_6", "dare_7", "dare_8", "dare_9", "dare_10",
        "dare_11", "dare_12", "dare_13", "dare_14", "dare_15"
    }
}
Config.TableModels = {
    { color = "wood", model = "boardgame_table" },
    { color = "blue", model = "boardgame_table_blue" },
    { color = "green", model = "boardgame_table_green" },
    { color = "ocean blue", model = "boardgame_table_oceanblue" },
    { color = "orange", model = "boardgame_table_orange" },
    { color = "red", model = "boardgame_table_red" },
    { color = "yellow", model = "boardgame_table_yellow" }
}

Config.Blips = {}

function FilterRequiredResourceSpawns(spawns)
    if not spawns or type(spawns) ~= "table" then return spawns end
    
    local keys = {}
    for k in pairs(spawns) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
            return a < b
        elseif type(a) == "number" then
            return true
        elseif type(b) == "number" then
            return false
        else
            return tostring(a) < tostring(b)
        end
    end)

    local filtered = {}
    for _, k in ipairs(keys) do
        local v = spawns[k]
        local allowed = true
        if v and type(v) == "table" and v.requiredResource then
            if type(v.requiredResource) == "string" and v.requiredResource ~= "" then
                local state = GetResourceState(v.requiredResource)
                if state ~= "started" and state ~= "starting" then
                    allowed = false
                end
            elseif type(v.requiredResource) == "table" then
                for _, res in ipairs(v.requiredResource) do
                    local state = GetResourceState(res)
                    if state ~= "started" and state ~= "starting" then
                        allowed = false
                        break
                    end
                end
            end
        end
        if allowed then
            if type(k) == "number" then
                table.insert(filtered, v)
            else
                filtered[k] = v
            end
        end
    end
    return filtered
end

if Config.Blips then
    Config.Blips = FilterRequiredResourceSpawns(Config.Blips)
end
