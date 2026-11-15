// ═══════════════════════════════════════════════════════════════
// BODHIX SPORT HUB - EQUIPMENT SYSTEM (NUI)
// Equipment selection UI and interaction handler
// ═══════════════════════════════════════════════════════════════

// Equipment state
const EquipmentState = {
    isOpen: false,
    currentStore: null,
    currentSport: null,
    currentCategory: null,
    ownedEquipment: [],
    prices: {},
    selectedModel: null,
    // Tebex integration
    tebexConfig: {
        storeUrl: "https://bodhix.tebex.io",
        packages: {}
    },
    ownedPackages: [], // List of package IDs the player owns
    // Preview loading state - prevents fast-clicking overlap issues
    isPreviewLoading: false,
    pendingPreview: null, // Queue next preview if one is in progress
    previewTimeout: null  // Safety timeout to prevent stuck states
};

// Category folder mapping for equipment images
const CategoryFolderMap = {
    helmet: "ht",
    forearms: "fr",
    shinguards: "sh"
};

// ═══════════════════════════════════════════════════════════════
// 🔊 SOUND FUNCTIONS
// ═══════════════════════════════════════════════════════════════

// Create hover sound element
const equipmentHoverSound = new Audio('sounds/select.MP3');
equipmentHoverSound.volume = 0.3;

/**
 * Play hover sound effect
 */
function playEquipmentHoverSound() {
    equipmentHoverSound.currentTime = 0;
    equipmentHoverSound.play().catch(e => console.log("Sound play prevented:", e));
}

/**
 * Add hover sound to equipment cards
 */
function addEquipmentHoverSounds() {
    const cards = document.querySelectorAll('.equipment-sport-card, .equipment-category-card, .equipment-model-card');
    cards.forEach(card => {
        // Remove existing listener to prevent duplicates
        card.removeEventListener('mouseenter', playEquipmentHoverSound);
        // Add new listener
        card.addEventListener('mouseenter', playEquipmentHoverSound);
    });
}

// ═══════════════════════════════════════════════════════════════
// 🎨 UI FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/**
 * Open equipment menu and show sport selection
 */
function openEquipmentMenu(data) {
    console.log("Opening equipment menu", data);

    EquipmentState.isOpen = true;
    EquipmentState.currentStore = data.store;

    // Store Tebex config if provided
    if (data.tebexConfig) {
        EquipmentState.tebexConfig = data.tebexConfig;
        console.log("Tebex config loaded:", EquipmentState.tebexConfig);
    }

    // Store owned packages if provided
    if (data.ownedPackages) {
        EquipmentState.ownedPackages = data.ownedPackages;
        console.log("Owned packages loaded:", EquipmentState.ownedPackages);
    }

    // Hide main menu
    document.getElementById("container").style.display = "none";

    // Show equipment container with smooth animation
    const equipmentContainer = document.getElementById("equipmentContainer");
    if (equipmentContainer) {
        equipmentContainer.style.display = "block";

        // Trigger animation after a small delay
        setTimeout(() => {
            equipmentContainer.classList.add("visible");
        }, 10);

        // Reset to sport selection
        showPage("equipmentSportSelection");
        showBackButton(); // Show back button to return to main menu

        // Show sport selection
        showSportSelection(data.sports);
    }
}

/**
 * Show a specific page (hide others)
 */
function showPage(pageId) {
    const pages = document.querySelectorAll(".equipment-page");
    pages.forEach(page => page.classList.remove("active"));

    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        targetPage.classList.add("active");
    }

    // Reset scroll position on the model grid when switching pages
    const modelGrid = document.getElementById("equipmentModelGrid");
    if (modelGrid) {
        modelGrid.scrollTop = 0;
    }
}

/**
 * Show/hide back button
 */
function showBackButton() {
    const backBtn = document.querySelector(".equipment-back-btn");
    if (backBtn) {
        backBtn.style.display = "flex";
    }
}

function hideBackButton() {
    const backBtn = document.querySelector(".equipment-back-btn");
    if (backBtn) {
        backBtn.style.display = "none";
    }
}

/**
 * Close equipment menu
 */
function closeEquipmentMenu() {
    console.log("Closing equipment menu");

    // Clear any selected model and delete preview
    if (EquipmentState.selectedModel) {
        fetch(`https://${GetParentResourceName()}/equipment:clearPreview`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        })
        .catch(err => console.error("Error clearing preview:", err));
    }

    // Notify client that equipment menu is now hidden (reset isEquipmentUIOpen flag)
    fetch(`https://${GetParentResourceName()}/equipment:menuHidden`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
    })
    .catch(err => console.error("Error notifying menu hidden:", err));

    // IMMEDIATELY clear all page content to prevent overlay issues
    const modelGrid = document.getElementById("equipmentModelGrid");
    if (modelGrid) {
        modelGrid.innerHTML = "";
    }
    const categoryGrid = document.getElementById("equipmentCategoryGrid");
    if (categoryGrid) {
        categoryGrid.innerHTML = "";
    }
    const sportGrid = document.getElementById("equipmentSportGrid");
    if (sportGrid) {
        sportGrid.innerHTML = "";
    }
    const actionButtonsContainer = document.querySelector(".equipment-action-buttons");
    if (actionButtonsContainer) {
        actionButtonsContainer.innerHTML = "";
    }

    // Reset all pages to inactive state
    const pages = document.querySelectorAll(".equipment-page");
    pages.forEach(page => page.classList.remove("active"));

    EquipmentState.isOpen = false;
    EquipmentState.currentStore = null;
    EquipmentState.currentSport = null;
    EquipmentState.currentCategory = null;
    EquipmentState.ownedEquipment = [];
    EquipmentState.prices = {};
    EquipmentState.selectedModel = null;
    // Reset preview loading state and clear timeout
    EquipmentState.isPreviewLoading = false;
    EquipmentState.pendingPreview = null;
    if (EquipmentState.previewTimeout) {
        clearTimeout(EquipmentState.previewTimeout);
        EquipmentState.previewTimeout = null;
    }

    // Hide equipment container with fade out
    const equipmentContainer = document.getElementById("equipmentContainer");
    if (equipmentContainer) {
        equipmentContainer.classList.remove("visible");
        setTimeout(() => {
            equipmentContainer.style.display = "none";
        }, 300);
    }

    // Show main menu again (NUI focus remains)
    setTimeout(() => {
        document.getElementById("container").style.display = "flex";
    }, 300);
}

/**
 * Force close equipment menu (used when store closes - does NOT show main menu)
 */
