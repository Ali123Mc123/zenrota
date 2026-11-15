/**
 * Cylex Music DUI - Listener
 * Handles DUI messages from Lua for music playback
 * Uses iframe approach like xsound for better YouTube compatibility
 * Audio filters (bass, treble, stereo, LPF) controlled via postMessage to player.html
 */

const MusicPlayers = {};
let pingInterval = null;

// Ping the client to indicate DUI is alive
function startPing() {
    if (pingInterval) return;
    pingInterval = setInterval(() => {
        fetch('https://cylex_phone/music:duiPing', {
            method: 'POST',
            body: JSON.stringify({})
        }).catch(() => {});
    }, 2000);
}

// Start ping on load
startPing();

// Player ended callback (called from iframe)
window.onPlayerEnded = function(playerId) {
    fetch('https://cylex_phone/music:duiEnded', {
        method: 'POST',
        body: JSON.stringify({ playerId: playerId })
    }).catch(() => {});
};

// Listen for messages from player iframes (duration, etc.)
window.addEventListener('message', function(event) {
    const data = event.data;
    if (!data) return;
    
    // Handle duration message from player.html
    if (data.type === 'duration' && data.playerId && data.duration) {
        const playerId = parseInt(data.playerId) || data.playerId;
        
        // Auto-ready: If we receive duration, the player is definitely ready
        if (MusicPlayers[playerId] && !MusicPlayers[playerId].isReady) {
            MusicPlayers[playerId].isReady = true;
            fetch('https://cylex_phone/music:duiReady', {
                method: 'POST',
                body: JSON.stringify({ playerId: playerId })
            }).catch(() => {});
        }

        // console.log('[Music API] Duration received:', playerId, data.duration);
        fetch('https://cylex_phone/music:duiDuration', {
            method: 'POST',
            body: JSON.stringify({ playerId: playerId, duration: data.duration })
        }).catch(() => {});
        return;
    }
    
    // Handle currentTime message from player.html
    if (data.type === 'currentTime' && data.playerId && data.currentTime !== undefined) {
        const playerId = parseInt(data.playerId) || data.playerId;
        // console.log('[Music API] CurrentTime:', playerId, data.currentTime);
        fetch('https://cylex_phone/music:duiCurrentTime', {
            method: 'POST',
            body: JSON.stringify({ playerId: playerId, currentTime: data.currentTime })
        }).catch(() => {});
        return;
    }

    // Handle log message from player.html
    if (data.type === 'log' && data.message) {
        fetch('https://cylex_phone/music:log', {
            method: 'POST',
            body: JSON.stringify({ message: data.message })
        }).catch(() => {});
        return;
    }

    // Handle playerReady message from player.html (cross-origin safe)
    if (data.type === 'playerReady' && data.playerId) {
        const playerId = data.playerId;
        const manager = MusicPlayers[playerId];
        if (manager && !manager.isReady) {
            manager.isReady = true;
            // console.log('[Music API] Player ready signal received for', playerId);
            
            // Notify Lua
            fetch('https://cylex_phone/music:duiReady', {
                method: 'POST',
                body: JSON.stringify({ playerId: playerId })
            }).catch(() => {});
        }
        return;
    }
    
    // Player gave up on itself (API never loaded, YouTube error, never got ready)
    if (data.type === 'playerFailed' && data.playerId) {
        const playerId = parseInt(data.playerId) || data.playerId;
        reportFailure(playerId, data.reason || 'unknown', data.permanent);
        return;
    }

    // Handle action messages from Lua
    if (!data.action) return;

    switch (data.action) {
        case 'play':
            handlePlay(data);
            break;
        case 'pause':
            handlePause(data);
            break;
        case 'resume':
            handleResume(data);
            break;
        case 'stop':
            handleStop(data);
            break;
        case 'seek':
            handleSeek(data);
            break;
        case 'setVolume':
            handleSetVolume(data);
            break;
        case 'setBassBoost':
            handleSetBassBoost(data);
            break;
        case 'setTrebleBoost':
            handleSetTrebleBoost(data);
            break;
        case 'setLPF':
            handleSetLPF(data);
            break;
        case 'setStereoPan':
            handleSetStereoPan(data);
            break;
        case 'setSpeakerColor':
            handleSetSpeakerColor(data);
            break;
        case 'destroy':
            handleDestroy(data);
            break;
        case 'destroyAll':
            handleDestroyAll();
            break;
    }
});

