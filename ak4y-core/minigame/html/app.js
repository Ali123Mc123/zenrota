let hackGameState = 'LOADING';
let hackGridData = [];
let hackTargetSequence = [];
let hackCurrentInputSequence = [];
let hackCanClick = false;
let hackTimerInterval = null;
let hackTimeRemaining = 0;
const HACK_GRID_SIZE = 7;
const HACK_SEQUENCE_LENGTH = 5;
const HACK_SYMBOLS = ['@', '#', '$', '%', '&', '*', '!', '?', '+', '-', '~', '^'];
const HACK_REVEAL_DURATION = 1000;
const HACK_ERROR_FLASH_DURATION = 500;
const HACK_TIME_LIMIT = 30; // seconds

// Audio context for sound effects
let hackAudioContext = null;

function initHackAudioContext() {
	if (!hackAudioContext) {
		try {
			hackAudioContext = new (window.AudioContext || window.webkitAudioContext)();
		} catch (e) {
			console.warn('Web Audio API not supported');
		}
	}
}

function playHackSound(frequency, duration, type = 'sine', volume = 0.3) {
	if (!hackAudioContext) {
		initHackAudioContext();
	}
	if (!hackAudioContext) return;
	
	try {
		const oscillator = hackAudioContext.createOscillator();
		const gainNode = hackAudioContext.createGain();
		
		oscillator.connect(gainNode);
		gainNode.connect(hackAudioContext.destination);
		
		oscillator.frequency.value = frequency;
		oscillator.type = type;
		
		gainNode.gain.setValueAtTime(volume, hackAudioContext.currentTime);
		gainNode.gain.exponentialRampToValueAtTime(0.01, hackAudioContext.currentTime + duration);
		
		oscillator.start(hackAudioContext.currentTime);
		oscillator.stop(hackAudioContext.currentTime + duration);
	} catch (e) {
		console.warn('Error playing sound:', e);
	}
}

function playCorrectSound() {
	// Yüksek frekanslı, kısa, pozitif beep
	playHackSound(800, 0.1, 'sine', 0.2);
	setTimeout(() => {
		playHackSound(1000, 0.1, 'sine', 0.2);
	}, 50);
}

function playWrongSound() {
	// Düşük frekanslı, kısa, negatif error beep
	playHackSound(200, 0.15, 'sawtooth', 0.25);
	setTimeout(() => {
		playHackSound(150, 0.15, 'sawtooth', 0.25);
	}, 100);
}

function playFailSound() {
	// Uzun, düşük frekanslı başarısızlık sesi
	playHackSound(150, 0.3, 'sawtooth', 0.3);
	setTimeout(() => {
		playHackSound(100, 0.4, 'sawtooth', 0.3);
	}, 200);
	setTimeout(() => {
		playHackSound(80, 0.5, 'sawtooth', 0.3);
	}, 500);
}

function playSuccessSound() {
	// Yükselen, pozitif başarı melodisi
	playHackSound(523, 0.1, 'sine', 0.2); // C
	setTimeout(() => {
		playHackSound(659, 0.1, 'sine', 0.2); // E
	}, 100);
	setTimeout(() => {
		playHackSound(784, 0.2, 'sine', 0.25); // G
	}, 200);
}

function playTypingSound() {
	// Gerçekçi klavye/daktilo sesi - white noise + ton karışımı
	if (!hackAudioContext) {
		initHackAudioContext();
	}
	if (!hackAudioContext) return;
	
	try {
		const duration = 0.05; // 50ms
		const now = hackAudioContext.currentTime;
		
		// Ana ton - daktilo tuş sesi
		const osc1 = hackAudioContext.createOscillator();
		const gain1 = hackAudioContext.createGain();
		osc1.type = 'square';
		osc1.frequency.value = 800 + Math.random() * 400; // 800-1200 Hz
		osc1.connect(gain1);
		gain1.connect(hackAudioContext.destination);
		gain1.gain.setValueAtTime(0.15, now);
		gain1.gain.exponentialRampToValueAtTime(0.01, now + duration);
		osc1.start(now);
		osc1.stop(now + duration);
		
		// İkinci ton - daha yüksek frekans (tıklama sesi)
		const osc2 = hackAudioContext.createOscillator();
		const gain2 = hackAudioContext.createGain();
		osc2.type = 'sawtooth';
		osc2.frequency.value = 2000 + Math.random() * 500; // 2000-2500 Hz
		osc2.connect(gain2);
		gain2.connect(hackAudioContext.destination);
		gain2.gain.setValueAtTime(0.08, now);
		gain2.gain.exponentialRampToValueAtTime(0.01, now + duration * 0.7);
		osc2.start(now);
		osc2.stop(now + duration * 0.7);
		
		// White noise - mekanik gürültü efekti
		const bufferSize = hackAudioContext.sampleRate * duration;
		const buffer = hackAudioContext.createBuffer(1, bufferSize, hackAudioContext.sampleRate);
		const data = buffer.getChannelData(0);
		for (let i = 0; i < bufferSize; i++) {
			data[i] = Math.random() * 2 - 1; // -1 ile 1 arası rastgele
		}
		const noise = hackAudioContext.createBufferSource();
		const noiseGain = hackAudioContext.createGain();
		noise.buffer = buffer;
		noise.connect(noiseGain);
		noiseGain.connect(hackAudioContext.destination);
		noiseGain.gain.setValueAtTime(0.05, now);
		noiseGain.gain.exponentialRampToValueAtTime(0.01, now + duration * 0.5);
		noise.start(now);
		noise.stop(now + duration * 0.5);
	} catch (e) {
		console.warn('Error playing typing sound:', e);
	}
}