function forceCloseEquipment() {
    console.log("Force closing equipment menu (store closed)");

    // Clear any selected model and delete preview
    if (EquipmentState.selectedModel) {
        fetch(`https://${GetParentResourceName()}/equipment:clearPreview`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        })
        .catch(err => console.error("Error clearing preview:", err));
    }

    // IMMEDIATELY clear all page content to prevent overlay issues
    const modelGrid = document.getElementById("equipmentModelGrid");
    if (modelGrid) {
        modelGrid.innerHTML = "";
    }
    const categoryGrid = document.getElementById("equipmentCategoryGrid");
    if (categoryGrid) {
        categoryGrid.innerHTML = "";
    }
    const sportGrid = document.getElementById("equipmentSportGrid");
    if (sportGrid) {
        sportGrid.innerHTML = "";
    }
    const actionButtonsContainer = document.querySelector(".equipment-action-buttons");
    if (actionButtonsContainer) {
        actionButtonsContainer.innerHTML = "";
    }

    // Reset all pages to inactive state
    const pages = document.querySelectorAll(".equipment-page");
    pages.forEach(page => page.classList.remove("active"));

    // Reset state
    EquipmentState.isOpen = false;
    EquipmentState.currentStore = null;
    EquipmentState.currentSport = null;
    EquipmentState.currentCategory = null;
    EquipmentState.ownedEquipment = [];
    EquipmentState.prices = {};
    EquipmentState.selectedModel = null;
    // Reset preview loading state and clear timeout
    EquipmentState.isPreviewLoading = false;
    EquipmentState.pendingPreview = null;
    if (EquipmentState.previewTimeout) {
        clearTimeout(EquipmentState.previewTimeout);
        EquipmentState.previewTimeout = null;
    }

    // Hide equipment container immediately (no animation for force close)
    const equipmentContainer = document.getElementById("equipmentContainer");
    if (equipmentContainer) {
        equipmentContainer.classList.remove("visible");
        equipmentContainer.style.display = "none";
    }

    // DO NOT show main menu - let hideMenu handle full cleanup
}

/**
 * Show sport selection page
 */
function showSportSelection(sports) {
    console.log("Showing sport selection", sports);

    showPage("equipmentSportSelection");
    showBackButton(); // Show back button to return to main menu

    // Populate sport grid
    const sportGrid = document.getElementById("equipmentSportGrid");
    if (sportGrid) {
        sportGrid.innerHTML = "";

        sports.forEach(sport => {
            const sportCard = document.createElement("div");
            sportCard.className = "equipment-sport-card";

            // Local-first, like the gear grid. This used to load ONLY from the CDN,
            // which doesn't have slopstyle.png — so slopstyle had an icon in the gear
            // section (local) but a broken one here. Every icon ships in
            // nui/images/icons/, so read it from there. `sport.image` may be a bare
            // filename, a relative path or a full URL, so reduce it to the last
            // segment either way; CDN stays only as a fallback if the local file is
            // somehow missing.
            const iconFile = String(sport.image || "").split('/').pop();

            const img = document.createElement("img");
            img.alt = sport.name;
            img.onerror = function() {
                if (!this.dataset.tried) {
                    this.dataset.tried = '1';
                    this.src = 'https://bdx-sport-hub.pages.dev/images/icons/' + iconFile;
                }
            };
            img.src = 'images/icons/' + iconFile;

            const label = document.createElement("span");
            label.innerText = sport.name;

            sportCard.appendChild(img);
            sportCard.appendChild(label);
            sportCard.onclick = () => selectSport(sport.id);
            sportGrid.appendChild(sportCard);
        });

        // Add hover sounds to newly created cards
        addEquipmentHoverSounds();
    }
}

/**
 * Show category selection page
 */
function showCategorySelection(categories) {
    console.log("Showing category selection", categories);

    showPage("equipmentCategorySelection");
    showBackButton();

    // Populate category grid
    const categoryGrid = document.getElementById("equipmentCategoryGrid");
    if (categoryGrid) {
        categoryGrid.innerHTML = "";

        categories.forEach(category => {
            const categoryCard = document.createElement("div");
            categoryCard.className = "equipment-category-card";
            categoryCard.innerHTML = `
                <div>
                    <h3>${category.name}</h3>
                    <p>${category.count} designs available</p>
                </div>
            `;
            categoryCard.onclick = () => selectEquipmentCategory(category.id);
            categoryGrid.appendChild(categoryCard);
        });

        // Add hover sounds to newly created cards
        addEquipmentHoverSounds();
    }
}

/**
 * Show model selection page
 */
function showModelSelection(models) {
    console.log("Showing model selection", models);

    showPage("equipmentModelSelection");
    showBackButton();

    // Populate model grid
    const modelGrid = document.getElementById("equipmentModelGrid");
    const actionButtonsContainer = document.querySelector(".equipment-action-buttons");

    if (modelGrid) {
        modelGrid.innerHTML = "";

        models.forEach(modelData => {
            const modelCard = document.createElement("div");
            modelCard.className = "equipment-model-card";
            modelCard.dataset.model = modelData.model;
            modelCard.dataset.displayName = modelData.displayName;
            modelCard.dataset.exclusive = modelData.exclusive || false;
            modelCard.dataset.package = modelData.package || "";

            // Check if owned/equipped
            const isOwned = isEquipmentOwned(modelData.model);
            const isEquipped = isEquipmentEquipped(modelData.model);

            // Check if locked (exclusive but player doesn't own package)
            // IMPORTANT: Lock is based ONLY on package ownership, NOT on whether item is equipped/owned
            const isExclusive = modelData.exclusive === true || modelData.exclusive === "true";
            const packageId = modelData.package || "";
            const hasPackage = playerOwnsPackage(packageId);
            const isLocked = isExclusive && !hasPackage;
            const packageInfo = getPackageInfo(packageId);

            // Debug logging for exclusive items
            if (isExclusive) {
                console.log(`[Exclusive Debug] Model: ${modelData.model}`);
                console.log(`  - exclusive: ${modelData.exclusive} (type: ${typeof modelData.exclusive})`);
                console.log(`  - package: "${packageId}"`);
                console.log(`  - isOwned: ${isOwned}`);
                console.log(`  - hasPackage: ${hasPackage}`);
                console.log(`  - isLocked: ${isLocked}`);
            }

            // Add state classes
            if (isLocked) {
                modelCard.classList.add("locked");
            } else if (isEquipped) {
                modelCard.classList.add("equipped");
            } else if (isOwned) {
                modelCard.classList.add("owned");
            }

            // Add exclusive class if needed (for VIP badge)
            if (isExclusive) {
                modelCard.classList.add("exclusive");
            }

            // Card content with lock overlay for locked items
            const folderName = CategoryFolderMap[EquipmentState.currentCategory] || EquipmentState.currentCategory;
            // Strip _lowpoly suffix from model name for image lookup
            const imageModelName = modelData.model.replace(/_lowpoly$/i, '');
            const lockOverlay = isLocked ? `
                <div class="equipment-lock-overlay">
                    <i class="fas fa-lock"></i>
                    <span class="lock-text">EXCLUSIVE</span>
                    <button class="unlock-btn" onclick="event.stopPropagation(); openTebexPackage('${packageId}');">
                        <i class="fas fa-shopping-cart"></i> Unlock
                    </button>
                    <button class="preview-btn" onclick="event.stopPropagation(); selectModel('${modelData.model}');">
                        <i class="fas fa-eye"></i> Preview
                    </button>
                </div>
            ` : '';

            // Build image path - handle model names with or without prefixes
            const imagePath = `https://bdx-sport-hub.pages.dev/images/Equipment/${folderName}/${imageModelName}.png`;

            modelCard.innerHTML = `
                <div class="equipment-model-preview">
                    <img src="${imagePath}"
                         alt="${modelData.displayName}"
                         onerror="console.warn('Equipment image not found:', '${imagePath}'); this.style.display='none'; this.parentElement.classList.add('no-image');">
                    <span class="equipment-model-name">${modelData.displayName}</span>
                    ${isExclusive && !isLocked ? '<span class="vip-unlocked-badge"><i class="fas fa-crown"></i> EXCLUSIVE</span>' : ''}
                    ${lockOverlay}
                </div>
            `;

            // Click handler for selection - only allow direct click for unlocked items
            // Locked items must use the Preview button instead
            if (!isLocked) {
                modelCard.onclick = () => selectModel(modelData.model);
            } else {
                modelCard.style.cursor = "default";
            }

            modelGrid.appendChild(modelCard);
        });
    }

    // Check if there's an equipped item for this category - auto-select it
    const equippedModel = EquipmentState.ownedEquipment.find(item =>
        item.sport === EquipmentState.currentSport &&
        item.category === EquipmentState.currentCategory &&
        (item.is_equipped === 1 || item.is_equipped === true)
    );

    if (equippedModel) {
        // Auto-select the equipped model
        EquipmentState.selectedModel = equippedModel.model;

        // Highlight the card
        const allCards = document.querySelectorAll(".equipment-model-card");
        allCards.forEach(card => {
            if (card.dataset.model === equippedModel.model) {
                card.classList.add("selected");
            }
        });

        // Show preview of equipped item
        fetch(`https://${GetParentResourceName()}/equipment:preview`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                model: equippedModel.model,
                sport: EquipmentState.currentSport,
                category: EquipmentState.currentCategory
            })
        })
        .catch(err => console.error("Error showing equipped preview:", err));

        console.log("Auto-selected equipped model:", equippedModel.model);
    } else {
        // No equipped item - clear selection
        EquipmentState.selectedModel = null;
    }

    updateActionButtons();

    // Add hover sounds to newly created cards
    addEquipmentHoverSounds();
}

