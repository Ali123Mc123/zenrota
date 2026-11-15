-- Português (pt) — prompt_arcade_games
return {
    title_space    = 'Space Monkey',
    title_wizard   = 'A Ruína do Feiticeiro',
    title_badlands = 'Badlands Revenge',
    title_rockets  = 'Race and Chase: Crotch Rockets',
    title_truckin  = 'Race and Chase: Get Truckin\'',
    title_street   = 'Race and Chase: Street Legal',
    title_love     = 'Medidor do Amor',
    title_claw     = 'Máquina de Garra',
    title_fortune  = 'Nazar o Vidente',
    title_strength = 'Medidor de Força',

    target_space    = 'Jogar Space Monkey',
    target_wizard   = 'Jogar A Ruína do Feiticeiro',
    target_badlands = 'Jogar Badlands Revenge',
    target_rockets  = 'Jogar Crotch Rockets',
    target_truckin  = "Jogar Get Truckin'",
    target_street   = 'Jogar Street Legal',
    target_love     = 'Testa o teu amor',
    target_claw     = 'Jogar na máquina de garra',
    target_fortune  = 'Pede a tua sorte ao Nazar',
    target_strength = 'Testa a tua força',

    textui_prompt = '[E]  %s',

    menu_arcade   = 'ARCADE',
    menu_play     = '[E] JOGAR',
    menu_playSolo = '[E] JOGAR SOZINHO',
    menu_volume   = '[Cima] / [Baixo]  VOLUME  %d%%',
    menu_leave    = '[Backspace] SAIR',
    menu_waitCoop = '...ou espera aqui — um 2º jogador pode juntar-se em coop',

    love_result   = 'Medidor do Amor:  %s',
    love_tookSide = 'Medidor do Amor — ocupaste o lado %s. À espera de um parceiro...',
    love_sideLeft  = 'ESQUERDO',
    love_sideRight = 'DIREITO',
    love_walkUp   = 'Aproxima-te de um Medidor do Amor para jogar.',
    loveRatings = {
        'GELADO', 'OMBRO FRIO', 'A DESCONGELAR', 'SUADO', 'MAIS QUENTE',
        'CORADO', 'A AQUECER', 'DESEJO ARDENTE', 'MUITO QUENTE', 'ESCALDANTE',
    },

    fortune_stir   = 'Nazar estremece... os espíritos agitam-se.',
    fortune_speaks = 'Nazar fala:  %s',

    strength_result = 'Medidor de Força:  %s  (%d)',
    strengthTiers = { 'FRACOTE', 'DURÃO', 'BRUTAMONTES', 'TOCA O SINO!' },

    menu_price   = '  —  $%d',
    textui_price = '[E]  %s  ($%d)',
    pay_denied   = 'Precisas de $%d para jogar.',
    pay_error    = 'Pagamento falhou — tenta outra vez.',
    play_denied  = 'Não podes começar isso a partir daqui.',
}
