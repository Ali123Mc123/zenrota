// izzy-motels NUI. The Lua side sends openBuyMotelMenu / openMyMotelsMenu / openActionMenu / openInviteMenu / close
// and listens on close, rentRoom, goRoom, invitePlayer, exitRoom; names and payloads are unchanged from the original UI.
let selectedRoom = null;
let selectedColor = "white";
let moneyType = 'en-US';
let selectedDays = 1;
let costPerDay = 1000;

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'izzy-motels';
const PRESET_DAYS = [5, 20, 30, 60];
const FEATURES = ['Çift kişilik yatak', 'Küçük Depo', 'Televizyon (TV)', 'Gardırop'];

const ICON_EMPTY_ROOMS = '<svg class="p-ico" viewBox="0 0 24 24"><path d="M5 21V4.5L14 3v18"/><path d="M14 5h5v16"/><path d="M3 21h18"/></svg>';
const ICON_EMPTY_PLAYERS = '<svg class="p-ico" viewBox="0 0 24 24"><circle cx="12" cy="8" r="3.5"/><path d="M5.5 20a6.5 6.5 0 0 1 13 0"/></svg>';
const ICON_GO = '<svg class="p-ico" viewBox="0 0 24 24"><path d="M14 8V5H5v14h9v-3"/><path d="M10 12h11M18 9l3 3-3 3"/></svg>';

function post(name, payload, done) {
    $.post(`https://${resource}/${name}`, JSON.stringify(payload || {}), done);
}

function money(n) {
    return '$' + new Intl.NumberFormat(moneyType).format(Number(n) || 0);
}

function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

function initials(name) {
    return String(name || '').trim().split(/\s+/).slice(0, 2).map(w => w.charAt(0)).join('').toLocaleUpperCase('tr');
}

// The stage is drawn for 1920x1080 and scaled to fit the window, centred.
function fitStage() {
    const s = Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
    const x = (window.innerWidth - 1920 * s) / 2;
    const y = (window.innerHeight - 1080 * s) / 2;
    $('#stage').css('transform', `translate(${x}px, ${y}px) scale(${s})`);
}

function show(screen) {
    const $stage = $('#stage');
    $stage.attr('data-screen', screen);
    $('body').attr('data-screen', screen);
    requestAnimationFrame(() => $stage.addClass('open'));
}

function hide() {
    $('#stage').removeClass('open').attr('data-screen', 'none');
    $('body').attr('data-screen', 'none');
}

function setPlayer(info, mugshot) {
    info = info || {};
    $('#name').text(info.name || '');
    $('#money').text(money(info.bank));
    $('#initials').text(initials(info.name));
    $('#mugshot').attr('src', mugshot || '');
}

function setHeader(crumb, lead, stats) {
    $('#crumb').text(crumb);
    $('#lead').text(lead);
    $('#strip').html((stats || []).map(s => `
        <div class="stat"${s.tone ? ` data-tone="${s.tone}"` : ''}>
            <div class="ui-label">${s.label}</div>
            <b>${s.value}</b>
        </div>`).join(''));
}

// ---------- Rent ----------

function selectRoom(room) {
    $("#motelRoomId").text(room);
}

function handlePriceForDays(days) {
    const life = days == "Lifetime";
    $("#daysText").text(life ? '∞' : days);
    $("#daysUnit").text(life ? 'Süresiz' : 'Gün');
    $(".dayItem").attr('data-on', 'false');
    if (life) {
        $('#lifetime').attr('data-on', 'true');
    } else if (PRESET_DAYS.indexOf(days) !== -1) {
        $(`#${days}days`).attr('data-on', 'true');
    }
    $("#roomRentPrice").text(new Intl.NumberFormat(moneyType).format(life ? costPerDay * 100 : costPerDay * days));
}

function setSelected(room) {
    selectedRoom = room;
    $('.room').removeClass('on');
    if (room != null) {
        $(`.room[data-room="${room}"]`).addClass('on');
        selectRoom(room);
    }
    $('#roomSettings').attr('data-empty', room == null ? 'true' : 'false');
    $('#rentRoomBtnDiv').attr('data-dim', room == null ? 'true' : 'false');
}

// The place's own words (Lua MotelLabels): Motel at the pier, Yurt on Cayo Perico.
let labels = { brand: 'Motel', name: 'Motel', room: 'Motel Odası', place: 'Del Perro Pier', empty: '' };
function applyLabels(l) {
    if (!l) return;
    labels = Object.assign({}, labels, l);
    $('#brandName').text(labels.brand);
    $('#motelName').text(labels.name);
    $('#motelPlace').text(labels.place);
    $('.room-label').text(labels.room);
}

