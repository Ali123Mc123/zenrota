(function () {
    const KINDS = [
        { value: 'main', label: 'Main Robbery', icon: 'fa-wand-magic-sparkles' },
        { value: 'house', label: 'House Robbery', icon: 'fa-house-crack' },
        { value: 'petty', label: 'Petty Crimes', icon: 'fa-box-open' },
        { value: 'banktruck', label: 'Bank Truck', icon: 'fa-truck' },
        { value: 'atm', label: 'ATM Robbery', icon: 'fa-piggy-bank' },
        { value: 'sell', label: 'Item Sell/Trader', icon: 'fa-hand-holding-dollar' },
    ];
    const KIND_PAGES = {
        house: { label: 'House Robbery', nav: 'rcNavHouse', presetEndpoint: 'SaveHousePreset' },
        petty: { label: 'Petty Crimes', nav: 'rcNavPetty', presetEndpoint: 'SavePettyCrimePreset' },
        banktruck: { label: 'Bank Truck', nav: 'rcNavBank', presetEndpoint: 'SaveBankTruckPreset' },
        atm: { label: 'ATM', nav: 'rcNavAtm', presetEndpoint: 'SaveAtmPreset' },
        sell: { label: 'Item Sell/Trader', nav: 'rcNavSell', presetEndpoint: 'SaveSellLocationPreset' },
    };
    const MAP_CHOICES = ['GTA default map', 'Gabz', 'K4MB1', 'King Maps'];
    const REPORT_REASONS = ['Does not work', 'Copied from someone else', 'Bad picture', 'Spam'];
    const IMAGE_MAX_W = 1280;
    const IMAGE_MAX_H = 720;

    const state = {
        status: null,
        statusLoading: null,
        tab: 'browse',
        kind: 'all',
        map: '',
        sort: 'top',
        q: '',
        page: 1,
        perPage: 12,
        totalPages: 1,
        total: 0,
        items: [],
        maps: [],
        requestId: 0,
        loading: false,
        error: '',
        detail: null,
        detailBusy: false,
        installResult: null,
        reportOpen: false,
        holdView: false,
        holdTimer: null,
        share: null,
        searchTimer: null,
    };

    const $id = (id) => document.getElementById(id);

    function esc(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function kindInfo(kind) {
        return KINDS.find((k) => k.value === kind) || { value: kind, label: kind, icon: 'fa-mask' };
    }

    function notify(message, type = 'success') {
        if (!message) return;
        if (typeof rcNotify === 'function') {
            rcNotify(message, type);
            return;
        }
        try {
            fetch(`https://${GetParentResourceName()}/NuiNotify`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ Notify: message, Type: type }),
            });
        } catch (e) {}
    }

    async function nui(name, body = {}) {
        try {
            const response = await fetch(`https://${GetParentResourceName()}/${name}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body || {}),
            });
            const data = await response.json();
            return data && typeof data === 'object' ? data : { ok: false, message: 'Could not reach the robbery community hub.' };
        } catch (e) {
            return { ok: false, message: 'Could not reach the robbery community hub.' };
        }
    }

    function normalizeCode(raw) {
        let value = String(raw || '').trim().toUpperCase().replace(/\s+/g, '');
        value = value.replace(/^RC-?/, '').replace(/[^0-9A-Z]/g, '');
        return value.length === 6 ? `RC-${value}` : '';
    }

    function formatDate(seconds) {
        const date = new Date((Number(seconds) || 0) * 1000);
        if (Number.isNaN(date.getTime())) return '';
        return date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
    }

    function formatCount(value) {
        const n = Number(value) || 0;
        if (n >= 10000) return `${Math.round(n / 1000)}k`;
        if (n >= 1000) return `${(n / 1000).toFixed(1)}k`;
        return String(n);
    }

    function formatAmount(value) {
        const n = Math.max(0, Math.round(Number(value) || 0));
        return n.toLocaleString('en-US');
    }

    function formatRange(min, max, prefix = '') {
        const low = formatAmount(min);
        const high = formatAmount(max);
        return low === high ? `${prefix}${high}` : `${prefix}${low} - ${prefix}${high}`;
    }

    function copyText(text) {
        const value = String(text || '');
        if (!value) return false;
        const area = document.createElement('textarea');
        area.value = value;
        area.setAttribute('readonly', '');
        area.style.position = 'fixed';
        area.style.opacity = '0';
        area.style.left = '-9999px';
        document.body.appendChild(area);
        area.select();
        let ok = false;
        try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
        area.remove();
        if (!ok && navigator.clipboard) {
            navigator.clipboard.writeText(value).catch(() => {});
            ok = true;
        }
        return ok;
    }

    function openExternal(url) {
        if (!url) return;
        if (typeof window.invokeNative === 'function') {
            window.invokeNative('openUrl', url);
            return;
        }
        if (copyText(url)) notify('Link copied to your clipboard.', 'success');
    }

    function wrapSelect(select, placeholder, emptyLabel) {
        if (!select || typeof rcWrapSelectWithSearch !== 'function') return;
        if (select.dataset.pugSelect === '1') {
            try { select._rcPugSelectRefresh?.(); } catch (e) {}
            return;
        }
        rcWrapSelectWithSearch(select, {
            placeholder,
            populate: false,
            emptyLabel,
            getItems: () => (typeof rcSelectItemsFromSelect === 'function' ? rcSelectItemsFromSelect(select) : []),
        });
    }

    function setSelectOptions(select, options, value) {
        if (!select) return;
        select.innerHTML = options.map((o) => `<option value="${esc(o.value)}">${esc(o.label)}</option>`).join('');
        if (value !== undefined && options.some((o) => String(o.value) === String(value))) {
            select.value = value;
        }
        try { select._rcPugSelectRefresh?.(); } catch (e) {}
    }

    function ensureStatus(force = false) {
        if (state.status && state.status.ok && !force) return Promise.resolve(state.status);
        if (state.statusLoading && !force) return state.statusLoading;
        state.statusLoading = nui('CommunityStatus').then((status) => {
            state.status = status;
            state.statusLoading = null;
            return status;
        });
        return state.statusLoading;
    }

    function renderStatusBanner() {
        const banner = $id('communityStatus');
        if (!banner) return;
        const status = state.status;
        if (status && status.ok === false) {
            banner.innerHTML = `
                <div class="rcc-banner">
                    <i class="fas fa-plug-circle-xmark"></i>
                    <div class="rcc-banner-text"><strong>Community hub unavailable</strong><span>${esc(status.message || 'Could not reach the robbery community hub.')}</span></div>
                    <button type="button" class="rcc-btn" data-rcc-action="retry"><i class="fas fa-rotate-right"></i> Retry</button>
                </div>`;
            banner.style.display = 'block';
            return;
        }
        banner.innerHTML = '';
        banner.style.display = 'none';
    }

    function cardHtml(item) {
        const info = kindInfo(item.kind);
        const viewer = item.viewer || {};
        const summary = item.summary || {};
        const flags = [];
        if (viewer.mine) flags.push('<span class="rcc-flag rcc-flag--mine">Yours</span>');
        if (viewer.installedHere) flags.push('<span class="rcc-flag rcc-flag--installed"><i class="fas fa-check"></i> Installed</span>');
        if (item.hidden) flags.push('<span class="rcc-flag rcc-flag--hidden">Hidden</span>');
        const thumb = item.imageUrl
            ? `<div class="rcc-thumb"><img src="${esc(item.imageUrl)}" alt="" loading="lazy" onerror="this.remove()"></div>`
            : `<div class="rcc-thumb rcc-thumb--empty"><i class="fas ${info.icon}"></i></div>`;
        let sizeLabel = '';
        if (summary.stepCount) sizeLabel = `<span class="rcc-card-size"><span>${summary.stepCount}</span> <span>steps</span></span>`;
        else if (summary.locationCount) sizeLabel = `<span class="rcc-card-size"><span>${summary.locationCount}</span> <span>locations</span></span>`;
        else if (summary.targetCount) sizeLabel = `<span class="rcc-card-size"><span>${summary.targetCount}</span> <span>targets</span></span>`;
        return `
            <div class="rcc-card${viewer.myVote === 1 ? ' is-liked' : ''}" role="button" tabindex="0" data-rcc-open="${esc(item.code)}">
                <div class="rcc-card-media">
                    ${thumb}
                    <span class="rcc-chip"><i class="fas ${info.icon}"></i> <span>${esc(info.label)}</span></span>
                    <div class="rcc-flags">${flags.join('')}</div>
                </div>
                <div class="rcc-card-body">
                    <div class="rcc-card-title" data-rc-no-translate>${esc(item.title)}</div>
                    <div class="rcc-card-meta" data-rc-no-translate><span>${esc(item.map || 'Any map')}</span><span class="rcc-dot"></span><span>${esc(item.serverName || item.author)}</span></div>
                    <div class="rcc-card-foot">
                        <span class="rcc-stat rcc-stat--up${viewer.myVote === 1 ? ' is-active' : ''}"><i class="fas fa-thumbs-up"></i> ${formatCount(item.likes)}</span>
                        <span class="rcc-stat rcc-stat--down${viewer.myVote === -1 ? ' is-active' : ''}"><i class="fas fa-thumbs-down"></i> ${formatCount(item.dislikes)}</span>
                        <span class="rcc-stat"><i class="fas fa-download"></i> ${formatCount(item.installs)}</span>
                        ${sizeLabel}
                    </div>
                </div>
            </div>`;
    }

    function renderGrid() {
        const grid = $id('communityGrid');
        if (!grid) return;
        if (state.loading && !state.items.length) {
            grid.innerHTML = Array.from({ length: 8 }, () => '<div class="rcc-card rcc-card--skeleton"><div class="rcc-card-media"></div><div class="rcc-card-body"><div class="rcc-skel"></div><div class="rcc-skel rcc-skel--short"></div></div></div>').join('');
            return;
        }
        if (state.error) {
            grid.innerHTML = `<div class="rcc-empty"><i class="fas fa-triangle-exclamation"></i><strong>Could not load shared robberies</strong><span>${esc(state.error)}</span><button type="button" class="rcc-btn" data-rcc-action="retry"><i class="fas fa-rotate-right"></i> Retry</button></div>`;
            return;
        }
        if (!state.items.length) {
            const filtered = state.q || state.kind !== 'all' || state.map;
            const message = filtered
                ? '<strong>No shared robberies match that search</strong><span>Try another word, type or map.</span>'
                : state.tab === 'mine'
                    ? '<strong>You have not shared anything yet</strong><span>Press Share a robbery to send one of your robberies to every server.</span>'
                    : '<strong>No shared robberies yet</strong><span>Be the first server to share one.</span>';
            grid.innerHTML = `<div class="rcc-empty"><i class="fas fa-globe"></i>${message}</div>`;
            return;
        }
        grid.innerHTML = state.items.map(cardHtml).join('');
        grid.classList.toggle('is-refreshing', state.loading);
    }

    function renderPagination() {
        const info = $id('communityPageInfo');
        const prev = $id('communityPrevPage');
        const next = $id('communityNextPage');
        if (info) info.textContent = `${state.page} / ${state.totalPages}`;
        if (prev) prev.disabled = state.page <= 1;
        if (next) next.disabled = state.page >= state.totalPages;
        const count = $id('communityResultCount');
        if (count) count.innerHTML = `<b>${state.total}</b> <span>${state.total === 1 ? 'robbery' : 'robberies'}</span>`;
    }

    function renderMapFilter() {
        const select = $id('communityMapFilter');
        if (!select) return;
        const maps = Array.from(new Set([...(state.maps || []), ...(state.map ? [state.map] : [])]));
        setSelectOptions(select, [{ value: '', label: 'Any map' }, ...maps.map((m) => ({ value: m, label: m }))], state.map);
    }

    function resetFilters() {
        state.kind = 'all';
        state.map = '';
        state.q = '';
        state.page = 1;
        const kind = $id('communityKindFilter');
        if (kind) {
            kind.value = 'all';
            try { kind._rcPugSelectRefresh?.(); } catch (e) {}
        }
        renderMapFilter();
        const search = $id('communitySearch');
        if (search) search.value = '';
    }

    function renderTabs() {
        document.querySelectorAll('[data-community-tab]').forEach((btn) => {
            btn.classList.toggle('active', btn.dataset.communityTab === state.tab);
        });
    }

    async function loadList() {
        const requestId = ++state.requestId;
        state.loading = true;
        state.error = '';
        renderGrid();
        const status = await ensureStatus();
        renderStatusBanner();
        if (requestId !== state.requestId) return;
        if (!status || !status.ok) {
            state.loading = false;
            state.items = [];
            state.error = status && status.message ? status.message : 'Could not reach the robbery community hub.';
            renderGrid();
            renderPagination();
            return;
        }
        const result = await nui('CommunityList', {
            kind: state.kind,
            sort: state.sort,
            q: state.q,
            map: state.map,
            page: state.page,
            perPage: state.perPage,
            mine: state.tab === 'mine',
        });
        if (requestId !== state.requestId) return;
        state.loading = false;
        if (!result || !result.ok) {
            state.items = [];
            state.error = (result && result.message) || 'Could not reach the robbery community hub.';
        } else {
            state.items = Array.isArray(result.items) ? result.items : [];
            state.total = Number(result.total) || 0;
            state.totalPages = Math.max(1, Number(result.totalPages) || 1);
            state.page = Math.min(state.page, state.totalPages);
            state.maps = Array.isArray(result.maps) ? result.maps : state.maps;
        }
        renderGrid();
        renderPagination();
        renderMapFilter();
    }

    function updateListItem(code, patch) {
        const item = state.items.find((i) => i.code === code);
        if (item) Object.assign(item, patch);
        if (state.detail && state.detail.code === code) Object.assign(state.detail, patch);
    }

    function showCommunityMenu(options = {}) {
        if (typeof rcCloseAllHomeSubPages === 'function') rcCloseAllHomeSubPages('community');
        const primary = $id('primaryContainer');
        if (primary) primary.style.display = 'block';
        try { if (typeof rcSetTabletOverlayVisible === 'function') rcSetTabletOverlayVisible(true); } catch (e) {}
        if (typeof rcSetView === 'function') rcSetView('community');

        const wrap = $id('communityMainPageContainer');
        const page = $id('communityMainPage');
        if (wrap) wrap.style.display = 'block';
        if (page) page.style.display = 'block';

        const home = $id('mainRobberySettingsPage');
        if (home) home.style.display = 'none';
        const heading = $id('selectHeading');
        if (heading) heading.style.display = 'none';
        ['toggleEditModeButton', 'deleteHeistButton', 'heistSelect', 'createHeistButton'].forEach((id) => {
            const el = $id(id);
            if (el) el.style.display = 'none';
        });

        requestAnimationFrame(() => {
            if (typeof rcCurrentView !== 'undefined' && rcCurrentView !== 'community') return;
            if (home) home.style.display = 'none';
            if (wrap) wrap.style.display = 'block';
            if (page) page.style.display = 'block';
        });

        bindPage();
        renderTabs();
        renderStatusBanner();
        if (options.skipRefresh && state.items.length) {
            renderGrid();
            renderPagination();
            return;
        }
        loadList();
    }

    function hideCommunityPage() {
        const wrap = $id('communityMainPageContainer');
        const page = $id('communityMainPage');
        if (wrap) wrap.style.display = 'none';
        if (page) page.style.display = 'none';
    }

    let pageBound = false;
    function bindPage() {
        if (pageBound) return;
        pageBound = true;

        const kindSelect = $id('communityKindFilter');
        setSelectOptions(kindSelect, [{ value: 'all', label: 'All types' }, ...KINDS.map((k) => ({ value: k.value, label: k.label }))], state.kind);
        wrapSelect(kindSelect, 'Search type...', 'All types');
        kindSelect?.addEventListener('change', () => {
            state.kind = kindSelect.value || 'all';
            state.page = 1;
            loadList();
        });

        const mapSelect = $id('communityMapFilter');
        setSelectOptions(mapSelect, [{ value: '', label: 'Any map' }], '');
        wrapSelect(mapSelect, 'Search map...', 'Any map');
        mapSelect?.addEventListener('change', () => {
            state.map = mapSelect.value || '';
            state.page = 1;
            loadList();
        });

        const sortSelect = $id('communitySort');
        setSelectOptions(sortSelect, [
            { value: 'top', label: 'Top rated' },
            { value: 'new', label: 'Newest' },
            { value: 'installs', label: 'Most installed' },
        ], state.sort);
        wrapSelect(sortSelect, 'Search sort...', 'Top rated');
        sortSelect?.addEventListener('change', () => {
            state.sort = sortSelect.value || 'top';
            state.page = 1;
            loadList();
        });

        $id('communitySearch')?.addEventListener('input', (event) => {
            clearTimeout(state.searchTimer);
            state.searchTimer = setTimeout(() => {
                state.q = String(event.target.value || '').trim();
                state.page = 1;
                loadList();
            }, 350);
        });

        document.querySelectorAll('[data-community-tab]').forEach((btn) => {
            btn.addEventListener('click', () => {
                if (state.tab === btn.dataset.communityTab) return;
                state.tab = btn.dataset.communityTab;
                state.page = 1;
                renderTabs();
                loadList();
            });
        });

        $id('communityPrevPage')?.addEventListener('click', () => {
            if (state.page <= 1) return;
            state.page -= 1;
            loadList();
        });
        $id('communityNextPage')?.addEventListener('click', () => {
            if (state.page >= state.totalPages) return;
            state.page += 1;
            loadList();
        });

        const codeInput = $id('communityCodeInput');
        const openCode = () => {
            const code = normalizeCode(codeInput?.value);
            if (!code) {
                notify('Share codes look like RC-7K2Q9M.', 'error');
                return;
            }
            openDetail(code);
        };
        $id('communityCodeOpen')?.addEventListener('click', openCode);
        codeInput?.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                openCode();
            }
        });

        $id('communityShareButton')?.addEventListener('click', () => openShare());
        $id('communityOpenSite')?.addEventListener('click', async () => {
            const status = await ensureStatus();
            openExternal(status && status.siteUrl ? status.siteUrl : (window.Config?.Community?.ApiUrl || ''));
        });

        const grid = $id('communityGrid');
        grid?.addEventListener('click', (event) => {
            const card = event.target.closest('[data-rcc-open]');
            if (card) openDetail(card.dataset.rccOpen);
        });
        grid?.addEventListener('keydown', (event) => {
            if (event.key !== 'Enter') return;
            const card = event.target.closest('[data-rcc-open]');
            if (card) openDetail(card.dataset.rccOpen);
        });

        $id('communityMainPage')?.addEventListener('click', async (event) => {
            const btn = event.target.closest('[data-rcc-action="retry"]');
            if (!btn) return;
            await ensureStatus(true);
            renderStatusBanner();
            loadList();
        });
    }

    function ensureModal() {
        let modal = $id('communityModal');
        if (modal) return modal;
        modal = document.createElement('div');
        modal.id = 'communityModal';
        modal.className = 'rcc-modal';
        modal.style.display = 'none';
        modal.innerHTML = '<div class="rcc-modal-card" role="dialog" aria-modal="true"><button type="button" class="rcc-modal-close" data-rcc-close aria-label="Close"><i class="fas fa-xmark"></i></button><div class="rcc-modal-content" id="communityModalContent"></div></div>';
        const host = $id('overlay') || document.body;
        host.appendChild(modal);
        modal.addEventListener('mousedown', (event) => {
            if (event.target === modal) closeModal();
        });
        modal.addEventListener('click', (event) => {
            if (event.target.closest('[data-rcc-close]')) closeModal();
        });
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && modal.style.display !== 'none' && !modal.classList.contains('rcc-modal--hidden')) {
                event.stopImmediatePropagation();
                event.stopPropagation();
                if (!state.share?.busy && !state.detailBusy) closeModal();
            }
        }, true);
        return modal;
    }

    function openModal(html, variant) {
        const modal = ensureModal();
        modal.querySelector('.rcc-modal-card').className = `rcc-modal-card${variant ? ` rcc-modal-card--${variant}` : ''}`;
        $id('communityModalContent').innerHTML = html;
        modal.style.display = 'flex';
        return modal;
    }

    function closeModal() {
        const modal = $id('communityModal');
        if (modal) modal.style.display = 'none';
        if (state.share && state.share.previewUrl && state.share.previewUrl.startsWith('blob:')) {
            try { URL.revokeObjectURL(state.share.previewUrl); } catch (e) {}
        }
        state.detail = null;
        state.installResult = null;
        state.reportOpen = false;
        state.share = null;
    }

    function setModalHidden(hidden) {
        const modal = $id('communityModal');
        if (modal) modal.classList.toggle('rcc-modal--hidden', !!hidden);
    }

    async function openDetail(code) {
        const normalized = normalizeCode(code);
        if (!normalized) return;
        state.installResult = null;
        state.reportOpen = false;
        const cached = state.items.find((i) => i.code === normalized);
        state.detail = cached ? { ...cached } : { code: normalized, loading: true };
        renderDetail();
        const status = await ensureStatus();
        if (!status || !status.ok) {
            renderDetailError(status && status.message);
            return;
        }
        const result = await nui('CommunityDetail', { code: normalized });
        if (!state.detail || state.detail.code !== normalized) return;
        if (!result || !result.ok || !result.item) {
            renderDetailError((result && result.message) || 'No shared robbery has that code.');
            return;
        }
        state.detail = result.item;
        updateListItem(normalized, result.item);
        renderDetail();
    }

    function renderDetailError(message) {
        openModal(`
            <div class="rcc-empty rcc-empty--modal">
                <i class="fas fa-circle-question"></i>
                <strong>Shared robbery not found</strong>
                <span>${esc(message || 'No shared robbery has that code.')}</span>
                <button type="button" class="rcc-btn" data-rcc-close>Close</button>
            </div>`, 'small');
        state.detail = null;
    }

    function detailFacts(item) {
        const s = item.summary || {};
        const facts = [];
        if (s.stepCount) facts.push(['Steps', s.stepCount]);
        if (s.doorCount) facts.push(['Door locks', s.doorCount]);
        if (s.locationCount) facts.push(['Locations', s.locationCount]);
        if (s.shellCount) facts.push(['Shells', s.shellCount]);
        if (s.targetCount) facts.push(['Targets', s.targetCount]);
        if (s.policeRequired) facts.push(['Police required', s.policeRequired]);
        facts.push(['Installs', formatCount(item.installs)]);
        if (item.scriptVersion) facts.push(['Made with', `v${item.scriptVersion}`]);
        return facts;
    }

    function rewardsHtml(item) {
        if (item.kind !== 'main') return '';
        const rewards = item.summary && item.summary.rewards;
        const label = '<div class="rcc-label">Rewards</div>';
        if (!rewards || typeof rewards !== 'object' || Array.isArray(rewards)) {
            return `${label}<div class="rcc-note rcc-note--box"><i class="fas fa-circle-info"></i><span>This robbery was shared before reward lists were added. Check its rewards after installing - it arrives paused.</span></div>`;
        }
        const list = (value) => (Array.isArray(value) ? value.filter((entry) => entry && typeof entry === 'object') : []);
        const money = list(rewards.money);
        const steps = list(rewards.steps);
        const items = list(rewards.items);
        const end = rewards.endPayout && typeof rewards.endPayout === 'object' && !Array.isArray(rewards.endPayout) ? rewards.endPayout : null;
        const moreSteps = Math.max(0, Math.round(Number(rewards.moreSteps) || 0));
        const moreItems = Math.max(0, Math.round(Number(rewards.moreItems) || 0));
        if (!money.length && !items.length && !end) {
            return `${label}<div class="rcc-note rcc-note--box"><i class="fas fa-circle-info"></i><span>This robbery pays no money or items.</span></div>`;
        }

        const blocks = [];
        const totals = money.map((m) => `
            <div class="rcc-reward-total"><i class="fas fa-sack-dollar"></i><div><span>Total money</span><b data-rc-no-translate>${esc(formatRange(m.min, m.max, '$'))} ${esc(m.type || 'cash')}</b></div></div>`);
        if (end) {
            totals.push(`
            <div class="rcc-reward-total"><i class="fas fa-handshake"></i><div><span>Ending payout</span><b><span data-rc-no-translate>${esc(formatRange(end.min, end.max, '$'))}</span> <span>cash for each reward item handed in</span></b></div></div>`);
        }
        if (totals.length) blocks.push(`<div class="rcc-reward-totals">${totals.join('')}</div>`);
        if (steps.length) {
            const rows = steps.map((s) => `
                <div class="rcc-reward-row">
                    <span class="rcc-reward-step"><span>Step</span> <b data-rc-no-translate>${esc(s.step)}</b> ${s.name ? `<span data-rc-no-translate>${esc(s.name)}</span>` : `<span>${esc(s.kind || '')}</span>`}</span>
                    <b data-rc-no-translate>${esc(formatRange(s.min, s.max, '$'))} ${esc(s.type || 'cash')}</b>
                </div>`).join('');
            const more = moreSteps ? `<div class="rcc-reward-row rcc-reward-row--more"><span data-rc-no-translate>+${moreSteps}</span> <span>more steps</span></div>` : '';
            blocks.push(`<div class="rcc-reward-list"><div class="rcc-reward-head">Money by step</div>${rows}${more}</div>`);
        }
        if (items.length) {
            const chips = items.map((i) => {
                const chance = Math.round(Number(i.chance) || 0);
                const chanceHtml = chance > 0 && chance < 100 ? ` <em><span data-rc-no-translate>${chance}%</span> <span>chance</span></em>` : '';
                return `<span class="rcc-reward-item"><b data-rc-no-translate>${esc(i.name)}</b> <em data-rc-no-translate>x${esc(formatRange(i.min, i.max))}</em>${chanceHtml}</span>`;
            }).join('');
            const more = moreItems ? `<span class="rcc-reward-item rcc-reward-item--more"><span data-rc-no-translate>+${moreItems}</span> <span>more items</span></span>` : '';
            blocks.push(`<div class="rcc-reward-head rcc-reward-head--plain">Reward items</div><div class="rcc-reward-items">${chips}${more}</div>`);
        }
        return `${label}<div class="rcc-rewards">${blocks.join('')}</div>`;
    }

    function installPanelHtml(item) {
        const viewer = item.viewer || {};
        if (state.installResult) return installResultHtml(state.installResult);
        if (item.kind === 'main') {
            const suggested = (item.summary && item.summary.robberyName) || item.title || '';
            return `
                <div class="rcc-install">
                    <div class="rcc-label">Install as</div>
                    <input type="text" id="communityInstallName" maxlength="50" value="${esc(suggested)}" data-rc-no-translate>
                    <button type="button" class="rcc-btn rcc-btn--primary rcc-btn--wide" data-rcc-action="install-main"${state.detailBusy ? ' disabled' : ''}><i class="fas fa-download"></i> ${viewer.installedHere ? 'Install again' : 'Install robbery'}</button>
                    <div class="rcc-note">Adds this as a new robbery. Your current robberies stay untouched. If the name is taken a number is added.</div>
                    <div class="rcc-note"><i class="fas fa-circle-pause"></i> <span>It arrives paused, so players cannot start it until you turn it on.</span></div>
                </div>`;
        }
        const presetName = String(item.title || item.code).replace(/[^A-Za-z0-9 _-]/g, '').trim().replace(/\s+/g, '_').slice(0, 40) || item.code.replace('-', '_');
        return `
            <div class="rcc-install">
                <div class="rcc-label">Install</div>
                <button type="button" class="rcc-btn rcc-btn--primary rcc-btn--wide" data-rcc-action="install-preset"${state.detailBusy ? ' disabled' : ''}><i class="fas fa-file-arrow-down"></i> Save as preset</button>
                <input type="text" id="communityPresetName" maxlength="40" value="${esc(presetName)}" data-rc-no-translate>
                <div class="rcc-note">Adds it to the Load Preset list on that robbery type's page so you can load it when you are ready.</div>
                <button type="button" class="rcc-btn rcc-btn--danger rcc-btn--wide" data-rcc-action="install-apply"${state.detailBusy ? ' disabled' : ''}><i class="fas fa-right-left"></i> Replace my setup now</button>
                <div class="rcc-note">Swaps your current setup for this one, the same as loading a preset.</div>
            </div>`;
    }

    function installResultHtml(result) {
        const lines = [];
        if (result.kind === 'main') {
            lines.push(`<div class="rcc-result-line"><i class="fas fa-check"></i><span><span>Installed as</span> <b data-rc-no-translate>${esc(result.heistName)}</b></span></div>`);
            if (result.paused) lines.push('<div class="rcc-result-line rcc-result-line--warn"><i class="fas fa-circle-pause"></i><span>Paused until you review it. Players cannot start it yet. Open the robbery, check the steps and rewards, then turn off Paused in Settings.</span></div>');
            if (result.createdDoors) lines.push(`<div class="rcc-result-line rcc-result-line--warn"><i class="fas fa-door-closed"></i><span><b>${result.createdDoors}</b> <span>new doors were added to ox_doorlock. Restart ox_doorlock (or the server) so they load.</span></span></div>`);
            if (result.reusedDoors) lines.push(`<div class="rcc-result-line"><i class="fas fa-door-open"></i><span><b>${result.reusedDoors}</b> <span>doors already existed on your server and were linked.</span></span></div>`);
            if (result.doorsToSet) lines.push(`<div class="rcc-result-line rcc-result-line--warn"><i class="fas fa-triangle-exclamation"></i><span><b>${result.doorsToSet}</b> <span>door steps need a door picked. Open the robbery and choose the doors.</span></span></div>`);
        } else if (result.mode === 'preset') {
            lines.push(`<div class="rcc-result-line"><i class="fas fa-check"></i><span><span>Saved as preset</span> <b data-rc-no-translate>${esc(result.fileName)}</b></span></div>`);
            lines.push(`<div class="rcc-result-line"><i class="fas fa-circle-info"></i><span>Load it from the Load Preset button on that page.</span></div>`);
        } else {
            lines.push(`<div class="rcc-result-line"><i class="fas fa-check"></i><span>Your setup was replaced and saved.</span></div>`);
        }
        if (result.missingItems && result.missingItems.length) {
            lines.push(`<div class="rcc-result-line rcc-result-line--warn"><i class="fas fa-box"></i><span><span>Items missing on your server:</span> <b data-rc-no-translate>${esc(result.missingItems.join(', '))}</b></span></div>`);
        }
        if (result.missingMinigames && result.missingMinigames.length) {
            lines.push(`<div class="rcc-result-line rcc-result-line--warn"><i class="fas fa-gamepad"></i><span><span>Minigames not installed:</span> <b data-rc-no-translate>${esc(result.missingMinigames.join(', '))}</b></span></div>`);
        }
        const goLabel = result.kind === 'main' ? 'Open robbery' : 'Go to page';
        return `
            <div class="rcc-install rcc-install--done">
                <div class="rcc-label">Installed</div>
                ${lines.join('')}
                <button type="button" class="rcc-btn rcc-btn--primary rcc-btn--wide" data-rcc-action="go-installed"><i class="fas fa-arrow-right"></i> ${goLabel}</button>
            </div>`;
    }

    function voteButtonsHtml(item) {
        const viewer = item.viewer || {};
        const disabled = viewer.mine || state.detailBusy;
        const title = viewer.mine ? ' title="You cannot vote on your own robbery"' : '';
        return `
            <div class="rcc-votes">
                <button type="button" class="rcc-vote rcc-vote--up${viewer.myVote === 1 ? ' is-active' : ''}" data-rcc-action="vote" data-value="1"${disabled ? ' disabled' : ''}${title}><i class="fas fa-thumbs-up"></i><b>${formatCount(item.likes)}</b><span>Like</span></button>
                <button type="button" class="rcc-vote rcc-vote--down${viewer.myVote === -1 ? ' is-active' : ''}" data-rcc-action="vote" data-value="-1"${disabled ? ' disabled' : ''}${title}><i class="fas fa-thumbs-down"></i><b>${formatCount(item.dislikes)}</b><span>Dislike</span></button>
            </div>`;
    }

    function reportHtml(item) {
        const viewer = item.viewer || {};
        if (viewer.mine) {
            return `<button type="button" class="rcc-link rcc-link--danger" data-rcc-action="delete"><i class="fas fa-trash"></i> <span>Delete from community</span></button>`;
        }
        if (!state.reportOpen) {
            return `<button type="button" class="rcc-link" data-rcc-action="report-open"><i class="fas fa-flag"></i> <span>Report</span></button>`;
        }
        return `
            <div class="rcc-report">
                <div class="rcc-label">Report this robbery</div>
                <div class="rcc-report-reasons">${REPORT_REASONS.map((r, i) => `<label><input type="radio" name="communityReportReason" value="${esc(r)}"${i === 0 ? ' checked' : ''}> <span>${esc(r)}</span></label>`).join('')}</div>
                <textarea id="communityReportText" maxlength="250" rows="2" placeholder="Anything else? (optional)"></textarea>
                <div class="rcc-row">
                    <button type="button" class="rcc-btn" data-rcc-action="report-cancel">Cancel</button>
                    <button type="button" class="rcc-btn rcc-btn--danger" data-rcc-action="report-send"><i class="fas fa-flag"></i> Send report</button>
                </div>
            </div>`;
    }

    function renderDetail() {
        const item = state.detail;
        if (!item) return;
        if (item.loading) {
            openModal('<div class="rcc-loading"><i class="fas fa-circle-notch fa-spin"></i><span>Loading shared robbery...</span></div>', 'small');
            return;
        }
        const info = kindInfo(item.kind);
        const summary = item.summary || {};
        const steps = Array.isArray(summary.stepTypes) ? summary.stepTypes : [];
        const items = Array.isArray(summary.items) ? summary.items : [];
        const minigames = Array.isArray(summary.minigames) ? summary.minigames : [];
        const hero = item.imageUrl
            ? `<div class="rcc-hero"><img src="${esc(item.imageUrl)}" alt="" onerror="this.parentNode.classList.add('rcc-hero--empty');this.remove()"><i class="fas ${info.icon}"></i></div>`
            : `<div class="rcc-hero rcc-hero--empty"><i class="fas ${info.icon}"></i></div>`;
        const facts = detailFacts(item).map(([k, v]) => `<div class="rcc-fact"><span>${esc(k)}</span><b>${esc(v)}</b></div>`).join('');
        const requirements = [];
        requirements.push(`<div class="rcc-req"><i class="fas fa-map-location-dot"></i><div><span>Map</span><b data-rc-no-translate>${esc(item.map || 'Any map')}</b></div></div>`);
        if (minigames.length) requirements.push(`<div class="rcc-req"><i class="fas fa-gamepad"></i><div><span>Minigames</span><b data-rc-no-translate>${esc(minigames.join(', '))}</b></div></div>`);
        if (items.length) requirements.push(`<div class="rcc-req"><i class="fas fa-box"></i><div><span>Items used</span><b data-rc-no-translate>${esc(items.slice(0, 24).join(', '))}${items.length > 24 ? ' ...' : ''}</b></div></div>`);

        openModal(`
            <div class="rcc-detail">
                <div class="rcc-detail-main">
                    ${hero}
                    <div class="rcc-detail-head">
                        <div class="rcc-detail-kicker"><span class="rcc-chip rcc-chip--inline"><i class="fas ${info.icon}"></i> <span>${esc(info.label)}</span></span>${item.hidden ? '<span class="rcc-flag rcc-flag--hidden">Hidden</span>' : ''}</div>
                        <h2 data-rc-no-translate>${esc(item.title)}</h2>
                        <div class="rcc-detail-by"><span>Shared by</span> <b data-rc-no-translate>${esc(item.author)}</b> <span class="rcc-dot"></span> <span data-rc-no-translate>${esc(item.serverName)}</span> <span class="rcc-dot"></span> <span data-rc-no-translate>${esc(formatDate(item.createdAt))}</span></div>
                    </div>
                    <div class="rcc-desc" data-rc-no-translate>${esc(item.description || '')}</div>
                    ${item.description ? '' : '<div class="rcc-desc rcc-desc--empty">No description given.</div>'}
                    ${steps.length ? `<div class="rcc-label">Steps</div><div class="rcc-steps">${steps.map((s) => `<span>${esc(s)}</span>`).join('')}</div>` : ''}
                    ${rewardsHtml(item)}
                    <div class="rcc-reqs">${requirements.join('')}</div>
                </div>
                <div class="rcc-detail-side">
                    <div class="rcc-codebox">
                        <div>
                            <div class="rcc-label">Share code</div>
                            <div class="rcc-code" data-rc-no-translate>${esc(item.code)}</div>
                        </div>
                        <div class="rcc-codebox-actions">
                            <button type="button" class="rcc-icon-btn tooltip-container" data-rcc-action="copy-code"><i class="fas fa-copy"></i><span class="tooltip-text">Copy code</span></button>
                            <button type="button" class="rcc-icon-btn tooltip-container" data-rcc-action="copy-link"><i class="fas fa-link"></i><span class="tooltip-text">Copy link</span></button>
                            <button type="button" class="rcc-icon-btn tooltip-container" data-rcc-action="open-link"><i class="fas fa-up-right-from-square"></i><span class="tooltip-text">Open in browser</span></button>
                        </div>
                    </div>
                    ${voteButtonsHtml(item)}
                    <div class="rcc-facts">${facts}</div>
                    ${installPanelHtml(item)}
                    <div class="rcc-detail-foot">${reportHtml(item)}</div>
                </div>
            </div>`, 'detail');
        bindDetailActions();
    }

    function bindDetailActions() {
        const content = $id('communityModalContent');
        if (!content || content.dataset.bound === '1') return;
        content.dataset.bound = '1';
        content.addEventListener('click', (event) => {
            const btn = event.target.closest('[data-rcc-action]');
            if (!btn || btn.disabled) return;
            const action = btn.dataset.rccAction;
            if (state.share && !String(action).startsWith('share')) {
                handleShareAction(action, btn, event);
                return;
            }
            handleDetailAction(action, btn);
        });
        content.addEventListener('change', (event) => {
            if (state.share) handleShareChange(event);
        });
        content.addEventListener('input', (event) => {
            if (state.share) handleShareInput(event);
        });
    }

    async function handleDetailAction(action, btn) {
        const item = state.detail;
        if (!item) return;
        if (action === 'copy-code') {
            if (copyText(item.code)) notify('Code copied.', 'success');
            return;
        }
        if (action === 'copy-link') {
            if (copyText(item.link)) notify('Link copied to your clipboard.', 'success');
            return;
        }
        if (action === 'open-link') {
            openExternal(item.link);
            return;
        }
        if (action === 'vote') {
            const wanted = Number(btn.dataset.value);
            const current = (item.viewer && item.viewer.myVote) || 0;
            const value = current === wanted ? 0 : wanted;
            state.detailBusy = true;
            renderDetail();
            const result = await nui('CommunityVote', { code: item.code, value });
            state.detailBusy = false;
            if (result && result.ok) {
                const viewer = { ...(item.viewer || {}), myVote: result.myVote };
                updateListItem(item.code, { likes: result.likes, dislikes: result.dislikes, viewer });
                renderGrid();
            } else {
                notify((result && result.message) || 'Your vote did not go through.', 'error');
            }
            renderDetail();
            return;
        }
        if (action === 'report-open') {
            state.reportOpen = true;
            renderDetail();
            return;
        }
        if (action === 'report-cancel') {
            state.reportOpen = false;
            renderDetail();
            return;
        }
        if (action === 'report-send') {
            const reason = document.querySelector('input[name="communityReportReason"]:checked')?.value || 'Other';
            const extra = String($id('communityReportText')?.value || '').trim();
            state.detailBusy = true;
            const result = await nui('CommunityReport', { code: item.code, reason: extra ? `${reason}: ${extra}` : reason });
            state.detailBusy = false;
            state.reportOpen = false;
            if (result && result.ok) notify('Thanks - the report was sent.', 'success');
            else notify((result && result.message) || 'The report did not go through.', 'error');
            renderDetail();
            return;
        }
        if (action === 'delete') {
            if (btn.dataset.armed !== '1') {
                btn.dataset.armed = '1';
                btn.classList.add('is-armed');
                btn.innerHTML = '<i class="fas fa-trash"></i> <span>Click again to delete</span>';
                return;
            }
            state.detailBusy = true;
            const result = await nui('CommunityDelete', { code: item.code });
            state.detailBusy = false;
            if (result && result.ok) {
                notify('Removed from the community.', 'success');
                closeModal();
                loadList();
            } else {
                notify((result && result.message) || 'Could not delete it.', 'error');
                renderDetail();
            }
            return;
        }
        if (action === 'install-main') {
            await installMain(item);
            return;
        }
        if (action === 'install-preset') {
            await installSetup(item, 'preset');
            return;
        }
        if (action === 'install-apply') {
            if (btn.dataset.armed !== '1') {
                btn.dataset.armed = '1';
                btn.classList.add('is-armed');
                btn.innerHTML = '<i class="fas fa-right-left"></i> <span>Click again to replace</span>';
                return;
            }
            await installSetup(item, 'apply');
            return;
        }
        if (action === 'go-installed') {
            goToInstalled(state.installResult);
        }
    }

    function holdCommunityView() {
        state.holdView = true;
        clearTimeout(state.holdTimer);
        state.holdTimer = setTimeout(() => { state.holdView = false; }, 15000);
    }

    window.rcCommunityAfterRefresh = function () {
        if (!state.holdView) return;
        state.holdView = false;
        state.restoredAt = Date.now();
        clearTimeout(state.holdTimer);
        showCommunityMenu({ skipRefresh: true });
    };

    async function installMain(item) {
        const name = String($id('communityInstallName')?.value || '').trim();
        state.detailBusy = true;
        renderDetail();
        holdCommunityView();
        const result = await nui('CommunityInstall', { code: item.code, name });
        state.detailBusy = false;
        if (!result || !result.ok) {
            state.holdView = false;
            notify((result && result.message) || 'The robbery could not be installed.', 'error');
            renderDetail();
            return;
        }
        state.installResult = {
            kind: 'main',
            heistName: result.result && result.result.heistName,
            createdDoors: result.result ? result.result.createdDoors : 0,
            reusedDoors: result.result ? result.result.reusedDoors : 0,
            doorsToSet: result.result ? result.result.doorsToSet : 0,
            paused: !!(result.result && result.result.paused),
            missingItems: result.missingItems || [],
            missingMinigames: result.missingMinigames || [],
        };
        const viewer = { ...(item.viewer || {}), installedHere: true };
        updateListItem(item.code, { installs: result.item ? result.item.installs : item.installs, viewer });
        notify('Robbery installed.', 'success');
        renderGrid();
        renderDetail();
    }

    function applySetup(kind, settings) {
        if (kind === 'house') {
            window.LoadHouseRobberyData(settings);
            window.SaveHouseRobberyData();
            return true;
        }
        if (kind === 'petty') {
            window.LoadPettyCrimeData(settings);
            window.SavePettyCrimeData();
            return true;
        }
        if (typeof setupPresetConfigs !== 'undefined' && setupPresetConfigs[kind]) {
            setupPresetConfigs[kind].applyData(settings);
            return true;
        }
        return false;
    }

    async function installSetup(item, mode) {
        const page = KIND_PAGES[item.kind];
        if (!page) return;
        let fileName = '';
        if (mode === 'preset') {
            fileName = String($id('communityPresetName')?.value || '').trim()
                .replace(/\.json$/i, '').replace(/[<>:"/\\|?*]/g, '_').replace(/\s+/g, '_').replace(/_+/g, '_').replace(/^_+|_+$/g, '');
            if (!fileName) {
                notify('Enter a preset name first.', 'error');
                return;
            }
        }
        state.detailBusy = true;
        renderDetail();
        const result = await nui('CommunityInstall', { code: item.code });
        if (!result || !result.ok || !result.settings) {
            state.detailBusy = false;
            notify((result && result.message) || 'The setup could not be downloaded.', 'error');
            renderDetail();
            return;
        }

        if (mode === 'preset') {
            const saved = await nui(page.presetEndpoint, { fileName, data: result.settings });
            state.detailBusy = false;
            if (!saved || saved.success === false || saved.ok === false) {
                notify((saved && (saved.error || saved.message)) || 'The preset could not be saved.', 'error');
                renderDetail();
                return;
            }
            state.installResult = { kind: item.kind, mode, fileName: saved.fileName || `${fileName}.json`, missingItems: result.missingItems || [], missingMinigames: result.missingMinigames || [] };
        } else {
            const nav = $id(page.nav);
            if (nav) nav.click();
            let applied = false;
            try { applied = applySetup(item.kind, result.settings); } catch (e) { console.error('Community setup apply failed', e); }
            state.detailBusy = false;
            if (!applied) {
                notify('That setup could not be applied on this page.', 'error');
                showCommunityMenu({ skipRefresh: true });
                renderDetail();
                return;
            }
            state.installResult = { kind: item.kind, mode, missingItems: result.missingItems || [], missingMinigames: result.missingMinigames || [] };
            showCommunityMenu({ skipRefresh: true });
        }
        const viewer = { ...(item.viewer || {}), installedHere: true };
        updateListItem(item.code, { installs: result.item ? result.item.installs : item.installs, viewer });
        renderGrid();
        renderDetail();
    }

    function goToInstalled(result) {
        if (!result) return;
        closeModal();
        if (result.kind === 'main') {
            const select = $id('heistSelect');
            let exists = false;
            if (select && result.heistName) {
                exists = Array.from(select.options).some((o) => o.value === result.heistName);
                if (exists) {
                    select.value = result.heistName;
                    try { select.dispatchEvent(new Event('change', { bubbles: true })); } catch (e) {}
                    try { select._rcPugSelectRefresh?.(); } catch (e) {}
                }
            }
            if (typeof ShowHubOnly === 'function') ShowHubOnly('main');
            if (exists) requestAnimationFrame(() => $id('toggleEditModeButton')?.click());
            return;
        }
        const page = KIND_PAGES[result.kind];
        const nav = page && $id(page.nav);
        if (nav) nav.click();
    }

    async function openShare(prefill = {}) {
        state.detail = null;
        state.share = {
            kind: prefill.kind || 'main',
            robberyName: prefill.robberyName || '',
            title: '',
            titleTouched: false,
            description: '',
            mapChoice: MAP_CHOICES[0],
            mapOther: '',
            author: '',
            agree: false,
            image: null,
            previewUrl: '',
            imageMode: '',
            imageLink: '',
            busy: false,
            progress: '',
            options: null,
            result: null,
        };
        openModal('<div class="rcc-loading"><i class="fas fa-circle-notch fa-spin"></i><span>Loading your robberies...</span></div>', 'small');
        bindDetailActions();
        const status = await ensureStatus();
        if (!state.share) return;
        if (!status || !status.ok) {
            renderDetailError(status && status.message);
            state.share = null;
            return;
        }
        const options = await nui('CommunityShareOptions');
        if (!state.share) return;
        if (!options || !options.ok) {
            renderDetailError((options && options.message) || 'Could not load your robberies.');
            state.share = null;
            return;
        }
        state.share.options = options;
        state.share.author = options.author || status.author || '';
        if (!state.share.robberyName && options.robberies && options.robberies.length) {
            state.share.robberyName = options.robberies[0].name;
        }
        if (state.share.kind !== 'main' && !(options.setups || {})[state.share.kind]) state.share.kind = 'main';
        state.share.title = defaultShareTitle();
        renderShare();
    }

    function defaultShareTitle() {
        const share = state.share;
        if (!share) return '';
        if (share.kind === 'main') return String(share.robberyName || '').replace(/\b\w/g, (c) => c.toUpperCase()).slice(0, 60);
        return `${kindInfo(share.kind).label} setup`;
    }

    function shareMapValue() {
        const share = state.share;
        if (!share) return '';
        return share.mapChoice === '__other' ? String(share.mapOther || '').trim().slice(0, 40) : share.mapChoice;
    }

    function shareReady() {
        const share = state.share;
        if (!share || share.busy) return false;
        if (String(share.title || '').trim().length < 3) return false;
        if (share.kind === 'main' && !share.robberyName) return false;
        if (!share.agree) return false;
        if (share.imageMode === 'link' && share.imageLink && !share.previewOk) return false;
        return true;
    }

    function renderShare() {
        const share = state.share;
        if (!share) return;
        if (share.result) {
            renderShareResult();
            return;
        }
        const options = share.options || { robberies: [], setups: {} };
        const kinds = KINDS.map((k) => {
            const available = k.value === 'main' ? (options.robberies || []).length > 0 : !!(options.setups || {})[k.value];
            return `<button type="button" class="rcc-kind${share.kind === k.value ? ' is-active' : ''}" data-rcc-action="pick-kind" data-kind="${k.value}"${available && !share.busy ? '' : ' disabled'}><i class="fas ${k.icon}"></i><span>${esc(k.label)}</span>${available ? '' : '<em>Nothing set up</em>'}</button>`;
        }).join('');
        const robberyOptions = (options.robberies || []).map((r) => `<option value="${esc(r.name)}"${r.name === share.robberyName ? ' selected' : ''}>${esc(r.name)} (${r.steps} steps)</option>`).join('');
        const mapOptions = [...MAP_CHOICES.map((m) => ({ value: m, label: m })), { value: '__other', label: 'Other map / MLO' }]
            .map((o) => `<option value="${esc(o.value)}"${o.value === share.mapChoice ? ' selected' : ''}>${esc(o.label)}</option>`).join('');
        const preview = share.previewUrl
            ? `<img src="${esc(share.previewUrl)}" alt="" id="communitySharePreviewImg">`
            : '<div class="rcc-shot-empty"><i class="fas fa-image"></i><span>No picture yet</span><em>Listings with a picture get far more installs.</em></div>';
        openModal(`
            <div class="rcc-share">
                <div class="rcc-share-head">
                    <div class="rcc-share-icon"><i class="fas fa-cloud-arrow-up"></i></div>
                    <div>
                        <h2>Share a robbery</h2>
                        <div class="rcc-share-sub">Every server running the robbery creator can see and install what you share.</div>
                    </div>
                </div>
                <div class="rcc-share-grid">
                    <div class="rcc-share-col">
                        <div class="rcc-label">What are you sharing?</div>
                        <div class="rcc-kinds">${kinds}</div>
                        ${share.kind === 'main' ? `<div class="rcc-label">Robbery</div><select id="communityShareRobbery">${robberyOptions}</select>` : `<div class="rcc-note rcc-note--box"><i class="fas fa-circle-info"></i> <span>This shares your whole saved setup for this robbery type. Save that page first so the newest changes are included.</span></div>`}
                        <div class="rcc-label">Title</div>
                        <input type="text" id="communityShareTitle" maxlength="60" value="${esc(share.title)}" placeholder="Paleto Bay bank job" data-rc-no-translate>
                        <div class="rcc-two">
                            <div>
                                <div class="rcc-label">Map / MLO</div>
                                <select id="communityShareMap">${mapOptions}</select>
                                ${share.mapChoice === '__other' ? `<input type="text" id="communityShareMapOther" maxlength="40" value="${esc(share.mapOther)}" placeholder="Map or MLO name" data-rc-no-translate>` : ''}
                            </div>
                            <div>
                                <div class="rcc-label">Shown as</div>
                                <input type="text" id="communityShareAuthor" maxlength="40" value="${esc(share.author)}" data-rc-no-translate>
                            </div>
                        </div>
                        <div class="rcc-label rcc-label--row"><span>Description</span><em id="communityShareDescCount">${String(share.description || '').length}/1500</em></div>
                        <textarea id="communityShareDescription" maxlength="1500" rows="5" placeholder="What makes it fun, how hard it is, which items and minigames it needs..." data-rc-no-translate>${esc(share.description)}</textarea>
                    </div>
                    <div class="rcc-share-col">
                        <div class="rcc-label">Picture</div>
                        <div class="rcc-shot${share.previewUrl ? ' has-image' : ''}">${preview}</div>
                        <div class="rcc-row">
                            <button type="button" class="rcc-btn" data-rcc-action="shot"${share.busy ? ' disabled' : ''}><i class="fas fa-camera"></i> Take in-game picture</button>
                            <button type="button" class="rcc-btn${share.imageMode === 'link' ? ' is-active' : ''}" data-rcc-action="link-mode"${share.busy ? ' disabled' : ''}><i class="fas fa-link"></i> Use image link</button>
                            ${share.previewUrl ? `<button type="button" class="rcc-icon-btn tooltip-container" data-rcc-action="clear-image"${share.busy ? ' disabled' : ''}><i class="fas fa-xmark"></i><span class="tooltip-text">Remove picture</span></button>` : ''}
                        </div>
                        ${share.imageMode === 'link' ? `<input type="text" id="communityShareLink" value="${esc(share.imageLink)}" placeholder="https://i.imgur.com/example.png" data-rc-no-translate><div class="rcc-note">Direct image links (JPG, PNG, WEBP, GIF) up to 6 MB. The picture is copied to the hub so it keeps working.</div>` : '<div class="rcc-note">The menu hides while you line up the shot. Press E to take it.</div>'}
                        <label class="rcc-agree"><input type="checkbox" id="communityShareAgree"${share.agree ? ' checked' : ''}> <span>I made this (or have permission to share it) and the picture is fine for everyone to see.</span></label>
                    </div>
                </div>
                <div class="rcc-share-foot">
                    <div class="rcc-progress" id="communityShareProgress">${share.progress ? `<i class="fas fa-circle-notch fa-spin"></i> <span>${esc(share.progress)}</span>` : ''}</div>
                    <button type="button" class="rcc-btn" data-rcc-close${share.busy ? ' disabled' : ''}>Cancel</button>
                    <button type="button" class="rcc-btn rcc-btn--primary" data-rcc-action="publish"${shareReady() ? '' : ' disabled'}><i class="fas fa-cloud-arrow-up"></i> Share robbery</button>
                </div>
            </div>`, 'share');
        wrapSelect($id('communityShareRobbery'), 'Search robbery...', 'Select robbery');
        wrapSelect($id('communityShareMap'), 'Search map...', 'Select map');
    }

    function renderShareResult() {
        const share = state.share;
        const item = share.result;
        openModal(`
            <div class="rcc-share-done">
                <div class="rcc-done-icon"><i class="fas fa-check"></i></div>
                <h2>Shared with every server</h2>
                <div class="rcc-share-sub">Anyone can install it from the Community tab or with this code.</div>
                <div class="rcc-codebox rcc-codebox--big">
                    <div class="rcc-code" data-rc-no-translate>${esc(item.code)}</div>
                    <div class="rcc-codebox-actions">
                        <button type="button" class="rcc-btn" data-rcc-action="done-copy-code"><i class="fas fa-copy"></i> Copy code</button>
                        <button type="button" class="rcc-btn" data-rcc-action="done-copy-link"><i class="fas fa-link"></i> Copy link</button>
                    </div>
                </div>
                <div class="rcc-row rcc-row--center">
                    <button type="button" class="rcc-btn" data-rcc-close>Close</button>
                    <button type="button" class="rcc-btn rcc-btn--primary" data-rcc-action="done-view"><i class="fas fa-eye"></i> View listing</button>
                </div>
            </div>`, 'small');
    }

    function refreshShareFooter() {
        const publish = document.querySelector('[data-rcc-action="publish"]');
        if (publish) publish.disabled = !shareReady();
    }

    function handleShareInput(event) {
        const share = state.share;
        if (!share) return;
        const id = event.target.id;
        if (id === 'communityShareTitle') {
            share.title = event.target.value;
            share.titleTouched = true;
        } else if (id === 'communityShareDescription') {
            share.description = event.target.value;
            const counter = $id('communityShareDescCount');
            if (counter) counter.textContent = `${share.description.length}/1500`;
        } else if (id === 'communityShareAuthor') {
            share.author = event.target.value;
        } else if (id === 'communityShareMapOther') {
            share.mapOther = event.target.value;
        } else if (id === 'communityShareLink') {
            share.imageLink = event.target.value.trim();
            clearTimeout(share.linkTimer);
            share.linkTimer = setTimeout(() => previewLink(share.imageLink), 450);
        }
        refreshShareFooter();
    }

    function handleShareChange(event) {
        const share = state.share;
        if (!share) return;
        const id = event.target.id;
        if (id === 'communityShareRobbery') {
            share.robberyName = event.target.value;
            if (!share.titleTouched) share.title = defaultShareTitle();
            renderShare();
        } else if (id === 'communityShareMap') {
            share.mapChoice = event.target.value;
            renderShare();
        } else if (id === 'communityShareAgree') {
            share.agree = !!event.target.checked;
            refreshShareFooter();
        }
    }

    function previewLink(url) {
        const share = state.share;
        if (!share || share.imageMode !== 'link') return;
        share.previewOk = false;
        if (!/^https?:\/\/\S+$/i.test(url || '')) {
            share.previewUrl = '';
            renderShare();
            return;
        }
        const img = new Image();
        img.onload = () => {
            if (state.share !== share || share.imageLink !== url) return;
            share.previewUrl = url;
            share.previewOk = true;
            share.image = { type: 'link', url };
            renderShare();
        };
        img.onerror = () => {
            if (state.share !== share || share.imageLink !== url) return;
            share.previewUrl = '';
            share.image = null;
            notify('That link did not load as an image. Use a direct image link.', 'error');
            renderShare();
        };
        img.src = url;
    }

    function dataUrlToImage(dataUrl) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.onload = () => resolve(img);
            img.onerror = reject;
            img.src = dataUrl;
        });
    }

    async function normalizeShot(dataUrl) {
        const img = await dataUrlToImage(dataUrl);
        const scale = Math.min(1, IMAGE_MAX_W / img.naturalWidth, IMAGE_MAX_H / img.naturalHeight);
        const width = Math.max(1, Math.round(img.naturalWidth * scale));
        const height = Math.max(1, Math.round(img.naturalHeight * scale));
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        ctx.imageSmoothingQuality = 'high';
        ctx.drawImage(img, 0, 0, width, height);
        const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.86));
        if (!blob) throw new Error('encode failed');
        return blob;
    }

    async function handleShareAction(action, btn) {
        const share = state.share;
        if (!share) return;
        if (action === 'pick-kind') {
            share.kind = btn.dataset.kind;
            if (!share.titleTouched) share.title = defaultShareTitle();
            renderShare();
            return;
        }
        if (action === 'link-mode') {
            share.imageMode = share.imageMode === 'link' ? '' : 'link';
            if (share.imageMode === 'link' && share.image && share.image.type === 'blob') {
                share.image = null;
                share.previewUrl = '';
            }
            renderShare();
            if (share.imageMode === 'link') setTimeout(() => $id('communityShareLink')?.focus(), 0);
            return;
        }
        if (action === 'clear-image') {
            share.image = null;
            share.previewUrl = '';
            share.imageLink = '';
            share.previewOk = false;
            renderShare();
            return;
        }
        if (action === 'shot') {
            const result = await nui('CommunityScreenshot');
            if (!result || !result.ok) {
                if (result && result.message) notify(result.message, 'error');
                return;
            }
            share.waitingShot = true;
            setModalHidden(true);
            return;
        }
        if (action === 'publish') {
            await publishShare();
            return;
        }
        if (action === 'done-copy-code') {
            if (copyText(share.result.code)) notify('Code copied.', 'success');
            return;
        }
        if (action === 'done-copy-link') {
            if (copyText(share.result.link)) notify('Link copied to your clipboard.', 'success');
            return;
        }
        if (action === 'done-view') {
            const code = share.result.code;
            state.share = null;
            state.tab = 'mine';
            resetFilters();
            renderTabs();
            loadList();
            openDetail(code);
        }
    }

    async function onScreenshot(message) {
        const share = state.share;
        setModalHidden(false);
        if (!share || !share.waitingShot) return;
        share.waitingShot = false;
        if (!message.ok || !message.dataUrl) {
            if (message.message) notify(message.message, 'error');
            renderShare();
            return;
        }
        try {
            const blob = await normalizeShot(message.dataUrl);
            if (share.previewUrl && share.previewUrl.startsWith('blob:')) URL.revokeObjectURL(share.previewUrl);
            share.image = { type: 'blob', blob };
            share.previewUrl = URL.createObjectURL(blob);
            share.imageMode = '';
            share.imageLink = '';
            share.previewOk = false;
        } catch (e) {
            notify('The picture could not be taken. Try again or paste an image link.', 'error');
        }
        renderShare();
    }

    function setProgress(text) {
        if (!state.share) return;
        state.share.progress = text;
        const el = $id('communityShareProgress');
        if (el) el.innerHTML = text ? `<i class="fas fa-circle-notch fa-spin"></i> <span>${esc(text)}</span>` : '';
    }

    async function uploadImage(share) {
        if (!share.image) return { ok: true, imageId: null };
        const ticket = await nui('CommunityTicket');
        if (!ticket || !ticket.ok || !ticket.ticket) return { ok: false, message: (ticket && ticket.message) || 'Could not get an upload ticket.' };
        try {
            let response;
            if (share.image.type === 'blob') {
                response = await fetch(ticket.uploadUrl, {
                    method: 'POST',
                    headers: { 'X-Upload-Ticket': ticket.ticket, 'Content-Type': share.image.blob.type || 'image/jpeg' },
                    body: share.image.blob,
                });
            } else {
                response = await fetch(ticket.fromUrlEndpoint, {
                    method: 'POST',
                    headers: { 'X-Upload-Ticket': ticket.ticket, 'Content-Type': 'application/json' },
                    body: JSON.stringify({ url: share.image.url }),
                });
            }
            const data = await response.json();
            if (!data || !data.ok) return { ok: false, message: (data && data.message) || 'The picture upload failed.' };
            return { ok: true, imageId: data.imageId };
        } catch (e) {
            return { ok: false, message: 'The picture upload failed. Check your connection and try again.' };
        }
    }

    async function publishShare() {
        const share = state.share;
        if (!shareReady()) return;
        share.busy = true;
        renderShare();
        let imageId = null;
        if (share.image) {
            setProgress('Uploading picture...');
            const upload = await uploadImage(share);
            if (state.share !== share) return;
            if (!upload.ok) {
                share.busy = false;
                setProgress('');
                notify(upload.message, 'error');
                renderShare();
                return;
            }
            imageId = upload.imageId;
        }
        setProgress('Sharing robbery...');
        const result = await nui('CommunityPublish', {
            kind: share.kind,
            robberyName: share.robberyName,
            title: String(share.title || '').trim(),
            description: String(share.description || '').trim(),
            map: shareMapValue(),
            author: String(share.author || '').trim(),
            imageId,
        });
        if (state.share !== share) return;
        share.busy = false;
        setProgress('');
        if (!result || !result.ok || !result.item) {
            notify((result && result.message) || 'Sharing failed.', 'error');
            renderShare();
            return;
        }
        share.result = result.item;
        notify('Robbery shared with the community.', 'success');
        if (share.previewUrl && share.previewUrl.startsWith('blob:')) {
            try { URL.revokeObjectURL(share.previewUrl); } catch (e) {}
            share.previewUrl = '';
        }
        renderShare();
        if (state.tab === 'mine' || state.sort === 'new') loadList();
    }

    window.addEventListener('message', (event) => {
        const data = event.data || {};
        if (data.type === 'communityScreenshot') onScreenshot(data);
        if (data.type === 'showHeistUI' && !state.holdView && Date.now() - (state.restoredAt || 0) > 1500) {
            const modal = $id('communityModal');
            if (modal && modal.style.display !== 'none' && !(state.share && state.share.waitingShot)) closeModal();
        }
    });

    window.showCommunityMenu = showCommunityMenu;
    window.hideCommunityPage = hideCommunityPage;
    window.rcCommunityOpenShare = openShare;
})();
