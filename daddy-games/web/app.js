// Web Audio API Context
let audioCtx = null;

function getAudioContext() {
    if (!audioCtx) {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        if (AudioContextClass) {
            audioCtx = new AudioContextClass();
        }
    }
    if (audioCtx && audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    return audioCtx;
}

// 🎲 Gerçekçi Zar Sesi
function playDiceSound(vol = 0.4) {
    if (vol <= 0.01) return;
    const ctx = getAudioContext();
    if (!ctx) return;

    const clicks = 5;
    for (let i = 0; i < clicks; i++) {
        setTimeout(() => {
            if (!ctx) return;
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            const filter = ctx.createBiquadFilter();

            osc.type = 'triangle';
            osc.frequency.setValueAtTime(140 + Math.random() * 80, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(40, ctx.currentTime + 0.05);

            filter.type = 'lowpass';
            filter.frequency.setValueAtTime(600, ctx.currentTime);

            gain.gain.setValueAtTime(vol * (0.6 + Math.random() * 0.4), ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.06);

            osc.connect(filter);
            filter.connect(gain);
            gain.connect(ctx.destination);

            osc.start();
            osc.stop(ctx.currentTime + 0.07);
        }, i * (50 + Math.random() * 40));
    }
}

// 🪙 Bozuk Para Şıngırtısı
function playCoinSound(vol = 0.4) {
    if (vol <= 0.01) return;
    const ctx = getAudioContext();
    if (!ctx) return;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(1800, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(2400, ctx.currentTime + 0.15);

    gain.gain.setValueAtTime(vol * 0.8, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.36);
}

// ✂️ Taş Kağıt Makas Sesi
function playRpsSound(vol = 0.4) {
    if (vol <= 0.01) return;
    const ctx = getAudioContext();
    if (!ctx) return;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(320, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(100, ctx.currentTime + 0.12);

    gain.gain.setValueAtTime(vol * 0.7, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.14);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.15);
}

// 🃏 Kart Çekme Sesi
function playCardSound(vol = 0.4) {
    if (vol <= 0.01) return;
    const ctx = getAudioContext();
    if (!ctx) return;

    const bufferSize = ctx.sampleRate * 0.1;
    const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
    }

    const noise = ctx.createBufferSource();
    noise.buffer = buffer;

    const filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1400;
    filter.Q.value = 3;

    const gain = ctx.createGain();
    gain.gain.setValueAtTime(vol * 0.9, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.09);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);

    noise.start();
}

// 🔢 Sayı Sesi
function playNumberSound(vol = 0.4) {
    if (vol <= 0.01) return;
    const ctx = getAudioContext();
    if (!ctx) return;

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(440, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(880, ctx.currentTime + 0.1);

    gain.gain.setValueAtTime(vol * 0.7, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.12);

    osc.connect(gain);
    gain.connect(ctx.destination);

    osc.start();
    osc.stop(ctx.currentTime + 0.13);
}

// =========================================================================
// 🪙 GOOGLE COINFLIP STİLİ İKONİK ALTIN SİKKE
// =========================================================================
const GOOGLE_COIN_GRAPHICS = {
    heads: `
        <svg viewBox="0 0 100 100" class="google-coin-svg" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <linearGradient id="gCoinGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#fffbeb"/>
                    <stop offset="25%" stop-color="#fde047"/>
                    <stop offset="65%" stop-color="#eab308"/>
                    <stop offset="100%" stop-color="#a16207"/>
                </linearGradient>
                <linearGradient id="gInnerGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#fef08a"/>
                    <stop offset="100%" stop-color="#ca8a04"/>
                </linearGradient>
            </defs>
            <circle cx="50" cy="50" r="46" fill="url(#gCoinGrad)" stroke="#a16207" stroke-width="2.5"/>
            <circle cx="50" cy="50" r="39" fill="none" stroke="#713f12" stroke-width="1.5" stroke-dasharray="3,3" opacity="0.6"/>
            <circle cx="50" cy="50" r="34" fill="url(#gInnerGrad)"/>
            <!-- Temiz İkonik Kafa Silüeti -->
            <path d="M50,25 C43,25 39,29 38,35 C37,39 39,42 36,45 C34,47 32,48 32,51 C32,55 35,57 38,58 C36,61 34,65 32,71 C37,74 45,75 53,75 C61,75 68,73 71,68 C68,62 66,57 63,55 C64,50 63,46 59,42 C61,36 58,30 53,26 C51.5,25.3 50.8,25 50,25 Z" fill="#713f12"/>
            <text x="50" y="85" font-family="'Segoe UI', Roboto, sans-serif" font-size="8.5" font-weight="900" fill="#713f12" text-anchor="middle" letter-spacing="1">YAZI</text>
        </svg>
    `,
    tails: `
        <svg viewBox="0 0 100 100" class="google-coin-svg" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <linearGradient id="gCoinGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#fffbeb"/>
                    <stop offset="25%" stop-color="#fde047"/>
                    <stop offset="65%" stop-color="#eab308"/>
                    <stop offset="100%" stop-color="#a16207"/>
                </linearGradient>
                <linearGradient id="gInnerGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#fef08a"/>
                    <stop offset="100%" stop-color="#ca8a04"/>
                </linearGradient>
            </defs>
            <circle cx="50" cy="50" r="46" fill="url(#gCoinGrad2)" stroke="#a16207" stroke-width="2.5"/>
            <circle cx="50" cy="50" r="39" fill="none" stroke="#713f12" stroke-width="1.5" stroke-dasharray="3,3" opacity="0.6"/>
            <circle cx="50" cy="50" r="34" fill="url(#gInnerGrad2)"/>
            <!-- Temiz İkonik Yıldız / Taç & Kalkan -->
            <g transform="translate(24, 23) scale(0.52)" fill="#713f12">
                <path d="M50,15 L58,35 L80,35 L62,48 L69,70 L50,56 L31,70 L38,48 L20,35 L42,35 Z"/>
            </g>
            <text x="50" y="85" font-family="'Segoe UI', Roboto, sans-serif" font-size="8.5" font-weight="900" fill="#713f12" text-anchor="middle" letter-spacing="1">TURA</text>
        </svg>
    `
};

const badgeContainer = document.getElementById('badge-container');
const badges = new Map();

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;

    if (data.action === 'showAction') {
        createBadge(data);
    } else if (data.action === 'updatePositions') {
        updateBadgePositions(data.badges);
    } else if (data.action === 'cleanup') {
        cleanupAll();
    }
});

