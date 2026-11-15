// State variables
let currentInteriorId = 0;
let currentCoords = { x: 0, y: 0, z: 0 };
let entitySets = [];
let selectedStyleName = null;
let soundEnabled = true;
let locales = {};
let hasChanges = false;
let allStates = {};
let autoPresetKey = "";
let presets = {};

// Helper to get localized or fallback label for a style name
function getStyleLabel(name) {
    const style = entitySets.find(s => s.name === name);
    if (style) return style.label;
    const mapping = {
        "1st_red": "Red Style",
        "2nd_yellow": "Yellow Style",
        "3rd_purple": "Purple Style",
        "4th_turquoise": "Turquoise Style",
        "5th_darkred": "Dark Red Style"
    };
    return mapping[name] || name;
}

// Helper to resolve the active theme name for a given preset
function getActiveThemeForPreset(presetKey, presetData) {
    const saved = allStates[presetKey];
    let activeName = null;
    
    if (saved && saved.states) {
        for (const [name, active] of Object.entries(saved.states)) {
            if (active) {
                activeName = name;
                break;
            }
        }
    }
    
    if (!activeName && presetData) {
        activeName = presetData.defaultEntitySet;
    }
    
    return activeName ? getStyleLabel(activeName) : "None";
}

// // Web Audio API Sound Synthesizer (Disabled)
function playSound(type) {}

// In-Game Toast System
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    let iconClass = 'fa-info-circle';
    if (type === 'success') iconClass = 'fa-check-circle';
    if (type === 'error') iconClass = 'fa-exclamation-circle';

    toast.innerHTML = `
        <i class="fas ${iconClass} toast-icon"></i>
        <div class="toast-content">${message}</div>
    `;

    container.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('toast-fade-out');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3500);
}

// Copy to Clipboard utility
function copyToClipboard(text, successMsg) {
    const el = document.createElement('textarea');
    el.value = text;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
    
    playSound('copy');
    showToast(successMsg, 'success');
}

// NUI Post Helper
function post(endpoint, data = {}) {
    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'rs_paddock_entitysetchanger';
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json());
}

// Translate UI elements
function translateUI() {
    const elements = {
        'loc-title': 'ui_title',
        'loc-subtitle': 'ui_subtitle',
        'loc-sidebar-title': 'ui_available_themes',
        'loc-selection-badge': 'ui_selected_theme',
        'loc-interior-type-label': 'ui_interior_type',
        'loc-status-label': 'ui_status',
        'loc-details-title': 'ui_interior_details',
        'loc-interior-id-label': 'ui_interior_id',
        'loc-coords-label': 'ui_coords',
        'loc-locations-title': 'ui_available_locations',
        'loc-col-address': 'ui_col_address',
        'loc-col-theme': 'ui_col_theme',
        'loc-col-tp': 'ui_col_tp',
        'save-db-btn': 'ui_save_db_btn'
    };

    for (const [id, key] of Object.entries(elements)) {
        const el = document.getElementById(id);
        if (el && locales[key]) {
            const icon = el.querySelector('i');
            if (icon) {
                el.innerHTML = '';
                el.appendChild(icon);
                el.appendChild(document.createTextNode(' ' + locales[key].toUpperCase()));
            } else {
                el.textContent = locales[key].toUpperCase();
            }
        }
    }
}

// Calculate Statistics
function updateStats() {
    const total = entitySets.length;
    document.getElementById('total-sets-count').textContent = total;
}

// Get Currently Selected Style Object
function getSelectedStyle() {
    return entitySets.find(s => s.name === selectedStyleName);
}

