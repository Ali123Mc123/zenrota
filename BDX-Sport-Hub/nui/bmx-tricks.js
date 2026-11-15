// ═══════════════════════════════════════════════════════════
// BMX TRICK HUD — Combo Accumulator (v5)
// Each trick/grind/landing restarts a 3-second silence timer.
// If another event arrives within the window, points sum into the active
// combo entry. When the timer expires, a quality verdict (GOOD/GREAT/
// AWESOME/EPIC/LEGENDARY) shows once based on total combo score, and the
// HUD hides cleanly (no fade/force-disappear animation).
// Landing events within 500ms of another landing are deduped so a single
// real landing only produces one entry.
// ═══════════════════════════════════════════════════════════
(function() {
    'use strict';

    // ─── HUD container ───
    var hud = document.createElement('div');
    hud.id = 'bmx-trick-hud';
    hud.innerHTML = [
        '<div id="bmx-combo-bar">',
        '  <div id="bmx-combo-fill"></div>',
        '  <div id="bmx-combo-text">',
        '    <span id="bmx-combo-new" style="display:none">NEW</span>',
        '    <span id="bmx-combo-name"></span>',
        '    <span id="bmx-combo-deg"></span>',
        '  </div>',
        '</div>',
        '<div id="bmx-entries"></div>',
        '<div id="bmx-score"></div>'
    ].join('');
    var qualityOverlay = document.createElement('div');
    qualityOverlay.id = 'bmx-quality-overlay';
    qualityOverlay.innerHTML = '<div id="bmx-quality-word"></div><div id="bmx-quality-score"></div>';
    hud.appendChild(qualityOverlay);
    document.body.appendChild(hud);

    // ─── State ───
    var SILENCE_MS         = 3000;  // no-activity window before quality shows
    var LANDING_DEDUPE_MS  = 500;   // drop duplicate landings fired within this

    var silenceTimer  = null;       // fires endCombo() when no new events for SILENCE_MS
    var qualityTimer  = null;
    var comboActiveProgress = false;
    var comboTotalPts = 0;          // accumulated points in the current combo
    var comboEntryEl  = null;       // single DOM entry showing accumulated combo
    var comboLabelStack = [];       // last few trick names for display
    var comboEventCount = 0;        // number of events that contributed
    var lastLandingAt = 0;
    var seenTricks    = {};
    var landedTricks  = {};
    var peakDegrees   = 0;
    var lastMilestone = 0;

    // ─── Visibility (no fade class — just show/hide) ───
    function show() { hud.classList.add('visible'); }
    function hide() { hud.classList.remove('visible'); }

    // ─── Combo accumulator ───
    function startSilenceTimer() {
        clearTimeout(silenceTimer);
        silenceTimer = setTimeout(endCombo, SILENCE_MS);
    }

    function addToCombo(label, points, kind) {
        show();
        comboTotalPts += (points || 0);
        comboEventCount++;
        // Keep a short trail of trick labels in the entry (max 3 rows)
        if (label) {
            comboLabelStack.push({ label: label, points: points || 0, kind: kind || 'trick' });
            if (comboLabelStack.length > 3) comboLabelStack.shift();
        }
        renderComboEntry();
        updateScoreDisplay(comboTotalPts);
        startSilenceTimer();
    }

    function renderComboEntry() {
        var entries = document.getElementById('bmx-entries');
        if (!comboEntryEl) {
            comboEntryEl = document.createElement('div');
            comboEntryEl.className = 'bmx-entry bmx-entry-trick';
            entries.insertBefore(comboEntryEl, entries.firstChild);
        }
        // Header: event count + total pts
        var header = comboEventCount > 1
            ? ('COMBO x' + comboEventCount)
            : (comboLabelStack[0] ? comboLabelStack[0].label : 'TRICK');
        var rows = comboLabelStack.map(function(e) {
            return '<div class="bmx-entry-sub">' + e.label + ' <span class="bmx-entry-sub-pts">+' + (e.points || 0).toLocaleString() + '</span></div>';
        }).join('');
        comboEntryEl.innerHTML =
            '<div class="bmx-entry-bar">' +
            '<span class="bmx-entry-name">' + header + '</span>' +
            '<span class="bmx-entry-pts">' + comboTotalPts.toLocaleString() + ' <small>PTS</small></span>' +
            '</div>' +
            (comboEventCount > 1 ? rows : '');
    }

    function endCombo() {
        clearTimeout(silenceTimer);
        silenceTimer = null;
        if (comboTotalPts <= 0 && comboEventCount === 0) return;
        var finalPts = comboTotalPts;
        // Mark tricks as landed now that combo ended cleanly
        for (var t in seenTricks) landedTricks[t] = true;

        showQuality(finalPts);
        // Clear combo state — entry fades out with the HUD hide below
        comboTotalPts = 0;
        comboEventCount = 0;
        comboLabelStack = [];
        comboEntryEl = null;
        var entries = document.getElementById('bmx-entries');
        if (entries) entries.innerHTML = '';
        // Hide HUD after a short beat so the quality overlay gets a moment
        // to be seen on its own (overlay has its own timer).
        setTimeout(hide, 1500);
    }

    function updateScoreDisplay(pts) {
        var el = document.getElementById('bmx-score');
        if (!el) return;
        el.style.display = 'block';
        el.innerHTML = '<div id="bmx-score-num">' + pts.toLocaleString() + '<span class="pts">PTS</span></div>';
    }

    // ─── Live rotation bar (during an in-air trick) ───
    function updateCombo(trickName, degrees, maxDeg, score) {
        show();
        comboActiveProgress = true;
        var bar = document.getElementById('bmx-combo-bar');
        var fill = document.getElementById('bmx-combo-fill');
        var nameEl = document.getElementById('bmx-combo-name');
        var degEl = document.getElementById('bmx-combo-deg');
        var newEl = document.getElementById('bmx-combo-new');

        bar.style.display = 'block';
        if (degrees > peakDegrees) peakDegrees = degrees;
        var pct = Math.min(100, (degrees / maxDeg) * 100);
        fill.style.width = pct + '%';
        nameEl.textContent = trickName;
        degEl.textContent = score > 0 ? score.toLocaleString() + ' PTS' : '';

        var cleanName = trickName.replace(/ \d+$/, '');
        newEl.style.display = seenTricks[cleanName] ? 'none' : 'inline-block';

        var snap = Math.floor(degrees / 180) * 180;
        if (snap > lastMilestone && snap >= 180) {
            lastMilestone = snap;
            bar.classList.remove('milestone');
            void bar.offsetWidth;
            bar.classList.add('milestone');
            setTimeout(function() { bar.classList.remove('milestone'); }, 400);
        }
    }

    // ─── Quality verdict overlay ───
    function showQuality(pts) {
        clearTimeout(qualityTimer);
        var word, tier;
        if (pts >= 25000)      { word = 'LEGENDARY'; tier = 'legendary'; }
        else if (pts >= 15000) { word = 'EPIC';      tier = 'epic'; }
        else if (pts >= 10000) { word = 'AWESOME';   tier = 'awesome'; }
        else if (pts >= 5000)  { word = 'GREAT';     tier = 'great'; }
        else if (pts >= 500)   { word = 'GOOD';      tier = 'good'; }
        else                   { return; }  // tiny score, no verdict

        var wordEl  = document.getElementById('bmx-quality-word');
        var scoreEl = document.getElementById('bmx-quality-score');
        wordEl.textContent = word;
        wordEl.setAttribute('data-text', word);
        wordEl.className = tier;
        scoreEl.innerHTML = pts.toLocaleString() + '<span>PTS</span>';
        scoreEl.classList.remove('animate');
        void scoreEl.offsetWidth;
        scoreEl.classList.add('animate');
        qualityOverlay.classList.add('visible');
        qualityTimer = setTimeout(function() {
            qualityOverlay.classList.remove('visible');
        }, 3000);
    }

    function resetState() {
        clearTimeout(silenceTimer);
        clearTimeout(qualityTimer);
        silenceTimer = null;
        qualityTimer = null;
        comboTotalPts = 0;
        comboEventCount = 0;
        comboLabelStack = [];
        comboEntryEl = null;
        comboActiveProgress = false;
        peakDegrees = 0;
        lastMilestone = 0;
        lastLandingAt = 0;
        var entries = document.getElementById('bmx-entries');
        if (entries) entries.innerHTML = '';
        var bar = document.getElementById('bmx-combo-bar');
        if (bar) bar.style.display = 'none';
        var scoreEl = document.getElementById('bmx-score');
        if (scoreEl) scoreEl.style.display = 'none';
        qualityOverlay.classList.remove('visible');
        hide();
    }

    // ─── Messages from Lua ───
    window.addEventListener('message', function(e) {
        var d = e.data;

        if (d.type === 'bmxComboProgress') {
            updateCombo(d.trickName || 'TRICK', d.degrees || 0, d.maxDegrees || 720, d.score || 0);
            return;
        }

        if (d.type === 'bdx_trickScore' && d.trickName) {
            var clean = d.trickName.replace(/ M$/, '').replace(/ \d+$/, '');
            seenTricks[clean] = true;
            if (comboActiveProgress) {
                // Live rotation ended — hide the progress bar before the
                // trick enters the accumulator as a scored event.
                var bar = document.getElementById('bmx-combo-bar');
                if (bar) bar.style.display = 'none';
                comboActiveProgress = false;
                lastMilestone = 0;
                peakDegrees = 0;
            }
            addToCombo(d.trickName, d.points || 0, 'trick');
            return;
        }

        if (d.type === 'bdx_chainUpdate') {
            // Chain totals roll into the existing combo accumulator — no
            // separate entry needed, just keep the silence timer alive and
            // update the displayed total.
            if (typeof d.chainScore === 'number' && d.chainScore > comboTotalPts) {
                comboTotalPts = d.chainScore;
                renderComboEntry();
                updateScoreDisplay(comboTotalPts);
            }
            startSilenceTimer();
            show();
            return;
        }

        if (d.type === 'bmxLanding') {
            var now = Date.now();
            // Dedupe: drop landings that fire within 500ms of the last one.
            // A single physical landing can trigger multiple events from
            // different code paths — we only want ONE entry per real land.
            if (now - lastLandingAt < LANDING_DEDUPE_MS) return;
            lastLandingAt = now;

            var q = d.quality || 'good';
            var pts = d.points || 0;
            var label = 'PERFECT LANDING';
            if (q === 'great')     label = 'GREAT LANDING';
            else if (q === 'good') label = 'GOOD LANDING';
            else if (q === 'bad')  label = 'BAD LANDING';

            if (pts > 0) {
                addToCombo(label, pts, 'landing');
            } else {
                // No-points landing — still extend the silence timer so
                // quality verdict doesn't fire mid-flight.
                startSilenceTimer();
            }
            return;
        }

        if (d.type === 'bdx_chainEnd') {
            // Explicit chain-end: flush the combo immediately to the
            // quality verdict instead of waiting for the silence timer.
            if (typeof d.chainScore === 'number' && d.chainScore > comboTotalPts) {
                comboTotalPts = d.chainScore;
            }
            endCombo();
            return;
        }

        if (d.type === 'bdx_chainHold') {
            // Keep-alive ping from Lua while the player is airborne mid-
            // trick. Resets the 3-second silence timer so big aerials
            // (long spins, multi-second air time) don't expire the combo
            // before the player lands.
            if (comboTotalPts > 0) startSilenceTimer();
            return;
        }

        if (d.type === 'bdx_clearTricks') {
            // Soft reset (no verdict) — used when tricks cancel out.
            resetState();
            return;
        }

        if (d.type === 'bdx_hasFailed') {
            // Bail: wipe everything including landed-tricks tracker so
            // NEW shows again next session.
            landedTricks = {};
            seenTricks = {};
            resetState();
            return;
        }

        if (d.type === 'bdx_forceClear') {
            resetState();
            return;
        }
    });
})();
