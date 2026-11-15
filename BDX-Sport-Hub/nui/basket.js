// ═══════════════════════════════════════════════════════════
// BDX Sport Hub — Basket / Cart UI
// Uses sporthubBasket* actions & callbacks to avoid bbsteez collision.
// ═══════════════════════════════════════════════════════════
(function() {
    'use strict';

    var panel = document.createElement('div');
    panel.id = 'bdx-sporthub-basket';
    panel.innerHTML = [
        '<div class="bdx-sporthub-basket-header">',
        '  <div class="bdx-sporthub-basket-icon">\u{1F6D2}</div>',
        '  <div class="bdx-sporthub-basket-title">Basket</div>',
        '  <div class="bdx-sporthub-basket-count" id="bdx-sporthub-basket-count">0</div>',
        '  <div class="bdx-sporthub-basket-close" id="bdx-sporthub-basket-close">\u00D7</div>',
        '</div>',
        '<div class="bdx-sporthub-basket-list" id="bdx-sporthub-basket-list"></div>',
        '<div class="bdx-sporthub-basket-footer">',
        '  <div class="bdx-sporthub-basket-total">',
        '    <span class="bdx-sporthub-basket-total-label">Items</span>',
        '    <span class="bdx-sporthub-basket-total-value" id="bdx-sporthub-basket-total">0</span>',
        '  </div>',
        '  <div class="bdx-sporthub-basket-actions">',
        '    <button class="bdx-sporthub-basket-btn bdx-sporthub-basket-btn-clear" id="bdx-sporthub-basket-clear">Clear</button>',
        '    <button class="bdx-sporthub-basket-btn bdx-sporthub-basket-btn-purchase" id="bdx-sporthub-basket-purchase">Purchase</button>',
        '  </div>',
        '</div>'
    ].join('');
    document.body.appendChild(panel);

    var currentBasket = {};
    var visible = false;

    function nui(cb, data) {
        return fetch('https://' + GetParentResourceName() + '/' + cb, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data || {})
        }).then(function(r) { return r.json(); }).catch(function() { return {}; });
    }

    var CATEGORY_LABEL = {
        bmx: 'BMX',
        skateboard: 'Skateboard',
        hoverboard: 'Hoverboard',
        rollers: 'Rollers',
        scooter: 'Scooter',
        ski: 'Ski',
        iceskates: 'Ice Skates',
        snowboard: 'Snowboard',
        surfboard: 'Surfboard'
    };
    function categoryLabel(cat) {
        return CATEGORY_LABEL[cat] || (cat.charAt(0).toUpperCase() + cat.slice(1));
    }

    function hasAnyItems(basket) {
        for (var cat in basket) {
            var catData = basket[cat];
            if (!catData || !catData.items) continue;
            for (var k in catData.items) return true;
        }
        return false;
    }

    function render() {
        var list = document.getElementById('bdx-sporthub-basket-list');
        var countEl = document.getElementById('bdx-sporthub-basket-count');
        var totalEl = document.getElementById('bdx-sporthub-basket-total');
        var purchaseBtn = document.getElementById('bdx-sporthub-basket-purchase');

        list.innerHTML = '';
        var totalItems = 0;
        var anyItems = false;

        for (var cat in currentBasket) {
            var catData = currentBasket[cat];
            if (!catData || !catData.items) continue;

            var itemKeys = Object.keys(catData.items);
            if (itemKeys.length === 0) continue;

            anyItems = true;

            var group = document.createElement('div');
            group.className = 'bdx-sporthub-basket-group';

            var title = document.createElement('div');
            title.className = 'bdx-sporthub-basket-group-title';
            title.textContent = categoryLabel(cat) + (catData.style ? ' \u00B7 ' + catData.style : '');
            group.appendChild(title);

            for (var k = 0; k < itemKeys.length; k++) {
                (function(key, item) {
                    var row = document.createElement('div');
                    row.className = 'bdx-sporthub-basket-item';

                    var label = document.createElement('div');
                    label.className = 'bdx-sporthub-basket-item-label';
                    var useCustom = item && (item.noPrefix || item.partType === null);
                    var prefix = '';
                    if (!useCustom && item && item.partType) {
                        prefix = item.partType.charAt(0).toUpperCase() + item.partType.slice(1) + ': ';
                    }
                    var idLabel = (item && (item.label || ('Design ' + ((item.id != null ? item.id : 0) + 1))));
                    label.textContent = prefix + idLabel;
                    row.appendChild(label);

                    var remove = document.createElement('div');
                    remove.className = 'bdx-sporthub-basket-item-remove';
                    remove.textContent = '\u00D7';
                    remove.addEventListener('click', function() {
                        nui('sporthubBasketRemove', {
                            category: cat,
                            partType: (key === 'design') ? null : key
                        });
                    });
                    row.appendChild(remove);

                    group.appendChild(row);
                    totalItems++;
                })(itemKeys[k], catData.items[itemKeys[k]]);
            }

            list.appendChild(group);
        }

        if (!anyItems) {
            var empty = document.createElement('div');
            empty.className = 'bdx-sporthub-basket-empty';
            empty.textContent = 'Sepet boş';
            list.appendChild(empty);
        }

        countEl.textContent = totalItems;
        totalEl.textContent = totalItems;
        purchaseBtn.disabled = !anyItems;
    }

    function show() {
        panel.classList.add('visible');
        visible = true;
    }
    function hide() {
        panel.classList.remove('visible');
        visible = false;
    }

    document.getElementById('bdx-sporthub-basket-close').addEventListener('click', hide);
    document.getElementById('bdx-sporthub-basket-clear').addEventListener('click', function() {
        nui('sporthubBasketClear');
    });
    document.getElementById('bdx-sporthub-basket-purchase').addEventListener('click', function() {
        nui('sporthubBasketPurchase');
    });

    window.addEventListener('message', function(e) {
        var d = e.data;
        if (!d) return;

        if (d.action === 'sporthubBasketUpdate') {
            currentBasket = d.basket || {};
            render();
        }

        if (d.action === 'sporthubBasketShow') show();
        if (d.action === 'sporthubBasketHide') hide();

        // BMX customization uses its own panel flow — show basket when any BMX panel opens
        if (d.action === 'bmxShowLivery'
            || d.action === 'bmxUpdateMarkers'
            || d.action === 'bmxShowPartButtons'
            || d.action === 'bmxShowBucketPicker') {
            show();
        }

        if (d.action === 'bmxHideAll') hide();

        // Hide on any non-gear page (only gear/subMenu page should show the basket)
        if (d.action === 'hideMenu'
            || d.action === 'closeMenu'
            || d.action === 'showContainer'
            || d.action === 'showFirstPage'
            || d.action === 'showMainMenu'
            || d.action === 'showSkateTypeSelect') {
            hide();
        }
    });
})();
