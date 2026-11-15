// ═══════════════════════════════════════════════════════════════
// SPORT GEAR WHEEL - Riders Republic Style
// ═══════════════════════════════════════════════════════════════

let gearWheel = { isOpen: false, currentHover: null, gears: [], currentGearId: null };

// Segment colors (Riders Republic palette)
const SEGMENT_COLORS = [
    '#c85088', // 0: pink (skate)
    '#d07840', // 1: brown (bmx)
    '#4898d0', // 2: blue (scooter)
    '#5098a0', // 3: teal (hoverboard)
    '#d89030', // 4: orange (rollers)
    '#489860', // 5: green (ski)
    '#d8a830', // 6: yellow (iceskates)
    '#986838', // 7: brown-dark (snowboard)
    '#50b8a8', // 8: teal-light (surf)
];

// Stats icons
const STAT_ICONS = ['⚡', '→', '↻', '🎯', '↓'];

function nui(cb, data) {
    fetch('https://' + GetParentResourceName() + '/' + cb, {
        method: 'POST', headers: {'Content-Type':'application/json'},
        body: JSON.stringify(data || {})
    });
}

function playSound(id) {
    var s = document.getElementById(id);
    if (s) { s.currentTime = 0; s.volume = 0.4; s.play().catch(function(){}); }
}

// ═══════════════════════════════════════════════════════════════
// SVG WHEEL BUILDER
// ═══════════════════════════════════════════════════════════════

function buildWheel(gears) {
    var total = 9;
    var cx = 240, cy = 240, r = 220, ir = 100;
    var angleStep = 360 / total;
    var svg = document.getElementById('gw-svg');
    svg.innerHTML = '';

    // Create defs for drop shadow
    svg.innerHTML = '<defs><filter id="gw-shadow"><feDropShadow dx="0" dy="2" stdDeviation="3" flood-opacity="0.2"/></filter></defs>';

    // Build segments
    gears.forEach(function(gear) {
        var idx = gear.slotIndex !== undefined ? gear.slotIndex : 0;
        var startAngle = (idx * angleStep - 90) * Math.PI / 180;
        var endAngle = ((idx + 1) * angleStep - 90) * Math.PI / 180;
        var gap = 0.02; // Small gap between segments
        startAngle += gap;
        endAngle -= gap;

        var x1 = cx + r * Math.cos(startAngle);
        var y1 = cy + r * Math.sin(startAngle);
        var x2 = cx + r * Math.cos(endAngle);
        var y2 = cy + r * Math.sin(endAngle);
        var ix1 = cx + ir * Math.cos(startAngle);
        var iy1 = cy + ir * Math.sin(startAngle);
        var ix2 = cx + ir * Math.cos(endAngle);
        var iy2 = cy + ir * Math.sin(endAngle);

        var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        var d = 'M ' + ix1 + ' ' + iy1 +
                ' L ' + x1 + ' ' + y1 +
                ' A ' + r + ' ' + r + ' 0 0 1 ' + x2 + ' ' + y2 +
                ' L ' + ix2 + ' ' + iy2 +
                ' A ' + ir + ' ' + ir + ' 0 0 0 ' + ix1 + ' ' + iy1 + ' Z';
        path.setAttribute('d', d);
        path.setAttribute('fill', SEGMENT_COLORS[idx] || '#666');
        path.setAttribute('class', 'gw-segment' + (gear.disabled ? ' disabled' : ''));
        path.setAttribute('data-gear-id', gear.id);
        path.setAttribute('filter', 'url(#gw-shadow)');

        path.addEventListener('mouseenter', function() { hoverGear(gear.id, idx); });
        path.addEventListener('mouseleave', function() { unhoverGear(gear.id); });
        path.addEventListener('click', function(e) {
            e.preventDefault();
            if (!gear.disabled) {
                nui('gearSelect', { gearId: gear.id });
            }
        });

        svg.appendChild(path);

        // White divider lines
        var lx1 = cx + (ir - 2) * Math.cos(startAngle - gap);
        var ly1 = cy + (ir - 2) * Math.sin(startAngle - gap);
        var lx2 = cx + (r + 2) * Math.cos(startAngle - gap);
        var ly2 = cy + (r + 2) * Math.sin(startAngle - gap);
        var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', lx1); line.setAttribute('y1', ly1);
        line.setAttribute('x2', lx2); line.setAttribute('y2', ly2);
        line.setAttribute('stroke', 'rgba(255,255,255,0.8)');
        line.setAttribute('stroke-width', '2');
        line.style.pointerEvents = 'none';
        svg.appendChild(line);
    });

    // Position icons
    var wheel = document.getElementById('gear-wheel');
    var oldIcons = wheel.querySelectorAll('.gw-seg-icon');
    oldIcons.forEach(function(i) { i.remove(); });

    gears.forEach(function(gear) {
        var idx = gear.slotIndex !== undefined ? gear.slotIndex : 0;
        var midAngle = ((idx + 0.5) * angleStep - 90) * Math.PI / 180;
        var iconR = (r + ir) / 2;
        var ix = cx + iconR * Math.cos(midAngle);
        var iy = cy + iconR * Math.sin(midAngle);

        var img = document.createElement('img');
        img.className = 'gw-seg-icon';
        img.dataset.gearId = gear.id;
        // Local-first: every icon ships in nui/images/wheel/. CDN was
        // missing slopstyle.png and the previous order (CDN src set BEFORE
        // onerror was attached) raced and silently dropped the fallback.
        var iconFile = gear.icon || 'default.png';
        // gearImg gears (e.g. Retro DLC) stream their slot art from their own
        // resource: FiveM serves it at https://cfx-nui-<resource>/<path>.
        var iconFolder = gear.gearImg ? 'https://cfx-nui-BDX-Retro-Skate/nui/gear/' : 'images/wheel/';
        img.onerror = function() {
            if (!this.dataset.tried && !gear.gearImg) {
                this.dataset.tried = '1';
                this.src = 'https://bdx-sport-hub.pages.dev/images/wheel/' + iconFile;
            }
        };
        img.src = iconFolder + iconFile;
        img.style.left = ix + 'px';
        img.style.top = iy + 'px';
        wheel.appendChild(img);
    });
}