/**
 * Check if equipment is owned
 */
function isEquipmentOwned(model) {
    return EquipmentState.ownedEquipment.some(item =>
        item.sport === EquipmentState.currentSport &&
        item.category === EquipmentState.currentCategory &&
        item.model === model
    );
}

/**
 * Check if equipment is equipped
 */
function isEquipmentEquipped(model) {
    return EquipmentState.ownedEquipment.some(item =>
        item.sport === EquipmentState.currentSport &&
        item.category === EquipmentState.currentCategory &&
        item.model === model &&
        (item.is_equipped === 1 || item.is_equipped === true)
    );
}

/**
 * Check if player owns a Tebex package
 */
function playerOwnsPackage(packageId) {
    // If no package required (empty/null), don't treat as "owned" - let other checks handle it
    if (!packageId || packageId === "" || packageId === "0") return false;
    return EquipmentState.ownedPackages.includes(packageId) ||
           EquipmentState.ownedPackages.includes(String(packageId)) ||
           EquipmentState.ownedPackages.includes(Number(packageId));
}

/**
 * Get Tebex package info from config
 */
function getPackageInfo(packageId) {
    if (!packageId || packageId === "") return null;
    return EquipmentState.tebexConfig.packages[packageId] ||
           EquipmentState.tebexConfig.packages[String(packageId)] || null;
}

/**
 * Open exclusive package popup (Comic Bubble Style)
 * Shows purchase option and Discord ID redemption
 */
function openTebexPackage(packageId) {
    console.log("openTebexPackage called with packageId:", packageId);
    console.log("Current tebexConfig:", EquipmentState.tebexConfig);
    console.log("Available packages:", EquipmentState.tebexConfig?.packages);

    let packageInfo = getPackageInfo(packageId);
    console.log("getPackageInfo returned:", packageInfo);

    // Hardcoded fallback for known packages (in case tebexConfig isn't loaded)
    if (!packageInfo) {
        const knownPackages = {
            "7139397": {
                name: "Neo Xtreme Pack",
                description: "Unlock exclusive helmets, forearms and shinguards",
                url: "https://bodhix.tebex.io/package/7139397",
                image: "discover/pack-1.jpg"
            }
        };
        packageInfo = knownPackages[packageId] || knownPackages[String(packageId)] || null;
        console.log("Using hardcoded fallback:", packageInfo);
    }

    // Build package info for popup
    const popupInfo = {
        id: packageId,
        name: packageInfo?.name || 'Exclusive Pack',
        description: packageInfo?.description || 'Unlock exclusive content',
        url: packageInfo?.url || `${EquipmentState.tebexConfig?.storeUrl || 'https://bodhix.tebex.io'}/package/${packageId}`,
        image: packageInfo?.image || null  // Use null so showExclusivePopup uses logo fallback
    };

    console.log("Opening exclusive package popup:", popupInfo);

    // Show the beautiful popup instead of directly opening URL
    // The popup is in index.html, so we call the function directly
    if (typeof showExclusivePopup === 'function') {
        showExclusivePopup(popupInfo);
    } else {
        // Fallback if function not found - send message to parent
        window.postMessage({ action: 'showExclusivePopup', packageInfo: popupInfo }, '*');
    }
}

/**
 * Select a model card and update action buttons
 * Includes protection against fast-clicking overlap issues
 */
function selectModel(model) {
    console.log("========================================");
    console.log("selectModel CALLED");
    console.log("  model:", model);
    console.log("  sport:", EquipmentState.currentSport);
    console.log("  category:", EquipmentState.currentCategory);
    console.log("  previous selectedModel:", EquipmentState.selectedModel);
    console.log("  isPreviewLoading:", EquipmentState.isPreviewLoading);
    console.log("========================================");

    // If a preview is already loading, queue this one for later
    if (EquipmentState.isPreviewLoading) {
        console.log("Preview loading in progress - queuing model:", model);
        EquipmentState.pendingPreview = {
            model: model,
            sport: EquipmentState.currentSport,
            category: EquipmentState.currentCategory
        };
        // Still update visual selection immediately for responsiveness
        updateVisualSelection(model);
        return;
    }

    // Set loading state
    EquipmentState.isPreviewLoading = true;
    EquipmentState.pendingPreview = null;

    // Update selected model
    EquipmentState.selectedModel = model;

    // Update visual selection
    updateVisualSelection(model);

    // Update action buttons
    updateActionButtons();

    // Safety timeout - clear loading state after 3 seconds if previewReady never arrives
    // This prevents permanent stuck states due to errors
    const safetyTimeout = setTimeout(() => {
        if (EquipmentState.isPreviewLoading) {
            console.warn("Preview loading timeout - clearing stuck state for model:", model);
            EquipmentState.isPreviewLoading = false;
            processPendingPreview();
        }
    }, 3000);

    // Store timeout ID to cancel if preview completes normally
    EquipmentState.previewTimeout = safetyTimeout;

    // Request preview attachment from client
    fetch(`https://${GetParentResourceName()}/equipment:preview`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            model: model,
            sport: EquipmentState.currentSport,
            category: EquipmentState.currentCategory
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log("Preview request acknowledged:", data);
        // Loading state will be cleared when we receive previewReady message
    })
    .catch(err => {
        console.error("Error requesting preview:", err);
        // Clear safety timeout
        if (EquipmentState.previewTimeout) {
            clearTimeout(EquipmentState.previewTimeout);
            EquipmentState.previewTimeout = null;
        }
        // Clear loading state on error
        EquipmentState.isPreviewLoading = false;
        processPendingPreview();
    });
}