// 3x3 Grid Gerçekçi Zar Noktaları Düzeni
function renderDicePips(value) {
    if (value < 1 || value > 6) {
        return `<div class="dice-custom-face">${value}</div>`;
    }

    if (value === 1) {
        return `
            <div></div><div></div><div></div>
            <div></div><div class="pip ace-pip"></div><div></div>
            <div></div><div></div><div></div>
        `;
    } else if (value === 2) {
        return `
            <div class="pip"></div><div></div><div></div>
            <div></div><div></div><div></div>
            <div></div><div></div><div class="pip"></div>
        `;
    } else if (value === 3) {
        return `
            <div class="pip"></div><div></div><div></div>
            <div></div><div class="pip"></div><div></div>
            <div></div><div></div><div class="pip"></div>
        `;
    } else if (value === 4) {
        return `
            <div class="pip"></div><div></div><div class="pip"></div>
            <div></div><div></div><div></div>
            <div class="pip"></div><div></div><div class="pip"></div>
        `;
    } else if (value === 5) {
        return `
            <div class="pip"></div><div></div><div class="pip"></div>
            <div></div><div class="pip"></div><div></div>
            <div class="pip"></div><div></div><div class="pip"></div>
        `;
    } else if (value === 6) {
        return `
            <div class="pip"></div><div></div><div class="pip"></div>
            <div class="pip"></div><div></div><div class="pip"></div>
            <div class="pip"></div><div></div><div class="pip"></div>
        `;
    }
}

function createBadge(data) {
    if (badges.has(data.id)) {
        removeBadge(data.id);
    }

    const badgeEl = document.createElement('div');
    badgeEl.className = 'floating-badge hidden';
    badgeEl.id = data.id;

    badgeEl.innerHTML = `
        <div class="diegetic-wrap" id="body_${data.id}">
            <div class="rolling-placeholder">
                <div class="rolling-orb"></div>
                <div class="rolling-orb"></div>
                <div class="rolling-orb"></div>
            </div>
        </div>
    `;

    badgeContainer.appendChild(badgeEl);
    badges.set(data.id, {
        element: badgeEl,
        data: data,
        createdAt: Date.now()
    });

    if (data.enableSound) {
        const distRatio = Math.max(0, 1 - (data.distance / data.maxDistance));
        const finalVol = (data.soundVolume || 0.5) * distRatio;

        if (data.actionType === 'dice') playDiceSound(finalVol);
        else if (data.actionType === 'coin') playCoinSound(finalVol);
        else if (data.actionType === 'rps') playRpsSound(finalVol);
        else if (data.actionType === 'card') playCardSound(finalVol);
        else if (data.actionType === 'number') playNumberSound(finalVol);
    }

    setTimeout(() => {
        revealResult(data);
    }, data.revealDelay || 1100);

    setTimeout(() => {
        removeBadge(data.id);
    }, data.duration || 6500);
}

