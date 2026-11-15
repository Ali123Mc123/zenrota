// ═══════════════════════════════════════════════════════════════
// BMX FREESTYLE - 6-BUCKET COLOR SYSTEM
// Renders inside Sport-Hub's #options + #submenu-title
// ═══════════════════════════════════════════════════════════════

(function() {
    'use strict';

    var buckets = [];
    var currentPartCallback = 'bmxPartSelected';
    var currentBMXPartLabel = '';
    var currentBMXBucketLabel = '';

    // ─── Markers ───
    var markerElements = {};
    var markersContainer = document.createElement('div');
    markersContainer.id = 'bmx-markers';
    document.body.appendChild(markersContainer);

    function getOrCreateMarker(key, label) {
        if (markerElements[key]) return markerElements[key];
        var el = document.createElement('div');
        el.className = 'bmx-marker';
        el.innerHTML = '<div class="bmx-ring"></div><div class="bmx-ring2"></div><div class="bmx-dot"></div><div class="bmx-label">' + label + '</div>';
        el.addEventListener('mousedown', function(e) {
            e.preventDefault(); e.stopPropagation();
            nui('bmxMarkerClicked', { key: key });
        });
        markersContainer.appendChild(el);
        markerElements[key] = el;
        return el;
    }

    // ─── Helpers ───
    function opt() { return document.getElementById('options'); }
    function title() { return document.getElementById('submenu-title'); }
    function nui(cb, data) {
        fetch('https://' + GetParentResourceName() + '/' + cb, {
            method: 'POST', headers: {'Content-Type':'application/json'},
            body: JSON.stringify(data || {})
        });
    }
    function pad(n) { var s = n.toString(16); return s.length < 2 ? '0' + s : s; }

    function setTitle(t) { var el = title(); if (el) el.textContent = t; }

    // Track the active customize category (passed in from Lua on each
    // bmxShowPartButtons / bmxShowBucketPicker etc.). Used by clearPanel
    // so it doesn't reset the title to a hardcoded "BMX CUSTOMIZATION"
    // when the player is actually customizing a slopstyle.
    var currentCustomizeCategory = 'bmx';
    function rootTitleForCategory(cat) {
        if (cat === 'slopstyle') return 'SLOPSTYLE CUSTOMIZATION';
        return 'BMX CUSTOMIZATION';
    }

    function setupBack(showApply) {
        var btn = document.getElementById('purchaseBtn');
        if (!btn) return;
        if (showApply) {
            btn.textContent = '\u2714 APPLY';
            btn.style.display = '';
            btn.disabled = false;
            btn.style.opacity = '1';
            btn.onclick = function(e) {
                e.preventDefault();
                nui('bmxApplyChanges');
                btn.textContent = '\u2714 SAVED!';
                setTimeout(function() { btn.textContent = '\u2714 APPLY'; }, 1500);
            };
        } else {
            btn.style.display = 'none';
        }
    }

    // ─── Bucket Bar ───
    function makeBucketBar(activeBucket) {
        var bar = document.createElement('div');
        bar.className = 'bmx-bucket-bar';
        for (var i = 0; i < buckets.length; i++) {
            (function(b) {
                var c = document.createElement('div');
                c.className = 'bmx-bucket-circle' + (b.index === activeBucket ? ' active' : '');
                c.style.background = b.hex;
                c.title = b.label + ' — click to edit';

                var n = document.createElement('span');
                n.className = 'bmx-bucket-num';
                n.textContent = b.index;
                c.appendChild(n);

                if (b.index === activeBucket) {
                    var d = document.createElement('div');
                    d.className = 'bmx-bucket-active-dot';
                    c.appendChild(d);
                }

                c.addEventListener('click', function(e) {
                    e.stopPropagation();
                    showColorPicker(b.index);
                });
                bar.appendChild(c);
            })(buckets[i]);
        }
        return bar;
    }

    // ═══════════════════════════════════════
    // PART LIST (subgroups or individual parts)
    // ═══════════════════════════════════════
    function showPartButtons(label, parts) {
        var o = opt(); if (!o) return;
        o.innerHTML = '';
        o.className = 'bmx-mode';
        setTitle(label);

        o.appendChild(makeBucketBar(0));

        var scroll = document.createElement('div');
        scroll.className = 'bmx-scroll';

        parts.forEach(function(p) {
            var row = document.createElement('div');
            row.className = 'bmx-row';

            var icon = document.createElement('div');
            icon.className = 'bmx-row-icon';
            icon.textContent = p.isLivery ? '\u2728' : '\u25C6';

            var txt = document.createElement('div');
            txt.className = 'bmx-row-text';
            txt.textContent = p.label;

            row.appendChild(icon);
            row.appendChild(txt);

            // Show color dot if part has a bucket
            if (p.bucket && p.bucket > 0 && buckets[p.bucket - 1]) {
                var dot = document.createElement('div');
                dot.className = 'bmx-row-dot';
                dot.style.background = buckets[p.bucket - 1].hex;
                row.appendChild(dot);
            }

            var arrow = document.createElement('span');
            arrow.className = 'bmx-row-arrow';
            arrow.textContent = '\u203A';
            row.appendChild(arrow);

            row.addEventListener('click', function() {
                nui(currentPartCallback, { key: p.key });
            });

            scroll.appendChild(row);
        });

        o.appendChild(scroll);
        setupBack();
    }

    // ═══════════════════════════════════════
    // BUCKET PICKER (assign part to a color slot)
    // ═══════════════════════════════════════
    function showBucketPicker(label, currentBucket) {
        var o = opt(); if (!o) return;
        o.innerHTML = '';
        o.className = 'bmx-mode';
        setTitle(label);
        currentBMXPartLabel = label || '';

        o.appendChild(makeBucketBar(currentBucket));

        var hdr = document.createElement('div');
        hdr.className = 'bmx-section-header';
        hdr.textContent = 'Assign to color slot';
        o.appendChild(hdr);

        var list = document.createElement('div');
        list.className = 'bmx-bucket-list';

        buckets.forEach(function(b) {
            var card = document.createElement('div');
            card.className = 'bmx-bcard' + (b.index === currentBucket ? ' sel' : '');

            var swatch = document.createElement('div');
            swatch.className = 'bmx-bcard-color';
            swatch.style.background = b.hex;

            var info = document.createElement('div');
            info.className = 'bmx-bcard-info';

            var name = document.createElement('div');
            name.className = 'bmx-bcard-name';
            name.textContent = b.label;

            var hex = document.createElement('div');
            hex.className = 'bmx-bcard-hex';
            hex.textContent = b.hex.toUpperCase();

            info.appendChild(name);
            info.appendChild(hex);
            card.appendChild(swatch);
            card.appendChild(info);

            if (b.index === currentBucket) {
                var chk = document.createElement('span');
                chk.className = 'bmx-bcard-check';
                chk.textContent = '\u2713';
                card.appendChild(chk);
            }

            card.addEventListener('click', function() {
                nui('bmxAssignBucket', {
                    bucket: b.index,
                    bucketLabel: b.label,
                    partLabel: currentBMXPartLabel
                });
                list.querySelectorAll('.bmx-bcard').forEach(function(c) { c.classList.remove('sel'); });
                card.classList.add('sel');
                // Rebuild check marks
                list.querySelectorAll('.bmx-bcard-check').forEach(function(c) { c.remove(); });
                var nc = document.createElement('span');
                nc.className = 'bmx-bcard-check';
                nc.textContent = '\u2713';
                card.appendChild(nc);
            });

            list.appendChild(card);
        });

        o.appendChild(list);
        setupBack(true);
    }

    // ═══════════════════════════════════════
    // COLOR PICKER (Canvas palette + RGB sliders)
    // ═══════════════════════════════════════
    // HSV to RGB (Photoshop-style: S=saturation, V=brightness)
    function hsvToRgb(h, s, v) {
        h /= 360; s /= 100; v /= 100;
        var r, g, b2;
        var i = Math.floor(h * 6);
        var f = h * 6 - i;
        var p = v * (1 - s);
        var q = v * (1 - f * s);
        var t = v * (1 - (1 - f) * s);
        switch (i % 6) {
            case 0: r = v; g = t; b2 = p; break;
            case 1: r = q; g = v; b2 = p; break;
            case 2: r = p; g = v; b2 = t; break;
            case 3: r = p; g = q; b2 = v; break;
            case 4: r = t; g = p; b2 = v; break;
            case 5: r = v; g = p; b2 = q; break;
        }
        return [Math.round(r * 255), Math.round(g * 255), Math.round(b2 * 255)];
    }

    // Dedicated color picker for parts that own an exclusive RGB channel
    // outside the 6-bucket system (e.g. frame_back → mat 5). Reuses
    // showColorPicker by injecting a fake bucket and a post-override.
    function showDedicatedColorPicker(label, target) {
        // Synthesize a bucket-like object so showColorPicker can read its
        // starting color. mat5 doesn't track its last value in `buckets`, so
        // start from a neutral mid-gray — the user repaints on every visit.
        var fake = {
            index: 99,                       // sentinel — out of the 1-6 range
            r: 128, g: 128, b: 128,
            hex: '#808080',
            label: label,
            supportsRGB: true,
            __dedicatedTarget: target,       // picked up below by pushColorLive
        };
        // Push onto the buckets array temporarily, then call showColorPicker.
        buckets.push(fake);
        var idx = buckets.length;             // 1-based index of our fake
        showColorPicker(idx);
        // Pop the fake after the picker is built so it doesn't leak into the
        // bucket bar on future renders.
        buckets.pop();
    }

    function showColorPicker(bucketIndex) {
        var b = buckets[bucketIndex - 1];
        if (!b) return;

        var o = opt(); if (!o) return;
        o.innerHTML = '';
        o.className = 'bmx-mode';
        setTitle('EDIT ' + b.label.toUpperCase());
        currentBMXBucketLabel = b.label || ('Bucket ' + bucketIndex);

        o.appendChild(makeBucketBar(bucketIndex));

        var picker = document.createElement('div');
        picker.className = 'bmx-picker';

        // Color palette canvas (saturation-brightness grid)
        var canvasWrap = document.createElement('div');
        canvasWrap.className = 'bmx-canvas-wrap';

        var canvas = document.createElement('canvas');
        canvas.width = 320; canvas.height = 160;
        canvas.className = 'bmx-palette-canvas';

        var cursor = document.createElement('div');
        cursor.className = 'bmx-palette-cursor';
        canvasWrap.appendChild(canvas);
        canvasWrap.appendChild(cursor);

        // Hue slider bar
        var hueBar = document.createElement('canvas');
        hueBar.width = 320; hueBar.height = 20;
        hueBar.className = 'bmx-hue-bar';

        // Preview + hex
        var preview = document.createElement('div');
        preview.className = 'bmx-preview-box';
        preview.style.background = b.hex;

        var hexLabel = document.createElement('div');
        hexLabel.className = 'bmx-hex-text';
        hexLabel.textContent = b.hex.toUpperCase();

        var rV = b.r, gV = b.g, bV = b.b;
        var currentHue = 0;

        function updateAll() {
            var h = '#' + pad(rV) + pad(gV) + pad(bV);
            preview.style.background = h;
            hexLabel.textContent = h.toUpperCase();
            // Update sliders if they exist
            var sliders = picker.querySelectorAll('.bmx-srange');
            var vals = picker.querySelectorAll('.bmx-sval');
            if (sliders[0]) sliders[0].value = rV;
            if (sliders[1]) sliders[1].value = gV;
            if (sliders[2]) sliders[2].value = bV;
            if (vals[0]) vals[0].textContent = rV;
            if (vals[1]) vals[1].textContent = gV;
            if (vals[2]) vals[2].textContent = bV;
        }

        // Draw saturation/brightness palette for given hue (Photoshop-style HSV)
        // X axis = Saturation (0 left to 100 right)
        // Y axis = Value/Brightness (100 top to 0 bottom)
        function drawPalette(hue) {
            currentHue = hue;
            var ctx = canvas.getContext('2d');
            var w = canvas.width, h = canvas.height;
            var imgData = ctx.createImageData(w, h);
            var d = imgData.data;
            for (var y = 0; y < h; y++) {
                var v = 100 - (y / (h - 1)) * 100; // top=bright, bottom=dark
                for (var x = 0; x < w; x++) {
                    var s = (x / (w - 1)) * 100;   // left=gray, right=vivid
                    var rgb = hsvToRgb(hue, s, v);
                    var idx = (y * w + x) * 4;
                    d[idx] = rgb[0]; d[idx+1] = rgb[1]; d[idx+2] = rgb[2]; d[idx+3] = 255;
                }
            }
            ctx.putImageData(imgData, 0, 0);
        }

        // Draw hue bar
        function drawHueBar() {
            var ctx = hueBar.getContext('2d');
            var w = hueBar.width, h = hueBar.height;
            for (var x = 0; x < w; x++) {
                var hue = (x / w) * 360;
                ctx.fillStyle = 'hsl(' + hue + ',100%,50%)';
                ctx.fillRect(x, 0, 1, h);
            }
        }

        // Live-apply the current rV/gV/bV to the vehicle. Throttled to ~50ms
        // so dragging sliders/canvas doesn't spam the NUI bridge. Without
        // this, the Lua state never sees the picked color until APPLY is
        // pressed — so if the user picks via canvas/sliders and then hits
        // the basket PURCHASE button (instead of the picker's APPLY), the
        // save commits with the previous color and the new one is lost.
        var lastPushTs = 0;
        var pendingPush = null;
        function pushColorLive() {
            var now = Date.now();
            if (now - lastPushTs >= 50) {
                lastPushTs = now;
                var hexStr = '#' + pad(rV) + pad(gV) + pad(bV);
                nui('bmxBucketColorChanged', {
                    bucket: bucketIndex,
                    r: rV, g: gV, b: bV,
                    hex: hexStr.toUpperCase(),
                    bucketLabel: currentBMXBucketLabel
                });
            } else if (!pendingPush) {
                pendingPush = setTimeout(function() {
                    pendingPush = null;
                    pushColorLive();
                }, 50 - (now - lastPushTs));
            }
        }

        // Pick from palette
        var pickingPalette = false;
        canvas.addEventListener('mousedown', function(e) { pickingPalette = true; pickFromPalette(e); });
        document.addEventListener('mousemove', function(e) { if (pickingPalette) pickFromPalette(e); });
        document.addEventListener('mouseup', function() {
            if (pickingPalette) { pickingPalette = false; pushColorLive(); }
        });

        function pickFromPalette(e) {
            var rect = canvas.getBoundingClientRect();
            var xPct = Math.max(0, Math.min((e.clientX - rect.left) / rect.width, 1));
            var yPct = Math.max(0, Math.min((e.clientY - rect.top) / rect.height, 1));
            // Read actual pixel from canvas (no math mismatch)
            var px = Math.min(Math.floor(xPct * canvas.width), canvas.width - 1);
            var py = Math.min(Math.floor(yPct * canvas.height), canvas.height - 1);
            var ctx = canvas.getContext('2d');
            var pixel = ctx.getImageData(px, py, 1, 1).data;
            rV = pixel[0]; gV = pixel[1]; bV = pixel[2];
            updateAll();
            cursor.style.left = (xPct * 100) + '%';
            cursor.style.top = (yPct * 100) + '%';
            pushColorLive();
        }

        // Pick hue from bar
        var pickingHue = false;
        hueBar.addEventListener('mousedown', function(e) { pickingHue = true; pickHue(e); });
        hueBar.addEventListener('mousemove', function(e) { if (pickingHue) pickHue(e); });
        document.addEventListener('mouseup', function() {
            if (pickingHue) { pickingHue = false; pushColorLive(); }
        });

        function pickHue(e) {
            var rect = hueBar.getBoundingClientRect();
            var xPct = Math.max(0, Math.min((e.clientX - rect.left) / rect.width, 1));
            var hue = xPct * 360;
            drawPalette(hue);
            // Re-pick color at current cursor position from the new palette
            var curLeft = parseFloat(cursor.style.left) || 0;
            var curTop = parseFloat(cursor.style.top) || 0;
            var px = Math.min(Math.floor((curLeft / 100) * canvas.width), canvas.width - 1);
            var py = Math.min(Math.floor((curTop / 100) * canvas.height), canvas.height - 1);
            var ctx = canvas.getContext('2d');
            var pixel = ctx.getImageData(px, py, 1, 1).data;
            rV = pixel[0]; gV = pixel[1]; bV = pixel[2];
            updateAll();
            pushColorLive();
        }

        drawPalette(0);
        drawHueBar();

        picker.appendChild(canvasWrap);
        picker.appendChild(hueBar);
        picker.appendChild(preview);
        picker.appendChild(hexLabel);

        if (!b.supportsRGB) {
            var note = document.createElement('div');
            note.className = 'bmx-picker-note';
            note.textContent = 'Slots 3-6 approximate to nearest GTA color';
            picker.appendChild(note);
        }

        // RGB sliders
        function slider(label, val, color, onChange) {
            var row = document.createElement('div');
            row.className = 'bmx-srow';
            var lbl = document.createElement('span');
            lbl.className = 'bmx-slabel'; lbl.textContent = label; lbl.style.color = color;
            var range = document.createElement('input');
            range.type = 'range'; range.min = '0'; range.max = '255'; range.value = val;
            range.className = 'bmx-srange';
            var vSpan = document.createElement('span');
            vSpan.className = 'bmx-sval'; vSpan.textContent = val;
            range.addEventListener('input', function() {
                vSpan.textContent = this.value;
                onChange(parseInt(this.value));
                var h2 = '#' + pad(rV) + pad(gV) + pad(bV);
                preview.style.background = h2;
                hexLabel.textContent = h2.toUpperCase();
                pushColorLive();
            });
            row.appendChild(lbl); row.appendChild(range); row.appendChild(vSpan);
            return row;
        }

        picker.appendChild(slider('R', rV, '#ff5566', function(v) { rV = v; }));
        picker.appendChild(slider('G', gV, '#55ff88', function(v) { gV = v; }));
        picker.appendChild(slider('B', bV, '#5588ff', function(v) { bV = v; }));

        o.appendChild(picker);
        setupBack(true);

        // The top purchaseBtn ("APPLY") owns this panel — first push the
        // picked RGB to the bike (otherwise the canvas/slider pick stays a
        // preview-only swatch), then commit. Without this users would click
        // APPLY without ever firing bmxBucketColorChanged and the save would
        // persist the previous color, not the one they picked.
        var topBtn = document.getElementById('purchaseBtn');
        if (topBtn) {
            topBtn.onclick = function(e) {
                e.preventDefault();
                var hexStr = '#' + pad(rV) + pad(gV) + pad(bV);
                nui('bmxBucketColorChanged', {
                    bucket: bucketIndex,
                    r: rV, g: gV, b: bV,
                    hex: hexStr.toUpperCase(),
                    bucketLabel: currentBMXBucketLabel
                });
                nui('bmxApplyChanges');
                topBtn.textContent = '✔ SAVED!';
                setTimeout(function() { topBtn.textContent = '✔ APPLY'; }, 1500);
            };
        }
    }

    // ═══════════════════════════════════════
    // LIVERY GRID (uses native Sport-Hub grid)
    // ═══════════════════════════════════════
    // Maps an uppercase NUI label to the customs/ folder + filename prefix
    // for its preview PNGs. Anything not in the table falls back to a
    // colored gradient placeholder. Add new entries here when a new
    // picker gets dedicated artwork.
    var LIVERY_IMAGE_MAP = {
        'FRAME DESIGN': { folder: 'customs/bmx/liverys/',      prefix: 'frame-' },
        'KEY CHAIN':    { folder: 'customs/bmx/keys/',         prefix: 'key-'   },
        'DECK DESIGN':  { folder: 'customs/skateboard/modern/', prefix: 'board_' },
    };

    function showLiveryGrid(label, count, current, retroImg) {
        var o = opt(); if (!o) return;
        o.innerHTML = '';
        // Retro (DLC) modkit art lives in the Retro resource; served via nui://.
        // deck → c_deck_N.png, each wheel slot → W N.png (same wheel art for all 4).
        var isRetroDeck = (retroImg === 'deck');
        var isRetro = (retroImg === 'deck' || retroImg === 'wheel');
        // Deck designs are tall/portrait skateboards — give their grid a modifier
        // class so the tiles go portrait and the board art shows big (not shrunk).
        o.className = 'bmx-livery-mode' + ((label === 'DECK DESIGN' || isRetroDeck) ? ' bmx-livery-deck' : '');
        setTitle(label);
        var total = count || 8;
        var imgCfg = LIVERY_IMAGE_MAP[label];
        // Retro art streamed from the BDX-Retro-Skate resource. FiveM NUI serves
        // another resource's files at https://cfx-nui-<resource>/<path> (the nui://
        // scheme doesn't resolve). deck=c_deck_N.png, wheel=W N.png.
        if (retroImg === 'deck')  imgCfg = { folder: 'https://cfx-nui-BDX-Retro-Skate/nui/customs/', prefix: 'c_deck_' };
        if (retroImg === 'wheel') imgCfg = { folder: 'https://cfx-nui-BDX-Retro-Skate/nui/customs/', prefix: 'W' };
        // Tile sizing tweak: key chains are small/portrait images, frame
        // designs are wider landscape. Letting CSS background-size: contain
        // on keys avoids the cropped/zoomed look you get with cover.
        var bgFit = (label === 'KEY CHAIN' || label === 'DECK DESIGN' || isRetroDeck) ? 'contain' : 'cover';

        for (var i = 0; i < total; i++) {
            (function(idx) {
                var card = document.createElement('div');
                card.className = 'bmx-liv' + ((idx + 1) === current ? ' sel' : '');

                if (imgCfg) {
                    // Use a real preview PNG. The image is set as a CSS
                    // background so existing .bmx-liv sizing/aspect rules
                    // keep working without restructuring the card markup.
                    // onerror fallback handles missing files (e.g. when a
                    // server adds variants but ships no preview yet).
                    var url = imgCfg.folder + imgCfg.prefix + (idx + 1) + '.png';
                    var probe = new Image();
                    probe.onload = function() {
                        card.style.backgroundImage = "url('" + url + "')";
                        card.style.backgroundSize = bgFit;
                        card.style.backgroundPosition = 'center';
                        card.style.backgroundRepeat = 'no-repeat';
                    };
                    probe.onerror = function() {
                        var hue = (idx * 55) + 180;
                        card.style.background = 'linear-gradient(135deg,hsl(' + hue + ',50%,35%),hsl(' + (hue+30) + ',60%,20%))';
                    };
                    probe.src = url;
                } else {
                    var hue = (idx * 55) + 180;
                    card.style.background = 'linear-gradient(135deg,hsl(' + hue + ',50%,35%),hsl(' + (hue+30) + ',60%,20%))';
                }

                var lbl = document.createElement('span');
                var itemLabel = (label && label !== 'FRAME DESIGN' && label !== 'DECK DESIGN') ? label : 'Design';
                lbl.textContent = itemLabel + ' ' + (idx + 1);
                card.appendChild(lbl);

                card.addEventListener('mousedown', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log('[BMX] Livery clicked: ' + (idx + 1));
                    o.querySelectorAll('.bmx-liv').forEach(function(c) { c.classList.remove('sel'); });
                    card.classList.add('sel');
                    nui('bmxSelectLivery', { index: idx + 1 });
                });

                o.appendChild(card);
            })(i);
        }

        setupBack();
    }

    // ═══════════════════════════════════════
    // CLEAR / HIDE
    // ═══════════════════════════════════════
    function clearPanel() {
        var o = opt();
        if (o) {
            o.innerHTML = '';
            o.className = '';
        }
        setTitle(rootTitleForCategory(currentCustomizeCategory));
    }

    function hideAll() {
        markersContainer.style.display = 'none';
        for (var k in markerElements) {
            if (markerElements[k].parentNode) markerElements[k].parentNode.removeChild(markerElements[k]);
            delete markerElements[k];
        }
        clearPanel();
        // Restore back arrows to default
        var backArrows = document.querySelectorAll('#subMenu .back-arrow');
        backArrows.forEach(function(btn) { btn.onclick = function() { goBack(); }; });
        // When the BMX session fully ends (back from main-level or stop-
        // customize), also close the subMenu so the user lands on the gear
        // selection page instead of staring at an empty #options with the
        // camera already restored. goBack() handles subMenu → mainMenu.
        if (typeof goBack === 'function') {
            try { goBack(); } catch (e) { /* swallow if called during teardown */ }
        }
    }

    // Wire the subMenu circle back-arrow to the CUSTOMIZER back (bmxGoBack ->
    // bmx:onBack, which walks color-picker -> subgroup list -> group list ->
    // exit) instead of the store's goBack() (which jumps straight to the
    // style-selection page). Must be re-applied on every customizer render
    // because the store re-points the arrow to goBack() on navigation.
    function wireCustomizerBack() {
        var backArrows = document.querySelectorAll('#subMenu .back-arrow');
        backArrows.forEach(function(btn) { btn.onclick = function(e) { e.preventDefault(); nui('bmxGoBack'); }; });
    }

    // ═══════════════════════════════════════
    // MESSAGE LISTENER
    // ═══════════════════════════════════════
    window.addEventListener('message', function(event) {
        var d = event.data;

        if (d.action === 'bmxUpdateMarkers') {
            // Override circle back arrow to use bmxGoBack
            wireCustomizerBack();
            markersContainer.style.display = 'block';
            var active = {};
            if (d.markers) {
                d.markers.forEach(function(m) {
                    active[m.key] = true;
                    var el = getOrCreateMarker(m.key, m.label);
                    el.style.left = (m.x * 100) + '%';
                    el.style.top = (m.y * 100) + '%';
                    el.style.display = 'block';
                });
            }
            for (var k in markerElements) {
                if (!active[k]) markerElements[k].style.display = 'none';
            }
        }

        if (d.action === 'bmxUpdateBuckets') {
            buckets = d.buckets || [];
        }

        if (d.action === 'bmxShowPartButtons') {
            currentPartCallback = d.callback || 'bmxPartSelected';
            if (d.category) currentCustomizeCategory = d.category;
            showPartButtons(d.label, d.parts);
            wireCustomizerBack();
        }

        if (d.action === 'bmxShowBucketPicker') {
            showBucketPicker(d.label, d.currentBucket || 1);
            wireCustomizerBack();
        }

        // Skateboard: a colour-target leaf (Wheel 1-4, Front/Back Trucks) opens
        // the colour picker directly on its GTA colour channel (slot 1-6). The
        // picker posts back via bmxBucketColorChanged { bucket = slot }.
        if (d.action === 'bmxShowColorPicker') {
            showColorPicker(d.slot || 1);
            wireCustomizerBack();
        }


        if (d.action === 'bmxShowLivery') {
            showLiveryGrid(d.label || 'FRAME DESIGN', d.count || 8, d.current || 1, d.retroImg);
            wireCustomizerBack();
        }

        if (d.action === 'bmxBucketAssigned') {
            // Could refresh UI here if needed
        }

        if (d.action === 'bmxClearPanel') {
            clearPanel();
        }

        if (d.action === 'bmxHideAll') {
            hideAll();
        }
    });

})();