const hackLoadingMessages = [
	"Bağlantı protokolleri başlatılıyor...",
	"Birincil güvenlik duvarı aşılıyor...",
	"Şifreleme anahtarları doğrulanıyor...",
	"Güvenli düğümler üzerinden yönlendiriliyor [DÜĞÜM 1: OK] [DÜĞÜM 2: OK] [DÜĞÜM 3: OK]...",
	"Ana sisteme erişiliyor...",
	"Arayüz matrisi çözülüyor...",
	"Görüntü akışı kuruluyor...",
	"Sistem hazır. Dizi çözümü bekleniyor.",
];

function typeHackLoadingText(messages, index = 0, charIndex = 0) {
	const loadingTextElement = document.getElementById('loading-text');
	const progressBarElement = document.getElementById('progress-bar');
	const loadingStatusElement = document.getElementById('loading-status');
	const loadingScreen = document.getElementById('loading-screen');
	const gameScreen = document.getElementById('game-screen');
	
	if (index >= messages.length) {
		progressBarElement.style.width = '100%';
		loadingStatusElement.textContent = "Bağlantı kuruldu. Hazır.";
		setTimeout(() => {
			loadingScreen.classList.add('hidden');
			gameScreen.classList.remove('hidden');
			startHackGame();
		}, 500);
		return;
	}

	const message = messages[index];
	if (charIndex < message.length) {
		const char = message[charIndex];
		loadingTextElement.textContent += char;
		loadingTextElement.scrollTop = loadingTextElement.scrollHeight;
		
		// Boşluk ve yeni satır karakterlerinde ses çalma
		if (char !== ' ' && char !== '\n') {
			playTypingSound();
		}
		
		setTimeout(() => typeHackLoadingText(messages, index, charIndex + 1), 30);
	} else {
		loadingTextElement.textContent += '\n';
		const progress = Math.round(((index + 1) / messages.length) * 100);
		progressBarElement.style.width = progress + '%';
		loadingStatusElement.textContent = messages[index];
		if (index === messages.length - 1) {
			loadingStatusElement.textContent = "Arayüz tamamlanıyor...";
		}
		setTimeout(() => typeHackLoadingText(messages, index + 1, 0), 200);
	}
}

function getHackRandomSymbol() {
	return HACK_SYMBOLS[Math.floor(Math.random() * HACK_SYMBOLS.length)];
}

function generateHackTargetSequence() {
	hackTargetSequence = [];
	while (hackTargetSequence.length < HACK_SEQUENCE_LENGTH) {
		hackTargetSequence.push(getHackRandomSymbol());
	}
	const targetSequenceElement = document.getElementById('target-sequence');
	if (targetSequenceElement) {
		targetSequenceElement.textContent = `[ ${hackTargetSequence.join(' ')} ]`;
	}
}

function generateHackGridData() {
	hackGridData = [];
	for (let r = 0; r < HACK_GRID_SIZE; r++) {
		const row = [];
		for (let c = 0; c < HACK_GRID_SIZE; c++) {
			row.push(getHackRandomSymbol());
		}
		hackGridData.push(row);
	}

	let placed = false;
	while (!placed) {
		const startRow = Math.floor(Math.random() * HACK_GRID_SIZE);
		const startCol = Math.floor(Math.random() * HACK_GRID_SIZE);
		const direction = Math.random() < 0.5 ? 'horizontal' : 'vertical';

		if (direction === 'horizontal' && startCol + HACK_SEQUENCE_LENGTH <= HACK_GRID_SIZE) {
			for (let i = 0; i < HACK_SEQUENCE_LENGTH; i++) {
				hackGridData[startRow][startCol + i] = hackTargetSequence[i];
			}
			placed = true;
		} else if (direction === 'vertical' && startRow + HACK_SEQUENCE_LENGTH <= HACK_GRID_SIZE) {
			for (let i = 0; i < HACK_SEQUENCE_LENGTH; i++) {
				hackGridData[startRow + i][startCol] = hackTargetSequence[i];
			}
			placed = true;
		}
	}
}

function renderHackGrid() {
	const gridContainer = document.getElementById('grid-container');
	if (!gridContainer) return;
	
	gridContainer.innerHTML = '';
	gridContainer.style.gridTemplateColumns = `repeat(${HACK_GRID_SIZE}, 45px)`;
	gridContainer.style.gridTemplateRows = `repeat(${HACK_GRID_SIZE}, 45px)`;

	for (let r = 0; r < HACK_GRID_SIZE; r++) {
		for (let c = 0; c < HACK_GRID_SIZE; c++) {
			const cell = document.createElement('div');
			cell.classList.add('grid-cell');
			cell.dataset.row = r;
			cell.dataset.col = c;
			cell.textContent = '?';
			cell.addEventListener('click', handleHackCellClick);
			gridContainer.appendChild(cell);
		}
	}
}

function handleHackCellClick(event) {
	if (!hackCanClick || hackGameState === 'SUCCESS' || hackGameState === 'ERROR' || hackGameState === 'TIMEOUT') return;

	const cell = event.target;
	const row = parseInt(cell.dataset.row);
	const col = parseInt(cell.dataset.col);
	const actualSymbol = hackGridData[row][col];
	const expectedSymbol = hackTargetSequence[hackCurrentInputSequence.length];

	revealHackSymbol(cell, actualSymbol);

	if (actualSymbol === expectedSymbol) {
		playCorrectSound();
		hackCurrentInputSequence.push(actualSymbol);
		updateHackStatus(`${actualSymbol} sembolü kabul edildi. (${hackCurrentInputSequence.length}/${HACK_SEQUENCE_LENGTH})`, 'inputting');
		cell.classList.add('correct');
		updateHackCurrentInputDisplay();

		if (hackCurrentInputSequence.length === hackTargetSequence.length) {
			handleHackSuccess();
		} else {
			hackGameState = 'INPUTTING';
		}
	} else {
		playWrongSound();
		handleHackError(cell);
	}
}

