(() => {
    const ui = document.getElementById('radio-ui');
    const panel = document.getElementById('panel');
    const list = document.getElementById('anim-list');

    // In the game the page posts to its own resource; a plain browser has nothing to post to.
    const post = (name, data = {}) => {
        if (typeof GetParentResourceName !== 'function') return;
        fetch(`https://${GetParentResourceName()}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).catch(() => {});
    };

    // Drawn for a 1080 screen; zoom follows the screen height (a transform scale blurs in FiveM).
    const fit = () => {
        panel.style.zoom = Math.min(2, Math.max(0.8, window.innerHeight / 1080));
    };

    // "Telsiz A (Sağ Ön)" is the name "Telsiz A" and the hint "Sağ Ön"; a label without brackets is the name alone.
    const split = (label) => {
        const m = /^(.*?)\s*\((.+)\)\s*$/.exec(label);
        return m ? [m[1], m[2]] : [label, ''];
    };

    const el = (tag, cls, text) => {
        const node = document.createElement(tag);
        node.className = cls;
        if (text) node.textContent = text;
        return node;
    };

    const hide = () => ui.classList.add('hidden');

    const close = () => {
        hide();
        post('closeUI');
    };

    const pick = (index) => {
        hide();
        post('selectAnim', { index });
    };

    const open = (labels, current) => {
        const rows = Array.isArray(labels) ? labels : Object.values(labels || {});
        let used = null;
        list.textContent = '';
        rows.forEach((label, i) => {
            const [name, what] = split(String(label));
            const row = el('li', 'row');
            row.append(el('span', 'n', String(i + 1).padStart(2, '0')), el('span', 'name', name), el('span', 'what', what));
            if (i + 1 === Number(current)) {
                const on = el('span', 'on lbl');
                on.append(el('i', ''), 'Seçili');
                row.append(on);
                row.dataset.on = 'true';
                used = row;
            }
            row.addEventListener('click', () => pick(i + 1));
            list.appendChild(row);
        });
        fit();
        ui.classList.remove('hidden');
        if (used) used.scrollIntoView({ block: 'nearest' });
    };

    document.getElementById('close-x').addEventListener('click', close);
    document.getElementById('close-btn').addEventListener('click', close);
    window.addEventListener('resize', fit);

    window.addEventListener('message', (event) => {
        const data = event.data || {};
        if (data.action === 'OPEN_UI') open(data.animations, data.currentAnim);
        if (data.action === 'CLOSE_UI') hide();
    });

    // Esc always gives the focus back, also when the list failed to draw.
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') close();
    });
})();