/**
 * Update visual selection of model cards
 */
function updateVisualSelection(model) {
    const allCards = document.querySelectorAll(".equipment-model-card");
    allCards.forEach(card => {
        if (card.dataset.model === model) {
            card.classList.add("selected");
        } else {
            card.classList.remove("selected");
        }
    });
}

/**
 * Process any pending preview request (called when current preview completes)
 */
function processPendingPreview() {
    if (EquipmentState.pendingPreview) {
        const pending = EquipmentState.pendingPreview;
        EquipmentState.pendingPreview = null;
        console.log("Processing pending preview:", pending.model);
        // Only process if we're still on the same category
        if (pending.sport === EquipmentState.currentSport &&
            pending.category === EquipmentState.currentCategory) {
            selectModel(pending.model);
        }
    }
}

/**
 * Called when preview is ready (from Lua callback)
 */
function onPreviewReady(model) {
    console.log("Preview ready for model:", model);

    // Clear safety timeout since preview completed successfully
    if (EquipmentState.previewTimeout) {
        clearTimeout(EquipmentState.previewTimeout);
        EquipmentState.previewTimeout = null;
    }

    EquipmentState.isPreviewLoading = false;

    // Update selected model and buttons if this is the current selection
    if (EquipmentState.selectedModel === model) {
        updateActionButtons();
    }

    // Process any pending preview
    processPendingPreview();
}

/**
 * Update action buttons based on selected model
 */
function updateActionButtons() {
    const actionButtonsContainer = document.querySelector(".equipment-action-buttons");
    if (!actionButtonsContainer) return;

    // Clear existing buttons
    actionButtonsContainer.innerHTML = "";

    // If no model selected, show nothing
    if (!EquipmentState.selectedModel) {
        return;
    }

    const model = EquipmentState.selectedModel;
    const isOwnedInGame = isEquipmentOwned(model);
    const isEquipped = isEquipmentEquipped(model);
    const price = EquipmentState.prices[EquipmentState.currentCategory] || 0;

    // Check if this is a VIP item with package access
    const selectedCard = document.querySelector(`.equipment-model-card[data-model="${model}"]`);
    const isExclusive = selectedCard?.dataset.exclusive === "true";
    const packageId = selectedCard?.dataset.package || "";
    const hasPackageAccess = isExclusive && playerOwnsPackage(packageId);

    // Check if locked (exclusive but no package access)
    const isLocked = isExclusive && !hasPackageAccess;

    // VIP items with package access are treated as "owned" (no in-game purchase needed)
    const isOwned = isOwnedInGame || hasPackageAccess;

    // Create appropriate buttons
    if (isEquipped) {
        // Show unequip button
        const unequipBtn = document.createElement("button");
        unequipBtn.className = "equipment-btn unequip";
        unequipBtn.textContent = "Unequip";
        unequipBtn.onclick = () => unequipModel(model);
        actionButtonsContainer.appendChild(unequipBtn);

    } else if (isLocked) {
        // Show unlock button for exclusive items without package access
        const unlockBtn = document.createElement("button");
        unlockBtn.className = "equipment-btn unlock";
        unlockBtn.innerHTML = '<i class="fas fa-lock" style="margin-right: 6px;"></i> Unlock Exclusive';
        unlockBtn.onclick = () => openTebexPackage(packageId);
        actionButtonsContainer.appendChild(unlockBtn);

    } else if (isOwned) {
        // Show equip button (for both in-game owned AND VIP package access)
        const equipBtn = document.createElement("button");
        equipBtn.className = "equipment-btn equip";
        // Add VIP badge if this is from package access
        if (hasPackageAccess && !isOwnedInGame) {
            equipBtn.innerHTML = '<i class="fas fa-crown" style="margin-right: 6px; color: #ffd700;"></i>Equip';
        } else {
            equipBtn.textContent = "Equip";
        }
        console.log("Creating EQUIP button for model:", model);
        equipBtn.onclick = function(e) {
            console.log("EQUIP BUTTON CLICKED! Model:", model);
            equipModel(model);
        };
        actionButtonsContainer.appendChild(equipBtn);

    } else {
        // Show purchase button
        const purchaseBtn = document.createElement("button");
        purchaseBtn.className = "equipment-btn purchase";
        purchaseBtn.textContent = `Purchase - $${price.toLocaleString()}`;
        purchaseBtn.onclick = () => purchaseModel(model);
        actionButtonsContainer.appendChild(purchaseBtn);
    }
}

/**
 * Update model card states (owned/equipped) without re-rendering entire grid
 */
function updateModelCardStates() {
    const allCards = document.querySelectorAll(".equipment-model-card");

    allCards.forEach(card => {
        const model = card.dataset.model;
        if (!model) return;

        const isOwned = isEquipmentOwned(model);
        const isEquipped = isEquipmentEquipped(model);

        // Remove all state classes
        card.classList.remove("owned", "equipped");

        // Add current state class
        if (isEquipped) {
            card.classList.add("equipped");
        } else if (isOwned) {
            card.classList.add("owned");
        }
    });
}

// ═══════════════════════════════════════════════════════════════
// 🎯 SELECTION HANDLERS
// ═══════════════════════════════════════════════════════════════

/**
 * Handle sport selection
 */
function selectSport(sportId) {
    console.log("Sport selected:", sportId);

    EquipmentState.currentSport = sportId;

    // Request categories from client
    fetch(`https://${GetParentResourceName()}/equipment:sportSelected`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ sport: sportId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showCategorySelection(data.categories);
        } else {
            console.error("Failed to load categories:", data.error);
        }
    })
    .catch(err => console.error("Error selecting sport:", err));
}

/**
 * Handle equipment category selection (renamed to avoid collision with index.html's selectCategory)
 */
function selectEquipmentCategory(categoryId) {
    console.log("Equipment category selected:", categoryId);

    EquipmentState.currentCategory = categoryId;

    // Request models from client
    fetch(`https://${GetParentResourceName()}/equipment:categorySelected`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ category: categoryId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showModelSelection(data.models);
        } else {
            console.error("Failed to load models:", data.error);
        }
    })
    .catch(err => console.error("Error selecting category:", err));
}

/**
 * Purchase equipment model
 */
function purchaseModel(model) {
    console.log("Purchasing model:", model);

    // DON'T clear preview when purchasing - keep equipment visible
    // The preview will remain attached as a visual representation

    fetch(`https://${GetParentResourceName()}/equipment:purchase`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model: model })
    })
    .then(response => response.json())
    .then(data => {
        console.log("Purchase response:", data);
    })
    .catch(err => console.error("Error purchasing model:", err));
}