function revealHackSymbol(cell, symbol) {
	if (cell.classList.contains('revealed')) return;

	cell.textContent = symbol;
	cell.classList.add('revealed');
	hackCanClick = false;

	setTimeout(() => {
		if (!cell.classList.contains('correct') && hackGameState !== 'SUCCESS') {
			cell.textContent = '?';
			cell.classList.remove('revealed');
		}
		hackCanClick = true;
	}, HACK_REVEAL_DURATION);
}

function handleHackError(clickedCell) {
	hackGameState = 'ERROR';
	hackCanClick = false;
	updateHackStatus('DİZİ UYUŞMADI! Giriş sıfırlanıyor.', 'error');
	hackCurrentInputSequence = [];
	updateHackCurrentInputDisplay();

	clickedCell.classList.add('incorrect');

	const gridContainer = document.getElementById('grid-container');
	const correctCells = gridContainer.querySelectorAll('.grid-cell.correct');
	correctCells.forEach(cell => {
		cell.classList.remove('correct');
		cell.classList.remove('revealed');
		cell.textContent = '?';
	});

	setTimeout(() => {
		clickedCell.classList.remove('incorrect');
		if (!clickedCell.classList.contains('correct')) {
			clickedCell.classList.remove('revealed');
			clickedCell.textContent = '?';
		}
		updateHackStatus('Dizi girişi sıfırlandı. Tekrar dene.', 'ready');
		hackGameState = 'READY';
		hackCanClick = true;
	}, HACK_ERROR_FLASH_DURATION);
}

function handleHackSuccess() {
	hackGameState = 'SUCCESS';
	hackCanClick = false;
	stopHackTimer();
	playSuccessSound();
	updateHackStatus('ERİŞİM SAĞLANDI! Dizi çözüldü.', 'success');
	showHackResultOverlay(true, "SİSTEM AŞILDI!");
	
	const gridContainer = document.getElementById('grid-container');
	const correctCells = gridContainer.querySelectorAll('.grid-cell.correct');
	correctCells.forEach(cell => {
		cell.style.borderColor = 'var(--hack-highlight-color)';
	});
	
	setTimeout(() => {
		sendHackResult(true);
	}, 2000);
}

function updateHackStatus(message, type) {
	const statusMessageElement = document.getElementById('status-message');
	if (!statusMessageElement) return;
	
	statusMessageElement.textContent = message;
	statusMessageElement.style.color = type === 'error' ? 'var(--hack-error-color)' :
										type === 'success' ? 'var(--hack-highlight-color)' :
										'var(--hack-primary-color)';
	if (type === 'error') {
		statusMessageElement.style.textShadow = '0 0 5px var(--hack-error-color)';
	} else if (type === 'success') {
		statusMessageElement.style.textShadow = '0 0 5px var(--hack-highlight-color)';
	} else {
		statusMessageElement.style.textShadow = 'none';
	}
}

function updateHackCurrentInputDisplay() {
	const currentInputElement = document.getElementById('current-input');
	if (currentInputElement) {
		currentInputElement.textContent = `[ ${hackCurrentInputSequence.join(' ')} ]`;
	}
}

function showHackResultOverlay(isSuccess, message) {
	const resultOverlay = document.getElementById('result-overlay');
	const resultMessage = document.getElementById('result-message');
	if (!resultOverlay || !resultMessage) return;
	
	resultMessage.textContent = message;
	resultOverlay.classList.remove('hidden', 'success', 'failure');
	resultOverlay.classList.add(isSuccess ? 'success' : 'failure');
}

function resetHackGame() {
	const resultOverlay = document.getElementById('result-overlay');
	if (resultOverlay) {
		resultOverlay.classList.add('hidden');
		resultOverlay.classList.remove('success', 'failure');
	}
	
	stopHackTimer();
	hackCurrentInputSequence = [];
	updateHackCurrentInputDisplay();
	generateHackTargetSequence();
	generateHackGridData();
	renderHackGrid();
	updateHackStatus('Giriş bekleniyor...', 'ready');
	hackGameState = 'READY';
	hackCanClick = true;
	startHackTimer();
}

function startHackTimer() {
	stopHackTimer();
	hackTimeRemaining = HACK_TIME_LIMIT;
	updateHackTimerDisplay();
	
	hackTimerInterval = setInterval(() => {
		hackTimeRemaining--;
		updateHackTimerDisplay();
		
		if (hackTimeRemaining <= 0) {
			handleHackTimeout();
		}
	}, 1000);
}

function stopHackTimer() {
	if (hackTimerInterval) {
		clearInterval(hackTimerInterval);
		hackTimerInterval = null;
	}
}

function updateHackTimerDisplay() {
	const timerDisplayElement = document.getElementById('timer-display');
	if (!timerDisplayElement) return;
	
	const minutes = Math.floor(hackTimeRemaining / 60);
	const seconds = hackTimeRemaining % 60;
	const timeString = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
	
	timerDisplayElement.textContent = timeString;
	
	// Kalan süre 10 saniyenin altına düştüğünde kırmızı yap
	if (hackTimeRemaining <= 10) {
		timerDisplayElement.style.color = 'var(--hack-error-color)';
		timerDisplayElement.style.textShadow = '0 0 5px var(--hack-error-color)';
	} else {
		timerDisplayElement.style.color = 'var(--hack-primary-color)';
		timerDisplayElement.style.textShadow = 'none';
	}
}

function handleHackTimeout() {
	stopHackTimer();
	hackGameState = 'TIMEOUT';
	hackCanClick = false;
	playFailSound();
	updateHackStatus('SÜRE DOLDU! Erişim reddedildi.', 'error');
	showHackResultOverlay(false, "ERİŞİM REDDEDİLDİ!");
	
	setTimeout(() => {
		sendHackResult(false);
	}, 2000);
}

