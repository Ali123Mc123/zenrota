(() => {
    'use strict';
    const panel = document.createElement('section');
    panel.className = 'gokart-hud'; panel.hidden = true;
    panel.innerHTML = `<div class="rh-head"><div class="rh-tag" id="kart-mode"></div><div class="rh-brand"><span data-i18n="go_kart_brand"></span><small data-i18n="los_santos_karting"></small></div></div>
        <div class="rh-box"><div class="rh-top"><div><b id="kart-position"></b></div><div class="rh-lap"><small data-i18n="lap"></small><b id="kart-lap"></b></div></div>
        <div class="rh-status"><span id="kart-phase"></span><strong id="kart-time"></strong></div>
        </div>
        <div class="player-section rh-section"><span data-i18n="karting_circuit"></span><em id="kart-track-length"></em></div>
        <div class="rh-track"><svg class="gokart-route" viewBox="0 0 260 150" data-i18n-aria-label="track_and_vehicle_position"><path id="kart-route-path"/><circle id="kart-route-start" r="3"/><circle id="kart-route-target" r="3"/><circle id="kart-route-car" r="4.5"/></svg></div>
        <div class="rh-bottom"><div class="rh-speed"><div><b id="kart-speed">000</b><small data-i18n="km_h"></small></div><span class="rh-gear"><small data-i18n="gear"></small><kbd id="kart-gear">N</kbd></span><div class="rh-gate-inline"><small data-i18n="lap_progress"></small><b id="kart-gate"></b></div><div class="rh-lapbar"><i id="kart-progress"></i></div><div class="rh-revs" hidden><i id="kart-revs"></i></div></div></div>`;
    const overlay = document.createElement('section');
    overlay.className = 'gokart-overlay'; overlay.hidden = true;
    overlay.innerHTML = `<div class="rh-start" id="kart-start" hidden><div class="rh-tag" data-i18n="race_start_tag"></div><div class="rh-start-row"><small id="kart-start-label" data-i18n="race_starting_in"></small><b id="kart-countdown"></b><i class="rh-start-bar"><span id="kart-start-bar"></span></i></div></div>
        <div class="rh-toast" id="kart-toast" hidden><small id="kart-toast-label"></small><b id="kart-toast-value"></b></div>
        <div class="rh-result" id="kart-result" hidden><div class="rh-tag" data-i18n="chequered_flag"></div><div class="rh-result-box"><p id="kart-result-position"></p><small data-i18n="total_time"></small><b id="kart-result-time"></b><footer data-i18n="race_complete_at_entry_point"></footer></div></div>`;
    document.body.append(panel, overlay);
    const elements = new Map();
    const el = id => {
        if (!elements.has(id)) elements.set(id, document.getElementById(`kart-${id}`));
        return elements.get(id);
    };
    const set = (id, text) => { const node = el(id), value = String(text); if (node.textContent !== value) node.textContent = value; };
    const formatTime = value => {
        if (value == null || !Number.isFinite(value)) return '—';
        const cs = Math.max(0, Math.floor(value / 10));
        return `${Math.floor(cs / 6000)}:${String(Math.floor(cs / 100) % 60).padStart(2, '0')}.${String(cs % 100).padStart(2, '0')}`;
    };
    let state = null, received = 0, points = [], project = null, goUntil = 0, toastUntil = 0, clockTimer = null;
    let startTotal = 0;
    const reset = () => {
        if (clockTimer !== null) clearInterval(clockTimer);
        clockTimer = null;
        state = null; goUntil = 0; toastUntil = 0; panel.hidden = true; overlay.hidden = true;
        el('start').hidden = true; el('toast').hidden = true; el('result').hidden = true;
        el('route-car').style.display = 'none';
        set('speed', '000'); set('gear', 'N'); el('revs').style.transform = 'scaleX(0)';
    };
    const toast = (label, value) => {
        set('toast-label', label); set('toast-value', value);
        el('toast').hidden = false; toastUntil = performance.now() + 3000;
    };
    window.addEventListener('message', ({ data: message }) => {
        if (!message || typeof message.action !== 'string') return;
        if (message.action === 'gokart:hide') { reset(); return; }
        if (message.action === 'gokart:route') {
            reset();
            const route = message.data;
            if (!Array.isArray(route) || route.length < 2) return;
            const minX = Math.min(...route.map(p => p.x)), maxX = Math.max(...route.map(p => p.x));
            const minY = Math.min(...route.map(p => p.y)), maxY = Math.max(...route.map(p => p.y));
            const scale = Math.min(240 / Math.max(1, maxX - minX), 130 / Math.max(1, maxY - minY));
            const offsetX = (260 - (maxX - minX) * scale) / 2;
            const offsetY = (150 - (maxY - minY) * scale) / 2;
            project = p => ({ x: offsetX + (p.x - minX) * scale, y: offsetY + (maxY - p.y) * scale });
            points = route.map(project);
            el('route-path').setAttribute('d', points.map((p, i) => `${i ? 'L' : 'M'}${p.x},${p.y}`).join(' ') + ' Z');
            el('route-start').setAttribute('cx', points[0].x); el('route-start').setAttribute('cy', points[0].y);
            const length = route.reduce((sum, p, i) => sum + Math.hypot(route[(i + 1) % route.length].x - p.x, route[(i + 1) % route.length].y - p.y), 0);
            set('track-length', `${(length / 1000).toFixed(2)} KM`);
            return;
        }
        if (message.action === 'gokart:telemetry') {
            if (!state || panel.hidden || state.finished) return;
            const data = message.data;
            set('speed', String(Math.max(0, Math.round(data.speed))).padStart(3, '0'));
            set('gear', data.gear === 0 ? (data.speed > 2 ? 'R' : 'N') : data.gear);
            el('revs').style.transform = `scaleX(${Math.max(0, Math.min(1, data.rpm))})`;
            if (project) {
                const p = project(data);
                el('route-car').style.display = '';
                el('route-car').setAttribute('cx', p.x); el('route-car').setAttribute('cy', p.y);
            }
            return;
        }
        if (message.action === 'gokart:reset') {
            if (state && !state.finished) toast(window.ActivityLocale.back_to_track(), `+${(message.penalty / 1000).toFixed(2)} ${window.ActivityLocale.seconds_short()}`);
            return;
        }
        if (message.action !== 'gokart:update') return;
        const previous = state;
        state = message.data; received = performance.now();
        if (clockTimer === null) clockTimer = setInterval(updateClock, 100);
        panel.hidden = false; overlay.hidden = false;
        const target = points[state.next - 1];
        if (target) { el('route-target').setAttribute('cx', target.x); el('route-target').setAttribute('cy', target.y); }
        panel.classList.toggle('racing', state.phase === 'RACING');
        panel.classList.toggle('finished', !!state.finished);
        set('position', `P${state.position} / ${state.total}`);
        set('mode', state.total === 1 ? window.ActivityLocale.solo_race() : window.ActivityLocale.multiplayer());
        set('lap', `${state.lap} / ${state.laps}`); set('gate', document.documentElement.lang === 'tr' ? `%${state.progress || 0}` : `${state.progress || 0}%`);
        el('progress').style.transform = `scaleX(${Math.max(0, Math.min(100, state.progress || 0)) / 100})`;
        set('phase', state.finished ? window.ActivityLocale.race_complete() : state.phase === 'LOADING' ? window.ActivityLocale.preparing_track() : state.phase === 'COUNTDOWN' ? window.ActivityLocale.starting_grid() : state.lap === state.laps ? window.ActivityLocale.last_lap_follow_the_line() : window.ActivityLocale.the_race_continues());
        if (state.finished) {
            set('time', formatTime(state.time));
            clearInterval(clockTimer); clockTimer = null;
            el('result').hidden = false; el('start').hidden = true; el('toast').hidden = true;
            goUntil = 0; toastUntil = 0;
            set('result-position', state.total === 1 ? window.ActivityLocale.solo_race_complete() : `${state.resultsPending ? window.ActivityLocale.provisional_position() : window.ActivityLocale.finish_position()}  ${state.position} / ${state.total}`);
            overlay.querySelector('footer').textContent = state.resultsPending
                ? window.ActivityLocale.waiting_for_other_racers_time_penalties_included_in_the_ranking()
                : window.ActivityLocale.the_result_is_finalized_at_entry_point();
            set('result-time', formatTime(state.time));
        } else if (state.phase === 'LOADING') {
            el('start').hidden = true; goUntil = 0; startTotal = 0;
        } else if (state.phase === 'COUNTDOWN') {
            el('start').hidden = false; el('start').classList.remove('go');
            set('countdown', Math.max(1, Math.ceil(state.countdown))); set('start-label', window.ActivityLocale.race_starting_in());
            startTotal = Math.max(startTotal, state.countdown);
            el('start-bar').style.transform = `scaleX(${Math.min(1, Math.max(0, 1 - state.countdown / Math.max(startTotal, 0.001)))})`;
        } else if (previous && previous.phase !== 'RACING' && state.phase === 'RACING') {
            goUntil = performance.now() + 1400; el('start').hidden = false; el('start').classList.add('go');
            el('start-bar').style.transform = 'scaleX(1)';
            set('countdown', window.ActivityLocale.start()); set('start-label', window.ActivityLocale.follow_the_line());
        }
        if (previous && !state.finished && state.lap > previous.lap) {
            toast(state.lap === state.laps ? window.ActivityLocale.you_have_entered_the_final_round() : `${state.lap}. ${window.ActivityLocale.lap()}`, `${state.lap} / ${state.laps}`);
        }
    });
    function updateClock() {
        if (!state || panel.hidden) return;
        const now = performance.now();
        const extra = state.phase === 'RACING' && !state.finished ? Math.min(now - received, 1500) : 0;
        set('time', formatTime(state.time + extra));
        if (goUntil && now >= goUntil) { el('start').hidden = true; goUntil = 0; }
        if (toastUntil && now >= toastUntil) { el('toast').hidden = true; toastUntil = 0; }
    }
})();
