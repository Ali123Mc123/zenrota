let currentJailTime = 0;
let maxJailTime = 0;
let tasksCompleted = 0;

let taskCooldown = 0;
let elecData = { done: 0, total: 5, cooldown: 0 };
let cleanData = { done: 0, total: 5, cooldown: 0 };
let kitchenData = { done: 0, total: 5, cooldown: 0 };

let timerInterval = null;

const hudContainer = document.getElementById('prison-hud');
const jailTimeDisplay = document.getElementById('jail-time-display');
const tabTimeDisplay = document.getElementById('tab-time');
const taskCountDisplay = document.getElementById('task-count');
const floatContainer = document.getElementById('float-container');
const progressFill = document.getElementById('progress-fill');
const collapsedTab = document.getElementById('collapsed-tab');

const badgeElectrical = document.getElementById('badge-electrical');
const badgeCleaning = document.getElementById('badge-cleaning');
const badgeKitchen = document.getElementById('badge-kitchen');

if (collapsedTab) {
  collapsedTab.addEventListener('click', () => {
    hudContainer.classList.remove('collapsed');
  });
}

function formatTime(seconds) {
  const s = Math.max(seconds, 0);
  const mins = Math.floor(s / 60);
  const secs = s % 60;
  return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

function updateProgressBar(current, max) {
  if (!max || max <= 0) max = Math.max(current, 1);
  const ratio = Math.min(Math.max(current / max, 0), 1);
  const percent = (ratio * 100).toFixed(1);

  if (progressFill) {
    progressFill.style.width = `${percent}%`;
    if (ratio <= 0.15) {
      progressFill.classList.add('green');
    } else {
      progressFill.classList.remove('green');
    }
  }
}

function showFloatingReduction(reduction) {
  if (!reduction || reduction <= 0) return;
  const badge = document.createElement('div');
  badge.className = 'float-badge';
  badge.textContent = `-${reduction} Ay`;
  floatContainer.appendChild(badge);

  setTimeout(() => {
    badge.remove();
  }, 1600);
}

function updateTasksDisplay() {
  // Elektrik Panoları Rozeti
  if (badgeElectrical) {
    if (elecData.cooldown > 0) {
      badgeElectrical.className = 'task-badge cooldown';
      badgeElectrical.textContent = formatTime(elecData.cooldown);
    } else if (elecData.done >= elecData.total) {
      badgeElectrical.className = 'task-badge done';
      badgeElectrical.textContent = `${elecData.done}/${elecData.total}`;
    } else {
      badgeElectrical.className = 'task-badge';
      badgeElectrical.textContent = `${elecData.done}/${elecData.total}`;
    }
  }

  // Avlu Temizliği Rozeti
  if (badgeCleaning) {
    if (cleanData.cooldown > 0) {
      badgeCleaning.className = 'task-badge cooldown';
      badgeCleaning.textContent = formatTime(cleanData.cooldown);
    } else if (cleanData.done >= cleanData.total) {
      badgeCleaning.className = 'task-badge done';
      badgeCleaning.textContent = `${cleanData.done}/${cleanData.total}`;
    } else {
      badgeCleaning.className = 'task-badge';
      badgeCleaning.textContent = `${cleanData.done}/${cleanData.total}`;
    }
  }

  // Mutfak İşleri Rozeti
  if (badgeKitchen) {
    if (kitchenData.cooldown > 0) {
      badgeKitchen.className = 'task-badge cooldown';
      badgeKitchen.textContent = formatTime(kitchenData.cooldown);
    } else if (kitchenData.done >= kitchenData.total) {
      badgeKitchen.className = 'task-badge done';
      badgeKitchen.textContent = `${kitchenData.done}/${kitchenData.total}`;
    } else {
      badgeKitchen.className = 'task-badge';
      badgeKitchen.textContent = `${kitchenData.done}/${kitchenData.total}`;
    }
  }
}

function startGlobalTimer() {
  if (timerInterval) clearInterval(timerInterval);

  updateTasksDisplay();

  timerInterval = setInterval(() => {
    let hasRunning = false;

    if (taskCooldown > 0) {
      taskCooldown--;
      hasRunning = true;
    }
    if (elecData.cooldown > 0) {
      elecData.cooldown--;
      hasRunning = true;
    }
    if (cleanData.cooldown > 0) {
      cleanData.cooldown--;
      hasRunning = true;
    }
    if (kitchenData.cooldown > 0) {
      kitchenData.cooldown--;
      hasRunning = true;
    }

    updateTasksDisplay();
  }, 1000);
}

window.addEventListener('message', (event) => {
  const { action, data } = event.data || {};

  if (action === 'showHUD') {
    currentJailTime = data.jailTime !== undefined ? data.jailTime : 0;
    maxJailTime = data.maxJailTime || currentJailTime || 1;
    tasksCompleted = data.tasksDone || 0;
    taskCooldown = data.taskCooldown || 0;

    if (data.electrical) elecData = data.electrical;
    if (data.cleaning) cleanData = data.cleaning;
    if (data.kitchen) kitchenData = data.kitchen;

    jailTimeDisplay.textContent = `${currentJailTime} Ay`;
    if (tabTimeDisplay) tabTimeDisplay.textContent = `${currentJailTime} Ay`;
    taskCountDisplay.textContent = tasksCompleted;
    updateProgressBar(currentJailTime, maxJailTime);
    startGlobalTimer();

    hudContainer.classList.remove('hidden');
    hudContainer.classList.remove('collapsed');
  } else if (action === 'updateHUD') {
    const prevTime = currentJailTime;
    if (data.jailTime !== undefined) currentJailTime = data.jailTime;
    if (data.maxJailTime) maxJailTime = data.maxJailTime;
    if (data.tasksDone !== undefined) tasksCompleted = data.tasksDone;
    if (data.taskCooldown !== undefined) taskCooldown = data.taskCooldown;

    if (data.electrical) elecData = data.electrical;
    if (data.cleaning) cleanData = data.cleaning;
    if (data.kitchen) kitchenData = data.kitchen;

    jailTimeDisplay.textContent = `${currentJailTime} Ay`;
    if (tabTimeDisplay) tabTimeDisplay.textContent = `${currentJailTime} Ay`;
    taskCountDisplay.textContent = tasksCompleted;

    if (data.reduction) {
      showFloatingReduction(data.reduction);
    } else if (prevTime > currentJailTime) {
      showFloatingReduction(prevTime - currentJailTime);
    }

    updateProgressBar(currentJailTime, maxJailTime);
    startGlobalTimer();

    hudContainer.classList.remove('hidden');
  } else if (action === 'toggleHUD') {
    hudContainer.classList.toggle('collapsed');
  } else if (action === 'hideHUD') {
    hudContainer.classList.add('hidden');
    if (timerInterval) {
      clearInterval(timerInterval);
      timerInterval = null;
    }
  }
});