function startHackGame() {
	initHackAudioContext();
	resetHackGame();
}

function sendHackResult(success) {
	$.post("https://ak4y-core/hackResult", JSON.stringify({ success: success }));
	
	const container = document.getElementById('hackMinigameContainer');
	if (container) {
		// Wait a bit more to ensure fail screen is visible and sounds finish
		setTimeout(() => {
			container.style.display = 'none';
			stopHackTimer();
			$.post("https://ak4y-core/closeHackMinigame", JSON.stringify({}));
		}, 1500);
	}
}

window.addEventListener('message', function(event) {
	if (event.data.action === 'openHackMinigame') {
		const container = document.getElementById('hackMinigameContainer');
		const loadingScreen = document.getElementById('loading-screen');
		const gameScreen = document.getElementById('game-screen');
		const loadingTextElement = document.getElementById('loading-text');
		const resultOverlay = document.getElementById('result-overlay');
		
		if (container) {
			container.style.display = 'flex';
			if (loadingScreen) loadingScreen.classList.remove('hidden');
			if (gameScreen) gameScreen.classList.add('hidden');
			if (loadingTextElement) loadingTextElement.textContent = '';
			
			// Result overlay'i gizle
			if (resultOverlay) {
				resultOverlay.classList.add('hidden');
				resultOverlay.classList.remove('success', 'failure');
			}
			
			initHackAudioContext();
			hackGameState = 'LOADING';
			setTimeout(() => {
				typeHackLoadingText(hackLoadingMessages);
			}, 100);
		}
	} else if (event.data.action === 'closeHackMinigame') {
		const container = document.getElementById('hackMinigameContainer');
		if (container) {
			container.style.display = 'none';
			stopHackTimer();
			$.post("https://ak4y-core/closeHackMinigame", JSON.stringify({}));
		}
	} else if (event.data.action === 'openFirewallMinigame') {
		const container = document.getElementById('firewallMinigameContainer');
		const resultOverlay = document.getElementById('firewall-result-overlay');
		if (container) {
			container.style.display = 'flex';
			// Result overlay'i gizle
			if (resultOverlay) {
				resultOverlay.classList.add('hidden');
				resultOverlay.classList.remove('success', 'failure');
			}
			startFirewallGame();
		}
	} else if (event.data.action === 'closeFirewallMinigame') {
		const container = document.getElementById('firewallMinigameContainer');
		if (container) {
			container.style.display = 'none';
			if (firewallTraceIntervalId) clearInterval(firewallTraceIntervalId);
			if (firewallLayerTimeoutId) clearTimeout(firewallLayerTimeoutId);
			$.post("https://ak4y-core/closeFirewallMinigame", JSON.stringify({}));
		}
	}
});


// ========== FIREWALL MINIGAME CODE ==========
// --- DOM Elements ---
const firewallLoadingScreen = document.getElementById('firewall-loading-screen');
const firewallLoadingTextElement = document.getElementById('firewall-loading-text');
const firewallProgressBarElement = document.getElementById('firewall-progress-bar');
const firewallLoadingStatusElement = document.getElementById('firewall-loading-status');
const firewallGameScreen = document.getElementById('firewall-game-screen');
const firewallGameStatusElement = document.getElementById('firewall-game-status');
const firewallLayersContainer = document.getElementById('firewall-layers');
const firewallTraceBarInner = document.getElementById('trace-bar-inner');
const firewallTracePercentageElement = document.getElementById('trace-percentage');
const firewallResultOverlay = document.getElementById('firewall-result-overlay');
const firewallResultMessage = document.getElementById('firewall-result-message');

// --- Game Configuration ---
const FIREWALL_NUM_LAYERS = 5;
const FIREWALL_NODES_PER_LAYER = 6;
const FIREWALL_SEQUENCE_LENGTH = 4;
const FIREWALL_ACTIVATION_FLASH_DURATION = 350;
const FIREWALL_ACTIVATION_DELAY_BETWEEN = 150;
const FIREWALL_PLAYER_INPUT_TIMEOUT = 4000;
const FIREWALL_TRACE_FILL_RATE = 2.0;
const FIREWALL_TRACE_PENALTY_ERROR = 10;
const FIREWALL_TRACE_PENALTY_TIMEOUT = 15;
const FIREWALL_TRACE_UPDATE_INTERVAL = 100;

// --- Loading Screen Text ---
const firewallLoadingMessages = [
	"Bağlantı protokolü başlatılıyor...",
	"Ağ dinleyici yerleştirildi...",
	"Hedef imza tespit edildi: CORPNET_FW_OMEGA",
	"Katman açıkları taranıyor [Katman 1..5]...",
	"Saldırı yükü hazırlanıyor...",
	"Saldırı kodlanıyor: Base64 -> XOR -> ROT13...",
	"Gizli bağlantı kuruluyor...",
	"İlk denetimler aşılıyor...",
	"Sızma dizisi hazırlanıyor...",
	"UYARI: Sistem izleme başlatıldı.",
	"GÜVENLİK DUVARI ARAYÜZÜ HAZIR.",
];

// --- Game State Variables ---
let firewallGameState = 'LOADING';
let firewallCurrentLayerIndex = 0;
let firewallActiveSequence = [];
let firewallPlayerInputSequence = [];
let firewallLayerTimeoutId = null;
let firewallTraceIntervalId = null;
let firewallCurrentTraceProgress = 0;
let firewallLayers = [];

// Audio context for firewall sound effects
let firewallAudioContext = null;

function initFirewallAudioContext() {
	if (!firewallAudioContext) {
		try {
			firewallAudioContext = new (window.AudioContext || window.webkitAudioContext)();
		} catch (e) {
			console.warn('Web Audio API not supported');
		}
	}
}