// ═══════════════════════════════════════════════════════════════
// STATS PANEL
// ═══════════════════════════════════════════════════════════════

function updateStats(gear) {
    var panel = document.getElementById('gw-stats');
    if (!gear || !gear.stats) { panel.classList.remove('visible'); return; }
    panel.classList.add('visible');

    document.getElementById('gw-stats-brand').textContent = gear.brand || '';
    document.getElementById('gw-stats-name').textContent = gear.label || '';
    document.getElementById('gw-stats-logo').textContent = gear.brandShort || '';

    var stats = gear.stats || {};
    var statNames = ['SPRINT', 'SPEED', 'AIR ROTATION', 'GRIP', 'ABSORPTION'];
    var statKeys = ['sprint', 'speed', 'airRotation', 'grip', 'absorption'];
    var rows = document.getElementById('gw-stats-rows');
    rows.innerHTML = '';

    for (var i = 0; i < statNames.length; i++) {
        var val = stats[statKeys[i]] || 0;
        var row = document.createElement('div');
        row.className = 'gw-stat-row';
        row.innerHTML =
            '<div class="gw-stat-icon">' + STAT_ICONS[i] + '</div>' +
            '<div class="gw-stat-info">' +
            '  <div class="gw-stat-label">' + statNames[i] + '</div>' +
            '  <div class="gw-stat-bar-bg"><div class="gw-stat-bar-fill" style="width:' + val + '%"></div></div>' +
            '</div>' +
            '<div class="gw-stat-value">' + val + '</div>';
        rows.appendChild(row);
    }

    var pk = (stats.sprint || 0) + (stats.speed || 0) + (stats.airRotation || 0) + (stats.grip || 0) + (stats.absorption || 0);
    document.getElementById('gw-stats-pk-value').textContent = pk;
}