/**
 * Equip equipment model
 */
function equipModel(model) {
    console.log("========================================");
    console.log("equipModel CALLED");
    console.log("  model:", model);
    console.log("  sport:", EquipmentState.currentSport);
    console.log("  category:", EquipmentState.currentCategory);
    console.log("========================================");

    if (!model) {
        console.error("ERROR: model is undefined/null!");
        return;
    }

    // DON'T clear preview when equipping - keep equipment visible
    // The preview will remain attached as a visual representation

    fetch(`https://${GetParentResourceName()}/equipment:equip`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model: model })
    })
    .then(response => response.json())
    .then(data => {
        console.log("Equip response:", data);
    })
    .catch(err => console.error("Error equipping model:", err));
}

/**
 * Unequip equipment model
 */
function unequipModel(model) {
    console.log("Unequipping model:", model);

    // Clear preview when unequipping - equipment is being removed
    fetch(`https://${GetParentResourceName()}/equipment:clearPreview`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
    })
    .catch(err => console.error("Error clearing preview:", err));

    fetch(`https://${GetParentResourceName()}/equipment:unequip`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model: model })
    })
    .then(response => response.json())
    .then(data => {
        console.log("Unequip response:", data);
        // Clear selection after unequip
        EquipmentState.selectedModel = null;
        updateActionButtons();
    })
    .catch(err => console.error("Error unequipping model:", err));
}

/**
 * Go back in equipment menu
 */
function equipmentGoBack() {
    console.log("========================================");
    console.log("equipmentGoBack CALLED");
    console.log("  currentSport:", EquipmentState.currentSport);
    console.log("  currentCategory:", EquipmentState.currentCategory);
    console.log("  selectedModel:", EquipmentState.selectedModel);
    console.log("========================================");

    // Close the exclusive package popup when navigating
    if (typeof closeExclusivePopup === "function") {
        closeExclusivePopup();
    }

    // Save current category before clearing (needed for reload)
    const previousCategory = EquipmentState.currentCategory;

    // Clear any selected model and reset loading state
    if (EquipmentState.selectedModel) {
        console.log("Clearing selectedModel:", EquipmentState.selectedModel);
        EquipmentState.selectedModel = null;
    }
    // Reset preview loading state and clear timeout when navigating back
    EquipmentState.isPreviewLoading = false;
    EquipmentState.pendingPreview = null;
    if (EquipmentState.previewTimeout) {
        clearTimeout(EquipmentState.previewTimeout);
        EquipmentState.previewTimeout = null;
    }

    if (EquipmentState.currentCategory) {
        // From model selection to category selection (NO teleport, just show categories)
        EquipmentState.currentCategory = null;

        console.log(">>> Going back from model selection - clearing preview first, then reloading equipped");
        console.log(">>> Category being cleared:", previousCategory);

        // IMMEDIATELY clear and hide the model page content to prevent overlay
        const modelGrid = document.getElementById("equipmentModelGrid");
        if (modelGrid) {
            modelGrid.innerHTML = "";
            modelGrid.scrollTop = 0;
        }
        const actionButtonsContainer = document.querySelector(".equipment-action-buttons");
        if (actionButtonsContainer) {
            actionButtonsContainer.innerHTML = "";
        }

        // IMMEDIATELY show category page (don't wait for async calls)
        showPage("equipmentCategorySelection");
        showBackButton();

        // Clear the preview for this category (async - don't block UI)
        fetch(`https://${GetParentResourceName()}/equipment:clearCategoryPreview`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                category: previousCategory
            })
        })
        .then(() => {
            // Reload the equipped item for the category (if any)
            return fetch(`https://${GetParentResourceName()}/equipment:reloadEquippedCategory`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    sport: EquipmentState.currentSport,
                    category: previousCategory
                })
            });
        })
        .catch(err => console.error("Error clearing/reloading category:", err));

        // Request categories to populate the grid
        fetch(`https://${GetParentResourceName()}/equipment:getCategories`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ sport: EquipmentState.currentSport })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Just populate the grid, page is already shown
                const categoryGrid = document.getElementById("equipmentCategoryGrid");
                if (categoryGrid) {
                    categoryGrid.innerHTML = "";
                    data.categories.forEach(category => {
                        const categoryCard = document.createElement("div");
                        categoryCard.className = "equipment-category-card";
                        categoryCard.innerHTML = `
                            <div>
                                <h3>${category.name}</h3>
                                <p>${category.count} designs available</p>
                            </div>
                        `;
                        categoryCard.onclick = () => selectEquipmentCategory(category.id);
                        categoryGrid.appendChild(categoryCard);
                    });
                    addEquipmentHoverSounds();
                }
            }
        })
        .catch(err => console.error("Error going back:", err));

    } else if (EquipmentState.currentSport) {
        // From category selection to sport selection
        EquipmentState.currentSport = null;

        // IMMEDIATELY clear and hide category content to prevent visual overlap
        const categoryGrid = document.getElementById("equipmentCategoryGrid");
        if (categoryGrid) {
            categoryGrid.innerHTML = "";
        }

        // IMMEDIATELY show sport selection page (don't wait for async)
        showPage("equipmentSportSelection");
        showBackButton(); // Keep back button to return to main menu

        // Notify client to restore player position (async - don't block UI)
        fetch(`https://${GetParentResourceName()}/equipment:goBack`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        })
        .catch(err => console.error("Error going back:", err));

    } else {
        // From sport selection, return to main menu
        closeEquipmentMenu();
    }
}

/**
 * Close equipment menu (send to client)
 */
function equipmentClose() {
    console.log("Closing equipment menu");

    fetch(`https://${GetParentResourceName()}/equipment:close`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        closeEquipmentMenu();
    })
    .catch(err => console.error("Error closing equipment:", err));
}

// ═══════════════════════════════════════════════════════════════
// 📨 MESSAGE HANDLERS (from client)
// ═══════════════════════════════════════════════════════════════

window.addEventListener("message", (event) => {
    const data = event.data;

    switch (data.action) {
        case "openEquipmentMenu":
            openEquipmentMenu(data);
            break;

        case "closeEquipmentMenu":
            closeEquipmentMenu();
            break;

        case "forceCloseEquipment":
            // Force close without showing main menu (used when store closes)
            forceCloseEquipment();
            break;

        case "updateEquipmentData":
            EquipmentState.ownedEquipment = data.equipment;
            // Update card states without re-rendering
            updateModelCardStates();
            // Update action buttons if a model is selected
            updateActionButtons();
            break;

        case "updateEquipmentPrices":
            EquipmentState.prices = data.prices;
            console.log("Prices updated:", EquipmentState.prices);
            // Update action buttons if a model is selected
            updateActionButtons();
            break;

        case "equipmentPurchaseSuccess":
            console.log("Purchase successful!", data.data);
            // Refresh will be triggered by updateEquipmentData
            break;

        case "equipmentPurchaseFailed":
            console.error("Purchase failed:", data.reason);
            if (data.reason === "requires_package" && data.packageInfo) {
                // Show notification with link to Tebex package
                console.log("Package required:", data.packageInfo);
                showPackageRequiredNotification(data.packageInfo);
            }
            break;

        case "updateOwnedPackages":
            EquipmentState.ownedPackages = data.packages || [];
            console.log("Owned packages updated:", EquipmentState.ownedPackages);
            // Refresh model cards if we're on model selection page
            if (EquipmentState.currentCategory) {
                updateModelCardLockStates();
                // Also update action buttons in case a model is selected
                updateActionButtons();
            }
            // Also update Discover page VIP button if function exists
            if (typeof loadDiscoverVipPrice === 'function') {
                loadDiscoverVipPrice();
            }
            break;

        case "equipmentEquipSuccess":
            console.log("Equip successful!", data.data);
            // Refresh will be triggered by updateEquipmentData
            break;

        case "equipmentUnequipSuccess":
            console.log("Unequip successful!", data.data);
            // Refresh will be triggered by updateEquipmentData
            break;

        case "previewReady":
            // Preview model has been loaded - clear loading state
            onPreviewReady(data.model);
            break;

        // Note: openUrlExternal is handled in index.html to avoid duplicate opens
    }
});