function playFirewallSound(frequency, duration, type = 'sine', volume = 0.3) {
	if (!firewallAudioContext) {
		initFirewallAudioContext();
	}
	if (!firewallAudioContext) return;
	
	try {
		const oscillator = firewallAudioContext.createOscillator();
		const gainNode = firewallAudioContext.createGain();
		
		oscillator.connect(gainNode);
		gainNode.connect(firewallAudioContext.destination);
		
		oscillator.frequency.value = frequency;
		oscillator.type = type;
		
		gainNode.gain.setValueAtTime(volume, firewallAudioContext.currentTime);
		gainNode.gain.exponentialRampToValueAtTime(0.01, firewallAudioContext.currentTime + duration);
		
		oscillator.start(firewallAudioContext.currentTime);
		oscillator.stop(firewallAudioContext.currentTime + duration);
	} catch (e) {
		console.warn('Error playing sound:', e);
	}
}

function playFirewallCorrectSound() {
	playFirewallSound(800, 0.1, 'sine', 0.2);
	setTimeout(() => {
		playFirewallSound(1000, 0.1, 'sine', 0.2);
	}, 50);
}

function playFirewallWrongSound() {
	playFirewallSound(200, 0.15, 'sawtooth', 0.25);
	setTimeout(() => {
		playFirewallSound(150, 0.15, 'sawtooth', 0.25);
	}, 100);
}

function playFirewallFailSound() {
	playFirewallSound(150, 0.3, 'sawtooth', 0.3);
	setTimeout(() => {
		playFirewallSound(100, 0.4, 'sawtooth', 0.3);
	}, 200);
	setTimeout(() => {
		playFirewallSound(80, 0.5, 'sawtooth', 0.3);
	}, 500);
}

function playFirewallSuccessSound() {
	playFirewallSound(523, 0.1, 'sine', 0.2); // C
	setTimeout(() => {
		playFirewallSound(659, 0.1, 'sine', 0.2); // E
	}, 100);
	setTimeout(() => {
		playFirewallSound(784, 0.2, 'sine', 0.25); // G
	}, 200);
}

function playFirewallTypingSound() {
	if (!firewallAudioContext) {
		initFirewallAudioContext();
	}
	if (!firewallAudioContext) return;
	
	try {
		const duration = 0.05;
		const now = firewallAudioContext.currentTime;
		
		const osc1 = firewallAudioContext.createOscillator();
		const gain1 = firewallAudioContext.createGain();
		osc1.type = 'square';
		osc1.frequency.value = 800 + Math.random() * 400;
		osc1.connect(gain1);
		gain1.connect(firewallAudioContext.destination);
		gain1.gain.setValueAtTime(0.15, now);
		gain1.gain.exponentialRampToValueAtTime(0.01, now + duration);
		osc1.start(now);
		osc1.stop(now + duration);
		
		const osc2 = firewallAudioContext.createOscillator();
		const gain2 = firewallAudioContext.createGain();
		osc2.type = 'sawtooth';
		osc2.frequency.value = 2000 + Math.random() * 500;
		osc2.connect(gain2);
		gain2.connect(firewallAudioContext.destination);
		gain2.gain.setValueAtTime(0.08, now);
		gain2.gain.exponentialRampToValueAtTime(0.01, now + duration * 0.7);
		osc2.start(now);
		osc2.stop(now + duration * 0.7);
		
		const bufferSize = firewallAudioContext.sampleRate * duration;
		const buffer = firewallAudioContext.createBuffer(1, bufferSize, firewallAudioContext.sampleRate);
		const data = buffer.getChannelData(0);
		for (let i = 0; i < bufferSize; i++) {
			data[i] = Math.random() * 2 - 1;
		}
		const noise = firewallAudioContext.createBufferSource();
		const noiseGain = firewallAudioContext.createGain();
		noise.buffer = buffer;
		noise.connect(noiseGain);
		noiseGain.connect(firewallAudioContext.destination);
		noiseGain.gain.setValueAtTime(0.05, now);
		noiseGain.gain.exponentialRampToValueAtTime(0.01, now + duration * 0.5);
		noise.start(now);
		noise.stop(now + duration * 0.5);
	} catch (e) {
		console.warn('Error playing typing sound:', e);
	}
}

function playFirewallNodeActivateSound() {
	playFirewallSound(600, 0.15, 'sine', 0.2);
}

// === Loading Functions ===
function typeFirewallLoadingText(messages, index = 0, charIndex = 0, callback) {
	if (index === 0 && charIndex === 0) {
		firewallLoadingTextElement.textContent = '';
		updateFirewallProgressBar(0);
		firewallLoadingStatusElement.textContent = messages[0];
	}
	if (index >= messages.length) {
		updateFirewallProgressBar(100);
		firewallLoadingStatusElement.textContent = "Arayüz hazır.";
		setTimeout(callback, 700);
		return;
	}
	const currentMessage = messages[index];
	if (charIndex < currentMessage.length) {
		const char = currentMessage[charIndex];
		firewallLoadingTextElement.textContent += char;
		firewallLoadingTextElement.scrollTop = firewallLoadingTextElement.scrollHeight;
		
		// Boşluk ve yeni satır karakterlerinde ses çalma
		if (char !== ' ' && char !== '\n') {
			playFirewallTypingSound();
		}
		
		setTimeout(() => typeFirewallLoadingText(messages, index, charIndex + 1, callback), 20);
	} else {
		firewallLoadingTextElement.textContent += '\n';
		firewallLoadingTextElement.scrollTop = firewallLoadingTextElement.scrollHeight;
		const progress = Math.min(100, Math.round(((index + 1) / messages.length) * 100));
		updateFirewallProgressBar(progress);
		firewallLoadingStatusElement.textContent = (index + 1 < messages.length) ? messages[index + 1] : "Tamamlanıyor...";
		setTimeout(() => typeFirewallLoadingText(messages, index + 1, 0, callback), 100);
	}
}

