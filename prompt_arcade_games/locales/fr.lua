-- Français (fr) — prompt_arcade_games
return {
    title_space    = 'Space Monkey',
    title_wizard   = 'La Ruine du Sorcier',
    title_badlands = 'Badlands Revenge',
    title_rockets  = 'Race and Chase: Crotch Rockets',
    title_truckin  = 'Race and Chase: Get Truckin\'',
    title_street   = 'Race and Chase: Street Legal',
    title_love     = "Testeur d'Amour",
    title_claw     = 'Machine à Pince',
    title_fortune  = 'Nazar la Diseuse de Bonne Aventure',
    title_strength = 'Testeur de Force',

    target_space    = 'Jouer à Space Monkey',
    target_wizard   = 'Jouer à La Ruine du Sorcier',
    target_badlands = 'Jouer à Badlands Revenge',
    target_rockets  = 'Jouer à Crotch Rockets',
    target_truckin  = "Jouer à Get Truckin'",
    target_street   = 'Jouer à Street Legal',
    target_love     = 'Teste ton amour',
    target_claw     = 'Jouer à la machine à pince',
    target_fortune  = 'Demander ton avenir à Nazar',
    target_strength = 'Teste ta force',

    textui_prompt = '[E]  %s',

    menu_arcade   = 'ARCADE',
    menu_play     = '[E] JOUER',
    menu_playSolo = '[E] JOUER SEUL',
    menu_volume   = '[Haut] / [Bas]  VOLUME  %d%%',
    menu_leave    = '[Retour] QUITTER',
    menu_waitCoop = '...ou attends ici — un 2e joueur peut te rejoindre en coop',

    love_result   = "Testeur d'Amour :  %s",
    love_tookSide = "Testeur d'Amour — tu occupes le côté %s. En attente d'un partenaire...",
    love_sideLeft  = 'GAUCHE',
    love_sideRight = 'DROIT',
    love_walkUp   = "Approche-toi d'un Testeur d'Amour pour jouer.",
    loveRatings = {
        'GLACIAL', 'FROIDEUR', 'DÉGEL', 'MOITE', 'PLUS CHAUD',
        'ROUGISSANT', 'ÇA CHAUFFE', 'REINS BRÛLANTS', 'TORRIDE', 'INCANDESCENT',
    },

    fortune_stir   = 'Nazar frissonne... les esprits s\'agitent.',
    fortune_speaks = 'Nazar parle :  %s',

    strength_result = 'Testeur de Force :  %s  (%d)',
    strengthTiers = { 'CHÉTIF', 'DUR À CUIRE', 'COLOSSE', 'SONNE LA CLOCHE !' },

    menu_price   = '  —  $%d',
    textui_price = '[E]  %s  ($%d)',
    pay_denied   = 'Il te faut $%d pour jouer.',
    pay_error    = 'Paiement échoué — réessaie.',
    play_denied  = "Tu ne peux pas lancer ça d'ici.",
}
