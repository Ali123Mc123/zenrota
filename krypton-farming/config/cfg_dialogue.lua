Config = Config or {}

Config.NpcDialogue = {
    ['tr'] = {

        harvest_perfect = {
            "Vay anasını... sıfır hata mı? Ben seni çalışıyor sanıyodum, meğer sanat icra ediyormuşsun.",
            "Heh, şöyle iş görünce insanın içi açılıyor. İçim açıldı ama yine de küreği sayacağım, alışkanlık.",
            "Ulan evlat, tarlayı öyle temiz toplamışsın ki ben bile kendimden şüphe ettim. Bu çiftlik bizim mi hâlâ?",
            "Maşallah. Bir tane ürün bile heba etmemişsin. Rahmetli görse seni bana örnek diye başıma kakardı.",
            "Helal olsun. Ben kırk yıl didindim, böyle jilet gibi işi ya iki kere gördüm ya üç. Biri de rüyaydı galiba.",
        },

        harvest_good = {
            "İyi iş çıkarmışsın. Dört dörtlük değil ama ayıptır söylemesi çoğundan daha adamsın.",
            "Fena değil evlat. Bir iki pürüz var ama ben onları saymıyorum, çünkü sayınca canım sıkılıyor.",
            "Olmuş bu iş. Hani biraz daha kasssan efsane olurmuş ama bu hali de ekmeğini hak ediyor.",
            "Güzel toplamışsın. Ben laf sokarım diye bekliyorsun ama bugün keyfim yerinde, az sokacağım.",
            "İyi işte. Tarlayı utandırmamışsın, beni de çok rezil etmemişsin. Daha ne olsun.",
        },

        harvest_mixed = {
            "Eh... bir var bir yok. Sen bugün çalıştın mı kafa mı dağıttın, ben tam çözemedim.",
            "Yarısı güzel, yarısı Allah'a emanet. Tıpkı benim gençliğim gibi; niyet vardı, ayar yoktu.",
            "Bak evlat, sende iş var ama akıl sürekli başka sokağa sapıyor. Toparla biraz kendini.",
            "Olmuş da olmamış da. Hani insan bakınca 'bir şeyler denemiş' diyor, o da bir şey.",
            "Bir kısmı maşallah, bir kısmı estağfurullah. Yarın gelirken beynini de yanında getir.",
        },

        harvest_failed = {
            "Yahu sen burada hasat mı yaptın, tarlayla kişisel hesaplaşmaya mı girdin?",
            "Bak bağırmıyorum çünkü tansiyonum var. Ama içimden sana uzun uzun söyleniyorum, bil.",
            "Bu kadar ürünü heba etmek için özel eğitim almış olman lazım. Doğuştan yetenekse daha da korkunç.",
            "Tarla senden sonra bir su içmek istedi resmen. Git bi çay koy da ikimiz de kendimize gelelim.",
            "Böyle facia en son selde olmuştu. Selin bahanesi vardı, senin neyin var onu merak ediyorum.",
        },

        greet_novice = {
            "Aaa yeni yüz. Hoş geldin evlat. Adını söyleme, ben şimdi duyarım birazdan unuturum.",
            "İlk gelişin galiba. Gözlerinde hâlâ umut var, yazık. Burada o fazla durmaz ama.",
            "Gel bakalım. Çiftlik burası, lunapark değil. Yine de para çıkıyor, o yüzden millet bırakmıyor.",
            "Yeni misin? İyi. Daha seni kimse kötü örnek göstermemiştir, tadını çıkar.",
        },

        greet_junior = {
            "Heh, yine geldin. Demek ilk günden kaçan tayfadan değilmişsin.",
            "Seni tanıdım ben... adını unuttum ama tipin bende borç hissi uyandırıyor.",
            "Tekrar geldin ha? Güzel. İnsan aynı yerde birkaç kere ter dökmeden adam sayılmıyor zaten.",
            "Aa bizim çocuk gelmiş. Yavaştan bu toprağın lafını da, nazını da öğreniyorsun.",
        },

        greet_veteran = {
            "Heh sen geldin. İçim rahatladı... sonra niye rahatladım onu unuttum ama iyi bir şeydi.",
            "Aaa evlat hoş geldin. Seni görünce moralim düzeldi, cüzdanımı bi yoklayayım yine de.",
            "Tecrübeli adam geldi çok şükür. Şöyle iş bilen biri gelince ben de insan içine çıkasım geliyor.",
            "Gel bakalım usta. Sen gelince ortalık toparlanıyor, ben de boş boş söylenmek yerine işe bakıyorum.",
        },

        greet_legend = {
            "Vay vay... efsane teşrif etmiş. Sen yokken burası kahvehane sonrası gibi tatsızdı.",
            "Heh, geldin ya iyi oldu. Çay soğudu, ben de iki kere yaşlandım seni beklerken.",
            "Sen bu çiftliğin yürüyen reklamısın evlat. Ben de bir zamanlar öyleydim, sonra bel ayrı gitti, heves ayrı.",
            "Aaa bizim meşhur geldi. Seni görünce seviniyorum da belli etmemeye çalışıyorum, huy meselesi.",
        },

        work_clothes = {
            "İş kıyafetiyle gelmişsin, güzel. Millet buraya terlikle gelip kariyer bekliyor.",
            "Hazırlıklı gelmen hoşuma gitti. İnsan niyetini önce üstünden başından belli eder.",
            "Oh be, sonunda iş için gelen biri. Çoğu süslenip geliyor, sanki hasada değil düğüne gidiyor.",
        },

        hard_attempt = {
            "Zoru mu seçtin? Güzel. Cesaretle delilik komşudur zaten, kapı kapıya otururlar.",
            "Hard ha? Tamam. Ya kendine çok güveniyorsun ya da bela seviyorsun.",
            "Zor işe girdin evlat. Allah yardımcın olsun, çünkü ben kenardan ancak laf veriyorum.",
        },

        hard_complete = {
            "Hard'ı da mı bitirdin? Ulan ben bunu anlatsam kahvede iki kişi inanır, biri de sağırdır.",
            "Vay anasını... zor işi de çözmüşsün. Ben sana saygı duydum, bu bende kolay açılan bir kapı değil.",
            "Hard tamamlandıysa sen bu işi çözmüşsün. Şapka çıkarırdım ama benim şapka geçen yaz rüzgara küstü.",
        },

        streak_3 = {
            "Üç gün üst üste geldin ha? Güzel. Bu devirde millet iki gün sonra ruhsal yorgunluk ilan ediyor.",
            "3 gün seri yapmışsın. Aferin. Benim en uzun serim de buydu, sonra diz devreyi kapattı.",
        },

        streak_7 = {
            "Bir hafta mı? Heeey maşallah. Burada yedi gün üst üste geleni ben en son... dur, onu da unuttum.",
            "7 gün seri kolay iş değil. Sana saygım arttı, hem de hissedilir miktarda arttı.",
        },

        group_create = {
            "Ekip mi kuruyorsun? Güzel. Liderlik havalı durur, sorumluluk kısmı sonradan tokat gibi iner.",
            "Heh, patronculuk başladı demek. Artık herkesin saçmalığı biraz da senin derdin, hayırlı olsun.",
        },

        group_join = {
            "Takıma girdin demek. İyi. Tek başına sürünmektense kalabalıkla uğraşmak bazen daha iyidir.",
            "Ekibe katılmak akıllıca. Hem iş bölünür hem suç ortaklaşa dağılır, mis gibi düzen.",
        },

        level_up = {
            "Seviye atladın ha? Aferin. Basamak basamak çıkarsın, sonra benim gibi inerken diz bırakırsın.",
            "Güzel, büyüyorsun. Rahmetli görse 'heh bundan adam olur' derdi, nadir derdi ama derdi.",
            "Yeni seviye, yeni dertler. Ama bunlar iyi dertler, fakirlikten iyidir.",
        },

        greet_active_job = {
            "Heh, ne oldu? İş mi karıştı, akıl mı karıştı?",
            "Hâlâ buralardasın. Demek bi pürüz var. Söyle bakalım, ne dağıldı?",
            "Ee problem ne? Tarla mı küstü, ekip mi saçmaladı, yoksa sen mi fazla düşündün?",
            "İşin ortasında geldin demek. Tamam anlat, kötü habere karşı bağışıklığım var artık.",
        },

        help_response = {
            "Bak şimdi, olay basit: tarla seç, git, çalış, dön, paranı al. Beş adım. Beşi de gözünde büyüdüyse ben ne diyeyim.",
            "Tarla var, ürün var, sen varsın. Gidiyorsun, topluyorsun, dönüyorsun. Uzay programı değil bu evlat.",
            "Nasıl çalışıyor diye soruyorsan kısa anlatayım: iş seç, ter dök, geri gel, paranı kap. Hayatın özeti de bu zaten.",
        },

        select_region = {
            "Hadi, hangi tarlaya gideceksen seç. Ben burada kök saldım, sen salma.",
            "Karar ver evlat, hangi tarla? Güneş tepeme vuruyor, sabrım da gölgede kaldı.",
            "Tarla seç. Hayattaki en zor karar bu değil, rahat ol.",
        },

        region_select_ok = {
            "{region} ha? Güzel seçim. O toprak zamanında beni doyurdu, şimdi sıra sende.",
            "{region} iyidir. Orayı bilirim ben... bir kere orada yuvarlandım ama mevzu bende kalsın.",
            "Tamam, {region} oldu. Hadi oyalanma, tarla seni bekliyor.",
            "{region} seçtin demek. Mantıklı seçim. Ben de giderdim ama bu dizler artık dekor niyetine.",
        },

        region_select_locked = {
            "Hop, yavaş. Orası için seviye {level} lazım. Daha gazla gidiyorsun, motor kadar değilsin.",
            "O tarla sana şu an ağır gelir. Önce {level}. seviyeye ulaş, sonra artistliğe başlarsın.",
            "Oraya girmek için {level} gerekiyor evlat. Her kapı omuz atınca açılmıyor.",
        },

        invite_who = {
            "Kimi çağırıyorsun yanına? Meraktan değil, düzen olsun diye soruyorum.",
            "Ekibe kim geliyor? Söyle de en azından kimin ne kadar dert olacağını bileyim.",
            "Yanına adam alacaksan akıllısını al. Tarla tek başına zor, aptalla daha da zor.",
        },

        invite_sent = {
            "{name}'e haber uçtu. Gelirse adamdır, gelmezse bahanesi hazırdır.",
            "Tamam, {name} haberdar. Şimdi bekleyeceğiz. Ben zaten ömrümün yarısını bekleyerek geçirdim.",
            "{name}'e söyledim. Gelirse iyi, gelmezse kader... ya da tembellik.",
        },

        kick_confirm = {
            "{name} mi? Tamam, yol verdik. Darısı diğer gevşeklerin başına.",
            "Oldu, {name} ekipten çıktı. Ben karışmam, emir büyük yerden.",
            "{name}'e kapıyı gösterdim. İnşallah dışarıda yönünü de bulur.",
        },

        start_job = {
            "Hadi bakalım, yolun açık olsun. Tarlayı da fazla travmaya sokma.",
            "Git artık. Tarla orada, ben burada. Hayat da böyle; biri gider, biri bekler.",
            "Kolay gelsin evlat. Kırk yıllık emeği beş dakikada çöplüğe çevirme yeter.",
            "Yürü git. Bir şey olursa önce kendin çözmeye çalış, ben panikle düşünemiyorum.",
        },

        quit_warning = {
            "İşi bırakacaksan para mara yok, baştan söyleyeyim. Sonra 'haberim yoktu' diye dolanma.",
            "Yarıda çıkarsan ödeme alamazsın. Bunu anladın mı? Gerçekten anladın mı, yoksa kafa geziyor mu?",
            "Gidersen para da gider. Hayat bazen böyledir, bazen de daha kötüdür.",
        },

        quit_cancelled = {
            "Heh, aklın başına geldi. Dön işine şimdi, beni de boş yere hararetlendirme.",
            "Doğru karar. Hadi uzatma, işe devam et.",
            "Güzel. Demek beynin tamamen tatile çıkmamış henüz.",
        },

        quit_confirmed = {
            "Peki. Git o zaman. Allah yolunu açık etsin, cebini değil.",
            "Tamam, çıkıyorsun. Bir dahaki sefere biraz daha akılla gelirsin.",
            "Anlaşıldı. Kapı orada. Dram yapmadan çıkarsan sevinirim.",
        },

        clothes_changed = {
            "Oldu bu iş. Giyindin kuşandın, şimdi çalış da görelim.",
            "Tamamdır, üstünü başını hallettik. Süs değil iş bekliyorum haberin olsun.",
            "Hazırsın artık. Keşke ben de senin yaşında böyle hızlı toparlansaydım.",
        },

        searching_players = {
            "Dur bakayım... etrafta adam var mı... Göz var nizam var da bende ikisi de yarım çalışıyor.",
            "Şöyle bir çevreye bakıyorum... biri vardır belki. Gözlük yine ortalıkta yok tabii.",
            "Hele bi etrafa göz gezdireyim. İnsan var mı, yoksa yine yalnızlığa mı kaldık?",
        },

        no_friends_nearby = {
            "Yok, kimse yok. Tek başınasın. Korkma, insan zamanla buna alışıyor. Ben alıştım mesela.",
            "Yakında kimsecikler yok. Yalnız gideceksin. En azından kimse başını ağrıtmaz.",
            "Etrafta dost most görünmüyor. Sen de benim gibi kendi kendine söylene söylene takılacaksın anlaşılan.",
        },
    },


    ['en'] = {

        harvest_perfect = {
            "Zero mistakes? I'll be damned. I haven't seen that since... well, I can't remember when. My memory ain't what it used to be. But still — nice work.",
            "Perfect harvest? Lord almighty. My late wife couldn't've done better, and she was half farmer herself. God rest her soul.",
            "Not a single wasted crop. I'd cry if my tear ducts still worked right. My knee's been actin' up too. Anyway — great job.",
            "Well I'll be. You didn't mess up once. I tried that every year since '74. Then my back went. But you did it. Good for you.",
            "Clean sweep! In forty years of farming I never managed that. To be fair, I was distracted by a chicken incident in '89.",
        },

        harvest_good = {
            "Solid work. Few mistakes but nothin' worth cryin' about. Lord knows I've made worse. Much worse.",
            "Good enough. My neighbor Hank used to say 'good enough is good enough.' Then he went bankrupt. But you'll be fine.",
            "You earned your money today. Come back tomorrow. Or don't. I'll be here either way, standin' in this same spot.",
            "Nice haul. Few wobbles but the field's intact. That's more than I can say for my left hip.",
            "Pretty good run. Not perfect but who's perfect? Not me. Not anymore anyway.",
        },

        harvest_mixed = {
            "Well... some of it was real good, some of it was rough. Story of my life, honestly.",
            "Half decent, half a disaster. Reminds me of my second marriage. Wait, I only had one. Same thing though.",
            "You started strong and then somethin' happened. I don't know what. Neither do you, probably.",
            "Middlin'. That's the word. Middlin'. Not bad, not good. Like a warm soda.",
            "The field's seen better and worse. We'll call it a wash. Come back tomorrow and try not to repeat... whatever that was.",
        },

        harvest_failed = {
            "Son, what in the tarnation happened out there? That field looks like a crime scene.",
            "I ain't gonna yell. I'm too tired to yell. I just wanna know: why? WHY?",
            "Three steps: water, grow, harvest. Three! My rooster figured it out and he's dumber than a fence post.",
            "You really made a mess of it today. Go home, eat something, sleep. We'll pretend this didn't happen.",
            "Rough day. Real rough. I once had a mule that destroyed two acres of corn. But you? You've outdone that mule.",
        },

        greet_novice = {
            "New face. Welcome. I'd shake your hand but my arthritis is actin' up. What do you want?",
            "Fresh blood! Don't worry, everyone starts somewhere. I started in 1967. Things were different then. Worse, mostly.",
            "You're new. I can tell by them eyes — full of hope. That'll go away. But for now, welcome.",
            "Oh, a newcomer. Good. I'm runnin' out of things to talk to. The crops don't talk back, I'll tell ya that.",
        },

        greet_junior = {
            "Hey, you're back. Good. I forgot your name. I'll call you 'you.' You okay with that?",
            "There you are. Gettin' the hang of it, are ya? Good. It gets easier. Sort of. Not really.",
            "Back again! I almost didn't recognize you. My eyes ain't great. Neither's my memory.",
            "Well, look who decided to show up. Welcome back. The field missed you. Or maybe that was the wind.",
        },

        greet_veteran = {
            "Well now, the professional's arrived. My day just got a little better. Just a little.",
            "Hey there, old hand. Which field we workin' today? My knee's holdin' up so I'm in a decent mood.",
            "Good to see ya. Truly. These young kids are driving me up the wall with their questions.",
            "Afternoon. Or mornin'. I've lost track. Anyway — good to have ya back.",
        },

        greet_legend = {
            "Well I'll be damned. A living legend walks onto my farm. I would've cleaned the place up but, eh.",
            "You again? Good. You're my favorite. Don't tell the others — not that there are others of your caliber.",
            "The legend arrives. Hold on, let me tip my cap. I lost my cap. Symbolically — I'm honoring you.",
            "I've been farming since before you were born and I still can't do what you do. That either means you're great or I'm terrible. Probably both.",
        },

        work_clothes = {
            "You came dressed for the job. That's already better than eighty percent of folks I see. Good on ya.",
            "Look at that, all suited up. I had a uniform once. The goats ate it. That was a bad week.",
            "Proper outfit. I like that. Shows commitment. Or at least it shows you own a change of clothes.",
        },

        hard_attempt = {
            "Hard mode, huh? You're either very good or very optimistic. Could be both. Could be neither.",
            "Goin' Hard? Lord help ya. That field does not forgive. I know from personal experience. And physical therapy.",
            "Hard difficulty? Alright. You asked for it. I'm not responsible for what happens next.",
        },

        hard_complete = {
            "You finished Hard? I need to sit down. I'm already sittin'. I need to sit down harder.",
            "Hard mode — done. I've been trying to pull that off since Reagan was president. You did it first try? Good grief.",
            "Well I'll be. Hard's done. The field respects you now. Fields don't really respect anything but still.",
        },

        streak_3 = {
            "Three days running. That's consistency. I had a three-day streak in '78. Then it rained for a week.",
            "Day three! Keep the streak alive. I believe in you. More than I believe in my knee, anyway.",
        },
        streak_7 = {
            "Seven days in a row. A whole week. That's dedication. I'm genuinely impressed, which doesn't happen often.",
            "A full week without missing a day. Back in my day we called that 'Tuesday through Monday.' We worked every day. But still — good on ya.",
        },

        group_create = {
            "You're forming a crew? Leadership's a fine thing. Responsibility is a terrible thing. They come together.",
            "A team leader, huh? Good for you. Now everyone's mistakes are also your mistakes. Congratulations.",
        },
        group_join = {
            "Joining up with a crew. Good call. More hands, less misery.",
            "You're a team player. I respect that. I'm more of a 'standing here alone in the dark' player but different strokes.",
        },

        level_up = {
            "Level up! Good work. You're movin' on up. I moved on up once. Then my knee went.",
            "You're growin' kid. Right before my eyes. My late wife would've liked you. She had a thing for hard workers.",
            "New level! Keep goin'. At this rate you'll be runnin' the whole operation. Which'd be fine by me. My back's killin' me.",
        },

        greet_active_job = {
            "Back already? Job ain't done is it? I wasn't expectin' ya this soon.",
            "What happened? Field closed down on ya? I've seen stranger things, believe me.",
            "You're still on the clock, ain't ya? What do you need?",
            "Mid-job visit, huh? Alright, make it quick. What's goin' on?",
        },

        help_response = {
            "Simple: pick a field, go there, do the work, come back. Five steps. If five steps is too many, farmin' ain't for you.",
            "Here's how it works: field, crops, harvest, money. That's it. Been workin' that way since before you were born. Probably before your daddy too.",
            "You pick a field. You go. You work the minigame. You bring back the goods. I give you money. Same process since 1974. Nothing's changed.",
        },

        select_region = {
            "Which field you headin' to? Pick one. I got time but not infinite time.",
            "Alright, which field? Just point at one. Any one. They all need work.",
            "Choose a field. There's only a few options. This shouldn't take long.",
        },

        region_select_ok = {
            "{region}? Good pick. That field's treated me well over the years. Threw out my back there once but still.",
            "{region} it is. Good field. I know it well. Me and that field have had a complicated relationship.",
            "Alright, {region}. Smart choice. You'll do fine out there. Probably.",
            "{region}, huh? I'd pick it myself but my knee says otherwise. Go on then.",
        },

        region_select_locked = {
            "Hold your horses. That field needs level {level}. You ain't there yet. Close maybe. But not yet.",
            "Not that one. You need to be level {level} first. The field'll eat you alive right now.",
            "That field's gonna humble you real quick. Come back when you're at level {level}.",
        },

        invite_who = {
            "Who you bringin' along? Not that I'm keepin' track. I just like to know.",
            "You takin' someone with ya? Smart. More hands make light work. Or so they say. I've worked alone most of my life.",
            "Who's comin'? Tell me. I ain't writin' it down but I wanna hear it.",
        },

        invite_sent = {
            "Word's out to {name}. They show up or they don't. That's their prerogative.",
            "Sent a message to {name}. Now we wait. I'm good at waitin'. I've been waitin' for my back to heal since 2003.",
            "Told {name}. Ball's in their court.",
        },

        kick_confirm = {
            "Done. {name}'s gone. I didn't say nothin'. You made the call.",
            "{name}'s been removed. I've seen it before. People come, people go. The crop remains.",
            "Handled. {name}'s off the crew. Happens. Next.",
        },

        start_job = {
            "Off you go. Stay sharp out there and don't break my field.",
            "Alright, the field's waitin'. Don't keep it waitin' too long. Fields get impatient. Or maybe that's just me.",
            "Good luck. And I mean that. The field looks tougher than usual today. Or my eyes are goin' bad again.",
            "Go on. Work hard. Come back in one piece. And for the love of all that's holy, don't knock over the fence posts.",
        },

        quit_warning = {
            "You wanna quit? Fine. But there's no pay. You understand that? Zero dollars. I want to make sure you heard that part.",
            "Walkin' away means walkin' away empty-handed. I ain't judgin'. Just statin' facts. You sure?",
            "If you go now, the money stays here with me. You wanna do this? Think. Take your time. I got nowhere to be.",
        },

        quit_cancelled = {
            "Smart. Get back out there.",
            "Good. Don't let me see you in here again until that job's done.",
            "Right call. Now go. Shoo.",
        },

        quit_confirmed = {
            "Alright. Your loss. Literally.",
            "Fine by me. Come back when you're ready to commit.",
            "Door's open. Watch your step on the way out.",
        },

        clothes_changed = {
            "There ya go. Now get moving.",
            "Done. You're suited up. Go on.",
            "That's sorted. Anything else or can I go back to standin' here doin' nothin'?",
        },

        searching_players = {
            "Lemme look around... give me a second, my eyes ain't what they were.",
            "One moment, checkin' who's nearby... there might be someone... maybe...",
            "Hold on... scannin' the area... I can still do this much at least.",
        },

        no_friends_nearby = {
            "Nobody around. You're on your own. Welcome to my world.",
            "Looked everywhere. Just you. That's fine. Some of my best work was solo. Most of my worst too.",
            "No one nearby right now. I'd come with ya but, well, the knee.",
        },
    },
}
