-- Türkçe (tr) — prompt_arcade_games
-- %s / %d yer tutucularını koruyun ve aynı sırada bırakın.
return {
    -- ── Kabin adları (oyun öncesi menü + skor tablosu başlığı) ──────────────────────
    title_space    = 'Space Monkey',
    title_wizard   = "The Wizard's Ruin",
    title_badlands = 'Badlands Revenge',
    title_rockets  = 'Race and Chase: Crotch Rockets',
    title_truckin  = "Race and Chase: Get Truckin'",
    title_street   = 'Race and Chase: Street Legal',
    title_love     = 'Aşk Ölçer',
    title_claw     = 'Pençe Makinesi',
    title_fortune  = 'Falcı Nazar',
    title_strength = 'Güç Ölçer',

    -- ── Etkileşim etiketleri (ox_target / qb-target ve yerleşik Text UI) ─────────────
    target_space    = 'Space Monkey Oyna',
    target_wizard   = "The Wizard's Ruin Oyna",
    target_badlands = 'Badlands Revenge Oyna',
    target_rockets  = 'Crotch Rockets Oyna',
    target_truckin  = "Get Truckin' Oyna",
    target_street   = 'Street Legal Oyna',
    target_love     = 'Aşkını ölç',
    target_claw     = 'Pençe makinesini oyna',
    target_fortune  = 'Nazar\'a falına bak',
    target_strength = 'Gücünü ölç',

    -- ── Text UI (yalnızca ox_target / qb-target yoksa) ───────────────────────────────
    textui_prompt = '[E]  %s',

    -- ── Kabin üzerindeki oyun öncesi menü ───────────────────────────────────────────
    menu_arcade   = 'ATARİ',
    menu_play     = '[E] OYNA',
    menu_playSolo = '[E] TEK BAŞINA OYNA',
    menu_volume   = '[Yukarı] / [Aşağı]  SES  %d%%',
    menu_leave    = '[Backspace] AYRIL',
    menu_waitCoop = '...ya da burada bekle — ikinci bir oyuncu bu kabine katılıp birlikte oynayabilir',

    -- ── Aşk Ölçer ───────────────────────────────────────────────────────────────────
    love_result   = 'Aşk Ölçer:  %s',
    love_tookSide = 'Aşk Ölçer — %s tarafı aldın. Partner bekleniyor...',
    love_sideLeft  = 'SOL',
    love_sideRight = 'SAĞ',
    love_walkUp   = 'Oynamak için bir Aşk Ölçer\'e yaklaş.',
    -- soğuktan sıcağa ölçek (tam 10 adet, en soğuk ilk)
    loveRatings = {
        'BUZ GİBİ', 'SOĞUK OMUZ', 'ÇÖZÜLÜYOR', 'ELLER TERLEDİ', 'ISINIYOR',
        'KIZARDI', 'BUHARLANIYOR', 'YANIP TUTUŞUYOR', 'ATEŞ GİBİ', 'CIZIRDIYOR',
    },

    -- ── Falcı Nazar ─────────────────────────────────────────────────────────────────
    fortune_stir   = 'Nazar ürperiyor... ruhlar kıpırdanıyor.',
    fortune_speaks = 'Nazar diyor ki:  %s',

    -- ── Güç Ölçer ───────────────────────────────────────────────────────────────────
    strength_result = 'Güç Ölçer:  %s  (%d)',
    -- tam 4 adet, en zayıf ilk
    strengthTiers = { 'CILIZ', 'SERT ÇOCUK', 'HE-MAN', 'ZİLİ ÇAL!' },

    -- ── Oyun başı ücret (yalnızca payment.enabled ise) ───────────────────────────────
    menu_price   = '  —  $%d',
    textui_price = '[E]  %s  ($%d)',
    pay_denied   = 'Oynamak için $%d gerekiyor.',
    pay_error    = 'Ödeme başarısız — tekrar dene.',
    play_denied  = 'Bunu buradan başlatamazsın.',
}
