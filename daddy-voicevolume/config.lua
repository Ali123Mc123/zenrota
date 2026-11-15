Config = {}

-- UI'ı açıp kapatan komut/tuş. Oyuncu FiveM ayarlarından tuşu değiştirebilir.
Config.OpenCommand = 'voicevolume'
Config.OpenKey = 'F10'

-- Panelde listelenecek "yakındaki oyuncu" yarıçapı (metre).
-- Native audio bağırma menzili ile aynı: proximity 6.0 * 3 = 18m.
Config.ListRange = 18.0

-- Panel açıkken listenin tazelenme periyodu (ms). Sadece UI açıkken çalışır.
Config.RefreshInterval = 1500

-- Override'ı pma-voice'a karşı diri tutan ve mesafe fade'ini güncelleyen thread periyodu (ms).
Config.ReapplyInterval = 200

-- MumbleSetVolumeOverrideByServerId için izin verilen aralık.
-- Minimum ses %5 (0.05): Mute atılamaz.
-- Varsayılan başlangıç sesi %50 (0.5): Oyuncu sesleri yukarı (%100) artırılabilir veya aşağı (%5) kısılabilir.
Config.MinVolume = 0.05
Config.DefaultVolume = 0.5
Config.MaxVolume = 1.0

-- Maske (component 1) takılıyken gösterilecek isimler. QBX gender: 0 erkek, 1 kadın.
Config.MaskedMaleLabel = 'Bilinmeyen Erkek'
Config.MaskedFemaleLabel = 'Bilinmeyen Kadın'
