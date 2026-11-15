Config = {
    GeneralDebug = false, -- Enables or disables debugging.
    UseLeaderboard = true, -- Enables or disables the use of a leaderboard to track players' table tennis scores.
    EnableBetting = true, -- Allows or disallows betting on table tennis matches.
    BettingInventoryName = nil, -- "money", etc. Specifies the name of the in-game currency that players can use to bet on table tennis matches.
    MinBet = 1000, -- Specifies the minimum amount of in-game currency players can bet on their table tennis match.
    MaxBet = 25000, -- Sets the maximum amount of in-game currency that players can bet on a table tennis match.
    BetStep = 1000, -- Determines the increment step for adjusting the bet amount during betting.
    PlayerIdentifier = "license", -- Identifies the player using their license or a specified identifier.

    Keys = {
        ActionKey = 38, -- Key code for performing actions in the game.
        LeaveKey = 177, -- Key code for leaving the table tennis game.
        MouseLock = 244, -- Key code for locking/unlocking the mouse during gameplay.
        RequestTop = 182, -- Key code for requesting the top players' scores.
        CameraTilt = 26 -- Key code for tilting the in-game camera.
    },
    -- All key codes can be found at: https://docs.fivem.net/docs/game-references/controls/

    -- Target
    UseTarget = true, -- whether to use target zones or not
    TargetZoneType = 4, -- 1: q_target, 2: bt_target, 3: qb-target, 4: ox_target

    Locale = "tr", -- Sets the language/locale for in-game text and messages. Check `translation.lua` for available locales.
    SpawnDistance = 30.0, -- Sets the maximum distance at which table tennis objects (specified in "Objects") can spawn from the player. If the player's distance exceeds this value, the tables will despawn.
    UseRoutingBuckets = false, -- Enables or disables the use of routing buckets for table tennis objects. When enabled, tables will only be visible to players in the same routing bucket.

    -- Enable rcore_stats? (https://store.rcore.cz/package/6273968)
    Rcore_Stats = GetResourceState("rcore_stats") ~= "missing",

    -- Spawns the table tennis objects in the game world.
    -- Color variations can be found at: https://documentation.rcore.cz/paid-resources/rcore_pingpong/spawning-a-pong-table
    Objects = {},

    -- daddy-games dinamik masa senkronizasyonu
    SyncTablesFromGameProps = function()
        pcall(function()
            local gamesExport = exports['daddy-games'] or exports['rcore_gameprops']
            if gamesExport and gamesExport.GetTablesByType then
                local extra = gamesExport:GetTablesByType('pingpong')
                if extra and #extra > 0 then
                    for _, t in ipairs(extra) do
                        local exists = false
                        for _, obj in ipairs(Config.Objects) do
                            if #(obj.pos - t.pos) < 1.0 then exists = true break end
                        end
                        if not exists then
                            Config.Objects[#Config.Objects + 1] = {
                                pos = t.pos,
                                heading = t.heading,
                                model = t.model or "prop_table_tennis",
                                routingBucket = 0
                            }
                        end
                    end
                end
            end
        end)
    end,

    -- Models that are used for games against AI.
    AIModels = {
        "mp_f_deadhooker",
        "s_f_y_hooker_01",
        "s_f_y_movprem_01",
        "s_m_y_baywatch_01",
        "s_m_y_clown_01",
        "s_m_y_mime",
        "ig_amandatownley",
        "ig_denise",
        "ig_djblamryans",
        "ig_kerrymcintosh",
        "ig_lifeinvad_01",
        "ig_money",
    },
    -- All models can be found at: https://docs.fivem.net/docs/game-references/ped-models/

    -- Framework
    ESXResourceName = "es_extended",
    QBCoreResourceName = "qb-core"
}
