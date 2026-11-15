// ═══════════════════════════════════════════════════════════
// BMX Trick Input Visualizer - Modern
// ═══════════════════════════════════════════════════════════
(function() {
    'use strict';

    var hud = document.createElement('div');
    hud.id = 'bdx-input-hud';
    hud.innerHTML = [
        '<div id="bdx-input-ring">',
        '  <div id="bdx-input-threshold"></div>',
        '  <div id="bdx-input-center"></div>',
        '  <div id="bdx-input-line"></div>',
        '  <div id="bdx-input-cursor"></div>',
        '  <div class="bdx-input-arrow up">\u25B2</div>',
        '  <div class="bdx-input-arrow down">\u25BC</div>',
        '  <div class="bdx-input-arrow left">\u25C0</div>',
        '  <div class="bdx-input-arrow right">\u25B6</div>',
        '</div>',
        '<div id="bdx-input-buttons">',
        '  <div class="bdx-btn-dot" id="bdx-btn-left"></div>',
        '  <div class="bdx-btn-dot" id="bdx-btn-right"></div>',
        '</div>',
        '<div id="bdx-input-mode"></div>'
    ].join('');
    document.body.appendChild(hud);

    var hideTimer = null;

    function show() {
        hud.classList.add('visible');
        clearTimeout(hideTimer);
    }

    function hide() {
        hud.classList.remove('visible');
    }

    function updateCursor(mx, my, dist, valid) {
        var ring = document.getElementById('bdx-input-ring');
        var cursor = document.getElementById('bdx-input-cursor');
        var line = document.getElementById('bdx-input-line');
        var radius = 50; // percentage from center

        // Clamp to ring
        var len = Math.sqrt(mx * mx + my * my);
        var clampLen = Math.min(len, 0.9);
        var nx = len > 0 ? mx / len : 0;
        var ny = len > 0 ? my / len : 0;

        var px = 50 + nx * clampLen * radius;
        var py = 50 + ny * clampLen * radius;

        cursor.style.left = px + '%';
        cursor.style.top = py + '%';

        // Valid state
        if (valid) {
            cursor.classList.remove('invalid');
            ring.classList.add('valid');
            line.classList.remove('invalid');
        } else {
            cursor.classList.add('invalid');
            ring.classList.remove('valid');
            line.classList.add('invalid');
        }

        // Line from center to cursor
        var dx = px - 50;
        var dy = py - 50;
        var lineLen = Math.sqrt(dx * dx + dy * dy);
        var angle = Math.atan2(dy, dx) * (180 / Math.PI);
        line.style.width = lineLen + '%';
        line.style.transform = 'rotate(' + angle + 'deg)';
    }

    function setButtons(combo) {
        var l = document.getElementById('bdx-btn-left');
        var r = document.getElementById('bdx-btn-right');
        l.classList.remove('active');
        r.classList.remove('active');
        if (combo === 'left' || combo === 'both') l.classList.add('active');
        if (combo === 'right' || combo === 'both') r.classList.add('active');
    }

    function setMode(mode) {
        var el = document.getElementById('bdx-input-mode');
        el.textContent = mode || '';
    }

    function flashDirection(dir) {
        var arrows = hud.querySelectorAll('.bdx-input-arrow');
        arrows.forEach(function(a) { a.classList.remove('active', 'flash'); });

        if (dir) {
            var target = hud.querySelector('.bdx-input-arrow.' + dir);
            if (target) {
                target.classList.add('active', 'flash');
            }
        }
    }

    function resetCursor() {
        var cursor = document.getElementById('bdx-input-cursor');
        var line = document.getElementById('bdx-input-line');
        var ring = document.getElementById('bdx-input-ring');
        cursor.style.left = '50%';
        cursor.style.top = '50%';
        cursor.classList.add('invalid');
        ring.classList.remove('valid');
        line.style.width = '0%';
        line.classList.remove('invalid');
        hud.querySelectorAll('.bdx-input-arrow').forEach(function(a) {
            a.classList.remove('active', 'flash');
        });
    }

    // Listen for messages
    window.addEventListener('message', function(e) {
        var d = e.data;

        if (d.type === 'bdx_showTrickInput') {
            show();
            resetCursor();
            setButtons(d.buttonCombo);
            setMode(d.mode);
        }

        if (d.type === 'bdx_updateTrickInput') {
            if (d.isActive) {
                show();
                updateCursor(d.mouseX || 0, d.mouseY || 0, d.distance || 0, d.validDistance || false);
                setButtons(d.buttonCombo);
                setMode(d.mode);
            } else {
                // Released: flash direction then hide
                if (d.direction) {
                    flashDirection(d.direction);
                    clearTimeout(hideTimer);
                    hideTimer = setTimeout(function() {
                        hide();
                        resetCursor();
                    }, 400);
                } else {
                    hide();
                    resetCursor();
                }
            }
        }
    });
})();
