Config = Config or {}

Config.Locales = {
    shared = {
        allStagesCompleted = 'Tüm Aşamalar Tamamlandı',
        stage = 'Aşama',
        completed = 'Tamamlandı',
        failed = 'Aşama Kaybedildi',
    },
    sequence = {
        instructions = 'Ok tuşları veya WASD ile ızgaradaki diziyi bul. Seçmek için Enter\'a bas.',
        findSequenceLabel = 'Bu diziyi bul:',
    },
    aimIt = {
        instructions = 'Hedeflere tıklayarak vur!',
    },
    matchIt = {
        instructions = 'Gelen karelerin renklerini doğru bölmelerle eşleştirmek için çemberi döndür!',
        controls = {
            rotate = 'Çemberi döndürmek için A/D veya ← → kullan',
        },
    },
    destroyLinks = {
        instructions = 'Alttaki blokları yok etmek için doğru ok tuşlarına bas!',
    },
    electricalBox = {
        instructions = 'Sisteme elektriği geri vermek için şalterleri aç/kapat!',
        sequenceLabel = 'DİZİ:',
        hiddenLabel = 'GİZLİ',
        targetLabel = 'HEDEF:',
        stepLabel = 'ADIM:',
        currentLabel = 'MEVCUT:',
        offLabel = 'KAPALI',
        onLabel = 'AÇIK',
    },
    cutIt = {
        instructions = 'İşaretli kabloları bulmak için gösterme aletini YAVAŞÇA hareket ettir, sonra kesiciyle kes! Çok hızlı hareket edersen tespit edemezsin.',
    },
    reach = {
        instructions = 'Daireyi duvarlara çarpmadan başlangıçtan bitişe sürükle!',
    },
    pairs = {
        instructions = 'Kartlara tıklayıp çevirerek tüm eşleri bul. Yerlerini aklında tut!',
    },
    onTheDot = {
        instructions = 'Düşen topların renklerini saptırıcılarınla eşleştir - yan topları uzaklaştırmak için SPACE\'e bas!',
    },
    stickIt = {
        instructions = 'Dönen çembere, mevcut iğnelere değdirmeden iğne fırlat. Fırlatmak için tıkla!',
    },
    breachProtocol = {
        instructions = 'Güvenlik matrisinde hedef diziyi bul. Satır ve sütun seçimlerini sırayla değiştirerek ilerle.',
    },
    fingerprint = {
        instructions = '5 parçanın hepsini doğru hizalayarak parmak izini birleştir!',
    },
    pipePressure = {
        instructions = 'Boruları döndürmek için tıkla. Akışı başlangıçtan bitişe bağla.',
        startLabel = 'BAŞLANGIÇ',
        endLabel = 'BİTİŞ',
        flowInProgress = 'Akış sürüyor...',
    },
    pathing = {
        instructions = 'Bir sonraki en yakın noktaya git.',
    },
    aMess = {
        instructions = 'Çizgilerin hiçbirinin birbiriyle kesişmediğinden emin ol.',
    },
    getIt = {
        instructions = 'Yılanı WASD veya ok tuşlarıyla hareket ettir. Büyümek ve aşamayı bitirmek için yem topla!',
    },
    dataStream = {
        instructions = 'Ağ kanallarından akan hedef paketleri yakala. Tıklayarak yakala, istendiğinde şifresini çöz.',
        packetsRemaining = 'Kalan Hedef:',
        mirrorPairsLabel = 'Ayna Çiftleri:',
        letterPositionsLabel = 'Harf Sıraları:',
        letterValuesLabel = 'Harf Değerleri:',
        morseCodeLabel = 'Mors Kodu:',
        hexToBinaryLabel = 'Hex\'ten Binary\'ye:',
        dot2x4SymbolsLabel = '2x4 Nokta Sembollerinden Binary\'ye:',
        shapeSideSymbolsLabel = 'Şekil Kenar Sembolleri:',
        dominoVerticalSymbolsLabel = 'Dikey Domino Sembollerinden Hex\'e:',
        enterHex = 'Hex gir...',
        enterBinary = 'Binary gir...',
        enterDecryption = 'Çözümü gir...',
        decryptButton = 'ÇÖZ',
        decryptPattern = 'Deseni çöz',
    },
    echo = {
        instructions = 'Renkli kutuları ezberle, sonra her renkten kaç tane gördüğünü cevapla',
        memorizePhase = 'Izgarayı ezberle...',
        questionPhase = 'Soruyu cevapla:',
        howManyBoxes = 'Kaç tane {color} kutu vardı?',
        answerKeys = 'Cevabını seçmek için 1, 2 veya 3\'e bas',
        getReadyMessage = 'Ezberlemeye hazırlan...',
        colors = {
            red = 'Kırmızı',
            green = 'Yeşil',
            blue = 'Mavi',
            yellow = 'Sarı',
        },
    },
    unlocked = {
        instructions = 'Noktalı çemberleri tek tek döndürerek renkleri çizgilerle eşleştir. A/D = aktif çemberi döndür, SPACE = çözümü kontrol et.',
    },
    numbers = {
        instructions = 'Sayılara küçükten büyüğe (1, 2, 3...) olabildiğince hızlı tıkla!',
    },
    mines = {
        instructions = 'Mayınların yerini aklında tut, kaybolduklarında hepsini bul!',
    },
    math = {
        instructions = 'İki işlemi de kafandan hesapla ve karşılaştır: > (büyük), < (küçük) veya = (eşit)',
        greater = 'Büyük (>)',
        less = 'Küçük (<)',
        equal = 'Eşit (=)',
    },
    keys = {
        instructions = 'Tuşlara soldan sağa, satır satır doğru sırayla bas!',
    },
    breaker = {
        instructions = 'Topu fırlatmak için SPACE veya ENTER\'a bas. Raketi ok tuşları veya A/D ile hareket ettir',
        lives = 'Can',
    },
    crackit = {
        instructions = 'PIN\'i kırmak için sayı gir. Yeşil = doğru yer, Sarı = yanlış yer, Kırmızı = PIN\'de yok',
        crackButton = 'KIR',
        deleteButton = 'SİL',
    },
    dash = {
        instructions = 'Hareket etmek için A/D veya ok tuşlarını kullan. Düşen çizgilerdeki yeşil boşluklardan geç!',
    },
    flappy = {
        instructions = 'Kanat çırpmak için SPACE\'e bas! Yatay boruların arasından geç!',
        startMessage = 'Başlamak için SPACE\'e bas veya tıkla!',
    },
    intime = {
        instructions = 'Düşen blokları yok etmek için harf veya sayı tuşlarına bas - ilerlemek için tüm blokları yok et!',
    },
    tothesky = {
        instructions = 'Sağa/sola gitmek için A/D veya ok tuşlarını kullan. Daha yükseğe zıplamak için platformlara kon! Gökyüzüne ulaş!',
    },
    towerofhanoi = {
        instructions = 'Tüm diskleri en sağdaki kuleye taşı. Her seferinde tek disk taşı. Büyük disk küçük diskin üstüne konamaz.',
    },
    typix = {
        instructions = '5 harfli kelimeyi 6 denemede bul. Yeşil = doğru yer, Sarı = yanlış yer, Gri = kelimede yok.',
        categoryLabel = 'Kategori',
        categories = {
            variety = 'Karışık',
            animals = 'Hayvanlar',
            food = 'Yiyecek',
            tech = 'Teknoloji',
            cities = 'Şehirler',
            countries = 'Ülkeler',
            math = 'Matematik',
            tools = 'Aletler',
            nsfw = 'NSFW',
        },
    },
    sequencememory = {
        instructions = 'Yanan kutuların sırasını izle, sonra aynı sırayla tıkla. Her turda hatırlanacak kutu sayısı artar.',
    },

    -- IveSeenIt Game
    IveSeenIt = {
        instructions = 'Bu kelimeyi bu oturumda daha önce gördüysen "Gördüm"e, ilk kez görüyorsan "Yeni"ye tıkla.',
        seenButton = 'GÖRDÜM',
        newButton = 'YENİ',
    },

    -- Game20471
    Game20471 = {
        instructions = 'Kareleri kaydırmak için WASD veya ok tuşlarını kullan. Hedefe ulaşmak için aynı sayıları birleştir!',
        stageDescription = '{target} değerine ulaşmak için kareleri birleştir!',
    },

    -- Locked Game
    locked = {
        instructions = 'Doğru bölümü bulmak için oku döndür. Kilidi hissetmek için hedeflerin yakınında yavaş hareket et.',
    },

    -- Balance Game
    balance = {
        instructions = 'İbreyi yeşil bölgede dengede tutmak için Q ve E kullan. Kırmızı bölgeye düşerse kaybedersin! Kazanmak için süre boyunca dayan.',
        controls = {
            left = 'Q - İbreyi sola it',
            right = 'E - İbreyi sağa it',
        },
        failed = 'BAŞARISIZ!',
        success = 'BAŞARILI!',
    },
    -- Pitch Lock Game
    pitchLock = {
        instructions = 'Hedef sesi dinle, sonra kulaktan aynısını yakala',
        playTarget = 'Hedefi Çal',
        secondsToRemember = 'Dinle...',
        submitGuess = 'Gönder',
        targetLabel = 'HEDEF',
        hzUnit = 'Hz',
        scoreLabel = 'Skor',
        perfectScore = 'Kusursuz kulak!',
        greatScore = 'İyi kulak!',
        goodScore = 'İyi.',
        okScore = 'Eh işte...',
        poorScore = 'Olmadı...',
        totalScore = 'Toplam Skor',
        tuningHint = 'Ayarlamak için tıklayıp yukarı/aşağı sürükle',
        passed = 'Geçtin!',
        notPassed = 'Yeterli puan yok!',
    },
    -- Chroma Lock Game
    chromaLock = {
        instructions = 'Hedef renge bak, sonra gözünle aynısını oluştur',
        targetLabel = 'HEDEF',
        scoreLabel = 'Skor',
        perfectScore = 'Kusursuz',
        greatScore = 'Harika',
        goodScore = 'İyi',
        okScore = 'Orta',
        poorScore = 'Kaçtı',
        totalScore = 'Toplam Skor',
        tuningHint = 'Ton, Doygunluk ve Parlaklığı kaydırıcılarla ayarla',
        passed = 'Geçtin!',
        notPassed = 'Yeterli puan yok!',
    },
    -- Pin Lock Game
    pinLock = {
        instructions = 'Pimi kaldırmak için SPACE\'e dokun, yandığında sabitlemek için E\'ye bas!',
        pushHint = 'Pimi Kaldır',
        setHint = 'Pimi Sabitle',
        attemptsLabel = 'Deneme',
        failed = 'BAŞARISIZ!',
        success = 'BAŞARILI!',
    },
    -- Untangle Game
    untangle = {
        instructions = 'Bir oka dokunarak onu tahtadan kaydırıp çıkar. Başının önünde ne varsa önce o çıkmalı!',
    },
    -- Calibrate Game
    calibrate = {
        instructions = 'Kadranını çevirmek için kaydırıcıyı sürükle. Sadece aynı uzunluktaki çizgiler birbirine aittir - tüm çiftleri aynı anda hizala.',
    },
    -- Resonance Game
    resonance = {
        instructions = 'Yükseklik, sayı ve şekil - dalgan soluk olanın üstüne oturana kadar üçünü de sürükle.',
        amplitudeLabel = 'YÜKSEKLİK',
        frequencyLabel = 'DALGA',
        shapeLabel = 'ŞEKİL',
    },
    -- Pulse Bar Game
    pulseBar = {
        instructions = 'Hareketli parça hedef bölgeyle çakıştığında E\'ye bas. Iskalamak ve fazla basmak kaybettirir.',
    },
    -- Stacker Game
    stacker = {
        instructions = 'Bloğu yığının üstüne bırakmak için Space, Enter veya tıkla',
    },
    -- Lights Out Game
    lightsOut = {
        instructions = 'Bir ışığa tıklayınca o ve komşuları değişir. Tüm ışıkları söndür.',
    },
    -- Data Crack Game
    dataCrack = {
        instructions = 'Vurgulanan boşluk çizginin üstüne geldiğinde E, Space, Enter\'a bas veya tıkla',
    },

}