// Update Center Preview Area & Right Sidebar Apply Button
function updateSelectedPreview() {
    const style = getSelectedStyle();
    
    const titleEl = document.getElementById('active-style-title');
    const subtitleEl = document.getElementById('active-style-subtitle');
    const previewBox = document.getElementById('active-preview-box');
    const previewImg = document.getElementById('active-preview-img');
    const previewInner = previewBox.querySelector('.preview-inner-content');
    const statusText = document.getElementById('active-status-text');
    const watermark = document.getElementById('preview-watermark-text');
    const applyBtn = document.getElementById('apply-style-btn');

    if (!style) {
        titleEl.textContent = locales['ui_no_active_theme'] || "No Theme Selected";
        subtitleEl.textContent = locales['ui_select_theme_desc'] || "Select a theme from the left";
        previewBox.className = "preview-box";
        previewImg.style.display = 'none';
        previewInner.style.display = 'flex';
        statusText.textContent = locales['ui_inactive'] || "INACTIVE";
        statusText.className = "footer-info-value";
        watermark.textContent = "PADDOCK";
        applyBtn.textContent = locales['ui_apply_theme'] || "Apply Theme";
        applyBtn.className = "apply-btn active-style";
        applyBtn.disabled = true;
        return;
    }

    titleEl.textContent = style.label;
    subtitleEl.textContent = style.name;
    watermark.textContent = style.label.replace(" Style", "").toUpperCase() + " THEME";

    // Set preview theme class for dynamic CSS gradients
    previewBox.className = "preview-box";
    previewBox.classList.add(`theme-${style.name}`);

    // Dynamic Image Loading
    if (style.name) {
        // Set handlers
        previewImg.onload = () => {
            previewImg.style.display = 'block';
            previewInner.style.display = 'none';
        };
        previewImg.onerror = () => {
            previewImg.style.display = 'none';
            previewInner.style.display = 'flex';
        };
        // Load the image
        previewImg.src = `img/${style.name}.png`;
    } else {
        previewImg.style.display = 'none';
        previewInner.style.display = 'flex';
    }

    if (style.active) {
        statusText.textContent = locales['ui_active'] || "ACTIVE";
        statusText.className = "footer-info-value accent-value";
        
        applyBtn.textContent = locales['ui_already_active'] || "Already Active";
        applyBtn.className = "apply-btn active-style";
        applyBtn.disabled = true;
    } else {
        statusText.textContent = locales['ui_inactive'] || "INACTIVE";
        statusText.className = "footer-info-value";
        
        applyBtn.textContent = (locales['ui_apply_theme'] || "Apply Theme") + " (" + style.label.toUpperCase() + ")";
        applyBtn.className = "apply-btn";
        applyBtn.disabled = false;
    }

}

// Render Left Sidebar Styles List
function renderEntitySets() {
    const container = document.getElementById('styles-list-container');
    if (!container) return;

    container.innerHTML = '';

    if (entitySets.length === 0) {
        container.innerHTML = `<div style="padding: 20px; text-align: center; font-size: 11px; color: var(--text-muted);">${locales['ui_empty_sets'] || "No themes found"}</div>`;
        return;
    }

    entitySets.forEach(set => {
        const item = document.createElement('div');
        item.className = `style-item ${selectedStyleName === set.name ? 'selected' : ''}`;

        const isDefault = (autoPresetKey && presets && presets[autoPresetKey] && presets[autoPresetKey].defaultEntitySet === set.name);
        const activeDot = set.active ? '<span class="style-item-active-dot" title="Active"></span>' : '';
        const defaultBadge = isDefault ? '<span class="style-item-default-badge">DEFAULT</span>' : '';

        item.innerHTML = `
            <div class="style-item-header">
                <span class="style-item-label">${set.label}</span>
                <div class="style-item-indicators">
                    ${defaultBadge}
                    ${activeDot}
                </div>
            </div>
            <span class="style-item-sub">${set.name}</span>
        `;

        // Click to select style
        item.addEventListener('click', () => {
            playSound('click');
            selectedStyleName = set.name;
            renderEntitySets();
            updateSelectedPreview();
        });

        container.appendChild(item);
    });
}

// Window actions
function closeUI() {
    playSound('click');
    if (hasChanges) {
        post('saveToDatabase');
    }
    document.getElementById('app').classList.add('hidden');
    post('closeUI');
}

// Dynamic scaling responsiveness function for 720p - 4K
function resizeUI() {
    const baseHeight = 1080; // The height at which scale = 1
    const windowHeight = window.innerHeight;
    
    // Scale factor based on vertical height
    const scale = windowHeight / baseHeight;
    
    const container = document.querySelector('.window-container');
    if (container) {
        container.style.transform = `scale(${scale})`;
    }
}