function updateFirewallProgressBar(percentage) {
	firewallProgressBarElement.style.width = `${percentage}%`;
}

// === Game Setup ===
function createFirewallLayers() {
	firewallLayersContainer.innerHTML = '';
	firewallLayers = [];
	
	for (let i = 0; i < FIREWALL_NUM_LAYERS; i++) {
		const layerDiv = document.createElement('div');
		layerDiv.classList.add('firewall-layer');
		layerDiv.dataset.layerIndex = i;
		
		const label = document.createElement('span');
		label.classList.add('layer-label');
		label.textContent = `KATMAN ${i + 1}`;
		layerDiv.appendChild(label);
		
		const nodesDiv = document.createElement('div');
		nodesDiv.classList.add('nodes-container');
		
		const layerNodes = [];
		for (let j = 0; j < FIREWALL_NODES_PER_LAYER; j++) {
			const nodeSpan = document.createElement('span');
			nodeSpan.classList.add('firewall-node');
			nodeSpan.dataset.layerIndex = i;
			nodeSpan.dataset.nodeIndex = j;
			nodeSpan.addEventListener('click', handleFirewallNodeClick);
			nodesDiv.appendChild(nodeSpan);
			layerNodes.push(nodeSpan);
		}
		
		layerDiv.appendChild(nodesDiv);
		firewallLayersContainer.appendChild(layerDiv);
		firewallLayers.push({ element: layerDiv, nodes: layerNodes });
	}
}

// === Game Loop and State Management ===
function startFirewallGame() {
	firewallGameState = 'LOADING';
	initFirewallAudioContext();
	createFirewallLayers();
	
	// Result overlay'i gizle
	if (firewallResultOverlay) {
		firewallResultOverlay.classList.add('hidden');
		firewallResultOverlay.classList.remove('success', 'failure');
	}
	
	if (firewallLoadingScreen) firewallLoadingScreen.classList.remove('hidden');
	if (firewallGameScreen) firewallGameScreen.classList.add('hidden');
	
	typeFirewallLoadingText(firewallLoadingMessages, 0, 0, () => {
		if (firewallLoadingScreen) firewallLoadingScreen.classList.add('hidden');
		if (firewallGameScreen) firewallGameScreen.classList.remove('hidden');
		
		firewallGameState = 'READY';
		firewallCurrentLayerIndex = 0;
		firewallCurrentTraceProgress = 0;
		resetFirewallVisuals();
		startFirewallTraceTimer();
		activateFirewallLayer(firewallCurrentLayerIndex);
	});
}


function resetFirewallVisuals() {
	updateFirewallTraceBar(0);
	firewallTracePercentageElement.textContent = `0%`;
	
	firewallLayers.forEach(layer => {
		layer.element.classList.remove('active-layer', 'disabled-layer');
		layer.nodes.forEach(node => {
			node.classList.remove('activating', 'hit', 'error');
		});
	});
	
	firewallGameStatusElement.textContent = "Tarama başlatılıyor...";
}

function activateFirewallLayer(index) {
	if (index >= FIREWALL_NUM_LAYERS) {
		handleFirewallGameSuccess();
		return;
	}
	
	firewallGameState = 'READY';
	firewallPlayerInputSequence = [];
	firewallGameStatusElement.textContent = `Katman ${index + 1} etkinleştiriliyor... Bekle...`;
	
	firewallLayers.forEach((layer, i) => {
		layer.element.classList.toggle('active-layer', i === index);
	});
	
	setTimeout(() => {
		if (firewallGameState === 'READY') {
			showFirewallLayerSequence(index);
		}
	}, 1000);
}

async function showFirewallLayerSequence(layerIndex) {
	if (firewallGameState === 'GAME_FAILURE' || firewallGameState === 'GAME_SUCCESS') return;
	
	firewallGameState = 'ACTIVATING';
	firewallGameStatusElement.textContent = `Katman ${layerIndex + 1}: Desen izleniyor...`;
	
	firewallActiveSequence = generateFirewallRandomSequence(FIREWALL_NODES_PER_LAYER, FIREWALL_SEQUENCE_LENGTH);
	
	firewallLayers[layerIndex].nodes.forEach(node => node.style.pointerEvents = 'none');
	
	for (const nodeIndex of firewallActiveSequence) {
		if (firewallGameState !== 'ACTIVATING') break;
		
		const nodeElement = firewallLayers[layerIndex].nodes[nodeIndex];
		if (nodeElement) {
			nodeElement.classList.add('activating');
			playFirewallNodeActivateSound();
			await new Promise(resolve => setTimeout(resolve, FIREWALL_ACTIVATION_FLASH_DURATION));
			nodeElement.classList.remove('activating');
			await new Promise(resolve => setTimeout(resolve, FIREWALL_ACTIVATION_DELAY_BETWEEN));
		}
	}
	
	if (firewallGameState === 'ACTIVATING') {
		firewallLayers[layerIndex].nodes.forEach(node => node.style.pointerEvents = 'auto');
		firewallGameState = 'AWAITING_INPUT';
		firewallGameStatusElement.textContent = `Katman ${layerIndex + 1}: Diziyi şimdi gir!`;
		startFirewallLayerTimer(FIREWALL_PLAYER_INPUT_TIMEOUT);
	} else {
		firewallLayers[layerIndex].nodes.forEach(node => node.style.pointerEvents = 'none');
	}
}