// ═══════════════════════════════════════════════════════════════
// HOVER / SELECT
// ═══════════════════════════════════════════════════════════════

function hoverGear(id, idx) {
    playSound('gearWheelSelectSound');
    gearWheel.currentHover = id;

    document.querySelectorAll('.gw-segment').forEach(function(s) { s.classList.remove('active'); });
    document.querySelectorAll('.gw-seg-icon').forEach(function(i) { i.classList.remove('active'); });

    var seg = document.querySelector('.gw-segment[data-gear-id="' + id + '"]');
    var icon = document.querySelector('.gw-seg-icon[data-gear-id="' + id + '"]');
    if (seg) seg.classList.add('active');
    if (icon) icon.classList.add('active');

    // Position inner arrow pointing toward hovered segment
    var arrow = document.getElementById('gw-arrow');
    var angleStep = 360 / 9;
    var arrowAngle = (idx + 0.5) * angleStep - 90;
    var arrowDist = 105; // Just outside center circle
    var arrowRad = arrowAngle * Math.PI / 180;
    var ax = Math.cos(arrowRad) * arrowDist;
    var ay = Math.sin(arrowRad) * arrowDist;
    arrow.style.display = 'block';
    arrow.style.transform = 'translate(' + (ax - 10) + 'px, ' + (ay - 9) + 'px) rotate(' + (arrowAngle + 90) + 'deg)';

    // Update center via shared helper (handles the no-gear case cleanly).
    setCenterGear(id);
    var gear = gearWheel.gears.find(function(g) { return g.id === id; });
    if (gear) updateStats(gear);

    nui('gearHover', { gearId: id });
}

function unhoverGear(id) {
    var seg = document.querySelector('.gw-segment[data-gear-id="' + id + '"]');
    var icon = document.querySelector('.gw-seg-icon[data-gear-id="' + id + '"]');
    if (seg) seg.classList.remove('active');
    if (icon) icon.classList.remove('active');
    if (gearWheel.currentHover === id) {
        document.getElementById('gw-arrow').style.display = 'none';
        gearWheel.currentHover = null;
        // Revert the center back to the currently-ridden gear's image,
        // or hide it if the player isn't riding anything.
        setCenterGear(gearWheel.currentGearId);
    }
}

// ═══════════════════════════════════════════════════════════════
// SHOW / HIDE
// ═══════════════════════════════════════════════════════════════

function showGearWheel(gears, hasCurrentGear, currentGearId) {
    gearWheel.gears = gears;
    gearWheel.isOpen = true;
    gearWheel.currentGearId = currentGearId || null;

    var container = document.getElementById('gear-wheel-container');
    container.style.display = 'flex';
    container.classList.remove('hiding');

    buildWheel(gears);

    var removeBtn = document.getElementById('gear-wheel-remove-btn');
    if (removeBtn) removeBtn.style.display = hasCurrentGear ? 'flex' : 'none';

    document.getElementById('gw-stats').classList.remove('visible');
    document.getElementById('gw-center-label').textContent = '';

    // Center image: if the player is currently riding a gear, show that
    // gear's image. Otherwise hide the <img> entirely so we don't fire a
    // request for a nil path and get a broken-image placeholder.
    setCenterGear(currentGearId || null);
}

// Swap the center circle's image+label to the given gear id (or clear if
// null). Used on open (to show current gear), on hover (preview), and on
// unhover (revert to current gear, or clear).
function setVariantArrows(visible) {
    // Show/hide the ◄ ► hints flanking the centre icon. Triggered when a
    // gear with hasVariants=true (e.g. the BMX/Slopstyle shared slot) is
    // hovered, so the player sees they can cycle the variant.
    var l = document.getElementById('gw-variant-arrow-left');
    var r = document.getElementById('gw-variant-arrow-right');
    if (l) l.style.display = visible ? '' : 'none';
    if (r) r.style.display = visible ? '' : 'none';
}

