local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do
        copy[key] = deepCopy(item)
    end
    return copy
end

local function mergeMissing(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            mergeMissing(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local english = {
    menu = {
        characterEditor = "Character Editor",
        favorites = "Favorites",
        showFavorites = "Show Favorites Only",
        toggleFavorite = "Add / Remove Favorite",
        startPreload = "Preload",
        preloadPause = "Pause",
        preloadContinue = "Continue",
        preloadRestart = "Restart",
        cancelPreload = "Cancel",
        loading = "Loading",
        lightSettings = "Studio Lighting",
        lightSubtitle = "Professional Light System",
        lightPresets = "Quick Presets",
        lightPresetStudio = "Studio",
        lightPresetWarm = "Warm",
        lightPresetCool = "Cool",
        lightPresetNeon = "Neon",
        lightIntensity = "Intensity",
        lightRotation = "Rotation",
        lightHeight = "Height",
        lightDistance = "Distance",
        restoreDefaults = "Restore Defaults",
        savedOutfits = "Saved Outfits",
        toggleHandsUp = "Hands Up",
        animations = "Animations",
        animationSubtitle = "Pose and stance controls",
        animationHandsUp = "Hands Up",
        animationArmsCrossed = "Arms Crossed",
        animationBoss = "Commanding Stance",
        animationGuard = "Guard Stance",
        animationHint = "Press the selected animation again to turn it off.",
        animationStop = "Stop Animation",
        animationCommandTitle = "Animation Command",
        animationCommandPlaceholder = "dance2, sit, mechanic...",
        animationRecent = "Recent",
        animationCommandStarted = "Animation started.",
        animationCommandStopped = "Animation stopped.",
        animationCommandInvalid = "Enter a valid animation name.",
        animationCommandReasons = {
            invalid_command = "Enter a valid animation name.",
            animation_not_found = "Animation not found.",
            emote_resource_unavailable = "Animation system is unavailable."
        },
        rotateLeft = "Rotate Left",
        rotateRight = "Rotate Right",
        turnAround = "Turn Around",
        favoritesTitle = "Favorites",
        favoritesSubtitle = "Your personal collection",
        favoritesAll = "All",
        favoriteOptions = "options",
        favoriteModel = "Model",
        removeFavorite = "Remove favorite",
        savedItems = "saved models",
        noFavorites = "No favorites yet",
        noFavoritesHint = "Use the star next to a model to collect it here.",
        preloadTitle = "Preload",
        preloadSubtitle = "Prepare the model cache",
        preloadReady = "Ready",
        preloadCompleted = "Completed",
        preloadResume = "Resume",
        preloadCancel = "Cancel",
        preloadCurrentTab = "Current Tab",
        preloadSelectAll = "All",
        preloadClear = "Clear",
        preloadSelection = "Selection",
        preloadSlots = "slots",
        preloadStart = "Start Preload",
        preloadHint = "Only model values are scanned; textures load automatically when needed."
    },
    editor = {
        tabs = {
            heritage = "Heritage", face = "Face", skin = "Skin", hair = "Hair", makeup = "Makeup",
            apparel = "Apparel", tattoos = "Tattoos"
        },
        groups = {
            body = "Body type", parents = "Parents", ancestry = "Ancestry",
            nose = "Nose", brows = "Brows", cheeks = "Cheeks", eyes = "Eyes", lips = "Lips", jaw = "Jaw",
            chin = "Chin", neck = "Neck",
            tone = "Skin tone", texture = "Texture", marks = "Marks",
            hair = "Hair", eyebrows = "Eyebrows", beard = "Facial hair", chest = "Chest hair",
            eyeMakeup = "Eye makeup", blush = "Blush", lipstick = "Lipstick",
            outfits = "Outfits", favourites = "My favourites", head = "Head", upper = "Upper body", wrist = "Hand & wrist", lower = "Lower body",
            tHead = "Head", tTorso = "Torso", tLeftArm = "Left arm", tRightArm = "Right arm",
            tLeftLeg = "Left leg", tRightLeg = "Right leg"
        },
        slots = {
            hats = "Hats", glasses = "Glasses", ears = "Ears", masks = "Masks", jackets = "Tops",
            shirts = "Undershirts", arms = "Arms", chains = "Chains", vests = "Vests", decals = "Decals",
            bags = "Bags", watches = "Watches", bracelets = "Bracelets", pants = "Bottoms", shoes = "Footwear",
            hair = "Hair", eyebrows = "Eyebrows", beard = "Facial hair", chest = "Chest hair",
            eyeMakeup = "Eye makeup", blush = "Blush", lipstick = "Lipstick"
        },
        features = {
            noseWidth = "Width", nosePeakHigh = "Peak height", nosePeakSize = "Peak length",
            noseBoneHigh = "Bone height", nosePeakLowering = "Peak lowering", noseBoneTwist = "Bone twist",
            eyeBrownHigh = "Height", eyeBrownForward = "Depth",
            cheeksBoneHigh = "Bone height", cheeksBoneWidth = "Bone width", cheeksWidth = "Width",
            eyesOpening = "Opening", lipsThickness = "Thickness",
            jawBoneWidth = "Width", jawBoneBackSize = "Length",
            chinBoneLowering = "Height", chinBoneLenght = "Length", chinBoneSize = "Width", chinHole = "Cleft",
            neckThickness = "Thickness"
        },
        overlays = {
            blemishes = "Blemishes", beard = "Facial hair", eyebrows = "Eyebrows", ageing = "Ageing",
            makeUp = "Eye makeup", blush = "Blush", complexion = "Complexion", sunDamage = "Sun damage",
            lipstick = "Lipstick", moleAndFreckles = "Moles & freckles", chestHair = "Chest hair",
            bodyBlemishes = "Body blemishes"
        },
        words = {
            style = "Style", none = "None", opacity = "Opacity", colour = "Colour", secondColour = "Second colour",
            highlight = "Highlight", fade = "Fade", texture = "Texture", colourways = "Colourways", options = "%d options",
            search = "Search...", favourites = "Favourites", remove = "Remove", male = "Male", female = "Female",
            mother = "Mother", father = "Father", resemblance = "Resemblance", skinMix = "Skin mix",
            influence = "Influence", third = "Third parent", eyeColour = "Eye colour", tone = "Tone %d",
            customization = "Customization", characters = "Characters", empty = "Nothing here", worn = "On you",
            oneColour = "This piece comes in one colour.", pickFirst = "Pick a piece to see its colours.",
            hairColour = "Hair colour", typeNumber = "Type a number, Enter",
            parentsHint = "Face and skin come from the parent you pick", toneHint = "Each tone is one parent's skin",
            randomOutfit = "Random outfit", randomOutfitHint = "A random top, trousers and shoes (locked ones stay)",
            allLocked = "Every random slot is locked",
            lockRandom = "Lock: Random outfit leaves this piece", unlockRandom = "Unlock: Random outfit may change this piece",
            random = "Random", resetGroup = "Reset", noFavourites = "No favourites yet. Star a piece in any list and it waits here."
        },
        lang = "en",
        cost = {
            total = "Total cost", free = "Free", onConfirm = "charged on confirm", changes = "%d changes",
            oneChange = "1 change", noChanges = "No changes yet", more = "+%d more", export = "Code",
            confirm = "Confirm"
        },
        stage = {
            pose = "Pose", light = "Light", camera = "Camera", stand = "Stand", off = "Off",
            hat = "Hat", mask = "Mask", top = "Top", bottom = "Bottom",
            cameras = {
                default = "Full body", head = "Face", body = "Upper body", legs = "Legs", hands = "Hands",
                bottom = "Feet", free = "Free"
            }
        },
        keys = {
            undo = "Undo", redo = "Redo", before = "Before", hide = "Hide UI", show = "Show UI",
            turntable = "Turntable", rotate = "Rotate", zoom = "Zoom", focus = "Focus", tabs = "Tabs",
            browse = "Browse", confirm = "Confirm", back = "Back", reset = "Start over", settings = "Settings",
            prevCap = "[", nextCap = "]"
        },
        settings = {
            title = "Settings", accent = "Accent colour", accentHint = "Picks, buttons and highlights",
            look = "Panel look", lookHint = "See-through or solid panels", glass = "Glass", solid = "Solid",
            corners = "Corners", cornersHint = "Cut or square panel corners", cut = "Cut", square = "Square",
            view = "Item view", viewHint = "Pictures, or rows with sliders", photos = "Photos", rows = "Rows",
            autoCamera = "Auto camera", autoCameraHint = "Moves to what you edit",
            hints = "Key hints", hintsHint = "The keys along the bottom",
            hidePlayers = "Hide other players", hidePlayersHint = "Only for you, while editing",
            motion = "Motion", motionHint = "Slides, fades and hover effects",
            preload = "Preload items", preloadHint = "Loads every item once so browsing is smooth",
            start = "Start", pause = "Pause", resume = "Resume", cancel = "Cancel",
            reset = "Reset", done = "Done", on = "On", off = "Off",
            groupLooks = "Look", groupItems = "Items", groupStudio = "Studio", groupFeel = "Feel",
            scale = "Interface size", scaleHint = "Panels and text larger or smaller", small = "Small", normal = "Normal", large = "Large",
            columns = "Card size", columnsHint = "Bigger pictures or more items at once", big = "Big", compact = "Small",
            favFirst = "Favourites first", favFirstHint = "Starred items at the top of the list",
            spin = "Turn speed", spinHint = "How fast T turns the character", slow = "Slow", fast = "Fast",
            sounds = "Sounds", soundsHint = "Soft game clicks when you pick and move",
            remember = "Remember sections", rememberHint = "Each tab opens where you left it last time",
            page_look = "Look", page_use = "Use", page_preload = "Preload", groupOther = "Other"
        },
        preload = {
            intro = "Downloads clothes ahead of time so they show up at once while you browse. Your character keeps wearing what it wears, and you can keep editing meanwhile.",
            state_idle = "Ready", state_counting = "Counting colours", state_running = "Loading", state_paused = "Paused", state_done = "Finished",
            start = "Start", pause = "Pause", resume = "Resume", cancel = "Cancel", again = "New run",
            loaded = "Loaded", left = "Time left", took = "Took", failed = "Failed",
            pieces = "pieces", about = "about", style = "Style", colour = "Colour",
            seconds = "s", minutes = "min", hours = "h", sep = ",",
            nothing = "Everything picked has loaded already.", emptySelection = "Pick at least one section below.",
            keepEditing = "You can keep editing; closing the editor pauses it.",
            how = "How", textures = "Colours", texturesHint = "Load each item's colour options too",
            texNone = "None", texSome = "First %d", texAll = "All",
            speed = "Speed", speedHint = "Calm is lighter on the game", calm = "Calm", normal = "Normal", fast = "Fast",
            skip = "Skip loaded ones", skipHint = "%s pieces loaded before are skipped.", skipEmpty = "Loaded pieces are remembered on this computer.", skipRunning = "What loads now is remembered for next time.", forget = "Forget",
            what = "What to load", all = "All", here = "This section", none = "None",
            locked = "The selection is locked while a run is going."
        },
        dialog = {
            saveTitle = "Keep this look?", saveText = "Your changes will be saved.", savePaid = "%s will be charged.",
            exitTitle = "Leave the editor?", exitText = "Your changes will be lost.",
            confirm = "Confirm", leave = "Leave", back = "Back"
        },
        code = {
            title = "Face code", hint = "Copy your face, or paste a code to try one on", copy = "Copy code",
            paste = "Paste a face code", apply = "Apply", restore = "Undo",
            copied = "Face code copied.", copyManual = "Could not copy: the code is in the box, select it and press Ctrl+C.",
            applied = "Face applied. Confirm to keep it.", restored = "Your old face is back.",
            empty = "Paste a face code first.", invalid = "That face code is not valid.",
            isOutfit = "That is an outfit code, not a face code.", wrongModel = "That face is for the other body type.",
            notFreemode = "Face codes work only on online characters."
        },
        outfits = {
            saveTitle = "Save current outfit", nameHint = "Outfit name", save = "Save",
            importTitle = "Import a code", codeHint = "Outfit code", import = "Import",
            saved = "Saved outfits", wear = "Wear", update = "Update with current", code = "Copy code",
            delete = "Delete", sure = "Sure?", empty = "No saved outfits yet"
        },
        tattoos = {
            applied = "Applied tattoos", apply = "Apply design", remove = "Remove design", removeAll = "Remove all",
            none = "No tattoos yet", empty = "No designs for this area", notPaid = "Not enough money for this tattoo.",
            design = "Design"
        }
    },
    outfits = {
        title = "Personal Wardrobe",
        empty = "No saved outfits",
        wear = "Wear",
        copyCode = "Copy Code",
        save = {
            menuTitle = "Save New",
            name = { placeholder = "Outfit name" }
        },
        update = { title = "Update" },
        delete = { title = "Delete" },
        generate = { title = "Generate Code" },
        import = {
            menuTitle = "Import Code",
            code = { placeholder = "Outfit code" }
        },
        loading = "Loading...",
        wearing = "Applying outfit...",
        copied = "Copied",
        status = {
            saved = "Outfit saved.",
            previewed = "Outfit applied to preview.",
            updated = "Outfit updated.",
            deleted = "Outfit deleted.",
            codeCopied = "Code copied to clipboard.",
            imported = "Outfit imported.",
            failed = "Operation failed."
        },
        reasons = {
            invalid_name = "Enter a valid outfit name.",
            invalid_code = "The outfit code is invalid.",
            invalid_appearance = "The current appearance could not be saved.",
            exists = "An outfit with this name already exists.",
            own_outfit = "You cannot import your own outfit code.",
            not_found = "Outfit not found.",
            database_error = "The database operation failed.",
            server_error = "The server did not respond.",
            no_money = "Not enough money to save this outfit."
        }
    }
}

local turkish = {
    menu = {
        characterEditor = "Karakter Düzenleme",
        favorites = "Favoriler",
        showFavorites = "Yalnız Favorileri Göster",
        toggleFavorite = "Favoriye Ekle / Çıkar",
        startPreload = "Ön Yükle",
        preloadPause = "Duraklat",
        preloadContinue = "Devam Et",
        preloadRestart = "Yeniden Başlat",
        cancelPreload = "İptal",
        loading = "Yükleniyor",
        lightSettings = "Stüdyo Aydınlatması",
        lightSubtitle = "Profesyonel Işık Sistemi",
        lightPresets = "Hızlı Önayarlar",
        lightPresetStudio = "Stüdyo",
        lightPresetWarm = "Sıcak",
        lightPresetCool = "Soğuk",
        lightPresetNeon = "Neon",
        lightIntensity = "Yoğunluk",
        lightRotation = "Dönüş",
        lightHeight = "Yükseklik",
        lightDistance = "Mesafe",
        restoreDefaults = "Varsayılana Sıfırla",
        savedOutfits = "Kayıtlı Kıyafetler",
        toggleHandsUp = "Eller Yukarı",
        animations = "Animasyonlar",
        animationSubtitle = "Duruş ve poz kontrolleri",
        animationHandsUp = "Eller Yukarı",
        animationArmsCrossed = "Kollar Bağlı",
        animationBoss = "Otoriter Duruş",
        animationGuard = "Nöbet Duruşu",
        animationHint = "Seçili animasyona tekrar basarak kapatabilirsin.",
        animationStop = "Animasyonu Durdur",
        animationCommandTitle = "Animasyon Komutu",
        animationCommandPlaceholder = "dance2, sit, mechanic...",
        animationRecent = "Son",
        animationCommandStarted = "Animasyon başlatıldı.",
        animationCommandStopped = "Animasyon durduruldu.",
        animationCommandInvalid = "Geçerli bir animasyon adı gir.",
        animationCommandReasons = {
            invalid_command = "Geçerli bir animasyon adı gir.",
            animation_not_found = "Animasyon bulunamadı.",
            emote_resource_unavailable = "Animasyon sistemi kullanılamıyor."
        },
        rotateLeft = "Sola Döndür",
        rotateRight = "Sağa Döndür",
        turnAround = "Arkanı Dön",
        favoritesTitle = "Favoriler",
        favoritesSubtitle = "Kişisel koleksiyonun",
        favoritesAll = "Tümü",
        favoriteOptions = "seçenek",
        favoriteModel = "Model",
        removeFavorite = "Favoriden çıkar",
        savedItems = "kayıtlı model",
        noFavorites = "Henüz favori yok",
        noFavoritesHint = "Model yanındaki yıldızı kullanarak seçimlerini burada toplayabilirsin.",
        preloadTitle = "Ön Yükleme",
        preloadSubtitle = "Model önbelleğini hazırla",
        preloadReady = "Hazır",
        preloadCompleted = "Tamamlandı",
        preloadResume = "Devam",
        preloadCancel = "İptal",
        preloadCurrentTab = "Aktif Sekme",
        preloadSelectAll = "Tümü",
        preloadClear = "Temizle",
        preloadSelection = "Seçim",
        preloadSlots = "slot",
        preloadStart = "Ön Yüklemeyi Başlat",
        preloadHint = "Yalnız model değerleri taranır; dokular gerektiğinde otomatik yüklenir."
    },
    editor = {
        tabs = {
            heritage = "Köken", face = "Yüz", skin = "Ten", hair = "Saç", makeup = "Makyaj",
            apparel = "Giyim", tattoos = "Dövme"
        },
        groups = {
            body = "Vücut tipi", parents = "Ebeveynler", ancestry = "Soy",
            nose = "Burun", brows = "Kaş kemiği", cheeks = "Elmacık", eyes = "Gözler", lips = "Dudaklar",
            jaw = "Çene", chin = "Çene ucu", neck = "Boyun",
            tone = "Ten rengi", texture = "Doku", marks = "İzler",
            hair = "Saç", eyebrows = "Kaşlar", beard = "Sakal", chest = "Göğüs kılı",
            eyeMakeup = "Göz makyajı", blush = "Allık", lipstick = "Ruj",
            outfits = "Kombinler", favourites = "Favorilerim", head = "Baş", upper = "Üst beden", wrist = "El ve bilek", lower = "Alt beden",
            tHead = "Baş", tTorso = "Gövde", tLeftArm = "Sol kol", tRightArm = "Sağ kol",
            tLeftLeg = "Sol bacak", tRightLeg = "Sağ bacak"
        },
        slots = {
            hats = "Şapkalar", glasses = "Gözlükler", ears = "Küpeler", masks = "Maskeler", jackets = "Üstler",
            shirts = "İç giyim", arms = "Kollar", chains = "Kolyeler", vests = "Yelekler", decals = "Armalar",
            bags = "Çantalar", watches = "Saatler", bracelets = "Bileklikler", pants = "Altlar", shoes = "Ayakkabılar",
            hair = "Saç", eyebrows = "Kaşlar", beard = "Sakal", chest = "Göğüs kılı",
            eyeMakeup = "Göz makyajı", blush = "Allık", lipstick = "Ruj"
        },
        features = {
            noseWidth = "Genişlik", nosePeakHigh = "Uç yüksekliği", nosePeakSize = "Uç uzunluğu",
            noseBoneHigh = "Kemik yüksekliği", nosePeakLowering = "Uç eğimi", noseBoneTwist = "Kemik kıvrımı",
            eyeBrownHigh = "Yükseklik", eyeBrownForward = "Derinlik",
            cheeksBoneHigh = "Kemik yüksekliği", cheeksBoneWidth = "Kemik genişliği", cheeksWidth = "Dolgunluk",
            eyesOpening = "Açıklık", lipsThickness = "Kalınlık",
            jawBoneWidth = "Genişlik", jawBoneBackSize = "Uzunluk",
            chinBoneLowering = "Yükseklik", chinBoneLenght = "Uzunluk", chinBoneSize = "Genişlik", chinHole = "Gamze",
            neckThickness = "Kalınlık"
        },
        overlays = {
            blemishes = "Lekeler", beard = "Sakal", eyebrows = "Kaşlar", ageing = "Yaşlanma",
            makeUp = "Göz makyajı", blush = "Allık", complexion = "Cilt tonu", sunDamage = "Güneş hasarı",
            lipstick = "Ruj", moleAndFreckles = "Ben ve çil", chestHair = "Göğüs kılı",
            bodyBlemishes = "Vücut lekeleri"
        },
        words = {
            style = "Stil", none = "Yok", opacity = "Yoğunluk", colour = "Renk", secondColour = "İkinci renk",
            highlight = "Röfle", fade = "Fade", texture = "Doku", colourways = "Renkler", options = "%d seçenek",
            search = "Ara...", favourites = "Favoriler", remove = "Çıkar", male = "Erkek", female = "Kadın",
            mother = "Anne", father = "Baba", resemblance = "Benzerlik", skinMix = "Ten karışımı",
            influence = "Etki", third = "Üçüncü ebeveyn", eyeColour = "Göz rengi", tone = "Ton %d",
            customization = "Özelleştir", characters = "Karakterler", empty = "Burada bir şey yok", worn = "Üzerinde",
            oneColour = "Bu parçanın tek rengi var.", pickFirst = "Renkleri görmek için bir parça seç.",
            hairColour = "Saç rengi", typeNumber = "Numara yaz, Enter",
            parentsHint = "Seçtiğin ebeveynden yüz ve ten gelir", toneHint = "Her ton bir ebeveynin teni",
            randomOutfit = "Rastgele kombin", randomOutfitHint = "Rastgele üst, alt ve ayakkabı (kilitliler değişmez)",
            allLocked = "Rastgelede değişecek parçaların hepsi kilitli",
            lockRandom = "Kilitle: rastgele kombin bu parçayı değiştirmez", unlockRandom = "Kilidi aç: rastgele kombin bu parçayı değiştirebilir",
            random = "Rastgele", resetGroup = "Sıfırla", noFavourites = "Henüz favorin yok. Bir listedeki parçanın yıldızına bas, burada seni bekler."
        },
        lang = "tr",
        cost = {
            total = "Toplam tutar", free = "Ücretsiz", onConfirm = "onaylayınca ödenir", changes = "%d değişiklik",
            oneChange = "1 değişiklik", noChanges = "Henüz değişiklik yok", more = "+%d daha", export = "Kod",
            confirm = "Onayla"
        },
        stage = {
            pose = "Poz", light = "Işık", camera = "Kamera", stand = "Ayakta", off = "Kapalı",
            hat = "Şapka", mask = "Maske", top = "Üst", bottom = "Alt",
            cameras = {
                default = "Tüm vücut", head = "Yüz", body = "Üst beden", legs = "Bacaklar", hands = "Eller",
                bottom = "Ayaklar", free = "Serbest"
            }
        },
        keys = {
            undo = "Geri al", redo = "Yinele", before = "Önce", hide = "Arayüzü gizle", show = "Arayüzü göster",
            turntable = "Döndür", rotate = "Çevir", zoom = "Yakınlaş", focus = "Odakla", tabs = "Sekmeler",
            browse = "Gez", confirm = "Onayla", back = "Geri", reset = "Baştan al", settings = "Ayarlar",
            prevCap = "Ğ", nextCap = "Ü"
        },
        settings = {
            title = "Ayarlar", accent = "Vurgu rengi", accentHint = "Seçimler, butonlar ve vurgular",
            look = "Panel görünümü", lookHint = "Saydam ya da düz paneller", glass = "Cam", solid = "Düz",
            corners = "Köşeler", cornersHint = "Kesik ya da düz köşeler", cut = "Kesik", square = "Düz",
            view = "Liste görünümü", viewHint = "Resimler ya da kaydırmalı satırlar", photos = "Resim", rows = "Satır",
            autoCamera = "Otomatik kamera", autoCameraHint = "Düzenlediğin yere gider",
            hints = "Tuş ipuçları", hintsHint = "Alttaki tuş şeridi",
            hidePlayers = "Diğer oyuncuları gizle", hidePlayersHint = "Sadece sende, düzenlerken",
            motion = "Hareket", motionHint = "Kayma, solma ve üzerine gelme efektleri",
            preload = "Ön yükleme", preloadHint = "Her parçayı bir kez yükler, gezinme akıcı olur",
            start = "Başlat", pause = "Duraklat", resume = "Devam", cancel = "İptal",
            reset = "Sıfırla", done = "Tamam", on = "Açık", off = "Kapalı",
            groupLooks = "Görünüm", groupItems = "Parçalar", groupStudio = "Stüdyo", groupFeel = "Kullanım",
            scale = "Arayüz boyutu", scaleHint = "Paneller ve yazılar büyük ya da küçük", small = "Küçük", normal = "Normal", large = "Büyük",
            columns = "Kart boyutu", columnsHint = "Büyük resimler ya da bir bakışta daha çok parça", big = "Büyük", compact = "Küçük",
            favFirst = "Önce favoriler", favFirstHint = "Yıldızlı parçalar listenin başında",
            spin = "Dönme hızı", spinHint = "T ile karakterin ne kadar hızlı döndüğü", slow = "Yavaş", fast = "Hızlı",
            sounds = "Sesler", soundsHint = "Seçip gezinirken oyunun yumuşak tık sesleri",
            remember = "Bölümleri hatırla", rememberHint = "Her sekme en son kaldığın yerden açılır",
            page_look = "Görünüm", page_use = "Kullanım", page_preload = "Ön yükleme", groupOther = "Diğer"
        },
        preload = {
            intro = "Kıyafetleri önceden indirir, gezinirken parçalar beklemeden görünür. Karakterin üzerindekini değiştirmez, bu sırada düzenlemeye devam edebilirsin.",
            state_idle = "Hazır", state_counting = "Renkler sayılıyor", state_running = "Yükleniyor", state_paused = "Duraklatıldı", state_done = "Tamamlandı",
            start = "Başlat", pause = "Duraklat", resume = "Devam et", cancel = "İptal", again = "Yeni yükleme",
            loaded = "Yüklenen", left = "Kalan süre", took = "Süre", failed = "Hatalı",
            pieces = "parça", about = "yaklaşık", style = "Stil", colour = "Renk",
            seconds = "sn", minutes = "dk", hours = "sa", sep = ".",
            nothing = "Seçilenlerin hepsi zaten yüklendi.", emptySelection = "Aşağıdan en az bir bölüm seç.",
            keepEditing = "Düzenlemeye devam edebilirsin; editörü kapatınca duraklar.",
            how = "Nasıl", textures = "Renk seçenekleri", texturesHint = "Her parçanın renkleri de yüklensin",
            texNone = "Yok", texSome = "İlk %d", texAll = "Hepsi",
            speed = "Hız", speedHint = "Sakin, oyunu daha az yorar", calm = "Sakin", normal = "Normal", fast = "Hızlı",
            skip = "Yüklenenleri atla", skipHint = "Daha önce yüklenen %s parça atlanır.", skipEmpty = "Yüklenen parçalar bu bilgisayarda hatırlanır.", skipRunning = "Şimdi yüklenenler bir dahaki sefere hatırlanır.", forget = "Unut",
            what = "Neler yüklensin", all = "Tümü", here = "Bu bölüm", none = "Hiçbiri",
            locked = "Yükleme sürerken seçim değiştirilemez."
        },
        dialog = {
            saveTitle = "Bu görünüm kalsın mı?", saveText = "Değişikliklerin kaydedilecek.", savePaid = "%s ödenecek.",
            exitTitle = "Düzenleyiciden çıkılsın mı?", exitText = "Değişikliklerin kaybolacak.",
            confirm = "Onayla", leave = "Çık", back = "Geri dön"
        },
        code = {
            title = "Yüz kodu", hint = "Yüzünü kopyala ya da bir kod yapıştırıp dene", copy = "Kodu kopyala",
            paste = "Yüz kodunu yapıştır", apply = "Uygula", restore = "Geri al",
            copied = "Yüz kodu kopyalandı.", copyManual = "Kopyalanamadı: kod kutuda, seçip Ctrl+C yap.",
            applied = "Yüz uygulandı. Kalması için onayla.", restored = "Eski yüzüne dönüldü.",
            empty = "Önce bir yüz kodu yapıştır.", invalid = "Yüz kodu geçersiz.",
            isOutfit = "Bu bir kıyafet kodu, yüz kodu değil.", wrongModel = "Bu yüz diğer vücut tipi için.",
            notFreemode = "Yüz kodu sadece online karakterlerde çalışır."
        },
        outfits = {
            saveTitle = "Üzerindekini kaydet", nameHint = "Kombin adı", save = "Kaydet",
            importTitle = "Kod ile ekle", codeHint = "Kombin kodu", import = "Ekle",
            saved = "Kayıtlı kombinler", wear = "Giy", update = "Üzerindekiyle güncelle", code = "Kodu kopyala",
            delete = "Sil", sure = "Emin misin?", empty = "Henüz kayıtlı kombin yok"
        },
        tattoos = {
            applied = "Yapılan dövmeler", apply = "Dövmeyi yap", remove = "Dövmeyi sil", removeAll = "Hepsini sil",
            none = "Henüz dövme yok", empty = "Bu bölge için desen yok", notPaid = "Bu dövme için paran yetmiyor.",
            design = "Desen"
        }
    },
    outfits = {
        title = "Kişisel Wardrobe",
        empty = "Kayıtlı outfit yok",
        wear = "Giy",
        copyCode = "Kodu Kopyala",
        save = {
            menuTitle = "Yeni Kaydet",
            name = { placeholder = "Outfit adı" }
        },
        update = { title = "Güncelle" },
        delete = { title = "Sil" },
        generate = { title = "Kod Üret" },
        import = {
            menuTitle = "Kod İçe Aktar",
            code = { placeholder = "Outfit kodu" }
        },
        loading = "Yükleniyor...",
        wearing = "Kıyafet uygulanıyor...",
        copied = "Kopyalandı",
        status = {
            saved = "Outfit kaydedildi.",
            previewed = "Outfit önizlemeye uygulandı.",
            updated = "Outfit güncellendi.",
            deleted = "Outfit silindi.",
            codeCopied = "Kod panoya kopyalandı.",
            imported = "Outfit içe aktarıldı.",
            failed = "İşlem başarısız."
        },
        reasons = {
            invalid_name = "Geçerli bir outfit adı gir.",
            invalid_code = "Outfit kodu geçersiz.",
            invalid_appearance = "Mevcut görünüm kaydedilemedi.",
            exists = "Bu isimde bir outfit zaten var.",
            own_outfit = "Kendi outfit kodunu içe aktaramazsın.",
            not_found = "Outfit bulunamadı.",
            database_error = "Veritabanı işlemi başarısız.",
            server_error = "Sunucu yanıt vermedi.",
            no_money = "Bu kıyafeti kaydetmek için yeterli paran yok."
        }
    }
}

if not Locales.tr or not Locales.tr.purchase then
    Locales.tr = deepCopy(Locales.en or {})
end

for language, locale in pairs(Locales) do
    locale.UI = locale.UI or {}
    mergeMissing(locale.UI, language == "tr" and turkish or english)
end

-- the photo studio's notifications for admins (client/photostudio.lua)
local photostudio = {
    en = {
        title = "Photo studio",
        started = "Shooting %s. Progress is in F8.",
        finished = "Done. %d items showed nothing.",
        stopped = "Stopped. %d items showed nothing.",
        busy = "The photo studio is already running.",
        editorOpen = "Close the editor first.",
        vehicle = "Get out of the vehicle first.",
        headVisible = "The head is still visible. Details in F8.",
        rejoin = "Reconnect once: the empty head loads when you join.",
        screen = "Something besides the clothes shows on the set. Details in F8.",
        capture = "The game view cannot be read on this machine. Details in F8.",
        usage = "Start with /%s run base m first (GTA's own clothing, male, first colour). Every form is in F8.",
        stopping = "Stopping after this item.",
        idle = "The photo studio is not running.",
        progress = "%s: %d / %d pictures, about %d min left.",
        listed = "The clothing collections are listed in F8.",
        redo = "%s will be shot again on the next run.",
        unloaded = "%d items or colours did not load. /%s retry tries them again.",
        -- the screen that covers the set during a run
        ui = {
            calibrating = "Reading the game view",
            checking = "Checking the set",
            shooting = "Shooting",
            faces = "Faces and looks",
            stopping = "Stopping after this item",
            finishing = "Saving the last pictures",
            pictures = "pictures",
            perPicture = "s / picture",
            left = "left",
            minutes = "min",
            empty = "empty",
            waiting = "The first picture shows here",
            hint = "/photostudio stop to stop · keep the game window in front",
        },
    },
    tr = {
        title = "Fotoğraf stüdyosu",
        started = "%s çekiliyor. İlerleme F8'de.",
        finished = "Bitti. %d parça hiçbir şey göstermedi.",
        stopped = "Durduruldu. %d parça hiçbir şey göstermedi.",
        busy = "Fotoğraf stüdyosu zaten çalışıyor.",
        editorOpen = "Önce editörü kapat.",
        vehicle = "Önce araçtan in.",
        headVisible = "Kafa hâlâ görünüyor. Ayrıntı F8'de.",
        rejoin = "Bir kez yeniden bağlan: boş kafa oyuna girerken yükleniyor.",
        screen = "Sette kıyafetten başka bir şey görünüyor. Ayrıntı F8'de.",
        capture = "Bu bilgisayarda oyun görüntüsü okunamıyor. Ayrıntı F8'de.",
        usage = "Önce /%s run base m first ile başla (GTA'nın kendi kıyafetleri, erkek, ilk renk). Bütün kullanımlar F8'de.",
        stopping = "Bu parçadan sonra duruyor.",
        idle = "Fotoğraf stüdyosu çalışmıyor.",
        progress = "%s: %d / %d resim, yaklaşık %d dk kaldı.",
        listed = "Kıyafet koleksiyonları F8'de listelendi.",
        redo = "%s bir sonraki çalıştırmada yeniden çekilecek.",
        unloaded = "%d parça ya da renk yüklenemedi. /%s retry ile tekrar denenir.",
        ui = {
            calibrating = "Oyun görüntüsü okunuyor",
            checking = "Set kontrol ediliyor",
            shooting = "Çekiliyor",
            faces = "Yüzler ve görünümler",
            stopping = "Bu parçadan sonra duruyor",
            finishing = "Son resimler kaydediliyor",
            pictures = "resim",
            perPicture = "sn / resim",
            left = "kaldı",
            minutes = "dk",
            empty = "boş",
            waiting = "İlk resim burada görünecek",
            hint = "Durdurmak için /photostudio stop · oyun penceresi önde kalsın",
        },
    }
}

for language, locale in pairs(Locales) do
    mergeMissing(locale, { photostudio = photostudio[language] or photostudio.en })
end