function generateFirewallRandomSequence(maxIndex, length) {
	const sequence = [];
	const availableIndices = Array.from({ length: maxIndex }, (_, i) => i);
	
	for (let i = 0; i < length; i++) {
		if (availableIndices.length === 0) break;
		const randomIndex = Math.floor(Math.random() * availableIndices.length);
		sequence.push(availableIndices.splice(randomIndex, 1)[0]);
	}
	
	return sequence;
}

// === Player Interaction ===
function handleFirewallNodeClick(event) {
	if (firewallGameState !== 'AWAITING_INPUT') return;
	
	const clickedLayerIndex = parseInt(event.target.dataset.layerIndex);
	const clickedNodeIndex = parseInt(event.target.dataset.nodeIndex);
	
	if (clickedLayerIndex !== firewallCurrentLayerIndex) return;
	
	clearTimeout(firewallLayerTimeoutId);
	
	const expectedNodeIndex = firewallActiveSequence[firewallPlayerInputSequence.length];
	
	if (clickedNodeIndex === expectedNodeIndex) {
		playFirewallCorrectSound();
		firewallPlayerInputSequence.push(clickedNodeIndex);
		event.target.classList.add('hit');
		event.target.style.pointerEvents = 'none';
		
		if (firewallPlayerInputSequence.length === firewallActiveSequence.length) {
			handleFirewallLayerSuccess();
		} else {
			startFirewallLayerTimer(FIREWALL_PLAYER_INPUT_TIMEOUT);
			firewallGameStatusElement.textContent = `Katman ${firewallCurrentLayerIndex + 1}: Dizi giriliyor... [${firewallPlayerInputSequence.length}/${firewallActiveSequence.length}]`;
		}
	} else {
		playFirewallWrongSound();
		handleFirewallLayerError(event.target);
	}
}

// === Timers and Trace ===
function startFirewallLayerTimer(duration) {
	clearTimeout(firewallLayerTimeoutId);
	firewallLayerTimeoutId = setTimeout(() => {
		handleFirewallLayerTimeout();
	}, duration);
}

function startFirewallTraceTimer() {
	if (firewallTraceIntervalId) clearInterval(firewallTraceIntervalId);
	
	const increment = (FIREWALL_TRACE_FILL_RATE / (1000 / FIREWALL_TRACE_UPDATE_INTERVAL));
	
	firewallTraceIntervalId = setInterval(() => {
		if (firewallGameState === 'GAME_SUCCESS' || firewallGameState === 'GAME_FAILURE') {
			clearInterval(firewallTraceIntervalId);
			return;
		}
		
		firewallCurrentTraceProgress += increment;
		firewallCurrentTraceProgress = Math.min(firewallCurrentTraceProgress, 100);
		updateFirewallTraceBar(firewallCurrentTraceProgress);
		
		if (firewallCurrentTraceProgress >= 100) {
			handleFirewallGameFailure();
		}
	}, FIREWALL_TRACE_UPDATE_INTERVAL);
}

function updateFirewallTraceBar(progress) {
	const percentage = Math.round(progress);
	firewallTraceBarInner.style.width = `${percentage}%`;
	firewallTracePercentageElement.textContent = `${percentage}%`;
	
	if (progress > 85) {
		firewallTraceBarInner.style.backgroundColor = 'var(--firewall-error-color)';
		firewallTraceBarInner.style.boxShadow = '0 0 8px var(--firewall-error-color)';
	} else {
		firewallTraceBarInner.style.backgroundColor = 'var(--firewall-trace-color)';
		firewallTraceBarInner.style.boxShadow = '0 0 8px var(--firewall-trace-color)';
	}
}

function applyFirewallTracePenalty(penaltyAmount) {
	firewallCurrentTraceProgress += penaltyAmount;
	firewallCurrentTraceProgress = Math.min(firewallCurrentTraceProgress, 100);
	updateFirewallTraceBar(firewallCurrentTraceProgress);
	
	if (firewallCurrentTraceProgress >= 100) {
		handleFirewallGameFailure();
		return true;
	}
	return false;
}

// === Outcome Handlers ===
function handleFirewallLayerSuccess() {
	firewallGameState = 'LAYER_SUCCESS';
	clearTimeout(firewallLayerTimeoutId);
	firewallGameStatusElement.textContent = `Katman ${firewallCurrentLayerIndex + 1} etkisiz hale getirildi!`;
	
	firewallLayers[firewallCurrentLayerIndex].element.classList.add('disabled-layer');
	firewallLayers[firewallCurrentLayerIndex].element.classList.remove('active-layer');
	firewallLayers[firewallCurrentLayerIndex].nodes.forEach(node => {
		node.classList.remove('hit');
		node.style.pointerEvents = 'none';
	});
	
	firewallCurrentLayerIndex++;
	
	if (firewallCurrentLayerIndex >= FIREWALL_NUM_LAYERS) {
		handleFirewallGameSuccess();
	} else {
		setTimeout(() => {
			if (firewallGameState === 'LAYER_SUCCESS') {
				activateFirewallLayer(firewallCurrentLayerIndex);
			}
		}, 800);
	}
}

function handleFirewallLayerError(clickedNode) {
	if (firewallGameState === 'GAME_FAILURE') return;
	
	firewallGameState = 'LAYER_ERROR';
	clearTimeout(firewallLayerTimeoutId);
	firewallGameStatusElement.textContent = `Katman ${firewallCurrentLayerIndex + 1}: Dizi hatası! Tekrar deneniyor...`;
	
	if (clickedNode) {
		clickedNode.classList.add('error');
		setTimeout(() => { clickedNode.classList.remove('error'); }, FIREWALL_ACTIVATION_FLASH_DURATION);
	}
	
	firewallPlayerInputSequence = [];
	firewallLayers[firewallCurrentLayerIndex].nodes.forEach(node => {
		node.classList.remove('hit');
		node.style.pointerEvents = 'auto';
	});
	
	if (applyFirewallTracePenalty(FIREWALL_TRACE_PENALTY_ERROR)) return;
	
	setTimeout(() => {
		if (firewallGameState === 'LAYER_ERROR') {
			showFirewallLayerSequence(firewallCurrentLayerIndex);
		}
	}, 1200);
}

