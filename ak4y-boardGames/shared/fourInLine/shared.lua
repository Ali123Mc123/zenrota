connect4Config = {}

connect4Config.TableModel = 'boardgame_table'
connect4Config.ChairModel = 'prop_table_04_chr'
connect4Config.BoardModel = 'connect4_board'
connect4Config.RedChipModel = 'connect4_chip_red'
connect4Config.YellowChipModel = 'connect4_chip_yellow'

connect4Config.Tables = {
    [2] = { coords = vec4(-1453.17, -1053.09, 3.07, 230.22), price = 500, requiredResource = "AuraStudio-GameYard" },
}

if connect4Config.Tables and FilterRequiredResourceSpawns then
    connect4Config.Tables = FilterRequiredResourceSpawns(connect4Config.Tables)
end