// A bare 11-char video id is what the player expects. Saved playlists have
// historically also carried full watch URLs, and those used to be dropped into
// the query string below unescaped - the `?v=` inside then collided with our own
// params and YT.Player got a videoId it could never load.
function toVideoId(value) {
    if (typeof value !== 'string') return value;

    const trimmed = value.trim();
    if (/^[\w-]{11}$/.test(trimmed)) return trimmed;

    const match = trimmed.match(/(?:v=|youtu\.be\/|\/embed\/|\/shorts\/)([\w-]{11})/);
    return match ? match[1] : trimmed;
}

function handlePlay(data) {
    const playerId = data.playerId;
    const videoId = toVideoId(data.videoId);
    const startTime = data.startTime || 0;
    const volume = data.volume || 0; // Start at 0, position loop will set correct volume
    const bassBoost = data.bassBoost || 0;
    const trebleBoost = data.trebleBoost || 0;

    // Destroy existing player if any
    if (MusicPlayers[playerId]) {
        destroyPlayer(playerId);
    }

    // Create container
    const container = document.getElementById('players');
    // Use unique ID to prevent collision during fast switches
    const iframeId = `player-${playerId}-${Date.now()}`;
    
    // Use cfx-nui- URL like xsound does
    // Pass initial values via query params for immediate effect initialization
    const playerUrl = `https://cfx-nui-cylex_phone/html/music-dui/player.html?videoId=${encodeURIComponent(videoId)}&playerId=${encodeURIComponent(playerId)}&startTime=${startTime}&volume=${volume}&bass=${bassBoost}&treble=${trebleBoost}`;
    
    // console.log('[Music API] Creating player for', playerId, 'video:', videoId);
    
    // Create iframe for YouTube player
    const iframe = document.createElement('iframe');
    iframe.id = iframeId;
    iframe.src = playerUrl;
    iframe.style.cssText = 'width:2px;height:2px;opacity:0;position:absolute;';
    iframe.allow = 'autoplay';
    container.appendChild(iframe);

    // Create manager object
    MusicPlayers[playerId] = {
        iframeId: iframeId,
        iframe: iframe,
        volume: volume,
        bassBoost: bassBoost,
        trebleBoost: trebleBoost,
        stereoPan: 0,
        lpfValue: 0,
        isReady: false
    };

    // No checkInterval needed anymore, we rely on postMessage 'playerReady'
    // but keep a destruction timeout just in case it hangs forever
    const manager = MusicPlayers[playerId];
    setTimeout(() => {
        // Identity check, not just a null check: by now this playerId may hold a
        // player for a newer song. Without it a stale timeout from a previous
        // track would kill the one that is currently playing.
        if (MusicPlayers[playerId] !== manager) return;
        if (manager.isReady) return;
        reportFailure(playerId, 'init-timeout', false);
    }, 15000);
}

// A player is dead. Previously this path only did a console.warn into the DUI's
// own console - which nobody can open in game - and left the iframe hanging, so
// the track stayed at 0:00 / 0:00 until the player relogged.
function reportFailure(playerId, reason, permanent) {
    const manager = MusicPlayers[playerId];
    if (!manager || manager.failed) return;
    manager.failed = true;

    // Surface it in F8 through the existing log bridge.
    fetch('https://cylex_phone/music:log', {
        method: 'POST',
        body: JSON.stringify({ message: `Player ${playerId} failed: ${reason}${permanent ? ' (permanent)' : ''}` })
    }).catch(() => {});

    destroyPlayer(playerId);

    fetch('https://cylex_phone/music:duiFailed', {
        method: 'POST',
        body: JSON.stringify({ playerId: playerId, reason: reason, permanent: !!permanent })
    }).catch(() => {});
}

// Send command to player iframe via postMessage
function sendToPlayer(playerId, cmd, value) {
    const manager = MusicPlayers[playerId];
    if (!manager) return;
    
    try {
        // Use direct reference if available, fallback to getElementById
        const frame = manager.iframe || document.getElementById(manager.iframeId);
        if (frame && frame.contentWindow) {
            frame.contentWindow.postMessage({ cmd: cmd, value: value }, '*');
        }
    } catch (e) {
        console.error('[Music API] postMessage error:', e);
    }
}

