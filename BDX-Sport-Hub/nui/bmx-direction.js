// ═══════════════════════════════════════════════════════════
// BMX TRICK DIRECTION INDICATOR
// Listens for 'bmxDirection' NUI messages and renders a
// circle + direction line in the bottom-right corner.
// ═══════════════════════════════════════════════════════════
(function() {
    'use strict';

    function init() {
        // Remove any existing widget (hot-reload safety)
        const existing = document.getElementById('bmx-direction-widget');
        if (existing) existing.remove();

        // Inject the widget into documentElement (escapes body's flex/overflow)
        const widget = document.createElement('div');
        widget.id = 'bmx-direction-widget';
        // Inline styles so nothing in other CSS files can hide it
        widget.style.cssText = [
            'position: fixed',
            'right: 28%',
            'top: 75%',
            'transform: translate(50%, -50%)',
            'width: 200px',
            'height: 200px',
            'z-index: 9000',
            'pointer-events: none',
            'opacity: 0',
            'transition: opacity 0.3s ease',
            'display: block'
        ].join(' !important;') + ' !important;';

        widget.innerHTML = `
            <svg viewBox="-75 -75 150 150" style="width:100%;height:100%;overflow:visible;filter:drop-shadow(0 0 10px rgba(0,255,255,0.3));">
                <defs>
                    <linearGradient id="bmxDirGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" stop-color="#00e5ff" stop-opacity="0.95" />
                        <stop offset="100%" stop-color="#ff4da6" stop-opacity="0.95" />
                    </linearGradient>
                    <linearGradient id="bmxDirLineGrad" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stop-color="rgba(255,255,255,0.95)" />
                        <stop offset="100%" stop-color="#ff4da6" />
                    </linearGradient>
                </defs>

                <circle cx="0" cy="0" r="52" fill="none" stroke="rgba(0,229,255,0.28)" stroke-width="2" style="filter:blur(4px);" />
                <circle cx="0" cy="0" r="50" fill="none" stroke="rgba(255,255,255,0.22)" stroke-width="1.5" />
                <circle cx="0" cy="0" r="30" fill="none" stroke="rgba(255,255,255,0.18)" stroke-width="1" stroke-dasharray="2 3" />

                <circle id="bmx-dir-arc" cx="0" cy="0" r="50" fill="none"
                        stroke="url(#bmxDirGradient)" stroke-width="2.5" stroke-linecap="round"
                        stroke-dasharray="0 1000" transform="rotate(-90)"
                        style="transition: stroke-dasharray 0.05s linear;" />

                <text x="0" y="-58" fill="rgba(255,255,255,0.5)" font-size="8" font-family="Segoe UI, sans-serif" font-weight="600" letter-spacing="1" text-anchor="middle" dominant-baseline="middle">UP</text>
                <text x="0" y="62"  fill="rgba(255,255,255,0.5)" font-size="8" font-family="Segoe UI, sans-serif" font-weight="600" letter-spacing="1" text-anchor="middle" dominant-baseline="middle">DOWN</text>
                <text x="-60" y="0" fill="rgba(255,255,255,0.5)" font-size="8" font-family="Segoe UI, sans-serif" font-weight="600" letter-spacing="1" text-anchor="middle" dominant-baseline="middle">L</text>
                <text x="60" y="0"  fill="rgba(255,255,255,0.5)" font-size="8" font-family="Segoe UI, sans-serif" font-weight="600" letter-spacing="1" text-anchor="middle" dominant-baseline="middle">R</text>

                <line id="bmx-dir-line" x1="0" y1="0" x2="0" y2="0"
                      stroke="url(#bmxDirLineGrad)" stroke-width="3" stroke-linecap="round"
                      style="filter:drop-shadow(0 0 4px rgba(255,64,160,0.6));" />

                <circle id="bmx-dir-tip" cx="0" cy="0" r="4" fill="#ff4da6"
                        style="filter:drop-shadow(0 0 6px rgba(255,77,166,0.9));" />

                <circle cx="0" cy="0" r="2.5" fill="rgba(255,255,255,0.9)" />
            </svg>
            <div id="bmx-dir-label" style="position:absolute;bottom:-18px;left:50%;transform:translateX(-50%);color:rgba(255,255,255,0.6);font-size:9px;font-weight:600;letter-spacing:2px;text-transform:uppercase;font-family:'Segoe UI',sans-serif;white-space:nowrap;">Direction</div>
        `;

        // Attach to documentElement (html), not body — bypasses body flex layout
        (document.documentElement || document.body).appendChild(widget);

        const line = document.getElementById('bmx-dir-line');
        const tip = document.getElementById('bmx-dir-tip');
        const arc = document.getElementById('bmx-dir-arc');
        const label = document.getElementById('bmx-dir-label');

        const maxRadius = 50;
        const triggerRadius = 45;

        let hideTimer = null;

        function scheduleHide(ms) {
            if (hideTimer) clearTimeout(hideTimer);
            hideTimer = setTimeout(function() {
                widget.style.setProperty('opacity', '0', 'important');
                hideTimer = null;
            }, ms);
        }

        window.addEventListener('message', function(event) {
            const d = event.data;
            if (!d || d.action !== 'bmxDirection') return;

            if (d.visible === false) {
                scheduleHide(600);
                return;
            }

            if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; }
            widget.style.setProperty('opacity', '1', 'important');

            const x = d.x || 0;
            const y = d.y || 0;
            const dist = d.dist || Math.sqrt(x * x + y * y);
            const threshold = d.threshold || 0.15;

            const pct = Math.min(dist / threshold, 1.0);
            const lineLen = pct * triggerRadius;

            const angle = Math.atan2(y, x);
            const tipX = Math.cos(angle) * lineLen;
            const tipY = Math.sin(angle) * lineLen;

            line.setAttribute('x2', tipX.toFixed(2));
            line.setAttribute('y2', tipY.toFixed(2));
            tip.setAttribute('cx', tipX.toFixed(2));
            tip.setAttribute('cy', tipY.toFixed(2));

            const circ = 2 * Math.PI * maxRadius;
            const arcLen = pct * circ;
            arc.setAttribute('stroke-dasharray', arcLen.toFixed(2) + ' ' + (circ - arcLen).toFixed(2));

            if (pct >= 1.0) {
                tip.setAttribute('r', '6');
                label.textContent = d.trickName || 'RELEASE TO TRIGGER';
            } else {
                tip.setAttribute('r', '4');
                label.textContent = d.trickName || 'Direction';
            }
        });
    }

    // Inject immediately if DOM ready, otherwise wait
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
