/* =========================================================================
   daddy-games :: gym :: hud.js
   Antrenman bandi — SALT GORSEL.

   Hicbir tus dinlemez, odak almaz. Hakemlik (PERFECT / IYI / BOZUK) Lua
   tarafinda yapilir; buraya yalnizca sonuc gelir. Ritim imleci her dongu
   basinda yeniden capalanir, boylece Lua'nin sayaci ile ekrandaki imlec
   ayrisamaz.

   Govde uc gorunum arasinda gecis yapar:
     setup  agirlik kademesi secimi
     run    nefes sutunu | ritim rayi | set izi
     grip   bilek guresi halat cekme
   ========================================================================= */
(function () {
  'use strict';

  var root = document.getElementById('gym-hud');
  if (!root) return;

  var ico = window.gymIcon || function () { return ''; };

  var el = {};
  var markerAnim = null;
  var timers = {};
  var isDuel = false;
  var view = 'run';

  // -----------------------------------------------------------------------
  // YARDIMCILAR
  // -----------------------------------------------------------------------
  function esc(v) {
    return String(v === undefined || v === null ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  function nf(v) { return Number(v || 0).toLocaleString('tr-TR'); }

  function clearTimer(k) { if (timers[k]) { clearTimeout(timers[k]); timers[k] = null; } }
  function clearAll() { Object.keys(timers).forEach(clearTimer); }

  function tag(text, variant, iconName) {
    return '<span class="tag' + (variant ? ' tag--' + variant : '') + '">' +
      (iconName ? ico(iconName, 12) : '') + esc(text) + '</span>';
  }

  var JUDGE = { perfect: 'PERFECT', good: 'İYİ', miss: 'BOZUK' };

  var HINTS = {
    tap:   '<span>' + key('SPACE') + 'tempoda bas</span>',
    hold:  '<span>' + key('SPACE') + 'indirirken bas ve tut</span>' +
           '<span>' + key('BIRAK') + 'kaldırırken bırak</span>',
    combo: '<span>' + key('SOL') + key('SAĞ') + 'kombinasyonu çak</span>',
    grip:  '<span>' + key('SPACE') + 'basılı tut — bırakınca nefes toplarsın</span>'
  };

  function key(k) { return '<span class="gh-key">' + k + '</span>'; }

  // -----------------------------------------------------------------------
  // ISKELET
  // -----------------------------------------------------------------------
  root.innerHTML = [
    '<div class="gh-vs" data-k="vs">',
    '  <div class="gh-vs__side gh-vs__side--me">',
    '    <div class="gh-vs__k">Sen</div><div class="gh-vs__v" data-k="vsMe">0</div>',
    '  </div>',
    '  <div class="gh-vs__mid">VS</div>',
    '  <div class="gh-vs__side gh-vs__side--them">',
    '    <div class="gh-vs__k">Rakip</div><div class="gh-vs__v" data-k="vsThem">0</div>',
    '    <div class="gh-vs__name" data-k="vsName"></div>',
    '  </div>',
    '  <div class="gh-vs__pot" data-k="vsPot"></div>',
    '</div>',

    '<div class="gh" data-k="panel">',
    '  <div class="gh-head">',
    '    <span class="gh-head__icon" data-k="hIcon"></span>',
    '    <span class="gh-head__name" data-k="hName">ANTRENMAN</span>',
    '    <span class="gh-head__tags" data-k="hTags"></span>',
    '    <span class="gh-head__spacer"></span>',
    '    <span class="gh-fatigue" data-k="hFatigue"></span>',
    '    <span class="gh-energy" data-k="hEnergy"></span>',
    '  </div>',

    // --- calisma gorunumu ---
    '  <div class="gh-body" data-k="viewRun">',
    '    <div class="gh-breath">',
    '      <span class="gh-breath__cap" data-k="brIcon"></span>',
    '      <div class="gh-breath__tube">',
    '        <div class="gh-breath__ticks"></div>',
    '        <div class="gh-breath__fill" data-k="brFill"></div>',
    '      </div>',
    '      <span class="gh-breath__pct" data-k="brPct">100</span>',
    '      <span class="gh-breath__lbl">Nefes</span>',
    '    </div>',

    '    <div class="gh-rail-wrap">',
    '      <div class="gh-rail" data-k="rail">',
    '        <div class="gh-rail__ticks"></div>',
    '        <div class="gh-tension" data-k="tension"></div>',
    '        <div data-k="zones"></div>',
    '        <div class="gh-combo" data-k="comboKeys"></div>',
    '        <div class="gh-marker" data-k="marker"></div>',
    '      </div>',
    '      <div class="gh-hint" data-k="hint"></div>',
    '    </div>',

    '    <div class="gh-side">',
    '      <div class="gh-count">',
    '        <span class="gh-count__v" data-k="cV">0</span>',
    '        <span class="gh-count__t" data-k="cT">/ 0</span>',
    '      </div>',
    '      <div class="gh-track" data-k="track"></div>',
    '      <div class="gh-judge" data-k="judge"></div>',
    '      <div class="gh-combo-badge" data-k="comboBadge"></div>',
    '    </div>',
    '  </div>',

    // --- kurulum seridi ---
    '  <div class="gh-setup" data-k="viewSetup" style="display:none">',
    '    <div class="gh-setup__levels" data-k="levels"></div>',
    '    <div class="gh-setup__foot">',
    '      <span class="gh-setup__meta" data-k="setupMeta"></span>',
    '      <span class="gh-hint">',
    '        <span>' + key('A') + key('D') + 'kademe</span>',
    '        <span>' + key('E') + 'başlat</span>',
    '        <span>' + key('X') + 'vazgeç</span>',
    '      </span>',
    '    </div>',
    '  </div>',

    // --- bilek guresi ---
    '  <div class="gh-grip" data-k="viewGrip" style="display:none">',
    '    <div class="gh-grip__ends"><span data-k="gripThem">Rakip</span><span data-k="gripMe">Sen</span></div>',
    '    <div class="gh-grip__bar">',
    '      <div class="gh-grip__center"></div>',
    '      <div class="gh-grip__knob" data-k="gripKnob"></div>',
    '    </div>',
    '    <div class="gh-hint">' + HINTS.grip + '</div>',
    '  </div>',
    '</div>',

    '<div class="gh-cd" data-k="cd"></div>',
    '<div class="gh-result" data-k="result"></div>'
  ].join('');

  root.querySelectorAll('[data-k]').forEach(function (n) { el[n.getAttribute('data-k')] = n; });

  el.brIcon.innerHTML = ico('wind', 14);

  // -----------------------------------------------------------------------
  // GORUNUM GECISI
  // -----------------------------------------------------------------------
  function setView(v) {
    view = v;
    el.viewRun.style.display = (v === 'run') ? '' : 'none';
    el.viewSetup.style.display = (v === 'setup') ? '' : 'none';
    el.viewGrip.style.display = (v === 'grip') ? '' : 'none';
  }

  function fatiguePips(f) {
    var lit = Math.round(Math.max(0, Math.min(1, f || 0)) * 5);
    var out = '<span class="gh-fatigue__label">Yorgunluk</span><span class="gh-fatigue__pips">';
    for (var i = 1; i <= 5; i++) {
      var cls = 'gh-fatigue__pip';
      if (i <= lit) cls += (i >= 4) ? ' is-on is-high' : ' is-on';
      out += '<span class="' + cls + '"></span>';
    }
    return out + '</span>';
  }

  function head(d) {
    el.hIcon.innerHTML = ico(d.icon || 'dumbbell', 17);
    el.hName.textContent = (d.label || 'Antrenman').toLocaleUpperCase('tr-TR');

    var tags = [];
    if (d.level && d.level.label) tags.push(tag(d.level.label, 'acc', 'weight'));
    if (d.setIndex) tags.push(tag(d.setIndex + '. set'));
    if (d.muscleLabel) tags.push(tag(d.muscleLabel));
    if (d.inProgram) tags.push(tag('Program', 'ok', 'clipboard-check'));
    if (d.isSore) tags.push(tag('Tutulmuş', 'warn', 'triangle-alert'));
    if (typeof d.gainMult === 'number' && d.gainMult < 0.95) {
      tags.push(tag('Verim %' + Math.round(d.gainMult * 100), 'warn'));
    }
    el.hTags.innerHTML = tags.join('');

    el.hFatigue.innerHTML = fatiguePips(d.fatigue);
    el.hEnergy.innerHTML = ico('zap', 13) + '-' + Math.round(d.energyCost || 0);
  }

  // -----------------------------------------------------------------------
  // AC / KAPAT
  // -----------------------------------------------------------------------
  function open(d) {
    clearAll();
    head(d);

    isDuel = !!d.duel;
    setView(d.mechanic === 'grip' ? 'grip' : 'run');

    el.hint.innerHTML = HINTS[d.mechanic] || HINTS.tap;
    el.hint.innerHTML += '<span>' + key('X') + 'seti bitir</span>';

    el.cV.textContent = '0';
    el.cT.textContent = isDuel ? 'dayan' : '/ ' + (d.targetReps || 0);
    el.track.innerHTML = '';
    el.judge.classList.remove('is-show');
    el.comboBadge.classList.remove('is-show');
    el.comboKeys.innerHTML = '';

    setBreath(d.startBreath !== undefined ? d.startBreath : 100);

    if (isDuel) {
      el.vs.classList.add('is-show');
      el.vsMe.textContent = '0';
      el.vsThem.textContent = '0';
      el.vsName.textContent = d.oppName || '';
      el.vsPot.innerHTML = d.pot ? ico('circle-dollar-sign', 13) + nf(d.pot) : '';
    } else {
      el.vs.classList.remove('is-show');
    }

    el.result.classList.remove('is-show');
    root.classList.remove('is-result');
    root.classList.add('is-open');
  }

  function close() {
    clearAll();
    isDuel = false;
    root.classList.remove('is-open');
    root.classList.remove('is-result');
    el.vs.classList.remove('is-show');
    el.cd.classList.remove('is-show');
    if (markerAnim) { markerAnim.cancel(); markerAnim = null; }
  }

  // -----------------------------------------------------------------------
  // RITIM DONGUSU
  // Lua her dongu basinda haber verir; imlec soldan saga bir kez suzulur.
  // Web Animations API kullanildigi icin kare basina JS isi sifirdir.
  // -----------------------------------------------------------------------
  function zone(centerPct, widthPct, kind) {
    return '<div class="gh-zone gh-zone--' + kind + '" style="left:' + centerPct +
      '%;width:' + widthPct + '%"></div>';
  }

  function cycle(d) {
    var w = el.rail.clientWidth || 560;
    var pPct = d.perfectPct || 12;
    var gPct = d.goodPct || 20;
    var html = '';

    if (d.mechanic === 'hold') {
      // Iki centik: indirme ve kaldirma
      var down = (d.holdDown || 0.30) * 100;
      var up = (d.holdUp || 0.72) * 100;
      html += zone(down, gPct, 'good') + zone(up, gPct, 'good');
      html += zone(down, pPct, 'perfect') + zone(up, pPct, 'perfect');

      el.tension.style.left = down + '%';
      el.tension.style.width = (up - down) + '%';
    } else if (d.mechanic === 'combo') {
      // Her yuva icin merkez centik
      var n = d.comboLen || 1;
      for (var i = 0; i < n; i++) {
        var c = ((i + 0.5) / n) * 100;
        html += zone(c, gPct, 'good');
      }
      for (var j = 0; j < n; j++) {
        var c2 = ((j + 0.5) / n) * 100;
        html += zone(c2, pPct, 'perfect');
      }
    } else {
      html += zone(50, gPct, 'good') + zone(50, pPct, 'perfect');
    }

    el.zones.innerHTML = html;
    el.rail.classList.remove('is-holding');

    if (markerAnim) markerAnim.cancel();

    if (el.marker.animate) {
      markerAnim = el.marker.animate(
        [{ transform: 'translateX(0px)' }, { transform: 'translateX(' + w + 'px)' }],
        { duration: Math.max(180, d.tempoMs || 1000), easing: 'linear', fill: 'forwards' }
      );
    }
  }

  function comboSeq(d) {
    var out = '';
    for (var i = 0; i < d.seq.length; i++) {
      var cls = 'gh-combo__key';
      if (i + 1 < d.slot) cls += ' is-done';
      else if (i + 1 === d.slot) cls += ' is-active';
      out += '<div class="' + cls + '">' + (d.seq[i] === 'left' ? 'SOL' : 'SAĞ') + '</div>';
    }
    el.comboKeys.innerHTML = out;
  }

  // -----------------------------------------------------------------------
  // DURUM
  // -----------------------------------------------------------------------
  function setBreath(b) {
    var v = Math.max(0, Math.min(100, b));
    el.brFill.style.height = v + '%';
    el.brPct.textContent = Math.round(v);

    var cls = 'gh-breath__fill';
    if (v <= 22) cls += ' is-crit';
    else if (v <= 45) cls += ' is-low';
    el.brFill.className = cls;
  }

  function state(d) {
    if (typeof d.reps === 'number' && el.cV.textContent !== String(d.reps)) {
      el.cV.textContent = d.reps;
      el.cV.classList.add('is-pop');
      clearTimer('pop');
      timers.pop = setTimeout(function () { el.cV.classList.remove('is-pop'); }, 150);
      if (isDuel) el.vsMe.textContent = d.reps;
    }

    if (!isDuel && typeof d.target === 'number') el.cT.textContent = '/ ' + d.target;
    if (typeof d.breath === 'number') setBreath(d.breath);

    el.rail.classList.toggle('is-holding', !!d.holding);

    if (d.track) {
      // Son 22 tekrar gosterilir; set izi tasmasin
      var t = d.track.slice(-22);
      var out = '';
      for (var i = 0; i < t.length; i++) out += '<div class="gh-track__b g-' + t[i] + '"></div>';
      el.track.innerHTML = out;
    }

    if (d.lastHit) {
      el.judge.className = 'gh-judge gh-judge--' + d.lastHit;
      el.judge.textContent = JUDGE[d.lastHit] || '';
      void el.judge.offsetWidth;               // reflow: animasyon yeniden bassin
      el.judge.classList.add('is-show');

      el.rail.classList.add('is-hit');
      clearTimer('hit');
      timers.hit = setTimeout(function () { el.rail.classList.remove('is-hit'); }, 110);
    }

    if (typeof d.combo === 'number') {
      if (d.combo >= 3) {
        el.comboBadge.textContent = d.combo + '× COMBO';
        el.comboBadge.classList.add('is-show');
      } else {
        el.comboBadge.classList.remove('is-show');
      }
    }
  }

  function skip() {
    el.judge.className = 'gh-judge gh-judge--miss';
    el.judge.textContent = 'KAÇTI';
    void el.judge.offsetWidth;
    el.judge.classList.add('is-show');
  }

  // -----------------------------------------------------------------------
  // KURULUM SERIDI
  // -----------------------------------------------------------------------
  var setupData = null;

  function setup(d) {
    clearAll();
    setupData = d;

    head({
      icon: d.icon, label: d.label, muscleLabel: d.muscle,
      setIndex: d.setIndex, inProgram: d.inProgram, isSore: d.isSore,
      gainMult: d.gainMult, fatigue: d.fatigue, energyCost: 0
    });
    el.hEnergy.innerHTML = ico('zap', 13) + Math.round(d.energy) + '/' + Math.round(d.energyMax);

    setView('setup');
    renderLevels(d.pick);

    el.setupMeta.innerHTML =
      ico('gauge', 13) + ' Kondisyon ' + Math.round(d.condition) +
      ' — ağır kademeler formla açılır';

    root.classList.remove('is-result');
    root.classList.add('is-open');
  }

  function renderLevels(pick) {
    if (!setupData) return;

    el.levels.innerHTML = setupData.levels.map(function (lv) {
      var cls = 'gh-lv';
      if (lv.index === pick) cls += ' is-pick';
      if (!lv.unlocked) cls += ' is-locked';
      else if (!lv.affordable) cls += ' is-poor';

      var body = lv.unlocked
        ? '<div class="gh-lv__stats">' +
            '<span>' + ico('repeat', 11) + ' <b>' + lv.targetReps + '</b></span>' +
            '<span>' + ico('zap', 11) + ' <b>' + Math.round(lv.energyCost) + '</b></span>' +
            '<span>×<b>' + lv.pointMult.toFixed(2) + '</b></span>' +
          '</div>'
        : '<div class="gh-lv__lock">' + ico('lock', 11) + ' ' + lv.minCondition + ' kond.</div>';

      return '<div class="' + cls + '">' +
        '<div class="gh-lv__name">' + esc(lv.label) + '</div>' + body + '</div>';
    }).join('');
  }

  // -----------------------------------------------------------------------
  // BILEK GURESI
  // -----------------------------------------------------------------------
  function gripState(d) {
    var w = el.viewGrip.clientWidth || 700;
    var travel = (w / 2 - 30) * Math.max(-1, Math.min(1, d.bar || 0));
    el.gripKnob.style.transform = 'translateX(' + travel + 'px)';
    el.gripKnob.classList.toggle('is-pushing', !!d.pushing);
    setBreath(d.breath);
  }

  // -----------------------------------------------------------------------
  // SONUC
  // -----------------------------------------------------------------------
  var RESULT_HEAD = {
    complete:  ['SET TAMAM', 'Hedefi tutturdun.'],
    exhausted: ['TÜKENDİN', 'Nefesin bitti, form bozuldu.'],
    quit:      ['SET BİTTİ', 'Kendi isteğinle bıraktın.']
  };

  function rstat(k, v, sub) {
    return '<div class="gh-rstat"><span class="gh-rstat__k">' + esc(k) + '</span>' +
      '<span class="gh-rstat__v">' + v + (sub ? '<small>' + esc(sub) + '</small>' : '') + '</span></div>';
  }

  function note(text, variant, iconName) {
    return '<div class="note' + (variant ? ' note--' + variant : '') + '">' +
      ico(iconName || 'info', 14) + '<span>' + text + '</span></div>';
  }

  function showResult(html, ms) {
    el.result.innerHTML = html;
    root.classList.add('is-result');
    el.result.classList.add('is-show');

    timers.res = setTimeout(function () {
      el.result.classList.remove('is-show');
      root.classList.remove('is-result');
      timers.res2 = setTimeout(close, 320);
    }, ms);
  }

  function result(d) {
    clearAll();

    var reps = d.reps || 0;
    var preset = RESULT_HEAD[d.reason] || RESULT_HEAD.complete;
    var title = reps > 0 ? preset[0] : 'SET İPTAL';
    var sub = reps > 0 ? preset[1] : 'Tekrar sayılmadı.';

    var notes = [];
    if (d.newRecord) notes.push(note('Yeni kişisel rekor: ' + esc(d.recordLabel || ''), 'brass', 'medal'));
    if (d.programDone) {
      notes.push(note('Günlük programı tamamladın (+' + nf(d.programBonus) +
        ' FP, seri ' + (d.streak || 0) + ' gün)', 'ok', 'clipboard-check'));
    } else if (d.inProgram) {
      notes.push(note('Bu set günlük programına sayıldı.', 'ok', 'clipboard-check'));
    }
    if (d.isSore) notes.push(note('Kas grubu tutulmuş — verim düşük. Yarın başka grup çalış.', 'warn', 'triangle-alert'));
    if (d.cappedByDaily) notes.push(note('Günlük kondisyon tavanına ulaştın.', 'warn', 'ban'));
    else if (typeof d.gainMult === 'number' && d.gainMult < 0.62) {
      notes.push(note('Aynı alette çok fazla set yaptın, verim %' + Math.round(d.gainMult * 100) + '.', 'warn', 'trending-down'));
    }

    var stats = rstat('Tekrar', reps) +
      rstat('Form Kalitesi', '%' + Math.round((d.quality || 0) * 100)) +
      (d.comboMult && d.comboMult > 1.01 ? rstat('Combo Çarpanı', '×' + d.comboMult.toFixed(2)) : '') +
      rstat('Form Puanı', '+' + nf(d.fp), 'FP') +
      rstat('Kondisyon', '+' + (d.condition || 0).toFixed(1)) +
      (d.powerScore ? rstat('Vuruş Gücü', d.powerScore, '/ 999') : '') +
      rstat('Kalan Enerji', Math.round(d.energyLeft || 0), '/ ' + Math.round(d.energyMax || 0));

    showResult([
      '<div class="gh-result__head">',
      '  <div class="gh-result__title">', esc(title), '</div>',
      '  <div class="gh-result__sub">', esc(sub), '</div>',
      '</div>',
      '<div class="gh-result__stats">', stats, '</div>',
      notes.length ? '<div class="gh-result__notes">' + notes.join('') + '</div>' : ''
    ].join(''), notes.length > 1 ? 7200 : 5400);
  }

  function duelResult(d) {
    clearAll();
    el.vs.classList.remove('is-show');

    var notes = [];
    if (d.won && d.prize > 0) notes.push(note('Potu aldın: $' + nf(d.prize), 'brass', 'circle-dollar-sign'));
    else if (!d.won) notes.push(note('Kaybetmek de antrenmandır — yine de puan kazandın.', 'warn', 'info'));

    var stats = rstat('Senin Tekrarın', d.myReps || 0) +
      rstat('Rakibin', d.oppReps || 0) +
      rstat('Form Puanı', '+' + nf(d.fp), 'FP') +
      rstat('Ödül', d.prize > 0 ? '$' + nf(d.prize) : '—');

    showResult([
      '<div class="gh-result__head">',
      '  <div class="gh-result__title" style="color:',
      (d.won ? 'var(--brass-hi)' : 'var(--bad)'), '">', d.won ? 'KAZANDIN' : 'KAYBETTİN', '</div>',
      '  <div class="gh-result__sub">', esc(d.reason || ''), '</div>',
      '</div>',
      '<div class="gh-result__stats">', stats, '</div>',
      '<div class="gh-result__notes">', notes.join(''), '</div>'
    ].join(''), 6400);
  }

  // -----------------------------------------------------------------------
  // MESAJ YONLENDIRICI
  // -----------------------------------------------------------------------
  var HANDLERS = {
    open: open,
    cycle: cycle,
    state: state,
    combo: comboSeq,
    skip: skip,
    setup: setup,
    setupPick: function (d) { renderLevels(d.pick); },
    setupDeny: function () {
      el.viewSetup.classList.add('is-deny');
      setTimeout(function () { el.viewSetup.classList.remove('is-deny'); }, 340);
    },
    setupClose: function () { setView('run'); },
    gripState: gripState,
    countdown: function (d) {
      if (d.value === false || d.value === undefined) { el.cd.classList.remove('is-show'); return; }
      el.cd.textContent = d.value;
      el.cd.classList.remove('is-show');
      void el.cd.offsetWidth;
      el.cd.classList.add('is-show');
    },
    opp: function (d) { if (typeof d.reps === 'number') el.vsThem.textContent = d.reps; },
    result: result,
    duelResult: duelResult,
    close: close
  };

  window.addEventListener('message', function (event) {
    var msg = event.data;
    if (!msg || typeof msg.action !== 'string') return;
    if (msg.action.indexOf('gym:hud:') !== 0) return;

    var fn = HANDLERS[msg.action.slice(8)];
    if (fn) fn(msg.data || {});
  });
})();