function handlePause(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager || !manager.isReady) return;

    try {
        const frame = manager.iframe || document.getElementById(manager.iframeId);
        if (frame && frame.contentWindow && frame.contentWindow.yPlayer) {
            frame.contentWindow.yPlayer.pauseVideo();
        }
    } catch (e) {
        console.error('[Music API] Pause error:', e);
    }
}

function handleResume(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager || !manager.isReady) return;

    try {
        const frame = manager.iframe || document.getElementById(manager.iframeId);
        if (frame && frame.contentWindow && frame.contentWindow.yPlayer) {
            frame.contentWindow.yPlayer.playVideo();
        }
    } catch (e) {
        console.error('[Music API] Resume error:', e);
    }
}

function handleStop(data) {
    destroyPlayer(data.playerId);
}

function handleSeek(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager || !manager.isReady) return;

    try {
        const frame = manager.iframe || document.getElementById(manager.iframeId);
        if (frame && frame.contentWindow && frame.contentWindow.yPlayer) {
            frame.contentWindow.yPlayer.seekTo(data.time, true);
        }
    } catch (e) {
        console.error('[Music API] Seek error:', e);
    }
}

function handleSetVolume(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;
    
    manager.volume = data.volume;
    sendToPlayer(data.playerId, 'setVolume', data.volume);
}

function handleSetBassBoost(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;
    
    manager.bassBoost = data.bassBoost;
    sendToPlayer(data.playerId, 'setBassBoost', data.bassBoost);
}

function handleSetTrebleBoost(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;
    
    manager.trebleBoost = data.trebleBoost;
    sendToPlayer(data.playerId, 'setTrebleBoost', data.trebleBoost);
}

function handleSetLPF(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;
    
    manager.lpfValue = data.value;
    sendToPlayer(data.playerId, 'setLPF', data.value);
}

function handleSetStereoPan(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;
    
    manager.stereoPan = data.pan;
    sendToPlayer(data.playerId, 'setStereoPan', data.pan);
}

// Hoparlör kabini renklendirmesi (highpass + orta frekans honk'u)
function handleSetSpeakerColor(data) {
    const manager = MusicPlayers[data.playerId];
    if (!manager) return;

    manager.speakerColor = { highpass: data.highpass, peak: data.peak };
    sendToPlayer(data.playerId, 'setSpeakerColor', { highpass: data.highpass, peak: data.peak });
}

function handleDestroy(data) {
    destroyPlayer(data.playerId);
}

function handleDestroyAll() {
    for (const playerId in MusicPlayers) {
        destroyPlayer(playerId);
    }
}

function destroyPlayer(playerId) {
    const manager = MusicPlayers[playerId];
    if (!manager) return;

    // Clear check interval
    if (manager.checkInterval) {
        clearInterval(manager.checkInterval);
        manager.checkInterval = null;
    }

    // Clean iframe safely using direct reference
    try {
        const frame = manager.iframe || document.getElementById(manager.iframeId);
        if (frame) {
            if (frame.contentWindow && typeof frame.contentWindow.clearMe === 'function') {
                frame.contentWindow.clearMe();
            }
            frame.src = 'about:blank';
            // Immediate removal to prevent ID collision (if we rely on IDs)
            // But we use unique IDs now, so timeout is fine for clean GC, 
            // but let's remove validation reliance on ID
            setTimeout(() => { 
                try {
                   if (frame && frame.parentNode) frame.parentNode.removeChild(frame);
                   else frame.remove();
                } catch(e) {}
            }, 100);
        }
    } catch (e) {
        console.error('[Music API] Destroy error:', e);
    }

    // Remove from registry
    delete MusicPlayers[playerId];
    // console.log('[Music API] Player destroyed:', playerId);
}

// Notify client that DUI is initialized
fetch('https://cylex_phone/music:duiInit', {
    method: 'POST',
    body: JSON.stringify({})
}).catch(() => {});

console.log('[Music API] Initialized');
