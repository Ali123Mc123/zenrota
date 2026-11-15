-- Typed guesses, with no game natives: Turkish and other accented letters folded to plain ones, case, spaces and
-- punctuation ignored, one wrong letter forgiven in a word of seven letters or more.
GameRules = GameRules or {}
local Words = {}
GameRules.words = Words

local FOLD = {
    ['ç'] = 'c', ['Ç'] = 'c', ['ğ'] = 'g', ['Ğ'] = 'g', ['ı'] = 'i', ['İ'] = 'i', ['ö'] = 'o', ['Ö'] = 'o', ['ş'] = 's', ['Ş'] = 's',
    ['ü'] = 'u', ['Ü'] = 'u', ['â'] = 'a', ['Â'] = 'a', ['î'] = 'i', ['û'] = 'u', ['é'] = 'e', ['è'] = 'e', ['ê'] = 'e', ['ë'] = 'e',
    ['á'] = 'a', ['à'] = 'a', ['ä'] = 'a', ['í'] = 'i', ['ó'] = 'o', ['ú'] = 'u', ['ñ'] = 'n',
}

function Words.fold(text)
    if type(text) ~= 'string' then return '' end
    text = text:gsub('[\194-\244][\128-\191]+', function(ch) return FOLD[ch] or '' end)
    return (text:lower():gsub('[^%w]', ''))
end

-- Edits between two short plain words.
local function distance(a, b)
    local prev = {}
    for j = 0, #b do prev[j] = j end
    for i = 1, #a do
        local cur = { [0] = i }
        for j = 1, #b do
            cur[j] = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a:byte(i) == b:byte(j) and 0 or 1))
        end
        prev = cur
    end
    return prev[#b]
end

-- Whether a guess names one of the answers.
function Words.match(guess, answers)
    local g = Words.fold(guess)
    if g == '' or #g > 40 then return false end
    for _, answer in ipairs(answers) do
        local a = Words.fold(answer)
        if g == a or (#a >= 7 and math.abs(#a - #g) <= 1 and distance(g, a) <= 1) then return true end
    end
    return false
end

-- A short line of text from a player, or nil.
function Words.line(text, max)
    if type(text) ~= 'string' or not utf8.len(text) then return nil end
    text = text:gsub('%c', ' '):gsub('%s+', ' '):gsub('^ ', ''):gsub(' $', '')
    local cut = utf8.offset(text, (max or 40) + 1)
    if cut then text = text:sub(1, cut - 1) end
    return text ~= '' and text or nil
end
