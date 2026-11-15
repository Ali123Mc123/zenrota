(() => {
    'use strict';
    let translations = {};
    window.ActivityLocale = new Proxy({}, {
        get: (_, key) => () => translations[key] || ''
    });

    function fillText(element, key, placement) {
        const translated = translations[key];
        if (translated === undefined) return;
        const nodes = [...element.childNodes];
        const text = placement === 'suffix'
            ? nodes.reverse().find(node => node.nodeType === Node.TEXT_NODE)
            : nodes.find(node => node.nodeType === Node.TEXT_NODE);
        if (text) {
            if (!text.nodeValue.trim()) text.nodeValue = placement === 'suffix' ? ` ${translated}` : translated;
        } else {
            const node = document.createTextNode(placement === 'suffix' ? ` ${translated}` : translated);
            if (placement === 'suffix') element.append(node);
            else element.prepend(node);
        }
    }

    function localize(element) {
        if (element.nodeType !== Node.ELEMENT_NODE) return;
        if (element.dataset.i18n) fillText(element, element.dataset.i18n, 'prefix');
        if (element.dataset.i18nSuffix) fillText(element, element.dataset.i18nSuffix, 'suffix');
        for (const attribute of ['aria-label', 'title', 'placeholder']) {
            const key = element.getAttribute(`data-i18n-${attribute}`);
            if (key && translations[key] !== undefined) element.setAttribute(attribute, translations[key]);
        }
        for (const child of element.children) localize(child);
    }

    const observer = new MutationObserver(records => {
        for (const record of records) {
            for (const node of record.addedNodes) localize(node);
        }
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });

    const loadLocale = (attempt = 0) => fetch(`https://${GetParentResourceName()}/locale`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}'
    }).then(response => response.json()).then(locale => {
        if (!locale || !locale.language || !locale.translations) throw new Error('Locale unavailable');
        translations = locale.translations;
        document.documentElement.lang = locale.language;
        localize(document.documentElement);
    }).catch(() => {
        if (attempt < 10) window.setTimeout(() => loadLocale(attempt + 1), 250);
    });
    loadLocale();
})();