function setCenterGear(id) {
    var img = document.getElementById('gw-center-img');
    var label = document.getElementById('gw-center-label');
    if (!img || !label) return;
    if (!id) {
        img.style.display = 'none';
        img.removeAttribute('src');
        label.textContent = '';
        setVariantArrows(false);
        return;
    }
    var gear = gearWheel.gears.find(function(g) { return g.id === id; });
    if (!gear) {
        img.style.display = 'none';
        img.removeAttribute('src');
        label.textContent = '';
        setVariantArrows(false);
        return;
    }
    // Show variant arrows only when this gear's slot has alternatives (the
    // Lua side populates hasVariants on every gear in the wheel payload).
    setVariantArrows(gear.hasVariants === true);
    label.textContent = gear.label || '';
    img.style.display = '';
    // Center icon uses the richer images/icons/ set (different art than the
    // wheel-slot icons). A few filenames differ between the two folders, so
    // map the wheel-icon names to their icons/ equivalents where needed.
    var WHEEL_TO_CENTER_ICON = {
        'skate.png':       'skateboard.png',
        'ski.png':         'skis.png',
    };
    var wheelIcon  = gear.icon || 'default.png';
    // gearImg gears (e.g. Retro DLC) keep their center art in nui/gear/ too. Use the
    // explicit gearCenter filename when provided, else `<base>_center.png`; on 404
    // fall back to the slot image.
    if (gear.gearImg) {
        var base = wheelIcon.replace(/\.png$/i, '');
        var gearBase = 'https://cfx-nui-BDX-Retro-Skate/nui/gear/';
        var centerFile = gear.gearCenter || (base + '_center.png');
        img.dataset.tried = '';
        img.onerror = function() {
            if (!this.dataset.tried) { this.dataset.tried = '1'; this.src = gearBase + wheelIcon; }
        };
        img.src = gearBase + centerFile;
        return;
    }
    var centerIcon = WHEEL_TO_CENTER_ICON[wheelIcon] || wheelIcon;
    img.dataset.tried = '';   // reset across calls so CDN-fallback can retry
    img.onerror = function() {
        if (!this.dataset.tried) {
            this.dataset.tried = '1';
            this.src = 'https://bdx-sport-hub.pages.dev/images/icons/' + centerIcon;
        }
    };
    img.src = 'images/icons/' + centerIcon;
}

function hideGearWheel() {
    playSound('gearWheelCameraFlashSound');
    var container = document.getElementById('gear-wheel-container');
    container.classList.add('hiding');
    setTimeout(function() { container.style.display = 'none'; container.classList.remove('hiding'); }, 200);
    gearWheel.isOpen = false;
    gearWheel.currentHover = null;
    document.getElementById('gw-stats').classList.remove('visible');
}

// ═══════════════════════════════════════════════════════════════
// MESSAGES + KEYS
// ═══════════════════════════════════════════════════════════════

window.addEventListener('message', function(e) {
    if (e.data.action === 'showWheel') showGearWheel(e.data.gears, e.data.hasCurrentGear, e.data.currentGearId);
    else if (e.data.action === 'hideWheel') hideGearWheel();
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && gearWheel.isOpen) {
        nui('closeWheel');
        hideGearWheel();
    }
    if (e.key === 'Enter' && gearWheel.isOpen && gearWheel.currentHover) {
        nui('gearSelect', { gearId: gearWheel.currentHover });
    }
});

// Remove button
document.addEventListener('DOMContentLoaded', function() {
    var btn = document.getElementById('gear-wheel-remove-btn');
    if (btn) {
        btn.addEventListener('mouseenter', function() {
            playSound('gearWheelSelectSound');
            btn.classList.add('hover');
            gearWheel.currentHover = '__remove__';
            nui('gearHover', { gearId: '__remove__' });
        });
        btn.addEventListener('mouseleave', function() {
            btn.classList.remove('hover');
            if (gearWheel.currentHover === '__remove__') gearWheel.currentHover = null;
        });
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            nui('gearSelect', { gearId: '__remove__' });
        });
    }
});

function GetParentResourceName() {
    var p = new URLSearchParams(window.location.search);
    return p.get('resource') || 'BDX-Sport-Hub';
}
