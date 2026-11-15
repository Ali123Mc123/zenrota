/* =========================================================================
   daddy-games :: gym :: hub.js
   Koc Merkezi. Sekmeler: Bugun / Karne / Siralama / Bufe / Rozetler.

   Not: Oyuncu adlari veritabanindan gelir, yani KULLANICI GIRDISIDIR.
   Ekrana basilan her serbest metin esc()'ten gecirilir.
   ========================================================================= */
(function () {
  'use strict';

  var root = document.getElementById('gym-hub');
  if (!root) return;

  var RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'daddy-games';
  var ico = window.gymIcon || function () { return ''; };

  var state = { data: null, tab: 'today', lb: 'fitness', busy: false };

  // -----------------------------------------------------------------------
  // YARDIMCILAR
  // -----------------------------------------------------------------------
  function esc(v) {
    return String(v === undefined || v === null ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function post(name, body) {
    return fetch('https://' + RES + '/' + name, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(body || {})
    }).then(function (r) { return r.json(); }).catch(function () { return null; });
  }

  function nf(v, d) {
    var n = Number(v) || 0;
    return d ? n.toFixed(d) : Math.round(n).toLocaleString('tr-TR');
  }

  function dur(sec) {
    var s = Math.max(0, Math.round(sec || 0));
    if (s === 0) return 'dolu';
    var h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60);
    return h > 0 ? h + 's ' + m + 'dk' : m + 'dk';
  }

  function medal(iconName, metal, size, locked) {
    var cls = 'medal' + (locked ? ' medal--locked' : (metal ? ' medal--' + metal : ''));
    if (size === 'sm') cls += ' medal--sm';
    if (size === 'lg') cls += ' medal--lg';
    var px = size === 'sm' ? 14 : (size === 'lg' ? 22 : 18);
    return '<span class="' + cls + '">' + ico(locked ? 'lock' : (iconName || 'medal'), px) + '</span>';
  }

  function sec(title, aside) {
    return '<div class="sec"><span class="sec__t">' + esc(title) + '</span>' +
      '<span class="sec__line"></span>' +
      (aside ? '<span class="sec__aside">' + aside + '</span>' : '') + '</div>';
  }

  function meter(pct, variant, tall) {
    return '<div class="meter' + (variant ? ' meter--' + variant : '') + (tall ? ' meter--tall' : '') +
      '"><div class="meter__fill" style="width:' + Math.max(0, Math.min(100, pct)).toFixed(1) + '%"></div></div>';
  }

  function note(text, variant, iconName) {
    return '<div class="note' + (variant ? ' note--' + variant : '') + '">' +
      ico(iconName || 'info', 14) + '<span>' + text + '</span></div>';
  }

  var TABS = [
    { id: 'today',  label: 'Bugün',    icon: 'clipboard-list' },
    { id: 'report', label: 'Karne',    icon: 'scroll-text' },
    { id: 'board',  label: 'Sıralama', icon: 'trophy' },
    { id: 'shop',   label: 'Büfe',     icon: 'flask-conical' },
    { id: 'badges', label: 'Rozetler', icon: 'award' }
  ];

  var LB = [
    { id: 'fitness', label: 'Form Puanı' }, { id: 'condition', label: 'Kondisyon' },
    { id: 'streak', label: 'Seri' }, { id: 'pushup', label: 'Şınav' },
    { id: 'pullup', label: 'Barfiks' }, { id: 'bench', label: 'Bench' },
    { id: 'punch', label: 'Vuruş Gücü' }, { id: 'duel', label: 'Düello' },
    { id: 'armwrestle', label: 'Bilek Güreşi' }
  ];

  // -----------------------------------------------------------------------
  // ISKELET
  // -----------------------------------------------------------------------
  root.innerHTML = [
    '<div class="hb">',
    '  <header class="hb-top">',
    '    <div class="hb-coach">',
    '      <div class="hb-coach__name" data-k="cName"></div>',
    '      <div class="hb-coach__title" data-k="cTitle"></div>',
    '    </div>',
    '    <span class="hb-top__spacer"></span>',
    '    <div class="hb-me" data-k="me"></div>',
    '    <button class="hb-close" data-act="close" title="Kapat (ESC)"></button>',
    '  </header>',
    '  <nav class="hb-tabs" data-k="tabs"></nav>',
    '  <div class="hb-body scroll" data-k="body"></div>',
    '  <div class="hb-toast" data-k="toast"></div>',
    '</div>'
  ].join('');

  var el = {};
  root.querySelectorAll('[data-k]').forEach(function (n) { el[n.getAttribute('data-k')] = n; });
  root.querySelector('[data-act="close"]').innerHTML = ico('x', 17);

  var toastTimer = null;
  function toast(text, kind) {
    el.toast.innerHTML = ico(kind === 'bad' ? 'triangle-alert' : 'check', 14) + '<span>' + esc(text) + '</span>';
    el.toast.className = 'hb-toast is-show' + (kind ? ' is-' + kind : '');
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { el.toast.className = 'hb-toast'; }, 3200);
  }

  // -----------------------------------------------------------------------
  // KIMLIK SERIDI + SEKMELER
  // -----------------------------------------------------------------------
  function renderTop() {
    var d = state.data;
    el.cName.textContent = ((d.trainer && d.trainer.name) || 'Salon').toLocaleUpperCase('tr-TR');
    el.cTitle.textContent = (d.trainer && d.trainer.title) || '';

    el.me.innerHTML = [
      '<div class="hb-me__block">',
      '  <div class="hb-me__name">', esc(d.name || ''), '</div>',
      '  <div class="hb-me__line">',
      '    <span>', esc(d.tier.label), '</span>',
      '    <span class="hb-me__sep"></span>',
      '    <span><b>', nf(d.condition), '</b> kond.</span>',
      '    <span class="hb-me__sep"></span>',
      '    <span><b>', nf(d.fitnessPoints), '</b> FP</span>',
      '    <span class="hb-me__sep"></span>',
      '    <span>', ico('flame', 12), ' <b>', nf(d.streak), '</b></span>',
      '  </div>',
      '</div>',
      medal(d.tier.icon, d.tier.metal, 'lg')
    ].join('');
  }

  function unlocked(d) {
    var ids = {};
    (d.achievements || []).forEach(function (i) { ids[i] = true; });
    return (d.catalog || []).filter(function (a) { return ids[a.id]; }).length;
  }

  function renderTabs() {
    var d = state.data;
    el.tabs.innerHTML = TABS.map(function (t) {
      var n = '';
      if (t.id === 'today' && d.program) {
        n = d.program.items.filter(function (i) { return i.complete; }).length + '/' + d.program.items.length;
      }
      if (t.id === 'badges') n = unlocked(d) + '/' + (d.catalog || []).length;

      return '<button class="hb-tab' + (state.tab === t.id ? ' is-active' : '') + '" data-tab="' + t.id + '">' +
        ico(t.icon, 14) + '<span>' + esc(t.label) + '</span>' +
        (n ? '<span class="hb-tab__n">' + n + '</span>' : '') + '</button>';
    }).join('');
  }

  // -----------------------------------------------------------------------
  // ANATOMIK SILUET — blok manken degil; yuk verisi tasir
  // -----------------------------------------------------------------------
  var FIGURE = [
    '<svg class="hb-figure" viewBox="0 0 120 208">',
    '  <circle cx="60" cy="20" r="12" class="ol"/>',
    '  <path d="M54,31 L66,31 L67,39 L53,39 Z" class="z" data-g="back"/>',
    // trapez / omuz bandi
    '  <path d="M38,42 Q60,33 82,42 L84,51 Q60,42 36,51 Z" class="z" data-g="back"/>',
    // deltoidler
    '  <path d="M36,47 Q27,50 25,63 Q30,67 37,62 Q38,53 40,50 Z" class="z" data-g="arms"/>',
    '  <path d="M84,47 Q93,50 95,63 Q90,67 83,62 Q82,53 80,50 Z" class="z" data-g="arms"/>',
    // pektoraller
    '  <path d="M42,53 Q52,49 58,54 L58,75 Q48,79 41,72 Z" class="z" data-g="chest"/>',
    '  <path d="M78,53 Q68,49 62,54 L62,75 Q72,79 79,72 Z" class="z" data-g="chest"/>',
    // karin
    '  <path d="M44,78 Q60,83 76,78 L73,117 Q60,122 47,117 Z" class="z" data-g="core"/>',
    // kollar
    '  <path d="M25,65 L22,97 Q25,101 31,98 L35,67 Z" class="z" data-g="arms"/>',
    '  <path d="M95,65 L98,97 Q95,101 89,98 L85,67 Z" class="z" data-g="arms"/>',
    // bacaklar
    '  <path d="M46,120 L43,197 Q49,200 55,197 L58,142 L62,142 L65,197 Q71,200 77,197 L74,120 Q60,125 46,120 Z"',
    '        class="z" data-g="full"/>',
    '</svg>'
  ].join('');

  function paintFigure(groups) {
    root.querySelectorAll('.hb-figure .z').forEach(function (n) {
      var g = groups[n.getAttribute('data-g')];
      n.setAttribute('class', 'z' + (g ? (g.sore ? ' sore' : (g.load ? ' l' + g.load : '')) : ''));
    });
  }

  // -----------------------------------------------------------------------
  // SEKME: BUGUN
  // -----------------------------------------------------------------------
  function tabToday() {
    var d = state.data;
    var prog = d.program || { items: [], done: false };

    var rows = prog.items.length ? prog.items.map(function (it) {
      return [
        '<div class="hb-prog__row', (it.complete ? ' is-done' : ''), '">',
        '  <span class="hb-prog__mark">', ico(it.complete ? 'check' : 'circle-dot', 14), '</span>',
        '  <span class="hb-prog__icon">', ico(it.icon || 'dumbbell', 16), '</span>',
        '  <span class="hb-prog__name">', esc(it.label), '</span>',
        '  <span class="hb-prog__count">', it.done, '<s> / ', it.need, '</s></span>',
        '</div>'
      ].join('');
    }).join('') : '<div class="hb-empty">Bugün için program atanmadı.</div>';

    var loadRows = ['chest', 'back', 'arms', 'core', 'full'].map(function (gid) {
      var g = (d.groups || {})[gid];
      if (!g) return '';
      var lvl = g.sore ? 'sore' : (g.load ? 'l' + g.load : '');
      var txt = g.sore ? ('tutulmuş · ' + g.soreMinutes + 'dk')
                       : (g.sets > 0 ? g.sets + ' set' : 'dinlenmiş');
      return '<div class="hb-loadrow' + (g.sore ? ' is-sore' : '') + '">' +
        '<span class="hb-loadrow__dot ' + lvl + '"></span>' +
        '<span class="hb-loadrow__n">' + esc(g.label) + '</span>' +
        '<span class="hb-loadrow__s">' + esc(txt) + '</span></div>';
    }).join('');

    var ePct = d.energyMax ? (d.energy / d.energyMax) * 100 : 0;
    var fPct = (d.fatigue || 0) * 100;

    var buffs = (d.buffs || []).length ? '<div>' + (d.buffs || []).map(function (b) {
        var left = b.sets ? b.sets + ' set' : (b.secondsLeft ? dur(b.secondsLeft) : '');
        return '<div class="hb-buff">' + ico('sparkles', 13) +
          '<span class="hb-buff__t">' + esc(BUFF[b.key] || b.key) + '</span>' +
          '<span class="hb-buff__n">' + esc(left) + '</span></div>';
      }).join('') + '</div>' : '';

    el.body.innerHTML = [
      '<div class="hb-cols hb-cols--main">',

      '  <div class="hb-stack">',
      sec(prog.label || 'Günlük Program',
          prog.done ? 'tamamlandı' : (prog.items.filter(function (i) { return i.complete; }).length + ' / ' + prog.items.length)),
      '    <div class="hb-prog">', rows, '</div>',
      '    <div class="hb-sum">',
      '      <div><div class="hb-sum__k">', ico('repeat', 12), 'Bugünkü Set</div>',
      '        <div class="hb-sum__v">', nf(d.todaySets), '</div></div>',
      '      <div><div class="hb-sum__k">', ico('zap', 12), 'Harcanan Enerji</div>',
      '        <div class="hb-sum__v">', nf(d.todayEnergy), '<small>/ ', nf(d.energyMax), '</small></div></div>',
      '      <div><div class="hb-sum__k">', ico('flame', 12), 'Seri</div>',
      '        <div class="hb-sum__v">', nf(d.streak), '<small>gün</small></div></div>',
      '    </div>',
      prog.done
        ? note('Program tamamlandı. Bundan sonraki setler seni pek geliştirmez — yarın gel.', 'brass', 'clipboard-check')
        : '',

      sec('Kas Grubu Durumu'),
      '    <div class="hb-load"><div>', FIGURE, '</div><div>', loadRows, '</div></div>',

      '  </div>',

      '  <div class="hb-stack">',
      sec('Durum'),
      '    <div>',
      '      <div class="hb-gauge__top"><span class="hb-gauge__k">', ico('zap', 12), 'Enerji</span>',
      '        <span class="hb-gauge__v">', nf(d.energy), ' / ', nf(d.energyMax), '</span></div>',
      meter(ePct, ePct <= 25 ? '' : (ePct <= 60 ? 'brass' : 'ok'), true),
      '      <div class="hb-gauge__note">Tam dolum: ', dur(d.energyFullIn), '</div>',
      '    </div>',

      '    <div>',
      '      <div class="hb-gauge__top"><span class="hb-gauge__k">', ico('battery-low', 12), 'Yorgunluk</span>',
      '        <span class="hb-gauge__v">%', nf(fPct), '</span></div>',
      meter(fPct, fPct >= 65 ? 'bad' : 'warn', true),
      '      <div class="hb-gauge__note">Yorgunluk arttıkça kabul bandı daralır ve nefes daha hızlı tükenir.</div>',
      '    </div>',

      '    <div>',
      '      <div class="hb-gauge__top"><span class="hb-gauge__k">', ico('heart-pulse', 12), 'Bugünkü Kazanç</span>',
      '        <span class="hb-gauge__v">', nf(d.conditionToday, 1), ' / ', nf(d.conditionCap, 1), '</span></div>',
      meter(d.conditionCap ? (d.conditionToday / d.conditionCap) * 100 : 0, 'ok', true),
      '      <div class="hb-gauge__note">Günlük kondisyon tavanı. Dolunca fazlası seni geliştirmez.</div>',
      '    </div>',

      buffs ? sec('Aktif Takviyeler') + buffs : '',
      '    <div class="hb-advice" data-act="advice">', ico('user', 14),
      '      <span>Koça bir şey sor…</span></div>',
      '  </div>',
      '</div>'
    ].join('');

    paintFigure(d.groups || {});
  }

  var BUFF = {
    breath: 'İzotonik — nefes yavaş tükeniyor',
    focus: 'Pre-Workout — geniş kabul bandı',
    grip: 'Magnezyum — form kaybı yarı',
    energymax: 'Kreatin — enerji tavanı yüksek',
    rest: 'Havlu — kısa toparlanma'
  };

  // -----------------------------------------------------------------------
  // SEKME: KARNE
  // -----------------------------------------------------------------------
  var RECORDS = [
    ['pushup', 'Şınav', 'tekrar', 'arrow-down-up'],
    ['pullup', 'Barfiks', 'tekrar', 'move-up'],
    ['bench', 'Bench Press', 'tekrar', 'dumbbell'],
    ['situp', 'Mekik', 'tekrar', 'fold-vertical'],
    ['dumbbell', 'Serbest Ağırlık', 'tekrar', 'biceps-flexed'],
    ['punch', 'Vuruş Gücü', 'puan', 'hand-metal']
  ];

  function tabReport() {
    var d = state.data;
    var p = d.perks || {};
    var cap = d.capacity || {};
    var dec = d.decay || { now: d.condition, in24: d.condition, in48: d.condition };
    var max = d.conditionMax || 100;

    var ghost = function (v, label, side) {
      return '<div class="hb-cond__ghost hb-cond__ghost--' + side + '" data-t="' + label +
        '" style="bottom:' + ((v / max) * 100).toFixed(1) + '%"></div>';
    };

    var ladder = (d.ladder || []).map(function (t) {
      var cls = t.index === d.tier.index ? ' is-now' : (t.index < d.tier.index ? ' is-past' : '');
      return '<div class="hb-ladder__s' + cls + '">' +
        medal(t.icon, t.metal, 'sm', t.index > d.tier.index) +
        '<span>' + esc(t.label) + '</span></div>';
    }).join('');

    var records = RECORDS.map(function (r) {
      return '<div class="row"><span class="row__k">' + ico(r[3], 14) + ' ' + esc(r[1]) + '</span>' +
        '<span class="row__v">' + nf((d.records || {})[r[0]]) +
        '<span class="row__u">' + esc(r[2]) + '</span></span></div>';
    }).join('');

    var perk = function (label, val, pct) {
      return '<div><div class="hb-perk__top"><span>' + esc(label) + '</span>' +
        '<span class="hb-perk__v">' + val + '</span></div>' +
        meter(pct, 'brass') + '</div>';
    };

    var setTypes = (d.setTypes || []).map(function (st) {
      return '<div class="row"><span class="row__k">' +
        ico(st.unlocked ? st.icon : 'lock', 14) + ' ' + esc(st.label) + '</span>' +
        '<span class="row__v" style="font-size:11.5px;color:var(--n6)">' +
        (st.unlocked ? 'açık' : esc(st.minTierLabel || '') + ' ile açılır') + '</span></div>';
    }).join('');

    el.body.innerHTML = [
      // --- SATIR 1: kondisyon sutunu | kapasite + perk'ler ---
      '<div class="hb-cols hb-cols--split">',

      '  <div class="hb-stack">',
      sec('Kondisyon'),
      '    <div class="hb-cond">',
      '      <div class="hb-cond__col">',
      '        <div class="hb-cond__scale"></div>',
      '        <div class="hb-cond__fill" style="height:', ((d.condition / max) * 100).toFixed(1), '%"></div>',
      ghost(dec.in24, '24s', 'a'), ghost(dec.in48, '48s', 'b'),
      '      </div>',
      '      <div class="hb-cond__side">',
      '        <div class="hb-cond__now"><span class="hb-cond__v">', nf(d.condition), '</span>',
      '          <span class="hb-cond__u">/ ', max, '</span></div>',
      '        <div class="hb-decay">',
      '          <div class="hb-decay__r">', ico('trending-down', 13),
      '            <span>24 saat çalışmazsan</span><b>', nf(dec.in24), '</b></div>',
      '          <div class="hb-decay__r">', ico('trending-down', 13),
      '            <span>48 saat çalışmazsan</span><b>', nf(dec.in48), '</b></div>',
      '        </div>',
      dec.shielded
        ? '<span class="tag tag--ok">' + ico('shield', 12) + 'Kas hafızası: çürüme yarı hızda</span>'
        : '<span class="tag tag--ghost">' + ico('info', 12) + '7 günlük seri çürümeyi yarıya indirir</span>',
      '      </div>',
      '    </div>',
      '  </div>',

      '  <div class="hb-stack">',
      sec('Kondisyonun Karşılığı', 'kapasite'),
      '    <div class="hb-cols" style="grid-template-columns:1fr 1fr;gap:0 var(--s5)">',
      '      <div>',
      '        <div class="row"><span class="row__k">Enerji tavanı</span><span class="row__v">', nf(cap.energyMax), '</span></div>',
      '        <div class="row"><span class="row__k">Set başına tekrar</span><span class="row__v">×', nf(cap.repMult, 2), '</span></div>',
      '      </div>',
      '      <div>',
      '        <div class="row"><span class="row__k">Tam dolum süresi</span><span class="row__v">', nf(cap.regenHours, 1), '<span class="row__u">saat</span></span></div>',
      '        <div class="row"><span class="row__k">Günlük tavan</span><span class="row__v">', nf(cap.dailyCap, 1), '</span></div>',
      '      </div>',
      '    </div>',

      sec('Aktif Kazanımlar', 'kondisyona bağlı'),
      '    <div class="hb-stack" style="gap:14px">',
      perk('Koşu / Stamina', nf(p.stamina) + ' / 100', p.stamina),
      perk('Yumruk Gücü', '×' + nf(p.meleeMult, 2), ((p.meleeMult - 1) / 0.45) * 100),
      perk('Nefes Kapasitesi', nf(p.lung) + ' / 100', p.lung),
      '    </div>',
      '  </div>',
      '</div>',

      // --- SATIR 2: rutbe merdiveni (tam genislik) ---
      '<div style="height:var(--s5)"></div>',
      sec('Rütbe Merdiveni', 'efektif rütbe = min(kondisyon, form puanı)'),
      '<div class="hb-ladder">', ladder, '</div>',
      '<div style="height:var(--s3)"></div>',
      d.nextTier ? note(
        'Sıradaki <b>' + esc(d.nextTier.label) + '</b> için ' +
        (d.nextTier.needCondition > 0 ? '+' + nf(d.nextTier.needCondition, 1) + ' kondisyon ' : '') +
        (d.nextTier.needPoints > 0 ? '+' + nf(d.nextTier.needPoints) + ' FP' : '') + ' gerek.',
        null, 'chevrons-up') : note('Zirvedesin. Şimdi burada kalmak var.', 'brass', 'crown'),

      // --- SATIR 3: rekorlar | set tipleri + genel ---
      '<div style="height:var(--s5)"></div>',
      '<div class="hb-cols" style="grid-template-columns:1fr 1fr">',
      '  <div><div>', sec('Kişisel Rekorlar'), '</div>', records, '</div>',
      '  <div>',
      sec('Set Tipleri'), '<div>', setTypes, '</div>',
      '    <div style="height:var(--s4)"></div>',
      sec('Genel'),
      '    <div>',
      '      <div class="row"><span class="row__k">Toplam set</span><span class="row__v">', nf(d.totalSets), '</span></div>',
      '      <div class="row"><span class="row__k">Tamamlanan program</span><span class="row__v">', nf(d.programsDone), '</span></div>',
      '      <div class="row"><span class="row__k">Düello</span><span class="row__v">', nf(d.duels.wins), ' - ', nf(d.duels.losses), '</span></div>',
      '      <div class="row"><span class="row__k">Bilek güreşi</span><span class="row__v">', nf(d.duels.armWins), ' - ', nf(d.duels.armLosses), '</span></div>',
      '    </div>',
      '  </div>',
      '</div>'
    ].join('');
  }

  // -----------------------------------------------------------------------
  // SEKME: SIRALAMA
  // -----------------------------------------------------------------------
  function tabBoard() {
    el.body.innerHTML = [
      '<div class="hb-seg">',
      LB.map(function (c) {
        return '<button class="hb-seg__b' + (state.lb === c.id ? ' is-active' : '') +
          '" data-lb="' + c.id + '">' + esc(c.label) + '</button>';
      }).join(''),
      '</div>',
      '<div data-k="lbList"><div class="hb-empty">Yükleniyor…</div></div>'
    ].join('');

    loadBoard();
  }

  function tierLabel(id) {
    var t = (state.data.ladder || []).filter(function (x) { return x.id === id; })[0];
    return t ? t.label : '';
  }

  function loadBoard() {
    post('gymHubLeaderboard', { category: state.lb }).then(function (res) {
      if (state.tab !== 'board') return;
      var host = root.querySelector('[data-k="lbList"]');
      if (!host) return;

      var rows = (res && res.rows) || [];
      if (!rows.length) {
        host.innerHTML = '<div class="hb-empty">Bu kategoride henüz kayıt yok. İlk sen ol.</div>';
        return;
      }

      var suffix = (res && res.suffix) || '';
      var body = rows.map(function (r, i) {
        var rank = i + 1;
        return '<tr' + (r.isMe ? ' class="is-me"' : '') + '>' +
          '<td class="hb-lb__rank' + (rank <= 3 ? ' r' + rank : '') + '">' + rank + '</td>' +
          '<td class="hb-lb__name">' + esc(r.name) + '</td>' +
          '<td class="hb-lb__tier">' + esc(tierLabel(r.tier)) + '</td>' +
          '<td class="num hb-lb__score">' + nf(r.score) + esc(suffix) + '</td></tr>';
      }).join('');

      if (res && res.myRank && res.myRank > rows.length) {
        body += '<tr class="is-me"><td class="hb-lb__rank">' + res.myRank + '</td>' +
          '<td class="hb-lb__name">Sen</td><td class="hb-lb__tier"></td>' +
          '<td class="num hb-lb__score">' + nf(res.myScore) + esc(suffix) + '</td></tr>';
      }

      host.innerHTML = '<table class="hb-lb"><thead><tr>' +
        '<th>#</th><th>Sporcu</th><th>Rütbe</th><th class="num">' +
        esc((res && res.label) || 'Skor') + '</th></tr></thead><tbody>' + body + '</tbody></table>';
    });
  }

  // -----------------------------------------------------------------------
  // SEKME: BUFE
  // -----------------------------------------------------------------------
  function tabShop() {
    var d = state.data;

    var items = (d.locker || []).map(function (it) {
      var limit = it.permanent
        ? (it.ownedPermanent ? 'sahipsin' : 'kalıcı')
        : (it.usedToday + ' / ' + it.dailyLimit + ' bugün');

      var canUse = !it.permanent && it.owned > 0 && it.usedToday < it.dailyLimit;
      var canBuy = !(it.permanent && it.ownedPermanent);

      return [
        '<div class="hb-item">',
        '  <span class="hb-item__icon">', ico(it.icon || 'flask-conical', 17), '</span>',
        '  <div class="hb-item__main">',
        '    <div class="hb-item__top"><span class="hb-item__name">', esc(it.label), '</span>',
        '      <span class="hb-item__price">$', nf(it.price), '</span></div>',
        '    <div class="hb-item__desc">', esc(it.desc), '</div>',
        '    <div class="hb-item__foot">',
        '      <button class="btn btn--primary" data-buy="', esc(it.id), '"', (canBuy ? '' : ' disabled'), '>Satın Al</button>',
        it.permanent ? '' :
          '<button class="btn btn--metal" data-use="' + esc(it.id) + '"' + (canUse ? '' : ' disabled') + '>Kullan</button>',
        '      <span class="hb-item__meta">',
        it.permanent ? '' : ('dolapta: ' + it.owned + '<br>'), esc(limit),
        '      </span>',
        '    </div>',
        '  </div>',
        '</div>'
      ].join('');
    }).join('');

    el.body.innerHTML = [
      note('Bu ürünler <b>açlık ve susuzluk gidermez</b>. Yalnızca antrenmanı etkiler: enerji ' +
           'tavanını yükseltir, nefesi uzatır veya kabul bandını genişletir. Salonun dolabında ' +
           'saklanır ve buradan kullanılır.', 'brass', 'flask-conical'),
      '<div style="height:var(--s4)"></div>',
      '<div class="hb-shop">', items, '</div>'
    ].join('');
  }

  // -----------------------------------------------------------------------
  // SEKME: ROZETLER
  // -----------------------------------------------------------------------
  function tabBadges() {
    var d = state.data;
    var have = {};
    (d.achievements || []).forEach(function (i) { have[i] = true; });

    var cards = (d.catalog || []).map(function (a) {
      var on = !!have[a.id];
      return [
        '<div class="hb-badge', (on ? '' : ' is-locked'), '">',
        medal(a.icon, a.metal, null, !on),
        '  <div class="hb-badge__main">',
        '    <div class="hb-badge__n">', esc(a.label), '</div>',
        '    <div class="hb-badge__d">', esc(a.description), '</div>',
        '    <div class="hb-badge__p">', (on ? 'kazanıldı' : '+' + nf(a.points) + ' FP'), '</div>',
        '  </div>',
        '</div>'
      ].join('');
    }).join('');

    el.body.innerHTML = sec('Rozet Vitrini', unlocked(d) + ' / ' + (d.catalog || []).length) +
      '<div class="hb-badges">' + cards + '</div>';
  }

  // -----------------------------------------------------------------------
  // YONLENDIRME
  // -----------------------------------------------------------------------
  var RENDER = { today: tabToday, report: tabReport, board: tabBoard, shop: tabShop, badges: tabBadges };

  function renderAll() {
    renderTop();
    renderTabs();
    (RENDER[state.tab] || tabToday)();
    el.body.scrollTop = 0;
  }

  // -----------------------------------------------------------------------
  // OLAYLAR
  // -----------------------------------------------------------------------
  root.addEventListener('click', function (ev) {
    var t = ev.target.closest('[data-tab], [data-act], [data-lb], [data-buy], [data-use]');
    if (!t) return;

    if (t.hasAttribute('data-tab')) { state.tab = t.getAttribute('data-tab'); renderAll(); return; }
    if (t.getAttribute('data-act') === 'close') { post('gymHubClose', {}); return; }

    if (t.getAttribute('data-act') === 'advice') {
      post('gymHubAdvice', { trainerId: state.data.trainer && state.data.trainer.id }).then(function (a) {
        if (a && a.line) t.innerHTML = ico('user', 14) + '<span>“' + esc(a.line) + '”</span>';
      });
      return;
    }

    if (t.hasAttribute('data-lb')) { state.lb = t.getAttribute('data-lb'); tabBoard(); return; }

    if (t.hasAttribute('data-buy') || t.hasAttribute('data-use')) {
      if (state.busy) return;
      state.busy = true;
      t.disabled = true;

      var isBuy = t.hasAttribute('data-buy');
      post(isBuy ? 'gymHubBuy' : 'gymHubUse', { id: t.getAttribute(isBuy ? 'data-buy' : 'data-use') })
        .then(function (res) {
          state.busy = false;
          if (!res) { toast('Sunucu yanıt vermedi.', 'bad'); return; }
          toast(res.message || (res.ok ? 'Tamam' : 'Olmadı'), res.ok ? 'ok' : 'bad');

          if (res.ok && res.payload) {
            merge(res.payload);
            renderAll();
          } else {
            t.disabled = false;
          }
        });
    }
  });

  // Statik veriyi (koc, katalog, merdiven) tazelemede koru
  function merge(payload) {
    var keep = {
      trainer: state.data.trainer,
      catalog: state.data.catalog,
      ladder: state.data.ladder
    };
    state.data = Object.assign(payload, keep);
  }

  // NUI odakli iken klavye buraya gelir; ESC birincil olarak burada yakalanir.
  // Lua tarafindaki kontrol dongusu yedek kalir.
  document.addEventListener('keydown', function (ev) {
    if (!root.classList.contains('is-open')) return;

    if (ev.key === 'Escape') { ev.preventDefault(); post('gymHubClose', {}); return; }

    var i = ['1', '2', '3', '4', '5'].indexOf(ev.key);
    if (i >= 0 && TABS[i]) { state.tab = TABS[i].id; renderAll(); }
  });

  // -----------------------------------------------------------------------
  // MESAJ YONLENDIRICI
  // -----------------------------------------------------------------------
  window.addEventListener('message', function (event) {
    var msg = event.data;
    if (!msg || typeof msg.action !== 'string') return;
    if (msg.action.indexOf('gym:hub:') !== 0) return;

    var what = msg.action.slice(8);

    if (what === 'open') {
      state.data = msg.data;
      state.tab = 'today';
      state.lb = 'fitness';
      state.busy = false;
      root.classList.add('is-open');
      renderAll();
    } else if (what === 'refresh') {
      if (!state.data) return;
      merge(msg.data);
      renderAll();
    } else if (what === 'close') {
      root.classList.remove('is-open');
    }
  });
})();