// Setup Event Listeners
document.addEventListener('DOMContentLoaded', () => {
    // Close Window Actions
    document.getElementById('close-window-btn').addEventListener('click', closeUI);
    
    // ESC key close
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeUI();
        }
    });

    // Copy IDs and Coords
    document.getElementById('interior-id-val').addEventListener('click', () => {
        copyToClipboard(currentInteriorId.toString(), locales['ui_copied_id'] || "Copied Interior ID to clipboard.");
    });

    document.getElementById('coords-val').addEventListener('click', () => {
        const text = document.getElementById('coords-val').textContent;
        copyToClipboard(text, locales['ui_copied_coords'] || "Copied Coordinates to clipboard.");
    });

    // Apply Button Click
    document.getElementById('apply-style-btn').addEventListener('click', () => {
        const style = getSelectedStyle();
        if (!style || style.active) return;

        playSound('toggle-on');
        
        // Locally set active state (mutually exclusive)
        entitySets.forEach(set => {
            // Deactivate other shared styles
            const isShared = set.name.includes("1st") || set.name.includes("2nd") || set.name.includes("3rd") || set.name.includes("4th") || set.name.includes("5th");
            if (isShared && set.name !== style.name) {
                set.active = false;
            }
        });
        
        style.active = true;

        // Trigger client NUI Callback
        post('toggleEntitySet', {
            interiorId: currentInteriorId,
            setName: style.name,
            state: true
        });

        // Enable active state for save button
        const saveBtn = document.getElementById('save-db-btn');
        saveBtn.classList.add('active');
        saveBtn.innerHTML = `<i class="fas fa-check"></i> ${(locales['ui_saved'] || "SAVED").toUpperCase()}`;
        hasChanges = true;

        // Re-render
        renderEntitySets();
        updateSelectedPreview();
    });

    // Save to Database
    document.getElementById('save-db-btn').addEventListener('click', () => {
        playSound('click');
        post('saveToDatabase').then(() => {
            showToast(locales['ui_saved_db_toast'] || "Saved database changes to interiors.json", 'success');
        });
    });



    // Responsive scaling resize listeners
    window.addEventListener('resize', resizeUI);
    resizeUI(); // Initial run
});

// Listen for NUI Messages
window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "openUI") {
        const uiData = data.data;
        
        // Save state
        currentInteriorId = uiData.interiorId;
        currentCoords = uiData.coords;
        entitySets = uiData.entitySets;
        soundEnabled = data.sound !== false;
        locales = uiData.locales || {};
        allStates = uiData.allStates || {};
        autoPresetKey = uiData.autoPresetKey || "";
        presets = uiData.presets || {};

        // Reset change tracking and save button state
        hasChanges = false;
        const saveBtn = document.getElementById('save-db-btn');
        saveBtn.classList.remove('active');
        saveBtn.innerHTML = `<i class="fas fa-cloud-upload-alt"></i> ${(locales['ui_save_db_btn'] || "SAVE").toUpperCase()}`;

        // Find active style or fall back to first one
        const activeStyle = entitySets.find(s => s.active);
        selectedStyleName = activeStyle ? activeStyle.name : (entitySets[0] ? entitySets[0].name : null);

        // Apply theme color
        const appEl = document.getElementById('app');
        appEl.className = ""; // Reset

        // Apply localization
        translateUI();

        // Populate side panel details
        document.getElementById('interior-id-val').textContent = currentInteriorId;
        document.getElementById('coords-val').textContent = `${currentCoords.x}, ${currentCoords.y}, ${currentCoords.z}`;

        // Populate Locations Table
        const tableBody = document.getElementById('locations-table-body');
        if (tableBody) {
            tableBody.innerHTML = '';
            if (uiData.presets) {
                for (const [key, preset] of Object.entries(uiData.presets)) {
                    const row = document.createElement('div');
                    row.className = 'location-row';
                    
                    // Shorten the label (remove "RS Paddock // ")
                    const shortLabel = preset.label.replace("RS Paddock // ", "");
                    
                    // Get active theme name for this preset location
                    const activeThemeLabel = getActiveThemeForPreset(key, preset);
                    
                    row.innerHTML = `
                        <span class="location-address" title="${preset.label}">${shortLabel}</span>
                        <span class="location-theme" title="${activeThemeLabel}">${activeThemeLabel}</span>
                        <div class="location-tp-btn-wrap">
                            <button class="location-tp-btn" data-key="${key}" title="Teleport to Location">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </div>
                    `;
                    
                    row.querySelector('.location-tp-btn').addEventListener('click', () => {
                        playSound('success');
                        post('teleportToPreset', {
                            presetKey: key
                        }).then(result => {
                            if (result && result.success) {
                                showToast(locales['ui_teleporting'] || "Teleporting to location...", 'success');
                                closeUI();
                            } else {
                                showToast(locales['ui_teleport_failed'] || "Teleportation failed.", 'error');
                            }
                        }).catch(err => {
                            console.error("Teleport failed:", err);
                            showToast(locales['ui_error_communication'] || "Error communicating with client script.", 'error');
                        });
                    });
                    
                    tableBody.appendChild(row);
                }
            }
        }

        // Trigger responsive scaling when opening
        resizeUI();

        // Render everything
        updateStats();
        renderEntitySets();
        updateSelectedPreview();

        // Show window
        appEl.classList.remove('hidden');
        
        // Synth intro beep
        playSound('success');
    }
});