function handleFirewallLayerTimeout() {
	if (firewallGameState === 'GAME_FAILURE' || firewallGameState === 'GAME_SUCCESS') return;
	
	firewallGameState = 'LAYER_ERROR';
	firewallGameStatusElement.textContent = `Katman ${firewallCurrentLayerIndex + 1}: Giriş süresi doldu! Tekrar deneniyor...`;
	
	firewallPlayerInputSequence = [];
	firewallLayers[firewallCurrentLayerIndex].nodes.forEach(node => {
		node.classList.remove('hit');
		node.style.pointerEvents = 'auto';
	});
	
	if (applyFirewallTracePenalty(FIREWALL_TRACE_PENALTY_TIMEOUT)) return;
	
	setTimeout(() => {
		if (firewallGameState === 'LAYER_ERROR') {
			showFirewallLayerSequence(firewallCurrentLayerIndex);
		}
	}, 1200);
}

function handleFirewallGameSuccess() {
	if (firewallGameState === 'GAME_SUCCESS') return;
	
	firewallGameState = 'GAME_SUCCESS';
	clearInterval(firewallTraceIntervalId);
	clearTimeout(firewallLayerTimeoutId);
	playFirewallSuccessSound();
	firewallGameStatusElement.textContent = "Güvenlik duvarı aşıldı!";
	
	const successMsg = "TÜM KATMANLAR ETKİSİZ\n:: GÜVENLİK DUVARI AŞILDI ::\n\n> SİSTEM ERİŞİMİ SAĞLANDI <";
	showFirewallResultOverlay(true, successMsg);
	
	setTimeout(() => {
		sendFirewallResult(true);
	}, 2000);
}

function handleFirewallGameFailure() {
	if (firewallGameState === 'GAME_FAILURE') return;
	
	firewallGameState = 'GAME_FAILURE';
	clearInterval(firewallTraceIntervalId);
	clearTimeout(firewallLayerTimeoutId);
	playFirewallFailSound();
	
	firewallCurrentTraceProgress = 100;
	updateFirewallTraceBar(100);
	firewallGameStatusElement.textContent = "İzleme tamamlandı! Bağlantı kesildi!";
	
	const failureMsg = "SİSTEM İZLEMESİ TAMAMLANDI\n:: BAĞLANTI KESİLDİ ::\n\n> ERİŞİM REDDEDİLDİ - SALDIRI BAŞARISIZ <";
	showFirewallResultOverlay(false, failureMsg);
	
	setTimeout(() => {
		sendFirewallResult(false);
	}, 2000);
}

function showFirewallResultOverlay(isSuccess, message) {
	firewallResultMessage.textContent = message;
	firewallResultOverlay.classList.remove('hidden', 'success', 'failure');
	firewallResultOverlay.classList.add(isSuccess ? 'success' : 'failure');
}

function sendFirewallResult(success) {
	$.post("https://ak4y-core/firewallResult", JSON.stringify({ success: success }));
	
	const container = document.getElementById('firewallMinigameContainer');
	if (container) {
		// Wait a bit more to ensure fail screen is visible and sounds finish
		setTimeout(() => {
			container.style.display = 'none';
			if (firewallTraceIntervalId) clearInterval(firewallTraceIntervalId);
			if (firewallLayerTimeoutId) clearTimeout(firewallLayerTimeoutId);
			$.post("https://ak4y-core/closeFirewallMinigame", JSON.stringify({}));
		}, 1500);
	}
}

// ESC key handler for both minigames
document.addEventListener('keydown', function(event) {
	if (event.key === 'Escape' || event.keyCode === 27) {
		const hackContainer = document.getElementById('hackMinigameContainer');
		const firewallContainer = document.getElementById('firewallMinigameContainer');
		
		// Check if hack minigame is open
		if (hackContainer && window.getComputedStyle(hackContainer).display !== 'none') {
			event.preventDefault();
			// If game is in progress, trigger timeout (which shows fail screen and closes after delay)
			if (hackGameState !== 'SUCCESS' && hackGameState !== 'TIMEOUT' && hackGameState !== 'LOADING') {
				handleHackTimeout();
			}
			// If already finished (SUCCESS or TIMEOUT), just close immediately
			else if (hackGameState === 'SUCCESS' || hackGameState === 'TIMEOUT') {
				hackContainer.style.display = 'none';
				stopHackTimer();
				$.post("https://ak4y-core/closeHackMinigame", JSON.stringify({}));
			}
			// If loading, do nothing (wait for game to start)
			return;
		}
		// Check if firewall minigame is open
		if (firewallContainer && window.getComputedStyle(firewallContainer).display !== 'none') {
			event.preventDefault();
			// If game is in progress, trigger failure (which shows fail screen and closes after delay)
			if (firewallGameState !== 'GAME_SUCCESS' && firewallGameState !== 'GAME_FAILURE' && firewallGameState !== 'LOADING') {
				handleFirewallGameFailure();
			}
			// If already finished (SUCCESS or FAILURE), just close immediately
			else if (firewallGameState === 'GAME_SUCCESS' || firewallGameState === 'GAME_FAILURE') {
				firewallContainer.style.display = 'none';
				if (firewallTraceIntervalId) clearInterval(firewallTraceIntervalId);
				if (firewallLayerTimeoutId) clearTimeout(firewallLayerTimeoutId);
				$.post("https://ak4y-core/closeFirewallMinigame", JSON.stringify({}));
			}
			// If loading, do nothing (wait for game to start)
			return;
		}
	}
});