function openBuy(data) {
    applyLabels(data.labels);
    costPerDay = data.costPerDay;
    setPlayer(data.personalInfo, data.mugshot);

    const max = Number(data.maxRooms) || 0;
    const me = data.personalInfo && data.personalInfo.identifier;
    const taken = {};
    (data.motelData || []).forEach(r => {
        taken[r.roomId] = me && r.identifier === me ? 'own' : 'rented';
    });

    let rented = 0;
    let html = '';
    for (let i = 1; i <= max; i++) {
        const state = taken[i] || 'free';
        if (state !== 'free') rented++;
        html += `<button class="room ${state}" data-room="${i}">${i}</button>`;
    }
    $('#rooms').html(html).scrollTop(0);
    $('#maxRooms').text(max);
    $('#roomPerNight').text(money(costPerDay));

    setHeader('Oda Kirala', 'Boş bir oda seç, odanın stilini ve kalacağın süreyi belirle. Ücret banka hesabından alınır.', [
        { label: 'Gecelik', value: money(costPerDay) },
        { label: 'Boş Oda', value: max - rented, tone: 'ok' },
        { label: 'Dolu Oda', value: rented },
    ]);

    selectedDays = 1;
    selectedColor = "white";
    $('.colorItem').attr('data-on', 'false');
    $('.colorItem[data-color="white"]').attr('data-on', 'true');
    setSelected(null);
    handlePriceForDays(selectedDays);

    show('welcome');
}

$(document).on('click', '#welcome', function () {
    show('newRoom');
});

$(document).on('click', '.room.free', function () {
    setSelected(Number($(this).data('room')));
});

$(document).on('click', '.dayItem', function () {
    const time = $(this).data('time');
    selectedDays = time != "Lifetime" ? Number(time) : time;
    handlePriceForDays(selectedDays);
});

$(document).on('click', '.colorItem', function () {
    $('.colorItem').attr('data-on', 'false');
    $(this).attr('data-on', 'true');
    selectedColor = $(this).data('color');
});

$(document).on('click', '#removeDayBtn', function () {
    if (selectedDays == "Lifetime") {
        selectedDays = 60;
    } else if (selectedDays > 1) {
        selectedDays--;
    } else {
        return;
    }
    handlePriceForDays(selectedDays);
});

$(document).on('click', '#addDayBtn', function () {
    if (selectedDays == "Lifetime") return;
    selectedDays++;
    handlePriceForDays(selectedDays);
});

$(document).on('click', '#rentRoomBtnDiv', function () {
    if (selectedRoom == null) return;
    post('rentRoom', {
        room: selectedRoom,
        color: selectedColor,
        days: selectedDays == "Lifetime" ? 120 : selectedDays
    }, function (response) {
        if (response) hide();
    });
});

// ---------- My rooms ----------

function timeLeft(finishDate) {
    if (finishDate == 1000) return { text: 'Süresiz', tone: 'life' };
    const ms = finishDate * 1000 - Date.now();
    if (ms <= 0) return { text: 'Süresi doldu', tone: 'warn' };
    const days = Math.floor(ms / 86400000);
    const hours = Math.floor((ms % 86400000) / 3600000);
    return { text: days > 0 ? `${days} gün ${hours} saat` : `${hours} saat`, tone: days < 2 ? 'warn' : '' };
}

const COLOR_NAMES = { white: 'Beyaz', black: 'Siyah', gray: 'Gri', green: 'Yeşil', yellow: 'Sarı', blue: 'Mavi', purple: 'Mor', red: 'Kırmızı' };

// One room (the server allows one per player by default) gets the whole column: a big photo, the dates and how much
// of the rental is left. The rented length is not stored, so it is worked out from what was paid.
function heroCard(room, motels) {
    const left = timeLeft(room.finishDate);
    const motel = motels[room.motelId - 1] || {};
    const color = room.color || 'white';
    const life = room.finishDate == 1000;

    let pct = 100;
    let ends = 'Süresiz';
    if (!life) {
        const totalDays = costPerDay > 0 ? (Number(room.totalPaid) || 0) / costPerDay : 0;
        const remaining = Math.max(0, room.finishDate * 1000 - Date.now());
        pct = totalDays > 0 ? Math.min(100, remaining / (totalDays * 86400000) * 100) : 0;
        ends = new Date(room.finishDate * 1000).toLocaleString('tr-TR', { day: 'numeric', month: 'long', hour: '2-digit', minute: '2-digit' });
    }

    return `
    <div class="hero">
        <div class="hero-shot">
            <img src="img/${esc(color)}.png" alt="">
            <div class="no ui-display">${esc(room.roomId)}</div>
            <div class="style-tag ui-caps">${esc(COLOR_NAMES[color] || color)} Stil</div>
        </div>
        <div class="hero-body">
            <div class="ui-label kicker">Senin Odan</div>
            <div class="ui-display hero-title">Oda ${esc(room.roomId)}</div>
            <div class="motel">${esc(motel.name || 'Motel')} · <span lang="en">${esc((motel.labels && motel.labels.place) || labels.place)}</span></div>
            <div class="hero-facts">
                <div class="paid"><div class="ui-label">Ödenen</div><b>${money(room.totalPaid)}</b></div>
                <div class="left-time" data-tone="${left.tone}"><div class="ui-label">Kalan Süre</div><b>${left.text}</b></div>
                <div><div class="ui-label">Bitiş</div><b>${esc(ends)}</b></div>
            </div>
            <div class="hero-bar" data-tone="${life ? 'life' : left.tone}"><i style="width:${pct.toFixed(1)}%"></i></div>
            <div class="ui-label sec">Odada Neler Var</div>
            <div class="feats">${FEATURES.map(f => `<span>${f}</span>`).join('')}</div>
            <button class="ui-btn goRoom" data-room="${esc(room.roomId)}"><b>Odaya Git</b><span class="chev"><i></i><i></i><i></i></span></button>
        </div>
    </div>`;
}

