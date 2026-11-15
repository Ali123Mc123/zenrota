(function () {
    const HOUSE_SECURITY_TAB_INDEX = -2;
    const HOUSE_HOME_OWNER_TAB_INDEX = -1;
    const HOUSE_MISSION_NPC_MODEL = 'a_m_y_business_03';
    const HOUSE_MISSION_INTERACTION_LABEL = 'Request House Lead';
    const HOUSE_LOCATION_LIST_VISIBLE_ROWS = 6;

    let houseRobberyUiState = {
        activePanel: 'shells',
        selectedShellIndex: 0,
        selectedPresetIndex: 0,
        selectedLocationIndex: 0,
        selectedPointIndex: 0,
        pointManagerOpen: false,
        pendingBulkSetting: '',
    };
    let housePointPreviewState = {
        active: false,
        shellKey: '',
        presetKey: '',
        pointIndex: -1,
    };
    let housePresetClipboard = null;
    let housePointRewardItemClipboard = [];
    let housePointEditorRenderDepth = 0;

    function escapeHouseHtml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function notifyHousePreset(message, type = 'success') {
        $.post('https://' + GetParentResourceName() + '/NuiNotify', JSON.stringify({
            Notify: message,
            Type: type,
        }));
    }

    function normalizeHousePresetBaseName(raw) {
        return String(raw || '')
            .trim()
            .replace(/\.json$/i, '')
            .replace(/[<>:"/\\|?*]/g, '_')
            .replace(/\s+/g, '_')
            .replace(/_+/g, '_')
            .replace(/^_+|_+$/g, '');
    }

    function ensureHousePresetModal() {
        let modal = document.getElementById('housePresetFileModal');
        if (modal) return modal;

        modal = document.createElement('div');
        modal.id = 'housePresetFileModal';
        modal.className = 'overlay rc-modal house-preset-file-modal';
        modal.style.display = 'none';
        modal.innerHTML = `
            <div class="container rc-modal-card rc-import-card rc-preset-card house-preset-file-card">
                <h2 id="housePresetFileModalTitle">House Preset</h2>
                <p id="housePresetFileModalNote" class="rc-preset-note"></p>
                <div id="housePresetFileSelectRow">
                    <label for="housePresetFileSelect" class="rc-preset-label">Preset File</label>
                    <select id="housePresetFileSelect"></select>
                </div>
                <div id="housePresetFileInputRow">
                    <label for="housePresetFileInput" class="rc-preset-label">Preset Name</label>
                    <input id="housePresetFileInput" type="text" placeholder="example-house-setup" autocomplete="off">
                </div>
                <div class="rc-preset-actions">
                    <button id="housePresetFileConfirmButton" type="button" class="save-banktruck-button">Continue</button>
                    <button id="housePresetFileCancelButton" type="button" class="remove-target-button">Cancel</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
        modal.addEventListener('click', (event) => {
            if (event.target === modal) closeHousePresetModal();
        });
        document.getElementById('housePresetFileCancelButton')?.addEventListener('click', closeHousePresetModal);
        document.getElementById('housePresetFileInput')?.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                document.getElementById('housePresetFileConfirmButton')?.click();
            }
        });
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && modal.style.display !== 'none') {
                closeHousePresetModal();
            }
        });
        return modal;
    }

    function closeHousePresetModal() {
        const modal = document.getElementById('housePresetFileModal');
        if (modal) modal.style.display = 'none';
        const selectWrap = document.querySelector('#housePresetFileSelect.pug-native-hidden + .pug-select');
        if (selectWrap) selectWrap.classList.remove('open');
    }

    async function fetchHousePresetFiles() {
        const response = await fetch(`https://${GetParentResourceName()}/GetHousePresetFiles`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({}),
        });
        return response.json();
    }

    function getHousePresetSelectItems() {
        const select = document.getElementById('housePresetFileSelect');
        return Array.from(select?.options || []).map((option) => ({
            value: option.value,
            label: option.textContent || option.value,
        }));
    }

    function ensureHousePresetDropdown() {
        const select = document.getElementById('housePresetFileSelect');
        if (!select || typeof rcWrapSelectWithSearch !== 'function') return;

        rcWrapSelectWithSearch(select, {
            placeholder: 'Search house preset...',
            populate: false,
            emptyLabel: 'Select house preset',
            getItems: getHousePresetSelectItems,
        });

        const selectWrap = document.querySelector('#housePresetFileSelect.pug-native-hidden + .pug-select');
        if (selectWrap) selectWrap.classList.remove('open');
    }

    async function openHousePresetModal(mode) {
        const modal = ensureHousePresetModal();
        const title = document.getElementById('housePresetFileModalTitle');
        const note = document.getElementById('housePresetFileModalNote');
        const selectRow = document.getElementById('housePresetFileSelectRow');
        const inputRow = document.getElementById('housePresetFileInputRow');
        const select = document.getElementById('housePresetFileSelect');
        const input = document.getElementById('housePresetFileInput');
        const confirmButton = document.getElementById('housePresetFileConfirmButton');

        if (!modal || !title || !note || !confirmButton) return;
        confirmButton.onclick = null;

        if (mode === 'load') {
            const result = await fetchHousePresetFiles().catch(() => null);
            const files = Array.isArray(result?.files) ? result.files : [];
            if (!files.length) {
                notifyHousePreset('No house robbery preset files were found.', 'error');
                return;
            }

            title.textContent = 'Load House Preset';
            note.textContent = 'Choose a saved full house robbery setup from preset-info/house-presets.';
            if (selectRow) selectRow.style.display = 'block';
            if (inputRow) inputRow.style.display = 'none';
            if (select) {
                select.innerHTML = '';
                files.forEach((fileName) => {
                    const option = document.createElement('option');
                    option.value = fileName;
                    option.textContent = fileName;
                    select.appendChild(option);
                });
                ensureHousePresetDropdown();
                if (select.options.length) {
                    select.selectedIndex = 0;
                    select.dispatchEvent(new Event('change', { bubbles: true }));
                }
            }
            confirmButton.textContent = 'Load Preset';
            confirmButton.onclick = () => {
                const fileName = select?.value || '';
                if (!fileName) {
                    notifyHousePreset('Select a house preset file first.', 'error');
                    return;
                }
                closeHousePresetModal();
                loadHousePreset(fileName);
            };
        } else {
            title.textContent = 'Save House Preset';
            note.textContent = 'Save the current full house robbery setup into preset-info/house-presets.';
            if (selectRow) selectRow.style.display = 'none';
            if (inputRow) inputRow.style.display = 'block';
            if (input) input.value = '';
            const selectWrap = document.querySelector('#housePresetFileSelect.pug-native-hidden + .pug-select');
            if (selectWrap) selectWrap.classList.remove('open');
            confirmButton.textContent = 'Save Preset';
            confirmButton.onclick = () => {
                const fileName = normalizeHousePresetBaseName(input?.value || '');
                if (!fileName) {
                    notifyHousePreset('Enter a house preset name first.', 'error');
                    return;
                }
                closeHousePresetModal();
                saveHousePreset(fileName);
            };
        }

        modal.style.display = 'flex';
        if (mode === 'save' && input) {
            requestAnimationFrame(() => {
                input.focus();
                input.select();
            });
        }
    }

    async function saveHousePreset(fileName) {
        prepareHouseRobberyDataForSave();

        try {
            const response = await fetch(`https://${GetParentResourceName()}/SaveHousePreset`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ fileName, data: houseRobberyData }),
            });
            const result = await response.json();
            if (!result?.success) {
                notifyHousePreset(result?.error || 'Failed to save house preset.', 'error');
                return;
            }
            notifyHousePreset(`Saved house preset ${result.fileName || `${fileName}.json`}.`, 'success');
        } catch (error) {
            console.error('Error saving house preset:', error);
            notifyHousePreset('Failed to save house preset.', 'error');
        }
    }

    async function loadHousePreset(fileName) {
        try {
            const response = await fetch(`https://${GetParentResourceName()}/LoadHousePreset`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ fileName }),
            });
            const result = await response.json();
            if (!result?.success) {
                notifyHousePreset(result?.error || 'Failed to load house preset.', 'error');
                return;
            }
            houseRobberyData = normalizeHouseRobberyData(result.data || {});
            window.LoadHouseRobberyData(houseRobberyData);
            window.SaveHouseRobberyData();
            notifyHousePreset(`Loaded house preset ${result.fileName || fileName}.`, 'success');
        } catch (error) {
            console.error('Error loading house preset:', error);
            notifyHousePreset('Failed to load house preset.', 'error');
        }
    }

    function getConfiguredHouseShells() {
        return Array.isArray(Config?.HouseRobberyShellModels) ? Config.HouseRobberyShellModels : [];
    }

    function getHouseAlertDefaultsFromConfig() {
        const defaults = (Config && typeof Config.HouseRobberyPresetSettings === 'object' && Config.HouseRobberyPresetSettings) || {};
        return {
            sendAlert: defaults.sendAlert === true,
            policeRequired: Number(defaults.policeRequired ?? 0) || 0,
            cooldown: Number(defaults.cooldownTimer ?? defaults.cooldown ?? 30) || 30,
            alertChance: String(defaults.alertChance ?? '100'),
            policeAlertHeader: String(defaults.policeAlertHeader || 'House Robbery Alert'),
            policeAlert: String(defaults.policeAlert || 'Suspicious activity reported at a house robbery.'),
            policeJobs: Array.isArray(defaults.policeJobs) ? defaults.policeJobs.map((job) => String(job || '').trim()).filter(Boolean) : (Array.isArray(Config?.DefualPoliceJobs) ? [...Config.DefualPoliceJobs] : []),
            alertCode: String(defaults.alertCode || '10-90'),
            alertIcon: String(defaults.alertIcon || 'fas fa-house'),
            alertPriority: String(defaults.alertPriority ?? '2'),
            alertCamId: String(defaults.alertCamId || ''),
            blipSprite: String(defaults.blipSprite ?? '40'),
            blipColor: String(defaults.blipColor ?? '1'),
            blipScale: String(defaults.blipScale ?? '1.0'),
            alertSound1: String(defaults.alertSound1 || 'robberysound'),
            blipFlash: defaults.blipFlash === true,
            missionLeadDurationMinutes: Number(defaults.missionLeadDurationMinutes ?? 60) || 60,
        };
    }

    function normalizeHouseAlertSettings(settings = {}) {
        const defaults = getHouseAlertDefaultsFromConfig();
        const defaultPoliceJobs = Array.isArray(Config?.DefualPoliceJobs) ? Config.DefualPoliceJobs : [];
        const normalizedPoliceJobs = Array.isArray(settings.policeJobs)
            ? settings.policeJobs.map((job) => String(job || '').trim()).filter(Boolean)
            : [];
        const defaultMissionNpc = defaults.missionNpc && typeof defaults.missionNpc === 'object'
            ? defaults.missionNpc
            : {
                heading: 0,
                model: HOUSE_MISSION_NPC_MODEL,
                interactionLabel: HOUSE_MISSION_INTERACTION_LABEL,
            };
        const missionNpcInput = settings.missionNpc && typeof settings.missionNpc === 'object' ? settings.missionNpc : {};
        const missionNpcCoords = missionNpcInput.coords || settings.missionNpcCoords || null;
        const missionNpcPlaced = hasHousePlacementCoords({ coords: missionNpcCoords });
        return {
            sendAlert: settings.sendAlert === undefined ? defaults.sendAlert : !!settings.sendAlert,
            policeRequired: Number(settings.policeRequired ?? defaults.policeRequired) || defaults.policeRequired,
            cooldown: Number(settings.cooldown ?? defaults.cooldown) || defaults.cooldown,
            alertChance: String(settings.alertChance ?? defaults.alertChance),
            policeAlertHeader: String(settings.policeAlertHeader || defaults.policeAlertHeader),
            policeAlert: String(settings.policeAlert || defaults.policeAlert),
            policeJobs: normalizedPoliceJobs.length ? normalizedPoliceJobs : (defaults.policeJobs.length ? [...defaults.policeJobs] : [...defaultPoliceJobs]),
            alertCode: String(settings.alertCode || defaults.alertCode),
            alertIcon: String(settings.alertIcon || defaults.alertIcon),
            alertPriority: String(settings.alertPriority ?? defaults.alertPriority),
            alertCamId: String(settings.alertCamId || defaults.alertCamId),
            blipSprite: String(settings.blipSprite ?? defaults.blipSprite),
            blipColor: String(settings.blipColor ?? defaults.blipColor),
            blipScale: String(settings.blipScale ?? defaults.blipScale),
            alertSound1: String(settings.alertSound1 || defaults.alertSound1),
            blipFlash: settings.blipFlash === undefined ? defaults.blipFlash : !!settings.blipFlash,
            missionNpcEnabled: settings.missionNpcEnabled === true && missionNpcPlaced,
            missionNpc: {
                coords: missionNpcPlaced ? {
                    x: Number(missionNpcCoords.x ?? 0) || 0,
                    y: Number(missionNpcCoords.y ?? 0) || 0,
                    z: Number(missionNpcCoords.z ?? 0) || 0,
                } : null,
                heading: Number(missionNpcInput.heading ?? settings.missionNpcHeading ?? defaultMissionNpc.heading ?? 0) || 0,
                model: String(missionNpcInput.model || settings.missionNpcModel || defaultMissionNpc.model || HOUSE_MISSION_NPC_MODEL),
                interactionLabel: String(missionNpcInput.interactionLabel || settings.missionNpcInteractionLabel || defaultMissionNpc.interactionLabel || HOUSE_MISSION_INTERACTION_LABEL),
                placed: missionNpcPlaced,
            },
            missionLeadDurationMinutes: Math.max(1, Math.floor(Number(settings.missionLeadDurationMinutes ?? defaults.missionLeadDurationMinutes ?? 60) || 60)),
        };
    }

    function getHouseLocationDefaults() {
        const defaults = (Config && typeof Config.HouseRobberyPresetSettings === 'object' && Config.HouseRobberyPresetSettings) || {};
        const globalAlertSettings = normalizeHouseAlertSettings(typeof houseRobberyData === 'object' && houseRobberyData?.settings ? houseRobberyData.settings : {});
        return {
            interactionLabel: String(defaults.targetLabel || defaults.interactionLabel || 'Break In'),
            progressLabel: String(defaults.progressbarLabel || defaults.progressLabel || 'Breaking into house'),
            progressDuration: Number(defaults.progressbarTime ?? defaults.progressDuration ?? 6500) || 6500,
            policeRequired: Number(globalAlertSettings.policeRequired ?? defaults.policeRequired ?? 0) || 0,
            cooldown: Number(globalAlertSettings.cooldown ?? defaults.cooldownTimer ?? defaults.cooldown ?? 30) || 30,
            alertChance: globalAlertSettings.alertChance,
            minigameOption: String(defaults.minigameOption || 'none'),
            sendAlert: globalAlertSettings.sendAlert,
            policeAlertHeader: globalAlertSettings.policeAlertHeader,
            policeAlert: globalAlertSettings.policeAlert,
            policeJobs: [...globalAlertSettings.policeJobs],
            alertCode: globalAlertSettings.alertCode,
            alertIcon: globalAlertSettings.alertIcon,
            alertPriority: globalAlertSettings.alertPriority,
            alertCamId: globalAlertSettings.alertCamId,
            blipSprite: globalAlertSettings.blipSprite,
            blipColor: globalAlertSettings.blipColor,
            blipScale: globalAlertSettings.blipScale,
            alertSound1: globalAlertSettings.alertSound1,
            blipFlash: globalAlertSettings.blipFlash,
            moneyReward: defaults.moneyReward === true,
            rewardType: String(defaults.rewardType || 'cash'),
            minMoney: String(defaults.minMoney ?? '50'),
            maxMoney: String(defaults.maxMoney ?? '150'),
            moneyChance: String(defaults.moneyChance ?? '100'),
            xpOptions: defaults.xpOptions === true,
            xpRewardAmount: String(defaults.xpRewardAmount ?? '0'),
            xpNeededAmount: String(defaults.xpNeededAmount ?? '0'),
            removeXpOnHit: defaults.removeXpOnHit === true,
            xpRemoveAmount: String(defaults.xpRemoveAmount ?? '0'),
        };
    }

    function normalizeHouseBatchLocationSettings(settings = {}) {
        const defaults = getHouseLocationDefaults();
        const xpOptionsEnabled = settings.xpOptionsEnabled === undefined ? false : !!settings.xpOptionsEnabled;
        return {
            enabled: settings.enabled === undefined ? true : !!settings.enabled,
            interactionLabel: String(settings.interactionLabel || defaults.interactionLabel),
            progressLabel: String(settings.progressLabel || defaults.progressLabel),
            progressDuration: Number(settings.progressDuration ?? defaults.progressDuration) || defaults.progressDuration,
            minigameOption: String(settings.minigameOption || defaults.minigameOption),
            requiredItemsEnabled: settings.requiredItemsEnabled === undefined ? false : !!settings.requiredItemsEnabled,
            requiredItems: Array.isArray(settings.requiredItems) ? settings.requiredItems : [],
            rewardItemsEnabled: settings.rewardItemsEnabled === undefined ? false : !!settings.rewardItemsEnabled,
            rewardItems: Array.isArray(settings.rewardItems) ? settings.rewardItems : [],
            moneyRewardEnabled: settings.moneyRewardEnabled === undefined ? false : !!settings.moneyRewardEnabled,
            rewardType: String(settings.rewardType || defaults.rewardType),
            minMoney: String(settings.minMoney ?? defaults.minMoney),
            maxMoney: String(settings.maxMoney ?? defaults.maxMoney),
            moneyChance: String(settings.moneyChance ?? defaults.moneyChance),
            xpOptionsEnabled,
            xpRewardAmount: String(settings.xpRewardAmount ?? defaults.xpRewardAmount),
            xpNeededAmount: String(settings.xpNeededAmount ?? defaults.xpNeededAmount),
            removeXpOnHit: xpOptionsEnabled && (settings.removeXpOnHit === undefined ? false : !!settings.removeXpOnHit),
            xpRemoveAmount: String(settings.xpRemoveAmount ?? defaults.xpRemoveAmount),
        };
    }

    function normalizePoint(point = {}, index = 0) {
        const coords = point.coords || point.offset || point.position || {};
        const pedCoords = point.pedCoords || {};
        const hasCoords = Array.isArray(coords)
            ? coords.length >= 3
            : coords && typeof coords === 'object' && ['x', 'y', 'z', 0, 1, 2].some((key) => coords[key] !== undefined);
        const normalizedCoords = {
            x: Number(coords.x ?? coords[0] ?? 0) || 0,
            y: Number(coords.y ?? coords[1] ?? 0) || 0,
            z: Number(coords.z ?? coords[2] ?? 0) || 0,
        };
        const normalizedPedCoords = {
            x: Number(pedCoords.x ?? pedCoords[0] ?? 0) || 0,
            y: Number(pedCoords.y ?? pedCoords[1] ?? 0) || 0,
            z: Number(pedCoords.z ?? pedCoords[2] ?? 0) || 0,
        };
        const explicitlyUnplaced = point.isPlaced === false || point.placed === false || point.templateNeedsPlacement === true;
        const isPlaced = !explicitlyUnplaced && hasCoords && !isHouseZeroCoords(normalizedCoords);
        const requiredItems = Array.isArray(point.requiredItems) ? point.requiredItems : [];
        const rewardItems = Array.isArray(point.rewardItems) ? point.rewardItems : [];
        const requiredWeapons = Array.isArray(point.requiredWeapons) ? point.requiredWeapons : [];
        const sharedHeading = Number(point.heading ?? point.pedHeading ?? point.propHeading ?? 0) || 0;
        const hasExplicitXpOptions = Object.prototype.hasOwnProperty.call(point, 'xpOptions');
        const hasPointXpSettings = Number(point.xpRewardAmount ?? 0) > 0
            || Number(point.xpNeededAmount ?? 0) > 0
            || point.removeXpOnHit === true
            || Number(point.xpRemoveAmount ?? 0) > 0;
        const xpOptionsEnabled = hasExplicitXpOptions ? point.xpOptions === true : hasPointXpSettings;
        let pedHeading = Number(point.pedHeading ?? sharedHeading) || 0;
        let propHeading = Number(point.propHeading ?? sharedHeading) || 0;
        const label = String(
            point.label
            ?? point.targetText
            ?? point.TargetText
            ?? point.targetLabel
            ?? point.TargetLabel
            ?? point.optionLabel
            ?? point.name
            ?? ''
        ).trim() || 'Search';
        if (pedHeading === 0 && sharedHeading !== 0) pedHeading = sharedHeading;
        if (propHeading === 0 && sharedHeading !== 0) propHeading = sharedHeading;
        return {
            id: String(point.id || `loot_${index + 1}`),
            label,
            numberValue: String(point.numberValue ?? (index + 1)),
            isPlaced,
            placed: isPlaced,
            coords: normalizedCoords,
            heading: sharedHeading,
            pedCoords: normalizedPedCoords,
            pedHeading,
            prop: String(point.prop || ''),
            animation: String(point.animation || ''),
            propHeading,
            createChance: String(point.createChance ?? point.targetCreateChance ?? point.spawnChance ?? '100'),
            minigameCheckbox: point.minigameCheckbox === true || (String(point.minigameType || 'none') !== 'none'),
            minigameType: String(point.minigameType || 'none'),
            failPoliceChance: String(point.failPoliceChance ?? point.alertChance ?? '0'),
            requiresItem: point.requiresItem === true || requiredItems.length > 0,
            requiredItems: requiredItems.map((item) => ({
                itemName: String(item.itemName || ''),
                amount: String(item.amount ?? 1),
                chance: String(item.chance ?? 100),
            })),
            rewardItem: point.rewardItem === true || rewardItems.length > 0,
            rewardItems: rewardItems.map((item) => ({
                itemName: String(item.itemName || ''),
                minAmount: String(item.minAmount ?? 1),
                maxAmount: String(item.maxAmount ?? 1),
                chance: String(item.chance ?? 100),
            })),
            rewardMoney: point.rewardMoney === true,
            rewardMoneyType: String(point.rewardMoneyType || point.rewardType || 'cash'),
            rewardMoneyMin: String(point.rewardMoneyMin ?? point.minMoney ?? '1'),
            rewardMoneyMax: String(point.rewardMoneyMax ?? point.maxMoney ?? '1'),
            moneyChance: String(point.moneyChance ?? '100'),
            xpOptions: xpOptionsEnabled,
            xpRewardAmount: String(point.xpRewardAmount ?? '0'),
            xpNeededAmount: String(point.xpNeededAmount ?? '0'),
            removeXpOnHit: xpOptionsEnabled && point.removeXpOnHit === true,
            xpRemoveAmount: String(point.xpRemoveAmount ?? '0'),
            delayRewardCheckbox: point.delayRewardCheckbox === true || Number(point.rewardDelayTime ?? 0) > 0,
            rewardDelayTime: String(point.rewardDelayTime ?? '1'),
            requireWeaponInHand: point.requireWeaponInHand === true || requiredWeapons.length > 0,
            requiredWeapons: requiredWeapons.map((weapon) => String(weapon || '').trim()).filter(Boolean),
        };
    }

    function ensureUniqueHouseLootPointIds(points = []) {
        const used = new Set();
        points.forEach((point, index) => {
            if (!point || typeof point !== 'object') return;
            const base = String(point.id || `loot_${index + 1}`).trim() || `loot_${index + 1}`;
            let nextId = base;
            let suffix = 2;
            while (used.has(nextId)) {
                nextId = `${base}_${suffix}`;
                suffix += 1;
            }
            point.id = nextId;
            used.add(nextId);
        });
        return points;
    }

    function normalizeHouseLaserVector(input) {
        if (Array.isArray(input)) {
            return input.slice(0, 3).map((value) => Number(value ?? 0) || 0);
        }

        if (typeof input === 'string') {
            const parts = input.split(',').map((value) => Number(String(value).trim()));
            if (parts.length >= 3 && parts.every((value) => Number.isFinite(value))) {
                return parts.slice(0, 3);
            }
        }

        if (input && typeof input === 'object') {
            return [
                Number(input.x ?? input[0] ?? input[1] ?? 0) || 0,
                Number(input.y ?? input[1] ?? input[2] ?? 0) || 0,
                Number(input.z ?? input[2] ?? input[3] ?? 0) || 0,
            ];
        }

        return [0, 0, 0];
    }

    function normalizeHouseSecurityLaser(laser = {}, index = 0) {
        const startVector = normalizeHouseLaserVector(laser.startVector || laser.vector1 || laser.start);
        const endVector = normalizeHouseLaserVector(laser.endVector || laser.vector2 || laser.endPos || laser.end);
        const hasStart = startVector.some((value) => value !== 0);
        const hasEnd = endVector.some((value) => value !== 0);
        if (!hasStart && !hasEnd) return null;

        const movement = laser.movement && typeof laser.movement === 'object'
            ? {
                direction: String(laser.movement.direction || 'none'),
                amount: Number(laser.movement.amount ?? 0) || 0,
                speed: Number(laser.movement.speed ?? 0.007) || 0.007,
            }
            : null;

        return {
            id: String(laser.id || `laser_${index + 1}`),
            startVector,
            endVector,
            intensity: Number(laser.intensity ?? 100) || 100,
            movement,
        };
    }

    function normalizeHouseSecurityKeypad(keypad = {}) {
        const coords = keypad.coords || {};
        const hasCoords = Array.isArray(coords)
            ? coords.length >= 3
            : ['x', 'y', 'z', 0, 1, 2].some((key) => coords[key] !== undefined);
        if (!hasCoords) return null;

        const x = Number(coords.x ?? coords[0] ?? 0) || 0;
        const y = Number(coords.y ?? coords[1] ?? 0) || 0;
        const z = Number(coords.z ?? coords[2] ?? 0) || 0;
        const minigameType = String(keypad.minigameType || keypad.minigameOption || 'none').trim() || 'none';

        return {
            prop: String(keypad.prop || 'prop_ld_keypad_01b'),
            label: String(keypad.label || 'Security Keypad'),
            coords: { x, y, z },
            heading: Number(keypad.heading ?? 0) || 0,
            placed: hasCoords,
            minigameCheckbox: keypad.minigameCheckbox === true || minigameType !== 'none',
            minigameType,
        };
    }

    function resolveHouseSecurityMinigameType(securitySystem = {}) {
        const keypad = securitySystem.keypad || {};
        const topLevelType = String(securitySystem.minigameType || securitySystem.minigameOption || '').trim();
        const keypadType = String(keypad.minigameType || keypad.minigameOption || '').trim();
        if (topLevelType && topLevelType !== 'none') return topLevelType;
        if (keypadType && keypadType !== 'none') return keypadType;
        return topLevelType || keypadType || 'none';
    }

    function isHouseZeroCoords(coords = {}) {
        const x = Number(coords.x ?? coords[0] ?? 0) || 0;
        const y = Number(coords.y ?? coords[1] ?? 0) || 0;
        const z = Number(coords.z ?? coords[2] ?? 0) || 0;
        return x === 0 && y === 0 && z === 0;
    }

    function normalizeHouseSecuritySystem(securitySystem = {}) {
        const keypad = normalizeHouseSecurityKeypad(securitySystem.keypad || securitySystem.keypadPoint || {});
        const securityExplicitlyUnplaced = securitySystem.isPlaced === false
            || securitySystem.placed === false
            || securitySystem.keypad?.placed === false;
        const securityHasPlacedCoords = !!keypad?.placed && !isHouseZeroCoords(keypad.coords);
        const securityIsPlaced = !securityExplicitlyUnplaced && securityHasPlacedCoords;
        const minigameType = resolveHouseSecurityMinigameType(securitySystem);
        const hasExplicitXpOptions = Object.prototype.hasOwnProperty.call(securitySystem, 'xpOptions');
        const hasSecurityXpSettings = Number(securitySystem.xpRewardAmount ?? 0) > 0
            || Number(securitySystem.xpNeededAmount ?? 0) > 0
            || securitySystem.removeXpOnHit === true
            || Number(securitySystem.xpRemoveAmount ?? 0) > 0;
        const xpOptionsEnabled = hasExplicitXpOptions
            ? securitySystem.xpOptions === true
            : hasSecurityXpSettings;
        return {
            id: String(securitySystem.id || 'security_system'),
            label: String(securitySystem.label || keypad?.label || 'Security System'),
            numberValue: String(securitySystem.numberValue ?? 'security'),
            isPlaced: securityIsPlaced,
            coords: keypad?.coords || { x: 0, y: 0, z: 0 },
            heading: Number(securitySystem.heading ?? keypad?.heading ?? 0) || 0,
            pedCoords: keypad?.coords || { x: 0, y: 0, z: 0 },
            pedHeading: Number(securitySystem.pedHeading ?? securitySystem.heading ?? keypad?.heading ?? 0) || 0,
            prop: String(securitySystem.prop || keypad?.prop || 'prop_ld_keypad_01b'),
            animation: String(securitySystem.animation || ''),
            propHeading: Number(securitySystem.propHeading ?? securitySystem.heading ?? keypad?.heading ?? 0) || 0,
            createChance: String(securitySystem.createChance ?? securitySystem.targetCreateChance ?? securitySystem.spawnChance ?? '100'),
            minigameCheckbox: securitySystem.minigameCheckbox === true || securitySystem.keypad?.minigameCheckbox === true || minigameType !== 'none',
            minigameType,
            failPoliceChance: String(securitySystem.failPoliceChance ?? securitySystem.alertChance ?? '0'),
            requiresItem: securitySystem.requiresItem === true || Array.isArray(securitySystem.requiredItems) && securitySystem.requiredItems.length > 0,
            requiredItems: Array.isArray(securitySystem.requiredItems) ? securitySystem.requiredItems.map((item) => ({
                itemName: String(item.itemName || ''),
                amount: String(item.amount ?? 1),
                chance: String(item.chance ?? 100),
            })) : [],
            rewardItem: securitySystem.rewardItem === true || Array.isArray(securitySystem.rewardItems) && securitySystem.rewardItems.length > 0,
            rewardItems: Array.isArray(securitySystem.rewardItems) ? securitySystem.rewardItems.map((item) => ({
                itemName: String(item.itemName || ''),
                minAmount: String(item.minAmount ?? 1),
                maxAmount: String(item.maxAmount ?? 1),
                chance: String(item.chance ?? 100),
            })) : [],
            rewardMoney: securitySystem.rewardMoney === true,
            rewardMoneyType: String(securitySystem.rewardMoneyType || securitySystem.rewardType || 'cash'),
            rewardMoneyMin: String(securitySystem.rewardMoneyMin ?? securitySystem.minMoney ?? '1'),
            rewardMoneyMax: String(securitySystem.rewardMoneyMax ?? securitySystem.maxMoney ?? '1'),
            moneyChance: String(securitySystem.moneyChance ?? '100'),
            xpOptions: xpOptionsEnabled,
            xpRewardAmount: String(securitySystem.xpRewardAmount ?? '0'),
            xpNeededAmount: String(securitySystem.xpNeededAmount ?? '0'),
            removeXpOnHit: xpOptionsEnabled && securitySystem.removeXpOnHit === true,
            xpRemoveAmount: String(securitySystem.xpRemoveAmount ?? '0'),
            delayRewardCheckbox: securitySystem.delayRewardCheckbox === true || Number(securitySystem.rewardDelayTime ?? 0) > 0,
            rewardDelayTime: String(securitySystem.rewardDelayTime ?? '1'),
            requireWeaponInHand: securitySystem.requireWeaponInHand === true || Array.isArray(securitySystem.requiredWeapons) && securitySystem.requiredWeapons.length > 0,
            requiredWeapons: Array.isArray(securitySystem.requiredWeapons) ? securitySystem.requiredWeapons.map((weapon) => String(weapon || '').trim()).filter(Boolean) : [],
            keypad: keypad ? {
                ...keypad,
                minigameCheckbox: securitySystem.minigameCheckbox === true || keypad.minigameCheckbox === true || minigameType !== 'none',
                minigameType,
            } : keypad,
            lasers: Array.isArray(securitySystem.lasers)
                ? securitySystem.lasers.map(normalizeHouseSecurityLaser).filter(Boolean)
                : [],
        };
    }

    function normalizeHouseHomeOwner(homeOwner = {}) {
        const coords = homeOwner.coords || {};
        const hasCoords = Array.isArray(coords)
            ? coords.length >= 3
            : ['x', 'y', 'z', 0, 1, 2].some((key) => coords[key] !== undefined);

        const x = hasCoords ? (Number(coords.x ?? 0) || 0) : 0;
        const y = hasCoords ? (Number(coords.y ?? 0) || 0) : 0;
        const z = hasCoords ? (Number(coords.z ?? 0) || 0) : 0;
        const homeOwnerExplicitlyUnplaced = homeOwner.isPlaced === false || homeOwner.placed === false;
        const homeOwnerIsPlaced = !homeOwnerExplicitlyUnplaced && hasCoords && !isHouseZeroCoords({ x, y, z });

        return {
            id: String(homeOwner.id || 'home_owner'),
            label: String(homeOwner.label || 'Home Owner'),
            numberValue: String(homeOwner.numberValue ?? 'owner'),
            isPlaced: homeOwnerIsPlaced,
            model: String(homeOwner.model || 'mp_m_freemode_01'),
            stance: String(homeOwner.stance || 'sleeping'),
            coords: { x, y, z },
            heading: Number(homeOwner.heading ?? 0) || 0,
            pedCoords: { x, y, z },
            pedHeading: Number(homeOwner.pedHeading ?? homeOwner.heading ?? 0) || 0,
            prop: String(homeOwner.prop || ''),
            animation: String(homeOwner.animation || ''),
            propHeading: Number(homeOwner.propHeading ?? homeOwner.heading ?? 0) || 0,
            minigameCheckbox: homeOwner.minigameCheckbox === true || (String(homeOwner.minigameType || 'none') !== 'none'),
            minigameType: String(homeOwner.minigameType || 'none'),
            failPoliceChance: String(homeOwner.failPoliceChance ?? homeOwner.alertChance ?? '0'),
            requiresItem: homeOwner.requiresItem === true || Array.isArray(homeOwner.requiredItems) && homeOwner.requiredItems.length > 0,
            requiredItems: Array.isArray(homeOwner.requiredItems) ? homeOwner.requiredItems.map((item) => ({
                itemName: String(item.itemName || ''),
                amount: String(item.amount ?? 1),
                chance: String(item.chance ?? 100),
            })) : [],
            rewardItem: homeOwner.rewardItem === true || Array.isArray(homeOwner.rewardItems) && homeOwner.rewardItems.length > 0,
            rewardItems: Array.isArray(homeOwner.rewardItems) ? homeOwner.rewardItems.map((item) => ({
                itemName: String(item.itemName || ''),
                minAmount: String(item.minAmount ?? 1),
                maxAmount: String(item.maxAmount ?? 1),
                chance: String(item.chance ?? 100),
            })) : [],
            rewardMoney: homeOwner.rewardMoney === true,
            rewardMoneyType: String(homeOwner.rewardMoneyType || homeOwner.rewardType || 'cash'),
            rewardMoneyMin: String(homeOwner.rewardMoneyMin ?? homeOwner.minMoney ?? '1'),
            rewardMoneyMax: String(homeOwner.rewardMoneyMax ?? homeOwner.maxMoney ?? '1'),
            moneyChance: String(homeOwner.moneyChance ?? '100'),
            delayRewardCheckbox: homeOwner.delayRewardCheckbox === true || Number(homeOwner.rewardDelayTime ?? 0) > 0,
            rewardDelayTime: String(homeOwner.rewardDelayTime ?? '1'),
            requireWeaponInHand: homeOwner.requireWeaponInHand === true || Array.isArray(homeOwner.requiredWeapons) && homeOwner.requiredWeapons.length > 0,
            requiredWeapons: Array.isArray(homeOwner.requiredWeapons) ? homeOwner.requiredWeapons.map((weapon) => String(weapon || '').trim()).filter(Boolean) : [],
            animDict: String(homeOwner.animDict || 'timetable@tracy@sleep@'),
            animAction: String(homeOwner.animAction || 'idle_c'),
        };
    }

    function normalizePreset(preset = {}, index = 0) {
        const lootPoints = ensureUniqueHouseLootPointIds(
            Array.isArray(preset.lootPoints) ? preset.lootPoints.map(normalizePoint) : []
        );
        return {
            id: String(preset.id || `preset_${index + 1}`),
            label: String(preset.label || `Preset ${index + 1}`),
            lootPoints,
            securitySystem: normalizeHouseSecuritySystem(preset.securitySystem || {}),
            homeOwner: normalizeHouseHomeOwner(preset.homeOwner || {}),
        };
    }

    function cloneHouseValue(value) {
        if (typeof structuredClone === 'function') {
            try {
                return structuredClone(value);
            } catch (error) {}
        }

        try {
            return JSON.parse(JSON.stringify(value));
        } catch (error) {
            return value;
        }
    }

    function isHouseLootPointPlaced(point) {
        return !!point && point.isPlaced === true && !isHouseZeroCoords(point.coords || {});
    }

    function needsHousePointPlacement(point, index) {
        if (!point) return true;
        if (index === HOUSE_SECURITY_TAB_INDEX || index === HOUSE_HOME_OWNER_TAB_INDEX) {
            return point.isPlaced !== true || isHouseZeroCoords(point.coords || {});
        }
        return !isHouseLootPointPlaced(point);
    }

    function resetHouseLootPointPlacement(point = {}, index = 0) {
        const template = normalizePoint(cloneHouseValue(point), index);
        template.coords = { x: 0, y: 0, z: 0 };
        template.pedCoords = { x: 0, y: 0, z: 0 };
        template.heading = 0;
        template.pedHeading = 0;
        template.propHeading = 0;
        template.isPlaced = false;
        template.placed = false;
        return template;
    }

    function resetHouseSecurityPlacement(securitySystem = {}) {
        const template = normalizeHouseSecuritySystem(cloneHouseValue(securitySystem));
        template.coords = { x: 0, y: 0, z: 0 };
        template.pedCoords = { x: 0, y: 0, z: 0 };
        template.heading = 0;
        template.pedHeading = 0;
        template.propHeading = 0;
        template.isPlaced = false;
        template.keypad = {
            prop: template.prop || 'prop_ld_keypad_01b',
            label: template.label || 'Security Keypad',
            coords: { x: 0, y: 0, z: 0 },
            heading: 0,
            placed: false,
            minigameCheckbox: template.minigameCheckbox === true,
            minigameType: template.minigameType || 'none',
        };
        template.lasers = [];
        return template;
    }

    function resetHouseHomeOwnerPlacement(homeOwner = {}) {
        const template = normalizeHouseHomeOwner(cloneHouseValue(homeOwner));
        template.coords = { x: 0, y: 0, z: 0 };
        template.pedCoords = { x: 0, y: 0, z: 0 };
        template.heading = 0;
        template.pedHeading = 0;
        template.propHeading = 0;
        template.isPlaced = false;
        return template;
    }

    function getUniqueHousePresetLabel(shell, requestedLabel) {
        const base = String(requestedLabel || `Preset ${(shell?.presets?.length || 0) + 1}`).trim() || `Preset ${(shell?.presets?.length || 0) + 1}`;
        const used = new Set((shell?.presets || []).map((preset, index) => String(preset.label || `Preset ${index + 1}`).trim().toLowerCase()));
        if (!used.has(base.toLowerCase())) return base;

        let suffix = 2;
        while (used.has(`${base} ${suffix}`.toLowerCase())) {
            suffix += 1;
        }
        return `${base} ${suffix}`;
    }

    function getHousePastedPresetLabel(shell, sourceLabel) {
        const base = String(sourceLabel || `Preset ${(shell?.presets?.length || 0) + 1}`).trim() || `Preset ${(shell?.presets?.length || 0) + 1}`;
        const used = new Set((shell?.presets || []).map((preset, index) => String(preset.label || `Preset ${index + 1}`).trim().toLowerCase()));
        if (!used.has(base.toLowerCase())) return base;
        return getUniqueHousePresetLabel(shell, `${base} Copy`);
    }

    function buildHousePresetPlacementTemplate(sourcePreset, shell) {
        const source = normalizePreset(cloneHouseValue(sourcePreset), (shell?.presets?.length || 0));
        return normalizePreset({
            id: `preset_${Date.now()}`,
            label: getHousePastedPresetLabel(shell, source.label),
            lootPoints: (source.lootPoints || []).map(resetHouseLootPointPlacement),
            securitySystem: resetHouseSecurityPlacement(source.securitySystem),
            homeOwner: resetHouseHomeOwnerPlacement(source.homeOwner),
        }, shell?.presets?.length || 0);
    }

    function updateHousePresetClipboardButtons() {
        const button = document.getElementById('pasteHousePresetButton');
        if (!button) return;
        const hasClipboard = !!housePresetClipboard?.preset;
        button.disabled = !hasClipboard;
        button.classList.toggle('is-disabled', !hasClipboard);
        const tooltip = button.querySelector('.tooltip-text');
        if (tooltip) {
            tooltip.textContent = hasClipboard
                ? `Paste copied preset: ${housePresetClipboard.preset.label || 'Preset'}`
                : 'Copy a preset before pasting';
        }
    }

    function copyHousePresetToClipboard(shell, preset) {
        if (!preset) return;
        saveHouseShellEditorToState();
        const copiedPreset = normalizePreset(cloneHouseValue(preset), 0);
        housePresetClipboard = {
            sourceShellId: String(shell?.id || ''),
            sourceShellLabel: String(shell?.label || shell?.model || 'Shell Profile'),
            preset: copiedPreset,
            copiedAt: Date.now(),
        };
        updateHousePresetClipboardButtons();
        notifyHousePreset(`Copied ${copiedPreset.label || 'preset'}. Paste it to another shell profile, then place each copied point.`, 'success');
    }

    function pasteHousePresetToSelectedShell(event) {
        event?.preventDefault?.();
        saveHouseShellEditorToState();
        const shell = getSelectedShell();
        if (!shell) return;
        if (!housePresetClipboard?.preset) {
            notifyHousePreset('Copy a preset before pasting.', 'error');
            updateHousePresetClipboardButtons();
            return;
        }

        shell.presets = Array.isArray(shell.presets) ? shell.presets : [];
        const pastedPreset = buildHousePresetPlacementTemplate(housePresetClipboard.preset, shell);
        shell.presets.push(pastedPreset);
        houseRobberyUiState.selectedPresetIndex = shell.presets.length - 1;
        const firstLootIndex = (pastedPreset.lootPoints || []).findIndex((point) => !isHouseLootPointPlaced(point));
        houseRobberyUiState.selectedPointIndex = firstLootIndex >= 0 ? firstLootIndex : HOUSE_SECURITY_TAB_INDEX;
        houseRobberyUiState.pointManagerOpen = true;
        renderShellList();
        renderShellEditor();
        notifyHousePreset(`Pasted ${pastedPreset.label || 'preset'} as a placement template. Place each point before saving it live.`, 'success');
    }

    function getPendingHouseLootPlacementIndex(preset) {
        const index = Number(houseRobberyUiState.selectedPointIndex);
        if (!preset || index < 0 || !Array.isArray(preset.lootPoints)) return -1;
        const point = preset.lootPoints[index];
        return point && !isHouseLootPointPlaced(point) ? index : -1;
    }

    function getSelectedHouseLootPlacementIndex(preset) {
        const index = Number(houseRobberyUiState.selectedPointIndex);
        if (!preset || index < 0 || !Array.isArray(preset.lootPoints)) return -1;
        return preset.lootPoints[index] ? index : -1;
    }

    function findNextPendingHouseLootPlacementIndex(preset, startIndex = 0) {
        if (!preset || !Array.isArray(preset.lootPoints)) return -1;
        for (let index = Math.max(0, Number(startIndex) || 0); index < preset.lootPoints.length; index += 1) {
            if (preset.lootPoints[index] && !isHouseLootPointPlaced(preset.lootPoints[index])) {
                return index;
            }
        }
        return -1;
    }

    function applyHouseLootPointPlacement(target, placement, index = 0) {
        if (!target || !placement) return false;
        const placed = normalizePoint(placement, index);
        target.coords = placed.coords;
        target.pedCoords = placed.pedCoords;
        target.heading = placed.heading;
        target.pedHeading = placed.pedHeading;
        target.prop = placed.prop;
        target.animation = placed.animation;
        target.propHeading = placed.propHeading;
        target.isPlaced = true;
        target.placed = true;
        target.id = target.id || placed.id || `loot_${index + 1}`;
        target.numberValue = target.numberValue || String(index + 1);
        if (!String(target.label || '').trim()) {
            target.label = placed.label || 'Search';
        }
        return true;
    }

    function applyHouseSecurityPlacement(target, placement) {
        const current = normalizeHouseSecuritySystem(target || {});
        const placed = normalizeHouseSecuritySystem(placement || {});
        const minigameType = resolveHouseSecurityMinigameType({
            minigameType: current.minigameType,
            minigameOption: placed.minigameType,
            keypad: {
                minigameType: current.keypad?.minigameType || placed.keypad?.minigameType,
                minigameOption: placed.keypad?.minigameType,
            },
        });
        const next = {
            ...current,
            id: current.id || placed.id || 'security_system',
            numberValue: current.numberValue || placed.numberValue || 'security',
            isPlaced: placed.isPlaced,
            coords: placed.coords,
            heading: placed.heading,
            pedCoords: placed.pedCoords,
            pedHeading: placed.pedHeading,
            prop: placed.prop,
            animation: current.animation || placed.animation,
            propHeading: placed.propHeading,
            minigameCheckbox: current.minigameCheckbox === true || placed.minigameCheckbox === true || minigameType !== 'none',
            minigameType,
            keypad: placed.keypad ? {
                ...placed.keypad,
                minigameCheckbox: current.minigameCheckbox === true || placed.minigameCheckbox === true || minigameType !== 'none',
                minigameType,
            } : placed.keypad,
            lasers: placed.lasers,
        };

        if (!String(current.label || '').trim()) {
            next.label = placed.label || 'Security System';
        }

        return normalizeHouseSecuritySystem(next);
    }

    function getShellConfigByModel(model) {
        return getConfiguredHouseShells().find((entry) => String(entry.model || '') === String(model || '')) || null;
    }

    function getHouseShellDisplayName(model) {
        const configured = getShellConfigByModel(model);
        return String(configured?.label || model || 'Unknown Shell');
    }

    function normalizeShell(shell = {}, index = 0) {
        const configured = getShellConfigByModel(shell.model);
        const fallbackExit = configured?.enterOffset || { x: 1.46, y: -10.33, z: 1.06, w: 0.0 };
        const exit = shell.enterOffset || {};
        return {
            id: String(shell.id || `shell_${index + 1}`),
            label: String(shell.label || configured?.label || shell.model || `Shell ${index + 1}`),
            model: String(shell.model || configured?.model || ''),
            shellType: String(shell.shellType || shell.type || configured?.shellType || configured?.type || (configured?.isWorldInterior ? 'world' : 'shell')),
            isWorldInterior: shell.isWorldInterior === true || configured?.isWorldInterior === true || String(shell.shellType || shell.type || configured?.shellType || configured?.type || '').toLowerCase() === 'world',
            enterOffset: {
                x: Number(exit.x ?? fallbackExit.x ?? 0) || 0,
                y: Number(exit.y ?? fallbackExit.y ?? 0) || 0,
                z: Number(exit.z ?? fallbackExit.z ?? 0) || 0,
                w: Number(exit.w ?? exit.h ?? fallbackExit.w ?? fallbackExit.h ?? 0) || 0,
            },
            presets: Array.isArray(shell.presets) ? shell.presets.map(normalizePreset) : [],
        };
    }

    function normalizeLocation(location = {}, index = 0, globalAlertSettings = null) {
        const entry = location.entry || {};
        const defaults = getHouseLocationDefaults();
        const alertSettings = normalizeHouseAlertSettings(globalAlertSettings || location);
        const hasExplicitXpOptions = Object.prototype.hasOwnProperty.call(location, 'xpOptions');
        const hasLocationXpSettings = Number(location.xpRewardAmount ?? 0) > 0
            || Number(location.xpNeededAmount ?? 0) > 0
            || location.removeXpOnHit === true
            || Number(location.xpRemoveAmount ?? 0) > 0;
        const xpOptionsEnabled = hasExplicitXpOptions ? location.xpOptions === true : (defaults.xpOptions || hasLocationXpSettings);
        return {
            id: String(location.id || `location_${index + 1}`),
            label: String(location.label || `House Robbery ${index + 1}`),
            streetName: String(location.streetName || ''),
            enabled: location.enabled !== false,
            interactionLabel: String(location.interactionLabel || defaults.interactionLabel),
            progressLabel: String(location.progressLabel || defaults.progressLabel),
            progressDuration: Number(location.progressDuration ?? defaults.progressDuration) || defaults.progressDuration,
            policeRequired: Number(alertSettings.policeRequired ?? defaults.policeRequired) || defaults.policeRequired,
            cooldown: Number(alertSettings.cooldown ?? defaults.cooldown) || defaults.cooldown,
            alertChance: alertSettings.alertChance,
            minigameOption: String(location.minigameOption || defaults.minigameOption),
            sendAlert: !!alertSettings.sendAlert,
            policeAlertHeader: alertSettings.policeAlertHeader,
            policeAlert: alertSettings.policeAlert,
            policeJobs: [...alertSettings.policeJobs],
            alertCode: alertSettings.alertCode,
            alertIcon: alertSettings.alertIcon,
            alertPriority: alertSettings.alertPriority,
            alertCamId: alertSettings.alertCamId,
            blipSprite: alertSettings.blipSprite,
            blipColor: alertSettings.blipColor,
            blipScale: alertSettings.blipScale,
            alertSound1: alertSettings.alertSound1,
            blipFlash: !!alertSettings.blipFlash,
            moneyReward: location.moneyReward === undefined ? defaults.moneyReward : !!location.moneyReward,
            rewardType: String(location.rewardType || defaults.rewardType),
            minMoney: String(location.minMoney ?? defaults.minMoney),
            maxMoney: String(location.maxMoney ?? defaults.maxMoney),
            moneyChance: String(location.moneyChance ?? defaults.moneyChance),
            xpOptions: xpOptionsEnabled,
            xpRewardAmount: String(location.xpRewardAmount ?? defaults.xpRewardAmount),
            xpNeededAmount: String(location.xpNeededAmount ?? defaults.xpNeededAmount),
            removeXpOnHit: xpOptionsEnabled && location.removeXpOnHit === true,
            xpRemoveAmount: String(location.xpRemoveAmount ?? defaults.xpRemoveAmount),
            requiredItems: Array.isArray(location.requiredItems) ? location.requiredItems : [],
            rewardItems: Array.isArray(location.rewardItems) ? location.rewardItems : [],
            shellIds: Array.isArray(location.shellIds) ? location.shellIds.map((id) => String(id || '').trim()).filter(Boolean) : [],
            presetSelections: (location.presetSelections && typeof location.presetSelections === 'object') ? location.presetSelections : {},
            entry: {
                coords: {
                    x: Number(entry.coords?.x ?? 0) || 0,
                    y: Number(entry.coords?.y ?? 0) || 0,
                    z: Number(entry.coords?.z ?? 0) || 0,
                },
                heading: Number(entry.heading ?? 0) || 0,
            },
        };
    }

    function normalizeHouseRobberyData(data) {
        const input = (typeof data === 'string' && data.trim()) ? JSON.parse(data) : (data && typeof data === 'object' ? data : {});
        const settingsSeed = input.settings || input.globalAlertSettings || input.alertSettings || (Array.isArray(input.locations) && input.locations[0]) || {};
        const normalizedSettings = normalizeHouseAlertSettings(settingsSeed);
        return {
            settings: normalizedSettings,
            shells: Array.isArray(input.shells) ? input.shells.map(normalizeShell) : [],
            locations: Array.isArray(input.locations) ? input.locations.map((location, index) => normalizeLocation(location, index, normalizedSettings)) : [],
            batchLocationSettings: normalizeHouseBatchLocationSettings(input.batchLocationSettings || input.bulkLocationSettings || {}),
        };
    }

    function populateShellModelSelect(selectId, selectedModel = '') {
        const select = document.getElementById(selectId);
        if (!select) return;
        select.innerHTML = '';
        getConfiguredHouseShells().forEach((entry) => {
            const option = document.createElement('option');
            option.value = entry.model;
            option.textContent = entry.label || entry.model;
            if (entry.model === selectedModel) option.selected = true;
            select.appendChild(option);
        });
    }

    function copySelectOptions(sourceId, targetId) {
        const source = document.getElementById(sourceId);
        const target = document.getElementById(targetId);
        if (!source || !target) return;
        target.innerHTML = source.innerHTML;
    }

    function populateHouseAlertSelects() {
        copySelectOptions('alertIcon', 'houseGlobalAlertIcon');
        copySelectOptions('alertPriority', 'houseGlobalAlertPriority');
        copySelectOptions('blipColor', 'houseGlobalBlipColor');
        copySelectOptions('alertSound1', 'houseGlobalAlertSound1');
        copySelectOptions('blipFlash', 'houseGlobalBlipFlash');
    }

    function refreshHouseRobberySelects(root) {
        const scope = root || document;
        [
            { id: '#houseShellModelSelect', placeholder: 'Search shell...', emptyLabel: 'Select shell' },
            { id: '#houseGlobalAlertIcon', placeholder: 'Search icon...', emptyLabel: 'Select alert icon' },
            { id: '#houseGlobalAlertPriority', placeholder: 'Search priority...', emptyLabel: 'Select alert priority' },
            { id: '#houseGlobalBlipColor', placeholder: 'Search color...', emptyLabel: 'Select blip color' },
            { id: '#houseGlobalAlertSound1', placeholder: 'Search sound...', emptyLabel: 'Select alert sound' },
            { id: '#houseGlobalBlipFlash', placeholder: 'Search option...', emptyLabel: 'Select blip flash' },
        ].forEach((entry) => {
            scope.querySelectorAll(`select${entry.id}`).forEach((sel) => {
                rcWrapSelectWithSearch(sel, {
                    placeholder: entry.placeholder,
                    populate: false,
                    emptyLabel: entry.emptyLabel,
                    getItems: () => Array.from(sel.options || []).map((opt) => ({
                        value: String(opt.value ?? ''),
                        label: String(opt.textContent ?? ''),
                    })),
                });
            });
        });

        const minigameSel = scope.querySelector('#houseLocationMinigame');
        if (minigameSel) {
            rcWrapSelectWithSearch(minigameSel, {
                placeholder: 'Search minigame...',
                getItems: rcMiniGameOptions,
                emptyLabel: 'Select minigame',
            });
        }

        const rewardTypeSel = scope.querySelector('#houseLocationRewardType');
        if (rewardTypeSel) {
            rcWrapSelectWithSearch(rewardTypeSel, {
                placeholder: 'Search type...',
                getItems: rcRewardTypeOptions,
                populate: false,
                emptyLabel: 'Select type',
            });
        }
    }

    function formatPlacementMeta(data) {
        if (!data || !data.coords) return 'Not placed yet.';
        const coords = data.coords;
        return `${Number(coords.x || 0).toFixed(2)}, ${Number(coords.y || 0).toFixed(2)}, ${Number(coords.z || 0).toFixed(2)} | H ${Number(data.heading || 0).toFixed(2)}`;
    }

    function hasHousePlacementCoords(data) {
        const coords = data?.coords;
        if (!coords || typeof coords !== 'object') return false;
        return ['x', 'y', 'z', 0, 1, 2].some((key) => coords[key] !== undefined && coords[key] !== null);
    }

    function formatHouseVectorMeta(vector) {
        const values = normalizeHouseLaserVector(vector);
        return `${values[0].toFixed(2)}, ${values[1].toFixed(2)}, ${values[2].toFixed(2)}`;
    }

    function getSelectedShell() {
        return houseRobberyData.shells[houseRobberyUiState.selectedShellIndex] || null;
    }

    function getSelectedPreset() {
        const shell = getSelectedShell();
        if (!shell) return null;
        return shell.presets[houseRobberyUiState.selectedPresetIndex] || null;
    }

    function getSelectedLocation() {
        return houseRobberyData.locations[houseRobberyUiState.selectedLocationIndex] || null;
    }

    function getHouseSpecialPointType(index = houseRobberyUiState.selectedPointIndex) {
        if (index === HOUSE_SECURITY_TAB_INDEX) return 'security';
        if (index === HOUSE_HOME_OWNER_TAB_INDEX) return 'homeOwner';
        return 'loot';
    }

    function getPointForSelectionIndex(preset, index = houseRobberyUiState.selectedPointIndex) {
        if (!preset) return null;
        const type = getHouseSpecialPointType(index);
        if (type === 'security') {
            preset.securitySystem = normalizeHouseSecuritySystem(preset.securitySystem || {});
            return preset.securitySystem;
        }
        if (type === 'homeOwner') {
            preset.homeOwner = normalizeHouseHomeOwner(preset.homeOwner || {});
            return preset.homeOwner;
        }
        return preset.lootPoints[index] || null;
    }

    function getSelectedPoint() {
        const preset = getSelectedPreset();
        return getPointForSelectionIndex(preset);
    }

    function getHouseTabEntries(preset = getSelectedPreset()) {
        if (!preset) return [];
        const securityPoint = getPointForSelectionIndex(preset, HOUSE_SECURITY_TAB_INDEX);
        const homeOwnerPoint = getPointForSelectionIndex(preset, HOUSE_HOME_OWNER_TAB_INDEX);
        return [
            { index: HOUSE_SECURITY_TAB_INDEX, type: 'security', point: securityPoint },
            { index: HOUSE_HOME_OWNER_TAB_INDEX, type: 'homeOwner', point: homeOwnerPoint },
            ...(preset.lootPoints || []).map((point, lootIndex) => ({ index: lootIndex, type: 'loot', point })),
        ];
    }

    function getSelectedHouseTabEntry() {
        const preset = getSelectedPreset();
        if (!preset) return null;
        return getHouseTabEntries(preset).find((entry) => entry.index === houseRobberyUiState.selectedPointIndex) || null;
    }

    function getHousePointEditorKey(index = houseRobberyUiState.selectedPointIndex) {
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        const point = getPointForSelectionIndex(preset, index);
        const type = getHouseSpecialPointType(index);
        const shellKey = String(shell?.id || shell?.model || houseRobberyUiState.selectedShellIndex);
        const presetKey = String(preset?.id || houseRobberyUiState.selectedPresetIndex);
        const pointKey = type === 'loot' ? String(point?.id || index) : type;
        return `${shellKey}|${presetKey}|${type}|${index}|${pointKey}`;
    }

    function isHousePointEditorReadyToSave(panel) {
        const manager = document.getElementById('housePointManagerView');
        if (!panel || !houseRobberyUiState.pointManagerOpen || housePointEditorRenderDepth > 0) return false;
        if (panel.style.display === 'none' || manager?.style.display === 'none') return false;
        const renderedKey = panel.dataset.housePointEditorKey || '';
        return !renderedKey || renderedKey === getHousePointEditorKey();
    }

    async function exitHousePointPreview(force = false) {
        if (!force && !housePointPreviewState.active) return;
        housePointPreviewState = {
            active: false,
            shellKey: '',
            presetKey: '',
            pointIndex: -1,
        };
        try {
            await fetch(`https://${GetParentResourceName()}/ExitHousePointPreview`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({}),
            });
        } catch (error) {
            console.error('Failed to exit house point preview:', error);
        }
    }

    async function focusHousePointPreview(index = houseRobberyUiState.selectedPointIndex) {
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        const point = getPointForSelectionIndex(preset, index);
        if (!shell || !preset || !point) {
            await exitHousePointPreview();
            return;
        }

        const shellKey = String(shell.id || shell.model || '');
        const presetKey = String(preset.id || '');
        const type = getHouseSpecialPointType(index);
        if (needsHousePointPlacement(point, index)) {
            await exitHousePointPreview();
            return;
        }

        if (
            housePointPreviewState.active
            && housePointPreviewState.shellKey === shellKey
            && housePointPreviewState.presetKey === presetKey
            && housePointPreviewState.pointIndex === index
        ) {
            return;
        }

        try {
            const endpoint = type === 'loot' ? 'FocusHousePointPreview' : 'FocusHouseSpecialPreview';
            const payload = type === 'loot'
                ? { shell, preset, pointIndex: index + 1 }
                : { shell, preset, coords: point.coords, heading: point.heading || 0, isPlaced: point.isPlaced === true, type };
            const response = await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
            });
            const result = await response.json();
            if (!result?.success) {
                throw new Error(result?.error || 'Failed to focus preview point.');
            }
            housePointPreviewState = {
                active: true,
                shellKey,
                presetKey,
                pointIndex: index,
            };
        } catch (error) {
            console.error('Failed to focus house point preview:', error);
        }
    }

    function getHousePointDisplayName(point, index) {
        if (index === HOUSE_SECURITY_TAB_INDEX) return String(point?.label || 'Security System');
        if (index === HOUSE_HOME_OWNER_TAB_INDEX) return String(point?.label || 'Home Owner');
        const raw = String(point?.label || '').trim();
        if (raw && !/^\d+$/.test(raw)) return raw;
        return `Point ${index + 1}`;
    }

    function clampHouseSelections() {
        if (!houseRobberyData.shells.length) {
            houseRobberyUiState.selectedShellIndex = 0;
            houseRobberyUiState.selectedPresetIndex = 0;
            houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
        } else {
            houseRobberyUiState.selectedShellIndex = Math.min(
                houseRobberyUiState.selectedShellIndex,
                houseRobberyData.shells.length - 1
            );
            const shell = getSelectedShell();
            const presetCount = Array.isArray(shell?.presets) ? shell.presets.length : 0;
            houseRobberyUiState.selectedPresetIndex = presetCount > 0
                ? Math.min(houseRobberyUiState.selectedPresetIndex, presetCount - 1)
                : 0;
            const preset = getSelectedPreset();
            const pointCount = Array.isArray(preset?.lootPoints) ? preset.lootPoints.length : 0;
            if (houseRobberyUiState.selectedPointIndex >= 0) {
                houseRobberyUiState.selectedPointIndex = pointCount > 0
                    ? Math.min(houseRobberyUiState.selectedPointIndex, pointCount - 1)
                    : HOUSE_SECURITY_TAB_INDEX;
            } else if (![HOUSE_SECURITY_TAB_INDEX, HOUSE_HOME_OWNER_TAB_INDEX].includes(houseRobberyUiState.selectedPointIndex)) {
                houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
            }
        }

        houseRobberyUiState.selectedLocationIndex = houseRobberyData.locations.length
            ? Math.min(houseRobberyUiState.selectedLocationIndex, houseRobberyData.locations.length - 1)
            : 0;
    }

    function saveHouseShellEditorToState() {
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        const shellEditor = document.getElementById('houseShellEditor');
        if (!shell || !shellEditor || shellEditor.style.display === 'none') return;

        saveHousePointSettingsFromPanel();

        const selectedModel = document.getElementById('houseShellEditorModel')?.value || '';
        shell.model = shell.model || selectedModel;
        shell.enterOffset = {
            x: Number(document.getElementById('houseShellExitX')?.value ?? shell.enterOffset.x) || 0,
            y: Number(document.getElementById('houseShellExitY')?.value ?? shell.enterOffset.y) || 0,
            z: Number(document.getElementById('houseShellExitZ')?.value ?? shell.enterOffset.z) || 0,
            w: Number(document.getElementById('houseShellExitH')?.value ?? shell.enterOffset.w) || 0,
        };

    }

    function collectHouseRequiredItems(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return [];
        return Array.from(panel.querySelectorAll('.section')).map((row) => ({
            itemName: row.querySelector('.item-name')?.value?.trim() || '',
            amount: row.querySelector('.item-quantity')?.value || 1,
            chance: row.querySelector('.lose-chance')?.value || 100,
        })).filter((item) => item.itemName);
    }

    function collectHouseRewardItems(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return [];
        return Array.from(panel.querySelectorAll('.reward-item')).map((row) => ({
            itemName: row.querySelector('.reward-item-name')?.value?.trim() || '',
            minAmount: row.querySelector('.reward-item-min')?.value || 1,
            maxAmount: row.querySelector('.reward-item-max')?.value || 1,
            chance: row.querySelector('.reward-item-chance')?.value || 100,
        })).filter((item) => item.itemName);
    }

    function cloneHouseRewardItems(items = []) {
        return items.map((item) => ({
            itemName: String(item.itemName || ''),
            minAmount: String(item.minAmount ?? 1),
            maxAmount: String(item.maxAmount ?? 1),
            chance: String(item.chance ?? 100),
        })).filter((item) => item.itemName);
    }

    function updateHousePointRewardClipboardButtons() {
        const pasteButton = document.getElementById('pasteHousePointRewardItemsButton');
        if (!pasteButton) return;

        const hasClipboard = housePointRewardItemClipboard.length > 0;
        pasteButton.disabled = !hasClipboard;
        pasteButton.classList.toggle('is-disabled', !hasClipboard);
        pasteButton.title = hasClipboard ? 'Paste copied reward items onto this point' : 'Copy reward items from another point first';
    }

    function copyHousePointRewardItems() {
        const items = cloneHouseRewardItems(collectHouseRewardItems('housePointRewardItemOptions'));
        if (!items.length) {
            notifyHousePreset('Add at least one reward item before copying.', 'error');
            return;
        }

        housePointRewardItemClipboard = items;
        updateHousePointRewardClipboardButtons();
        notifyHousePreset(`Copied ${items.length} reward item${items.length === 1 ? '' : 's'}.`, 'success');
    }

    function pasteHousePointRewardItems() {
        if (!housePointRewardItemClipboard.length) {
            notifyHousePreset('Copy reward items from another point first.', 'error');
            return;
        }

        const list = document.querySelector('#housePointRewardItemOptions .reward-item-list');
        if (!list) return;

        list.innerHTML = '';
        cloneHouseRewardItems(housePointRewardItemClipboard).forEach((item) => {
            addHouseRewardItemRow('housePointRewardItemOptions', item);
        });

        const checkbox = document.getElementById('housePointRewardItemCheckbox');
        if (checkbox) checkbox.checked = true;

        const openButton = document.getElementById('openHousePointRewardItemOptionsButton');
        if (openButton) openButton.classList.remove('hidden');

        try { bindItemHandlers(); } catch (e) {}
        saveHousePointSettingsFromPanel();
        updateHousePointRewardClipboardButtons();
        notifyHousePreset(`Pasted ${housePointRewardItemClipboard.length} reward item${housePointRewardItemClipboard.length === 1 ? '' : 's'}.`, 'success');
    }

    function collectHouseWeaponItems(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return [];
        return Array.from(panel.querySelectorAll('.selected-weapon'))
            .map((input) => input.value?.trim() || '')
            .filter(Boolean);
    }

    function normalizeHousePercentValue(value, fallback = 100) {
        if (value === undefined || value === null || value === '') return fallback;
        const numberValue = Number(value);
        if (!Number.isFinite(numberValue)) return fallback;
        return Math.max(0, Math.min(100, numberValue));
    }

    function syncHouseGlobalSettingsToLocations() {
        if (!houseRobberyData || typeof houseRobberyData !== 'object') return;
        houseRobberyData.settings = normalizeHouseAlertSettings(houseRobberyData.settings || {});
        if (!Array.isArray(houseRobberyData.locations)) return;
        houseRobberyData.locations.forEach((location) => {
            if (!location || typeof location !== 'object') return;
            location.policeRequired = houseRobberyData.settings.policeRequired;
            location.cooldown = houseRobberyData.settings.cooldown;
        });
    }

    function getHouseBatchLocationSettings() {
        if (!houseRobberyData || typeof houseRobberyData !== 'object') return normalizeHouseBatchLocationSettings();
        houseRobberyData.batchLocationSettings = normalizeHouseBatchLocationSettings(houseRobberyData.batchLocationSettings || {});
        return houseRobberyData.batchLocationSettings;
    }

    function houseBatchPanelHasData(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return false;

        if (typeof rcHasMeaningfulData === 'function' && rcHasMeaningfulData(panel)) {
            return true;
        }

        const defaults = getHouseBatchLocationSettings();
        if (panelId === 'houseBatchRewardMoneyOptions') {
            const type = document.getElementById('houseBatchRewardType')?.value || defaults.rewardType;
            const min = String(document.getElementById('houseBatchRewardMinMoney')?.value || defaults.minMoney);
            const max = String(document.getElementById('houseBatchRewardMaxMoney')?.value || defaults.maxMoney);
            const chance = String(document.getElementById('houseBatchRewardMoneyChance')?.value || defaults.moneyChance);
            return type !== defaults.rewardType || min !== String(defaults.minMoney) || max !== String(defaults.maxMoney) || chance !== String(defaults.moneyChance);
        }

        if (panelId === 'houseBatchXpOptions') {
            const reward = String(document.getElementById('houseBatchXpRewardAmount')?.value || defaults.xpRewardAmount);
            const needed = String(document.getElementById('houseBatchXpNeededAmount')?.value || defaults.xpNeededAmount);
            const remove = !!document.getElementById('houseBatchRemoveXpOnHitCheckbox')?.checked;
            const removeAmount = String(document.getElementById('houseBatchXpRemoveAmount')?.value || defaults.xpRemoveAmount);
            return reward !== String(defaults.xpRewardAmount)
                || needed !== String(defaults.xpNeededAmount)
                || remove
                || removeAmount !== String(defaults.xpRemoveAmount);
        }

        return false;
    }

    function renderHouseBulkApplyLocationList() {
        const list = document.getElementById('houseBulkApplyLocationList');
        if (!list) return;
        list.innerHTML = '';

        const locations = Array.isArray(houseRobberyData?.locations) ? houseRobberyData.locations : [];
        if (!locations.length) {
            list.innerHTML = '<div class="petty-crime-location-empty">No house robbery locations have been created yet.</div>';
            return;
        }

        locations.forEach((location, index) => {
            const row = document.createElement('label');
            row.className = 'house-bulk-apply-location';
            row.innerHTML = `
                <span class="house-bulk-apply-location-copy">
                    <strong>${escapeHouseHtml(location.label || `House Robbery ${index + 1}`)}</strong>
                    <small>${escapeHouseHtml(location.streetName || 'No street yet')}</small>
                </span>
                <input type="checkbox" class="house-bulk-apply-checkbox" value="${escapeHouseHtml(location.id || `location_${index + 1}`)}">
            `;
            list.appendChild(row);
        });
    }

    function getHouseBulkApplyDefinition(settingKey) {
        return {
            enabled: {
                title: 'Apply Enabled',
                description: 'Choose which house robbery locations should use this enabled state.',
                apply(location, template) {
                    location.enabled = !!template.enabled;
                },
            },
            interactionLabel: {
                title: 'Apply Target Label',
                description: 'Choose which house robbery locations should use this target label.',
                apply(location, template) {
                    location.interactionLabel = template.interactionLabel;
                },
            },
            progressLabel: {
                title: 'Apply Progress Label',
                description: 'Choose which house robbery locations should use this progress label.',
                apply(location, template) {
                    location.progressLabel = template.progressLabel;
                },
            },
            progressDuration: {
                title: 'Apply Progress Time',
                description: 'Choose which house robbery locations should use this progress duration.',
                apply(location, template) {
                    location.progressDuration = template.progressDuration;
                },
            },
            minigameOption: {
                title: 'Apply Minigame Option',
                description: 'Choose which house robbery locations should use this minigame option.',
                apply(location, template) {
                    location.minigameOption = template.minigameOption;
                },
            },
            requiredItems: {
                title: 'Apply Required Items',
                description: 'Choose which house robbery locations should use this required item setup.',
                apply(location, template) {
                    location.requiredItems = template.requiredItemsEnabled
                        ? (Array.isArray(template.requiredItems) ? template.requiredItems.map((item) => ({ ...item })) : [])
                        : [];
                },
            },
            rewardItems: {
                title: 'Apply Reward Items',
                description: 'Choose which house robbery locations should use this reward item setup.',
                apply(location, template) {
                    location.rewardItems = template.rewardItemsEnabled
                        ? (Array.isArray(template.rewardItems) ? template.rewardItems.map((item) => ({ ...item })) : [])
                        : [];
                },
            },
            moneyReward: {
                title: 'Apply Money Reward',
                description: 'Choose which house robbery locations should use this money reward setup.',
                apply(location, template) {
                    location.moneyReward = !!template.moneyRewardEnabled;
                    location.rewardType = template.rewardType;
                    location.minMoney = template.minMoney;
                    location.maxMoney = template.maxMoney;
                    location.moneyChance = template.moneyChance;
                },
            },
            xpOptions: {
                title: 'Apply XP Options',
                description: 'Choose which house robbery locations should use this XP setup.',
                apply(location, template) {
                    location.xpOptions = !!template.xpOptionsEnabled;
                    location.xpRewardAmount = template.xpRewardAmount;
                    location.xpNeededAmount = template.xpNeededAmount;
                    location.removeXpOnHit = !!template.removeXpOnHit;
                    location.xpRemoveAmount = template.xpRemoveAmount;
                },
            },
        }[settingKey] || null;
    }

    function openHouseBulkApplyModal(settingKey) {
        const definition = getHouseBulkApplyDefinition(settingKey);
        if (!definition) return;
        if (!Array.isArray(houseRobberyData?.locations) || !houseRobberyData.locations.length) {
            if (typeof rcNotify === 'function') rcNotify('Create at least one house robbery location first.', 'error');
            return;
        }

        saveHouseGlobalSettingsEditorToState();
        houseRobberyUiState.pendingBulkSetting = settingKey;

        const panel = document.getElementById('houseBulkApplyOptionsPanel');
        const description = document.getElementById('houseBulkApplyDescription');
        if (!panel || !description) return;

        description.textContent = definition.description;
        renderHouseBulkApplyLocationList();

        panel.querySelectorAll('.house-bulk-apply-checkbox').forEach((input) => {
            input.checked = true;
        });

        if (typeof OpenFeatureModal === 'function') {
            OpenFeatureModal(document.getElementById('houseGlobalSettingsPanel') || document.getElementById('houseRobberyMainPageContainer') || document.body, definition.title, panel);
        }
    }

    function applyHouseBatchSettingToLocations() {
        const settingKey = houseRobberyUiState.pendingBulkSetting;
        const definition = getHouseBulkApplyDefinition(settingKey);
        if (!definition) return;

        saveHouseGlobalSettingsEditorToState();

        const selectedIds = Array.from(document.querySelectorAll('#houseBulkApplyLocationList .house-bulk-apply-checkbox:checked'))
            .map((input) => input.value)
            .filter(Boolean);
        if (!selectedIds.length) {
            if (typeof rcNotify === 'function') rcNotify('Select at least one house robbery location.', 'error');
            return;
        }

        const template = getHouseBatchLocationSettings();
        houseRobberyData.locations.forEach((location, index) => {
            const locationId = String(location.id || `location_${index + 1}`);
            if (!selectedIds.includes(locationId)) return;
            definition.apply(location, template);
        });

        renderLocationList();
        renderLocationEditor();
        if (typeof CloseFeatureModal === 'function' && window.rcFeatureModalIsOpen && rcFeatureModalIsOpen()) {
            CloseFeatureModal({ restorePrevious: false, forceAll: true });
        }
        if (typeof rcNotify === 'function') rcNotify('House robbery locations updated.', 'success');
    }

    function saveHouseLocationEditorToState() {
        const location = getSelectedLocation();
        const editor = document.getElementById('houseLocationEditor');
        if (!location || !editor || editor.style.display === 'none') return;
        const defaults = getHouseLocationDefaults();

        location.enabled = !!document.getElementById('houseLocationEnabled')?.checked;
        location.interactionLabel = document.getElementById('houseLocationInteractionLabel')?.value?.trim() || defaults.interactionLabel;
        location.progressLabel = document.getElementById('houseLocationProgressLabel')?.value?.trim() || defaults.progressLabel;
        location.progressDuration = document.getElementById('houseLocationProgressDuration')?.value || defaults.progressDuration;
        location.policeRequired = defaults.policeRequired;
        location.cooldown = defaults.cooldown;
        location.minigameOption = document.getElementById('houseLocationMinigame')?.value || defaults.minigameOption;
        location.moneyReward = !!document.getElementById('houseLocationMoneyRewardCheckbox')?.checked;
        location.rewardType = document.getElementById('houseLocationRewardType')?.value || defaults.rewardType;
        location.minMoney = document.getElementById('houseLocationRewardMinMoney')?.value || defaults.minMoney;
        location.maxMoney = document.getElementById('houseLocationRewardMaxMoney')?.value || defaults.maxMoney;
        location.moneyChance = document.getElementById('houseLocationRewardMoneyChance')?.value || defaults.moneyChance;
        const locationXpEnabled = !!document.getElementById('houseLocationXpOptionsCheckbox')?.checked;
        location.xpOptions = locationXpEnabled;
        location.xpRewardAmount = document.getElementById('houseLocationXpRewardAmount')?.value || defaults.xpRewardAmount;
        location.xpNeededAmount = document.getElementById('houseLocationXpNeededAmount')?.value || defaults.xpNeededAmount;
        location.removeXpOnHit = locationXpEnabled && !!document.getElementById('houseLocationRemoveXpOnHitCheckbox')?.checked;
        location.xpRemoveAmount = document.getElementById('houseLocationXpRemoveAmount')?.value || defaults.xpRemoveAmount;
        location.requiredItems = document.getElementById('houseLocationRequiredItemCheckbox')?.checked
            ? collectHouseRequiredItems('houseLocationRequiredItemOptions')
            : [];
        location.rewardItems = document.getElementById('houseLocationRewardItemCheckbox')?.checked
            ? collectHouseRewardItems('houseLocationRewardItemOptions')
            : [];

        const shellIds = [];
        const presetSelections = {};
        document.querySelectorAll('.house-shell-assignment').forEach((card) => {
            const shellId = card.dataset.shellId;
            const enabled = card.querySelector('.house-shell-enabled')?.checked;
            if (!enabled || !shellId) return;
            shellIds.push(shellId);
            presetSelections[shellId] = Array.from(card.querySelectorAll('.house-preset-enabled:checked'))
                .map((input) => input.value)
                .filter(Boolean);
        });
        location.shellIds = shellIds;
        location.presetSelections = presetSelections;
        delete location.exit;
    }

    function saveHouseAlertEditorToState() {
        if (!houseRobberyData || typeof houseRobberyData !== 'object') return;
        const defaults = normalizeHouseAlertSettings(houseRobberyData.settings || {});
        houseRobberyData.settings = normalizeHouseAlertSettings({
            ...defaults,
            sendAlert: !!document.getElementById('houseGlobalSendAlertCheckbox')?.checked,
            policeRequired: document.getElementById('houseGlobalPoliceRequired')?.value || defaults.policeRequired,
            cooldown: defaults.cooldown,
            alertChance: document.getElementById('houseGlobalAlertChance')?.value || defaults.alertChance,
            policeAlertHeader: document.getElementById('houseGlobalPoliceAlertHeader')?.value?.trim() || defaults.policeAlertHeader,
            policeAlert: document.getElementById('houseGlobalPoliceAlert')?.value?.trim() || defaults.policeAlert,
            alertCode: document.getElementById('houseGlobalAlertCode')?.value?.trim() || defaults.alertCode,
            alertCamId: document.getElementById('houseGlobalAlertCamId')?.value?.trim() || defaults.alertCamId,
            alertIcon: document.getElementById('houseGlobalAlertIcon')?.value || defaults.alertIcon,
            alertPriority: document.getElementById('houseGlobalAlertPriority')?.value || defaults.alertPriority,
            blipSprite: document.getElementById('houseGlobalBlipSprite')?.value || defaults.blipSprite,
            blipColor: document.getElementById('houseGlobalBlipColor')?.value || defaults.blipColor,
            blipScale: document.getElementById('houseGlobalBlipScale')?.value || defaults.blipScale,
            alertSound1: document.getElementById('houseGlobalAlertSound1')?.value || defaults.alertSound1,
            blipFlash: document.getElementById('houseGlobalBlipFlash')?.value === 'true',
            policeJobs: (document.getElementById('houseGlobalPoliceJobs')?.value || '')
                .split(',')
                .map((job) => job.trim())
                .filter(Boolean),
        });
        syncHouseGlobalSettingsToLocations();
    }

    function saveHouseGlobalSettingsEditorToState() {
        if (!houseRobberyData || typeof houseRobberyData !== 'object') return;
        const defaults = normalizeHouseAlertSettings(houseRobberyData.settings || {});
        const batchXpEnabled = !!document.getElementById('houseBatchXpOptionsCheckbox')?.checked;
        houseRobberyData.settings = normalizeHouseAlertSettings({
            ...defaults,
            cooldown: document.getElementById('houseGlobalCooldown')?.value || defaults.cooldown,
            missionNpcEnabled: !!document.getElementById('houseMissionNpcCheckbox')?.checked && hasHousePlacementCoords(defaults.missionNpc),
            missionNpc: defaults.missionNpc,
        });
        houseRobberyData.batchLocationSettings = normalizeHouseBatchLocationSettings({
            enabled: !!document.getElementById('houseBatchEnabled')?.checked,
            interactionLabel: document.getElementById('houseBatchInteractionLabel')?.value?.trim() || getHouseLocationDefaults().interactionLabel,
            progressLabel: document.getElementById('houseBatchProgressLabel')?.value?.trim() || getHouseLocationDefaults().progressLabel,
            progressDuration: document.getElementById('houseBatchProgressDuration')?.value || getHouseLocationDefaults().progressDuration,
            minigameOption: document.getElementById('houseBatchMinigame')?.value || getHouseLocationDefaults().minigameOption,
            requiredItemsEnabled: !!document.getElementById('houseBatchRequiredItemCheckbox')?.checked,
            requiredItems: document.getElementById('houseBatchRequiredItemCheckbox')?.checked
                ? collectHouseRequiredItems('houseBatchRequiredItemOptions')
                : [],
            rewardItemsEnabled: !!document.getElementById('houseBatchRewardItemCheckbox')?.checked,
            rewardItems: document.getElementById('houseBatchRewardItemCheckbox')?.checked
                ? collectHouseRewardItems('houseBatchRewardItemOptions')
                : [],
            moneyRewardEnabled: !!document.getElementById('houseBatchMoneyRewardCheckbox')?.checked,
            rewardType: document.getElementById('houseBatchRewardType')?.value || getHouseLocationDefaults().rewardType,
            minMoney: document.getElementById('houseBatchRewardMinMoney')?.value || getHouseLocationDefaults().minMoney,
            maxMoney: document.getElementById('houseBatchRewardMaxMoney')?.value || getHouseLocationDefaults().maxMoney,
            moneyChance: document.getElementById('houseBatchRewardMoneyChance')?.value || getHouseLocationDefaults().moneyChance,
            xpOptionsEnabled: batchXpEnabled,
            xpRewardAmount: document.getElementById('houseBatchXpRewardAmount')?.value || getHouseLocationDefaults().xpRewardAmount,
            xpNeededAmount: document.getElementById('houseBatchXpNeededAmount')?.value || getHouseLocationDefaults().xpNeededAmount,
            removeXpOnHit: batchXpEnabled && !!document.getElementById('houseBatchRemoveXpOnHitCheckbox')?.checked,
            xpRemoveAmount: document.getElementById('houseBatchXpRemoveAmount')?.value || getHouseLocationDefaults().xpRemoveAmount,
        });
        syncHouseGlobalSettingsToLocations();
    }

    function addHouseRequiredItemRow(panelId, item = {}) {
        const panel = document.getElementById(panelId);
        const list = panel?.querySelector('.item-list');
        if (!list) return;
        const loseChance = normalizeHousePercentValue(item.chance, 100);
        const row = document.createElement('div');
        row.className = 'section';
        row.innerHTML = `
            <div class="rcCombo" data-combo="item">
                <div class="rcComboSearch">
                    <i class="fas fa-magnifying-glass"></i>
                    <input type="text" class="item-name" placeholder="Search item" autocomplete="off" value="${escapeHouseHtml(item.itemName || '')}">
                    <i class="fas fa-chevron-down rcComboCaret"></i>
                </div>
                <div class="rcComboList hidden"></div>
            </div>
            <label class="quantity-label">Item Quantity</label>
            <input type="number" class="item-quantity" min="1" value="${Number(item.amount ?? 1) || 1}">
            <label class="lose-chance-label">Lose Chance (%)</label>
            <input type="number" class="lose-chance" min="0" max="100" value="${loseChance}">
            <button type="button" class="remove-item-button">Remove</button>
        `;
        row.querySelector('.remove-item-button')?.addEventListener('click', () => row.remove());
        list.appendChild(row);
    }

    function addHouseRewardItemRow(panelId, item = {}) {
        const panel = document.getElementById(panelId);
        const list = panel?.querySelector('.reward-item-list');
        if (!list) return;
        const rewardChance = normalizeHousePercentValue(item.chance, 100);
        const row = document.createElement('div');
        row.className = 'reward-item';
        row.innerHTML = `
            <div class="section">
                <div class="rcCombo" data-combo="item">
                    <div class="rcComboSearch">
                        <i class="fas fa-magnifying-glass"></i>
                        <input type="text" class="reward-item-name" placeholder="Search item" autocomplete="off" value="${escapeHouseHtml(item.itemName || '')}">
                        <i class="fas fa-chevron-down rcComboCaret"></i>
                    </div>
                    <div class="rcComboList hidden"></div>
                </div>
                <div>
                    <label>Min Amount</label>
                    <input type="number" class="reward-item-min" min="1" value="${Number(item.minAmount ?? 1) || 1}">
                </div>
                <div>
                    <label>Max Amount</label>
                    <input type="number" class="reward-item-max" min="1" value="${Number(item.maxAmount ?? 1) || 1}">
                </div>
                <div>
                    <label>Reward Chance (%)</label>
                    <input type="number" class="reward-item-chance" min="0" max="100" value="${rewardChance}">
                </div>
                <button type="button" class="remove-reward-item-button">Remove</button>
            </div>
        `;
        row.querySelector('.remove-reward-item-button')?.addEventListener('click', () => row.remove());
        list.appendChild(row);
    }

    function addHouseWeaponRow(panelId, weaponName = '') {
        const panel = document.getElementById(panelId);
        const list = panel?.querySelector('.weapon-list');
        if (!list) return;
        const row = document.createElement('div');
        row.className = 'weapon-item';
        row.innerHTML = `
            <div class="section">
                <div class="rcCombo" data-combo="item">
                    <div class="rcComboSearch">
                        <i class="fas fa-magnifying-glass"></i>
                        <input type="text" class="selected-weapon" placeholder="Search item" autocomplete="off" value="${escapeHouseHtml(weaponName)}">
                        <i class="fas fa-chevron-down rcComboCaret"></i>
                    </div>
                    <div class="rcComboList hidden"></div>
                </div>
                <button type="button" class="remove-weapon-button">Remove</button>
            </div>
        `;
        row.querySelector('.remove-weapon-button')?.addEventListener('click', () => row.remove());
        list.appendChild(row);
    }

    function generateHouseLocationLabel(streetName) {
        const base = String(streetName || 'House Location').trim() || 'House Location';
        const count = houseRobberyData.locations.filter((location) => String(location.streetName || '').trim() === base).length;
        return `${base} ${count + 1}`;
    }

    function cloneHouseLocationTemplate(location) {
        if (!location || typeof location !== 'object') return null;
        return JSON.parse(JSON.stringify(location));
    }

    function buildPlacedHouseLocation(placementResult, template = null) {
        const streetName = String(placementResult?.streetName || 'House Location').trim() || 'House Location';
        const nextLocation = template && typeof template === 'object'
            ? cloneHouseLocationTemplate(template)
            : {};

        nextLocation.id = `location_${Date.now()}`;
        nextLocation.label = generateHouseLocationLabel(streetName);
        nextLocation.streetName = streetName;
        nextLocation.entry = {
            coords: placementResult.location.coords,
            heading: placementResult.location.heading,
        };
        delete nextLocation.exit;

        return normalizeLocation(nextLocation, houseRobberyData.locations.length);
    }

    function housePointPanelHasData(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return false;

        if (typeof rcHasMeaningfulData === 'function' && rcHasMeaningfulData(panel)) {
            return true;
        }

        if (panelId === 'housePointWeaponOptions') {
            return panel.querySelectorAll('.weapon-item').length > 0;
        }

        if (panelId === 'housePointMinigameOptions') {
            const value = document.getElementById('housePointMinigameSelect')?.value || 'none';
            return value !== 'none';
        }

        if (panelId === 'housePointRewardMoneyOptions') {
            const type = document.getElementById('housePointRewardType')?.value || 'cash';
            const min = String(document.getElementById('housePointRewardMinMoney')?.value || '1');
            const max = String(document.getElementById('housePointRewardMaxMoney')?.value || '1');
            const chance = String(document.getElementById('housePointRewardMoneyChance')?.value || '100');
            return type !== 'cash' || min !== '1' || max !== '1' || chance !== '100';
        }

        if (panelId === 'housePointDelayRewardOptions') {
            return String(document.getElementById('housePointRewardDelayTime')?.value || '1') !== '1';
        }

        if (panelId === 'housePointXpOptions') {
            const reward = String(document.getElementById('housePointXpRewardAmount')?.value || '0');
            const needed = String(document.getElementById('housePointXpNeededAmount')?.value || '0');
            const remove = !!document.getElementById('housePointRemoveXpOnHitCheckbox')?.checked;
            const removeAmount = String(document.getElementById('housePointXpRemoveAmount')?.value || '0');
            return reward !== '0' || needed !== '0' || remove || removeAmount !== '0';
        }

        return false;
    }

    function bindHousePointFeatureToggles() {
        const minigameSelect = document.getElementById('housePointMinigameSelect');
        if (minigameSelect) {
            const syncMinigame = () => {
                saveHousePointSettingsFromPanel();
            };
            syncMinigame();
            minigameSelect.onchange = syncMinigame;
        }

        const syncHousePointXpRemoveAmount = () => {
            const xpEnabled = !!document.getElementById('housePointXpOptionsCheckbox')?.checked;
            const removeEnabled = xpEnabled && !!document.getElementById('housePointRemoveXpOnHitCheckbox')?.checked;
            const removeXpWrap = document.getElementById('housePointXpRemoveAmountWrap');
            if (!removeXpWrap) return;
            removeXpWrap.classList.toggle('hidden', !removeEnabled);
            removeXpWrap.style.display = removeEnabled ? 'grid' : 'none';
        };

        [
            ['housePointXpOptionsCheckbox', 'housePointXpOptions', 'openHousePointXpOptionsButton', 'House Robbery XP Options'],
            ['housePointRequiredItemCheckbox', 'housePointRequiredItemOptions', 'openHousePointRequiredItemOptionsButton', 'Required Items'],
            ['housePointRewardItemCheckbox', 'housePointRewardItemOptions', 'openHousePointRewardItemOptionsButton', 'Reward Items'],
            ['housePointRewardMoneyCheckbox', 'housePointRewardMoneyOptions', 'openHousePointRewardMoneyOptionsButton', 'Reward Money'],
            ['housePointDelayRewardCheckbox', 'housePointDelayRewardOptions', 'openHousePointDelayRewardOptionsButton', 'Reward Grab Delay'],
            ['housePointRequireWeaponCheckbox', 'housePointWeaponOptions', 'openHousePointWeaponOptionsButton', 'Weapon Requirement'],
        ].forEach(([checkboxId, panelId, buttonId, modalTitle]) => {
            const checkbox = document.getElementById(checkboxId);
            const panel = document.getElementById(panelId);
            const button = buttonId ? document.getElementById(buttonId) : null;
            if (!checkbox || !panel) return;

            const sync = (openWhenChecked = false) => {
                const enabled = !!checkbox.checked;
                const hasData = housePointPanelHasData(panelId);
                const keepButtonForSavedData = panelId !== 'housePointXpOptions' && hasData;
                if (button) button.classList.toggle('hidden', !(enabled || keepButtonForSavedData));
                if (panelId === 'housePointXpOptions') syncHousePointXpRemoveAmount();

                panel.classList.add('hidden');
                if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                    panel.style.display = 'none';
                }

                saveHousePointSettingsFromPanel();

                if (openWhenChecked && enabled && typeof OpenFeatureModal === 'function') {
                    OpenFeatureModal(document.getElementById('housePointEditor') || document.getElementById('housePointManagerView') || document.body, modalTitle, panel);
                }
            };

            if (button && button.dataset.rcBound !== '1') {
                button.dataset.rcBound = '1';
                button.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    if (!checkbox.checked) return;
                    if (typeof OpenFeatureModal === 'function') {
                        OpenFeatureModal(document.getElementById('housePointEditor') || document.getElementById('housePointManagerView') || document.body, modalTitle, panel);
                    }
                });
            }

            sync(false);
            checkbox.onchange = () => sync(true);
        });

        const removeXpCheckbox = document.getElementById('housePointRemoveXpOnHitCheckbox');
        if (removeXpCheckbox) {
            removeXpCheckbox.onchange = () => {
                syncHousePointXpRemoveAmount();
                saveHousePointSettingsFromPanel();
            };
        }
    }

    function collapseHousePointFeaturePanels() {
        [
            'housePointXpOptions',
            'housePointWeaponOptions',
            'housePointRequiredItemOptions',
            'housePointRewardItemOptions',
            'housePointRewardMoneyOptions',
            'housePointDelayRewardOptions',
        ].forEach((panelId) => {
            const panel = document.getElementById(panelId);
            if (!panel) return;
            if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                panel.classList.add('hidden');
                panel.style.display = 'none';
            }
        });
    }

    function populateHousePointMinigameSelect(selectedValue = 'none') {
        const select = document.getElementById('housePointMinigameSelect');
        if (!select) return;
        const wantedValue = String(selectedValue || 'none');
        select.innerHTML = '';
        rcMiniGameOptions().forEach((entry) => {
            const option = document.createElement('option');
            option.value = entry.value;
            option.textContent = entry.label;
            select.appendChild(option);
        });
        const hasWantedValue = Array.from(select.options || []).some((option) => String(option.value) === wantedValue);
        select.value = hasWantedValue ? wantedValue : 'none';
        try { select._rcPugSelectRefresh?.(); } catch (error) {}
    }

    function getHousePointMinigameEditorValue() {
        const select = document.getElementById('housePointMinigameSelect');
        if (!select) return 'none';

        const nativeValue = String(select.value || '').trim();
        if (nativeValue && nativeValue !== 'none') return nativeValue;

        const wrap = select.nextElementSibling?.classList?.contains('pug-select') ? select.nextElementSibling : null;
        const activeValue = String(wrap?.querySelector('.pug-select-item.active')?.dataset?.value || '').trim();
        if (activeValue && activeValue !== 'none') return activeValue;

        const visibleLabel = String(wrap?.querySelector('.pug-select-btn .label')?.textContent || '').trim();
        if (visibleLabel) {
            const optionFromLabel = rcMiniGameOptions().find((entry) => String(entry.label || '').trim() === visibleLabel);
            if (optionFromLabel?.value && optionFromLabel.value !== 'none') return optionFromLabel.value;
            if (visibleLabel.toLowerCase() === 'none') return 'none';
        }

        return nativeValue || activeValue || 'none';
    }

    function applyHousePointEditorSnapshotToData(data, snapshot) {
        if (!data || !snapshot) return;
        const shell = data.shells?.[snapshot.shellIndex];
        const preset = shell?.presets?.[snapshot.presetIndex];
        if (!preset) return;

        const minigameType = String(snapshot.minigameType || 'none').trim() || 'none';
        const failPoliceChance = String(snapshot.failPoliceChance ?? '0');
        const pointSettings = snapshot.pointSettings && typeof snapshot.pointSettings === 'object'
            ? cloneHouseValue(snapshot.pointSettings)
            : {};
        if (snapshot.pointIndex === HOUSE_SECURITY_TAB_INDEX) {
            preset.securitySystem = normalizeHouseSecuritySystem({
                ...(preset.securitySystem || {}),
                ...pointSettings,
                minigameCheckbox: minigameType !== 'none',
                minigameType,
                failPoliceChance,
                keypad: {
                    ...((preset.securitySystem && preset.securitySystem.keypad) || {}),
                    ...((pointSettings && pointSettings.keypad) || {}),
                    minigameCheckbox: minigameType !== 'none',
                    minigameType,
                },
            });
            return;
        }

        if (snapshot.pointIndex === HOUSE_HOME_OWNER_TAB_INDEX) {
            preset.homeOwner = normalizeHouseHomeOwner({
                ...(preset.homeOwner || {}),
                ...pointSettings,
                minigameCheckbox: minigameType !== 'none',
                minigameType,
                failPoliceChance,
            });
            return;
        }

        const point = preset.lootPoints?.[snapshot.pointIndex];
        if (point) {
            Object.assign(point, pointSettings);
            point.minigameCheckbox = minigameType !== 'none';
            point.minigameType = minigameType;
            point.failPoliceChance = failPoliceChance;
        }
    }

    function captureHousePointEditorSnapshot() {
        const panel = document.getElementById('housePointEditor');
        const manager = document.getElementById('housePointManagerView');
        if (!panel || panel.style.display === 'none' || manager?.style.display === 'none') return null;
        saveHousePointSettingsFromPanel(true);
        const point = getSelectedPoint();
        return {
            shellIndex: houseRobberyUiState.selectedShellIndex,
            presetIndex: houseRobberyUiState.selectedPresetIndex,
            pointIndex: houseRobberyUiState.selectedPointIndex,
            minigameType: getHousePointMinigameEditorValue(),
            failPoliceChance: document.getElementById('housePointFailPoliceChance')?.value || '0',
            pointSettings: cloneHouseValue(point || {}),
        };
    }

    function prepareHouseRobberyDataForSave() {
        const pointEditorSnapshot = captureHousePointEditorSnapshot();
        saveHouseShellEditorToState();
        saveHouseLocationEditorToState();
        saveHouseAlertEditorToState();
        saveHouseGlobalSettingsEditorToState();
        houseRobberyData = normalizeHouseRobberyData(houseRobberyData);
        applyHousePointEditorSnapshotToData(houseRobberyData, pointEditorSnapshot);
        return pointEditorSnapshot;
    }

    function saveHousePointSettingsFromPanel(force = false) {
        const panel = document.getElementById('housePointEditor');
        const point = getSelectedPoint();
        if (!panel || !point) return;
        if (!force && !isHousePointEditorReadyToSave(panel)) return;

        point.label = document.getElementById('housePointSettingsLabel')?.value?.trim() || 'Search';
        point.numberValue = point.numberValue || `${houseRobberyUiState.selectedPointIndex + 1}`;
        point.heading = Number(document.getElementById('housePointSettingsHeading')?.value ?? point.heading) || 0;
        point.createChance = document.getElementById('housePointCreateChance')?.value || '100';
        point.minigameType = getHousePointMinigameEditorValue();
        point.minigameCheckbox = point.minigameType !== 'none';
        point.failPoliceChance = document.getElementById('housePointFailPoliceChance')?.value || '0';
        point.requiresItem = !!document.getElementById('housePointRequiredItemCheckbox')?.checked;
        point.requiredItems = point.requiresItem ? collectHouseRequiredItems('housePointRequiredItemOptions') : [];
        point.rewardItem = !!document.getElementById('housePointRewardItemCheckbox')?.checked;
        point.rewardItems = point.rewardItem ? collectHouseRewardItems('housePointRewardItemOptions') : [];
        point.rewardMoney = !!document.getElementById('housePointRewardMoneyCheckbox')?.checked;
        point.rewardMoneyType = document.getElementById('housePointRewardType')?.value || 'cash';
        point.rewardMoneyMin = document.getElementById('housePointRewardMinMoney')?.value || '1';
        point.rewardMoneyMax = document.getElementById('housePointRewardMaxMoney')?.value || '1';
        point.moneyChance = document.getElementById('housePointRewardMoneyChance')?.value || '100';
        const pointXpEnabled = !!document.getElementById('housePointXpOptionsCheckbox')?.checked;
        point.xpOptions = pointXpEnabled;
        point.xpRewardAmount = document.getElementById('housePointXpRewardAmount')?.value || '0';
        point.xpNeededAmount = document.getElementById('housePointXpNeededAmount')?.value || '0';
        point.removeXpOnHit = pointXpEnabled && !!document.getElementById('housePointRemoveXpOnHitCheckbox')?.checked;
        point.xpRemoveAmount = document.getElementById('housePointXpRemoveAmount')?.value || '0';
        point.delayRewardCheckbox = !!document.getElementById('housePointDelayRewardCheckbox')?.checked;
        point.rewardDelayTime = document.getElementById('housePointRewardDelayTime')?.value || '1';
        point.requireWeaponInHand = !!document.getElementById('housePointRequireWeaponCheckbox')?.checked;
        point.requiredWeapons = point.requireWeaponInHand ? collectHouseWeaponItems('housePointWeaponOptions') : [];

        if (houseRobberyUiState.selectedPointIndex === HOUSE_SECURITY_TAB_INDEX) {
            point.keypad = point.keypad || {};
            point.keypad.label = point.label || 'Security System';
            point.keypad.prop = point.prop || point.keypad.prop || 'prop_ld_keypad_01b';
            point.keypad.heading = point.heading || 0;
            point.keypad.coords = point.coords || { x: 0, y: 0, z: 0 };
            point.keypad.placed = point.isPlaced === true;
            point.keypad.minigameType = point.minigameType || 'none';
            point.keypad.minigameCheckbox = point.minigameCheckbox === true;
        }
    }

    function renderHousePointSettingsPanel() {
        const point = getSelectedPoint();
        const panel = document.getElementById('housePointEditor');
        if (!point || !panel) return;

        housePointEditorRenderDepth += 1;
        panel.dataset.housePointEditorKey = getHousePointEditorKey();
        try {
            const title = document.getElementById('housePointEditorTitle');
            if (title) title.textContent = getHousePointDisplayName(point, houseRobberyUiState.selectedPointIndex).toUpperCase();
            document.getElementById('housePointSettingsLabel').value = point.label || '';
            const headingInput = document.getElementById('housePointSettingsHeading');
            if (headingInput) headingInput.value = Number(point.heading || 0).toFixed(2);
            const createChanceInput = document.getElementById('housePointCreateChance');
            if (createChanceInput) createChanceInput.value = point.createChance ?? '100';
            populateHousePointMinigameSelect(point.minigameType || 'none');
            document.getElementById('housePointFailPoliceChance').value = point.failPoliceChance ?? '0';
            document.getElementById('housePointRequiredItemCheckbox').checked = !!point.requiresItem;
            document.getElementById('housePointRewardItemCheckbox').checked = !!point.rewardItem;
            document.getElementById('housePointRewardMoneyCheckbox').checked = !!point.rewardMoney;
            document.getElementById('housePointRewardType').value = point.rewardMoneyType || 'cash';
            document.getElementById('housePointRewardMinMoney').value = point.rewardMoneyMin ?? '1';
            document.getElementById('housePointRewardMaxMoney').value = point.rewardMoneyMax ?? '1';
            document.getElementById('housePointRewardMoneyChance').value = point.moneyChance ?? '100';
            document.getElementById('housePointXpOptionsCheckbox').checked = !!point.xpOptions;
            document.getElementById('housePointXpRewardAmount').value = point.xpRewardAmount ?? '0';
            document.getElementById('housePointXpNeededAmount').value = point.xpNeededAmount ?? '0';
            document.getElementById('housePointRemoveXpOnHitCheckbox').checked = !!point.removeXpOnHit;
            document.getElementById('housePointXpRemoveAmount').value = point.xpRemoveAmount ?? '0';
            document.getElementById('housePointDelayRewardCheckbox').checked = !!point.delayRewardCheckbox;
            document.getElementById('housePointRewardDelayTime').value = point.rewardDelayTime ?? '1';
            document.getElementById('housePointRequireWeaponCheckbox').checked = !!point.requireWeaponInHand;

            const reqList = document.querySelector('#housePointRequiredItemOptions .item-list');
            const rewardList = document.querySelector('#housePointRewardItemOptions .reward-item-list');
            const weaponList = document.querySelector('#housePointWeaponOptions .weapon-list');
            if (reqList) reqList.innerHTML = '';
            if (rewardList) rewardList.innerHTML = '';
            if (weaponList) weaponList.innerHTML = '';
            (point.requiredItems || []).forEach((item) => addHouseRequiredItemRow('housePointRequiredItemOptions', item));
            (point.rewardItems || []).forEach((item) => addHouseRewardItemRow('housePointRewardItemOptions', item));
            (point.requiredWeapons || []).forEach((weaponName) => addHouseWeaponRow('housePointWeaponOptions', weaponName));

            bindHousePointFeatureToggles();
            updateHousePointRewardClipboardButtons();
            collapseHousePointFeaturePanels();
            try { rcEnhanceMiniGameSelects(panel); } catch (e) {}
            try { rcEnhanceRewardTypeSelects(panel); } catch (e) {}
            try { bindItemHandlers(); } catch (e) {}
        } finally {
            housePointEditorRenderDepth = Math.max(0, housePointEditorRenderDepth - 1);
        }
    }

    async function openHousePointManager(index = 0) {
        const preset = getSelectedPreset();
        if (!preset) return;
        saveHousePointSettingsFromPanel();
        houseRobberyUiState.pointManagerOpen = true;
        if ([HOUSE_SECURITY_TAB_INDEX, HOUSE_HOME_OWNER_TAB_INDEX].includes(index)) {
            houseRobberyUiState.selectedPointIndex = index;
        } else {
            const pointCount = Array.isArray(preset.lootPoints) ? preset.lootPoints.length : 0;
            houseRobberyUiState.selectedPointIndex = pointCount > 0 ? Math.min(index, pointCount - 1) : HOUSE_SECURITY_TAB_INDEX;
        }
        renderShellEditor();
        await focusHousePointPreview(houseRobberyUiState.selectedPointIndex);
    }

    async function closeHousePointManager() {
        saveHousePointSettingsFromPanel();
        houseRobberyUiState.pointManagerOpen = false;
        await exitHousePointPreview(true);
        renderShellEditor();
    }

    function removeHousePointAtIndex(index = houseRobberyUiState.selectedPointIndex) {
        const preset = getSelectedPreset();
        if (!preset?.lootPoints?.length) return;

        const previousSelectedIndex = houseRobberyUiState.selectedPointIndex;
        const removeIndex = Math.max(0, Math.min(index, preset.lootPoints.length - 1));
        preset.lootPoints.splice(removeIndex, 1);
        ensureUniqueHouseLootPointIds(preset.lootPoints);

        if (!preset.lootPoints.length) {
            houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
        } else if (previousSelectedIndex === removeIndex) {
            houseRobberyUiState.selectedPointIndex = Math.min(removeIndex, preset.lootPoints.length - 1);
        } else if (previousSelectedIndex > removeIndex) {
            houseRobberyUiState.selectedPointIndex = previousSelectedIndex - 1;
        } else {
            houseRobberyUiState.selectedPointIndex = previousSelectedIndex;
        }
        clampHouseSelections();

        if (!preset.lootPoints.length) {
            houseRobberyUiState.pointManagerOpen = false;
            exitHousePointPreview(true);
        }

        renderShellEditor();
        if (houseRobberyUiState.pointManagerOpen) {
            focusHousePointPreview(houseRobberyUiState.selectedPointIndex);
        }
    }

    async function placeHousePointFromRow(index, type, replaceExisting = false) {
        saveHousePointSettingsFromPanel();
        houseRobberyUiState.selectedPointIndex = index;
        renderPointManagerList();
        renderPointEditor();

        if (type === 'security') {
            await previewHouseSecurityPlacement();
        } else if (type === 'homeOwner') {
            await previewHouseHomeOwnerPlacement();
        } else {
            await previewShellPreset({ replaceSelected: replaceExisting, singlePlacement: true });
        }
    }

    function renderPointManagerList() {
        const list = document.getElementById('housePointStageTabs');
        const preset = getSelectedPreset();
        if (!list) return;
        list.innerHTML = '';
        getHouseTabEntries(preset).forEach((entry) => {
            const point = entry.point;
            const index = entry.index;
            const row = document.createElement('div');
            row.className = 'stage-tab-row';
            const tab = document.createElement('div');
            const needsPlacement = needsHousePointPlacement(point, index);
            tab.className = `stage-tab ${index === houseRobberyUiState.selectedPointIndex ? 'active' : ''} ${needsPlacement ? 'needs-placement' : 'is-placed'}`;
            tab.innerHTML = `
                <div class="stage-tab-copy">${escapeHouseHtml(getHousePointDisplayName(point, index).toUpperCase())}</div>
                <span class="house-point-placement-state ${needsPlacement ? 'is-pending' : 'is-placed'}">${needsPlacement ? 'Place' : 'Placed'}</span>
            `;
            row.appendChild(tab);

            const placementActionButton = document.createElement('button');
            placementActionButton.type = 'button';
            placementActionButton.className = `${needsPlacement ? 'house-point-tab-place' : 'house-point-tab-replace'} tooltip-container`;
            placementActionButton.setAttribute('aria-label', `${needsPlacement ? 'Place' : 'Replace'} ${getHousePointDisplayName(point, index)}`);
            placementActionButton.innerHTML = needsPlacement
                ? `
                    <i class="fas ${entry.type === 'security' ? 'fa-shield-alt' : entry.type === 'homeOwner' ? 'fa-bed' : 'fa-map-marker-alt'}"></i>
                    <span class="tooltip-text">Place this ${entry.type === 'loot' ? 'loot point' : entry.type === 'security' ? 'security keypad' : 'home owner'}</span>
                `
                : `
                    <i class="fas fa-sync-alt"></i>
                    <span class="tooltip-text">Replace this ${entry.type === 'loot' ? 'loot point' : entry.type === 'security' ? 'security keypad' : 'home owner'}</span>
                `;
            placementActionButton.addEventListener('click', async (event) => {
                event.preventDefault();
                event.stopPropagation();
                await placeHousePointFromRow(index, entry.type, !needsPlacement);
            });
            row.appendChild(placementActionButton);

            const removeButton = document.createElement('button');
            removeButton.type = 'button';
            removeButton.className = 'house-point-tab-remove tooltip-container';
            if (entry.type === 'loot') {
                removeButton.setAttribute('aria-label', 'Remove Point');
                removeButton.innerHTML = `
                    <i class="fas fa-trash"></i>
                    <span class="tooltip-text">Remove point</span>
                `;
                removeButton.addEventListener('click', (event) => {
                    event.preventDefault();
                    event.stopPropagation();
                    saveHousePointSettingsFromPanel();
                    removeHousePointAtIndex(index);
                });
                row.appendChild(removeButton);
            } else {
                removeButton.setAttribute('aria-label', entry.type === 'security' ? 'Clear Security System' : 'Clear Home Owner');
                removeButton.innerHTML = `
                    <i class="fas fa-trash"></i>
                    <span class="tooltip-text">${entry.type === 'security' ? 'Clear security placement' : 'Clear home owner placement'}</span>
                `;
                removeButton.addEventListener('click', (event) => {
                    event.preventDefault();
                    event.stopPropagation();
                    saveHousePointSettingsFromPanel();
                    if (entry.type === 'security') {
                        preset.securitySystem = normalizeHouseSecuritySystem({});
                    } else {
                        preset.homeOwner = normalizeHouseHomeOwner({});
                    }
                    renderPointManagerList();
                    renderPointEditor();
                    exitHousePointPreview(true);
                });
                row.appendChild(removeButton);
            }

            tab.addEventListener('click', () => {
                saveHousePointSettingsFromPanel();
                houseRobberyUiState.selectedPointIndex = index;
                renderPointManagerList();
                renderPointEditor();
                focusHousePointPreview(index);
            });
            list.appendChild(row);
        });
    }

    function renderPointEditor() {
        const emptyState = document.getElementById('housePointEmptyState');
        const editor = document.getElementById('housePointEditor');
        const point = getSelectedPoint();
        if (!point) {
            if (emptyState) emptyState.style.display = 'flex';
            if (editor) {
                editor.style.display = 'none';
                delete editor.dataset.housePointEditorKey;
            }
            exitHousePointPreview();
            updateHousePointPlacementButtons();
            return;
        }

        if (emptyState) emptyState.style.display = 'none';
        if (editor) editor.style.display = 'block';
        renderHousePointSettingsPanel();
        updateHousePointPlacementButtons();
    }

    function updateHousePointPlacementButtons() {
        const selectedIndex = houseRobberyUiState.selectedPointIndex;
        const point = getSelectedPoint();
        const type = getHouseSpecialPointType(selectedIndex);
        const needsPlacement = needsHousePointPlacement(point, selectedIndex);

        const lootButton = document.getElementById('housePointManagerPlaceButton');
        const lootCardButton = document.getElementById('housePointManagerAddPointButton');
        if (lootButton) {
            lootButton.innerHTML = type === 'loot' && needsPlacement
                ? '<i class="fas fa-map-marker-alt"></i> Place Selected Loot Point'
                : '<i class="fas fa-user-secret"></i> Place New Robbable Object';
            lootButton.title = type === 'loot' && needsPlacement
                ? 'Place the selected copied loot point into this shell.'
                : 'Add a new robbable object to this preset.';
        }
        if (lootCardButton) {
            const strong = lootCardButton.querySelector('strong');
            const small = lootCardButton.querySelector('small');
            const tooltip = lootCardButton.querySelector('.tooltip-text');
            if (strong) strong.textContent = type === 'loot' && needsPlacement ? 'Place Selected Point' : 'New Loot Point';
            if (small) small.textContent = type === 'loot' && needsPlacement ? 'Fill the copied point' : 'Place a robbable object';
            if (tooltip) tooltip.textContent = type === 'loot' && needsPlacement
                ? 'Place the selected copied loot point into this shell instead of creating a new row.'
                : 'Open the same robbable-object placer used in stages and save more points into this preset.';
        }

        const securityButton = document.getElementById('housePointManagerPlaceSecurityButton');
        const securityCardButton = document.getElementById('housePointManagerSecurityButton');
        if (securityButton) {
            securityButton.innerHTML = type === 'security' && needsPlacement
                ? '<i class="fas fa-shield-alt"></i> Place Selected Security'
                : '<i class="fas fa-shield-alt"></i> Place Security System';
            securityButton.title = type === 'security' && needsPlacement
                ? 'Place the selected copied security keypad into this shell.'
                : 'Place or replace the security system for this preset.';
        }
        if (securityCardButton) {
            const strong = securityCardButton.querySelector('strong');
            const small = securityCardButton.querySelector('small');
            const tooltip = securityCardButton.querySelector('.tooltip-text');
            if (strong) strong.textContent = type === 'security' && needsPlacement ? 'Place Selected Security' : 'Security Keypad';
            if (small) small.textContent = type === 'security' && needsPlacement ? 'Fill copied keypad' : 'Place keypad and lasers';
            if (tooltip) tooltip.textContent = type === 'security' && needsPlacement
                ? 'Place the selected copied security keypad into this shell.'
                : 'Place a keypad inside the shell, then add as many security lasers as you want.';
        }

        const homeOwnerButton = document.getElementById('housePointManagerPlaceHomeOwnerButton');
        const homeOwnerCardButton = document.getElementById('housePointManagerHomeOwnerButton');
        if (homeOwnerButton) {
            homeOwnerButton.innerHTML = type === 'homeOwner' && needsPlacement
                ? '<i class="fas fa-bed"></i> Place Selected Home Owner'
                : '<i class="fas fa-bed"></i> Place Home Owner';
            homeOwnerButton.title = type === 'homeOwner' && needsPlacement
                ? 'Place the selected copied home owner into this shell.'
                : 'Place or replace the home owner for this preset.';
        }
        if (homeOwnerCardButton) {
            const strong = homeOwnerCardButton.querySelector('strong');
            const small = homeOwnerCardButton.querySelector('small');
            const tooltip = homeOwnerCardButton.querySelector('.tooltip-text');
            if (strong) strong.textContent = type === 'homeOwner' && needsPlacement ? 'Place Selected Owner' : 'Home Owner Ped';
            if (small) small.textContent = type === 'homeOwner' && needsPlacement ? 'Fill copied resident' : 'Place the sleeping resident';
            if (tooltip) tooltip.textContent = type === 'homeOwner' && needsPlacement
                ? 'Place the selected copied home owner into this shell.'
                : 'Place a sleeping ped inside the shell for this preset.';
        }
    }

    function renderPointManagerView() {
        const workspace = document.getElementById('houseShellCreatorWorkspace');
        const manager = document.getElementById('housePointManagerView');
        const header = document.getElementById('housePointManagerHeader');
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        const isOpen = !!houseRobberyUiState.pointManagerOpen && !!shell && !!preset;

        if (!shell || !preset) {
            houseRobberyUiState.pointManagerOpen = false;
        }

        if (workspace) workspace.style.display = isOpen ? 'none' : '';
        if (manager) manager.style.display = isOpen ? 'grid' : 'none';
        if (header) header.style.display = isOpen ? 'flex' : 'none';
        if (!isOpen) return;

        const context = document.getElementById('housePointManagerContextText');
        if (context) {
            context.textContent = `${shell.label || 'Shell'} / ${preset.label || 'Preset'}`;
        }

        renderPointManagerList();
        renderPointEditor();
    }

    function renderShellList() {
        const list = document.getElementById('houseShellList');
        if (!list) return;
        list.innerHTML = '';
        houseRobberyData.shells.forEach((shell, index) => {
            const row = document.createElement('div');
            row.className = `house-shell-list-row ${index === houseRobberyUiState.selectedShellIndex ? 'active' : ''}`;

            const card = document.createElement('div');
            card.className = `petty-crime-list-item house-shell-list-item ${index === houseRobberyUiState.selectedShellIndex ? 'active' : ''}`;
            card.tabIndex = 0;

            const editWrap = document.createElement('div');
            editWrap.className = 'house-shell-inline-edit';

            const nameCopy = document.createElement('strong');
            nameCopy.className = 'house-shell-name';
            nameCopy.textContent = shell.label || shell.model || `Shell ${index + 1}`;
            editWrap.appendChild(nameCopy);

            const renameInput = document.createElement('input');
            renameInput.type = 'text';
            renameInput.className = 'house-shell-rename-input';
            renameInput.value = shell.label || shell.model || `Shell ${index + 1}`;
            renameInput.placeholder = `Shell ${index + 1}`;
            renameInput.addEventListener('mousedown', (event) => event.stopPropagation());
            renameInput.addEventListener('click', (event) => {
                event.stopPropagation();
                if (houseRobberyUiState.selectedShellIndex !== index) {
                    houseRobberyUiState.selectedShellIndex = index;
                    houseRobberyUiState.selectedPresetIndex = 0;
                    houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                    houseRobberyUiState.pointManagerOpen = false;
                }
            });
            renameInput.addEventListener('focus', () => {
                if (houseRobberyUiState.selectedShellIndex !== index) {
                    houseRobberyUiState.selectedShellIndex = index;
                    houseRobberyUiState.selectedPresetIndex = 0;
                    houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                    houseRobberyUiState.pointManagerOpen = false;
                }
                requestAnimationFrame(() => renameInput.select());
            });
            renameInput.addEventListener('input', () => {
                const nextLabel = renameInput.value.trim() || shell.model || `Shell ${index + 1}`;
                shell.label = nextLabel;
                nameCopy.textContent = nextLabel;
            });
            renameInput.addEventListener('blur', () => {
                const nextLabel = renameInput.value.trim() || shell.model || `Shell ${index + 1}`;
                shell.label = nextLabel;
                renameInput.value = nextLabel;
                nameCopy.textContent = nextLabel;
                renderShellList();
                renderShellEditor();
            });
            renameInput.addEventListener('keydown', (event) => {
                event.stopPropagation();
                if (event.key === 'Enter') {
                    event.preventDefault();
                    renameInput.blur();
                }
            });
            editWrap.appendChild(renameInput);
            card.appendChild(editWrap);

            const status = document.createElement('span');
            status.className = `petty-crime-status ${shell.presets?.length ? 'is-enabled' : 'is-disabled'}`;
            status.textContent = `${shell.presets?.length || 0} Presets`;
            card.appendChild(status);

            card.addEventListener('click', () => {
                saveHouseShellEditorToState();
                exitHousePointPreview(true);
                houseRobberyUiState.selectedShellIndex = index;
                houseRobberyUiState.selectedPresetIndex = 0;
                houseRobberyUiState.pointManagerOpen = false;
                renderShellList();
                renderShellEditor();
            });
            card.addEventListener('keydown', (event) => {
                if (event.key !== 'Enter' && event.key !== ' ') return;
                event.preventDefault();
                card.click();
            });

            row.appendChild(card);
            list.appendChild(row);
        });
    }

    function renderPresetList(shell) {
        const list = document.getElementById('housePresetList');
        if (!list) return;
        list.innerHTML = '';
        if (!shell?.presets?.length) {
            list.innerHTML = "<div class=\"petty-crime-location-empty house-preset-list-empty\">Add a preset to start building this shell's robbable-object layout.</div>";
            return;
        }
        (shell?.presets || []).forEach((preset, index) => {
            const row = document.createElement('div');
            row.className = `house-preset-list-row ${index === houseRobberyUiState.selectedPresetIndex ? 'active' : ''}`;

            const card = document.createElement('div');
            card.className = `petty-crime-list-item house-preset-list-item ${index === houseRobberyUiState.selectedPresetIndex ? 'active' : ''}`;
            card.tabIndex = 0;

            const editWrap = document.createElement('div');
            editWrap.className = 'house-preset-inline-edit';

            const nameCopy = document.createElement('strong');
            nameCopy.className = 'house-preset-name';
            nameCopy.textContent = preset.label || `Preset ${index + 1}`;
            editWrap.appendChild(nameCopy);

            const renameInput = document.createElement('input');
            renameInput.type = 'text';
            renameInput.className = 'house-preset-rename-input';
            renameInput.value = preset.label || `Preset ${index + 1}`;
            renameInput.placeholder = `Preset ${index + 1}`;
            renameInput.addEventListener('mousedown', (event) => event.stopPropagation());
            renameInput.addEventListener('click', (event) => {
                event.stopPropagation();
                if (houseRobberyUiState.selectedPresetIndex !== index) {
                    houseRobberyUiState.selectedPresetIndex = index;
                    houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                    houseRobberyUiState.pointManagerOpen = false;
                }
            });
            renameInput.addEventListener('focus', () => {
                if (houseRobberyUiState.selectedPresetIndex !== index) {
                    houseRobberyUiState.selectedPresetIndex = index;
                    houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                    houseRobberyUiState.pointManagerOpen = false;
                }
                requestAnimationFrame(() => renameInput.select());
            });
            renameInput.addEventListener('input', () => {
                const nextLabel = renameInput.value.trim() || `Preset ${index + 1}`;
                preset.label = nextLabel;
                nameCopy.textContent = nextLabel;
            });
            renameInput.addEventListener('blur', () => {
                const nextLabel = renameInput.value.trim() || `Preset ${index + 1}`;
                preset.label = nextLabel;
                renameInput.value = nextLabel;
                nameCopy.textContent = nextLabel;
                renderPresetList(shell);
            });
            renameInput.addEventListener('keydown', (event) => {
                event.stopPropagation();
                if (event.key === 'Enter') {
                    event.preventDefault();
                    renameInput.blur();
                }
            });
            editWrap.appendChild(renameInput);
            card.appendChild(editWrap);

            const actions = document.createElement('div');
            actions.className = 'house-preset-row-actions';

            const pointsButton = document.createElement('button');
            pointsButton.type = 'button';
            pointsButton.className = 'house-preset-point-settings tooltip-container';
            pointsButton.setAttribute('aria-label', 'Open Point Settings');
            pointsButton.innerHTML = `
                <span class="petty-crime-status ${(preset.lootPoints?.length || 0) > 0 ? 'is-enabled' : 'is-disabled'}">${preset.lootPoints?.length || 0}</span>
                <i class="fas fa-gear"></i>
                <span class="tooltip-text">Open point settings for this preset</span>
            `;
            pointsButton.addEventListener('click', async (event) => {
                event.preventDefault();
                event.stopPropagation();
                saveHouseShellEditorToState();
                const changedPreset = houseRobberyUiState.selectedPresetIndex !== index;
                houseRobberyUiState.selectedPresetIndex = index;
                if (changedPreset) {
                    houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                }
                await openHousePointManager(houseRobberyUiState.selectedPointIndex || 0);
            });
            actions.appendChild(pointsButton);

            const copyButton = document.createElement('button');
            copyButton.type = 'button';
            copyButton.className = 'house-preset-copy-action tooltip-container';
            copyButton.setAttribute('aria-label', 'Copy Preset Template');
            copyButton.innerHTML = `
                <i class="fas fa-copy"></i>
                <span class="tooltip-text">Copy preset as a placement template</span>
            `;
            copyButton.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                copyHousePresetToClipboard(shell, preset);
            });
            actions.appendChild(copyButton);

            const removeButton = document.createElement('button');
            removeButton.type = 'button';
            removeButton.className = 'remove-target-button house-remove-action house-preset-inline-remove tooltip-container';
            removeButton.setAttribute('aria-label', 'Remove Loot Preset');
            removeButton.innerHTML = `
                <i class="fas fa-trash"></i>
                <span class="tooltip-text">Remove loot preset</span>
            `;
            removeButton.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                houseRobberyUiState.selectedPresetIndex = index;
                houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                houseRobberyUiState.pointManagerOpen = false;
                removeSelectedHousePreset();
            });
            actions.appendChild(removeButton);

            card.appendChild(actions);
            card.addEventListener('click', () => {
                saveHouseShellEditorToState();
                houseRobberyUiState.selectedPresetIndex = index;
                houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
                houseRobberyUiState.pointManagerOpen = false;
                renderPresetList(shell);
            });
            card.addEventListener('keydown', (event) => {
                if (event.key !== 'Enter' && event.key !== ' ') return;
                event.preventDefault();
                card.click();
            });
            row.appendChild(card);

            list.appendChild(row);
        });
    }

    function renderShellEditor() {
        const emptyState = document.getElementById('houseShellEmptyState');
        const editor = document.getElementById('houseShellEditor');
        const manager = document.getElementById('housePointManagerView');
        const workspace = document.getElementById('houseShellCreatorWorkspace');
        const shell = getSelectedShell();
        if (!shell) {
            exitHousePointPreview(true);
            if (emptyState) emptyState.style.display = 'flex';
            if (editor) editor.style.display = 'none';
            if (manager) manager.style.display = 'none';
            if (workspace) workspace.style.display = '';
            updateHousePresetClipboardButtons();
            return;
        }

        if (emptyState) emptyState.style.display = 'none';
        if (editor) editor.style.display = 'block';
        populateShellModelSelect('houseShellEditorModel', shell.model);
        const shellModelDisplay = document.getElementById('houseShellModelDisplay');
        if (shellModelDisplay) shellModelDisplay.textContent = getHouseShellDisplayName(shell.model);
        document.getElementById('houseShellExitX').value = shell.enterOffset?.x ?? 0;
        document.getElementById('houseShellExitY').value = shell.enterOffset?.y ?? 0;
        document.getElementById('houseShellExitZ').value = shell.enterOffset?.z ?? 0;
        document.getElementById('houseShellExitH').value = shell.enterOffset?.w ?? 0;
        renderPresetList(shell);
        updateHousePresetClipboardButtons();
        renderPointManagerView();
        refreshHouseRobberySelects(editor);
    }

    function createHouseShellProfile(label, model) {
        const configured = getShellConfigByModel(model);
        houseRobberyData.shells.push(normalizeShell({
            id: `shell_${Date.now()}`,
            label,
            model,
            shellType: configured?.shellType || configured?.type || (configured?.isWorldInterior ? 'world' : 'shell'),
            isWorldInterior: configured?.isWorldInterior === true || String(configured?.shellType || configured?.type || '').toLowerCase() === 'world',
            enterOffset: configured?.enterOffset,
            presets: [],
        }, houseRobberyData.shells.length));
        document.getElementById('houseShellProfileName').value = '';
        houseRobberyUiState.selectedShellIndex = houseRobberyData.shells.length - 1;
        houseRobberyUiState.selectedPresetIndex = 0;
        houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
        houseRobberyUiState.pointManagerOpen = false;
        renderShellList();
        renderShellEditor();
    }

    function createHousePreset(label) {
        const shell = getSelectedShell();
        if (!shell) return;
        shell.presets.push(normalizePreset({ id: `preset_${Date.now()}`, label, lootPoints: [] }, shell.presets.length));
        houseRobberyUiState.selectedPresetIndex = shell.presets.length - 1;
        houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
        houseRobberyUiState.pointManagerOpen = false;
        renderPresetList(shell);
    }

    function openHouseShellPicker(profileLabel) {
        const configuredShells = getConfiguredHouseShells();
        if (!configuredShells.length) {
            if (typeof rcNotify === 'function') {
                rcNotify('No configured house shells were found.', 'error');
            }
            return;
        }

        const panel = document.getElementById('houseShellPickerPanel');
        const meta = document.getElementById('houseShellPickerProfileMeta');
        if (!panel) return;

        panel.dataset.pendingProfileLabel = String(profileLabel || '').trim();
        if (meta) {
            meta.textContent = `Select the shell for "${panel.dataset.pendingProfileLabel || 'New Shell Profile'}". This choice is locked after creation.`;
        }

        const defaultModel = configuredShells[0]?.model || '';
        populateShellModelSelect('houseShellModelSelect', defaultModel);
        document.getElementById('houseShellModelSelect')?.dispatchEvent(new Event('change', { bubbles: true }));
        OpenFeatureModal(document.getElementById('houseRobberyMainPageContainer') || document.body, 'Select Shell', panel);
        refreshHouseRobberySelects(panel);
        document.getElementById('houseShellModelSelect')?.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function openHousePresetCreator() {
        const shell = getSelectedShell();
        const panel = document.getElementById('housePresetCreatePanel');
        const input = document.getElementById('housePresetCreateName');
        if (!shell || !panel || !input) return;

        input.value = `Preset ${shell.presets.length + 1}`;
        OpenFeatureModal(document.getElementById('housePresetSidebar') || document.getElementById('houseRobberyMainPageContainer') || document.body, 'Create Preset', panel);
        window.setTimeout(() => {
            input.focus();
            input.select();
        }, 0);
    }

    function renderLocationList() {
        const list = document.getElementById('houseLocationList');
        if (!list) return;
        list.innerHTML = '';
        houseRobberyData.locations.forEach((location, index) => {
            const row = document.createElement('div');
            row.className = `house-location-list-row ${index === houseRobberyUiState.selectedLocationIndex ? 'active' : ''}`;

            const card = document.createElement('div');
            card.className = `petty-crime-list-item house-location-list-item ${index === houseRobberyUiState.selectedLocationIndex ? 'active' : ''}`;
            card.tabIndex = 0;

            const editWrap = document.createElement('div');
            editWrap.className = 'house-location-inline-edit';

            const nameCopy = document.createElement('strong');
            nameCopy.className = 'house-location-name';
            nameCopy.textContent = location.label || 'House Robbery';
            editWrap.appendChild(nameCopy);

            const renameInput = document.createElement('input');
            renameInput.type = 'text';
            renameInput.className = 'house-location-rename-input';
            renameInput.value = location.label || 'House Robbery';
            renameInput.placeholder = `House Robbery ${index + 1}`;
            renameInput.addEventListener('mousedown', (event) => event.stopPropagation());
            renameInput.addEventListener('click', (event) => {
                event.stopPropagation();
                if (houseRobberyUiState.selectedLocationIndex !== index) {
                    houseRobberyUiState.selectedLocationIndex = index;
                }
            });
            renameInput.addEventListener('focus', () => {
                if (houseRobberyUiState.selectedLocationIndex !== index) {
                    houseRobberyUiState.selectedLocationIndex = index;
                }
                requestAnimationFrame(() => renameInput.select());
            });
            renameInput.addEventListener('input', () => {
                const nextLabel = renameInput.value.trim() || `House Robbery ${index + 1}`;
                location.label = nextLabel;
                nameCopy.textContent = nextLabel;
            });
            renameInput.addEventListener('blur', () => {
                const nextLabel = renameInput.value.trim() || `House Robbery ${index + 1}`;
                location.label = nextLabel;
                renameInput.value = nextLabel;
                nameCopy.textContent = nextLabel;
                renderLocationList();
            });
            renameInput.addEventListener('keydown', (event) => {
                event.stopPropagation();
                if (event.key === 'Enter') {
                    event.preventDefault();
                    renameInput.blur();
                }
            });
            editWrap.appendChild(renameInput);

            const streetCopy = document.createElement('small');
            streetCopy.className = 'house-location-street';
            streetCopy.textContent = location.streetName || 'No street yet';
            editWrap.appendChild(streetCopy);
            card.appendChild(editWrap);

            const actions = document.createElement('div');
            actions.className = 'house-location-row-actions';

            const status = document.createElement('span');
            status.className = `petty-crime-status ${location.enabled ? 'is-enabled' : 'is-disabled'}`;
            status.textContent = location.enabled ? 'Live' : 'Off';
            actions.appendChild(status);

            const duplicateButton = document.createElement('button');
            duplicateButton.type = 'button';
            duplicateButton.className = 'house-location-duplicate-button';
            duplicateButton.title = 'Duplicate this house robbery to a new placed location';
            duplicateButton.innerHTML = '<i class="fas fa-copy"></i>';
            duplicateButton.addEventListener('mousedown', (event) => event.stopPropagation());
            duplicateButton.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                createHouseLocationFromPlacement(location);
            });
            actions.appendChild(duplicateButton);

            const teleportButton = document.createElement('button');
            teleportButton.type = 'button';
            teleportButton.className = 'house-location-teleport-button';
            teleportButton.title = hasHousePlacementCoords(location.entry) ? 'Teleport to house location' : 'Place the house location first';
            teleportButton.innerHTML = '<i class="fas fa-location-arrow"></i>';
            teleportButton.disabled = !hasHousePlacementCoords(location.entry);
            teleportButton.addEventListener('mousedown', (event) => event.stopPropagation());
            teleportButton.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                if (!hasHousePlacementCoords(location.entry)) return;
                $.post(`https://${GetParentResourceName()}/TeleportToPosition`, JSON.stringify({
                    x: Number(location.entry.coords.x || 0),
                    y: Number(location.entry.coords.y || 0),
                    z: Number(location.entry.coords.z || 0),
                }));
            });
            actions.appendChild(teleportButton);

            card.appendChild(actions);

            card.addEventListener('click', () => {
                saveHouseLocationEditorToState();
                houseRobberyUiState.selectedLocationIndex = index;
                renderLocationList();
                renderLocationEditor();
            });
            card.addEventListener('keydown', (event) => {
                if (event.key !== 'Enter' && event.key !== ' ') return;
                event.preventDefault();
                card.click();
            });

            row.appendChild(card);
            list.appendChild(row);
        });
        updateHouseLocationListScrollLimit(list);
        scrollSelectedHouseLocationIntoView(list);
    }

    function updateHouseLocationListScrollLimit(list) {
        if (!list) return;

        const rows = Array.from(list.querySelectorAll('.house-location-list-row'));
        const isScrollable = rows.length > HOUSE_LOCATION_LIST_VISIBLE_ROWS;
        list.classList.toggle('is-scrollable', isScrollable);

        if (!isScrollable) {
            list.style.removeProperty('--house-location-list-max-height');
            return;
        }

        const visibleRows = rows.slice(0, HOUSE_LOCATION_LIST_VISIBLE_ROWS);
        const firstRow = visibleRows[0];
        const lastRow = visibleRows[visibleRows.length - 1];
        const maxHeight = firstRow && lastRow
            ? Math.ceil((lastRow.offsetTop - firstRow.offsetTop) + lastRow.offsetHeight)
            : 0;

        if (maxHeight > 0) {
            list.style.setProperty('--house-location-list-max-height', `${maxHeight}px`);
        } else {
            list.style.removeProperty('--house-location-list-max-height');
        }
    }

    function scrollSelectedHouseLocationIntoView(list) {
        if (!list || !list.classList.contains('is-scrollable')) return;

        const activeRow = list.querySelector('.house-location-list-row.active');
        if (!activeRow) return;

        const rowTop = activeRow.offsetTop;
        const rowBottom = rowTop + activeRow.offsetHeight;
        const viewTop = list.scrollTop;
        const viewBottom = viewTop + list.clientHeight;

        if (rowTop < viewTop) {
            list.scrollTop = rowTop;
        } else if (rowBottom > viewBottom) {
            list.scrollTop = rowBottom - list.clientHeight;
        }
    }

    function renderShellAssignments(location) {
        const container = document.getElementById('houseLocationShellAssignments');
        const meta = document.getElementById('houseLocationShellAssignmentsMeta');
        if (!container) return;
        container.innerHTML = '';

        if (!houseRobberyData.shells.length) {
            container.innerHTML = '<div class="petty-crime-location-empty">Create at least one shell profile first.</div>';
            if (meta) meta.textContent = 'No shell profiles created yet.';
            return;
        }

        let selectedShellCount = 0;
        let selectedPresetCount = 0;

        houseRobberyData.shells.forEach((shell) => {
            const enabled = (location.shellIds || []).includes(shell.id);
            const allowedPresets = Array.isArray(location.presetSelections?.[shell.id]) ? location.presetSelections[shell.id] : [];
            if (enabled) {
                selectedShellCount += 1;
                selectedPresetCount += allowedPresets.length || (shell.presets || []).length || 0;
            }
            const card = document.createElement('div');
            card.className = 'house-shell-assignment';
            card.dataset.shellId = shell.id;
            card.innerHTML = `
                <label class="house-shell-assignment-head">
                    <span>
                        <strong>${escapeHouseHtml(shell.label)}</strong>
                        <small>${escapeHouseHtml(shell.model)}</small>
                    </span>
                    <input type="checkbox" class="house-shell-enabled" ${enabled ? 'checked' : ''}>
                </label>
                <div class="house-shell-preset-checks ${enabled ? '' : 'is-disabled'}">
                    ${(shell.presets || []).map((preset) => `
                        <label class="house-preset-check">
                            <input type="checkbox" class="house-preset-enabled" value="${escapeHouseHtml(preset.id)}" ${(allowedPresets.length ? allowedPresets.includes(preset.id) : true) ? 'checked' : ''}>
                            <span>${escapeHouseHtml(preset.label)}</span>
                        </label>
                    `).join('')}
                </div>
            `;
            const shellToggle = card.querySelector('.house-shell-enabled');
            const presetWrap = card.querySelector('.house-shell-preset-checks');
            shellToggle?.addEventListener('change', () => {
                presetWrap?.classList.toggle('is-disabled', !shellToggle.checked);
                saveHouseLocationEditorToState();
                renderShellAssignments(getSelectedLocation());
            });
            card.querySelectorAll('.house-preset-enabled').forEach((presetToggle) => {
                presetToggle.addEventListener('change', () => {
                    saveHouseLocationEditorToState();
                    renderShellAssignments(getSelectedLocation());
                });
            });
            container.appendChild(card);
        });

        if (meta) {
            if (!selectedShellCount) {
                meta.textContent = 'No shells selected yet.';
            } else {
                const shellLabel = selectedShellCount === 1 ? 'shell' : 'shells';
                const presetLabel = selectedPresetCount === 1 ? 'preset' : 'presets';
                meta.textContent = `${selectedShellCount} ${shellLabel} selected • ${selectedPresetCount} ${presetLabel} allowed`;
            }
        }
    }

    function houseLocationPanelHasData(panelId) {
        const panel = document.getElementById(panelId);
        if (!panel) return false;

        if (typeof rcHasMeaningfulData === 'function' && rcHasMeaningfulData(panel)) {
            return true;
        }

        const defaults = getHouseLocationDefaults();
        if (panelId === 'houseLocationRewardMoneyOptions') {
            const type = document.getElementById('houseLocationRewardType')?.value || defaults.rewardType;
            const min = String(document.getElementById('houseLocationRewardMinMoney')?.value || defaults.minMoney);
            const max = String(document.getElementById('houseLocationRewardMaxMoney')?.value || defaults.maxMoney);
            const chance = String(document.getElementById('houseLocationRewardMoneyChance')?.value || defaults.moneyChance);
            return type !== defaults.rewardType || min !== String(defaults.minMoney) || max !== String(defaults.maxMoney) || chance !== String(defaults.moneyChance);
        }

        if (panelId === 'houseLocationXpOptions') {
            const reward = String(document.getElementById('houseLocationXpRewardAmount')?.value || defaults.xpRewardAmount);
            const needed = String(document.getElementById('houseLocationXpNeededAmount')?.value || defaults.xpNeededAmount);
            const remove = !!document.getElementById('houseLocationRemoveXpOnHitCheckbox')?.checked;
            const removeAmount = String(document.getElementById('houseLocationXpRemoveAmount')?.value || defaults.xpRemoveAmount);
            return reward !== String(defaults.xpRewardAmount)
                || needed !== String(defaults.xpNeededAmount)
                || remove
                || removeAmount !== String(defaults.xpRemoveAmount);
        }

        return false;
    }

    function renderShellAssignments(location) {
        const container = document.getElementById('houseLocationShellAssignments');
        const meta = document.getElementById('houseLocationShellAssignmentsMeta');
        if (!container) return;
        const selectedLocation = location || getSelectedLocation() || {};
        const shells = Array.isArray(houseRobberyData.shells) ? houseRobberyData.shells : [];
        container.innerHTML = '';

        if (!shells.length) {
            container.innerHTML = '<div class="petty-crime-location-empty">Create at least one shell profile first.</div>';
            if (meta) meta.textContent = 'No shell profiles created yet.';
            return;
        }

        let selectedShellCount = 0;
        let selectedPresetCount = 0;
        let totalPresetCount = 0;

        shells.forEach((shell) => {
            const presetTotal = Array.isArray(shell.presets) ? shell.presets.length : 0;
            const enabled = (selectedLocation.shellIds || []).includes(shell.id);
            const allowedPresets = Array.isArray(selectedLocation.presetSelections?.[shell.id]) ? selectedLocation.presetSelections[shell.id] : [];
            totalPresetCount += presetTotal;
            if (enabled) {
                selectedShellCount += 1;
                selectedPresetCount += allowedPresets.length || presetTotal;
            }
        });

        const summary = document.createElement('div');
        summary.className = 'house-shell-assignment-summary';
        summary.innerHTML = `
            <div class="house-shell-summary-item">
                <span>Shells</span>
                <strong>${selectedShellCount}/${shells.length}</strong>
            </div>
            <div class="house-shell-summary-item">
                <span>Presets</span>
                <strong>${selectedPresetCount}/${totalPresetCount}</strong>
            </div>
            <div class="house-shell-summary-item">
                <span>Status</span>
                <strong>${selectedShellCount ? 'Ready' : 'None'}</strong>
            </div>
        `;
        container.appendChild(summary);

        shells.forEach((shell) => {
            const enabled = (selectedLocation.shellIds || []).includes(shell.id);
            const presets = Array.isArray(shell.presets) ? shell.presets : [];
            const allowedPresets = Array.isArray(selectedLocation.presetSelections?.[shell.id]) ? selectedLocation.presetSelections[shell.id] : [];
            const presetTotal = presets.length;
            const selectedForShell = enabled ? (allowedPresets.length || presetTotal) : 0;
            const presetLabel = presetTotal === 1 ? 'Preset' : 'Presets';

            const presetMarkup = presetTotal
                ? presets.map((preset) => {
                    const checked = allowedPresets.length ? allowedPresets.includes(preset.id) : true;
                    return `
                    <label class="house-preset-check ${checked ? 'is-checked' : ''}">
                        <input type="checkbox" class="house-preset-enabled" value="${escapeHouseHtml(preset.id)}" ${checked ? 'checked' : ''}>
                        <span class="house-preset-check-indicator"><i class="fas fa-check"></i></span>
                        <span class="house-preset-check-label">${escapeHouseHtml(preset.label)}</span>
                    </label>
                `;
                }).join('')
                : '<div class="petty-crime-location-empty house-shell-preset-empty">No presets created for this shell yet.</div>';

            const card = document.createElement('div');
            card.className = `house-shell-assignment ${enabled ? 'is-enabled' : 'is-disabled'}`;
            card.dataset.shellId = shell.id;
            card.innerHTML = `
                <div class="house-shell-assignment-head">
                    <span class="house-shell-assignment-icon">
                        <i class="fas fa-house-user"></i>
                    </span>
                    <span class="house-shell-assignment-copy">
                        <strong>${escapeHouseHtml(shell.label)}</strong>
                        <small>${escapeHouseHtml(shell.model)}</small>
                    </span>
                    <span class="house-shell-assignment-count">
                        <strong>${selectedForShell}/${presetTotal}</strong>
                        <small>${presetLabel}</small>
                    </span>
                    <span class="house-shell-assignment-toggle">
                        <input type="checkbox" class="house-shell-enabled" ${enabled ? 'checked' : ''}>
                        <span class="house-shell-toggle-track" aria-hidden="true"></span>
                        <span class="house-shell-toggle-label">${enabled ? 'Enabled' : 'Disabled'}</span>
                    </span>
                </div>
                <div class="house-shell-assignment-body">
                    <div class="house-shell-assignment-kicker">
                        <span>${enabled ? 'Allowed Presets' : 'Presets'}</span>
                        <small>${enabled ? `${selectedForShell} active` : `${presetTotal} available`}</small>
                    </div>
                    <div class="house-shell-preset-checks ${enabled ? '' : 'is-disabled'}">
                        ${presetMarkup}
                    </div>
                </div>
            `;

            const shellToggle = card.querySelector('.house-shell-enabled');
            const presetWrap = card.querySelector('.house-shell-preset-checks');
            shellToggle?.addEventListener('change', () => {
                presetWrap?.classList.toggle('is-disabled', !shellToggle.checked);
                saveHouseLocationEditorToState();
                renderShellAssignments(getSelectedLocation());
            });
            card.querySelectorAll('.house-preset-enabled').forEach((presetToggle) => {
                presetToggle.addEventListener('change', () => {
                    saveHouseLocationEditorToState();
                    renderShellAssignments(getSelectedLocation());
                });
            });
            container.appendChild(card);
        });

        if (meta) {
            if (!selectedShellCount) {
                meta.textContent = 'No shells selected yet.';
            } else {
                const shellLabel = selectedShellCount === 1 ? 'shell' : 'shells';
                const presetLabel = selectedPresetCount === 1 ? 'preset' : 'presets';
                meta.textContent = `${selectedShellCount} ${shellLabel} selected - ${selectedPresetCount} ${presetLabel} allowed`;
            }
        }
    }

    function bindHouseLocationFeatureToggles() {
        const locationEditor = document.getElementById('houseLocationEditor');
        const shellAssignmentsButton = document.getElementById('openHouseLocationShellAssignmentsButton');
        const shellAssignmentsPanel = document.getElementById('houseLocationShellAssignments');
        if (shellAssignmentsButton && shellAssignmentsPanel && shellAssignmentsButton.dataset.rcBound !== '1') {
            shellAssignmentsButton.dataset.rcBound = '1';
            shellAssignmentsButton.addEventListener('click', (e) => {
                e.preventDefault();
                e.stopPropagation();
                if (typeof OpenFeatureModal === 'function') {
                    OpenFeatureModal(locationEditor || document.getElementById('houseLocationCreatorPanel') || document.body, 'Shells & Presets', shellAssignmentsPanel);
                }
            });
        }

        const syncHouseLocationXpRemoveAmount = () => {
            const xpEnabled = !!document.getElementById('houseLocationXpOptionsCheckbox')?.checked;
            const removeEnabled = xpEnabled && !!document.getElementById('houseLocationRemoveXpOnHitCheckbox')?.checked;
            const removeXpWrap = document.getElementById('houseLocationXpRemoveAmountWrap');
            if (!removeXpWrap) return;
            removeXpWrap.classList.toggle('hidden', !removeEnabled);
            removeXpWrap.style.display = removeEnabled ? 'grid' : 'none';
        };

        [
            ['houseLocationXpOptionsCheckbox', 'houseLocationXpOptions', 'openHouseLocationXpOptionsButton', 'House Robbery XP Options'],
            ['houseLocationRequiredItemCheckbox', 'houseLocationRequiredItemOptions', 'openHouseLocationRequiredItemOptionsButton', 'Required Items'],
            ['houseLocationRewardItemCheckbox', 'houseLocationRewardItemOptions', 'openHouseLocationRewardItemOptionsButton', 'Reward Items'],
            ['houseLocationMoneyRewardCheckbox', 'houseLocationRewardMoneyOptions', 'openHouseLocationRewardMoneyOptionsButton', 'Reward Money'],
        ].forEach(([checkboxId, panelId, buttonId, modalTitle]) => {
            const checkbox = document.getElementById(checkboxId);
            const panel = document.getElementById(panelId);
            const button = buttonId ? document.getElementById(buttonId) : null;
            if (!checkbox || !panel) return;

            const sync = (openWhenChecked = false) => {
                const enabled = !!checkbox.checked;
                const hasData = houseLocationPanelHasData(panelId);
                const keepButtonForSavedData = panelId !== 'houseLocationXpOptions' && hasData;
                if (button) button.classList.toggle('hidden', !(enabled || keepButtonForSavedData));
                if (panelId === 'houseLocationXpOptions') syncHouseLocationXpRemoveAmount();

                if (button) {
                    panel.classList.add('hidden');
                    if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                        panel.style.display = 'none';
                    }
                } else {
                    panel.style.display = enabled ? 'block' : 'none';
                    panel.classList.toggle('hidden', !enabled);
                }

                saveHouseLocationEditorToState();

                if (button && openWhenChecked && enabled && typeof OpenFeatureModal === 'function') {
                    OpenFeatureModal(locationEditor || document.getElementById('houseLocationCreatorPanel') || document.body, modalTitle, panel);
                }
            };

            if (button && button.dataset.rcBound !== '1') {
                button.dataset.rcBound = '1';
                button.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    if (!checkbox.checked) return;
                    if (typeof OpenFeatureModal === 'function') {
                        OpenFeatureModal(locationEditor || document.getElementById('houseLocationCreatorPanel') || document.body, modalTitle, panel);
                    }
                });
            }

            sync(false);
            checkbox.onchange = () => sync(true);
        });

        const removeXpCheckbox = document.getElementById('houseLocationRemoveXpOnHitCheckbox');
        if (removeXpCheckbox) {
            removeXpCheckbox.onchange = () => {
                syncHouseLocationXpRemoveAmount();
                saveHouseLocationEditorToState();
            };
        }
    }

    function collapseHouseLocationFeaturePanels() {
        [
            'houseLocationShellAssignments',
            'houseLocationXpOptions',
            'houseLocationRequiredItemOptions',
            'houseLocationRewardItemOptions',
            'houseLocationRewardMoneyOptions',
        ].forEach((panelId) => {
            const panel = document.getElementById(panelId);
            if (!panel) return;
            if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                panel.classList.add('hidden');
                panel.style.display = 'none';
            }
        });
    }

    function bindHouseBatchFeatureToggles() {
        const settingsPanel = document.getElementById('houseGlobalSettingsPanel');
        const syncHouseBatchXpRemoveAmount = () => {
            const xpEnabled = !!document.getElementById('houseBatchXpOptionsCheckbox')?.checked;
            const removeEnabled = xpEnabled && !!document.getElementById('houseBatchRemoveXpOnHitCheckbox')?.checked;
            const removeXpWrap = document.getElementById('houseBatchXpRemoveAmountWrap');
            if (!removeXpWrap) return;
            removeXpWrap.classList.toggle('hidden', !removeEnabled);
            removeXpWrap.style.display = removeEnabled ? 'grid' : 'none';
        };

        [
            ['houseBatchXpOptionsCheckbox', 'houseBatchXpOptions', 'openHouseBatchXpOptionsButton', 'XP Options'],
            ['houseBatchRequiredItemCheckbox', 'houseBatchRequiredItemOptions', 'openHouseBatchRequiredItemOptionsButton', 'Required Items'],
            ['houseBatchRewardItemCheckbox', 'houseBatchRewardItemOptions', 'openHouseBatchRewardItemOptionsButton', 'Reward Items'],
            ['houseBatchMoneyRewardCheckbox', 'houseBatchRewardMoneyOptions', 'openHouseBatchRewardMoneyOptionsButton', 'Reward Money'],
        ].forEach(([checkboxId, panelId, buttonId, modalTitle]) => {
            const checkbox = document.getElementById(checkboxId);
            const panel = document.getElementById(panelId);
            const button = buttonId ? document.getElementById(buttonId) : null;
            if (!checkbox || !panel) return;

            const sync = (openWhenChecked = false) => {
                const enabled = !!checkbox.checked;
                const hasData = houseBatchPanelHasData(panelId);
                const keepButtonForSavedData = panelId !== 'houseBatchXpOptions' && hasData;
                if (button) button.classList.toggle('hidden', !(enabled || keepButtonForSavedData));
                if (panelId === 'houseBatchXpOptions') syncHouseBatchXpRemoveAmount();

                if (button) {
                    panel.classList.add('hidden');
                    if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                        panel.style.display = 'none';
                    }
                } else {
                    panel.style.display = enabled ? 'block' : 'none';
                    panel.classList.toggle('hidden', !enabled);
                }

                saveHouseGlobalSettingsEditorToState();

                if (button && openWhenChecked && enabled && typeof OpenFeatureModal === 'function') {
                    OpenFeatureModal(settingsPanel || document.getElementById('houseRobberyMainPageContainer') || document.body, modalTitle, panel);
                }
            };

            if (button && button.dataset.rcBound !== '1') {
                button.dataset.rcBound = '1';
                button.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    if (typeof OpenFeatureModal === 'function') {
                        OpenFeatureModal(settingsPanel || document.getElementById('houseRobberyMainPageContainer') || document.body, modalTitle, panel);
                    }
                });
            }

            sync(false);
            checkbox.onchange = () => sync(true);
        });

        const removeXpCheckbox = document.getElementById('houseBatchRemoveXpOnHitCheckbox');
        if (removeXpCheckbox) {
            removeXpCheckbox.onchange = () => {
                syncHouseBatchXpRemoveAmount();
                saveHouseGlobalSettingsEditorToState();
            };
        }
    }

    function collapseHouseBatchFeaturePanels() {
        [
            'houseBatchXpOptions',
            'houseBatchRequiredItemOptions',
            'houseBatchRewardItemOptions',
            'houseBatchRewardMoneyOptions',
        ].forEach((panelId) => {
            const panel = document.getElementById(panelId);
            if (!panel) return;
            if (!window.rcFeatureModalIsOpen || !rcFeatureModalIsOpen() || typeof _rcFeature === 'undefined' || !_rcFeature || _rcFeature.panel !== panel) {
                panel.classList.add('hidden');
                panel.style.display = 'none';
            }
        });
    }

    function renderLocationEditor() {
        const emptyState = document.getElementById('houseLocationEmptyState');
        const editor = document.getElementById('houseLocationEditor');
        const location = getSelectedLocation();
        const defaults = getHouseLocationDefaults();
        if (!location) {
            if (emptyState) emptyState.style.display = 'flex';
            if (editor) editor.style.display = 'none';
            return;
        }

        if (emptyState) emptyState.style.display = 'none';
        if (editor) editor.style.display = 'block';

        document.getElementById('houseLocationEnabled').checked = !!location.enabled;
        document.getElementById('houseLocationInteractionLabel').value = location.interactionLabel || defaults.interactionLabel;
        document.getElementById('houseLocationProgressLabel').value = location.progressLabel || defaults.progressLabel;
        document.getElementById('houseLocationProgressDuration').value = location.progressDuration ?? defaults.progressDuration;
        document.getElementById('houseLocationRewardType').value = location.rewardType || defaults.rewardType;
        document.getElementById('houseLocationRewardMinMoney').value = location.minMoney ?? defaults.minMoney;
        document.getElementById('houseLocationRewardMaxMoney').value = location.maxMoney ?? defaults.maxMoney;
        document.getElementById('houseLocationRewardMoneyChance').value = location.moneyChance ?? defaults.moneyChance;
        document.getElementById('houseLocationMoneyRewardCheckbox').checked = !!location.moneyReward;
        document.getElementById('houseLocationXpOptionsCheckbox').checked = !!location.xpOptions;
        document.getElementById('houseLocationXpRewardAmount').value = location.xpRewardAmount ?? defaults.xpRewardAmount;
        document.getElementById('houseLocationXpNeededAmount').value = location.xpNeededAmount ?? defaults.xpNeededAmount;
        document.getElementById('houseLocationRemoveXpOnHitCheckbox').checked = !!location.removeXpOnHit;
        document.getElementById('houseLocationXpRemoveAmount').value = location.xpRemoveAmount ?? defaults.xpRemoveAmount;
        document.getElementById('houseLocationRequiredItemCheckbox').checked = Array.isArray(location.requiredItems) && location.requiredItems.length > 0;
        document.getElementById('houseLocationRewardItemCheckbox').checked = Array.isArray(location.rewardItems) && location.rewardItems.length > 0;
        document.getElementById('houseEntryPositionMeta').textContent = formatPlacementMeta(location.entry);

        const minigameSelect = document.getElementById('houseLocationMinigame');
        if (minigameSelect) {
            minigameSelect.innerHTML = '';
            rcMiniGameOptions().forEach((entry) => {
                const option = document.createElement('option');
                option.value = entry.value;
                option.textContent = entry.label;
                if (entry.value === (location.minigameOption || 'none')) option.selected = true;
                minigameSelect.appendChild(option);
            });
        }

        renderShellAssignments(location);

        const reqList = document.querySelector('#houseLocationRequiredItemOptions .item-list');
        const rewardList = document.querySelector('#houseLocationRewardItemOptions .reward-item-list');
        if (reqList) reqList.innerHTML = '';
        if (rewardList) rewardList.innerHTML = '';
        (location.requiredItems || []).forEach((item) => addHouseRequiredItemRow('houseLocationRequiredItemOptions', item));
        (location.rewardItems || []).forEach((item) => addHouseRewardItemRow('houseLocationRewardItemOptions', item));

        bindHouseLocationFeatureToggles();
        collapseHouseLocationFeaturePanels();
        refreshHouseRobberySelects(editor);
        try { bindItemHandlers(); } catch (e) {}
    }

    function renderHouseAlertEditor() {
        const defaults = normalizeHouseAlertSettings(houseRobberyData?.settings || {});
        populateHouseAlertSelects();
        document.getElementById('houseGlobalSendAlertCheckbox').checked = !!defaults.sendAlert;
        document.getElementById('houseGlobalPoliceRequired').value = defaults.policeRequired ?? 0;
        document.getElementById('houseGlobalAlertChance').value = defaults.alertChance ?? '100';
        document.getElementById('houseGlobalPoliceAlertHeader').value = defaults.policeAlertHeader || '';
        document.getElementById('houseGlobalPoliceAlert').value = defaults.policeAlert || '';
        document.getElementById('houseGlobalAlertCode').value = defaults.alertCode || '';
        document.getElementById('houseGlobalAlertCamId').value = defaults.alertCamId || '';
        document.getElementById('houseGlobalAlertIcon').value = defaults.alertIcon || '';
        document.getElementById('houseGlobalAlertPriority').value = defaults.alertPriority || '';
        document.getElementById('houseGlobalBlipSprite').value = defaults.blipSprite ?? '';
        document.getElementById('houseGlobalBlipColor').value = defaults.blipColor || '';
        document.getElementById('houseGlobalBlipScale').value = defaults.blipScale ?? '';
        document.getElementById('houseGlobalAlertSound1').value = defaults.alertSound1 || '';
        document.getElementById('houseGlobalBlipFlash').value = String(!!defaults.blipFlash);
        document.getElementById('houseGlobalPoliceJobs').value = Array.isArray(defaults.policeJobs) ? defaults.policeJobs.join(', ') : '';
        refreshHouseRobberySelects(document.getElementById('houseGlobalAlertPanel') || document);
    }

    function renderHouseGlobalSettingsEditor() {
        const defaults = normalizeHouseAlertSettings(houseRobberyData?.settings || {});
        const batch = getHouseBatchLocationSettings();
        document.getElementById('houseGlobalCooldown').value = defaults.cooldown ?? 30;
        document.getElementById('houseMissionNpcCheckbox').checked = !!defaults.missionNpcEnabled;
        document.getElementById('houseMissionNpcPlacement').value = formatPlacementMeta(defaults.missionNpc);
        const missionTeleportButton = document.getElementById('teleportHouseMissionNpcButton');
        if (missionTeleportButton) {
            missionTeleportButton.disabled = !hasHousePlacementCoords(defaults.missionNpc);
            missionTeleportButton.title = hasHousePlacementCoords(defaults.missionNpc)
                ? 'Teleport to mission NPC'
                : 'Place the mission NPC first';
        }
        document.getElementById('houseBatchEnabled').checked = !!batch.enabled;
        document.getElementById('houseBatchInteractionLabel').value = batch.interactionLabel || '';
        document.getElementById('houseBatchProgressLabel').value = batch.progressLabel || '';
        document.getElementById('houseBatchProgressDuration').value = batch.progressDuration ?? getHouseLocationDefaults().progressDuration;
        document.getElementById('houseBatchMoneyRewardCheckbox').checked = !!batch.moneyRewardEnabled;
        document.getElementById('houseBatchRewardType').value = batch.rewardType || getHouseLocationDefaults().rewardType;
        document.getElementById('houseBatchRewardMinMoney').value = batch.minMoney ?? getHouseLocationDefaults().minMoney;
        document.getElementById('houseBatchRewardMaxMoney').value = batch.maxMoney ?? getHouseLocationDefaults().maxMoney;
        document.getElementById('houseBatchRewardMoneyChance').value = batch.moneyChance ?? getHouseLocationDefaults().moneyChance;
        document.getElementById('houseBatchXpOptionsCheckbox').checked = !!batch.xpOptionsEnabled;
        document.getElementById('houseBatchXpRewardAmount').value = batch.xpRewardAmount ?? getHouseLocationDefaults().xpRewardAmount;
        document.getElementById('houseBatchXpNeededAmount').value = batch.xpNeededAmount ?? getHouseLocationDefaults().xpNeededAmount;
        document.getElementById('houseBatchRemoveXpOnHitCheckbox').checked = !!batch.removeXpOnHit;
        document.getElementById('houseBatchXpRemoveAmount').value = batch.xpRemoveAmount ?? getHouseLocationDefaults().xpRemoveAmount;
        document.getElementById('houseBatchRequiredItemCheckbox').checked = !!batch.requiredItemsEnabled;
        document.getElementById('houseBatchRewardItemCheckbox').checked = !!batch.rewardItemsEnabled;

        const minigameSelect = document.getElementById('houseBatchMinigame');
        if (minigameSelect) {
            minigameSelect.innerHTML = '';
            rcMiniGameOptions().forEach((entry) => {
                const option = document.createElement('option');
                option.value = entry.value;
                option.textContent = entry.label;
                if (entry.value === (batch.minigameOption || 'none')) option.selected = true;
                minigameSelect.appendChild(option);
            });
        }

        const reqList = document.querySelector('#houseBatchRequiredItemOptions .item-list');
        const rewardList = document.querySelector('#houseBatchRewardItemOptions .reward-item-list');
        if (reqList) reqList.innerHTML = '';
        if (rewardList) rewardList.innerHTML = '';
        (batch.requiredItems || []).forEach((item) => addHouseRequiredItemRow('houseBatchRequiredItemOptions', item));
        (batch.rewardItems || []).forEach((item) => addHouseRewardItemRow('houseBatchRewardItemOptions', item));

        bindHouseBatchFeatureToggles();
        collapseHouseBatchFeaturePanels();
        refreshHouseRobberySelects(document.getElementById('houseGlobalSettingsPanel') || document);
        try { bindItemHandlers(); } catch (e) {}
    }

    function switchHousePanel(panelKey) {
        saveHouseShellEditorToState();
        saveHouseLocationEditorToState();
        saveHouseAlertEditorToState();
        saveHouseGlobalSettingsEditorToState();
        if (panelKey !== 'shells') {
            houseRobberyUiState.pointManagerOpen = false;
            exitHousePointPreview(true);
        }
        houseRobberyUiState.activePanel = panelKey;
        document.getElementById('houseShellCreatorTab')?.classList.toggle('active', panelKey === 'shells');
        document.getElementById('houseLocationCreatorTab')?.classList.toggle('active', panelKey === 'locations');
        document.getElementById('houseGlobalAlertTab')?.classList.toggle('active', panelKey === 'alerts');
        document.getElementById('houseGlobalSettingsTab')?.classList.toggle('active', panelKey === 'global-settings');
        const shellPanel = document.getElementById('houseShellCreatorPanel');
        const locationPanel = document.getElementById('houseLocationCreatorPanel');
        const alertPanel = document.getElementById('houseGlobalAlertPanel');
        const globalSettingsPanel = document.getElementById('houseGlobalSettingsPanel');
        const pointManagerHeader = document.getElementById('housePointManagerHeader');
        if (shellPanel) shellPanel.style.display = panelKey === 'shells' ? 'block' : 'none';
        if (locationPanel) locationPanel.style.display = panelKey === 'locations' ? 'block' : 'none';
        if (alertPanel) alertPanel.style.display = panelKey === 'alerts' ? 'block' : 'none';
        if (globalSettingsPanel) globalSettingsPanel.style.display = panelKey === 'global-settings' ? 'block' : 'none';
        if (pointManagerHeader) {
            pointManagerHeader.style.display = panelKey === 'shells' && houseRobberyUiState.pointManagerOpen ? 'flex' : 'none';
        }
    }

    function restoreHouseRobberyPage(panelKey = 'shells') {
        if (typeof rcCloseAllHomeSubPages === 'function') rcCloseAllHomeSubPages('house');

        const overlay = document.getElementById('overlay');
        if (overlay) overlay.style.display = 'flex';

        if (typeof primaryContainer !== 'undefined' && primaryContainer) {
            primaryContainer.style.display = 'block';
        }

        const pageWrap = document.getElementById('houseRobberyMainPageContainer');
        const page = document.getElementById('houseRobberyMainPage');
        const home = document.getElementById('mainRobberySettingsPage');
        const shellPanel = document.getElementById('houseShellCreatorPanel');
        const locationPanel = document.getElementById('houseLocationCreatorPanel');
        const alertPanel = document.getElementById('houseGlobalAlertPanel');
        const globalSettingsPanel = document.getElementById('houseGlobalSettingsPanel');
        const pointManagerHeader = document.getElementById('housePointManagerHeader');

        if (pageWrap) pageWrap.style.display = 'block';
        if (page) page.style.display = 'block';
        if (home) home.style.display = 'none';

        houseRobberyUiState.activePanel = panelKey;
        document.getElementById('houseShellCreatorTab')?.classList.toggle('active', panelKey === 'shells');
        document.getElementById('houseLocationCreatorTab')?.classList.toggle('active', panelKey === 'locations');
        document.getElementById('houseGlobalAlertTab')?.classList.toggle('active', panelKey === 'alerts');
        document.getElementById('houseGlobalSettingsTab')?.classList.toggle('active', panelKey === 'global-settings');
        if (shellPanel) shellPanel.style.display = panelKey === 'shells' ? 'block' : 'none';
        if (locationPanel) locationPanel.style.display = panelKey === 'locations' ? 'block' : 'none';
        if (alertPanel) alertPanel.style.display = panelKey === 'alerts' ? 'block' : 'none';
        if (globalSettingsPanel) globalSettingsPanel.style.display = panelKey === 'global-settings' ? 'block' : 'none';
        if (pointManagerHeader) pointManagerHeader.style.display = 'none';

        if (typeof rcSetView === 'function') rcSetView('house');
    }

    function hideHouseRobberyPageForPlacement() {
        const overlay = document.getElementById('overlay');
        const pageWrap = document.getElementById('houseRobberyMainPageContainer');
        const page = document.getElementById('houseRobberyMainPage');

        if (overlay) overlay.style.display = 'none';
        if (typeof primaryContainer !== 'undefined' && primaryContainer) {
            primaryContainer.style.display = 'none';
        }
        if (pageWrap) pageWrap.style.display = 'none';
        if (page) page.style.display = 'none';
    }

    async function setHousePlacement(targetKey) {
        if (targetKey !== 'entry') return;
        saveHouseLocationEditorToState();
        const location = getSelectedLocation();
        if (!location) return;
        try {
            const response = await fetch(`https://${GetParentResourceName()}/PlaceHouseLocationPoint`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    prompt: '~INPUT_CONTEXT~ Confirm entry position  |  ~INPUT_VEH_DUCK~ Cancel',
                    useClone: true,
                }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('locations');
            if (!result?.success || !result.location) return;
            location.entry = {
                coords: result.location.coords,
                heading: result.location.heading,
            };
            delete location.exit;
            renderLocationEditor();
        } catch (error) {
            console.error('Failed to set house placement:', error);
        }
    }

    async function placeHouseMissionNpc(options = {}) {
        saveHouseGlobalSettingsEditorToState();
        const settings = normalizeHouseAlertSettings(houseRobberyData?.settings || {});
        try {
            hideHouseRobberyPageForPlacement();
            const response = await fetch(`https://${GetParentResourceName()}/placeHouseMissionNpc`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    heading: settings.missionNpc?.heading || 0,
                    pedModel: settings.missionNpc?.model || HOUSE_MISSION_NPC_MODEL,
                }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('global-settings');

            if (!result?.FinalInfo?.coords) {
                if (options.triggeredByCheckbox) {
                    houseRobberyData.settings = normalizeHouseAlertSettings({
                        ...settings,
                        missionNpcEnabled: false,
                        missionNpc: settings.missionNpc,
                    });
                    renderHouseGlobalSettingsEditor();
                }
                return;
            }

            houseRobberyData.settings = normalizeHouseAlertSettings({
                ...settings,
                missionNpcEnabled: true,
                missionNpc: {
                    ...settings.missionNpc,
                    coords: result.FinalInfo.coords,
                    heading: result.FinalInfo.heading,
                    model: settings.missionNpc?.model || HOUSE_MISSION_NPC_MODEL,
                    interactionLabel: settings.missionNpc?.interactionLabel || HOUSE_MISSION_INTERACTION_LABEL,
                },
            });
            renderHouseGlobalSettingsEditor();
            if (typeof rcNotify === 'function') {
                rcNotify('Placed the house robbery mission NPC.', 'success');
            }
        } catch (error) {
            restoreHouseRobberyPage('global-settings');
            console.error('Failed to place house mission NPC:', error);
        }
    }

    function teleportHouseMissionNpc() {
        const settings = normalizeHouseAlertSettings(houseRobberyData?.settings || {});
        if (!hasHousePlacementCoords(settings.missionNpc)) {
            if (typeof rcNotify === 'function') {
                rcNotify('Place the house robbery mission NPC first.', 'error');
            }
            return;
        }

        $.post(`https://${GetParentResourceName()}/TeleportToPosition`, JSON.stringify({
            x: Number(settings.missionNpc.coords.x || 0),
            y: Number(settings.missionNpc.coords.y || 0),
            z: Number(settings.missionNpc.coords.z || 0),
        }));
    }

    async function createHouseLocationFromPlacement(templateLocation = null) {
        saveHouseLocationEditorToState();
        const duplicatedTemplate = cloneHouseLocationTemplate(templateLocation);
        try {
            const response = await fetch(`https://${GetParentResourceName()}/PlaceHouseLocationPoint`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    prompt: duplicatedTemplate
                        ? '~INPUT_CONTEXT~ Confirm duplicated house location  |  ~INPUT_VEH_DUCK~ Cancel'
                        : '~INPUT_CONTEXT~ Confirm house location  |  ~INPUT_VEH_DUCK~ Cancel',
                    useClone: true,
                }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('locations');
            if (!result?.success || !result.location) return;
            houseRobberyData.locations.push(buildPlacedHouseLocation(result, duplicatedTemplate));
            houseRobberyUiState.selectedLocationIndex = houseRobberyData.locations.length - 1;
            renderLocationList();
            renderLocationEditor();
            if (duplicatedTemplate && typeof rcNotify === 'function') {
                rcNotify('Placed duplicated house robbery location with copied settings.', 'success');
            }
        } catch (error) {
            console.error('Failed to create house robbery location:', error);
        }
    }

    async function previewShellPreset(options = {}) {
        const replaceSelected = options?.replaceSelected === true;
        const singlePlacement = options?.singlePlacement === true || replaceSelected;
        saveHouseShellEditorToState();
        const wasPointManagerOpen = !!houseRobberyUiState.pointManagerOpen;
        const previousPointIndex = houseRobberyUiState.selectedPointIndex;
        housePointPreviewState = {
            active: false,
            shellKey: '',
            presetKey: '',
            pointIndex: -1,
        };
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        if (!shell || !preset) return;
        const forcedReplacementIndex = replaceSelected ? getSelectedHouseLootPlacementIndex(preset) : -1;
        const pendingPlacementIndex = replaceSelected ? forcedReplacementIndex : getPendingHouseLootPlacementIndex(preset);
        try {
            const response = await fetch(`https://${GetParentResourceName()}/BeginHouseShellPlacement`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ shell, preset, singlePlacement }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('shells');
            houseRobberyUiState.pointManagerOpen = wasPointManagerOpen;
            preset.lootPoints = Array.isArray(preset.lootPoints) ? preset.lootPoints : [];
            const newPoints = Array.isArray(result.points)
                ? result.points
                : (result.point ? [result.point] : []);

            if (result?.success && newPoints.length) {
                let nextReplacementIndex = pendingPlacementIndex;
                let usedForcedReplacement = false;
                let selectedPlacedIndex = -1;
                newPoints.forEach((point) => {
                    const replacementIndex = replaceSelected
                        ? (!usedForcedReplacement ? nextReplacementIndex : -1)
                        : (nextReplacementIndex >= 0 ? findNextPendingHouseLootPlacementIndex(preset, nextReplacementIndex) : -1);
                    if (replacementIndex >= 0 && preset.lootPoints[replacementIndex]) {
                        applyHouseLootPointPlacement(preset.lootPoints[replacementIndex], point, replacementIndex);
                        selectedPlacedIndex = replacementIndex;
                        if (replaceSelected) {
                            usedForcedReplacement = true;
                            nextReplacementIndex = -1;
                        } else {
                            nextReplacementIndex = replacementIndex + 1;
                        }
                        return;
                    }

                    const normalizedPoint = normalizePoint(point, preset.lootPoints.length);
                    normalizedPoint.isPlaced = true;
                    normalizedPoint.placed = true;
                    preset.lootPoints.push(normalizedPoint);
                    selectedPlacedIndex = preset.lootPoints.length - 1;
                });
                ensureUniqueHouseLootPointIds(preset.lootPoints);
                houseRobberyUiState.selectedPointIndex = Math.max(0, selectedPlacedIndex);
            } else {
                const pointCount = Array.isArray(preset.lootPoints) ? preset.lootPoints.length : 0;
                houseRobberyUiState.selectedPointIndex = pointCount > 0
                    ? Math.min(previousPointIndex, pointCount - 1)
                    : 0;
            }

            renderShellList();
            renderShellEditor();
        } catch (error) {
            console.error('Failed to preview shell preset:', error);
        }
    }

    async function previewHouseSecurityPlacement() {
        saveHouseShellEditorToState();
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        if (!shell || !preset) return;

        try {
            const response = await fetch(`https://${GetParentResourceName()}/BeginHouseSecurityPlacement`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ shell, preset, keepInside: true }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('shells');
            if (!result?.success || !result.securitySystem) return;

            preset.securitySystem = applyHouseSecurityPlacement(preset.securitySystem, result.securitySystem);
            houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
            renderShellList();
            renderShellEditor();
            focusHousePointPreview(houseRobberyUiState.selectedPointIndex);
        } catch (error) {
            console.error('Failed to place house security system:', error);
        }
    }

    async function previewHouseHomeOwnerPlacement() {
        saveHouseShellEditorToState();
        const shell = getSelectedShell();
        const preset = getSelectedPreset();
        if (!shell || !preset) return;

        try {
            const response = await fetch(`https://${GetParentResourceName()}/BeginHouseHomeOwnerPlacement`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ shell, preset, keepInside: true }),
            });
            const result = await response.json();
            restoreHouseRobberyPage('shells');
            if (!result?.success || !result.homeOwner) return;

            preset.homeOwner = normalizeHouseHomeOwner(result.homeOwner);
            houseRobberyUiState.selectedPointIndex = HOUSE_HOME_OWNER_TAB_INDEX;
            renderShellList();
            renderShellEditor();
            focusHousePointPreview(houseRobberyUiState.selectedPointIndex);
        } catch (error) {
            console.error('Failed to place house home owner:', error);
        }
    }

    function removeSelectedHousePreset() {
        exitHousePointPreview(true);
        const shell = getSelectedShell();
        if (!shell?.presets?.length) return;
        const removed = getSelectedPreset();
        shell.presets.splice(houseRobberyUiState.selectedPresetIndex, 1);
        houseRobberyData.locations.forEach((location) => {
            if (location.presetSelections?.[shell.id]) {
                location.presetSelections[shell.id] = location.presetSelections[shell.id].filter((presetId) => presetId !== removed?.id);
            }
        });
        houseRobberyUiState.selectedPresetIndex = Math.max(0, houseRobberyUiState.selectedPresetIndex - 1);
        houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
        houseRobberyUiState.pointManagerOpen = false;
        renderShellEditor();
        renderLocationEditor();
    }

    function bindHouseButtons() {
        const bind = (id, handler) => {
            const element = document.getElementById(id);
            if (!element || element.dataset.rcBound === '1') return;
            element.dataset.rcBound = '1';
            element.addEventListener('click', handler);
        };

        bind('houseShellCreatorTab', () => switchHousePanel('shells'));
        bind('houseLocationCreatorTab', () => switchHousePanel('locations'));
        bind('houseGlobalAlertTab', () => switchHousePanel('alerts'));
        bind('houseGlobalSettingsTab', () => switchHousePanel('global-settings'));
        bind('addHouseShellButton', () => {
            saveHouseShellEditorToState();
            const label = document.getElementById('houseShellProfileName')?.value?.trim() || `Shell Profile ${houseRobberyData.shells.length + 1}`;
            openHouseShellPicker(label);
        });
        bind('cancelHouseShellModalButton', () => {
            const panel = document.getElementById('houseShellPickerPanel');
            if (panel) delete panel.dataset.pendingProfileLabel;
            if (typeof CloseFeatureModal === 'function') {
                CloseFeatureModal({ restorePrevious: false, forceAll: true });
            }
        });
        bind('confirmHouseShellModalButton', () => {
            const panel = document.getElementById('houseShellPickerPanel');
            const model = document.getElementById('houseShellModelSelect')?.value || '';
            const label = panel?.dataset.pendingProfileLabel?.trim() || `Shell Profile ${houseRobberyData.shells.length + 1}`;
            if (!model) {
                if (typeof rcNotify === 'function') {
                    rcNotify('Select a shell before creating the profile.', 'error');
                }
                return;
            }
            createHouseShellProfile(label, model);
            if (panel) delete panel.dataset.pendingProfileLabel;
            if (typeof CloseFeatureModal === 'function') {
                CloseFeatureModal({ restorePrevious: false, forceAll: true });
            }
        });
        bind('removeHouseShellButton', () => {
            exitHousePointPreview(true);
            if (!houseRobberyData.shells.length) return;
            const removed = getSelectedShell();
            houseRobberyData.shells.splice(houseRobberyUiState.selectedShellIndex, 1);
            houseRobberyData.locations.forEach((location) => {
                location.shellIds = (location.shellIds || []).filter((shellId) => shellId !== removed?.id);
                delete location.presetSelections?.[removed?.id];
            });
            houseRobberyUiState.selectedShellIndex = Math.max(0, houseRobberyUiState.selectedShellIndex - 1);
            houseRobberyUiState.selectedPresetIndex = 0;
            houseRobberyUiState.selectedPointIndex = HOUSE_SECURITY_TAB_INDEX;
            houseRobberyUiState.pointManagerOpen = false;
            renderShellList();
            renderShellEditor();
            renderLocationEditor();
        });
        bind('addHousePresetButton', () => {
            saveHouseShellEditorToState();
            openHousePresetCreator();
        });
        bind('pasteHousePresetButton', pasteHousePresetToSelectedShell);
        bind('cancelHousePresetModalButton', () => {
            if (typeof CloseFeatureModal === 'function') {
                CloseFeatureModal({ restorePrevious: false, forceAll: true });
            }
        });
        bind('confirmHousePresetModalButton', () => {
            const shell = getSelectedShell();
            const input = document.getElementById('housePresetCreateName');
            if (!shell || !input) return;
            const label = input.value?.trim() || `Preset ${shell.presets.length + 1}`;
            createHousePreset(label);
            input.value = '';
            if (typeof CloseFeatureModal === 'function') {
                CloseFeatureModal({ restorePrevious: false, forceAll: true });
            }
        });
        bind('housePointManagerAddPointButton', () => previewShellPreset({ singlePlacement: true }));
        bind('housePointManagerPlaceButton', () => previewShellPreset({ singlePlacement: true }));
        bind('housePointManagerSecurityButton', previewHouseSecurityPlacement);
        bind('housePointManagerPlaceSecurityButton', previewHouseSecurityPlacement);
        bind('housePointManagerHomeOwnerButton', previewHouseHomeOwnerPlacement);
        bind('housePointManagerPlaceHomeOwnerButton', previewHouseHomeOwnerPlacement);
        bind('closeHousePointManagerButton', closeHousePointManager);
        bind('addHouseLocationButton', createHouseLocationFromPlacement);
        bind('removeHouseLocationButton', () => {
            if (!houseRobberyData.locations.length) return;
            houseRobberyData.locations.splice(houseRobberyUiState.selectedLocationIndex, 1);
            houseRobberyUiState.selectedLocationIndex = Math.max(0, houseRobberyUiState.selectedLocationIndex - 1);
            renderLocationList();
            renderLocationEditor();
        });
        bind('setHouseEntryButton', () => setHousePlacement('entry'));
        bind('openHouseGlobalAlertFromLocationButton', () => switchHousePanel('alerts'));
        bind('addHouseLocationRequiredItemButton', () => addHouseRequiredItemRow('houseLocationRequiredItemOptions'));
        bind('addHouseLocationRewardItemButton', () => addHouseRewardItemRow('houseLocationRewardItemOptions'));
        bind('addHouseBatchRequiredItemButton', () => addHouseRequiredItemRow('houseBatchRequiredItemOptions'));
        bind('addHouseBatchRewardItemButton', () => addHouseRewardItemRow('houseBatchRewardItemOptions'));
        bind('addHousePointRequiredItemButton', () => addHouseRequiredItemRow('housePointRequiredItemOptions'));
        bind('addHousePointRewardItemButton', () => addHouseRewardItemRow('housePointRewardItemOptions'));
        bind('copyHousePointRewardItemsButton', copyHousePointRewardItems);
        bind('pasteHousePointRewardItemsButton', pasteHousePointRewardItems);
        bind('addHousePointWeaponButton', () => addHouseWeaponRow('housePointWeaponOptions'));
        bind('teleportHouseMissionNpcButton', teleportHouseMissionNpc);
        bind('replaceHouseMissionNpcButton', () => placeHouseMissionNpc({ triggeredByReplaceButton: true }));
        bind('houseBulkApplySelectAllButton', () => {
            document.querySelectorAll('#houseBulkApplyLocationList .house-bulk-apply-checkbox').forEach((input) => {
                input.checked = true;
            });
        });
        bind('houseBulkApplyClearButton', () => {
            document.querySelectorAll('#houseBulkApplyLocationList .house-bulk-apply-checkbox').forEach((input) => {
                input.checked = false;
            });
        });
        bind('cancelHouseBulkApplyButton', () => {
            if (typeof CloseFeatureModal === 'function') {
                CloseFeatureModal({ restorePrevious: false, forceAll: true });
            }
        });
        bind('confirmHouseBulkApplyButton', applyHouseBatchSettingToLocations);
        bind('saveHouseRobberyDataButton', SaveHouseRobberyData);
        bind('loadHousePresetButton', () => openHousePresetModal('load'));
        bind('saveHousePresetButton', () => openHousePresetModal('save'));

        document.querySelectorAll('.house-bulk-apply-trigger[data-house-bulk-setting]').forEach((button) => {
            if (button.dataset.rcBound === '1') return;
            button.dataset.rcBound = '1';
            button.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                openHouseBulkApplyModal(button.dataset.houseBulkSetting || '');
            });
        });

        const missionCheckbox = document.getElementById('houseMissionNpcCheckbox');
        if (missionCheckbox && missionCheckbox.dataset.rcBound !== '1') {
            missionCheckbox.dataset.rcBound = '1';
            missionCheckbox.addEventListener('change', async () => {
                const currentSettings = normalizeHouseAlertSettings(houseRobberyData?.settings || {});
                if (missionCheckbox.checked && !hasHousePlacementCoords(currentSettings.missionNpc)) {
                    await placeHouseMissionNpc({ triggeredByCheckbox: true });
                    return;
                }
                saveHouseGlobalSettingsEditorToState();
                renderHouseGlobalSettingsEditor();
            });
        }

        const pointPanel = document.getElementById('housePointEditor');
        if (pointPanel && pointPanel.dataset.rcBound !== '1') {
            pointPanel.dataset.rcBound = '1';
            pointPanel.addEventListener('input', () => {
                saveHousePointSettingsFromPanel();
                const title = document.getElementById('housePointEditorTitle');
                const point = getSelectedPoint();
                if (title && point) title.textContent = getHousePointDisplayName(point, houseRobberyUiState.selectedPointIndex).toUpperCase();
                renderPresetList(getSelectedShell());
                renderPointManagerList();
            });
            pointPanel.addEventListener('change', () => {
                saveHousePointSettingsFromPanel();
                const title = document.getElementById('housePointEditorTitle');
                const point = getSelectedPoint();
                if (title && point) title.textContent = getHousePointDisplayName(point, houseRobberyUiState.selectedPointIndex).toUpperCase();
                renderPresetList(getSelectedShell());
                renderPointManagerList();
            });
        }

        const presetCreateInput = document.getElementById('housePresetCreateName');
        if (presetCreateInput && presetCreateInput.dataset.rcBound !== '1') {
            presetCreateInput.dataset.rcBound = '1';
            presetCreateInput.addEventListener('keydown', (event) => {
                if (event.key !== 'Enter') return;
                event.preventDefault();
                document.getElementById('confirmHousePresetModalButton')?.click();
            });
        }
    }

    window.LoadHouseRobberyData = function LoadHouseRobberyData(data) {
        try {
            houseRobberyData = normalizeHouseRobberyData(data);
        } catch (error) {
            console.error('Failed to normalize house robbery data:', error);
            houseRobberyData = { shells: [], locations: [] };
        }
        houseRobberyData.settings = normalizeHouseAlertSettings(houseRobberyData.settings || {});
        syncHouseGlobalSettingsToLocations();

        clampHouseSelections();
        populateShellModelSelect('houseShellModelSelect');
        populateHouseAlertSelects();
        bindHouseButtons();
        renderShellList();
        renderShellEditor();
        renderLocationList();
        renderLocationEditor();
        renderHouseAlertEditor();
        renderHouseGlobalSettingsEditor();
        switchHousePanel(houseRobberyUiState.activePanel || 'shells');
        refreshHouseRobberySelects(document.getElementById('houseRobberyMainPageContainer') || document);
    };

    window.showHouseRobberyMenu = function showHouseRobberyMenu() {
        saveHouseShellEditorToState();
        saveHouseLocationEditorToState();
        if (typeof rcCloseAllHomeSubPages === 'function') rcCloseAllHomeSubPages('house');

        if (primaryContainer) primaryContainer.style.display = 'block';
        const pageWrap = document.getElementById('houseRobberyMainPageContainer');
        const page = document.getElementById('houseRobberyMainPage');
        if (pageWrap) pageWrap.style.display = 'block';
        if (page) page.style.display = 'block';

        const home = document.getElementById('mainRobberySettingsPage');
        if (home) home.style.display = 'none';

        window.LoadHouseRobberyData(houseRobberyData);
        if (typeof rcSetView === 'function') rcSetView('house');
    };

    window.SaveHouseRobberyData = function SaveHouseRobberyData() {
        const pointEditorSnapshot = prepareHouseRobberyDataForSave();
        fetch(`https://${GetParentResourceName()}/SaveHouseRobberyData`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(houseRobberyData),
        })
            .then((response) => response.json())
            .then((data) => {
                if (data?.success) {
                    const nextData = normalizeHouseRobberyData(data.data || houseRobberyData);
                    applyHousePointEditorSnapshotToData(nextData, pointEditorSnapshot);
                    if (typeof window.LoadHouseRobberyData === 'function') {
                        window.LoadHouseRobberyData(nextData);
                    } else {
                        houseRobberyData = nextData;
                    }
                }
                console.log('House robbery data saved:', data);
            })
            .catch((error) => console.error('Error saving house robbery data:', error));
    };

    window.addEventListener('rc:viewchange', (event) => {
        const nextView = event?.detail?.view;
        if (nextView && nextView !== 'house') {
            houseRobberyUiState.pointManagerOpen = false;
            exitHousePointPreview(true);
        }
    });
})();