// ═══════════════════════════════════════════════════════════════
// 🚲 MARKER-BASED CUSTOMIZATION MESSAGE (BMX)
// When BMX is selected in the gear menu, design images are skipped.
// Instead, a message is shown telling the user to use the 3D markers
// on the vehicle itself to customize.
// ═══════════════════════════════════════════════════════════════

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "showMarkerCustomization") {
        // NOTE: bmx-customize.lua's ShowMainGroupButtons() already fires a
        // `bmxShowPartButtons` message handled in bmx-freestyle.js — that
        // renders a CLICKABLE BUTTON for each main bike part (Frame, Handle,
        // Front Wheel, Back Wheel) into #options. We used to overwrite that
        // with a static "Use the markers" placeholder, which is why the
        // user only saw the text and not the buttons. Keep the options
        // panel untouched so the real buttons stay visible.
        //
        // Still hide the purchase button (no price/buy on BMX customization)
        // and set the title for consistency.
        const purchaseBtn = document.getElementById("purchaseBtn");
        if (purchaseBtn) {
            purchaseBtn.style.display = "none";
        }
        const title = document.getElementById("submenu-title");
        if (title) {
            // Title adapts to the active category — was hardcoded "BMX
            // Customization", which displayed even when customizing a slopstyle.
            const labelByCategory = {
                bmx:       "BMX Customization",
                slopstyle: "Slopstyle Customization",
            };
            title.innerText = labelByCategory[data.category] || "Customization";
        }
    }
});

// Restore the purchase button when navigating to a non-BMX category.
// showSubMenu() clears #options (innerHTML = "") before populating it.
// renderDesignOptions() then adds .design-item-wrapper children.
// We watch for those children and restore the button if it was hidden.
(function() {
    const options = document.getElementById("options");
    if (!options) return;

    const observer = new MutationObserver(function(mutations) {
        for (const mutation of mutations) {
            for (const node of mutation.addedNodes) {
                if (node.nodeType === 1 && node.classList && node.classList.contains("design-item-wrapper")) {
                    // A real design item was added (non-BMX category)
                    const purchaseBtn = document.getElementById("purchaseBtn");
                    if (purchaseBtn && purchaseBtn.style.display === "none") {
                        purchaseBtn.style.display = "";
                    }
                    return; // Only need to restore once per batch
                }
            }
        }
    });

    observer.observe(options, { childList: true });
})();

// ═══════════════════════════════════════════════════════════════
// ⌨️ KEYBOARD CONTROLS
// ═══════════════════════════════════════════════════════════════

document.addEventListener("keydown", (event) => {
    if (!EquipmentState.isOpen) return;

    // ESC key - close or go back
    if (event.key === "Escape") {
        event.preventDefault();
        if (EquipmentState.currentCategory || EquipmentState.currentSport) {
            equipmentGoBack();
        } else {
            equipmentClose();
        }
    }
});

// ═══════════════════════════════════════════════════════════════
// 🔧 HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/**
 * Get parent resource name
 */
function GetParentResourceName() {
    let resourceName = "BDX-Sport-Hub";
    if (window.location.href.includes("://nui_")) {
        resourceName = window.location.href.split("://nui_")[1].split("/")[0];
    }
    return resourceName;
}

/**
 * Show notification when package is required
 */