function openMine(data) {
    applyLabels(data.labels);
    costPerDay = data.costPerDay;
    setPlayer(data.personalInfo, data.mugshot);

    const rooms = data.myRooms || [];
    const motels = data.configMotels || [];
    const paid = rooms.reduce((sum, r) => sum + (Number(r.totalPaid) || 0), 0);

    setHeader('Odalarım', 'Kiraladığın odalar ve kalan süreleri. Odana gitmek için Odaya Git butonunu kullan.', [
        { label: 'Odaların', value: rooms.length },
        { label: 'Toplam Ödenen', value: money(paid), tone: 'ok' },
    ]);

    const $list = $('#myRoomsList');
    $list.toggleClass('solo', rooms.length <= 1);

    if (!rooms.length) {
        $list.html(`
            <div class="none">
                ${ICON_EMPTY_ROOMS}
                <div class="ui-display">Henüz Odan Yok</div>
                <span>${esc(labels.empty || 'Bu motelde kiraladığın bir oda yok. Oda kiralamak için resepsiyondaki görevliyle konuş.')}</span>
            </div>`);
    } else if (rooms.length === 1) {
        $list.html(heroCard(rooms[0], motels));
    } else {
        $list.html(rooms.map(room => {
            const left = timeLeft(room.finishDate);
            const motel = motels[room.motelId - 1] || {};
            const color = esc(room.color || 'white');
            return `
            <div class="card">
                <div class="shot">
                    <img src="img/${color}.png" alt="">
                    <div class="no ui-display">${esc(room.roomId)}</div>
                </div>
                <div class="body">
                    <div class="ui-caps h">Oda ${esc(room.roomId)}</div>
                    <div class="motel">${esc(motel.name || 'Motel')}</div>
                    <div class="feats">${FEATURES.map(f => `<span>${f}</span>`).join('')}</div>
                    <div class="facts">
                        <div class="paid"><div class="ui-label">Ödenen</div><b>${money(room.totalPaid)}</b></div>
                        <div class="left-time" data-tone="${left.tone}"><div class="ui-label">Kalan Süre</div><b>${left.text}</b></div>
                    </div>
                    <button class="btn-dark goRoom" data-room="${esc(room.roomId)}">${ICON_GO}Odaya Git</button>
                </div>
            </div>`;
        }).join(''));
    }

    show('myRooms');
}

$(document).on('click', '.goRoom', function () {
    post('goRoom', { room: Number($(this).data('room')) }, function (response) {
        if (response) hide();
    });
});

// ---------- Inside the room ----------

function renderPlayers(players) {
    players = players || [];
    if (!players.length) {
        $('#playerList').html(`<div class="none">${ICON_EMPTY_PLAYERS}<span>Yakınında davet edebileceğin kimse yok.</span></div>`);
        return;
    }
    $('#playerList').html(players.map(p => `
        <div class="prow">
            <div class="ini">${esc(initials(p.name))}</div>
            <div class="pname">${esc(p.name)}</div>
            <div class="pid">#${esc(p.id)}</div>
            <button class="inviteBtn" data-id="${esc(p.id)}">Davet Et</button>
        </div>`).join(''));
}

$(document).on('click', '.inviteBtn', function () {
    const $btn = $(this);
    if ($btn.attr('data-sent') === 'true') return;
    post('invitePlayer', { id: Number($btn.data('id')) });
    $btn.attr('data-sent', 'true').text('Gönderildi');
});

$(document).on('click', '#exitRoomBtn', function () {
    post('exitRoom', {});
    hide();
});

$(document).on('click', '#inviteMenuBtn', function () {
    show('invite');
});

// Back is only shown when the invite list was reached from the action menu.
$(document).on('click', '#inviteBackBtn', function () {
    show('action');
});

// ---------- Messages ----------

$(document).ready(function () {
    fitStage();
    $(window).on('resize', fitStage);

    $(document).on('keyup', function (e) {
        if (e.key === "Escape" && $('#stage').attr('data-screen') !== 'none') {
            post('close', {});
        }
    });

    window.addEventListener('message', function (event) {
        const data = event.data;
        switch (data.action) {
            case 'openBuyMotelMenu':
                openBuy(data);
                break;
            case 'openMyMotelsMenu':
                openMine(data);
                break;
            case 'openActionMenu':
                applyLabels(data.labels);
                $('#inviteBackBtn').show();
                renderPlayers(data.players);
                show('action');
                break;
            case 'openInviteMenu':
                applyLabels(data.labels);
                $('#inviteBackBtn').hide();
                renderPlayers(data.players);
                show('invite');
                break;
            case 'close':
                hide();
                break;
        }
    });
});