function revealResult(data) {
    const bodyEl = document.getElementById(`body_${data.id}`);
    if (!bodyEl) return;

    let html = '';

    if (data.actionType === 'dice') {
        const res = data.resultData;
        let diceHtml = '<div class="dice-row">';
        for (const val of res.rolls) {
            diceHtml += `<div class="realistic-dice">${renderDicePips(val)}</div>`;
        }
        diceHtml += '</div>';

        if (res.count > 1 || res.sides !== 6) {
            diceHtml += `
                <div class="diegetic-total">
                    <span>TOPLAM</span> ${res.total}
                </div>
            `;
        }
        html = diceHtml;
    } else if (data.actionType === 'coin') {
        const res = data.resultData;
        const svgContent = res.isHeads ? GOOGLE_COIN_GRAPHICS.heads : GOOGLE_COIN_GRAPHICS.tails;
        html = `
            <div class="google-coin-wrap">
                ${svgContent}
            </div>
        `;
    } else if (data.actionType === 'rps') {
        const res = data.resultData;
        const key = (res.key || '').toLowerCase();
        let handEmoji = '✊';

        if (key === 'kagit') {
            handEmoji = '✋';
        } else if (key === 'makas') {
            handEmoji = '✌️';
        }

        // Yalnızca saf büyük el emojisi (Kutusuz, yazısız!)
        html = `
            <div class="large-emoji-rps">
                ${handEmoji}
            </div>
        `;
    } else if (data.actionType === 'card') {
        const res = data.resultData;
        const color = (res.suit === 'Kupa' || res.suit === 'Karo') ? '#dc2626' : '#0f172a';

        html = `
            <div class="realistic-card">
                <div class="card-corner top-corner" style="color: ${color};">
                    <span class="card-corner-code">${res.code}</span>
                    <span class="card-corner-symbol">${res.symbol}</span>
                </div>
                <div class="card-center-symbol" style="color: ${color};">
                    ${res.symbol}
                </div>
                <div class="card-corner bottom-corner" style="color: ${color};">
                    <span class="card-corner-code">${res.code}</span>
                    <span class="card-corner-symbol">${res.symbol}</span>
                </div>
            </div>
        `;
    } else if (data.actionType === 'number') {
        const res = data.resultData;
        html = `
            <div class="realistic-number">
                <span class="number-main-val">${res.result}</span>
                <span class="number-sub-range">${res.min} - ${res.max}</span>
            </div>
        `;
    }

    bodyEl.innerHTML = html;
}

function updateBadgePositions(updates) {
    if (!updates) return;

    for (const update of updates) {
        const badge = badges.get(update.id);
        if (!badge || !badge.element) continue;

        if (update.visible) {
            badge.element.classList.remove('hidden');
            badge.element.style.left = `${update.x}%`;
            badge.element.style.top = `${update.y}%`;
            badge.element.style.transform = `translate(-50%, -100%) scale(${update.scale || 1.0})`;
            badge.element.style.opacity = update.opacity !== undefined ? update.opacity : 1.0;
        } else {
            badge.element.classList.add('hidden');
        }
    }
}

function removeBadge(id) {
    const badge = badges.get(id);
    if (badge && badge.element) {
        badge.element.style.opacity = '0';
        badge.element.style.transform = 'translate(-50%, -100%) scale(0.7)';
        setTimeout(() => {
            if (badge.element && badge.element.parentNode) {
                badge.element.parentNode.removeChild(badge.element);
            }
            badges.delete(id);
        }, 250);
    }
}

function cleanupAll() {
    badges.forEach((b) => {
        if (b.element && b.element.parentNode) {
            b.element.parentNode.removeChild(b.element);
        }
    });
    badges.clear();
}