function showPackageRequiredNotification(packageInfo) {
    // Create notification element
    const notification = document.createElement("div");
    notification.className = "equipment-notification package-required";
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas fa-lock"></i>
            <span>This item requires an Exclusive package!</span>
            <button onclick="openTebexPackage('${packageInfo.packageId}'); this.parentElement.parentElement.remove();">
                <i class="fas fa-shopping-cart"></i> Get Package
            </button>
            <button class="close-btn" onclick="this.parentElement.parentElement.remove();">
                <i class="fas fa-times"></i>
            </button>
        </div>
    `;

    // Add to equipment container
    const container = document.getElementById("equipmentContainer");
    if (container) {
        container.appendChild(notification);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }
}

/**
 * Update model card lock states (when packages update)
 */
function updateModelCardLockStates() {
    const allCards = document.querySelectorAll(".equipment-model-card");

    allCards.forEach(card => {
        const model = card.dataset.model;
        const isExclusive = card.dataset.exclusive === "true";
        const packageId = card.dataset.package || "";

        if (!model) return;

        const isOwnedInGame = isEquipmentOwned(model);
        const isEquipped = isEquipmentEquipped(model);
        const hasPackageAccess = isExclusive && playerOwnsPackage(packageId);

        // VIP items with package access are treated as "owned" (no in-game purchase needed)
        const isOwned = isOwnedInGame || hasPackageAccess;
        const isLocked = isExclusive && !playerOwnsPackage(packageId) && !isOwnedInGame;

        // Update classes
        card.classList.remove("locked", "owned", "equipped", "vip-owned");

        if (isLocked) {
            card.classList.add("locked");
        } else if (isEquipped) {
            card.classList.add("equipped");
        } else if (hasPackageAccess) {
            // VIP item unlocked via package - mark as owned (can equip directly)
            card.classList.add("owned", "vip-owned");
        } else if (isOwnedInGame) {
            card.classList.add("owned");
        }

        // IMPORTANT: Update click handler when lock state changes
        if (!isLocked) {
            card.onclick = () => selectModel(model);
            card.style.cursor = "pointer";
        } else {
            // Locked items don't have a direct click - use Preview button instead
            card.onclick = null;
            card.style.cursor = "default";
        }

        // Update lock overlay
        const existingOverlay = card.querySelector(".equipment-lock-overlay");
        const preview = card.querySelector(".equipment-model-preview");

        if (isLocked && !existingOverlay) {
            // Add lock overlay with Preview button
            if (preview) {
                const lockOverlay = document.createElement("div");
                lockOverlay.className = "equipment-lock-overlay";
                lockOverlay.innerHTML = `
                    <i class="fas fa-lock"></i>
                    <span class="lock-text">EXCLUSIVE</span>
                    <button class="unlock-btn" onclick="event.stopPropagation(); openTebexPackage('${packageId}');">
                        <i class="fas fa-shopping-cart"></i> Unlock
                    </button>
                    <button class="preview-btn" onclick="event.stopPropagation(); selectModel('${model}');">
                        <i class="fas fa-eye"></i> Preview
                    </button>
                `;
                preview.appendChild(lockOverlay);
            }
        } else if (!isLocked && existingOverlay) {
            // Remove lock overlay
            existingOverlay.remove();
        }

        // Update exclusive badge (add when unlocked, remove when locked)
        const existingBadge = card.querySelector(".vip-unlocked-badge");
        if (isExclusive && !isLocked && !existingBadge && preview) {
            // Add exclusive badge
            const badge = document.createElement("span");
            badge.className = "vip-unlocked-badge";
            badge.innerHTML = '<i class="fas fa-crown"></i> EXCLUSIVE';
            preview.appendChild(badge);
        } else if (isLocked && existingBadge) {
            // Remove badge if item becomes locked
            existingBadge.remove();
        }
    });

    console.log("Model card lock states updated");
}

console.log("Equipment.js loaded successfully");

// ═══════════════════════════════════════════════════════════════
// BMX 3D MARKER CUSTOMIZATION SYSTEM (MOVED TO bmx-freestyle.js)
// ═══════════════════════════════════════════════════════════════
/* OLD CODE DISABLED - handled by bmx-freestyle.js now

(function() {
    // Inject BMX marker CSS
    const style = document.createElement('style');
    style.textContent = `
        #bmx-markers { position: fixed; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 9000; }
        .bmx-marker {
            position: fixed; transform: translate(-50%, -50%);
            cursor: pointer; pointer-events: all; z-index: 9001;
            transition: transform 0.2s ease;
        }
        .bmx-marker:hover { transform: translate(-50%, -50%) scale(1.3); }
        .bmx-marker:hover .bmx-dot {
            background: #fff; border-color: #fff;
            box-shadow: 0 0 24px rgba(255,255,255,0.8), 0 0 48px rgba(255,255,255,0.3);
        }
        .bmx-marker:hover .bmx-dot::after { background: #000; width: 6px; height: 6px; }
        .bmx-marker:hover .bmx-label { opacity: 1; transform: translateX(-50%) translateY(0); }
        .bmx-marker:hover .bmx-ring { border-color: rgba(255,255,255,0.6); }
        .bmx-dot {
            width: 20px; height: 20px; border-radius: 50%;
            background: rgba(15,15,15,0.8); border: 2px solid rgba(255,255,255,0.75);
            position: relative; transition: all 0.25s ease;
            box-shadow: 0 0 10px rgba(0,0,0,0.5), 0 0 20px rgba(255,255,255,0.1);
        }
        .bmx-dot::after {
            content: ''; position: absolute; top: 50%; left: 50%;
            transform: translate(-50%,-50%); width: 5px; height: 5px;
            border-radius: 50%; background: rgba(255,255,255,0.9); transition: all 0.25s ease;
        }
        .bmx-ring {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%);
            width: 20px; height: 20px; border-radius: 50%;
            border: 1.5px solid rgba(255,255,255,0.15);
            animation: bmxRingPulse 2s ease-out infinite; pointer-events: none;
        }
        .bmx-ring2 {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%);
            width: 20px; height: 20px; border-radius: 50%;
            border: 1px solid rgba(255,255,255,0.08);
            animation: bmxRingPulse 2s ease-out 0.8s infinite; pointer-events: none;
        }
        @keyframes bmxRingPulse {
            0% { width: 20px; height: 20px; opacity: 0.6; }
            100% { width: 50px; height: 50px; opacity: 0; }
        }
        .bmx-label {
            position: absolute; bottom: calc(100% + 12px); left: 50%;
            transform: translateX(-50%) translateY(5px);
            background: rgba(0,0,0,0.9); color: #fff;
            font-size: 10px; font-weight: 600; letter-spacing: 1.8px;
            text-transform: uppercase; padding: 6px 14px; border-radius: 6px;
            white-space: nowrap; opacity: 0; transition: all 0.25s ease; pointer-events: none;
            backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.08);
        }
    `;
    document.head.appendChild(style);

    // Inject marker container + panel into body
    const markersDiv = document.createElement('div');
    markersDiv.id = 'bmx-markers';
    document.body.appendChild(markersDiv);

    // No separate panel — colors/liveries render inside the existing #options container

    let bmxPanelOpen = false;
    const bmxMarkerElements = {}; // Persistent marker elements keyed by marker key
    // Cached latest marker list — used to build the menu buttons that mirror
    // the 3D markers on the bike. Key set changes when the user drills into
    // a subgroup (Level 2 markers) or returns to the root (Level 1 markers).
    let bmxMarkerList = [];
    let bmxMarkerKeySig = ''; // concat of keys to detect list changes cheaply

    function bmxClickMarker(key) {
        console.log('[BMX] Marker clicked: ' + key);
        fetch(`https://${GetParentResourceName()}/bmxMarkerClicked`, {
            method: 'POST',
            headers: {'Content-Type':'application/json'},
            body: JSON.stringify({ key: key })
        });
    }

    // Render the current marker list as clickable buttons inside the gear
    // menu's #options container. Each button fires the SAME callback as
    // clicking the corresponding 3D marker on the bike. Placeholder text
    // shown until the Lua side pushes the first marker list.
    function bmxRenderMarkerButtons(options) {
        if (!options) return;
        options.innerHTML = '';
        if (bmxMarkerList.length === 0) {
            options.innerHTML = '<div style="text-align:center;padding:28px 20px;color:rgba(255,255,255,0.4);font-size:12px;letter-spacing:1px;">Waiting for bike parts…</div>';
            return;
        }
        const grid = document.createElement('div');
        grid.style.cssText = 'display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:14px;';
        bmxMarkerList.forEach(function(m) {
            const btn = document.createElement('button');
            btn.textContent = m.label;
            btn.style.cssText = [
                'padding:14px 10px',
                'background:rgba(255,255,255,0.06)',
                'border:1px solid rgba(255,255,255,0.12)',
                'border-radius:8px',
                'color:#fff',
                'font-size:12px',
                'font-weight:700',
                'letter-spacing:1px',
                'text-transform:uppercase',
                'cursor:pointer',
                'transition:all 0.15s ease',
                'font-family:inherit',
            ].join(';');
            btn.addEventListener('mouseenter', function() {
                btn.style.background = 'rgba(255,255,255,0.14)';
                btn.style.borderColor = 'rgba(255,255,255,0.28)';
            });
            btn.addEventListener('mouseleave', function() {
                btn.style.background = 'rgba(255,255,255,0.06)';
                btn.style.borderColor = 'rgba(255,255,255,0.12)';
            });
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                bmxClickMarker(m.key);
            });
            grid.appendChild(btn);
        });
        options.appendChild(grid);
    }

    function getOrCreateMarker(container, key, label) {
        if (bmxMarkerElements[key]) return bmxMarkerElements[key];
        const el = document.createElement('div');
        el.className = 'bmx-marker';
        el.setAttribute('data-key', key);
        el.innerHTML = '<div class="bmx-ring"></div><div class="bmx-ring2"></div><div class="bmx-dot"></div><div class="bmx-label">' + label + '</div>';
        el.addEventListener('mousedown', function(e) {
            e.preventDefault();
            e.stopPropagation();
            bmxClickMarker(key);
        });
        container.appendChild(el);
        bmxMarkerElements[key] = el;
        return el;
    }

    // Listen for BMX NUI messages
    window.addEventListener('message', function(event) {
        const d = event.data;

        // Update marker positions (reuse elements, don't recreate)
        if (d.action === 'bmxUpdateMarkers') {
            const c = document.getElementById('bmx-markers');
            if (!c) return;
            c.style.display = 'block';

            // Track which keys are present this frame
            const activeKeys = {};

            if (d.markers) {
                d.markers.forEach(function(m) {
                    activeKeys[m.key] = true;
                    const el = getOrCreateMarker(c, m.key, m.label);
                    el.style.left = (m.x * 100) + '%';
                    el.style.top = (m.y * 100) + '%';
                    el.style.display = 'block';
                });
            }

            // Hide markers not in this frame
            for (const k in bmxMarkerElements) {
                if (!activeKeys[k]) {
                    bmxMarkerElements[k].style.display = 'none';
                }
            }

            // Cache list for menu-button rendering. Only rebuild buttons if
            // the key set actually changed (e.g., user drilled into a
            // subgroup) or the panel isn't mid-customization.
            const newList = d.markers || [];
            const newSig = newList.map(function(m) { return m.key; }).join('|');
            if (newSig !== bmxMarkerKeySig) {
                bmxMarkerKeySig = newSig;
                bmxMarkerList = newList.slice();
                // Rebuild menu buttons only when we're on the marker-select
                // screen (panel closed). If a part is open, leave its
                // customization options visible.
                if (!bmxPanelOpen) {
                    const opts = document.getElementById('options');
                    if (opts) bmxRenderMarkerButtons(opts);
                }
            }
        }

        // Show selection in existing #options container (store page)
        // Show selection using the same design-item-wrapper format as other gears
        if (d.action === 'bmxShowPanel') {
            bmxPanelOpen = true;
            const options = document.getElementById('options');
            if (!options) return;
            options.innerHTML = '';

            // Update submenu title
            const subTitle = document.querySelector('#subMenu .menu-title');
            if (subTitle) subTitle.textContent = d.label || 'CUSTOMIZE';

            // Show purchase button area (for "BACK TO MARKERS")
            const purchaseBtn = document.getElementById('purchaseBtn');
            if (purchaseBtn) {
                purchaseBtn.textContent = 'BACK TO MARKERS';
                purchaseBtn.disabled = false;
                purchaseBtn.style.opacity = '1';
                purchaseBtn.style.cursor = 'pointer';
                purchaseBtn.style.display = '';
                purchaseBtn.onclick = function(e) {
                    e.preventDefault();
                    bmxPanelOpen = false;
                    // Return to marker-select view: re-render the button grid
                    // from the cached marker list (mirrors the 3D markers).
                    bmxRenderMarkerButtons(options);
                    if (subTitle) subTitle.textContent = 'BMX CUSTOMIZATION';
                    purchaseBtn.textContent = 'PURCHASE';
                    purchaseBtn.onclick = null;
                    purchaseBtn.style.display = 'none';
                    fetch(`https://${GetParentResourceName()}/bmxClosePanel`, { method:'POST', headers:{'Content-Type':'application/json'}, body:'{}' });
                };
            }

            // Build items using design-item-wrapper format (same as scooter/other gears)
            if (d.type === 'livery') {
                d.items.forEach(function(item, i) {
                    const wrapper = document.createElement('div');
                    wrapper.className = 'design-item-wrapper';

                    const img = document.createElement('img');
                    const hue = i * 55;
                    // Create a canvas-based color swatch as image
                    const canvas = document.createElement('canvas');
                    canvas.width = 256; canvas.height = 256;
                    const ctx = canvas.getContext('2d');
                    const grad = ctx.createLinearGradient(0, 0, 256, 256);
                    grad.addColorStop(0, 'hsl(' + hue + ', 60%, 45%)');
                    grad.addColorStop(1, 'hsl(' + (hue + 40) + ', 70%, 30%)');
                    ctx.fillStyle = grad;
                    ctx.fillRect(0, 0, 256, 256);
                    // Add text
                    ctx.fillStyle = 'rgba(255,255,255,0.9)';
                    ctx.font = 'bold 28px sans-serif';
                    ctx.textAlign = 'center';
                    ctx.fillText(item.name, 128, 140);
                    img.src = canvas.toDataURL();

                    img.alt = item.name;
                    img.setAttribute('data-id', i + 1);
                    img.setAttribute('data-type', 'livery');
                    img.onclick = function() {
                        // Remove selected from all, add to this one
                        options.querySelectorAll('.design-item-wrapper').forEach(function(w) { w.classList.remove('design-equipped'); });
                        wrapper.classList.add('design-equipped');
                        fetch(`https://${GetParentResourceName()}/bmxSelectLivery`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({index: i + 1}) });
                    };

                    wrapper.appendChild(img);
                    options.appendChild(wrapper);
                });

            } else if (d.type === 'color') {
                d.items.forEach(function(item, i) {
                    const wrapper = document.createElement('div');
                    wrapper.className = 'design-item-wrapper';

                    const img = document.createElement('img');
                    // Try to load PNG from customs/bmx/colors/
                    img.src = 'https://bdx-sport-hub.pages.dev/customs/bmx/colors/' + item.img;
                    img.onerror = function() {
                        this.src = `nui://${GetParentResourceName()}/nui/customs/bmx/colors/` + item.img;
                        this.onerror = null;
                    };
                    img.alt = item.name;
                    img.setAttribute('data-id', i + 1);
                    img.setAttribute('data-type', 'color');
                    img.onclick = function() {
                        options.querySelectorAll('.design-item-wrapper').forEach(function(w) { w.classList.remove('design-equipped'); });
                        wrapper.classList.add('design-equipped');
                        fetch(`https://${GetParentResourceName()}/bmxSelectColor`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({index: i + 1}) });
                    };

                    // Add name label
                    const nameLabel = document.createElement('div');
                    nameLabel.className = 'design-price';
                    nameLabel.textContent = item.name;
                    nameLabel.style.color = 'rgba(255,255,255,0.6)';

                    wrapper.appendChild(img);
                    wrapper.appendChild(nameLabel);
                    options.appendChild(wrapper);
                });
            }
        }

        // Hide all BMX UI
        if (d.action === 'bmxHideAll') {
            bmxPanelOpen = false;
            document.getElementById('bmx-markers').style.display = 'none';
            for (const k in bmxMarkerElements) {
                if (bmxMarkerElements[k].parentNode) bmxMarkerElements[k].parentNode.removeChild(bmxMarkerElements[k]);
                delete bmxMarkerElements[k];
            }
        }
    });
})();
OLD CODE DISABLED */
