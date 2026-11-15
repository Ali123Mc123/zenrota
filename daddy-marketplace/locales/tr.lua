-- ═══════════════════════════════════════════════════════════════════════════════
-- Daddy Marketplace - Türkçe Dil Dosyası
-- ═══════════════════════════════════════════════════════════════════════════════

Locales = Locales or {}

Locales['tr'] = {
    ['notify.offline_sales'] = 'Pazar Yeri: sen yokken %d satışın oldu, paran bankana yatırıldı.',
    ['notify.offline_other'] = 'Pazar Yeri: sen yokken %d ilanının süresi doldu ya da bir işlem oldu. Eşyalar envanterine teslim edilir.',
    -- Discord logs
    ['log.listing_created'] = '%s pazara ilan verdi',
    ['log.listing_cancelled'] = '%s ilanını kaldırdı',
    ['log.listing_expired'] = '%s adlı oyuncunun ilanının süresi doldu',
    ['log.featured'] = '%s ilanını öne çıkardı',
    ['log.featured_auction'] = '%s açık artırmasını öne çıkardı',
    ['log.sale'] = '%s pazardan ürün satın aldı',
    ['log.auction_created'] = '%s açık artırma başlattı',
    ['log.auction_cancelled'] = '%s açık artırmasını iptal etti',
    ['log.bid'] = '%s açık artırmaya teklif verdi',
    ['log.auction_won'] = '%s açık artırmayı kazandı',
    ['log.auction_buyout'] = '%s açık artırmadaki ürünü hemen satın aldı',
    ['log.auction_no_bids'] = '%s adlı oyuncunun açık artırması teklifsiz bitti',
    ['log.auction_unpaid'] = '%s açık artırmayı kazandı ama ödeyemedi',
    ['log.offer_made'] = '%s bir ilana pazarlık teklifi verdi',
    ['log.offer_accepted'] = '%s pazarlıkla ürün satın aldı',
    ['log.buyorder_created'] = '%s satın alma talebi açtı',
    ['log.buyorder_filled'] = '%s satın alma talebine ürün sattı',
    ['log.buyorder_cancelled'] = '%s satın alma talebini iptal etti',
    ['log.buyorder_expired'] = '%s adlı oyuncunun satın alma talebinin süresi doldu',
    ['log.admin_listing'] = '%s #%s numaralı ilanı kaldırdı',
    ['log.admin_auction'] = '%s #%s numaralı açık artırmayı iptal etti',
    ['log.admin_buyorder'] = '%s #%s numaralı satın alma talebini iptal etti',
    ['log.pay_offline'] = '%s çevrimdışıyken hesabına satış parası yattı',
    ['log.pay_refund'] = '%s çevrimdışıyken hesabına iade yattı',
    ['log.pay_failed'] = '%s adlı oyuncuya ödeme yapılamadı',
    ['log.flag_pay_failed'] = 'Para hesaba geçmedi, elle ödenmeli',
    ['log.flag_unpaid'] = 'Kazanan ödeyemedi, ürün satıcıya geri döndü',
    ['log.f_seller'] = 'Satıcı',
    ['log.f_buyer'] = 'Alıcı',
    ['log.f_bidder'] = 'En yüksek teklif veren',
    ['log.f_owner'] = 'Sahibi',
    ['log.f_unit'] = 'Birim fiyat',
    ['log.f_fee'] = 'Ücret',
    ['log.f_payout'] = 'Satıcıya geçen',
    ['log.f_sale'] = 'Satış tutarı',
    ['log.f_market'] = 'Pazar',
    ['log.f_ref'] = 'Kayıt',
    ['log.f_refund'] = 'İade',
    ['log.f_duration'] = 'Süre',
    ['log.f_bids'] = 'Teklif sayısı',
    ['log.f_prev_bid'] = 'Önceki teklif',
    ['log.f_asking'] = 'İstenen fiyat',
    ['log.f_start'] = 'Başlangıç fiyatı',
    ['log.f_buyout'] = 'Hemen al fiyatı',
    ['log.f_hidden'] = 'Satıcı adı gizli',
    ['log.ref_listing'] = 'İlan #%s',
    ['log.ref_auction'] = 'Açık artırma #%s',
    ['log.ref_offer'] = 'Teklif #%s',
    ['log.ref_order'] = 'Satın alma talebi #%s',
    ['log.hours'] = '%s saat',
    ['log.minutes'] = '%s dakika',
    ['log.yes'] = 'Evet',
    ['log.console'] = 'Konsol',
    ['log.cash'] = 'nakit',
    ['log.bank'] = 'banka',
    -- ─────────────────────────────────────────────────────────────────────────
    -- Genel / UI
    -- ─────────────────────────────────────────────────────────────────────────
    ['ui.confirm']                  = 'Onayla',
    ['ui.cancel']                   = 'İptal',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Navigasyon
    -- ─────────────────────────────────────────────────────────────────────────
    ['nav.dashboard']               = 'Panel',
    ['nav.marketplace']             = 'Pazar Yeri',
    ['nav.buy_orders']              = 'Satın Alma Talepleri',
    ['nav.offers']                  = 'Teklifler',
    ['nav.auctions']                = 'Açık Artırma',
    ['nav.my_listings']             = 'İlanlarım',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Panel / Dashboard
    -- ─────────────────────────────────────────────────────────────────────────
    ['dashboard.welcome']           = 'Tekrar hoş geldin,',
    ['dashboard.subtitle']          = 'Pazarda {0} aktif ilanın var',
    ['dashboard.net_worth']         = 'Net Değer',
    ['dashboard.active_listings']   = 'Aktif İlanlar',
    ['dashboard.potential_earnings'] = 'Potansiyel Kazanç',
    ['dashboard.inventory_items']   = 'Envanter Eşyaları',
    ['dashboard.market_pulse']      = 'Piyasa Nabzı',
    ['dashboard.pulse_listings']    = 'Aktif İlan',
    ['dashboard.pulse_auctions']    = 'Aktif Açık Artırma',
    ['dashboard.pulse_trades_today'] = 'Bugünkü İşlem',
    ['dashboard.top_items']         = 'En Çok Satılan Eşyalar',
    ['dashboard.no_top_items']      = 'Henüz satış yok.',
    ['dashboard.ending_soon']       = 'Yakında Bitecek',
    ['dashboard.no_ending_soon']    = 'Yakında bitecek açık artırma yok.',
    ['dashboard.quick_actions']     = 'Hızlı Aksiyonlar',
    ['dashboard.sales_chart']       = 'Satışların (Son 30 Gün)',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Marketplace
    -- ─────────────────────────────────────────────────────────────────────────
    ['market.quantity']             = 'Miktar',
    ['market.empty_subtitle']        = 'Aradığınızı bulmak için arama veya filtrelerinizi değiştirmeyi deneyin.',
    ['market.empty_action']          = 'Filtreleri Sıfırla',

    -- ─────────────────────────────────────────────────────────────────────────
    -- İlan Oluşturma
    -- ─────────────────────────────────────────────────────────────────────────
    ['create.title']                = 'İlan Oluştur',
    ['create.item']                 = 'Eşya',
    ['create.price']                = 'Birim Fiyat',
    ['create.duration_minutes']     = 'dakika',
    ['create.submit']               = 'İlan Ver',
    ['create.available']            = 'Mevcut',
    ['create.per_item']             = 'Birim Satış',
    ['create.show_name']            = 'İlanda ismimi göster',
    ['create.amount']               = 'Miktar',
    ['create.max_reached']          = 'Maksimum ilan sayısına ulaşıldı',
    ['create.requirements_title']   = 'Oluşturmak için eksik kalanlar',
    ['create.blocker.select_item']  = 'Önce envanterinden bir eşya seçmelisin.',
    ['create.blocker.amount']       = 'Satış miktarını 1 veya daha yüksek yapmalısın.',
    ['create.blocker.listing_price_min'] = 'İlan fiyatı minimum %s olmalı.',
    ['create.blocker.listing_price_max'] = 'İlan fiyatı maksimum %s olabilir.',
    ['create.blocker.max_listings'] = 'Aktif ilan limitine ulaştın.',
    ['create.blocker.auction_price_min'] = 'Açık artırma başlangıç fiyatını minimum %s yapmalısın.',
    ['create.blocker.auction_price_max'] = 'Açık artırma başlangıç fiyatı maksimum %s olabilir.',
    ['create.blocker.buyout_negative'] = 'Hemen al fiyatı negatif olamaz.',
    ['create.blocker.buyout_lower'] = 'Hemen al fiyatı başlangıç fiyatından yüksek olmalı ya da 0 bırakılmalı.',
    ['create.blocker.buyout_max']   = 'Hemen al fiyatı maksimum %s olabilir.',
    ['create.blocker.duration_min'] = 'Süre en az %s dakika olmalı.',
    ['create.blocker.duration_max'] = 'Süre en fazla %s dakika olabilir.',
    ['create.blocker.max_auctions'] = 'Aktif açık artırma limitine ulaştın.',
    ['create.suggested_price']      = 'Önerilen fiyat: ~{0} (son satışlara göre)',
    ['create.use_suggested']        = 'Kullan',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Satın Alma
    -- ─────────────────────────────────────────────────────────────────────────
    ['purchase.cash']               = 'Nakit',
    ['purchase.bank']               = 'Banka',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Açık Artırma
    -- ─────────────────────────────────────────────────────────────────────────
    ['auction.current_bid']         = 'Güncel Teklif',
    ['auction.min_bid']             = 'Minimum Teklif',
    ['auction.place_bid']           = 'Teklif Ver',
    ['auction.ended']               = 'Sona Erdi',
    ['auction.no_bids']             = 'Henüz teklif yok',
    ['auction.highest_bidder']      = 'En Yüksek Teklif',
    ['auction.no_auctions']         = 'Aktif açık artırma yok',
    ['auction.empty_subtitle']       = 'Filtrelerinize uyan açık artırma bulunamadı. Daha sonra tekrar kontrol edin veya kendiniz oluşturun!',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Kendi İlanlarım
    -- ─────────────────────────────────────────────────────────────────────────
    ['my.title']                    = 'İlanlarım',
    ['my.cancel_listing']           = 'İlanı İptal Et',
    ['my.cancel_auction']           = 'Açık Artırmayı İptal Et',
    ['my.edit_listing']             = 'Düzenle',
    ['my.save_changes']             = 'Değişiklikleri Kaydet',
    ['my.no_listings']              = 'Henüz ilanın yok',
    ['my.empty_subtitle']            = 'Yeni bir ilan veya açık artırma oluşturarak satışa başlayın. Eşyalarınız tüm alıcılara görünür olacaktır.',
    ['my.new_listing']              = 'Yeni İlan',
    ['my.new_auction']              = 'Yeni Açık Artırma',
    ['my.listings_count']           = 'İlanlar',
    ['my.auctions_count']           = 'Açık Artırmalar',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Geçmiş
    -- ─────────────────────────────────────────────────────────────────────────
    ['history.title']               = 'İşlem Geçmişi',
    ['history.auction_sell']        = 'Açık Artırma Satıldı',
    ['history.buyorder_sale']       = 'Satın Alma Talebine Satış',
    ['history.buyorder_purchase']   = 'Satın Alma Talebi Alışı',
    ['history.no_history']          = 'İşlem geçmişi yok',
    ['history.empty_subtitle']       = 'Alım satım yaptığınızda satın almalarınız, satışlarınız ve açık artırma sonuçlarınız burada görünecektir.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Kategoriler
    -- ─────────────────────────────────────────────────────────────────────────
    ['category.food']               = 'Yiyecek & İçecek',
    ['category.materials']          = 'Malzemeler',
    ['category.tools']              = 'Aletler',
    ['category.electronics']        = 'Elektronik',
    ['category.clothing']           = 'Kıyafetler',
    ['category.medical']            = 'Medikal',
    ['category.farming']            = 'Çiftçilik',
    ['category.misc']               = 'Diğer',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Bildirimler
    -- ─────────────────────────────────────────────────────────────────────────
    ['notify.listing_created']      = 'Eşya pazar yerine listelendi!',
    ['notify.listing_updated']      = 'İlan başarıyla güncellendi!',
    ['notify.listing_cancelled']    = 'İlan iptal edildi. Eşyalar iade edildi.',
    ['notify.purchase_success']     = 'Satın alma başarılı!',
    ['notify.item_sold']            = 'Eşyan satıldı!',
    ['notify.auction_created']      = 'Açık artırma başlatıldı!',
    ['notify.auction_cancelled']    = 'Açık artırma iptal edildi. Eşya iade edildi.',
    ['notify.auction_cancelled_bidder'] = 'Teklif verdiğiniz %s açık artırması satıcı tarafından iptal edildi.',
    ['notify.bid_placed']           = 'Teklif başarıyla verildi!',
    ['notify.bid_outbid']           = '%s için teklifin geçildi!',
    ['notify.bid_refunded']         = '%s için bloke edilen teklif tutarın iade edildi.',
    ['notify.auction_new_bid']      = '%s için açık artırmanıza yeni teklif geldi: $%d',
    ['notify.auction_won']          = '%s için açık artırmayı kazandın!',
    ['notify.auction_sold']         = '%s için açık artırma sona erdi. Kazanan: %s',
    ['notify.auction_no_bids']      = '%s için açık artırma teklif almadan sona erdi. Eşyalar iade edildi.',
    ['notify.not_enough_money']     = 'Yeterli paran yok!',
    ['notify.payment_not_allowed']  = 'Bu eşya bu ödeme yöntemiyle satın alınamaz!',
    ['notify.inventory_full']       = 'Envanterin dolu!',
    ['notify.item_blacklisted']     = 'Bu eşya satışa konulamaz!',
    ['notify.not_enough_items']     = 'Yeterli eşyan yok!',
    ['notify.max_listings']         = 'Maksimum ilan sayısına ulaştın!',
    ['notify.max_auctions']         = 'Maksimum aktif açık artırma sayısına ulaştın!',
    ['notify.invalid_price']        = 'Geçersiz fiyat!',
    ['notify.invalid_auction_duration'] = 'Açık artırma süresi geçersiz!',
    ['notify.auction_missing_fields'] = 'Açık artırmayı başlatmak için tüm gerekli alanları doldurmalısın!',
    ['notify.invalid_quantity']     = 'Geçersiz miktar!',
    ['notify.too_far']              = 'Pazar yerinden çok uzaktasın!',
    ['notify.job_restricted']       = 'Mesleğin bu pazar yerine erişemez!',
    ['notify.own_listing']          = 'Kendi ilanını satın alamazsın!',
    ['notify.listing_not_found']    = 'Bu ilan artık mevcut değil!',
    ['notify.bid_too_low']          = 'Teklifin çok düşük!',
    ['notify.cannot_bid_own']       = 'Kendi açık artırmana teklif veremezsin!',
    ['notify.rate_limited']         = 'Lütfen tekrar denemeden önce bekle!',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Teklifler / Offers
    -- ─────────────────────────────────────────────────────────────────────────
    ['notify.offer_sent']           = 'Teklifiniz gönderildi!',
    ['notify.offer_received']       = '%s için yeni bir teklif aldınız!',
    ['notify.offer_cancelled_refund'] = 'Bir teklif iptal edildi. Emanet iadeniz yapıldı.',
    ['notify.offer_accepted_buyer'] = '%s için teklifiniz kabul edildi!',
    ['notify.offer_accepted_seller'] = 'Teklifi kabul ettiniz. Ödeme alındı!',
    ['notify.offer_rejected']       = 'Teklif reddedildi.',
    ['notify.offer_rejected_buyer'] = '%s için teklifiniz reddedildi.',
    ['notify.offer_withdrawn']      = 'Teklif başarıyla geri çekildi.',
    ['notify.counter_sent']         = 'Karşı teklif gönderildi.',
    ['notify.counter_received']     = '%s için karşı teklif aldın: $%d',
    ['notify.counter_accepted_seller'] = '%s için karşı teklifin kabul edildi — satış tamamlandı!',
    ['notify.counter_rejected']     = 'Karşı teklif reddedildi, teklifin iade edildi.',
    ['notify.counter_rejected_seller'] = '%s için karşı teklifin reddedildi.',
    ['notify.offer_expired_refund'] = 'Teklifinizin süresi doldu. Emanet iade edildi.',
    ['notify.offer_too_low']        = 'Teklifiniz çok düşük!',
    ['notify.offer_not_found']      = 'Teklif bulunamadı veya zaten işlendi.',
    ['notify.already_offered']      = 'Bu ilana zaten bekleyen bir teklifiniz var.',
    ['notify.max_offers']           = 'Maksimum aktif teklif sayısına ulaştınız.',
    ['notify.cannot_offer_own']     = 'Kendi ilanınıza teklif veremezsiniz.',
    ['notify.offer_buyer_no_money'] = 'Alıcının bu teklif için yeterli parası yok.',
    ['notify.error']                = 'Bir hata oluştu. Lütfen tekrar deneyin.',
    ['notify.auction_ended']        = 'Bu açık artırma zaten sona erdi!',
    ['notify.listing_expired']      = '%s ilanınızın süresi doldu. Eşyalar iade edildi.',
    ['notify.pending_delivery']     = 'Bekleyen teslimat: %s (x%d) envanterinize eklendi!',
    ['notify.pending_delivery_no_money'] = 'Bekleyen açık artırma eşyası %s için yeterli paranız yok. Paranız olduğunda teslim edilecek.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Buy Orders
    -- ─────────────────────────────────────────────────────────────────────────
    ['notify.buyorder_created']     = 'Satın alma talebi oluşturuldu: %s x%d',
    ['notify.buyorder_cancelled']   = '%s için satın alma talebi iptal edildi. Kalan emanet iade edildi.',
    ['notify.buyorder_sold']        = '%s x%d sattınız, $%d kazandınız!',
    ['notify.buyorder_fulfilled_partial'] = 'Satın alma talebinizin bir kısmı karşılandı: %s x%d teslim edildi!',
    ['notify.buyorder_fulfilled_full'] = 'Satın alma talebiniz tamamen karşılandı: %s',
    ['notify.buyorder_claimed']     = 'Depodan %s x%d alındı!',
    ['notify.buyorder_expired']     = '%s için satın alma talebinizin süresi doldu. Kalan emanet iade edildi.',
    ['notify.buyorder_not_found']   = 'Satın alma talebi bulunamadı veya artık aktif değil.',
    ['notify.buyorder_cannot_sell_own'] = 'Kendi satın alma talebinize satamazsınız.',
    ['notify.buyorder_full_only']   = 'Bu talep tam karşılama gerektiriyor.',
    ['notify.buyorder_need_item']   = 'Satın alma talebi oluşturmak için envanterinizde en az 1 adet bu eşyadan olmalıdır.',
    ['notify.buyorder_max_reached'] = 'Maksimum aktif satın alma talebi sayısına ulaştınız.',
    ['notify.buyorder_nothing_to_claim'] = 'Alınacak eşya yok.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Zaman
    -- ─────────────────────────────────────────────────────────────────────────
    ['time.days']                   = 'g',
    ['time.hours']                  = 's',
    ['time.minutes']                = 'dk',
    ['time.seconds']                = 'sn',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Öne Çıkarma / Featured
    -- ─────────────────────────────────────────────────────────────────────────
    ['notify.featured_success']     = 'Eşyanız artık öne çıkarılıyor!',
    ['notify.already_featured']     = 'Bu eşya zaten öne çıkarılmış.',
    ['notify.max_featured']         = 'Maksimum öne çıkarma limitine ulaştınız.',
    ['notify.max_featured_location'] = 'Bu pazar yeri maksimum öne çıkarma limitine ulaştı.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Marketplace (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['market.search']               = 'Eşya ara...',
    ['market.no_results']           = 'Eşya bulunamadı.',
    ['market.add_to_cart']          = 'Sepete Ekle',
    ['market.in_cart']              = 'Sepette',
    ['market.seller']               = 'Satıcı',
    ['market.per_unit']             = 'birim',
    ['market.last_item']            = 'Son 1 kaldı!',
    ['market.sort.newest']          = 'En Yeni',
    ['market.sort.oldest']          = 'En Eski',
    ['market.sort.price_asc']       = 'Fiyat: Düşükten Yükseğe',
    ['market.sort.price_desc']      = 'Fiyat: Yüksekten Düşüğe',
    ['market.sort.name_asc']        = 'İsim: A-Z',
    ['market.sort.name_desc']       = 'İsim: Z-A',
    ['market.your_listing']         = 'Senin İlanın',
    ['market.more']                 = 'Daha Fazla',
    ['market.quick_select']         = 'Kategoriler',
    ['market.price_filter']         = 'Fiyat',
    ['market.price_min']            = 'Min',
    ['market.price_max']            = 'Max',
    ['market.price_apply']          = 'Uygula',
    ['market.price_clear']          = 'Temizle',
    ['market.current']              = 'Mevcut',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Sepet / Cart
    -- ─────────────────────────────────────────────────────────────────────────
    ['cart.title']                  = 'Sepet',
    ['cart.empty']                  = 'Sepetin boş.',
    ['cart.subtotal']               = 'Ara Toplam',
    ['cart.tax']                    = 'Vergi',
    ['cart.total']                  = 'Toplam',
    ['cart.clear']                  = 'Tümünü Temizle',
    ['cart.checkout']               = 'Ödeme',
    ['cart.save_for_later']         = 'Sonra için sakla',
    ['cart.saved_for_later']        = 'Sonra İçin Saklananlar',
    ['cart.move_to_cart']           = 'Sepet',
    ['cart.out_of_stock']           = 'Ürün artık mevcut değil',
    ['cart.stock_exceeded']         = 'Yeterli stok yok',
    ['cart.stock_warning']          = 'Bazı ürünlerde stok sorunu var. Ödeme için kaldırın veya güncelleyin.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Ödeme / Checkout
    -- ─────────────────────────────────────────────────────────────────────────
    ['checkout.title']              = 'Ödeme',
    ['checkout.payment']            = 'Ödeme Yöntemi',
    ['checkout.cash']               = 'Nakit',
    ['checkout.bank']               = 'Banka',
    ['checkout.confirm']            = 'Satın Almayı Onayla',
    ['checkout.cancel']             = 'İptal',
    ['checkout.insufficient']       = 'Yetersiz bakiye',
    ['checkout.confirm_large_title'] = 'Büyük satın alma',
    ['checkout.confirm_large_message'] = '{0} harcamak üzeresin. Bu işlem geri alınamaz.',
    ['checkout.confirm_large_button'] = 'Evet, satın al',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Açık Artırma (Frontend ek)
    -- ─────────────────────────────────────────────────────────────────────────
    ['auction.search']              = 'Açık artırma ara...',
    ['auction.bids']                = 'teklif',
    ['auction.outbid_warning']      = 'Teklifin geçildi!',
    ['auction.sort.ending_soon']    = 'Yakında Bitiyor',
    ['auction.sort.newest']         = 'En Yeni',
    ['auction.sort.bid_asc']        = 'Teklif: Düşükten Yükseğe',
    ['auction.sort.bid_desc']       = 'Teklif: Yüksekten Düşüğe',
    ['auction.sort.name_asc']       = 'İsim: A-Z',
    ['auction.sort.name_desc']      = 'İsim: Z-A',
    ['auction.tab.active']          = 'Aktif',
    ['auction.buyout']              = 'Hemen Al',
    ['auction.your_bid']            = 'En yüksek teklif senin',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Teklif Verme Modalı / Bid
    -- ─────────────────────────────────────────────────────────────────────────
    ['bid.title']                   = 'Teklif Ver',
    ['bid.amount']                  = 'Teklif Tutarı',
    ['bid.min']                     = 'Minimum teklif',
    ['bid.escrow_notice']           = 'Teklif tutarın, teklifin geçilene veya açık artırma bitene kadar bankandan bloke edilir.',
    ['bid.confirm']                 = 'Teklif Ver',
    ['bid.buyout_confirm']          = 'Hemen Al',
    ['bid.buyout_click_again']      = 'Onaylamak için tekrar tıkla',
    ['bid.use_buyout']              = 'Bir sonraki teklif hemen al fiyatına ulaşıyor. Hemen Al seçeneğini kullan.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Açık Artırma Oluşturma
    -- ─────────────────────────────────────────────────────────────────────────
    ['create_auction.title']        = 'Açık Artırma Oluştur',
    ['create_auction.start_price']  = 'Başlangıç Fiyatı',
    ['create_auction.buyout_price'] = 'Hemen Al Fiyatı',
    ['create_auction.duration']     = 'Süre (saat)',
    ['create_auction.submit']       = 'Açık Artırmayı Başlat',

    -- ─────────────────────────────────────────────────────────────────────────
    -- İlanlarım (Frontend ek)
    -- ─────────────────────────────────────────────────────────────────────────
    ['my.active_items']             = 'Aktif Eşyalar',
    ['my.total_value']              = 'Toplam Değer',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Geçmiş (Frontend ek)
    -- ─────────────────────────────────────────────────────────────────────────
    ['history.total_earnings']      = 'Toplam Kazanç',
    ['history.total_spending']      = 'Toplam Harcama',
    ['history.net_profit']          = 'Net Kar',
    ['history.transactions']        = 'İşlemler',
    ['history.filter.all']          = 'Tüm Zamanlar',
    ['history.filter.today']        = 'Bugün',
    ['history.filter.week']         = 'Bu Hafta',
    ['history.filter.month']        = 'Bu Ay',
    ['history.type_filter.all']     = 'Tümü',
    ['history.type_filter.purchases'] = 'Satın Almalar',
    ['history.type_filter.sales']   = 'Satışlar',
    ['history.type_filter.auctions'] = 'Açık Artırmalar',
    ['history.type_filter.cancelled'] = 'İptal Edilenler',
    ['history.sale']                = 'Satış',
    ['history.purchase']            = 'Satın Alma',
    ['history.auction_win']         = 'Açık Artırma Kazanıldı',
    ['history.listing_cancelled']   = 'İptal Edildi',
    ['history.auction_cancelled']   = 'Açık Artırma İptal',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Bildirimler (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['notification.title']          = 'Bildirimler',
    ['notification.empty']          = 'Henüz bildirim yok.',
    ['notification.mark_all_read']  = 'Tümünü okundu yap',
    ['notification.today']          = 'Bugün',
    ['notification.earlier']        = 'Daha Önce',
    ['notification.filter.all']     = 'Tümü',
    ['notification.filter.unread']  = 'Okunmamış',
    ['notification.filter.trade']   = 'Satış & Teklif',
    ['notification.filter.auction'] = 'Açık Artırma',
    ['notification.clear']          = 'Temizle',
    ['notification.just_now']       = 'Az önce',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Profil
    -- ─────────────────────────────────────────────────────────────────────────
    ['profile.title']               = 'Profilim',
    ['profile.activity']            = 'Satış Aktivitesi (Son 30 Gün)',
    ['profile.no_activity']         = 'Son 30 günde satış kaydı yok.',
    ['profile.level.bronze']        = 'Bronz',
    ['profile.level.silver']        = 'Gümüş',
    ['profile.level.gold']          = 'Altın',
    ['profile.level.platinum']      = 'Platin',
    ['profile.stats.transactions']  = 'İşlemler',
    ['profile.stats.sales']         = 'Satışlar',
    ['profile.stats.purchases']     = 'Alımlar',
    ['profile.stats.earned']        = 'Kazanılan',
    ['profile.badges']              = 'Rozetler',
    ['profile.badge.first_sale']    = 'İlk Satış',
    ['profile.badge.hot_seller']    = 'Popüler Satıcı',
    ['profile.badge.auction_king']  = 'Açık Artırma Kralı',
    ['profile.badge.veteran']       = 'Kıdemli',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Genel (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['general.cancel']              = 'İptal',
    ['general.items']               = 'eşya',
    ['general.less']                = 'Daha Az',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Teklifler / Offers (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['offer.title']                 = 'Teklif Ver',
    ['offer.make_offer']            = 'Teklif Ver',
    ['offer.offer_price']           = 'Teklif Fiyatı',
    ['offer.quantity']              = 'Miktar',
    ['offer.accept']                = 'Kabul Et',
    ['offer.reject']                = 'Reddet',
    ['offer.withdraw']              = 'Geri Çek',
    ['offer.pending']               = 'Bekliyor',
    ['offer.counter']               = 'Karşı Teklif',
    ['offer.counter_send']          = 'Gönder',
    ['offer.countered_waiting']     = 'Karşı teklif: {0}',
    ['offer.counter_received']      = 'Karşı teklif: {0}',
    ['offer.min_offer']             = 'Minimum teklif: {0}',
    ['offer.escrow_notice']         = 'Paranız teklif kabul edilene, reddedilene veya süresi dolana kadar emanette tutulacaktır.',
    ['offer.sent']                  = 'Gönderilen Teklifler',
    ['offer.received']              = 'Gelen Teklifler',
    ['offer.payment_method']        = 'Ödeme Yöntemi',
    ['offer.escrow_label']          = 'Emanet',
    ['offer.percentage_of_listing'] = 'ilan fiyatının %{0}\'i',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Buy Orders (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['buyorder.your_order']         = 'Senin Talebin',
    ['buyorder.per_unit']           = 'birim',
    ['buyorder.remaining']          = 'kalan',
    ['buyorder.fulfilled_label']    = 'karşılandı',
    ['buyorder.depot_items']        = 'depoda {0} eşya',
    ['buyorder.sell']               = 'Sat',
    ['buyorder.claim']              = 'Eşyaları Al',
    ['buyorder.no_item_in_inv']     = 'Bu eşyan yok',
    ['buyorder.stats.active']       = 'Aktif Talepler',
    ['buyorder.stats.unclaimed']    = 'Depoda',
    ['buyorder.stats.my_orders']    = 'Taleplerim',
    ['buyorder.tab.browse']         = 'Göz At',
    ['buyorder.tab.my_orders']      = 'Taleplerim',
    ['buyorder.search']             = 'Satın alma talebi ara...',
    ['buyorder.create']             = 'Talep Oluştur',
    ['buyorder.no_orders']          = 'Satın alma talebi bulunamadı.',
    ['buyorder.empty_subtitle_browse'] = 'Şu an hiç satın alma talebi yok. İhtiyacınız olan eşyaları talep etmek için bir tane oluşturun!',
    ['buyorder.empty_subtitle_my']  = 'Henüz satın alma talebi oluşturmadınız. Satıcıların neye ihtiyacınız olduğunu bilmesi için bir tane oluşturun.',
    ['buyorder.no_my_orders']       = 'Satın alma talebiniz yok.',
    ['buyorder.item_hint']          = 'Envanterinizde en az 1 adet bu eşyadan olmalıdır.',
    ['buyorder.no_items_available'] = 'Envanterinizde uygun eşya yok.',
    ['buyorder.price_per_unit']     = 'Birim Fiyat',
    ['buyorder.max_reached']        = 'Maksimum aktif satın alma talebi sayısına ulaşıldı.',
    ['buyorder.escrow_notice']      = 'Toplam tutar, talep karşılanana veya iptal edilene kadar emanette tutulacaktır.',
    ['buyorder.confirm_create']     = 'Talep Oluştur',
    ['buyorder.sell_title']         = 'Satın Alma Talebine Sat',
    ['buyorder.buyer']              = 'Alıcı',
    ['buyorder.quantity_to_sell']    = 'Satılacak Miktar',
    ['buyorder.full_only_notice']   = 'Kısmi karşılama devre dışı. Kalan miktarın tamamını satmalısınız.',
    ['buyorder.sell_amount']        = 'Satış Tutarı',
    ['buyorder.your_earnings']      = 'Kazancınız',
    ['buyorder.items_removed_notice'] = 'Eşyalar envanterinizden alınacak ve ödeme anında yapılacaktır.',
    ['buyorder.confirm_sell']       = 'Satışı Onayla',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Öne Çıkarma / Featured (Frontend ek)
    -- ─────────────────────────────────────────────────────────────────────────
    ['featured.badge']              = 'Öne Çıkan',
    ['featured.feature_item']       = 'Öne Çıkar',
    ['featured.renew']              = 'Süreyi Uzat',
    ['featured.select_duration']    = 'Süre Seçin',
    ['featured.description']        = 'Öne çıkarılan eşyalar pazar yerinin en üstünde özel bir rozet ile görünür, böylece alıcılar tarafından daha kolay fark edilir.',
    ['featured.type_listing']       = 'Pazar Yeri İlanı',
    ['featured.type_auction']       = 'Açık Artırma',
    ['featured.payment_info']       = 'Ödeme %s hesabınızdan alınacaktır.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Zaman (Frontend ek)
    -- ─────────────────────────────────────────────────────────────────────────
    ['time.days_full']              = 'Gün',
    ['time.hours_full']             = 'Saat',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Eşya seçim metinleri
    -- ─────────────────────────────────────────────────────────────────────────
    ['create.in_inventory']         = 'Envanterde: {0}',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Zaman Formatları (Frontend)
    -- ─────────────────────────────────────────────────────────────────────────
    ['time.just_now']               = 'Az önce',
    ['time.m_ago']                  = '{0}dk önce',
    ['time.h_ago']                  = '{0}s önce',
    ['time.d_ago']                  = '{0}g önce',
    ['time.ended']                  = 'Sona Erdi',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Satıcı Profili (herkese açık, salt-okunur)
    -- ─────────────────────────────────────────────────────────────────────────
    ['seller.title']                = 'Satıcı Profili',
    ['seller.total_sales']          = 'Toplam Satış',
    ['seller.rating']               = 'Puan',
    ['seller.active_listings']      = 'Aktif İlanlar',
    ['seller.active_auctions']      = 'Aktif Açık Artırmalar',
    ['seller.no_listings']          = 'Aktif ilan yok.',
    ['seller.no_auctions']          = 'Aktif açık artırma yok.',
    ['notify.rating_submitted']     = 'Puanın gönderildi, teşekkürler!',
    ['notify.rating_invalid']       = 'Puan 1 ile 5 arasında olmalı.',
    ['notify.rating_cannot_rate_self'] = 'Kendine puan veremezsin.',
    ['notify.rating_invalid_transaction'] = 'Sadece gerçekten alışveriş yaptığın satıcılara puan verebilirsin.',
    ['notify.rating_already_submitted'] = 'Bu işlem için zaten puan verdin.',
    ['rating.title']                = 'Satıcıyı Puanla',
    ['rating.your_rating']          = 'Puanın',
    ['rating.comment_optional']     = 'Yorum (opsiyonel)',
    ['rating.comment_placeholder']  = 'Deneyimin nasıldı?',
    ['rating.submit']               = 'Puanı Gönder',
    ['rating.rate_seller']          = 'Satıcıyı Puanla',
    ['price_history.title']         = 'Fiyat Geçmişi',
    ['price_history.no_data']       = 'Bu eşya için henüz satış kaydı yok.',
    ['price_history.min']           = 'En Düşük',
    ['price_history.max']           = 'En Yüksek',
    ['price_history.avg']           = 'Ortalama',
    ['price_history.view']          = 'Fiyat Geçmişi',
    ['notify.watched_price_drop']   = 'Fiyat düştü! %s artık $%d fiyatla listelendi.',

    -- ─────────────────────────────────────────────────────────────────────────
    -- Target / Etkileşim
    -- ─────────────────────────────────────────────────────────────────────────
    ['target.open_market']          = 'Pazar Yerini Aç',
    ['target.help_text']            = 'Pazar Yerini açmak için ~INPUT_CONTEXT~ tuşuna bas',

    ['create.cancel']                      = 'İptal',
    ['my.cancel']                          = 'İptal',
    ['my.auctions']                        = 'Açık Artırmalarım',
    ['ui.anonymous_seller']                = 'Anonim Satıcı',
    ['notify.auction_cannot_cancel']       = 'Bu açık artırma artık iptal edilemez (teklif var veya süresi doldu).',
    ['notify.auction_winner_unpaid']       = '%s açık artırmasının kazananı ödeme yapamadı. Eşya sana iade edildi.',
    ['notify.cart_partial_failed']         = 'Sepetindeki %d ürün satın alınamadı.',
    ['notify.listing_changed_retry']       = 'İlan bu sırada değişti. Lütfen tekrar dene.',
    ['notify.delivery_stored']             = '%s envanterine eklenemedi. Pazarı bir sonraki açışında teslim edilecek.',
    ['notify.offer_quantity_unavailable']  = 'İlanda bu teklif için yeterli ürün kalmadı.',

    -- Confirmations & delivery inbox
    ['auction.tab.my_bids']                 = 'En Yüksek Tekliflerim',
    ['confirm.cancel_listing_title']        = 'İlan iptal edilsin mi?',
    ['confirm.cancel_listing_message']      = 'Kalan ürünler envanterine döner ve bu ilandaki tüm açık teklifler iade edilir.',
    ['confirm.cancel_auction_title']        = 'Açık artırma iptal edilsin mi?',
    ['confirm.cancel_auction_message']      = 'Ürün envanterine geri döner. Bu işlem geri alınamaz.',
    ['confirm.accept_offer_title']          = 'Teklif kabul edilsin mi?',
    ['confirm.accept_offer_message']        = '{0}x {1} ürününü {2} karşılığında satıyorsun. Bu işlem geri alınamaz.',
    ['confirm.reject_offer_title']          = 'Teklif reddedilsin mi?',
    ['confirm.reject_offer_message']        = 'Alıcı parasını geri alır ve teklif kapanır.',
    ['confirm.accept_counter_title']        = 'Karşı teklif kabul edilsin mi?',
    ['confirm.accept_counter_message']      = '{0} ödeyip ürünleri alacaksın. Bu işlem geri alınamaz.',
    ['confirm.reject_counter_title']        = 'Karşı teklif reddedilsin mi?',
    ['confirm.reject_counter_message']      = 'Teklifin kapanır ve paran iade edilir.',
    ['confirm.cancel_buyorder_title']       = 'Satın alma talebi iptal edilsin mi?',
    ['confirm.cancel_buyorder_message']     = '{0} iade edilecek. {1} tutarındaki oluşturma ücreti iade edilmez.',
    ['delivery.title']                      = 'Seni bekleyen {0} ürün var',
    ['delivery.claim']                      = 'Teslim Al',
    ['notify.no_deliveries']                = 'Seni bekleyen ürün yok.',

    -- Price rules, fees, admin
    ['notify.price_outside_limits']         = 'Bu ürünün birim fiyatı $%s ile $%s arasında olmalı.',
    ['notify.listing_fee_missing']          = 'İlan ücreti için $%s gerekiyor.',
    ['notify.item_sold_detail']             = '%sx %s ürününü $%s karşılığında sattın. (Ödeme banka hesabına aktarıldı)',
    ['notify.auction_lost_unpaid']          = '%s açık artırmasını kazandın ama ödeme yapamadın, ürün satıcıya döndü.',
    ['notify.admin_removed']                = 'Bir yetkili %s ilanını kaldırdı. Ürünler ve para iade edildi.',
    ['create.blocker.item_price_limit']     = 'Bu ürünün birim fiyatı {0} ile {1} arasında olmalı.',
    ['create.blocker.listing_fee']          = 'İlan ücreti için {0} gerekiyor.',
    ['create.listing_fee_notice']           = 'İlan ücreti: {0} (iade edilmez)',
    ['buyorder.search_items']               = 'Ürün ara...',
    ['market.all_items']                    = 'Tüm Ürünler',
    ['dashboard.pulse_ratio']               = 'İlan / Açık Artırma Oranı',

    -- Arayüzde varsayılanı İngilizce kalan metinler
    ['nav.history']                 = 'Geçmiş',
    ['dashboard.trending']          = 'Öne Çıkan İlanlar',
    ['dashboard.no_trending']       = 'Pazarda henüz ilan yok.',
    ['dashboard.recent_activity']   = 'Son Hareketler',
    ['dashboard.no_activity']       = 'Henüz hareket yok.',
    ['dashboard.view_all']          = 'Tümünü Gör',
    ['dashboard.my_buy_orders']     = 'Satın Alma Taleplerim',
    ['dashboard.no_buy_orders']     = 'Aktif satın alma talebin yok.',
    ['dashboard.claim_deliveries']  = 'Depodaki Eşyaları Al',
    ['dashboard.depot_waiting']     = 'Teslimat Bekleyen Eşyalar',
    ['dashboard.market_status']     = 'Piyasa Durumu',
    ['dashboard.market_stable']     = 'Aktif & Kararlı',
    ['market.title']                = 'Pazar Yeri',
    ['market.page_of']              = '/',
    ['market.items_shown']          = '{0}-{1} / {2} gösteriliyor',
    ['cart.remove']                 = 'Kaldır',
    ['create.category']             = 'Kategori',
    ['create.sale_type']            = 'Satış Türü',
    ['create.bulk']                 = 'Toplu Satış',
    ['create.select_category']      = 'Kategori seç...',
    ['create.blocker.no_category']  = 'Oluşturmadan önce bir kategori seç.',
    ['auction.title']               = 'Açık Artırmalar',
    ['auction.time_left']           = 'Kalan Süre',
    ['auction.start_price']         = 'Başlangıç Fiyatı',
    ['auction.quick_bid']           = 'Hızlı Teklif',
    ['auction.tab.ended']           = 'Bitenler',
    ['bid.cancel']                  = 'İptal',
    ['history.type']                = 'Tür',
    ['history.item']                = 'Ürün',
    ['history.amount']              = 'Adet',
    ['history.price']               = 'Fiyat',
    ['history.party']               = 'Karşı Taraf',
    ['history.date']                = 'Tarih',
    ['notification.mark_all']       = 'Tümünü okundu say',
    ['profile.seller_level']        = 'Satıcı Seviyesi',
    ['general.close']               = 'Kapat',
    ['general.confirm']             = 'Onayla',
    ['general.loading']             = 'Yükleniyor...',
    ['offer.your_offer']            = 'Teklifin',
    ['offer.cancel']                = 'İptal',
    ['offer.accepted']              = 'Kabul Edildi',
    ['offer.rejected']              = 'Reddedildi',
    ['offer.expired']               = 'Süresi Doldu',
    ['offer.cancelled']             = 'İptal Edildi',
    ['offer.no_offers']             = 'Henüz teklif yok.',
    ['offer.already_offered']       = 'Bu ilana zaten bir teklifin var.',
    ['offer.max_reached']           = 'Aktif teklif sınırına ulaştın.',
    ['offer.expires_in']            = '{0} sa içinde sona erer',
    ['offer.incoming_offers']       = 'Gelen Teklifler',
    ['offer.offer_from']            = '{0} kişisinden',
    ['offer.for_quantity']          = 'x{0} için',
    ['offer.confirm_accept']        = 'Bu teklifi kabul et?',
    ['offer.confirm_reject']        = 'Bu teklifi reddet?',
    ['my.edit_price']               = 'Fiyatı Düzenle',
}
