// fz-rental NUI. client/main.lua sends { action: 'open', ... } with the counter's cars and texts and { action: 'close' };
// the page answers with the rent, recover, return and close callbacks.
(() => {
    const resource = window.GetParentResourceName ? window.GetParentResourceName() : 'fz-rental';
    const $ = (id) => document.getElementById(id);

    const state = { open: false, vehicles: [], pick: 0, hours: 1, min: 1, max: 24, currency: '$', texts: {} };

    const post = (name, data = {}) =>
        fetch(`https://${resource}/${name}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data),
        }).catch(() => {});

    // The stage is drawn for 1080p and zoomed to the real screen height.
    const fit = () => {
        const s = window.innerHeight / 1080;
        const stage = $('stage');
        stage.style.width = `${window.innerWidth / s}px`;
        stage.style.transform = `scale(${s})`;
    };

    const money = (n) => `${state.currency}${Number(n).toLocaleString('en-US')}`;
    const t = (k) => state.texts[k] ?? '';

    const showPhoto = (v) => {
        const img = $('photo');
        const car = $('car');
        // The config picture first, then the FiveM docs render of the model, then a plain outline.
        const tries = [v.image, v.model ? `https://docs.fivem.net/vehicles/${v.model}.webp` : null].filter(Boolean);
        let i = 0;
        const next = () => {
            if (i >= tries.length) {
                img.hidden = true;
                car.style.display = '';
                return;
            }
            img.src = tries[i++];
        };
        img.onload = () => {
            img.hidden = false;
            car.style.display = 'none';
        };
        img.onerror = next;
        img.hidden = true;
        car.style.display = '';
        next();
    };

    const renderList = () => {
        const ul = $('vehicles');
        ul.innerHTML = '';
        state.vehicles.forEach((v, i) => {
            const li = document.createElement('li');
            li.className = 'row' + (i === state.pick ? ' on' : '');
            li.innerHTML = `<span class="no">${String(i + 1).padStart(2, '0')}</span>
                <span class="what"><b></b><small></small></span>
                <span class="cost"></span>`;
            li.querySelector('b').textContent = v.name;
            li.querySelector('small').textContent = v.description || '';
            li.querySelector('.cost').innerHTML = `${money(v.price)}<span></span>`;
            li.querySelector('.cost span').textContent = t('perHour');
            li.onclick = () => choose(i);
            ul.appendChild(li);
        });
    };

    const renderDetail = () => {
        const v = state.vehicles[state.pick];
        $('detail').style.visibility = v ? 'visible' : 'hidden';
        if (!v) return;
        $('name').textContent = v.name;
        $('desc').textContent = v.description || '';
        $('hours').textContent = state.hours;
        const range = $('range');
        range.min = state.min;
        range.max = state.max;
        range.value = state.hours;
        const p = state.max > state.min ? ((state.hours - state.min) / (state.max - state.min)) * 100 : 100;
        range.style.setProperty('--p', `${p}%`);
        $('total').textContent = money(v.price * state.hours);
    };

    const choose = (i) => {
        if (!state.vehicles.length) return;
        state.pick = (i + state.vehicles.length) % state.vehicles.length;
        renderList();
        renderDetail();
        showPhoto(state.vehicles[state.pick]);
        $('vehicles').children[state.pick]?.scrollIntoView({ block: 'nearest' });
    };

    const setHours = (h) => {
        state.hours = Math.max(state.min, Math.min(state.max, Math.round(h)));
        renderDetail();
    };

    const open = (d) => {
        state.open = true;
        state.vehicles = d.vehicles || [];
        state.min = Number(d.min) || 1;
        state.max = Math.max(state.min, Number(d.max) || state.min);
        state.hours = state.min;
        state.currency = (d.currency || '$').trim();
        state.texts = d.texts || {};
        state.pick = 0;

        $('kicker').textContent = t('kicker');
        $('title').textContent = t('title');
        $('t-close').textContent = t('close');
        $('t-vehicles').textContent = t('vehicles');
        $('t-hours').textContent = t('hours');
        $('t-hour').textContent = t('hour');
        $('t-total').textContent = t('total');
        $('t-rent').textContent = t('rent');
        $('pay').textContent = t('pay');
        $('t-recover').textContent = t('recover');
        $('t-recover-d').textContent = t('recoverDesc');
        $('t-return').textContent = t('return');
        $('t-return-d').textContent = t('returnDesc');
        $('info').textContent = t('info');

        $('stage').classList.add('open');
        renderList();
        choose(0);
        renderDetail();
    };

    const close = (tell = true) => {
        if (!state.open) return;
        state.open = false;
        $('stage').classList.remove('open');
        if (tell) post('close');
    };

    const rent = () => {
        const v = state.vehicles[state.pick];
        if (!v) return;
        post('rent', { index: state.pick + 1, hours: state.hours });
        close(false);
    };

    $('close').onclick = () => close();
    $('rent').onclick = rent;
    $('minus').onclick = () => setHours(state.hours - 1);
    $('plus').onclick = () => setHours(state.hours + 1);
    $('range').oninput = (e) => setHours(Number(e.target.value));
    $('recover').onclick = () => {
        post('recover');
        close(false);
    };
    $('return').onclick = () => {
        post('return');
        close(false);
    };

    window.addEventListener('keydown', (e) => {
        if (!state.open) return;
        if (e.key === 'Escape' || e.key === 'Backspace') close();
        else if (e.key === 'Enter') rent();
        else if (e.key === 'ArrowUp') choose(state.pick - 1);
        else if (e.key === 'ArrowDown') choose(state.pick + 1);
        else if (e.key === 'ArrowLeft') setHours(state.hours - 1);
        else if (e.key === 'ArrowRight') setHours(state.hours + 1);
    });

    window.addEventListener('message', ({ data }) => {
        if (!data) return;
        if (data.action === 'open') open(data);
        else if (data.action === 'close') close(false);
    });

    window.addEventListener('resize', fit);
    fit();
})();
