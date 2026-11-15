--- Starts the maze game.
--- @param callback function: Callback function to handle the result of the game (true for success, false for failure).
--- @param speed number|nil: Time duration of the game in seconds. Defaults to 10 seconds if nil.
local function Maze(callback, speed)
    if speed == nil then speed = 10 end  -- Default to 10 seconds if speed is nil
    DebugPrint("Maze called with " .. speed .. " speed")
    SendNUI("GameLauncher", callback, {
        game = "NumberMaze",  -- Name of the game
        gameName = "Sayı Labirenti",  -- Display name of the game
        gameDescription = "Sayı Labirenti'nde yeteneğini sına! Zamana karşı yarışıp doğru diziyi bul. Süre bitmeden çözebilecek misin?",  -- Description of the game
        gameTime = speed,  -- Time duration of the game
        triggerEvent = 'maze-callback',  -- Event to trigger on completion
        maxAnswersIncorrect = 2,  -- Maximum number of incorrect answers allowed
    }, true)
end
exports("Maze", Maze)