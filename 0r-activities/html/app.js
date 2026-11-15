(() => {
    'use strict';

    const hud = document.getElementById('cablecar');
    const status = document.getElementById('status');
    const detail = document.getElementById('detail');
    const controls = document.getElementById('controls');
    const controlsTitle = document.getElementById('controls-title');
    const controlsList = document.getElementById('controls-list');
    const queueHud = document.getElementById('queue-hud');
    const queueTitle = document.getElementById('queue-title');
    const queuePosition = document.getElementById('queue-position');
    const queueCountdown = document.getElementById('queue-countdown');
    const queueKey = document.getElementById('queue-key');
    const queueAction = document.getElementById('queue-action');
    const queueActionPanel = queueHud.querySelector('.queue-action');
    const queueStandings = document.getElementById('queue-standings');
    const queueSeconds = document.getElementById('queue-seconds');
    const lobby = document.getElementById('lobby');
    const lobbyTitle = document.getElementById('lobby-title');
    const lobbySubtitle = document.getElementById('lobby-subtitle');
    const lobbyDescription = document.getElementById('lobby-description');
    const lobbyStatus = document.getElementById('lobby-status');
    const lobbyCountdown = document.getElementById('lobby-countdown');
    const lobbyProgress = document.getElementById('lobby-progress');
    const lobbyProgressBar = lobbyProgress.querySelector('i');
    const lobbyPlayers = document.getElementById('lobby-players');
    const lobbyPlayersLabel = document.getElementById('lobby-players-label');
    const lobbyPrimary = document.getElementById('lobby-primary');
    const lobbySecondary = document.getElementById('lobby-secondary');
    const lobbyExtraOptions = document.getElementById('lobby-extra-options');
    const lobbyBack = document.getElementById('lobby-back');
    const multiplayerView = document.getElementById('lobby-multiplayer-view');
    const multiplayerList = document.getElementById('multiplayer-list');
    const multiplayerGroup = document.getElementById('multiplayer-group');
    const multiplayerGroupLabel = document.getElementById('multiplayer-group-label');
    const multiplayerNearbyLabel = document.getElementById('multiplayer-nearby-label');
    const multiplayerBack = document.getElementById('multiplayer-back');
    const multiplayerPrimary = document.getElementById('multiplayer-primary');
    const invitation = document.getElementById('invitation');
    const invitationTitle = document.getElementById('invitation-title');
    const invitationMessage = document.getElementById('invitation-message');
    const invitationTime = document.getElementById('invitation-time');
    const invitationProgress = document.getElementById('invitation-progress');
    const invitationAccept = document.getElementById('invitation-accept');
    const invitationReject = document.getElementById('invitation-reject');
    let selectedOption = 0;
    let selectedMultiplayerOption = 0;
    let selectedInvitationOption = 0;
    let invitationToken = 0;
    let invitationEndsAt = 0;
    let invitationDuration = 0;
    let invitationTimer = 0;
    let invitationResponding = false;
    let groupMembers = [];
    let groupCanSelectDriver = false;
    let groupDriverRequired = false;
    let invitedPlayers = new Set();
    let countdownTotal = 0;
    let countdownLast = 0;

    const post = (name, data = {}) => fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data)
    }).then(async (response) => {
        if (!response.ok) return { ok: false };
        try { return await response.json(); } catch (_) { return { ok: true }; }
    }).catch(() => ({ ok: false }));

    const titleCase = (text) => {
        const lang = document.documentElement.lang || undefined;
        const value = String(text);
        if (lang && lang !== 'en' && lang !== 'tr') return value;
        const allCaps = value === value.toLocaleUpperCase(lang);
        return value.split(' ').map((word) => {
            if (/\d/.test(word) || (!allCaps && word.length <= 3 && word === word.toLocaleUpperCase(lang))) return word;
            const lower = word.toLocaleLowerCase(lang);
            return lower.charAt(0).toLocaleUpperCase(lang) + lower.slice(1);
        }).join(' ');
    };

    const visibleOptions = () => [lobbyPrimary, lobbySecondary,
        ...lobbyExtraOptions.querySelectorAll('button'), lobbyBack, ...lobbyPlayers.querySelectorAll('.driver-select')]
        .filter((button) => !button.hidden && !button.disabled);

    const selectOption = (index) => {
        const options = visibleOptions();
        if (options.length === 0) return;
        selectedOption = (index + options.length) % options.length;
        options.forEach((button, buttonIndex) => {
            const selected = buttonIndex === selectedOption;
            button.classList.toggle('selected', selected);
            button.setAttribute('aria-selected', String(selected));
        });
    };

    const multiplayerOptions = () => [multiplayerPrimary, multiplayerBack, ...multiplayerGroup.querySelectorAll('.driver-select'),
        ...multiplayerList.querySelectorAll('button')]
        .filter((button) => !button.hidden && !button.disabled);

    const selectMultiplayerOption = (index) => {
        const options = multiplayerOptions();
        if (options.length === 0) return;
        selectedMultiplayerOption = (index + options.length) % options.length;
        multiplayerView.querySelectorAll('.focused').forEach((button) => button.classList.remove('focused'));
        options[selectedMultiplayerOption].classList.add('focused');
    };

    const invitePlayer = async (playerId) => {
        if (invitedPlayers.has(playerId)) return;
        const result = await post('lobby:groupStart', { players: [playerId] });
        if (result && result.close) showMainLobby();
    };

    const updateInvitedPlayers = () => {
        multiplayerList.querySelectorAll('button').forEach((button) => {
            const invited = invitedPlayers.has(Number(button.dataset.playerId));
            button.classList.toggle('invited', invited);
            if (invited) button.classList.remove('focused');
            button.disabled = invited;
            button.querySelector('span').textContent = invited ? '' : button.dataset.distance;
        });
        if (lobby.classList.contains('multiplayer-open')) {
            selectMultiplayerOption(Math.min(selectedMultiplayerOption, multiplayerOptions().length - 1));
        }
    };

    const fillMemberRow = (row, player, index, onHover) => {
        row.replaceChildren();
        row.className = '';
        const member = player && typeof player === 'object' ? player : { name: player };
        const name = document.createElement('span');
        name.className = 'lobby-member-name';
        name.textContent = `${index + 1}. ${String(member.name || `${window.ActivityLocale.player()} ${member.id || index + 1}`)}`;
        row.append(name);
        if (member.leader || (groupDriverRequired && member.driver)) {
            const badges = document.createElement('span');
            badges.className = 'member-badges';
            if (member.role) badges.title = String(member.role);
            if (member.leader) badges.append(Object.assign(document.createElement('i'), { className: 'badge-leader' }));
            if (groupDriverRequired && member.driver) badges.append(Object.assign(document.createElement('i'), { className: 'badge-driver' }));
            row.append(badges);
        }
        if (groupCanSelectDriver && member.id) {
            const driver = document.createElement('button');
            driver.type = 'button';
            driver.className = `driver-select${member.driver ? ' is-driver' : ''}`;
            driver.dataset.memberId = row.dataset.memberId;
            driver.append(...row.childNodes);
            driver.addEventListener('click', () => {
                if (!member.driver) post('lobby:setDriver', { player: Number(member.id) });
            });
            driver.addEventListener('mouseenter', () => onHover(driver));
            row.append(driver);
            row.classList.add('has-driver-select');
        }
    };

    const renderMembers = (list, onHover) => {
        const existing = new Map([...list.children].map((row) => [row.dataset.memberId, row]));
        list.replaceChildren(...groupMembers.map((player, index) => {
            const key = String((player && player.id) || `index-${index}`);
            const row = existing.get(key) || document.createElement('li');
            row.dataset.memberId = key;
            fillMemberRow(row, player, index, onHover);
            return row;
        }));
    };

    const syncMultiplayerPrimary = () => {
        multiplayerPrimary.textContent = lobbyPrimary.textContent;
        multiplayerPrimary.hidden = lobbyPrimary.hidden || groupMembers.length === 0;
    };

    const renderGroup = () => {
        const empty = groupMembers.length === 0;
        renderMembers(lobbyPlayers, (button) => selectOption(visibleOptions().indexOf(button)));
        renderMembers(multiplayerGroup, (button) => selectMultiplayerOption(multiplayerOptions().indexOf(button)));
        lobbyPlayers.hidden = empty;
        lobbyPlayersLabel.hidden = empty;
        multiplayerGroup.hidden = empty;
        multiplayerGroupLabel.hidden = empty;
        lobby.classList.toggle('has-members', !empty);
        if (lobby.classList.contains('multiplayer-open')) {
            selectMultiplayerOption(Math.min(selectedMultiplayerOption, multiplayerOptions().length - 1));
        }
    };

    const showMainLobby = () => {
        lobby.classList.remove('multiplayer-open');
        multiplayerView.setAttribute('aria-hidden', 'true');
        selectOption(0);
    };

    const invitationOptions = () => [invitationAccept, invitationReject]
        .filter((button) => !button.disabled);

    const selectInvitationOption = (index) => {
        const options = invitationOptions();
        if (options.length === 0) return;
        selectedInvitationOption = (index + options.length) % options.length;
        options.forEach((button, buttonIndex) => {
            const selected = buttonIndex === selectedInvitationOption;
            button.classList.toggle('selected', selected);
            button.setAttribute('aria-selected', String(selected));
        });
    };

    const stopInvitationTimer = () => {
        if (invitationTimer) window.clearInterval(invitationTimer);
        invitationTimer = 0;
    };

    const updateInvitationTimer = () => {
        const remaining = Math.max(0, invitationEndsAt - Date.now());
        const seconds = Math.ceil(remaining / 1000);
        const minutes = Math.floor(seconds / 60);
        invitationTime.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;
        const ratio = invitationDuration > 0 ? Math.max(0, Math.min(1, remaining / invitationDuration)) : 0;
        invitationProgress.style.transform = `scaleX(${ratio})`;
        if (remaining <= 0) stopInvitationTimer();
    };

    const openInvitation = (data) => {
        const timeout = Math.max(1, Math.min(120, Number(data.timeout) || 20));
        invitationToken = Number(data.token) || 0;
        invitationDuration = timeout * 1000;
        invitationEndsAt = Date.now() + invitationDuration;
        invitationResponding = false;
        invitationTitle.textContent = titleCase(data.title || window.ActivityLocale.activity_invitation());
        invitationMessage.textContent = String(data.message || window.ActivityLocale.do_you_want_to_participate_in_this_activity());
        invitationAccept.disabled = false;
        invitationReject.disabled = false;
        invitation.classList.remove('responding');
        invitation.classList.add('visible');
        invitation.setAttribute('aria-hidden', 'false');
        lobby.classList.add('invitation-covered');
        selectedInvitationOption = 0;
        selectInvitationOption(0);
        stopInvitationTimer();
        updateInvitationTimer();
        invitationTimer = window.setInterval(updateInvitationTimer, 250);
    };

    const closeInvitation = (token) => {
        if (token && invitationToken && Number(token) !== invitationToken) return;
        stopInvitationTimer();
        invitationToken = 0;
        invitationResponding = false;
        invitationAccept.disabled = false;
        invitationReject.disabled = false;
        invitation.classList.remove('visible', 'responding');
        invitation.setAttribute('aria-hidden', 'true');
        lobby.classList.remove('invitation-covered');
    };

    const respondInvitation = async (accepted) => {
        if (invitationResponding || !invitation.classList.contains('visible')) return;
        const token = invitationToken;
        invitationResponding = true;
        invitationAccept.disabled = true;
        invitationReject.disabled = true;
        invitation.classList.add('responding');
        const result = await post('invitation:respond', { accepted: accepted === true, token });
        if (result && result.ok !== false) return;
        if (!invitation.classList.contains('visible') || token !== invitationToken) return;
        invitationResponding = false;
        invitationAccept.disabled = false;
        invitationReject.disabled = false;
        invitation.classList.remove('responding');
        selectInvitationOption(selectedInvitationOption);
    };

    let lobbyKeys = new Set();

    const renderLobbyOptions = (options) => {
        const list = Array.isArray(options) ? options : [];
        lobbyExtraOptions.replaceChildren(...list.map((option) => {
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'activity-option';
            button.textContent = String(option.label || option.title || window.ActivityLocale.selective());
            button.dataset.option = String(option.id || '');
            button.addEventListener('click', () => post('lobby:option', { id: option.id }));
            button.addEventListener('mouseenter', () => selectOption(visibleOptions().indexOf(button)));
            return button;
        }));
    };

    const renderMultiplayerPlayers = (players) => {
        const list = Array.isArray(players) ? players : [];
        const existing = new Map([...multiplayerList.querySelectorAll('button')]
            .map((button) => [Number(button.dataset.playerId), button]));
        const present = new Set(list.map((player) => Number(player.id) || 0));
        const focused = multiplayerOptions()[selectedMultiplayerOption];
        const focusedPlayer = focused && focused.dataset.playerId
            ? Number(focused.dataset.playerId) : null;
        const nodes = list.map((player, index) => {
            const playerId = Number(player.id) || 0;
            let button = existing.get(playerId);
            if (!button) {
                button = document.createElement('button');
                button.type = 'button';
                button.className = 'multiplayer-player';
                button.dataset.playerId = String(playerId);
                button.append(document.createElement('strong'), document.createElement('span'));
                button.addEventListener('click', () => invitePlayer(Number(button.dataset.playerId)));
                button.addEventListener('mouseenter', () => {
                    const options = multiplayerOptions();
                    selectMultiplayerOption(options.indexOf(button));
                });
            }
            button.style.setProperty('--row-index', String(index));
            button.querySelector('strong').textContent = String(player.name || `${window.ActivityLocale.player()} ${player.id}`);
            button.dataset.distance = `${Number(player.distance || 0).toFixed(1)} m`;
            return button;
        });
        [...multiplayerList.querySelectorAll('button')].forEach((button) => {
            if (!present.has(Number(button.dataset.playerId))) button.remove();
        });
        nodes.forEach((button, index) => {
            const current = multiplayerList.children[index];
            if (current !== button) multiplayerList.insertBefore(button, current || null);
        });
        multiplayerNearbyLabel.hidden = list.length === 0;
        updateInvitedPlayers();
        if (focusedPlayer !== null) {
            const focusedIndex = multiplayerOptions().findIndex((button) =>
                Number(button.dataset.playerId) === focusedPlayer);
            if (focusedIndex >= 0) selectMultiplayerOption(focusedIndex);
        }
    };

    const applyMultiplayer = (data) => {
        selectedMultiplayerOption = 0;
        renderMultiplayerPlayers(data.players);
        lobby.classList.add('multiplayer-open');
        multiplayerView.setAttribute('aria-hidden', 'false');
        selectMultiplayerOption(0);
    };

    const optionKey = (element) => {
        if (!element) return null;
        if (element.id) return element.id;
        if (element.dataset.memberId) return `member:${element.dataset.memberId}`;
        if (element.dataset.playerId) return `player:${element.dataset.playerId}`;
        if (element.dataset.option) return `option:${element.dataset.option}`;
        return null;
    };

    const layoutTargets = () => [...lobby.querySelectorAll(
        '.activity-identity, .activity-copy, .activity-option, .player-section, .lobby-players li, .multiplayer-player')]
        .filter((element) => element.getClientRects().length !== 0);

    const smoothUpdate = (update) => {
        if (!lobby.classList.contains('visible')) {
            update();
            return;
        }
        const mainKey = optionKey(visibleOptions()[selectedOption]);
        const multiplayerKey = optionKey(multiplayerOptions()[selectedMultiplayerOption]);
        const before = new Map(layoutTargets().map((element) => [element, element.getBoundingClientRect()]));
        update();
        const mainIndex = visibleOptions().findIndex((element) => optionKey(element) === mainKey);
        if (mainIndex >= 0) selectOption(mainIndex);
        const multiplayerIndex = multiplayerOptions().findIndex((element) => optionKey(element) === multiplayerKey);
        if (multiplayerIndex >= 0) selectMultiplayerOption(multiplayerIndex);
        layoutTargets().forEach((element) => {
            const previous = before.get(element);
            if (!previous) {
                element.animate([{ opacity: 0, transform: 'translateY(6px)' }, { opacity: 1, transform: 'none' }],
                    { duration: 200, easing: 'ease-out' });
                return;
            }
            const next = element.getBoundingClientRect();
            const dx = previous.left - next.left;
            const dy = previous.top - next.top;
            if (Math.abs(dx) < 1 && Math.abs(dy) < 1) return;
            element.animate([{ transform: `translate(${dx}px, ${dy}px)` }, { transform: 'none' }],
                { duration: 240, easing: 'cubic-bezier(0.2, 0.7, 0.2, 1)' });
        });
    };

    const applyCountdown = (value) => {
        const remaining = Math.max(0, Math.floor(Number(value) || 0));
        lobbyCountdown.hidden = remaining === 0;
        lobbyProgress.hidden = remaining === 0;
        if (remaining === 0) {
            countdownTotal = 0;
            countdownLast = 0;
            return;
        }
        if (remaining > countdownLast) countdownTotal = remaining;
        countdownLast = remaining;
        lobbyCountdown.textContent = `${String(Math.floor(remaining / 60)).padStart(2, '0')}:${String(remaining % 60).padStart(2, '0')}`;
        lobbyProgressBar.style.transform = `scaleX(${remaining / countdownTotal})`;
    };

    const applyLobby = (data) => {
        if (data.title !== undefined) lobbyTitle.textContent = titleCase(data.title || window.ActivityLocale.activity_2());
        if (data.subtitle !== undefined) lobbySubtitle.textContent = String(data.subtitle || window.ActivityLocale.activity());
        if (data.description !== undefined) lobbyDescription.textContent = String(data.description || '');
        if (data.status !== undefined) lobbyStatus.textContent = String(data.status || '');
        if (data.countdown !== undefined) applyCountdown(data.countdown);
        if (data.players !== undefined) {
            groupMembers = Array.isArray(data.players) ? data.players : [];
            groupCanSelectDriver = data.canSelectDriver === true;
            groupDriverRequired = data.driverRequired === true;
            renderGroup();
        }
        if (data.invited !== undefined) {
            invitedPlayers = new Set((Array.isArray(data.invited) ? data.invited : []).map(Number));
            updateInvitedPlayers();
        }
        if (data.multiplayer === false) renderMultiplayerPlayers([]);
        if (data.primary !== undefined) {
            lobbyPrimary.textContent = String(data.primary || window.ActivityLocale.start_activity());
            lobbyPrimary.hidden = !data.primary;
        }
        if (data.secondary !== undefined) {
            lobbySecondary.textContent = String(data.secondary || '');
            lobbySecondary.hidden = !data.secondary;
        }
        if (data.options !== undefined) renderLobbyOptions(data.options);
        if (data.back !== undefined) {
            lobbyBack.textContent = String(data.back || window.ActivityLocale.back_option());
            lobbyBack.classList.toggle('cancel', Boolean(data.back));
        }
        if (data.keys !== undefined) lobbyKeys = new Set((Array.isArray(data.keys) ? data.keys : []).map((key) => String(key).toLowerCase()));
        syncMultiplayerPrimary();
        if (lobby.classList.contains('multiplayer-open')) {
            selectMultiplayerOption(Math.min(selectedMultiplayerOption, multiplayerOptions().length - 1));
        }
        selectOption(0);
    };

    document.getElementById('lobby-close').addEventListener('click', () => post('lobby:close'));
    lobbyPrimary.addEventListener('click', () => post('lobby:primary'));
    lobbySecondary.addEventListener('click', () => post('lobby:secondary'));
    lobbyBack.addEventListener('click', () => post('lobby:close'));
    multiplayerPrimary.addEventListener('click', () => post('lobby:primary'));
    multiplayerPrimary.addEventListener('mouseenter', () => selectMultiplayerOption(multiplayerOptions().indexOf(multiplayerPrimary)));
    lobbyBack.addEventListener('mouseenter', () => selectOption(visibleOptions().indexOf(lobbyBack)));
    multiplayerBack.addEventListener('click', () => {
        post('lobby:multiplayerClosed');
        showMainLobby();
    });
    multiplayerBack.addEventListener('mouseenter', () => selectMultiplayerOption(multiplayerOptions().indexOf(multiplayerBack)));
    invitationAccept.addEventListener('click', () => respondInvitation(true));
    invitationReject.addEventListener('click', () => respondInvitation(false));
    invitationAccept.addEventListener('mouseenter', () => selectInvitationOption(0));
    invitationReject.addEventListener('mouseenter', () => selectInvitationOption(1));
    lobbyPrimary.addEventListener('mouseenter', () => selectOption(visibleOptions().indexOf(lobbyPrimary)));
    lobbySecondary.addEventListener('mouseenter', () => selectOption(visibleOptions().indexOf(lobbySecondary)));
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Tab') {
            event.preventDefault();
            return;
        }
        if (invitation.classList.contains('visible')) {
            if (event.key === 'Escape') {
                event.preventDefault();
                respondInvitation(false);
            } else if (event.key === 'ArrowLeft' || event.key === 'ArrowUp'
                || event.key.toLowerCase() === 'a' || event.key.toLowerCase() === 'w') {
                event.preventDefault();
                selectInvitationOption(selectedInvitationOption - 1);
            } else if (event.key === 'ArrowRight' || event.key === 'ArrowDown'
                || event.key.toLowerCase() === 'd' || event.key.toLowerCase() === 's') {
                event.preventDefault();
                selectInvitationOption(selectedInvitationOption + 1);
            } else if (event.key === 'Enter') {
                event.preventDefault();
                const option = invitationOptions()[selectedInvitationOption];
                if (option) option.click();
            }
            return;
        }
        if (!lobby.classList.contains('visible')) return;
        if (lobby.classList.contains('multiplayer-open')) {
            if (event.key === 'Escape' || event.key === 'Backspace') {
                event.preventDefault();
                post('lobby:multiplayerClosed');
                showMainLobby();
                return;
            }
            if (!event.repeat && lobbyKeys.has(event.key.toLowerCase())) {
                event.preventDefault();
                post('lobby:key', { key: event.key.toLowerCase() });
                return;
            }
            if (event.key === 'ArrowUp' || event.key === 'ArrowLeft' || event.key.toLowerCase() === 'w') {
                event.preventDefault();
                selectMultiplayerOption(selectedMultiplayerOption - 1);
                return;
            }
            if (event.key === 'ArrowDown' || event.key === 'ArrowRight' || event.key.toLowerCase() === 's') {
                event.preventDefault();
                selectMultiplayerOption(selectedMultiplayerOption + 1);
                return;
            }
            if (event.key === 'Enter') {
                event.preventDefault();
                const option = multiplayerOptions()[selectedMultiplayerOption];
                if (option) option.click();
            }
            return;
        }
        if (event.key === 'Escape' || event.key === 'Backspace') {
            event.preventDefault();
            post('lobby:close');
            return;
        }
        if (!event.repeat && lobbyKeys.has(event.key.toLowerCase())) {
            event.preventDefault();
            post('lobby:key', { key: event.key.toLowerCase() });
            return;
        }
        if (event.key === 'ArrowUp' || event.key === 'ArrowLeft' || event.key.toLowerCase() === 'w') {
            event.preventDefault();
            selectOption(selectedOption - 1);
            return;
        }
        if (event.key === 'ArrowDown' || event.key === 'ArrowRight' || event.key.toLowerCase() === 's') {
            event.preventDefault();
            selectOption(selectedOption + 1);
            return;
        }
        if (event.key === 'Enter') {
            event.preventDefault();
            const option = visibleOptions()[selectedOption];
            if (option) option.click();
        }
    });

    window.addEventListener('message', (event) => {
        const message = event.data || {};
        if (message.action === 'controls:hide') {
            controls.classList.remove('visible');
            controls.setAttribute('aria-hidden', 'true');
            return;
        }
        if (message.action === 'controls:update') {
            const data = message.data || {};
            controlsTitle.textContent = String(data.title || '');
            controlsList.replaceChildren(...(data.controls || []).map((item) => {
                const row = document.createElement('span');
                const text = String(item.key || '').trim();
                const arrows = text.split(/\s+/);
                if (arrows.length > 1 && arrows.every((part) => part === '←' || part === '→')) {
                    row.append(...arrows.map((part) => {
                        const key = document.createElement('kbd');
                        key.className = 'arrow-key';
                        key.dataset.arrow = part === '←' ? 'left' : 'right';
                        key.setAttribute('aria-label', part);
                        return key;
                    }), document.createTextNode(String(item.label || '')));
                    return row;
                }
                const key = document.createElement('kbd');
                key.textContent = /^w[\s/]*a[\s/]*s[\s/]*d$/i.test(text) ? 'W/S' : text;
                row.append(key, document.createTextNode(String(item.label || '')));
                return row;
            }));
            controls.classList.add('visible');
            controls.setAttribute('aria-hidden', 'false');
            return;
        }
        if (message.action === 'queue:hide') {
            queueStandings.textContent = '';
            queueStandings.hidden = true;
            queueHud.classList.remove('visible');
            queueHud.setAttribute('aria-hidden', 'true');
            return;
        }
        if (message.action === 'queue:update') {
            const data = message.data || {};
            queueTitle.textContent = String(data.title || window.ActivityLocale.roller_coaster_queue());
            queuePosition.textContent = String(data.position || window.ActivityLocale.position_1());
            queueCountdown.textContent = String(data.countdown || '');
            const seconds = Number(data.seconds);
            const hasSeconds = Number.isFinite(seconds) && seconds >= 0;
            queueSeconds.textContent = hasSeconds ? String(Math.floor(seconds)) : '';
            queueSeconds.hidden = !hasSeconds;
            queueHud.classList.toggle('has-seconds', hasSeconds);
            queueKey.textContent = String(data.key || 'F');
            queueAction.textContent = String(data.action || window.ActivityLocale.leave_queue_2());
            queueActionPanel.hidden = data.hideAction === true;
            const standings = Array.isArray(data.standings) ? data.standings : [];
            queueStandings.textContent = standings.map((row, index) =>
                `${index + 1}. ${String(row.name || window.ActivityLocale.player())} · ${Number(row.score) || 0}`).join('  /  ');
            queueStandings.hidden = standings.length === 0;
            queueHud.classList.add('visible');
            queueHud.setAttribute('aria-hidden', 'false');
            return;
        }
        if (message.action === 'lobby:close') {
            showMainLobby();
            lobby.classList.remove('visible');
            lobby.setAttribute('aria-hidden', 'true');
            return;
        }
        if (message.action === 'invitation:open') {
            openInvitation(message.data || {});
            return;
        }
        if (message.action === 'invitation:close') {
            closeInvitation(message.token);
            return;
        }
        if (message.action === 'lobby:multiplayer') {
            applyMultiplayer(message.data || {});
            return;
        }
        if (message.action === 'lobby:multiplayerPlayers') {
            smoothUpdate(() => renderMultiplayerPlayers((message.data || {}).players));
            return;
        }
        if (message.action === 'lobby:open' || message.action === 'lobby:update') {
            if (message.action === 'lobby:open') {
                showMainLobby();
                applyCountdown(0);
                applyLobby(message.data || {});
            } else {
                smoothUpdate(() => applyLobby(message.data || {}));
            }
            lobby.classList.add('visible');
            lobby.setAttribute('aria-hidden', 'false');
            return;
        }
        if (message.action === 'cablecar:hide') {
            hud.classList.remove('visible');
            hud.setAttribute('aria-hidden', 'true');
            return;
        }
        if (message.action !== 'cablecar:update') return;

        const data = message.data || {};
        status.textContent = String(data.status || window.ActivityLocale.getting_information());
        detail.textContent = String(data.detail || '');
        hud.classList.remove('ready', 'travel');
        hud.classList.add(data.tone === 'ready' ? 'ready' : 'travel', 'visible');
        hud.setAttribute('aria-hidden', 'false');
    });
})();
