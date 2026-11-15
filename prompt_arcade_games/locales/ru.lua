-- Русский (ru) — prompt_arcade_games
return {
    title_space    = 'Space Monkey',
    title_wizard   = 'Руины Волшебника',
    title_badlands = 'Badlands Revenge',
    title_rockets  = 'Race and Chase: Crotch Rockets',
    title_truckin  = 'Race and Chase: Get Truckin\'',
    title_street   = 'Race and Chase: Street Legal',
    title_love     = 'Тестер Любви',
    title_claw     = 'Автомат с Хватайкой',
    title_fortune  = 'Назар Предсказатель',
    title_strength = 'Силомер',

    target_space    = 'Играть в Space Monkey',
    target_wizard   = 'Играть в Руины Волшебника',
    target_badlands = 'Играть в Badlands Revenge',
    target_rockets  = 'Играть в Crotch Rockets',
    target_truckin  = "Играть в Get Truckin'",
    target_street   = 'Играть в Street Legal',
    target_love     = 'Проверить свою любовь',
    target_claw     = 'Играть в автомат с хватайкой',
    target_fortune  = 'Спросить судьбу у Назара',
    target_strength = 'Проверить свою силу',

    textui_prompt = '[E]  %s',

    menu_arcade   = 'АРКАДА',
    menu_play     = '[E] ИГРАТЬ',
    menu_playSolo = '[E] ИГРАТЬ ОДНОМУ',
    menu_volume   = '[Вверх] / [Вниз]  ГРОМКОСТЬ  %d%%',
    menu_leave    = '[Backspace] ВЫЙТИ',
    menu_waitCoop = '...или подожди здесь — 2-й игрок может присоединиться для кооператива',

    love_result   = 'Тестер Любви:  %s',
    love_tookSide = 'Тестер Любви — ты занял %s сторону. Ожидание партнёра...',
    love_sideLeft  = 'ЛЕВУЮ',
    love_sideRight = 'ПРАВУЮ',
    love_walkUp   = 'Подойди к Тестеру Любви, чтобы сыграть.',
    loveRatings = {
        'ЛЕДЯНОЙ ХОЛОД', 'ХОЛОДНОЕ ПЛЕЧО', 'ОТТЕПЕЛЬ', 'ЛИПКИЕ ЛАДОНИ', 'ТЕПЛЕЕ',
        'РУМЯНЕЦ', 'СТАНОВИТСЯ ЖАРКО', 'ПЫЛАЮЩАЯ СТРАСТЬ', 'ЖАРКО И СТРАСТНО', 'РАСКАЛЁННЫЙ',
    },

    fortune_stir   = 'Назар вздрагивает... духи зашевелились.',
    fortune_speaks = 'Назар говорит:  %s',

    strength_result = 'Силомер:  %s  (%d)',
    strengthTiers = { 'СЛАБАК', 'КРЕПКИЙ ОРЕШЕК', 'СИЛАЧ', 'ЗВОНИ В КОЛОКОЛ!' },

    menu_price   = '  —  $%d',
    textui_price = '[E]  %s  ($%d)',
    pay_denied   = 'Нужно $%d, чтобы сыграть.',
    pay_error    = 'Оплата не прошла — попробуй ещё раз.',
    play_denied  = 'Отсюда это не запустить.',
}
