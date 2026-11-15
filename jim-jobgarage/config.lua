Config = {
	Lan = "tr",
	System = {
		Debug = false,  -- Enable to use debug features (geçici olarak true yaptık)
		Menu = "ox",
		Notify = "ox",
	},

	General = {
		Fuel = "savana-fuel", -- Set this to your fuel script folder (ox_fuel, LegacyFuel, cdn-fuel, savana-fuel)
		CarDespawn = true, -- Sends the vehicle to hell (removal animation)
		DistCheck = false, -- Require the vehicle to be near by to remove it
		SaveToDatabase = true, -- Araçlar veritabanına kaydedilsin mi? (true/false)
	},

	Database = {
		CheckDuplicatePlates = true, -- Aynı plakadan birden fazla araç kaydını kontrol et
		DefaultGarage = "jobgarage", -- Araçların kaydedileceği varsayılan garaj adı
		NotifyPlayer = true, -- Oyuncuya araç kaydedildiğinde bildirim gönder
		SaveMods = true, -- Araç modifikasyonlarını kaydet
		DefaultFuel = 100, -- Varsayılan yakıt seviyesi
		DefaultEngine = 1000, -- Varsayılan motor sağlığı
		DefaultBody = 1000, -- Varsayılan kasa sağlığı
	},
}
