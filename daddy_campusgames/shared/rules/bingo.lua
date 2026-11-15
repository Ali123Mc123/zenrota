-- 75-ball bingo with no game natives: cards, patterns, how far a card is from a pattern, prize shares and the host's
-- programme. random(n) gives 1..n. A card is 5 x 5 under B I N G O; the middle square (0) is free.
GameRules = GameRules or {}
local Bingo = {}
GameRules.bingo = Bingo

Bingo.SIZE = 75
Bingo.LETTERS = { 'B', 'I', 'N', 'G', 'O' }

-- Patterns as 5 x 5 masks (rows split by /, X = needed); a pattern with several masks is won by any one of them.
local MASKS = {
    corners = { 'X...X/...../...../...../X...X' },
    stamp = { 'XX.../XX.../...../...../.....', '...XX/...XX/...../...../.....', '...../...../...../XX.../XX...', '...../...../...../...XX/...XX' },
    x = { 'X...X/.X.X./..X../.X.X./X...X' },
    plus = { '..X../..X../XXXXX/..X../..X..' },
    arrow = { '..X../.X.../XXXXX/.X.../..X..' },
    tee = { 'XXXXX/..X../..X../..X../..X..' },
    frame = { 'XXXXX/X...X/X...X/X...X/XXXXX' },
    full = { 'XXXXX/XXXXX/XXXXX/XXXXX/XXXXX' },
    small_frame = { '...../.XXX./.X.X./.XXX./.....' },
    diamond = { '..X../.X.X./X...X/.X.X./..X..' },
    kite = { 'XXX../XXX../XXX../...X./....X', '..XXX/..XXX/..XXX/.X.../X....', 'X..../.X.../XXX../XXX../XXX..', '....X/...X./..XXX/..XXX/..XXX' },
    ladder = { 'X..../XX.../.XX../..XX./...XX', '....X/...XX/..XX./.XX../XX...' },
    heart = { '.X.X./XXXXX/XXXXX/.XXX./..X..' },
    tree = { '..X../.XXX./XXXXX/..X../.XXX.' },
    letter_b = { 'XXXX./X...X/XXXX./X...X/XXXX.' },
    letter_i = { 'XXXXX/..X../..X../..X../XXXXX' },
    letter_n = { 'X...X/XX..X/X.X.X/X..XX/X...X' },
    letter_g = { '.XXXX/X..../X..XX/X...X/.XXX.' },
    letter_o = { '.XXX./X...X/X...X/X...X/.XXX.' },
    letter_h = { 'X...X/X...X/XXXXX/X...X/X...X' },
    letter_l = { 'X..../X..../X..../X..../XXXXX' },
    letter_u = { 'X...X/X...X/X...X/X...X/XXXXX' },
    letter_z = { 'XXXXX/...X./..X../.X.../XXXXX' },
    line = {},
    double = {},
}
for i = 1, 5 do
    local row, col = {}, {}
    for j = 1, 5 do
        row[j] = i == j and 'XXXXX' or '.....'
        col[j] = ('.'):rep(i - 1) .. 'X' .. ('.'):rep(5 - i)
    end
    MASKS.line[#MASKS.line + 1] = table.concat(row, '/')
    MASKS.line[#MASKS.line + 1] = table.concat(col, '/')
end
MASKS.line[11], MASKS.line[12] = 'X..../.X.../..X../...X./....X', '....X/...X./..X../.X.../X....'

-- Two lines: every pair of the twelve lines as one mask.
local function union(a, b)
    local out = {}
    for i = 1, #a do out[i] = (a:sub(i, i) == 'X' or b:sub(i, i) == 'X') and 'X' or a:sub(i, i) end
    return table.concat(out)
end
for i = 1, #MASKS.line do
    for j = i + 1, #MASKS.line do MASKS.double[#MASKS.double + 1] = union(MASKS.line[i], MASKS.line[j]) end
end

Bingo.PATTERNS = { 'line', 'double', 'corners', 'stamp', 'small_frame', 'x', 'plus', 'arrow', 'tee', 'diamond', 'kite', 'ladder', 'frame',
    'full', 'heart', 'tree', 'letter_b', 'letter_i', 'letter_n', 'letter_g', 'letter_o', 'letter_h', 'letter_l', 'letter_u', 'letter_z' }

-- Each pattern's masks as lists of { row, column } cells.
local SHAPES = {}
for name, masks in pairs(MASKS) do
    SHAPES[name] = {}
    for k, mask in ipairs(masks) do
        local cells, r = {}, 1
        for line in mask:gmatch('[^/]+') do
            for c = 1, 5 do
                if line:sub(c, c) == 'X' then cells[#cells + 1] = { r, c } end
            end
            r = r + 1
        end
        SHAPES[name][k] = cells
    end
end
Bingo.MASKS = MASKS

local function shuffle(list, random)
    for i = #list, 2, -1 do
        local j = random(i)
        list[i], list[j] = list[j], list[i]
    end
    return list
end

local function has(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

-- The bag: 1..75 in random order.
function Bingo.bag(random)
    local list = {}
    for n = 1, Bingo.SIZE do list[n] = n end
    return shuffle(list, random)
end

-- The letter of a number (B for 1-15 ... O for 61-75).
function Bingo.letter(n) return Bingo.LETTERS[math.ceil(n / 15)] end

-- A card: column c holds five of (c-1)*15+1..c*15, the middle square is free (0).
function Bingo.card(random)
    local rows = { {}, {}, {}, {}, {} }
    for c = 1, 5 do
        local pool = {}
        for n = (c - 1) * 15 + 1, c * 15 do pool[#pool + 1] = n end
        shuffle(pool, random)
        for r = 1, 5 do rows[r][c] = pool[r] end
    end
    rows[3][3] = 0
    return { rows = rows }
end

-- Numbers a card still needs for a pattern (its closest mask). marked = { [n] = true }: the numbers that count.
function Bingo.need(rows, marked, pattern)
    local best = math.huge
    for _, cells in ipairs(SHAPES[pattern] or SHAPES.full) do
        local m = 0
        for _, cell in ipairs(cells) do
            local n = rows[cell[1]][cell[2]]
            if n ~= 0 and not marked[n] then m = m + 1 end
        end
        if m < best then best = m end
    end
    return best
end

-- The goals of a game: its one pattern.
function Bingo.goals(game) return { game.pattern } end

-- An amount shared by n winners: each share (whole money) and what is left over.
function Bingo.split(amount, n)
    if n < 1 then return 0, amount end
    local share = math.floor(amount / n)
    return share, amount - share * n
end

-- A host's programme checked against the limits { MaxGames, MaxCards, MaxPrize, Speed = { Min, Max, Default } }.
-- cards = the most cards a player may hold. -> clean copy | nil, the field that failed ('games', 'games.2.pattern', ...)
function Bingo.cleanProgram(program, limits)
    if type(program) ~= 'table' or #program < 1 or #program > limits.MaxGames then return nil, 'games' end
    local out = {}
    for i, g in ipairs(program) do
        local at = 'games.' .. i
        if type(g) ~= 'table' or not has(Bingo.PATTERNS, g.pattern) then return nil, at .. '.pattern' end
        local game = { kind = 'bingo', pattern = g.pattern, prizes = {} }
        local cards = math.floor(tonumber(g.cards) or 0)
        if cards < 1 or cards > limits.MaxCards then return nil, at .. '.cards' end
        game.cards = cards
        local amount = math.floor(tonumber(type(g.prizes) == 'table' and g.prizes[g.pattern]) or 0)
        if amount < 0 or amount > limits.MaxPrize then return nil, at .. '.prizes' end
        game.prizes[g.pattern] = amount
        local speed = math.floor(tonumber(g.speed) or limits.Speed.Default)
        if speed < limits.Speed.Min or speed > limits.Speed.Max then return nil, at .. '.speed' end
        game.speed, game.auto = speed, g.auto == true
        out[i] = game
    end
    return out
end

-- All the prize money a programme promises.
function Bingo.total(program)
    local sum = 0
    for _, game in ipairs(program) do
        for _, amount in pairs(game.prizes) do sum = sum + amount end
    end
    return sum
end
