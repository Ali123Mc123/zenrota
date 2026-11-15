Config = {}

Config.Command = 'kolejtur'   -- /kolejtur: next stop, /kolejtur 5: stop 5, /kolejtur kapat: ends the markers
Config.Aces = { 'command', 'admin', 'daddy.admin', 'daddy.college.admin' } -- any one of these opens the tour
Config.MarkerDistance = 30.0  -- markers of the moved points are drawn this close (m)
Config.LabelDistance = 5.0    -- and their names this close
Config.LoadMs = 6000          -- longest wait for the floor under a stop
Config.NoticeMs = 15000

Config.Text = {
    denied = 'Bu komut için yetkin yok (command, admin ya da daddy.admin gerekir).',
    usage = '/kolejtur [durak no], boş: sıradaki durak, /kolejtur kapat: işaretleri kapatır',
    stop = 'Durak %d/%d: %s',
    closeWord = 'kapat',
    closed = 'Kolej turu kapandı.',
}

-- Marker colours by kind: lockers blue, boards green, classrooms orange, discipline red, doors brown, easels purple,
-- the new outside places white, everything else grey.
Config.Colors = {
    locker = { 40, 120, 230 }, board = { 30, 200, 110 }, room = { 245, 140, 30 }, discipline = { 230, 50, 50 },
    door = { 160, 100, 50 }, easel = { 170, 90, 220 }, new = { 255, 255, 255 }, other = { 150, 150, 150 },
}

-- Stops in walking order: the campus outside, the ground floor, up, down, then the outside places.
Config.Stops = {
    { label = 'Spawn: ana merdivenin önü', coords = vec4(5318.610, -5263.894, 30.868, 326.0), check = 'Öğrenci ve öğretmenler burada doğuyor. Zemine düzgün basıyor mu?' },
    { label = 'Servis durağı', coords = vec4(5315.662, -5302.007, 32.070, 16.0), check = 'Durak görevlisi durak cebinde mi, inen oyuncu kaldırımda mı?' },
    { label = 'Öğrenci İşleri masası', coords = vec4(5337.340, -5236.230, 32.000, 326.0), check = 'Görevli masanın arkasında mı? Kayıt testi noktası masanın önünde mi?' },
    { label = 'Ana kapı: ATM, dart, şişe', coords = vec4(5313.214, -5247.409, 32.160, 236.0), check = 'ATM ve iki dart tahtası duvarda, şişe yeri yerde mi?' },
    { label = 'Kantin ve otomatlar', coords = vec4(5360.194, -5232.762, 32.081, 340.3), check = 'Kantinci tezgâhta mı? Otomatlar duvara oturmuş mu?' },
    { label = 'Revir', coords = vec4(5338.937, -5250.331, 32.037, 186.3), check = 'Hemşire ve yatak yerinde mi?' },
    { label = 'Disiplin odası (depo)', coords = vec4(5321.339, -5224.991, 32.019, 324.5), check = 'Ceza odası, çıkış ve 10 görev noktası depoda mı?' },
    { label = 'Zemin kat dolapları', coords = vec4(5324.215, -5249.688, 32.281, 235.0), check = 'Dolap işaretleri dolap kapılarının önünde mi? Bir dolabı aç.' },
    { label = 'Asansör: zemin kat', coords = vec4(5317.564, -5227.938, 31.994, 244.9), check = 'Asansörü dene: her kat ve tiyatro durağı.' },
    { label = '1. kat: Fen Bilimleri (Tahta 1)', coords = vec4(5352.196, -5238.396, 37.936, 0.0), check = 'Tahta beyaz tahtanın üstünde mi? F dersliği burada.' },
    { label = '1. kat: Görsel Sanatlar (şövaleler)', coords = vec4(5338.994, -5255.774, 37.961, 0.0), check = '10 şövale yerinde mi?' },
    { label = '1. kat: Müzik (Tahta 2) ve dolaplar', coords = vec4(5329.917, -5224.878, 37.962, 0.0), check = 'Tahta 2 ve 1. kat dolapları.' },
    { label = '2. kat: müdür, öğretmenler, kıyafet', coords = vec4(5321.627, -5247.973, 43.814, 329.5), check = 'Müdür ve öğretmenler odası kapı kilitleri, kıyafet 3 ve berber 3.' },
    { label = 'Alt kat: Bilgisayar ve Rehberlik', coords = vec4(5317.323, -5240.291, 26.198, 0.0), check = 'J ve H derslikleri, alt kat dolapları.' },
    { label = 'Alt kat: Gazetecilik (Tahta 7)', coords = vec4(5333.716, -5197.025, 26.198, 0.0), check = 'Tahta 7 duvarda mı?' },
    { label = 'Alt kat: Mekanik atölyesi', coords = vec4(5382.141, -5228.006, 26.351, 0.0), check = 'Kolej Mekanik, parça, depo, Garaj Kolej, Tahta 5 ve 6. Garajdan araç çıkar.' },
    { label = 'Spor katı: bilardo', coords = vec4(5339.365, -5227.138, 21.727, 0.0), check = 'Bilardo masaları ve ıstaka rafları yerde mi?' },
    { label = 'Spor katı: boks salonu ve dojo', coords = vec4(5353.466, -5253.175, 21.664, 0.0), check = 'Dojo hocası, boks kapısı, mahzen kilidi.' },
    { label = 'Spor salonu', coords = vec4(5370.225, -5181.590, 15.127, 0.0), check = 'P dersliği.' },
    { label = 'Tiyatro', coords = vec4(5312.447, -5265.804, 17.082, 0.0), check = 'I dersliği, sahne arkasında kıyafet 1-2 ve berber 1-2.' },
    { label = 'Aşçılık atölyesi', coords = vec4(5303.150, -5202.335, 19.742, 0.0), check = 'K dersliği.' },
    { label = 'Fitness pedi', coords = vec4(5393.230, -5287.500, 32.000, 56.0), check = 'Antrenör, bench, mekik, dumbbell, kum torbası, bilek güreşi.' },
    { label = 'Sahne', coords = vec4(5397.417, -5241.228, 33.020, 146.0), check = 'Sahne mikrofonu.' },
    { label = 'Dilek ağacı', coords = vec4(5302.945, -5193.515, 32.122, 0.0), check = 'Ağaç çemberin ortasında mı?' },
    { label = 'Otopark (Garaj 66)', coords = vec4(5346.483, -5316.573, 32.050, 218.4), check = 'Garaj noktası ve araç çıkışı.' },
}
