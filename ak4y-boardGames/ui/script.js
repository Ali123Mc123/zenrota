
let currentLocales = null;
let globalLeaderboards = {};
let globalMyStats = {};
let globalMyCitizenId = "";
let globalSeasonsHistory = [];

function renderGlobalLeaderboard(game) {
    let listHtml = "";
    let leaderboard = globalLeaderboards[game] || [];
    let myStats = globalMyStats[game] || {};
    
    let isHighScoreGame = (game === "rodeo" || game === "boxmachine" || game === "basketball");
    
    $("#global-leaderboard-record-header").text(getLoc("record"));
    $("#global-leaderboard-rating-header").show();
    
    if (isHighScoreGame) {
        $("#global-leaderboard-rating-header").text(getLoc("rating"));
    } else {
        $("#global-leaderboard-rating-header").text(getLoc("rating"));
    }
    
    leaderboard.forEach(function(row) {
        let isSelf = (row.citizenid === globalMyCitizenId);
        let rowClass = isSelf ? "class='self-row'" : "";
        let avatarUrl = row.avatar && row.avatar !== "" ? row.avatar : "https://files.catbox.moe/4kd7sv.jpg";
        
        let recordText = "";
        let ratingText = "";
        
        if (isHighScoreGame) {
            let suffix = getLoc("plays_count") || "Plays";
            if (game === "rodeo") suffix = getLoc("rides_count") || "Rides";
            else if (game === "boxmachine") suffix = getLoc("punches_count") || "Punches";
            else if (game === "basketball") suffix = getLoc("throws_count") || "Throws";
            
            recordText = row.totalRides + " " + suffix;
            ratingText = row.highScore;
        } else {
            recordText = row.wins + "W - " + row.losses + "L - " + (row.draws || 0) + "D";
            ratingText = row.elo;
        }
        
        listHtml += `
            <tr ${rowClass}>
                <td style="padding: 0.7vh 1vh;">${row.rank}</td>
                <td style="padding: 0.7vh 1vh;">
                    <div class="leaderboard-player-cell">
                        <div class="leaderboard-player-avatar" style="background-image: url('${avatarUrl}');"></div>
                        <span class="leaderboard-player-name">${row.name}</span>
                    </div>
                </td>
                <td style="padding: 0.7vh 1vh;">${recordText}</td>
                <td style="padding: 0.7vh 1vh;"><span class="leaderboard-elo-val">${ratingText}</span></td>
            </tr>
        `;
    });
    
    if (listHtml === "") {
        listHtml = `<tr><td colspan="4" style="text-align: center; padding: 20px; color: #909296;">${getLoc("no_stats")}</td></tr>`;
    }
    
    $("#global-leaderboard-list").html(listHtml);
    
    if (myStats && myStats.rank) {
        let myRecord = "";
        let myRating = "";
        if (isHighScoreGame) {
            let suffix = getLoc("plays_count") || "Plays";
            if (game === "rodeo") suffix = getLoc("rides_count") || "Rides";
            else if (game === "boxmachine") suffix = getLoc("punches_count") || "Punches";
            else if (game === "basketball") suffix = getLoc("throws_count") || "Throws";

            myRecord = myStats.totalRides + " " + suffix;
            myRating = myStats.highScore;
        } else {
            myRecord = myStats.wins + "W - " + myStats.losses + "L - " + (myStats.draws || 0) + "D";
            myRating = myStats.elo;
        }
        let myStatsText = getLoc("my_stats")
            .replace("%s", myStats.rank)
            .replace("%s", myRecord)
            .replace("%s", myRating);
        $("#global-leaderboard-my-stats").text(myStatsText);
    } else {
        $("#global-leaderboard-my-stats").text("");
    }
}

function getLoc(key) {
    if (currentLocales && currentLocales.common && currentLocales.common.ui && currentLocales.common.ui[key]) {
        return currentLocales.common.ui[key];
    }
    if (currentLocales && currentLocales.general && currentLocales.general.game && currentLocales.general.game[key]) {
        return currentLocales.general.game[key];
    }
    if (currentLocales && currentLocales.santosPoly && currentLocales.santosPoly.game && currentLocales.santosPoly.game[key]) {
        return currentLocales.santosPoly.game[key];
    }
    return key;
}
function applyLocales() {
    $("[data-i18n]").each(function() {
        let key = $(this).attr("data-i18n").split(".").pop();
        let val = getLoc(key);
        if (val !== key) {
            if ($(this).is("input") || $(this).is("textarea")) {
                $(this).attr("placeholder", val);
            } else {
                $(this).html(val);
            }
        }
    });
}
$.post(`https://${GetParentResourceName()}/getLocales`, JSON.stringify({}), function(data) {
    if (data) {
        currentLocales = data;
        applyLocales();
    }
});

$(document).ready(function() {
    
    window.addEventListener('message', function(event) {
        let data = event.data;
        applyLocales();
        if (data.action === "showPaymentPopup") {
            let cost = data.cost;
            window.currentPaymentSessionId = data.sessionId;
            let text = getLoc("payment_desc").replace("%s", cost);
            $("#game-payment-desc").text(text);
            
            window.hadUniversalLobbyOpen = $("#universal-lobby-modal").is(":visible");
            if (window.hadUniversalLobbyOpen) {
                $("#universal-lobby-modal").hide();
            }
            window.hadJengoLobbyOpen = $("#jengo-waiting-display").is(":visible");
            if (window.hadJengoLobbyOpen) {
                $("#jengo-waiting-display").hide();
                $("#jengo-ui-container").hide();
            }
            window.hadChess3DUIOpen = $("#chess-3d-ui-container").is(":visible");
            if (window.hadChess3DUIOpen) {
                $("#chess-3d-ui-container").hide();
            }

            $("#game-payment-modal").fadeIn(200);
        } else if (data.action === "hidePaymentPopup") {
            setTimeout(() => {
                $("#game-payment-modal").fadeOut(200);
            }, 750);
            if (window.hadChess3DUIOpen) {
                $("#chess-3d-ui-container").show();
                window.hadChess3DUIOpen = false;
            }
        } else if (data.action === "openGlobalLeaderboard") {
            let payload = data.payload;
            globalLeaderboards = payload.leaderboards;
            globalMyStats = payload.myStats;
            globalMyCitizenId = payload.myCitizenId;
            globalSeasonsHistory = payload.seasonsHistory || [];
            
            let seasonSelect = $("#global-leaderboard-season-select");
            seasonSelect.empty();
            if (globalSeasonsHistory.length === 0) {
                seasonSelect.append(`<option value="">No past seasons</option>`);
            } else {
                globalSeasonsHistory.forEach(function(s) {
                    seasonSelect.append(`<option value="${s.season}">Season ${s.season} (${s.endDate})</option>`);
                });
            }
            
            $(".leaderboard-tab").removeClass("active");
            $("#leaderboard-tab-active").addClass("active");
            $("#leaderboard-active-controls").show();
            $("#leaderboard-history-controls").hide();
            
            let lastGame = $("#global-leaderboard-game-select").val() || "chess";
            renderGlobalLeaderboard(lastGame);
            
            $("#global-leaderboard-modal").fadeIn(250).css("display", "flex");
        }
        if (data.gameName) {
            window.currentLobbyGameName = data.gameName;
        }

        if (data.action === "showXoxUI") {
            if (data.active) {
                $("#xox-ui-container").fadeIn(300);
            } else {
                $("#xox-ui-container").fadeOut(200);
                $("#xox-turn-row").hide();
            }
        } else if (data.action === "xoxTurnUpdate") {
            if (data.gameActive) {
                $("#xox-turn-row").show();
                let indicator = $("#xox-turn-indicator");
                if (data.myTurn) {
                    indicator.text(getLoc("your_turn"));
                    indicator.removeClass("opponent-turn").addClass("my-turn");
                } else {
                    indicator.text(getLoc("opponent_s_turn"));
                    indicator.removeClass("my-turn").addClass("opponent-turn");
                }
            } else {
                $("#xox-turn-row").hide();
            }
        } else if (data.action === "showGameUI") {
            if (data.active) {
                $("#game-ui").fadeIn(300);
                if (data.isSpectator) {
                    $(".controls-panel").hide();
                    $("#eno-game-state-panel").hide();
                } else {
                    $(".controls-panel").show();
                    $("#eno-game-state-panel").show();
                }
            } else {
                $("#game-ui").fadeOut(200);
                $("#swap-player-modal").fadeOut(200);
            }
        }

        if (data.action === "showPassControl") {
            if (data.show) {
                $('#pass-control-row').show();
            } else {
                $('#pass-control-row').hide();
            }
        }

        if (data.action === "updateGameState") {
            
            let turnBadge = $("#turn-badge");
            let turnText = $("#turn-text");

            if (data.myTurn) {
                turnBadge.text(getLoc("your_turn") || "Your Turn").removeClass("other-turn").addClass("my-turn");
                turnText.html('<span style="color: #40C057; font-weight: 600;">' + (getLoc("it_is_your_turn") || "It's your turn!") + '</span> ' + (getLoc("select_card_to_play_or_draw") || "Select a card to play or draw from the deck."));
            } else {
                turnBadge.text(getLoc("opponent_s_turn") || "Opponent's Turn").removeClass("my-turn").addClass("other-turn");
                turnText.html(data.turnText || getLoc("waiting_for_opponent_to_play") || "Waiting for opponent to play...");
            }

            
            let colorBadge = $("#color-badge");
            colorBadge.removeClass("red blue green yellow none");
            
            if (data.currentColor && data.currentColor !== "wild") {
                let colorNames = {
                    red: getLoc("red") || "Red",
                    blue: getLoc("blue") || "Blue",
                    green: getLoc("green") || "Green",
                    yellow: getLoc("yellow") || "Yellow"
                };
                colorBadge.text(colorNames[data.currentColor] || data.currentColor).addClass(data.currentColor);
            } else {
                colorBadge.text("-").addClass("none");
            }

            
            $("#pot-badge").text("$" + (data.pot || 0));

            
            if (data.lastCard) {
                updateDiscardCardUI(data.lastCard);
            }
        }
    });

    
    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.action === "showColorPicker") {
            if (data.active) {
                $("#color-picker-modal").fadeIn(200);
            } else {
                $("#color-picker-modal").fadeOut(200);
            }
        }

        if (data.action === "showSwapTargetUI") {
            let container = $("#swap-player-list");
            container.empty();
            if (data.targets && data.targets.length > 0) {
                let cardSuffix = getLoc("cards_count_suffix") || "cards";
                data.targets.forEach(t => {
                    let btn = $(`<button class="gamemode-option" style="padding: 1vh; font-size: 1.5vh; cursor: pointer; border-radius: 0.5vh; background: rgba(30, 20, 15, 0.6); color: #F5F0E6; border: 0.1vh solid rgba(80, 50, 35, 0.6); transition: all 0.3s ease; text-align: center;">${t.name} (${t.cardCount} ${cardSuffix})</button>`);
                    btn.hover(
                        function() { $(this).css({ background: "rgba(212, 175, 55, 0.15)", border: "0.1vh solid rgba(212, 175, 55, 0.4)", transform: "translateY(-0.2vh)", boxShadow: "0 1vh 1.5vh rgba(0,0,0,0.4)" }); },
                        function() { $(this).css({ background: "rgba(30, 20, 15, 0.6)", border: "0.1vh solid rgba(80, 50, 35, 0.6)", transform: "translateY(0)", boxShadow: "none" }); }
                    );
                    btn.click(function() {
                        $.post(`https://${GetParentResourceName()}/swapTargetSelected`, JSON.stringify({
                            targetChair: t.chairId
                        }));
                        $("#swap-player-modal").fadeOut(200);
                    });
                    container.append(btn);
                });
                $("#swap-player-modal").fadeIn(200);
            } else {
                // Auto skip if no targets
                $.post(`https://${GetParentResourceName()}/swapTargetSelected`, JSON.stringify({
                    targetChair: null
                }));
            }
        }
        
        if (data.action === "hideSwapTargetUI") {
            $("#swap-player-modal").fadeOut(200);
        }

        if (data.action === "showEnoAlert") {
            let toast = $("#eno-toast-container");
            $("#eno-toast-text").text(data.message);
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(300);
            }, 3000);
        }

        if (data.action === "showWinner") {
            let toast = $("#winner-toast-container");
            $("#winner-toast-text").text(data.message);
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(500);
            }, 5000);
        }

        if (data.action === "showBlockAlert") {
            let toast = $("#block-toast-container");
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(400);
            }, 2500);
        }

        if (data.action === "showReverseAlert") {
            let toast = $("#reverse-toast-container");
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(400);
            }, 2500);
        }

        if (data.action === "showDrawAlert") {
            let toast = $("#draw-toast-container");
            $("#draw-toast-text").text("+" + data.count);
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(400);
            }, 2500);
        }

        if (data.action === "showColorAlert") {
            let toast = $("#color-toast-container");
            let bg = $("#color-toast-bg");
            
            bg.removeClass("red blue green yellow none");
            if (data.color && data.color !== "wild") {
                bg.addClass(data.color);
            }
            
            toast.hide();
            toast.css("animation", "none");
            toast[0].offsetHeight;
            toast.css("animation", "");
            toast.show();
            
            setTimeout(function() {
                toast.fadeOut(400);
            }, 2500);
        }

        if (data.action === "showLobby") {
            if (data.gameName) {
                window.currentLobbyGameName = data.gameName;
            }
            if (data.active) {
                $("#universal-lobby-modal").fadeIn(200);
                if (data.players) {
                    renderLobbyPlayers(data.players);
                }
                if (typeof data.myReady !== 'undefined') {
                    isReady = data.myReady;
                    let btn = $("#uni-lobby-ready-toggle-btn");
                    if (isReady) {
                        btn.addClass("ready-active").text(getLoc("unready"));
                    } else {
                        btn.removeClass("ready-active").text(getLoc("ready"));
                    }
                }
            } else {
                $("#universal-lobby-modal").fadeOut(200);
                
                isReady = false;
                $("#uni-lobby-ready-toggle-btn").removeClass("ready-active").text(getLoc("ready"));
            }
        }

        if (data.action === "updateLobby") {
            if (data.players) {
                renderLobbyPlayers(data.players);
            }
        }
    });

    function renderLobbyPlayers(players) {
        let container = $("#uni-lobby-players-list");
        container.empty();
        
        let myId = null; 
        
        let totalPot = 0;
        
        
        Object.values(players).forEach(player => {
            if (!player) return;
            totalPot += (player.bet || 0);
            
            let statusClass = player.ready ? "status-ready" : "status-not-ready";
            let statusText = player.ready ? getLoc("ready") : getLoc("not_ready");
            
            let html = `
                <div class="lobby-player-col">
                    <div class="lobby-avatar" style="background-image: url('${player.avatar || ''}');"></div>
                    <div class="lobby-player-name">${player.name}</div>
                    <div class="lobby-player-bet">${getLoc("bet") || "Bet"}: $${player.bet || 0}</div>
                    <div class="lobby-ready-status ${statusClass}">${statusText}</div>
                </div>
            `;
            container.append(html);
        });
        
        $("#uni-lobby-total-pot-vs, #uni-lobby-total-pot-multi").text("$" + totalPot);
    }

    






















    
    $(".color-btn").on("click", function() {
        let selectedColor = $(this).data("color");
        
        $("#color-picker-modal").fadeOut(150);
        
        
        $.post(`https://${GetParentResourceName()}/colorSelected`, JSON.stringify({
            color: selectedColor
        }));
    });

    
    function updateDiscardCardUI(cardName) {
        let card = $("#uno-card");
        if (!cardName) return;
        
        card.removeClass("red blue green yellow wild special special-huge card-pop-anim");
        
        let color = "wild";
        if (cardName.indexOf("red_") === 0) color = "red";
        else if (cardName.indexOf("blue_") === 0) color = "blue";
        else if (cardName.indexOf("green_") === 0) color = "green";
        else if (cardName.indexOf("yellow_") === 0) color = "yellow";
        
        card.addClass(color);
        
        let cleanName = cardName;
        if (cleanName === "wild_draw4" || cleanName === "draw4") cleanName = "draw_4";
        if (cleanName === "wild_change_color" || cleanName === "color_change") cleanName = "change_color";
        
        let imgPath = "cards/" + cleanName + ".png";
        card.html('<img id="uno-card-img" class="card-face-img" src="' + imgPath + '" alt="' + cleanName + '" onerror="this.onerror=null; this.src=\'cards/blue_0.png\';">');
        
        card[0].offsetHeight;
        card.addClass("card-pop-anim");
    }
});

let checkersPgnVisible = true;

$(function() {
    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.action === "showCheckersUI") {
            if (data.show) {
                $("#checkers-ui-container").fadeIn(300).css("display", "flex");
            } else {
                $("#checkers-ui-container").fadeOut(200);
                $("#universal-lobby-modal").fadeOut(200);
                $("#promotion-modal").fadeOut(200);
                $("#gamemode-modal").fadeOut(200);
                $("#leaderboard-modal").fadeOut(200);
                $("#pgn-container").fadeOut(200);
                $("#pgn-toggle-btn").fadeOut(200);
                $("#checkers-leave-prompt-modal").fadeOut(200);
            }
        } else if (data.action === "showCheckersLeavePrompt") {
            $("#checkers-leave-prompt-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "togglePGN") {
            checkersPgnVisible = !checkersPgnVisible;
            if (checkersPgnVisible) {
                $("#pgn-container").fadeIn(150);
            } else {
                $("#pgn-container").fadeOut(150);
            }
        } else if (data.action === "setSpectatorMode") {
            if (data.isSpectating) {
                $("#player-hints").hide();
                $("#spectator-hints").show();
                $(".keyboard-hint").show();
            } else if (data.isObserver) {
                $("#player-hints").hide();
                $("#spectator-hints").hide();
                $(".keyboard-hint").hide();
            } else {
                $("#player-hints").show();
                $("#spectator-hints").hide();
                $(".keyboard-hint").show();
            }
        } else if (data.action === "update") {
            let wName = (!data.whiteName || data.whiteName === "Waiting") ? (getLoc("waiting") || "Waiting") : data.whiteName;
            let bName = (!data.blackName || data.blackName === "Waiting") ? (getLoc("waiting") || "Waiting") : data.blackName;
            $("#white-name").text(wName).removeAttr("data-i18n");
            $("#black-name").text(bName).removeAttr("data-i18n");
            $("#white-score").text((data.whiteScore || 0) + " pts");
            $("#black-score").text((data.blackScore || 0) + " pts");

            if (data.whiteAvatar && data.whiteAvatar !== "") {
                $(".white-avatar").css("background-image", "url('" + data.whiteAvatar + "')");
            } else {
                $(".white-avatar").css("background-image", "none");
            }

            if (data.blackAvatar && data.blackAvatar !== "") {
                $(".black-avatar").css("background-image", "url('" + data.blackAvatar + "')");
            } else {
                $(".black-avatar").css("background-image", "none");
            }

            if (data.whiteInCheck) {
                $("#white-check").show();
            } else {
                $("#white-check").hide();
            }

            if (data.blackInCheck) {
                $("#black-check").show();
            } else {
                $("#black-check").hide();
            }

            $(".player-section").removeClass("active");
            $("#turn-status").removeClass("waiting my-turn their-turn");

            if (!data.gameReady) {
                $("#turn-status").text(getLoc("waiting_for_turn") || "Waiting").removeAttr("data-i18n").addClass("waiting");
            } else {
                if (data.turn === "white") {
                    $(".white-player").addClass("active");
                } else if (data.turn === "black") {
                    $(".black-player").addClass("active");
                }

                if (data.turn === data.myColor) {
                    $("#turn-status").text(getLoc("your_turn") || "Your Turn").removeAttr("data-i18n").addClass("my-turn");
                } else {
                    $("#turn-status").text(getLoc("opponent_s_turn") || "Opponent's Turn").removeAttr("data-i18n").addClass("their-turn");
                }
            }

            if (data.totalPot && data.totalPot > 0) {
                $("#hud-bet-val").text("$" + data.totalPot).removeAttr("data-i18n");
                $("#hud-bet-display").show();
            } else {
                $("#hud-bet-display").hide();
            }

            if (data.gameReady && data.timeLimit && data.timeLimit > 0 && data.clocks) {
                $("#white-timer-box").show();
                $("#black-timer-box").show();
                
                let wTime = data.clocks.white || 0;
                let bTime = data.clocks.black || 0;
                
                $("#white-timer").text(formatTime(wTime));
                $("#black-timer").text(formatTime(bTime));
                
                if (wTime < 30) {
                    $("#white-timer-box").addClass("low-time");
                } else {
                    $("#white-timer-box").removeClass("low-time");
                }
                
                if (bTime < 30) {
                    $("#black-timer-box").addClass("low-time");
                } else {
                    $("#black-timer-box").removeClass("low-time");
                }
            } else {
                $("#white-timer-box").hide();
                $("#black-timer-box").hide();
            }

            if (data.showLobby) {
                let proposedTime = data.timeLimit || 0;
                $(".uni-time-limit-btn").removeClass("active");
                $(`.uni-time-limit-btn[data-time="${proposedTime}"]`).addClass("active");

                
                $("#uni-lobby-p1-name").text(data.whiteName || getLoc("waiting") || "Waiting");
                if (data.whiteAvatar && data.whiteAvatar !== "") {
                    $("#uni-lobby-p1-avatar").css("background-image", "url('" + data.whiteAvatar + "')");
                } else {
                    $("#uni-lobby-p1-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p1-bet").text((getLoc("bet") || "Bet") + ": $" + (data.whiteBet || 0));
                if (data.whiteReady) {
                    $("#uni-lobby-p1-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p1-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                
                $("#uni-lobby-p2-name").text(data.blackName || getLoc("waiting") || "Waiting");
                if (data.blackAvatar && data.blackAvatar !== "") {
                    $("#uni-lobby-p2-avatar").css("background-image", "url('" + data.blackAvatar + "')");
                } else {
                    $("#uni-lobby-p2-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p2-bet").text((getLoc("bet") || "Bet") + ": $" + (data.blackBet || 0));
                if (data.blackReady) {
                    $("#uni-lobby-p2-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p2-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                
                $("#uni-lobby-total-pot-vs, #uni-lobby-total-pot-multi").text("$" + (data.totalPot || 0));
                
                
                if (!$("#uni-lobby-bet-amount-vs").is(":focus")) {
                    let myCurrentBet = (data.myColor === "white") ? data.whiteBet : data.blackBet;
                    $("#uni-lobby-bet-amount-vs").val(myCurrentBet || 0);
                }

                
                if (data.myReady) {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("unready") || "UNREADY").addClass("ready-active");
                } else {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("ready") || "READY").removeClass("ready-active");
                }

                
                $("#universal-lobby-modal").fadeIn(250).css("display", "flex");
            } else {
                $("#universal-lobby-modal").fadeOut(150);
            }

            if (data.gameReady && !data.showLobby) {
                $("#pgn-toggle-btn").fadeIn(250);
                if (checkersPgnVisible) {
                    $("#pgn-container").fadeIn(250);
                } else {
                    $("#pgn-container").fadeOut(150);
                }
                let movesListHtml = "";
                let moves = data.moves || [];
                if (moves.length === 0) {
                    movesListHtml = `<div class="pgn-no-moves">` + (getLoc("no_moves_played") || "No moves played yet") + `</div>`;
                } else {
                    let totalRows = Math.ceil(moves.length / 2);
                    let startRow = 0;
                    if (totalRows > 10) {
                        startRow = totalRows - 10;
                    }
                    for (let r = startRow; r < totalRows; r++) {
                        let i = r * 2;
                        let moveNum = r + 1;
                        let whiteMove = moves[i] || "";
                        let blackMove = moves[i + 1] || "";
                        movesListHtml += `
                            <div class="pgn-row">
                                <span class="pgn-num">${moveNum}.</span>
                                <span class="pgn-move white-move">${whiteMove}</span>
                                <span class="pgn-move black-move">${blackMove}</span>
                            </div>
                        `;
                    }
                }
                $("#pgn-moves-list").html(movesListHtml);
                let listElement = document.getElementById("pgn-moves-list");
                if (listElement) {
                    listElement.scrollTop = listElement.scrollHeight;
                }
            } else {
                checkersPgnVisible = true;
                $("#pgn-toggle-btn").fadeOut(150);
                $("#pgn-container").fadeOut(150);
            }
        } else if (data.action === "showGameModeModal") {
            $("#gamemode-title").text(getLoc("select_game_mode") || "Select Game Mode");
            $("#gamemode-desc").text(getLoc("choose_how_you_want_to_play") || "Choose how you want to play:");
            $("#mode-selection-step").show();
            $("#difficulty-selection-step").hide();
            $("#gamemode-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "hideGameModeModal") {
            $("#gamemode-modal").fadeOut(150);
        } else if (data.action === "showLeaderboard") {
            let listHtml = "";
            let leaderboard = data.leaderboard || [];
            let myCitizenId = data.myCitizenId;
            
            leaderboard.forEach(function(row) {
                let badgeContent = row.rank;
                
                let isSelf = (row.citizenid === myCitizenId);
                let rowClass = isSelf ? "class='self-row'" : "";
                
                let avatarUrl = row.avatar && row.avatar !== "" ? row.avatar : "https://files.catbox.moe/4kd7sv.jpg";
                
                listHtml += `
                    <tr ${rowClass}>
                        <td>
                            ${badgeContent}
                        </td>
                        <td>
                            <div class="leaderboard-player-cell">
                                <div class="leaderboard-player-avatar" style="background-image: url('${avatarUrl}');"></div>
                                <span class="leaderboard-player-name">${row.name}</span>
                            </div>
                        </td>
                        <td>${row.wins}W - ${row.losses}L - ${row.draws || 0}D</td>
                        <td><span class="leaderboard-elo-val">${row.elo}</span></td>
                    </tr>
                `;
            });
            
            $("#leaderboard-list").html(listHtml);
            $("#leaderboard-modal").fadeIn(250).css("display", "flex");
        }
    });

    $(document).on("click", ".gamemode-option", function() {
        let mode = $(this).data("mode");
        if (mode === "player") {
            $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "player" }));
            $("#gamemode-modal").fadeOut(150);
        } else if (mode === "ped") {
            $("#gamemode-title").text(getLoc("select_difficulty") || "Select Difficulty");
            $("#gamemode-desc").text(getLoc("choose_ai_opponent_strength") || "Choose AI opponent strength:");
            $("#mode-selection-step").fadeOut(150, function() {
                $("#difficulty-selection-step").fadeIn(150);
            });
        }
    });

    $(document).on("click", ".difficulty-option", function() {
        let difficulty = $(this).data("difficulty");
        $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "ped", difficulty: difficulty }));
        $("#gamemode-modal").fadeOut(150);
    });

    $(document).on("click", "#close-gamemode-btn", function() {
        $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "cancel" }));
        $("#gamemode-modal").fadeOut(150);
    });



























    $(document).on("click", "#pgn-toggle-btn", function() {
        checkersPgnVisible = !checkersPgnVisible;
        if (checkersPgnVisible) {
            $("#pgn-container").fadeIn(150);
        } else {
            $("#pgn-container").fadeOut(150);
        }
    });
});

function formatTime(seconds) {
    let m = Math.floor(seconds / 60);
    let s = seconds % 60;
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
}

function updateCrowns(crowns) {
    let container = document.getElementById('crowns-container');
    if (!container) return;
    container.innerHTML = '';
    if (crowns && crowns.length > 0) {
        container.style.display = 'block';
        crowns.forEach(c => {
            let img = document.createElement('img');
            img.src = 'crown.png';
            img.className = 'crown-sprite';
            img.style.left = (c.x * 100) + 'vw';
            img.style.top = (c.y * 100) + 'vh';
            container.appendChild(img);
        });
    } else {
        container.style.display = 'none';
    }
}

window.addEventListener('message', function(event) {
    let item = event.data;
    if (item.action === 'updateCrowns') {
        updateCrowns(item.crowns);
    } else if (item.action === 'playJumpSound') {
        let jumpAudio = new Audio('audio/jump.mp3');
        jumpAudio.volume = 0.5;
        jumpAudio.play();
    }
});

let pgnVisible = true;

$(function() {
    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.action === "showChessUI") {
            if (data.show) {
                $("#chess-ui-container").fadeIn(300).css("display", "flex");
            } else {
                $("#chess-ui-container").fadeOut(200);
                $("#universal-lobby-modal").fadeOut(200);
                $("#promotion-modal").fadeOut(200);
                $("#gamemode-modal").fadeOut(200);
                $("#leaderboard-modal").fadeOut(200);
                $("#pgn-container").fadeOut(200);
                $("#pgn-toggle-btn").fadeOut(200);
                $("#chess-leave-prompt-modal").fadeOut(200);
                $("#checkers-leave-prompt-modal").fadeOut(200);
            }
        } else if (data.action === "showXoxLeavePrompt") {
            $("#xox-leave-prompt-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "showChessLeavePrompt") {
            $("#chess-leave-prompt-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "showCheckersLeavePrompt") {
            $("#checkers-leave-prompt-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "showEnoLeavePrompt") {
            $("#eno-leave-prompt-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "togglePGN") {
            pgnVisible = !pgnVisible;
            if (pgnVisible) {
                $("#pgn-container").fadeIn(150);
            } else {
                $("#pgn-container").fadeOut(150);
            }
        } else if (data.action === "setSpectatorMode") {
            if (data.isSpectating) {
                $("#player-hints").hide();
                $("#spectator-hints").show();
                $(".keyboard-hint").show();
            } else if (data.isObserver) {
                $("#player-hints").hide();
                $("#spectator-hints").hide();
                $(".keyboard-hint").hide();
            } else {
                $("#player-hints").show();
                $("#spectator-hints").hide();
                $(".keyboard-hint").show();
            }
        } else if (data.action === "update") {
            let $c = $("#chess-ui-container");
            let wNameC = (!data.whiteName || data.whiteName === "Waiting") ? (getLoc("waiting") || "Waiting") : data.whiteName;
            let bNameC = (!data.blackName || data.blackName === "Waiting") ? (getLoc("waiting") || "Waiting") : data.blackName;
            $c.find("#white-name").text(wNameC).removeAttr("data-i18n");
            $c.find("#black-name").text(bNameC).removeAttr("data-i18n");
            $c.find("#white-score").text((data.whiteScore || 0) + " pts");
            $c.find("#black-score").text((data.blackScore || 0) + " pts");

            if (data.whiteAvatar && data.whiteAvatar !== "") {
                $c.find(".white-avatar").css("background-image", "url('" + data.whiteAvatar + "')");
            } else {
                $c.find(".white-avatar").css("background-image", "none");
            }

            if (data.blackAvatar && data.blackAvatar !== "") {
                $c.find(".black-avatar").css("background-image", "url('" + data.blackAvatar + "')");
            } else {
                $c.find(".black-avatar").css("background-image", "none");
            }

            if (data.whiteInCheck) {
                $c.find("#white-check").show();
            } else {
                $c.find("#white-check").hide();
            }

            if (data.blackInCheck) {
                $c.find("#black-check").show();
            } else {
                $c.find("#black-check").hide();
            }

            $c.find(".player-section").removeClass("active");
            $c.find("#turn-status").removeClass("waiting my-turn their-turn");

            if (!data.gameReady) {
                $c.find("#turn-status").text(getLoc("waiting_for_turn") || "Waiting").removeAttr("data-i18n").addClass("waiting");
            } else {
                if (data.turn === "white") {
                    $c.find(".white-player").addClass("active");
                } else if (data.turn === "black") {
                    $c.find(".black-player").addClass("active");
                }

                if (data.turn === data.myColor) {
                    $c.find("#turn-status").text(getLoc("your_turn") || "Your Turn").removeAttr("data-i18n").addClass("my-turn");
                } else {
                    $c.find("#turn-status").text(getLoc("opponent_s_turn") || "Opponent's Turn").removeAttr("data-i18n").addClass("their-turn");
                }
            }

            if (data.totalPot && data.totalPot > 0) {
                $c.find("#hud-bet-val").text("$" + data.totalPot).removeAttr("data-i18n");
                $c.find("#hud-bet-display").show();
            } else {
                $c.find("#hud-bet-display").hide();
            }

            if (data.gameReady && data.timeLimit && data.timeLimit > 0 && data.clocks) {
                $c.find("#white-timer-box").show();
                $c.find("#black-timer-box").show();
                
                let wTime = data.clocks.white || 0;
                let bTime = data.clocks.black || 0;
                
                $c.find("#white-timer").text(formatTime(wTime));
                $c.find("#black-timer").text(formatTime(bTime));
                
                if (wTime < 30) {
                    $("#white-timer-box").addClass("low-time");
                } else {
                    $("#white-timer-box").removeClass("low-time");
                }
                
                if (bTime < 30) {
                    $("#black-timer-box").addClass("low-time");
                } else {
                    $("#black-timer-box").removeClass("low-time");
                }
            } else {
                $("#white-timer-box").hide();
                $("#black-timer-box").hide();
            }

            if (data.showLobby) {
                let proposedTime = data.timeLimit || 0;
                $(".uni-time-limit-btn").removeClass("active");
                $(`.uni-time-limit-btn[data-time="${proposedTime}"]`).addClass("active");

                
                $("#uni-lobby-p1-name").text(data.whiteName || getLoc("waiting") || "Waiting");
                if (data.whiteAvatar && data.whiteAvatar !== "") {
                    $("#uni-lobby-p1-avatar").css("background-image", "url('" + data.whiteAvatar + "')");
                } else {
                    $("#uni-lobby-p1-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p1-bet").text((getLoc("bet") || "Bet") + ": $" + (data.whiteBet || 0));
                if (data.whiteReady) {
                    $("#uni-lobby-p1-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p1-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                
                $("#uni-lobby-p2-name").text(data.blackName || getLoc("waiting") || "Waiting");
                if (data.blackAvatar && data.blackAvatar !== "") {
                    $("#uni-lobby-p2-avatar").css("background-image", "url('" + data.blackAvatar + "')");
                } else {
                    $("#uni-lobby-p2-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p2-bet").text((getLoc("bet") || "Bet") + ": $" + (data.blackBet || 0));
                if (data.blackReady) {
                    $("#uni-lobby-p2-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p2-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                
                $("#uni-lobby-total-pot-vs, #uni-lobby-total-pot-multi").text("$" + (data.totalPot || 0));
                
                
                if (!$("#uni-lobby-bet-amount-vs").is(":focus")) {
                    let myCurrentBet = (data.myColor === "white") ? data.whiteBet : data.blackBet;
                    $("#uni-lobby-bet-amount-vs").val(myCurrentBet || 0);
                }

                
                if (data.myReady) {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("unready") || "UNREADY").addClass("ready-active");
                } else {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("ready") || "READY").removeClass("ready-active");
                }

                
                $("#universal-lobby-modal").fadeIn(250).css("display", "flex");
            } else {
                $("#universal-lobby-modal").fadeOut(150);
            }

            if (data.gameReady && !data.showLobby) {
                $("#pgn-toggle-btn").fadeIn(250);
                if (pgnVisible) {
                    $("#pgn-container").fadeIn(250);
                } else {
                    $("#pgn-container").fadeOut(150);
                }
                let movesListHtml = "";
                let moves = data.moves || [];
                if (moves.length === 0) {
                    movesListHtml = `<div class="pgn-no-moves">` + (getLoc("no_moves_played") || "No moves played yet") + `</div>`;
                } else {
                    let totalRows = Math.ceil(moves.length / 2);
                    let startRow = 0;
                    if (totalRows > 10) {
                        startRow = totalRows - 10;
                    }
                    for (let r = startRow; r < totalRows; r++) {
                        let i = r * 2;
                        let moveNum = r + 1;
                        let whiteMove = moves[i] || "";
                        let blackMove = moves[i + 1] || "";
                        movesListHtml += `
                            <div class="pgn-row">
                                <span class="pgn-num">${moveNum}.</span>
                                <span class="pgn-move white-move">${whiteMove}</span>
                                <span class="pgn-move black-move">${blackMove}</span>
                            </div>
                        `;
                    }
                }
                $("#pgn-moves-list").html(movesListHtml);
                let listElement = document.getElementById("pgn-moves-list");
                if (listElement) {
                    listElement.scrollTop = listElement.scrollHeight;
                }
            } else {
                pgnVisible = true;
                $("#pgn-toggle-btn").fadeOut(150);
                $("#pgn-container").fadeOut(150);
            }
        } else if (data.action === "showPromotion") {
            let isWhite = (data.color === "white");
            $(".promotion-option[data-choice='queen'] .option-symbol").text(isWhite ? "â™•" : "â™›");
            $(".promotion-option[data-choice='rook'] .option-symbol").text(isWhite ? "â™–" : "â™œ");
            $(".promotion-option[data-choice='bishop'] .option-symbol").text(isWhite ? "â™—" : "â™");
            $(".promotion-option[data-choice='knight'] .option-symbol").text(isWhite ? "â™˜" : "â™");
            $("#promotion-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "hidePromotion") {
            $("#promotion-modal").fadeOut(150);
        } else if (data.action === "showGameModeModal") {
            $("#gamemode-title").text(getLoc("select_game_mode") || "Select Game Mode");
            $("#gamemode-desc").text(getLoc("choose_how_you_want_to_play") || "Choose how you want to play:");
            $("#mode-selection-step").show();
            $("#difficulty-selection-step").hide();
            $("#gamemode-modal").fadeIn(250).css("display", "flex");
        } else if (data.action === "hideGameModeModal") {
            $("#gamemode-modal").fadeOut(150);
        } else if (data.action === "showLeaderboard") {
            let listHtml = "";
            let leaderboard = data.leaderboard || [];
            let myCitizenId = data.myCitizenId;
            
            leaderboard.forEach(function(row) {
                let badgeContent = row.rank;
                
                let isSelf = (row.citizenid === myCitizenId);
                let rowClass = isSelf ? "class='self-row'" : "";
                
                let avatarUrl = row.avatar && row.avatar !== "" ? row.avatar : "https://files.catbox.moe/4kd7sv.jpg";
                
                listHtml += `
                    <tr ${rowClass}>
                        <td>
                            ${badgeContent}
                        </td>
                        <td>
                            <div class="leaderboard-player-cell">
                                <div class="leaderboard-player-avatar" style="background-image: url('${avatarUrl}');"></div>
                                <span class="leaderboard-player-name">${row.name}</span>
                            </div>
                        </td>
                        <td>${row.wins}W - ${row.losses}L - ${row.draws || 0}D</td>
                        <td><span class="leaderboard-elo-val">${row.elo}</span></td>
                    </tr>
                `;
            });
            
            $("#leaderboard-list").html(listHtml);
            $("#leaderboard-modal").fadeIn(250).css("display", "flex");
        }
    });

    $(document).on("click", "#chess-leave-yes", function() {
        $.post(`https://${GetParentResourceName()}/chessLeaveConfirm`, JSON.stringify({}));
        $("#chess-leave-prompt-modal").fadeOut(150);
    });

    $(document).on("click", "#chess-leave-no", function() {
        $.post(`https://${GetParentResourceName()}/chessLeaveCancel`, JSON.stringify({}));
        $("#chess-leave-prompt-modal").fadeOut(150);
    });

    $(document).on("click", ".promotion-option", function() {
        let choice = $(this).data("choice");
        $.post(`https://${GetParentResourceName()}/promoteChoice`, JSON.stringify({ choice: choice }));
        $("#promotion-modal").fadeOut(150);
    });

    $(document).on("click", ".gamemode-option", function() {
        let mode = $(this).data("mode");
        if (mode === "player") {
            $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "player" }));
            $("#gamemode-modal").fadeOut(150);
        } else if (mode === "ped") {
            $("#gamemode-title").text(getLoc("select_difficulty") || "Select Difficulty");
            $("#gamemode-desc").text(getLoc("choose_ai_opponent_strength") || "Choose AI opponent strength:");
            $("#mode-selection-step").fadeOut(150, function() {
                $("#difficulty-selection-step").fadeIn(150);
            });
        }
    });

    $(document).on("click", ".difficulty-option", function() {
        let difficulty = $(this).data("difficulty");
        $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "ped", difficulty: difficulty }));
        $("#gamemode-modal").fadeOut(150);
    });

    $(document).on("click", "#close-gamemode-btn", function() {
        $.post(`https://${GetParentResourceName()}/selectGameMode`, JSON.stringify({ mode: "cancel" }));
        $("#gamemode-modal").fadeOut(150);
    });



































});

function formatTime(seconds) {
    let m = Math.floor(seconds / 60);
    let s = seconds % 60;
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
}

;(function() {
let currentRequesterId = null;

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === "openPlayerList") {
        openPlayerList(data.players);
    } else if (data.action === "openRequest") {
        openRequest(data.requesterId, data.requesterName);
    } else if (data.action === "close") {
        closeAll();
    }
});

function openPlayerList(players) {
    const listContainer = document.getElementById('player-list');
    listContainer.innerHTML = '';

    if (players && players.length > 0) {
        players.forEach(player => {
            const card = document.createElement('div');
            card.className = 'player-card';
            card.innerHTML = `
                <span class="player-name">${player.name}</span>
                <span class="player-id">ID: ${player.id}</span>
            `;
            card.onclick = () => selectPlayer(player.id);
            listContainer.appendChild(card);
        });
    } else {
        listContainer.innerHTML = '<p class="subtitle" style="text-align: center; margin-top: 20px;">' + (getLoc("no_players_nearby") || "No players nearby.") + '</p>';
    }

    document.getElementById('player-list-container').classList.remove('hidden');
}

function openRequest(id, name) {
    currentRequesterId = id;
    document.getElementById('requester-name').innerText = name;
    document.getElementById('request-container').classList.remove('hidden');
}

function selectPlayer(id) {
    fetch(`https://${GetParentResourceName()}/selectPlayer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ targetId: id })
    });
    closeAll();
}

document.getElementById('close-list').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
    closeAll();
});

document.getElementById('btn-accept').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/answerRequest`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requesterId: currentRequesterId, accepted: true })
    });
    closeAll();
});

document.getElementById('btn-decline').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/answerRequest`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ requesterId: currentRequesterId, accepted: false })
    });
    closeAll();
});

window.closeAll = function() {
    document.getElementById('player-list-container').classList.add('hidden');
    document.getElementById('request-container').classList.add('hidden');
    document.getElementById('image-selection-container').classList.add('hidden');
}

document.onkeyup = function (data) {
    if (data.key === 'Escape') {
        if ($("#admin-menu-modal").is(":visible")) {
            $('#admin-close-btn').click();
            return;
        }
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
        closeAll();
    }
};

let selectedImageUrl = null;
let selectedImageIsDirect = false;
let currentTargetIdForImage = null;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === "openImageSelector") {
        currentTargetIdForImage = data.targetId;
        document.getElementById('image-search-input').value = '';
        document.getElementById('image-grid').innerHTML = '';
        document.getElementById('selected-action-area').classList.add('hidden');
        selectedImageUrl = null;
        selectedImageIsDirect = false;
        document.getElementById('image-selection-container').classList.remove('hidden');
    }
});

document.getElementById('close-image-list').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
    closeAll();
});

document.getElementById('btn-search').addEventListener('click', () => {
    const query = document.getElementById('image-search-input').value.trim();
    if (!query) return;

    const grid = document.getElementById('image-grid');
    grid.innerHTML = '<div class="loader-text">' + (getLoc("searching") || "Searching...") + '</div>';
    document.getElementById('selected-action-area').classList.add('hidden');
    selectedImageUrl = null;
    selectedImageIsDirect = false;

    if (query.startsWith('http://') || query.startsWith('https://')) {
        grid.innerHTML = '';
        addImageToGrid(query, true);
        return;
    }

    const url = `https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=${encodeURIComponent(query)}&prop=pageimages&pithumbsize=500&format=json&origin=*`;
    
    fetch(url)
        .then(res => res.json())
        .then(data => {
            grid.innerHTML = '';
            const pages = data.query && data.query.pages;
            if (pages) {
                let found = false;
                Object.values(pages).forEach(page => {
                    if (page.thumbnail && page.thumbnail.source) {
                        found = true;
                        addImageToGrid(page.thumbnail.source, false);
                    }
                });
                if (!found) {
                    grid.innerHTML = '<div class="loader-text">' + (getLoc("no_images_found") || "No images found. Try a different search.") + '</div>';
                }
            } else {
                grid.innerHTML = '<div class="loader-text">' + (getLoc("no_results_found") || "No results found.") + '</div>';
            }
        })
        .catch(err => {
            grid.innerHTML = '<div class="loader-text">' + (getLoc("error_searching") || "Error searching. Try pasting a direct URL.") + '</div>';
        });
});

document.getElementById('image-search-input').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
        document.getElementById('btn-search').click();
    }
});

function addImageToGrid(imgUrl, isDirect) {
    const grid = document.getElementById('image-grid');
    const container = document.createElement('div');
    container.className = 'grid-img-container';
    container.innerHTML = `<img src="${imgUrl}" alt="Result">`;
    
    container.addEventListener('click', () => {
        document.querySelectorAll('.grid-img-container').forEach(el => el.classList.remove('selected'));
        container.classList.add('selected');
        selectedImageUrl = imgUrl;
        selectedImageIsDirect = isDirect;
        document.getElementById('selected-action-area').classList.remove('hidden');
    });
    
    grid.appendChild(container);
}

document.getElementById('btn-confirm-image').addEventListener('click', () => {
    if (selectedImageUrl && currentTargetIdForImage) {
        const duration = parseInt(document.getElementById('timer-select').value);
        fetch(`https://${GetParentResourceName()}/submitImage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                targetId: currentTargetIdForImage, 
                imageUrl: selectedImageUrl,
                duration: duration,
                isDirectLink: selectedImageIsDirect
            })
        });
        closeAll();
    }
});


let timerInterval = null;
let totalTime = 0;
let currentTime = 0;
let verifyGuessTargetId = null;

window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === "startTimer") {
        totalTime = data.duration;
        currentTime = data.duration;
        
        if (totalTime > 0) {
            document.getElementById('timer-hud-container').classList.remove('hidden');
            updateTimerUI();
            
            clearInterval(timerInterval);
            timerInterval = setInterval(() => {
                currentTime--;
                updateTimerUI();
                
                if (currentTime <= 0) {
                    clearInterval(timerInterval);
                    document.getElementById('timer-hud-container').classList.add('hidden');
                    fetch(`https://${GetParentResourceName()}/timeUp`, { method: 'POST' });
                }
            }, 1000);
        } else {
            
            document.getElementById('timer-text').innerText = "âˆž";
            document.getElementById('timer-bar').style.width = "100%";
            document.getElementById('timer-hud-container').classList.remove('hidden');
        }
    } else if (data.action === "stopTimer") {
        clearInterval(timerInterval);
        document.getElementById('timer-hud-container').classList.add('hidden');
    } else if (data.action === "startWatcherTimer") {
        totalTime = data.duration;
        currentTime = data.duration;
        if (totalTime > 0) {
            document.getElementById('timer-hud-container').classList.remove('hidden');
            let hint = document.querySelector('#timer-hud-container .hud-hint');
            if (hint) hint.style.display = 'none';
            updateTimerUI();
            
            clearInterval(timerInterval);
            timerInterval = setInterval(() => {
                currentTime--;
                if (currentTime < 0) {
                    clearInterval(timerInterval);
                    document.getElementById('timer-hud-container').classList.add('hidden');
                } else {
                    updateTimerUI();
                }
            }, 1000);
        }
    } else if (data.action === "stopWatcherTimer") {
        clearInterval(timerInterval);
        document.getElementById('timer-hud-container').classList.add('hidden');
        let hint = document.querySelector('#timer-hud-container .hud-hint');
        if (hint) hint.style.display = 'block';
    } else if (data.action === "openGuessInput") {
        document.getElementById('guess-text-input').value = '';
        document.getElementById('guess-input-container').classList.remove('hidden');
        document.getElementById('guess-text-input').focus();
    } else if (data.action === "openVerifyGuess") {
        verifyGuessTargetId = data.targetId;
        document.getElementById('verify-guess-text').innerText = data.guess;
        document.getElementById('verify-guess-container').classList.remove('hidden');
    }
});

function updateTimerUI() {
    if (currentTime < 0) return;
    
    const m = Math.floor(currentTime / 60).toString().padStart(2, '0');
    const s = (currentTime % 60).toString().padStart(2, '0');
    document.getElementById('timer-text').innerText = `${m}:${s}`;
    
    const pct = (currentTime / totalTime) * 100;
    const bar = document.getElementById('timer-bar');
    bar.style.width = `${pct}%`;
    
    if (pct < 20) {
        bar.style.backgroundColor = '#FA5252'; 
    } else if (pct < 50) {
        bar.style.backgroundColor = '#FAB005'; 
    } else {
        bar.style.backgroundColor = '#40C057'; 
    }
}

document.getElementById('close-guess-input').addEventListener('click', () => {
    document.getElementById('guess-input-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
});

document.getElementById('btn-submit-guess').addEventListener('click', () => {
    const guess = document.getElementById('guess-text-input').value.trim();
    if (guess) {
        fetch(`https://${GetParentResourceName()}/submitGuess`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ guess: guess })
        });
        document.getElementById('guess-input-container').classList.add('hidden');
    }
});

document.getElementById('guess-text-input').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
        document.getElementById('btn-submit-guess').click();
    }
});

document.getElementById('btn-verify-yes').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/verifyGuess`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ targetId: verifyGuessTargetId, isCorrect: true })
    });
    document.getElementById('verify-guess-container').classList.add('hidden');
});

document.getElementById('btn-verify-no').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/verifyGuess`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ targetId: verifyGuessTargetId, isCorrect: false })
    });
    document.getElementById('verify-guess-container').classList.add('hidden');
});

})();

;(function() {
(function() {
    var container = document.getElementById('jengo-ui-container');
    var waitingDisplay = document.getElementById('jengo-waiting-display');
    var lobbyModal = document.getElementById('universal-lobby-modal');

    window.addEventListener('message', function(event) {
        var data = event.data;

        if (data.action === 'showJengoUI') {
            if (data.show) {
                container.style.display = 'block';
            } else {
                container.style.display = 'none';
                lobbyModal.style.display = 'none';
                waitingDisplay.style.display = 'none';
                document.getElementById('jengo-game-hud').style.display = 'none';
                $("#jengo-leave-prompt-modal").fadeOut(200);
            }
        } else if (data.action === 'showJengoLeavePrompt') {
            $("#jengo-leave-prompt-modal").fadeIn(250).css("display", "flex");
        }

        if (data.action === 'updateJengo') {
            if (data.showLobby) {
                waitingDisplay.style.display = 'none';
                lobbyModal.style.display = 'flex';

                document.getElementById('uni-lobby-p1-name').textContent = data.player1Name || 'Waiting...';
                document.getElementById('uni-lobby-p2-name').textContent = data.player2Name || 'Waiting...';

                var p1Avatar = document.getElementById('uni-lobby-p1-avatar');
                var p2Avatar = document.getElementById('uni-lobby-p2-avatar');
                if (data.player1Avatar) {
                    p1Avatar.style.backgroundImage = 'url(' + data.player1Avatar + ')';
                } else {
                    p1Avatar.style.backgroundImage = 'none';
                }
                if (data.player2Avatar) {
                    p2Avatar.style.backgroundImage = 'url(' + data.player2Avatar + ')';
                } else {
                    p2Avatar.style.backgroundImage = 'none';
                }

                if (document.getElementById('uni-lobby-p1-bet')) {
                    document.getElementById('uni-lobby-p1-bet').textContent = (getLoc("bet") || 'Bet: ') + '$' + (data.player1Bet || 0);
                    document.getElementById('uni-lobby-p1-bet').removeAttribute('data-i18n');
                    document.getElementById('uni-lobby-p2-bet').textContent = (getLoc("bet") || 'Bet: ') + '$' + (data.player2Bet || 0);
                    document.getElementById('uni-lobby-p2-bet').removeAttribute('data-i18n');
                }

                var p1Status = document.getElementById('uni-lobby-p1-status');
                var p2Status = document.getElementById('uni-lobby-p2-status');

                if (p1Status) {
                    if (data.player1Ready) {
                        p1Status.classList.remove('status-not-ready');
                        p1Status.classList.add('status-ready');
                        p1Status.textContent = getLoc("ready") || 'READY';
                    } else {
                        p1Status.classList.remove('status-ready');
                        p1Status.classList.add('status-not-ready');
                        p1Status.textContent = getLoc("not_ready") || 'NOT READY';
                    }
                }
                
                if (p2Status) {
                    if (data.player2Ready) {
                        p2Status.classList.remove('status-not-ready');
                        p2Status.classList.add('status-ready');
                        p2Status.textContent = getLoc("ready") || 'READY';
                    } else {
                        p2Status.classList.remove('status-ready');
                        p2Status.classList.add('status-not-ready');
                        p2Status.textContent = getLoc("not_ready") || 'NOT READY';
                    }
                }

                document.getElementById('uni-lobby-total-pot-vs').textContent = '$' + (data.totalPot || 0);

                var betInput = document.getElementById('uni-lobby-bet-amount-vs');
                if (document.activeElement !== betInput) {
                    var myBet = 0;
                    if (data.mySide === 'player1') {
                        myBet = data.player1Bet || 0;
                    } else if (data.mySide === 'player2') {
                        myBet = data.player2Bet || 0;
                    }
                    betInput.value = myBet || '';
                }

                var readyBtn = document.getElementById('uni-lobby-ready-toggle-btn');
                if (data.myReady) {
                    readyBtn.classList.add('ready-active');
                    readyBtn.textContent = getLoc("unready") || 'UNREADY';
                } else {
                    readyBtn.classList.remove('ready-active');
                    readyBtn.textContent = getLoc("ready") || 'READY';
                }
            } else {
                lobbyModal.style.display = 'none';

                if (data.bothSeated || data.gameStarted) {
                    waitingDisplay.style.display = 'none';
                } else if (!data.gameStarted) {
                    waitingDisplay.style.display = 'none';
                }

                
                var hud = document.getElementById('jengo-game-hud');
                if (data.gameStarted && data.mySide) {
                    hud.style.display = 'flex';
                    var turnDisplay = document.getElementById('jengo-turn-display');
                    
                    if (data.myTurn) {
                        turnDisplay.textContent = getLoc("your_turn") || "Your Turn";
                        turnDisplay.className = 'turn-indicator turn-active';
                        document.getElementById('jengo-drag-hint-row').style.display = data.mouseActive ? 'flex' : 'none';
                        document.getElementById('jengo-mouse-hint-text').textContent = data.mouseActive ? getLoc("disable_cursor") : getLoc("enable_cursor");
                    } else {
                        turnDisplay.textContent = getLoc("opponent_s_turn") || "Opponent's Turn";
                        turnDisplay.className = 'turn-indicator';
                        document.getElementById('jengo-drag-hint-row').style.display = 'none';
                        document.getElementById('jengo-mouse-hint-text').textContent = getLoc("lock_camera") || "Lock Camera";
                    }
                } else {
                    hud.style.display = 'none';
                }
            }
        }
    });

































})();
})();

;(function() {
$(document).ready(function() {
    let gameActive = false;
    let notes = [];
    let noteId = 0;
    let spawnTimer = null;
    let animationFrame = null;
    
    let currentScore = 0;
    let lastScoreUpdate = 0;
    let lastRodeoPostTime = 0;
    
    let baseFallSpeed = 3.2;
    let baseSpawnInterval = 1600;
    
    let currentFallSpeed = baseFallSpeed;
    let currentSpawnInterval = baseSpawnInterval;
    
    const keys = ["A", "W", "S", "D"];
    
    function syncRodeoScore(force) {
        let now = Date.now();
        if (force || now - lastRodeoPostTime > 1000) {
            lastRodeoPostTime = now;
            $.post(`https://${GetParentResourceName()}/rodeoUpdateScore`, JSON.stringify({ score: currentScore }));
        }
    }
    
    function triggerFail() {
        if (!gameActive) return;
        gameActive = false;
        
        clearInterval(spawnTimer);
        cancelAnimationFrame(animationFrame);
        
        $(".note").remove();
        notes = [];
        
        $("#rodeo-rhythm-game").fadeOut(200);
        
        $.post(`https://${GetParentResourceName()}/rodeoFail`, JSON.stringify({ score: currentScore }));
    }
    
    function spawnNote() {
        if (!gameActive) return;
        
        const randomKey = keys[Math.floor(Math.random() * keys.length)];
        const track = $(`#rodeo-track-${randomKey}`);
        
        const noteEl = $('<div class="note"></div>')
            .addClass(`note-${randomKey}`)
            .text(randomKey);
            
        track.append(noteEl);
        
        notes.push({
            id: noteId++,
            key: randomKey,
            element: noteEl,
            y: -50
        });
    }
    
    function updateGame() {
        if (!gameActive) return;
        
        let now = Date.now();
        if (now - lastScoreUpdate > 100) {
            currentScore += Math.floor(1 * (currentFallSpeed / baseFallSpeed));
            $("#rodeo-score").text(currentScore);
            lastScoreUpdate = now;
            syncRodeoScore(false);
        }
        
        let notesToRemove = [];
        
        for (let i = 0; i < notes.length; i++) {
            let note = notes[i];
            note.y += currentFallSpeed;
            if (note.element && note.element[0]) {
                note.element[0].style.transform = "translate3d(-50%, " + note.y + "px, 0)";
            }
            
            if (note.y > 350) {
                notesToRemove.push(note.id);
                triggerFail();
                return;
            }
        }
        
        notes = notes.filter(n => !notesToRemove.includes(n.id));
        
        if (gameActive) {
            animationFrame = requestAnimationFrame(updateGame);
        }
    }
    
    function startRhythmGame() {
        gameActive = true;
        notes = [];
        noteId = 0;
        currentFallSpeed = baseFallSpeed;
        currentSpawnInterval = baseSpawnInterval;
        currentScore = 0;
        lastScoreUpdate = Date.now();
        lastRodeoPostTime = Date.now();
        
        $("#rodeo-score").text(currentScore);
        $("#rodeo-rhythm-game").fadeIn(200);
        
        function runTimer() {
            if (!gameActive) return;
            spawnNote();
            clearInterval(spawnTimer);
            spawnTimer = setInterval(runTimer, currentSpawnInterval);
        }
        
        spawnTimer = setInterval(runTimer, currentSpawnInterval);
        animationFrame = requestAnimationFrame(updateGame);
    }
    
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        if (data.action === "rodeoShowMinigame") {
            if (data.show) {
                startRhythmGame();
            } else {
                gameActive = false;
                clearInterval(spawnTimer);
                cancelAnimationFrame(animationFrame);
                $(".note").remove();
                notes = [];
                $("#rodeo-rhythm-game").fadeOut(200);
            }
        }
        
        if (data.action === "rodeoUpdateDifficulty" && gameActive) {
            currentFallSpeed = baseFallSpeed * data.multiplier;
            currentSpawnInterval = baseSpawnInterval / Math.max(1.0, (data.multiplier * 0.8));
        }
        
        if (data.action === "rodeoOpenStatsUI") {
            let listHtml = "";
            let leaderboard = data.leaderboard || [];
            let myCitizenId = data.myCitizenId;
            
            leaderboard.forEach(function(row) {
                let badgeContent = "";
                if (row.rank === 1) {
                    badgeContent = `<span class="leaderboard-rank-badge rank-1">1</span>`;
                } else if (row.rank === 2) {
                    badgeContent = `<span class="leaderboard-rank-badge rank-2">2</span>`;
                } else if (row.rank === 3) {
                    badgeContent = `<span class="leaderboard-rank-badge rank-3">3</span>`;
                } else {
                    badgeContent = `<span class="leaderboard-rank-badge rank-other">${row.rank}</span>`;
                }
                
                let isSelf = (row.citizenid === myCitizenId);
                let rowClass = isSelf ? "class='self-row'" : "";
                
                let avatarUrl = row.avatar && row.avatar !== "" ? row.avatar : "https://files.catbox.moe/4kd7sv.jpg";
                
                listHtml += `
                    <tr ${rowClass}>
                        <td>${badgeContent}</td>
                        <td>
                            <div class="leaderboard-player-cell">
                                <div class="leaderboard-player-avatar" style="background-image: url('${avatarUrl}');"></div>
                                <span class="leaderboard-player-name">${row.name}</span>
                            </div>
                        </td>
                        <td>${row.totalRides || 0}</td>
                        <td><span class="rodeo-stats-high-score">${row.highScore || 0}</span></td>
                    </tr>
                `;
            });
            
            $("#rodeo-rodeo-stats-list").html(listHtml);
            $("#rodeo-rodeo-stats-modal").fadeIn(250).css("display", "flex");
        }
    });
    
    $(window).on("keydown", function(e) {
        if (!gameActive) return;
        
        if (e.which === 70 || e.which === 27) {
            gameActive = false;
            clearInterval(spawnTimer);
            cancelAnimationFrame(animationFrame);
            $(".note").remove();
            notes = [];
            $("#rodeo-rhythm-game").fadeOut(200);
            $.post(`https://${GetParentResourceName()}/rodeoExit`, JSON.stringify({ score: currentScore }));
            return;
        }
        
        let pressedKey = "";
        if (e.which === 65) pressedKey = "A";
        else if (e.which === 87) pressedKey = "W";
        else if (e.which === 83) pressedKey = "S";
        else if (e.which === 68) pressedKey = "D";
        
        if (pressedKey !== "") {
            const trackEl = $(`#rodeo-track-${pressedKey}`);
            trackEl.addClass("hit-active");
            setTimeout(() => {
                trackEl.removeClass("hit-active");
            }, 100);
            
            const trackNotes = notes.filter(n => n.key === pressedKey);
            if (trackNotes.length > 0) {
                let closestNote = trackNotes[0];
                let noteCenter = closestNote.y + 22;
                let targetCenter = 305;
                
                if (Math.abs(noteCenter - targetCenter) <= 28) {
                    closestNote.element.remove();
                    notes = notes.filter(n => n.id !== closestNote.id);
                    currentScore += 100;
                    $("#rodeo-score").text(currentScore);
                    syncRodeoScore(false);
                } else {
                    triggerFail();
                }
            } else {
                triggerFail();
            }
        }
    });
    $(document).on("click", "#rodeo-close-rodeo-stats-btn", function() {
        $.post(`https://${GetParentResourceName()}/rodeoStatsClose`, JSON.stringify({}));
        $("#rodeo-rodeo-stats-modal").fadeOut(150);
    });
});

})();

;(function() {
$(document).ready(function() {
    let lastOpenTime = 0;
    let isReady = false;
    let gameTimerInterval = null;
    let clientTimeSyncDiff = 0;
    let currentTurnStartTime = 0;
    let isGameRolling = false;
    let isAwaitingPurchase = false;
    let isAwaitingJailAction = false;
    let currentDebtAmount = 0;
    let currentWalletAmount = 0;
    let debtTableId = null;
    let debtProperties = [];
    let gameEndTime = 0;

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "santospolyShowUI") {
            $("#santospoly-game-ui").show();
            let html = "";
            if (data.type === "otur") {
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_sit") || "Sit"}</span><span class="key-badge">E</span></div>`;
            } else if (data.type === "host_start_lobby") {
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_start") || "Start Lobby"}</span><span class="key-badge">G</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "kalk_kamera") {
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "my_turn") {
                html += `<div class="state-row"><span class="state-label" style="color: #40C057; font-weight: bold;">${getLoc("sp_control_roll") || "Your Turn - Roll Dice"}</span><span class="key-badge">${getLoc("sp_control_lclick") || "LEFT CLICK"}</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "rolling_dice") {
                html += `<div class="state-row"><span class="state-label" style="color: #FFD43B; font-weight: bold;">${getLoc("sp_control_rolling") || "Rolling Dice..."}</span><span class="key-badge">${getLoc("sp_control_wait") || "WAIT"}</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "chance_draw") {
                html += `<div class="state-row"><span class="state-label" style="color: #FF922B; font-weight: bold;">${getLoc("sp_control_chance") || "Draw Chance Card - Click Deck"}</span><span class="key-badge">${getLoc("sp_control_lclick") || "LEFT CLICK"}</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "chest_draw") {
                html += `<div class="state-row"><span class="state-label" style="color: #339AF0; font-weight: bold;">${getLoc("sp_control_chest") || "Draw Chest Card - Click Deck"}</span><span class="key-badge">${getLoc("sp_control_lclick") || "LEFT CLICK"}</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            } else if (data.type === "other_turn") {
                html += `<div class="state-row"><span class="state-label" style="color: #FFD43B;">${getLoc("sp_control_turn") || "Turn:"} ${data.playerName}</span><span class="key-badge">${getLoc("sp_control_wait") || "WAIT"}</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_cam") || "Camera"}</span><span class="key-badge">V</span></div>`;
                html += `<div class="state-row"><span class="state-label">${getLoc("sp_control_stand") || "Stand Up"}</span><span class="key-badge">BACKSPACE</span></div>`;
            }
            $("#santospoly-controls-container").html(html);
        } else if (data.action === "playSound") {
            if (data.file) {
                let audio = new Audio(`audio/${data.file}.mp3`);
                audio.volume = data.volume || 1.0;
                audio.play().catch(() => {});
            }
        } else if (data.action === "hideUI") {
            $("#santospoly-game-ui").hide();
            $("#santospoly-game-info-ui").hide();
            $("#santospoly-game-countdown-ui").hide();
            gameEndTime = 0;
        } else if (data.action === "showLobby") {
            if (data.active) {
                lastOpenTime = Date.now();
                $("#universal-lobby-modal").fadeIn(200);
                $("#santospoly-game-info-ui").fadeOut(200);
                if (data.data && data.data.players) {
                    renderLobbyPlayers(data.data.players);
                }
                if (data.data && data.data.timeLimit !== undefined) {
                    $("#uni-lobby-time-select-input").val(data.data.timeLimit);
                }
                if (data.data && data.myId && data.data.owner == data.myId) {
                    $("#uni-lobby-time-select-input").prop("disabled", false);
                } else {
                    $("#uni-lobby-time-select-input").prop("disabled", true);
                }
                if (typeof data.myReady !== 'undefined') {
                    isReady = data.myReady;
                    let btn = $("#uni-lobby-ready-toggle-btn");
                    if (isReady) {
                        btn.addClass("ready-active").text(getLoc("unready") || "UNREADY");
                    } else {
                        btn.removeClass("ready-active").text(getLoc("ready") || "READY");
                    }
                }
            } else {
                $("#universal-lobby-modal").fadeOut(200);
                isReady = false;
                $("#uni-lobby-ready-toggle-btn").removeClass("ready-active").text(getLoc("ready") || "READY");
            }
        } else if (data.action === "santospolyUpdateLobby") {
            if (data.data) {
                if (data.data.serverTime) {
                    clientTimeSyncDiff = Date.now() - (data.data.serverTime * 1000);
                }
                if (data.data.turnStartTime) {
                    currentTurnStartTime = data.data.turnStartTime;
                }
                isGameRolling = data.data.isRolling;
                isAwaitingPurchase = data.data.awaitingPurchase || false;
                isAwaitingJailAction = data.data.awaitingJailAction || false;
                gameEndTime = data.data.gameEndTime || 0;
                
                if (data.data.timeLimit !== undefined) {
                    $("#uni-lobby-time-select-input").val(data.data.timeLimit);
                }
                
                if (data.data.owner == data.myId) {
                    $("#uni-lobby-time-select-input").prop("disabled", false);
                } else {
                    $("#uni-lobby-time-select-input").prop("disabled", true);
                }
                
                if (data.data.players) {
                    if (data.data.inLobby) {
                        renderLobbyPlayers(data.data.players);
                    } else if (data.data.gameStarted) {
                        renderGamePlayers(data.data.players, data.data.inactivePlayers, data.data.currentTurnChair);
                    }
                }
            }
            if (typeof data.myReady !== 'undefined') {
                isReady = data.myReady;
                let btn = $("#uni-lobby-ready-toggle-btn");
                if (isReady) {
                    btn.addClass("ready-active").text(getLoc("unready") || "UNREADY");
                } else {
                    btn.removeClass("ready-active").text(getLoc("ready") || "READY");
                }
            }
        } else if (data.action === "closePropertyCardForce") {
            $("#santospoly-property-card-modal").fadeOut(200);
        } else if (data.action === "showJailPrompt") {
            $("#santospoly-jail-turns-count").text(data.jailTurns || 3);
            if (data.jailCards > 0) {
                $("#santospoly-jail-card-btn").prop('disabled', false).css('opacity', 1);
            } else {
                $("#santospoly-jail-card-btn").prop('disabled', true).css('opacity', 0.5);
            }
            $("#santospoly-jail-card-modal").fadeIn(200);
        } else if (data.action === "closeJailPromptForce") {
            $("#santospoly-jail-card-modal").fadeOut(200);
        } else if (data.action === "closeChancePromptForce") {
            $("#santospoly-chance-reveal-modal").fadeOut(200);
            $("#santospoly-chance-flipper").removeClass("flipped");
        } else if (data.action === "closeChestPromptForce") {
            $("#santospoly-chest-reveal-modal").fadeOut(200);
            $("#santospoly-chest-flipper").removeClass("flipped");
        } else if (data.action === "showChanceReveal") {
            $("#santospoly-chance-card-title-text").text(data.cardTitle);
            $("#santospoly-chance-card-desc-text").text(data.cardDesc);
            $("#santospoly-chance-card-result-text").text(data.extraMsg);
            $("#santospoly-chance-flipper").removeClass("flipped");
            $("#santospoly-chance-reveal-modal").fadeIn(200, function() {
                setTimeout(() => {
                    $("#santospoly-chance-flipper").addClass("flipped");
                }, 400);
            });
            setTimeout(() => {
                $("#santospoly-chance-reveal-modal").fadeOut(300, function() {
                    $("#santospoly-chance-flipper").removeClass("flipped");
                });
            }, 4500);
        } else if (data.action === "showChestReveal") {
            $("#santospoly-chest-card-title-text").text(data.cardTitle);
            $("#santospoly-chest-card-desc-text").text(data.cardDesc);
            $("#santospoly-chest-card-result-text").text(data.extraMsg);
            $("#santospoly-chest-flipper").removeClass("flipped");
            $("#santospoly-chest-reveal-modal").fadeIn(200, function() {
                setTimeout(() => {
                    $("#santospoly-chest-flipper").addClass("flipped");
                }, 400);
            });
            setTimeout(() => {
                $("#santospoly-chest-reveal-modal").fadeOut(300, function() {
                    $("#santospoly-chest-flipper").removeClass("flipped");
                });
            }, 4500);
        } else if (data.action === "showStartAnnouncement") {
            showSantosPolyAnnouncement("start", data.title || "START BONUS", data.message || "", 3500);
        } else if (data.action === "showReverseAnnouncement") {
            showSantosPolyAnnouncement("reverse", data.title || "DIRECTION REVERSED", data.message || "", 3500);
        } else if (data.action === "showJailAnnouncement") {
            var jMsg = data.message || (data.playerName ? (data.playerName + " is in jail!") : "In Jail!");
            showSantosPolyAnnouncement("jail", data.title || "JAIL", jMsg, 3500);
        } else if (data.action === "showRentAnnouncement") {
            showSantosPolyAnnouncement(data.type || "rent", data.title, data.message || "", 3500);
        } else if (data.action === "showWinAnnouncement") {
            showSantosPolyAnnouncement("win", data.title || "VICTORY", data.message || "", 5000);
        } else if (data.action === "showAnnouncement") {
            showSantosPolyAnnouncement(data.type || "info", data.title, data.message || "", data.duration || 3500);
        } else if (data.action === "showDebtUI") {
            setupDebtUI(data);
        } else if (data.action === "updateDebtProperties") {
            updateDebtPropertiesList(data.properties, data.money);
                } else if (data.action === "xoxUpdate") {
            if (data.showLobby) {
                $("#uni-lobby-p1-name").text(data.xName || getLoc("waiting"));
                if (data.xAvatar && data.xAvatar !== "") {
                    $("#uni-lobby-p1-avatar").css("background-image", "url('" + data.xAvatar + "')");
                } else {
                    $("#uni-lobby-p1-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p1-bet").text((getLoc("bet") || "Bet") + ": $" + (data.xBet || 0));
                if (data.xReady) {
                    $("#uni-lobby-p1-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p1-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                $("#uni-lobby-p2-name").text(data.oName || getLoc("waiting"));
                if (data.oAvatar && data.oAvatar !== "") {
                    $("#uni-lobby-p2-avatar").css("background-image", "url('" + data.oAvatar + "')");
                } else {
                    $("#uni-lobby-p2-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p2-bet").text((getLoc("bet") || "Bet") + ": $" + (data.oBet || 0));
                if (data.oReady) {
                    $("#uni-lobby-p2-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready");
                } else {
                    $("#uni-lobby-p2-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready");
                }

                let totalPot = (data.xBet || 0) + (data.oBet || 0);
                $("#uni-lobby-total-pot-vs").text("$" + totalPot);

                if (typeof data.myReady !== 'undefined') {
                    isReady = data.myReady;
                    let btn = $("#uni-lobby-ready-toggle-btn");
                    if (isReady) {
                        btn.addClass("ready-active").text(getLoc("unready") || "UNREADY");
                    } else {
                        btn.removeClass("ready-active").text(getLoc("ready") || "READY");
                    }
                }
                $("#universal-lobby-modal").fadeIn(250).css("display", "flex");
            } else {
                $("#universal-lobby-modal").fadeOut(150);
            }
        } else if (data.action === "closeDebtUI") {
            $("#santospoly-debt-modal").fadeOut(200);
        } else if (data.action === "hideLobby") {
            $("#universal-lobby-modal").fadeOut(200);
            $("#santospoly-game-info-ui").fadeIn(200);
        } else if (data.action === "hideGameInfo") {
            $("#santospoly-game-info-ui").fadeOut(200);
        } else if (data.action === "showCursorOverlay") {
            $("#santospoly-cursor-overlay").css("cursor", "default").show();
        } else if (data.action === "hideCursorOverlay") {
            $("#santospoly-cursor-overlay").hide();
        } else if (data.action === "setCursor") {
            $("#santospoly-cursor-overlay").css("cursor", data.type || "default");
        } else if (data.action === "showLeavePrompt") {
            $("#santospoly-leave-prompt-modal").fadeIn(200);
        } else if (data.action === "closeTakeoverPromptForce") {
            $("#santospoly-takeover-modal").fadeOut(200);
        } else if (data.action === "santospolyResetAll") {
            $("#santospoly-property-card-modal").fadeOut(200);
            $("#santospoly-jail-card-modal").fadeOut(200);
            $("#santospoly-chance-reveal-modal").fadeOut(200);
            $("#santospoly-chest-reveal-modal").fadeOut(200);
            $("#santospoly-leave-prompt-modal").fadeOut(200);
            $("#santospoly-takeover-modal").fadeOut(200);
            $("#santospoly-debt-modal").fadeOut(200);
            $("#santospoly-jail-announcement").hide();
            $("#santospoly-rent-announcement").hide();
            $("#santospoly-win-announcement").hide();
            $("#santospoly-game-ui").hide();
            $("#santospoly-game-info-ui").hide();
            $("#santospoly-game-countdown-ui").hide();
            $("#santospoly-cursor-overlay").hide();
            gameEndTime = 0;
        } else if (data.action === "showTakeoverPrompt") {
            let rData = data.regionData;
            currentRegionId = data.regionId;
            let propName = rData.name || getLoc("this_property") || "This property";
            let descText = (getLoc("takeover_prompt_desc") || "Do you want to buy %s1 from %s2 for M%s3?")
                .replace("%s1", propName)
                .replace("%s2", data.ownerName)
                .replace("%s3", data.price);
            $("#santospoly-takeover-desc").text(descText);
            $("#santospoly-takeover-modal").fadeIn(200);
        } else if (data.action === "santospolyShowPropertyCard" || data.action === "showPurchasePrompt") {
            let rData = data.regionData;
            currentRegionId = data.regionId;
            $("#santospoly-pc-name").text(rData.name || "UNKNOWN");
            $("#santospoly-pc-header-box").css("background-color", rData.colorHex || "#FFFFFF");
            
            $("#pc-owner-box").remove();
            if (data.ownerName) {
                const chairColors = {
                    "1": "#ff4d4d", 
                    "2": "#4da6ff", 
                    "3": "#4dff4d", 
                    "4": "#ffff4d"  
                };
                let pColor = chairColors[data.ownerChair] || "#ffffff";
                let ownerHtml = `<div id="pc-owner-box" style="margin-top: 0.6vh; margin-bottom: 1.2vh; padding: 0.6vh 1vh; background: linear-gradient(135deg, rgba(28, 20, 15, 0.95), rgba(14, 10, 8, 0.95)); border: 0.15vh solid ${pColor}; border-radius: 0.6vh; text-align: center; font-family: 'Cinzel', serif; font-weight: 800; font-size: 1.2vh; color: #f5ebd7; box-shadow: 0 0.4vh 1vh rgba(0,0,0,0.4);">
                    ${getLoc("property_owner") || "Property Owner:"} <span style="color: ${pColor}; text-shadow: 0 0 0.8vh ${pColor};">${data.ownerName}</span>
                </div>`;
                $("#santospoly-pc-header-box").after(ownerHtml);
            }
            
            if (rData.isRailroad) {
                $(".pc-row").hide();
                $("#santospoly-pc-hotel").hide();
                $("#santospoly-pc-house-cost").hide();
                $("#santospoly-pc-hotel-cost").hide();
                $("#santospoly-pc-rent").text((getLoc("rent_m") || "RENT M%s").replace("%s", rData.rent || 25));
                $("#santospoly-pc-mortgage").text((getLoc("mortgage_value_m") || "Mortgage Value M%s").replace("%s", rData.mortgage || 100));
                $(".pc-footer").text(getLoc("railroad_desc") || "If 2 Railroads are owned, rent is M50. If 3, M100. If 4, M200.");
            } else if (rData.isUtility) {
                $(".pc-row").hide();
                $("#santospoly-pc-hotel").hide();
                $("#santospoly-pc-house-cost").hide();
                $("#santospoly-pc-hotel-cost").hide();
                $("#santospoly-pc-rent").text(getLoc("utility") || "Utility");
                $("#santospoly-pc-mortgage").text((getLoc("mortgage_value_m") || "Mortgage Value M%s").replace("%s", rData.mortgage || 75));
                $(".pc-footer").text(getLoc("utility_desc") || "If one Utility is owned, rent is 4x amount shown on dice. If both are owned, rent is 10x amount shown on dice.");
            } else {
                $(".pc-row").show();
                $("#santospoly-pc-hotel").show();
                $("#santospoly-pc-house-cost").show();
                $("#santospoly-pc-hotel-cost").show();
                $("#santospoly-pc-rent").text((getLoc("rent_m") || "RENT M%s").replace("%s", rData.rent || 0));
                $("#santospoly-pc-h1").text("M " + (rData.house1 || 0) + ".");
                $("#santospoly-pc-h2").text((rData.house2 || 0) + ".");
                $("#santospoly-pc-h3").text((rData.house3 || 0) + ".");
                $("#santospoly-pc-h4").text((rData.house4 || 0) + ".");
                $("#santospoly-pc-hotel").text((getLoc("hotel") || "With HOTEL M%s").replace("%s", rData.hotel || 0));
                $("#santospoly-pc-mortgage").text((getLoc("mortgage_value_m") || "Mortgage Value M%s").replace("%s", rData.mortgage || 0));
                $("#santospoly-pc-house-cost").text((getLoc("houses_cost_each") || "Houses cost M%s each").replace("%s", rData.houseCost || 0));
                $("#santospoly-pc-hotel-cost").text((getLoc("hotels_cost_plus_houses") || "Hotels, M%s plus 4 houses").replace("%s", rData.houseCost || 0));
                $(".pc-footer").text(getLoc("lots_color_group_desc") || "If a player owns ALL the Lots of any Color-Group, the rent is Doubled on Unimproved Lots in that group.");
                
                
                $(".pc-row, #santospoly-pc-hotel").css("font-weight", "normal").css("color", "inherit");
                if (data.currentHouses === 1) $("#santospoly-pc-h1").parent().css("font-weight", "bold").css("color", "#51CF66");
                if (data.currentHouses === 2) $("#santospoly-pc-h2").parent().css("font-weight", "bold").css("color", "#51CF66");
                if (data.currentHouses === 3) $("#santospoly-pc-h3").parent().css("font-weight", "bold").css("color", "#51CF66");
                if (data.currentHouses === 4) $("#santospoly-pc-h4").parent().css("font-weight", "bold").css("color", "#51CF66");
                if (data.currentHouses === 5) $("#santospoly-pc-hotel").css("font-weight", "bold").css("color", "#51CF66");
            }

            $("#santospoly-pc-purchase-actions").hide();
            $("#santospoly-pc-build-actions").hide();
            $("#santospoly-pc-close-btn").show();

            if (data.action === "showPurchasePrompt") {
                $("#santospoly-pc-close-btn").hide();
                $("#santospoly-pc-purchase-actions").css('display', 'flex');
                
                
                $("#santospoly-chk-buy-flag").prop('checked', true).prop('disabled', false);
                $("#santospoly-chk-buy-h1, #santospoly-chk-buy-h2, #santospoly-chk-buy-h3, #santospoly-chk-buy-h4").prop('checked', false).prop('disabled', false);
                
                
                $("#santospoly-price-flag").text("M" + (rData.price || 0));
                let hCost = rData.houseCost || 0;
                $("#santospoly-price-h1, #santospoly-price-h2, #santospoly-price-h3, #santospoly-price-h4").text("M" + hCost);
                
                if (rData.isUtility || rData.isRailroad) {
                    $(".house-opt").hide();
                } else {
                    $(".house-opt").show();
                    if (data.laps === 0) {
                        $("#santospoly-lbl-buy-h4").css('opacity', 0.5);
                        $("#santospoly-chk-buy-h4").prop('disabled', true);
                    } else {
                        $("#santospoly-lbl-buy-h4").css('opacity', 1);
                    }
                }
                
                updatePurchaseTotal(rData.price || 0, hCost);
                
                
                $("#santospoly-chk-buy-flag, #santospoly-chk-buy-h1, #santospoly-chk-buy-h2, #santospoly-chk-buy-h3, #santospoly-chk-buy-h4").off('change').on('change', function() {
                    let id = $(this).attr('id');
                    let isChecked = $(this).is(':checked');

                    if (isChecked) {
                        if (id === "santospoly-chk-buy-h4") {
                            $("#santospoly-chk-buy-h3, #santospoly-chk-buy-h2, #santospoly-chk-buy-h1, #santospoly-chk-buy-flag").prop('checked', true);
                        } else if (id === "santospoly-chk-buy-h3") {
                            $("#santospoly-chk-buy-h2, #santospoly-chk-buy-h1, #santospoly-chk-buy-flag").prop('checked', true);
                        } else if (id === "santospoly-chk-buy-h2") {
                            $("#santospoly-chk-buy-h1, #santospoly-chk-buy-flag").prop('checked', true);
                        } else if (id === "santospoly-chk-buy-h1") {
                            $("#santospoly-chk-buy-flag").prop('checked', true);
                        }
                    } else {
                        if (id === "santospoly-chk-buy-flag") {
                            $("#santospoly-chk-buy-h1, #santospoly-chk-buy-h2, #santospoly-chk-buy-h3, #santospoly-chk-buy-h4").prop('checked', false);
                        } else if (id === "santospoly-chk-buy-h1") {
                            $("#santospoly-chk-buy-h2, #santospoly-chk-buy-h3, #santospoly-chk-buy-h4").prop('checked', false);
                        } else if (id === "santospoly-chk-buy-h2") {
                            $("#santospoly-chk-buy-h3, #santospoly-chk-buy-h4").prop('checked', false);
                        } else if (id === "santospoly-chk-buy-h3") {
                            $("#santospoly-chk-buy-h4").prop('checked', false);
                        }
                    }
                    updatePurchaseTotal(rData.price || 0, hCost);
                });
                
                function updatePurchaseTotal(pPrice, hPrice) {
                    let t = 0;
                    if ($("#santospoly-chk-buy-flag").is(':checked')) t += pPrice;
                    if ($("#santospoly-chk-buy-h1").is(':checked')) t += hPrice;
                    if ($("#santospoly-chk-buy-h2").is(':checked')) t += hPrice;
                    if ($("#santospoly-chk-buy-h3").is(':checked')) t += hPrice;
                    if ($("#santospoly-chk-buy-h4").is(':checked')) t += hPrice;
                    $("#santospoly-purchase-total-price").text("M" + t);
                    
                    if (t === 0) {
                        $("#santospoly-pc-buy-selected-btn").prop('disabled', true).css('opacity', 0.5);
                    } else {
                        $("#santospoly-pc-buy-selected-btn").prop('disabled', false).css('opacity', 1);
                    }
                }
            } else if (data.action === "santospolyShowPropertyCard") {
                if (data.isOwner && data.isMyTurn && !rData.isRailroad && !rData.isUtility) {
                    let maxHousesAllowed = (data.laps === 0) ? 3 : 5;
                    if (data.currentHouses < maxHousesAllowed) {
                        $("#santospoly-pc-build-actions").css('display', 'flex');
                        $("#santospoly-pc-build-price").text(rData.houseCost || 0);
                        let nextHouse = (data.currentHouses || 0) + 1;
                        if (nextHouse === 5) {
                            $("#santospoly-pc-build-text").text(getLoc("hotel") || "Hotel");
                        } else {
                            let suffix = "th";
                            if (nextHouse === 1) suffix = "st";
                            if (nextHouse === 2) suffix = "nd";
                            if (nextHouse === 3) suffix = "rd";
                            $("#santospoly-pc-build-text").text(nextHouse + suffix + " " + (getLoc("house") || "House"));
                        }
                    }
                }
            }

            $("#santospoly-property-card-modal").css('display', 'flex').hide().fadeIn(200);
        }
    });

    function showSantosPolyAnnouncement(type, title, message, duration) {
        duration = duration || 3500;
        var icon = "📢";
        var themeClass = "info-theme";
        var defaultTitle = "ANNOUNCEMENT";

        if (type === "start") {
            icon = "🏁";
            themeClass = "start-theme";
            defaultTitle = getLoc("sp_ann_start") || "START BONUS";
        } else if (type === "reverse") {
            icon = "🔄";
            themeClass = "reverse-theme";
            defaultTitle = getLoc("sp_ann_reverse") || "DIRECTION REVERSED";
        } else if (type === "rent") {
            icon = "💰";
            themeClass = "rent-theme";
            defaultTitle = getLoc("sp_ann_rent") || "RENT PAID";
        } else if (type === "jail") {
            icon = "⛓️";
            themeClass = "jail-theme";
            defaultTitle = getLoc("sp_ann_jail") || "JAIL";
        } else if (type === "fine" || type === "tax") {
            icon = "⚖️";
            themeClass = type === "tax" ? "tax-theme" : "fine-theme";
            defaultTitle = type === "tax" ? (getLoc("sp_ann_tax") || "LUXURY TAX") : (getLoc("sp_ann_fine") || "LSPD FINE");
        } else if (type === "win") {
            icon = "🏆";
            themeClass = "win-theme";
            defaultTitle = getLoc("sp_ann_victory") || "VICTORY";
        } else if (type === "timeout") {
            icon = "⏱️";
            themeClass = "timeout-theme";
            defaultTitle = getLoc("sp_ann_timeout") || "TIME OUT";
        }

        var finalTitle = title || defaultTitle;
        var toastId = "sp_toast_" + Date.now() + "_" + Math.floor(Math.random() * 10000);
        var html = '<div id="' + toastId + '" class="santospoly-toast-item">' +
            '<div class="santospoly-announcement-box ' + themeClass + '">' +
                '<div class="santospoly-announcement-icon-badge">' +
                    '<span class="badge-icon">' + icon + '</span>' +
                '</div>' +
                '<div class="santospoly-announcement-content">' +
                    '<div class="santospoly-announcement-title">' + finalTitle + '</div>' +
                    '<div class="santospoly-announcement-message">' + (message || "") + '</div>' +
                '</div>' +
            '</div>' +
        '</div>';

        var $toast = $(html);
        $("#santospoly-announcements-container").append($toast);

        setTimeout(function() {
            $toast.addClass("toast-leaving");
            setTimeout(function() {
                $toast.remove();
            }, 260);
        }, duration);
    }

    $("#santospoly-pc-close-btn").click(function() {
        $("#santospoly-property-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyclosePropertyCard`, JSON.stringify({}));
    });

    $("#santospoly-jail-roll-btn").click(function() {
        if ($(this).prop('disabled')) return;
        $("#santospoly-jail-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyjailRollDice`, JSON.stringify({}));
    });

    $("#santospoly-jail-pay-btn").click(function() {
        if ($(this).prop('disabled')) return;
        $("#santospoly-jail-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyjailPayFine`, JSON.stringify({}));
    });

    $("#santospoly-jail-card-btn").click(function() {
        if ($(this).prop('disabled')) return;
        $("#santospoly-jail-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyjailUseCard`, JSON.stringify({}));
    });

    $("#santospoly-pc-buy-selected-btn").click(function() {
        if (!$("#santospoly-chk-buy-flag").is(':checked')) return; 
        let houseCount = 0;
        if ($("#santospoly-chk-buy-h1").is(':checked')) houseCount++;
        if ($("#santospoly-chk-buy-h2").is(':checked')) houseCount++;
        if ($("#santospoly-chk-buy-h3").is(':checked')) houseCount++;
        if ($("#santospoly-chk-buy-h4").is(':checked')) houseCount++;
        
        $("#santospoly-property-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolybuyProperty`, JSON.stringify({houseCount: houseCount}));
    });

    $("#santospoly-pc-skip-btn").click(function() {
        $("#santospoly-property-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyskipProperty`, JSON.stringify({}));
    });

    $("#santospoly-pc-build-house-btn").click(function() {
        $("#santospoly-property-card-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolybuyHouse`, JSON.stringify({regionId: currentRegionId}));
    });

    $("#santospoly-takeover-buy-btn").click(function() {
        $("#santospoly-takeover-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolytakeoverBuy`, JSON.stringify({}));
    });

    $("#santospoly-takeover-skip-btn").click(function() {
        $("#santospoly-takeover-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolytakeoverSkip`, JSON.stringify({}));
    });

    function renderGamePlayers(players, inactivePlayers, currentTurnChair) {
        let container = $("#santospoly-game-info-ui");
        container.empty();
        
        if (players) {
            Object.keys(players).forEach(chairId => {
                let player = players[chairId];
                if (!player) return;
                
                let isActive = (parseInt(chairId) === parseInt(currentTurnChair));
                let activeClass = isActive ? "active-turn" : "";
                
                let timerHtml = "";
                if (isActive && !isGameRolling) {
                    let maxTime = 21;
                    if (isAwaitingPurchase) {
                        maxTime = 20;
                    } else if (isAwaitingJailAction) {
                        maxTime = 10;
                    }
                    timerHtml = `<div class="gpc-timer" id="turn-timer-${chairId}">${getLoc("time_left") || "Time Left"}: ${maxTime}s</div>`;
                } else if (isActive && isGameRolling) {
                    timerHtml = `<div class="gpc-timer" style="color: #FFD43B;">${getLoc("rolling") || "Rolling..."}</div>`;
                }
                
                let html = `
                    <div class="game-player-card ${activeClass}">
                        <div class="gpc-avatar" style="background-image: url('${player.avatar || 'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png'}');"></div>
                        <div class="gpc-info">
                            <div class="gsantospoly-pc-name">${player.name}</div>
                            <div class="gpc-money">$${player.money || 0}</div>
                            ${timerHtml}
                        </div>
                    </div>
                `;
                container.append(html);
            });
        }
        
        if (inactivePlayers) {
            Object.keys(inactivePlayers).forEach(chairId => {
                let player = inactivePlayers[chairId];
                if (!player) return;
                
                let html = `
                    <div class="game-player-card" style="opacity: 0.5; filter: grayscale(100%);">
                        <div class="gpc-avatar" style="background-image: url('${player.avatar || 'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png'}');"></div>
                        <div class="gpc-info">
                            <div class="gsantospoly-pc-name" style="text-decoration: line-through;">${player.name}</div>
                            <div class="gpc-money" style="color: #ff4d4d; font-weight: bold; font-size: 14px;">${player.statusStr || (getLoc("bankrupt") || 'BANKRUPT')}</div>
                        </div>
                    </div>
                `;
                container.append(html);
            });
        }
    }

    if (gameTimerInterval) clearInterval(gameTimerInterval);
    gameTimerInterval = setInterval(() => {
        if (currentTurnStartTime > 0 && !isGameRolling) {
            let nowServer = Math.floor((Date.now() - clientTimeSyncDiff) / 1000);
            let diff = nowServer - currentTurnStartTime;
            let maxTime = 21;
            if (isAwaitingPurchase) {
                maxTime = 20;
            } else if (isAwaitingJailAction) {
                maxTime = 10;
            }
            let remain = Math.max(0, maxTime - diff);
            $(".gpc-timer").text((getLoc("time_left") || "Time Left") + `: ${remain}s`);
        }
        
        if (gameEndTime > 0) {
            let nowServer = Math.floor((Date.now() - clientTimeSyncDiff) / 1000);
            let remainGame = Math.max(0, gameEndTime - nowServer);
            if (remainGame > 0) {
                let m = Math.floor(remainGame / 60);
                let s = remainGame % 60;
                $("#santospoly-game-countdown-text").text(`${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`);
                $("#santospoly-game-countdown-ui").show();
            } else {
                $("#santospoly-game-countdown-text").text(`00:00`);
            }
        } else {
            $("#santospoly-game-countdown-ui").hide();
        }
    }, 1000);

    function renderLobbyPlayers(players) {
        let container = $("#uni-lobby-players-list");
        container.empty();
        
        let totalPot = 0;
        
        Object.values(players).forEach(player => {
            if (!player) return;
            totalPot += (player.bet || 0);
            
            let statusClass = player.ready ? "status-ready" : "status-not-ready";
            let statusText = player.ready ? (getLoc("ready") || "READY") : (getLoc("not_ready") || "NOT READY");
            
            let html = `
                <div class="lobby-player-col">
                    <div class="lobby-avatar" style="background-image: url('${player.avatar || 'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png'}');"></div>
                    <div class="lobby-player-name">${player.name}</div>
                    <div class="lobby-player-bet">${getLoc("bet") || "Bet"}: $${player.bet || 0}</div>
                    <div class="lobby-ready-status ${statusClass}">${statusText}</div>
                </div>
            `;
            container.append(html);
        });
        
        $("#uni-lobby-total-pot-vs, #uni-lobby-total-pot-multi").text("$" + totalPot);
    }

    

    
    $(document).keyup(function(e) {
        if (e.keyCode === 27) { 
            if ($("#global-leaderboard-modal").is(":visible")) {
                $("#close-global-leaderboard-btn").click();
                return;
            }
            if ($("#rodeo-rhythm-game").is(":visible")) {
                return;
            }
            if ($("#admin-menu-modal").is(":visible")) {
                $('#admin-close-btn').click();
                return;
            }
            if ($("#universal-lobby-modal").is(":visible")) {
                $("#uni-lobby-exit-btn").click();
                return;
            }
            
            if (window.currentLobbyGameName === 'santosPoly') {
                $("#santospoly-leave-prompt-modal").fadeIn(200);
                $.post(`https://${GetParentResourceName()}/santospolyrequestLeavePrompt`, JSON.stringify({}));
            } else if (window.currentLobbyGameName === 'checkers') {
                $("#checkers-leave-prompt-modal").fadeIn(200);
            } else if (window.currentLobbyGameName === 'chess') {
                $("#chess-leave-prompt-modal").fadeIn(200);
            } else if (window.currentLobbyGameName === 'connect4') {
                $("#connect4-leave-prompt-modal").fadeIn(200);
            } else if (window.currentLobbyGameName === 'xox') {
                $("#xox-leave-prompt-modal").fadeIn(200);
            } else if (window.currentLobbyGameName === 'eno') {
                $("#eno-leave-prompt-modal").fadeIn(200);
            } else if (window.currentLobbyGameName === 'jengo') {
                $("#jengo-leave-prompt-modal").fadeIn(200);
            }
        } else if (e.keyCode === 71) { 
            if (Date.now() - lastOpenTime > 500) {
                $.post(`https://${GetParentResourceName()}/santospolycloseLobby`, JSON.stringify({}));
            }
        }
    });

    function setupDebtUI(data) {
        debtTableId = data.tableId;
        currentDebtAmount = data.amount;
        currentWalletAmount = data.money;
        debtProperties = data.properties || [];

        $("#santospoly-debt-amount-text").text("M" + currentDebtAmount);
        $("#santospoly-debt-wallet-text").text("M" + currentWalletAmount);
        
        let reason = getLoc("debt_payment") || "Debt Payment";
        if (data.paymentType === "rent") {
            reason = (getLoc("must_pay_rent_for") || "You must pay rent for %s").replace("%s", data.cardTitle || "Property");
        } else if (data.paymentType === "fine") {
            reason = getLoc("must_pay_lspd_fine") || "You must pay an LSPD fine.";
        } else if (data.paymentType === "card") {
            reason = `${data.cardTitle || (getLoc("chance_card") || "Chance Card")}: ${data.cardDesc || (getLoc("debt_payment") || "Debt payment")}`;
        }
        $("#santospoly-debt-reason-text").text(reason);

        updateDebtPropertiesList(debtProperties, currentWalletAmount);
        $("#santospoly-debt-modal").fadeIn(200);
    }

    function updateDebtPropertiesList(properties, money) {
        debtProperties = properties;
        currentWalletAmount = money;
        $("#santospoly-debt-wallet-text").text("M" + currentWalletAmount);

        let container = $("#santospoly-debt-properties-container");
        container.empty();

        if (properties.length === 0) {
            container.append(`<div class="no-props-msg">` + (getLoc("no_properties_left_to_sell") || "You have no properties left to sell!") + `</div>`);
        } else {
            properties.forEach((prop, idx) => {
                let sellValue = prop.mortgage + (prop.houses * Math.floor(prop.houseCost / 2));
                let houseText = prop.houses > 0 ? (prop.houses === 5 ? (getLoc("hotel") || "Hotel") : (getLoc("house") || "House") + `: ${prop.houses}`) : (getLoc("lot") || "Lot");
                let html = `
                    <div class="debt-prop-card" data-region-id="${prop.regionId}" data-value="${sellValue}">
                        <div class="prop-info">
                            <span class="prop-name">${prop.name}</span>
                            <span class="prop-houses">${houseText}</span>
                        </div>
                        <div class="prop-action">
                            <span class="prop-value">${getLoc("value") || "Value"}: M${sellValue}</span>
                            <label class="debt-checkbox-container">
                                <input type="checkbox" class="prop-debt-checkbox" data-index="${idx}">
                                <span class="checkmark"></span>
                            </label>
                        </div>
                    </div>
                `;
                container.append(html);
            });
        }

        recalculateDebtSelection();
    }

    function recalculateDebtSelection() {
        let selectedTotal = 0;
        $(".prop-debt-checkbox:checked").each(function() {
            let idx = $(this).data("index");
            let prop = debtProperties[idx];
            if (prop) {
                let sellValue = prop.mortgage + (prop.houses * Math.floor(prop.houseCost / 2));
                selectedTotal += sellValue;
            }
        });

        $("#santospoly-debt-selected-text").text("M" + selectedTotal);
        
        let remaining = Math.max(0, currentDebtAmount - (currentWalletAmount + selectedTotal));
        if (remaining > 0) {
            $("#santospoly-debt-remaining-text").text("M" + remaining).parent().addClass("highlight").removeClass("success");
            $("#santospoly-debt-pay-btn").prop("disabled", true);
        } else {
            $("#santospoly-debt-remaining-text").text("M0").parent().addClass("success").removeClass("highlight");
            $("#santospoly-debt-pay-btn").prop("disabled", false);
        }
        
        let allPropertiesTotal = 0;
        debtProperties.forEach(prop => {
            let sellValue = prop.mortgage + (prop.houses * Math.floor(prop.houseCost / 2));
            allPropertiesTotal += sellValue;
        });

        if (currentWalletAmount + allPropertiesTotal < currentDebtAmount) {
            $("#santospoly-debt-bankrupt-btn").show();
        } else {
            $("#santospoly-debt-bankrupt-btn").hide();
        }
    }

    $(document).on("change", ".prop-debt-checkbox", function() {
        recalculateDebtSelection();
    });

    $("#santospoly-debt-auto-select-btn").on("click", function() {
        if (debtProperties.length === 0) return;
        
        let target = currentDebtAmount - currentWalletAmount;
        if (target <= 0) {
            $(".prop-debt-checkbox").prop("checked", false);
            recalculateDebtSelection();
            return;
        }

        let items = debtProperties.map((p, idx) => {
            return {
                index: idx,
                value: p.mortgage + (p.houses * Math.floor(p.houseCost / 2))
            };
        });

        let bestCombo = null;
        function search(idx, currentCombo, currentSum) {
            if (currentSum >= target) {
                if (!bestCombo || currentCombo.length < bestCombo.length || 
                    (currentCombo.length === bestCombo.length && currentSum < bestCombo.sum)) {
                    bestCombo = {
                        indices: [...currentCombo],
                        sum: currentSum
                    };
                }
                return;
            }
            if (idx >= items.length) return;

            currentCombo.push(items[idx].index);
            search(idx + 1, currentCombo, currentSum + items[idx].value);
            currentCombo.pop();

            search(idx + 1, currentCombo, currentSum);
        }

        search(0, [], 0);

        $(".prop-debt-checkbox").prop("checked", false);
        if (bestCombo) {
            bestCombo.indices.forEach(i => {
                $(`.prop-debt-checkbox[data-index="${i}"]`).prop("checked", true);
            });
        } else {
            $(".prop-debt-checkbox").prop("checked", true);
        }

        recalculateDebtSelection();
    });

    $("#santospoly-debt-pay-btn").on("click", function() {
        let regionIds = [];
        $(".prop-debt-checkbox:checked").each(function() {
            let idx = $(this).data("index");
            let prop = debtProperties[idx];
            if (prop) {
                regionIds.push(prop.regionId);
            }
        });

        $.post(`https://${GetParentResourceName()}/santospolysellSelectedProperties`, JSON.stringify({
            regionIds: regionIds
        }));
    });

    $("#santospoly-debt-bankrupt-btn").on("click", function() {
        $.post(`https://${GetParentResourceName()}/santospolydeclareBankruptcy`, JSON.stringify({}));
    });

    $("#santospoly-leave-confirm-btn").on("click", function() {
        $("#santospoly-leave-prompt-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyconfirmLeave`, JSON.stringify({ confirm: true }));
    });

    $("#santospoly-leave-cancel-btn").on("click", function() {
        $("#santospoly-leave-prompt-modal").fadeOut(200);
        $.post(`https://${GetParentResourceName()}/santospolyconfirmLeave`, JSON.stringify({ confirm: false }));
    });
});

function playUISound(type) {
    fetch(`https://${GetParentResourceName()}/santospolyplayUISound`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: type })
    }).catch(() => {});
}

document.addEventListener('mouseover', function(e) {
    if (e.target.closest('button, .btn, .action-btn, .close-btn, .buy-btn, .jail-action-btn, .debt-action-btn, .seat')) {
        playUISound("hover");
    }
});

document.addEventListener('mousedown', function(e) {
    if (e.target.closest('button, .btn, .action-btn, .close-btn, .buy-btn, .jail-action-btn, .debt-action-btn, .seat')) {
        playUISound("click");
    }
});

})();

;(function() {
let currentCreatorSource = null;

$(function () {
    function hideAllModals() {
        $("#truthOrDare-respondent-choice-panel").addClass("hidden");
        $("#truthOrDare-asker-panel").addClass("hidden");
        $("#truthOrDare-wait-panel").addClass("hidden");
        $("#truthOrDare-question-card").addClass("hidden");
    }

    window.addEventListener('message', function (event) {
        let data = event.data;
        if (data.action === "truthOrDareShowGamePanel") {
            currentCreatorSource = data.creatorSource;
            $("#truthOrDare-game-panel").removeClass("hidden");
            updatePlayerListUI(data.playerList);
            if (data.isLeader) {
                $("#truthOrDare-leader-controls").removeClass("hidden");
                $("#truthOrDare-normal-controls").addClass("hidden");
            } else {
                $("#truthOrDare-leader-controls").addClass("hidden");
                $("#truthOrDare-normal-controls").removeClass("hidden");
                $("#truthOrDare-status-text").text(getLoc("waiting_leader_spin") || "Waiting for leader to spin");
            }
        } else if (data.action === "truthOrDareUpdatePlayerList") {
            updatePlayerListUI(data.playerList);
        } else if (data.action === "truthOrDareHideGamePanel") {
            $("#truthOrDare-game-panel").addClass("hidden");
            hideAllModals();
            currentCreatorSource = null;
        } else if (data.action === "truthOrDareSpinStarted") {
            $("#truthOrDare-status-text").text(getLoc("bottle_spinning") || "Bottle is spinning...");
            $("#truthOrDare-spin-btn").prop("disabled", true);
            hideAllModals();
        } else if (data.action === "truthOrDareShowRespondentChoicePanel") {
            currentCreatorSource = data.creatorSource;
            hideAllModals();
            $("#truthOrDare-respondent-choice-panel").removeClass("hidden");
            if (data.consecutiveTruthCount >= 3) {
                $("#truthOrDare-resp-truth-btn").prop("disabled", true);
                $("#truthOrDare-resp-truth-warning").removeClass("hidden");
            } else {
                $("#truthOrDare-resp-truth-btn").prop("disabled", false);
                $("#truthOrDare-resp-truth-warning").addClass("hidden");
            }
        } else if (data.action === "truthOrDareShowWaitPanelChoice") {
            hideAllModals();
            $("#truthOrDare-wait-panel-text").text(getLoc("waiting_response") || "Waiting for response...");
            $("#truthOrDare-wait-panel").removeClass("hidden");
        } else if (data.action === "truthOrDareShowAskerPanel") {
            hideAllModals();
            currentCreatorSource = data.creatorSource;
            $("#truthOrDare-target-name-asker").text(data.targetName);
            $("#truthOrDare-asker-choice-type").text(data.choice === "truth" ? getLoc("truth") : getLoc("dare"));
            $("#truthOrDare-custom-question-label").text(data.choice === "truth" ? (getLoc("write_your_question") || "Write your question") : (getLoc("write_dare_task") || "Write dare task"));
            $("#truthOrDare-custom-question-input").attr("placeholder", data.choice === "truth" ? (getLoc("write_question_placeholder") || "Enter question...") : (getLoc("write_task_placeholder") || "Enter task..."));
            $("#truthOrDare-asker-panel").removeClass("hidden");
            $("#truthOrDare-asker-choices").removeClass("hidden");
            $("#truthOrDare-asker-custom-sub").addClass("hidden");
            $("#truthOrDare-custom-question-input").val("");
        } else if (data.action === "truthOrDareShowWaitPanelQuestion") {
            hideAllModals();
            $("#truthOrDare-wait-panel-text").text((getLoc("asker_preparing_task") || "%s is preparing task...").replace("%s", data.askerName));
            $("#truthOrDare-wait-panel").removeClass("hidden");
        } else if (data.action === "truthOrDareShowQuestionCard") {
            hideAllModals();
            $("#truthOrDare-asker-name-card").text(data.askerName);
            $("#truthOrDare-target-name-card").text(data.targetName);
            $("#truthOrDare-question-text").text(data.text);
            $("#truthOrDare-question-card").removeClass("hidden");
            if (data.isLeader) {
                $("#truthOrDare-close-question-btn").removeClass("hidden");
                $("#truthOrDare-waiting-close-text").addClass("hidden");
            } else {
                $("#truthOrDare-close-question-btn").addClass("hidden");
                $("#truthOrDare-waiting-close-text").removeClass("hidden");
            }
        } else if (data.action === "truthOrDareResetRoundUI") {
            hideAllModals();
            $("#truthOrDare-status-text").text(getLoc("waiting_leader_spin") || "Waiting for leader to spin");
            $("#truthOrDare-spin-btn").prop("disabled", false);
        }
    });

    function updatePlayerListUI(list) {
        let container = $("#truthOrDare-player-list");
        container.empty();
        if (list && list.length > 0) {
            list.forEach(function (player) {
                let badge = player.isLeader ? '<span class="leader-badge">' + (getLoc("leader") || "LEADER") + '</span>' : '';
                let leaderClass = player.isLeader ? 'leader' : '';
                container.append('<div class="player-item ' + leaderClass + '"><span>' + player.name + '</span>' + badge + '</div>');
            });
        }
    }

    $("#truthOrDare-spin-btn").click(function () {
        $.post(`https://${GetParentResourceName()}/truthOrDarespinBottle`, JSON.stringify({
            creatorSource: currentCreatorSource
        }));
    });

    $("#truthOrDare-resp-truth-btn").click(function () {
        $("#truthOrDare-respondent-choice-panel").addClass("hidden");
        $.post(`https://${GetParentResourceName()}/truthOrDarerespondentChoice`, JSON.stringify({
            creatorSource: currentCreatorSource,
            choice: "truth"
        }));
    });

    $("#truthOrDare-resp-dare-btn").click(function () {
        $("#truthOrDare-respondent-choice-panel").addClass("hidden");
        $.post(`https://${GetParentResourceName()}/truthOrDarerespondentChoice`, JSON.stringify({
            creatorSource: currentCreatorSource,
            choice: "dare"
        }));
    });

    $("#truthOrDare-asker-random-btn").click(function () {
        $("#truthOrDare-asker-panel").addClass("hidden");
        $.post(`https://${GetParentResourceName()}/truthOrDareaskerFinalChoice`, JSON.stringify({
            creatorSource: currentCreatorSource,
            method: "random"
        }));
    });

    $("#truthOrDare-asker-custom-btn").click(function () {
        $("#truthOrDare-asker-panel").addClass("hidden");
        $("#truthOrDare-asker-choices").addClass("hidden");
        $("#truthOrDare-asker-custom-sub").removeClass("hidden");
    });

    $("#truthOrDare-asker-custom-back-btn").click(function () {
        $("#truthOrDare-asker-custom-sub").addClass("hidden");
        $("#truthOrDare-asker-choices").removeClass("hidden");
    });

    $("#truthOrDare-asker-submit-btn").click(function () {
        let text = $("#truthOrDare-custom-question-input").val().trim();
        if (text.length > 0) {
            $("#truthOrDare-asker-panel").addClass("hidden");
            $.post(`https://${GetParentResourceName()}/truthOrDareaskerFinalChoice`, JSON.stringify({
                creatorSource: currentCreatorSource,
                method: "custom",
                customText: text
            }));
        }
    });

    $("#truthOrDare-close-question-btn").click(function () {
        $.post(`https://${GetParentResourceName()}/truthOrDareresetRound`, JSON.stringify({
            creatorSource: currentCreatorSource
        }));
    });
});

})();

;(function() {
const ui = document.getElementById("armwrestling-mash-ui")
const cdUI = document.getElementById("armwrestling-countdown-ui")
const cdNum = document.getElementById("armwrestling-countdown-num")
const resultUI = document.getElementById("armwrestling-result-ui")
const resultText = document.getElementById("armwrestling-result-text")
const resultSub = document.getElementById("armwrestling-result-sub")

let fastTimer = null
let mashTimer = null
let resultTimer = null

const setClass = (el, cls, on) => (on ? el.classList.add(cls) : el.classList.remove(cls))

function onMash() {
    setClass(ui, "mash", true)
    clearTimeout(mashTimer)
    mashTimer = setTimeout(() => setClass(ui, "mash", false), 120)

    setClass(ui, "fast", true)
    clearTimeout(fastTimer)
    fastTimer = setTimeout(() => setClass(ui, "fast", false), 350)
}

function showCountdown(val) {
    if (val <= 0) {
        cdUI.classList.add("hidden")
        return
    }
    cdNum.textContent = val
    cdNum.style.animation = "none"
    cdNum.offsetHeight
    cdNum.style.animation = ""
    cdUI.classList.remove("hidden")
}

function showResult(win, reason) {
    clearTimeout(resultTimer)

    const wonByForfeit = win && reason === "left"
    resultText.textContent = win ? (getLoc("you_won_result") || "You Won!") : (getLoc("you_lost_result") || "You Lost!")
    resultText.setAttribute("data-win", win ? "true" : "false")

    if (wonByForfeit) resultSub.textContent = getLoc("opponent_left_result") || "Opponent Left"
    else if (!win) resultSub.textContent = getLoc("better_luck_next_time") || "Better luck next time"
    else resultSub.textContent = getLoc("congratulations") || "Congratulations"

    resultText.style.animation = "none"
    resultSub.style.animation = "none"
    resultText.offsetHeight
    resultText.style.animation = ""
    resultSub.style.animation = ""

    resultUI.classList.remove("hidden")
    resultTimer = setTimeout(() => resultUI.classList.add("hidden"), 3800)
}

window.addEventListener("message", ({ data }) => {
    if (!data?.type) return
    switch (data.type) {
        case "show":
            cdUI.classList.add("hidden")
            ui.classList.remove("hidden", "mash", "fast")
            break
        case "hide":
            ui.classList.add("hidden")
            cdUI.classList.add("hidden")
            clearTimeout(fastTimer)
            clearTimeout(mashTimer)
            ui.classList.remove("mash", "fast")
            $("#universal-lobby-modal").fadeOut(150);
            break
        case "mash":
            onMash()
            break
        case "countdown":
            showCountdown(data.value)
            break
        case "result":
            showResult(data.win, data.reason)
            break
        case "updateLobby":
            if (data.showLobby) {
                
                $("#uni-lobby-p1-name").text(data.aName || getLoc("waiting")).removeAttr("data-i18n");
                if (data.aAvatar && data.aAvatar !== "") {
                    $("#uni-lobby-p1-avatar").css("background-image", "url('" + data.aAvatar + "')");
                } else {
                    $("#uni-lobby-p1-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p1-bet").text((getLoc("bet") || "Bet") + ": $" + (data.aBet || 0)).removeAttr("data-i18n");
                if (data.aReady) {
                    $("#uni-lobby-p1-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready").removeAttr("data-i18n");
                } else {
                    $("#uni-lobby-p1-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready").removeAttr("data-i18n");
                }

                
                $("#uni-lobby-p2-name").text(data.bName || getLoc("waiting")).removeAttr("data-i18n");
                if (data.bAvatar && data.bAvatar !== "") {
                    $("#uni-lobby-p2-avatar").css("background-image", "url('" + data.bAvatar + "')");
                } else {
                    $("#uni-lobby-p2-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p2-bet").text((getLoc("bet") || "Bet") + ": $" + (data.bBet || 0)).removeAttr("data-i18n");
                if (data.bReady) {
                    $("#uni-lobby-p2-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready").removeAttr("data-i18n");
                } else {
                    $("#uni-lobby-p2-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready").removeAttr("data-i18n");
                }

                
                $("#uni-lobby-total-pot-vs, #uni-lobby-total-pot-multi").text("$" + (data.totalPot || 0));
                if (!$("#uni-lobby-bet-amount-vs").is(":focus")) {
                    let myCurrentBet = (data.myRole === "A") ? data.aBet : data.bBet;
                    $("#uni-lobby-bet-amount-vs").val(myCurrentBet || 0);
                }

                if (data.myReady) {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("unready") || "UNREADY").addClass("ready-active");
                } else {
                    $("#uni-lobby-ready-toggle-btn").text(getLoc("ready") || "READY").removeClass("ready-active");
                }

                $("#universal-lobby-modal").fadeIn(250).css("display", "flex");
            } else {
                $("#universal-lobby-modal").fadeOut(150);
                
                $("#uni-lobby-p1-name").attr("data-i18n", "common.waiting");
                $("#uni-lobby-p2-name").attr("data-i18n", "common.waiting");
                $("#uni-lobby-p1-bet").attr("data-i18n", "common.bet");
                $("#uni-lobby-p2-bet").attr("data-i18n", "common.bet");
                $("#uni-lobby-p1-status").attr("data-i18n", "common.not_ready");
                $("#uni-lobby-p2-status").attr("data-i18n", "common.not_ready");
            }
            break
    }
})


















})();

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === "showLobby" || (data.action === "updateJengo" && data.showLobby) || (data.type === "updateLobby" && data.showLobby) || (data.action === "update" && data.showLobby) || (data.action === "connect4Update" && data.showLobby) || (data.action === "xoxUpdate" && data.showLobby)) {
        if (data.players || data.gameName === "santosPoly" || (data.data && data.data.players)) {
            $("#uni-lobby-vs-layout").hide();
            $("#uni-lobby-multi-layout").show();
            $(".currency-symbol").text("$");
            
            if (typeof data.timeLimit !== 'undefined' || data.gameName === 'santosPoly' || (data.data && typeof data.data.timeLimit !== 'undefined')) {
                $("#uni-lobby-time-select").css("display", "flex");
            } else {
                $("#uni-lobby-time-select").hide();
            }
            $("#uni-lobby-exit-btn").show();
        } else {
            $("#uni-lobby-multi-layout").hide();
            $("#uni-lobby-vs-layout").show();
            if (typeof data.timeLimit !== 'undefined') {
                $("#uni-lobby-time-buttons").show();
            } else {
                $("#uni-lobby-time-buttons").hide();
            }
            $("#uni-lobby-exit-btn").show();
        }
    }
});

;(function() {
    window.addEventListener('message', function(event) {
        let data = event.data;
        if (data.action === "connect4Update") {
            if (data.showLobby) {
                let proposedTime = data.timeLimit || 0;
                $(".uni-time-limit-btn").removeClass("active");
                $(`.uni-time-limit-btn[data-time="${proposedTime}"]`).addClass("active");

                $("#uni-lobby-p1-name").text(data.whiteName || getLoc("waiting")).removeAttr("data-i18n");
                if (data.whiteAvatar && data.whiteAvatar !== "") {
                    $("#uni-lobby-p1-avatar").css("background-image", "url('" + data.whiteAvatar + "')");
                } else {
                    $("#uni-lobby-p1-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p1-bet").text((getLoc("bet") || "Bet") + ": $" + (data.whiteBet || 0)).removeAttr("data-i18n");
                if (data.whiteReady) {
                    $("#uni-lobby-p1-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready").removeAttr("data-i18n");
                } else {
                    $("#uni-lobby-p1-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready").removeAttr("data-i18n");
                }

                $("#uni-lobby-p2-name").text(data.blackName || getLoc("waiting")).removeAttr("data-i18n");
                if (data.blackAvatar && data.blackAvatar !== "") {
                    $("#uni-lobby-p2-avatar").css("background-image", "url('" + data.blackAvatar + "')");
                } else {
                    $("#uni-lobby-p2-avatar").css("background-image", "none");
                }
                $("#uni-lobby-p2-bet").text((getLoc("bet") || "Bet") + ": $" + (data.blackBet || 0)).removeAttr("data-i18n");
                if (data.blackReady) {
                    $("#uni-lobby-p2-status").text(getLoc("ready") || "READY").removeClass("status-not-ready").addClass("status-ready").removeAttr("data-i18n");
                } else {
                    $("#uni-lobby-p2-status").text(getLoc("not_ready") || "NOT READY").removeClass("status-ready").addClass("status-not-ready").removeAttr("data-i18n");
                }

                let btn = $("#uni-lobby-ready-toggle-btn");
                if (data.myReady) {
                    btn.addClass("ready-active").text(getLoc("unready") || "UNREADY");
                } else {
                    btn.removeClass("ready-active").text(getLoc("ready") || "READY");
                }

                $("#universal-lobby-modal").fadeIn(250).css("display", "flex");
            } else {
                $("#universal-lobby-modal").fadeOut(150);
                
                $("#uni-lobby-p1-name").attr("data-i18n", "common.waiting");
                $("#uni-lobby-p2-name").attr("data-i18n", "common.waiting");
                $("#uni-lobby-p1-bet").attr("data-i18n", "common.bet");
                $("#uni-lobby-p2-bet").attr("data-i18n", "common.bet");
                $("#uni-lobby-p1-status").attr("data-i18n", "common.not_ready");
                $("#uni-lobby-p2-status").attr("data-i18n", "common.not_ready");
            }
            
            if (data.gameActive) {
                $("#connect4-turn-row").show();
                let indicator = $("#connect4-turn-indicator");
                indicator.removeAttr("data-i18n");
                if (data.myTurn) {
                    indicator.text(getLoc("your_turn") || "Your Turn");
                    indicator.removeClass("opponent-turn").addClass("my-turn");
                } else {
                    indicator.text(getLoc("opponent_s_turn") || "Opponent's Turn");
                    indicator.removeClass("my-turn").addClass("opponent-turn");
                }
            } else {
                $("#connect4-turn-row").hide();
            }
        } else if (data.action === "connect4ShowUI") {
            if (data.show) {
                $("#connect4-ui-container").fadeIn(250).css("display", "flex");
            } else {
                $("#connect4-ui-container").fadeOut(150);
            }
        } else if (data.action === "connect4PromptLeave") {
            $("#connect4-leave-prompt-modal").fadeIn(200).css("display", "flex");
        }
    });
})();

$("#connect4-leave-yes").click(function() {
    $("#connect4-leave-prompt-modal").fadeOut(150);
    $.post(`https://${GetParentResourceName()}/connect4LeaveYes`, JSON.stringify({}));
});

$("#connect4-leave-no").click(function() {
    $("#connect4-leave-prompt-modal").fadeOut(150);
    $.post(`https://${GetParentResourceName()}/connect4LeaveNo`, JSON.stringify({}));
});

document.getElementById('uni-lobby-ready-toggle-btn').addEventListener('click', function() {
    if (window.currentLobbyGameName === 'eno') {
        $.post(`https://${GetParentResourceName()}/enoToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'checkers') {
        $.post(`https://${GetParentResourceName()}/checkersToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'chess') {
        $.post(`https://${GetParentResourceName()}/chessToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'connect4') {
        $.post(`https://${GetParentResourceName()}/connect4ToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'xox') {
        $.post(`https://${GetParentResourceName()}/xoxToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'santosPoly') {
        $.post(`https://${GetParentResourceName()}/santospolytoggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'jengo') {
        $.post(`https://${GetParentResourceName()}/jengoToggleReady`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'armwrestling') {
        $.post(`https://${GetParentResourceName()}/armwrestlingToggleReady`, JSON.stringify({}));
    }
});















document.getElementById('uni-lobby-update-bet-btn-multi').addEventListener('click', function() {
    if (window.currentLobbyGameName === 'eno') {
        let amount = parseInt(document.getElementById('uni-lobby-bet-amount-multi').value) || 0;
        if (amount < 0) return;
        $.post(`https://${GetParentResourceName()}/enoProposeBet`, JSON.stringify({ amount: amount }));
    } else if (window.currentLobbyGameName === 'santosPoly') {
        let amount = parseInt(document.getElementById('uni-lobby-bet-amount-multi').value) || 0;
        if (amount < 0) return;
        $.post(`https://${GetParentResourceName()}/santospolyproposeBet`, JSON.stringify({ amount: amount }));
    }
});

document.getElementById('uni-lobby-update-bet-btn-vs').addEventListener('click', function() {
    let val = parseInt(document.getElementById('uni-lobby-bet-amount-vs').value) || 0;
    if (val < 0) val = 0;
    if (window.currentLobbyGameName === 'checkers') {
        $.post(`https://${GetParentResourceName()}/checkersProposeBet`, JSON.stringify({ amount: val }));
    } else if (window.currentLobbyGameName === 'chess') {
        $.post(`https://${GetParentResourceName()}/chessProposeBet`, JSON.stringify({ amount: val }));
    } else if (window.currentLobbyGameName === 'connect4') {
        $.post(`https://${GetParentResourceName()}/connect4ProposeBet`, JSON.stringify({ amount: val }));
    } else if (window.currentLobbyGameName === 'xox') {
        $.post(`https://${GetParentResourceName()}/xoxProposeBet`, JSON.stringify({ amount: val }));
    } else if (window.currentLobbyGameName === 'jengo') {
        $.post(`https://${GetParentResourceName()}/jengoProposeBet`, JSON.stringify({ amount: val }));
    } else if (window.currentLobbyGameName === 'armwrestling') {
        $.post(`https://${GetParentResourceName()}/armwrestlingProposeBet`, JSON.stringify({ amount: val }));
    }
});



















document.getElementById('uni-lobby-exit-btn').addEventListener('click', function() {
    if (window.currentLobbyGameName === 'checkers') {
        $.post(`https://${GetParentResourceName()}/checkersLobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'chess') {
        $.post(`https://${GetParentResourceName()}/chessLobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'connect4') {
        $.post(`https://${GetParentResourceName()}/connect4LobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'xox') {
        $.post(`https://${GetParentResourceName()}/xoxLobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'santosPoly') {
        $.post(`https://${GetParentResourceName()}/santospolycloseLobby`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'eno') {
        $.post(`https://${GetParentResourceName()}/enoLobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'jengo') {
        $.post(`https://${GetParentResourceName()}/jengoLobbyExit`, JSON.stringify({}));
    } else if (window.currentLobbyGameName === 'armwrestling') {
        $.post(`https://${GetParentResourceName()}/armwrestlingLobbyExit`, JSON.stringify({}));
    }
});















document.querySelectorAll('.uni-time-limit-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        if (window.currentLobbyGameName === 'checkers') {
            $.post(`https://${GetParentResourceName()}/checkersProposeTimeLimit`, JSON.stringify({ timeLimit: parseInt(this.getAttribute('data-time')) }));
        } else if (window.currentLobbyGameName === 'chess') {
            $.post(`https://${GetParentResourceName()}/chessProposeTimeLimit`, JSON.stringify({ timeLimit: parseInt(this.getAttribute('data-time')) }));
        }
    });
});

document.getElementById('uni-lobby-time-select-input').addEventListener('change', function() {
    if (window.currentLobbyGameName === 'santosPoly') {
        let val = parseInt(this.value);
        $.post(`https://${GetParentResourceName()}/santospolyproposeTimeLimit`, JSON.stringify({timeLimit: val}));
    }
});

$(document).on("click", "#checkers-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/checkersLeaveConfirm`, JSON.stringify({}));
    $("#checkers-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#checkers-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/checkersLeaveCancel`, JSON.stringify({}));
    $("#checkers-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#jengo-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/jengoLeaveConfirm`, JSON.stringify({}));
    $("#jengo-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#jengo-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/jengoLeaveCancel`, JSON.stringify({}));
    $("#jengo-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#xox-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/xoxLeaveConfirm`, JSON.stringify({}));
    $("#xox-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#xox-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/xoxLeaveCancel`, JSON.stringify({}));
    $("#xox-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#eno-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/enoLeaveConfirm`, JSON.stringify({}));
    $("#eno-leave-prompt-modal").fadeOut(150);
});


document.querySelectorAll('.uni-time-limit-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        if (window.currentLobbyGameName === 'checkers') {
            $.post(`https://${GetParentResourceName()}/checkersProposeTimeLimit`, JSON.stringify({ timeLimit: parseInt(this.getAttribute('data-time')) }));
        } else if (window.currentLobbyGameName === 'chess') {
            $.post(`https://${GetParentResourceName()}/chessProposeTimeLimit`, JSON.stringify({ timeLimit: parseInt(this.getAttribute('data-time')) }));
        }
    });
});

document.getElementById('uni-lobby-time-select-input').addEventListener('change', function() {
    if (window.currentLobbyGameName === 'santosPoly') {
        let val = parseInt(this.value);
        $.post(`https://${GetParentResourceName()}/santospolyproposeTimeLimit`, JSON.stringify({timeLimit: val}));
    }
});

$(document).on("click", "#checkers-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/checkersLeaveConfirm`, JSON.stringify({}));
    $("#checkers-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#checkers-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/checkersLeaveCancel`, JSON.stringify({}));
    $("#checkers-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#jengo-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/jengoLeaveConfirm`, JSON.stringify({}));
    $("#jengo-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#jengo-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/jengoLeaveCancel`, JSON.stringify({}));
    $("#jengo-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#xox-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/xoxLeaveConfirm`, JSON.stringify({}));
    $("#xox-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#xox-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/xoxLeaveCancel`, JSON.stringify({}));
    $("#xox-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#eno-leave-yes", function() {
    $.post(`https://${GetParentResourceName()}/enoLeaveConfirm`, JSON.stringify({}));
    $("#eno-leave-prompt-modal").fadeOut(150);
});

$(document).on("click", "#eno-leave-no", function() {
    $.post(`https://${GetParentResourceName()}/enoLeaveCancel`, JSON.stringify({}));
    $("#eno-leave-prompt-modal").fadeOut(150);
});

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === "showAdminMenu") {
        if (data.active) {
            updateAdminSpawnList(data.items);
            updateAdminTablesList(data.tables);
            
            $('.admin-tab-btn[data-tab="player"]').addClass('active');
            $('.admin-tab-btn[data-tab="admin"]').removeClass('active');
            $('#player-tab-content').css('display', 'flex');
            $('#admin-tab-content').hide();
            
            $("#admin-menu-modal").css("display", "flex").hide().fadeIn(300);
        } else {
            $("#admin-menu-modal").fadeOut(200);
        }
    } else if (data.action === "updateAdminTables") {
        updateAdminTablesList(data.tables);
    } else if (data.action === "forceStandUp") {
        $("#universal-lobby-modal").fadeOut(200);
        $("#jengo-waiting-display").fadeOut(200);
        $("#jengo-ui-container").fadeOut(200);
        
        let game = data.game;
        if (game === 'chess') {
            $.post(`https://${GetParentResourceName()}/chessLeaveConfirm`, JSON.stringify({}));
        } else if (game === 'checkers') {
            $.post(`https://${GetParentResourceName()}/checkersLeaveConfirm`, JSON.stringify({}));
        } else if (game === 'jengo') {
            $.post(`https://${GetParentResourceName()}/jengoLeaveConfirm`, JSON.stringify({}));
        } else if (game === 'xox') {
            $.post(`https://${GetParentResourceName()}/xoxLeaveConfirm`, JSON.stringify({}));
        } else if (game === 'eno') {
            $.post(`https://${GetParentResourceName()}/enoLeaveConfirm`, JSON.stringify({}));
        } else if (game === 'connect4') {
            $.post(`https://${GetParentResourceName()}/connect4LobbyExit`, JSON.stringify({}));
        } else if (game === 'armwrestling') {
            $.post(`https://${GetParentResourceName()}/armwrestlingLobbyExit`, JSON.stringify({}));
        } else if (game === 'santospoly') {
            $.post(`https://${GetParentResourceName()}/santospolycloseLobby`, JSON.stringify({}));
            $.post(`https://${GetParentResourceName()}/santospolyconfirmLeave`, JSON.stringify({ confirm: true }));
        }
    } else if (data.action === "playerDied") {
        if (window.currentLobbyGameName) {
            let game = window.currentLobbyGameName;
            if (game === 'chess') {
                $.post(`https://${GetParentResourceName()}/chessLeaveConfirm`, JSON.stringify({}));
            } else if (game === 'checkers') {
                $.post(`https://${GetParentResourceName()}/checkersLeaveConfirm`, JSON.stringify({}));
            } else if (game === 'jengo') {
                $.post(`https://${GetParentResourceName()}/jengoLeaveConfirm`, JSON.stringify({}));
            } else if (game === 'xox') {
                $.post(`https://${GetParentResourceName()}/xoxLeaveConfirm`, JSON.stringify({}));
            } else if (game === 'eno') {
                $.post(`https://${GetParentResourceName()}/enoLeaveConfirm`, JSON.stringify({}));
            } else if (game === 'connect4') {
                $.post(`https://${GetParentResourceName()}/connect4LobbyExit`, JSON.stringify({}));
            } else if (game === 'armwrestling') {
                $.post(`https://${GetParentResourceName()}/armwrestlingLobbyExit`, JSON.stringify({}));
            } else if (game === 'santospoly') {
                $.post(`https://${GetParentResourceName()}/santospolycloseLobby`, JSON.stringify({}));
                $.post(`https://${GetParentResourceName()}/santospolyconfirmLeave`, JSON.stringify({ confirm: true }));
            }
        }
        closeAll();
    }
});

function getTranslatedGameName(gameId) {
    let key = gameId.toLowerCase();
    if (key === 'armwrestling') key = 'arm_wrestling';
    let translated = getLoc(key);
    if (translated === key) return gameId; // fallback if not found
    return translated;
}

function updateAdminTablesList(tables) {
    let playerContainer = $('#admin-player-tables-list');
    let adminContainer = $('#admin-placed-tables-list');
    playerContainer.empty();
    adminContainer.empty();
    
    let playerPlacedCount = 0;
    let adminPlacedCount = 0;
    
    let keys = Object.keys(tables);
    
    keys.forEach(id => {
        let table = tables[id];
        let coordsStr = `x: ${table.coords.x.toFixed(1)}, y: ${table.coords.y.toFixed(1)}, z: ${table.coords.z.toFixed(1)}`;
        let row = `
            <div style="background: #25262b; border: 1px solid #2c2e33; border-radius: 8px; padding: 12px 16px; display: flex; align-items: center; justify-content: space-between; gap: 12px; transition: border-color 0.2s;">
                <div style="display: flex; flex-direction: column; gap: 4px;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-size: 14px; font-weight: 600; color: #fff;">${getTranslatedGameName(table.game).toUpperCase()}</span>
                        <span style="font-size: 11px; background: #2c2e33; color: #a6a7ab; padding: 2px 6px; border-radius: 4px;">ID: ${table.id.split('_')[0]}</span>
                    </div>
                    <div style="font-size: 12px; color: #909296; display: flex; flex-direction: column; gap: 2px;">
                        <span>Coords: ${coordsStr}</span>
                        <span>Owner: ${table.owner || 'Unknown'}</span>
                    </div>
                </div>
                <div style="display: flex; gap: 8px; align-items: center;">
                    <button class="admin-tp-btn" data-id="${table.id}" data-x="${table.coords.x}" data-y="${table.coords.y}" data-z="${table.coords.z}" style="background: #228be6; color: #fff; border: none; border-radius: 6px; padding: 8px 14px; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#1c7ed6'" onmouseout="this.style.background='#228be6'">TP</button>
                    <button class="admin-delete-btn" data-id="${table.id}" style="background: #fa5252; color: #fff; border: none; border-radius: 6px; padding: 8px 14px; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#e03131'" onmouseout="this.style.background='#fa5252'">Delete</button>
                </div>
            </div>
        `;
        
        if (table.adminPlaced) {
            adminContainer.append(row);
            adminPlacedCount++;
        } else {
            playerContainer.append(row);
            playerPlacedCount++;
        }
    });
    
    $('#player-tables-count').text(playerPlacedCount);
    $('#admin-tables-count').text(adminPlacedCount);
    
    if (playerPlacedCount === 0) {
        playerContainer.append(`<div style="padding: 16px; text-align: center; color: #5c5f66; font-size: 14px;">${getLoc("no_player_placed_tables")}</div>`);
    }
    if (adminPlacedCount === 0) {
        adminContainer.append(`<div style="padding: 16px; text-align: center; color: #5c5f66; font-size: 14px;">${getLoc("no_admin_placed_tables")}</div>`);
    }
}

function updateAdminSpawnList(items) {
    let container = $('#admin-spawn-list');
    container.empty();
    
    Object.keys(items).forEach(key => {
        let item = items[key];
        let row = `
            <button class="admin-spawn-btn" data-game="${item.game}" data-model="${item.model}" data-item="${item.name}" style="width: 100%; text-align: left; background: #25262b; border: 1px solid #2c2e33; border-radius: 8px; padding: 12px; display: flex; flex-direction: column; gap: 4px; cursor: pointer; transition: background 0.2s, border-color 0.2s; color: #c1c2c5;" onmouseover="this.style.background='#2c2e33'; this.style.borderColor='#3b5bdb';" onmouseout="this.style.background='#25262b'; this.style.borderColor='#2c2e33';">
                <span style="font-size: 13px; font-weight: 600; color: #fff;">${getTranslatedGameName(item.game).toUpperCase()}</span>
                <span style="font-size: 11px; color: #909296;">Model: ${item.model}</span>
            </button>
        `;
        container.append(row);
    });
}

$(document).on('click', '#admin-close-btn', function() {
    $('#admin-menu-modal').fadeOut(200);
    $.post(`https://${GetParentResourceName()}/closeAdminMenu`, JSON.stringify({}));
});

let tempSpawnData = null;

$(document).on('click', '.admin-spawn-btn', function() {
    let gameType = $(this).data('game');
    let itemName = $(this).data('item');
    let model = $(this).data('model');
    
    let isExcluded = (gameType.toLowerCase() === 'guesswho' || gameType.toLowerCase() === 'truthordare');
    if (isExcluded) {
        $('#admin-menu-modal').fadeOut(200);
        $.post(`https://${GetParentResourceName()}/adminSpawnTable`, JSON.stringify({
            game: gameType,
            item: itemName,
            model: model,
            price: 0
        }));
    } else {
        tempSpawnData = { game: gameType, item: itemName, model: model };
        $('#admin-price-input').val(0);
        $('#admin-price-modal').fadeIn(200).css("display", "flex");
    }
});

$(document).on('click', '#admin-price-confirm', function() {
    if (tempSpawnData) {
        let price = parseInt($('#admin-price-input').val()) || 0;
        if (price < 0) price = 0;
        $('#admin-price-modal').hide();
        $('#admin-menu-modal').fadeOut(200);
        $.post(`https://${GetParentResourceName()}/adminSpawnTable`, JSON.stringify({
            game: tempSpawnData.game,
            item: tempSpawnData.item,
            model: tempSpawnData.model,
            price: price
        }));
        tempSpawnData = null;
    }
});

$(document).on('click', '#admin-price-cancel', function() {
    $('#admin-price-modal').fadeOut(200);
    tempSpawnData = null;
});

$(document).on('click', '#game-payment-yes', function() {
    $("#game-payment-modal").fadeOut(200);
    if (window.hadChess3DUIOpen) {
        $("#chess-3d-ui-container").show();
        window.hadChess3DUIOpen = false;
    }
    if (window.currentPaymentSessionId) {
        $.post(`https://${GetParentResourceName()}/acceptPayment`, JSON.stringify({
            sessionId: window.currentPaymentSessionId
        }));
        window.currentPaymentSessionId = null;
    }
});

$(document).on('click', '#game-payment-no', function() {
    $("#game-payment-modal").fadeOut(200);
    if (window.hadChess3DUIOpen) {
        $("#chess-3d-ui-container").show();
        window.hadChess3DUIOpen = false;
    }
    if (window.currentPaymentSessionId) {
        $.post(`https://${GetParentResourceName()}/declinePayment`, JSON.stringify({
            sessionId: window.currentPaymentSessionId
        }));
        window.currentPaymentSessionId = null;
    }
});

$(document).on('click', '.admin-delete-btn', function() {
    let tableId = $(this).data('id');
    $.post(`https://${GetParentResourceName()}/adminDeleteTable`, JSON.stringify({
        id: tableId
    }));
});

$(document).on('click', '.admin-tp-btn', function() {
    let x = parseFloat($(this).data('x'));
    let y = parseFloat($(this).data('y'));
    let z = parseFloat($(this).data('z'));
    $('#admin-menu-modal').fadeOut(200);
    $.post(`https://${GetParentResourceName()}/adminTeleport`, JSON.stringify({
        coords: { x: x, y: y, z: z }
    }));
});

$(document).on('click', '.admin-tab-btn', function() {
    $('.admin-tab-btn').removeClass('active');
    $(this).addClass('active');
    
    let tab = $(this).data('tab');
    if (tab === 'player') {
        $('#player-tab-content').css('display', 'flex');
        $('#admin-tab-content').hide();
    } else {
        $('#admin-tab-content').css('display', 'flex');
        $('#player-tab-content').hide();
    }
});

$(document).on('change', '#global-leaderboard-game-select', function() {
    let game = $(this).val();
    renderGlobalLeaderboard(game);
});

$(document).on('click', '#close-global-leaderboard-btn', function() {
    $("#global-leaderboard-modal").fadeOut(150);
    $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
});

$(document).on('click', '.leaderboard-tab', function() {
    $('.leaderboard-tab').removeClass('active');
    $(this).addClass('active');
    
    let id = $(this).attr('id');
    if (id === 'leaderboard-tab-active') {
        $("#leaderboard-active-controls").show();
        $("#leaderboard-history-controls").hide();
        
        let game = $("#global-leaderboard-game-select").val() || "chess";
        renderGlobalLeaderboard(game);
    } else {
        $("#leaderboard-active-controls").hide();
        $("#leaderboard-history-controls").show();
        
        let season = $("#global-leaderboard-season-select").val();
        renderSeasonHistory(season);
    }
});

$(document).on('change', '#global-leaderboard-season-select', function() {
    let season = $(this).val();
    renderSeasonHistory(season);
});

function renderSeasonHistory(season) {
    if (!season || season === "") {
        $("#global-leaderboard-list").html(`<tr><td colspan="4" style="text-align: center; padding: 20px; color: #909296;">No season data available.</td></tr>`);
        $("#global-leaderboard-my-stats").html("");
        return;
    }
    
    let sData = globalSeasonsHistory.find(s => s.season == season);
    if (!sData) {
        $("#global-leaderboard-list").html(`<tr><td colspan="4" style="text-align: center; padding: 20px; color: #909296;">Season not found.</td></tr>`);
        $("#global-leaderboard-my-stats").html("");
        return;
    }
    
    $("#global-leaderboard-record-header").text(getLoc("average_elo") || "Average ELO");
    $("#global-leaderboard-rating-header").hide();
    
    let listHtml = "";
    sData.standings.forEach(function(row) {
        let isSelf = (row.citizenid === globalMyCitizenId);
        let rowClass = isSelf ? "class='self-row'" : "";
        let avatarUrl = row.avatar && row.avatar !== "" ? row.avatar : "https://files.catbox.moe/4kd7sv.jpg";
        
        listHtml += `
            <tr ${rowClass}>
                <td style="padding: 0.7vh 1vh;">${row.rank}</td>
                <td style="padding: 0.7vh 1vh;">
                    <div class="leaderboard-player-cell">
                        <div class="leaderboard-player-avatar" style="background-image: url('${avatarUrl}');"></div>
                        <span class="leaderboard-player-name">${row.name}</span>
                    </div>
                </td>
                <td style="padding: 0.7vh 1vh;">${row.averageElo} ELO</td>
                <td style="padding: 0.7vh 1vh; display: none;"></td>
            </tr>
        `;
    });
    
    if (listHtml === "") {
        listHtml = `<tr><td colspan="4" style="text-align: center; padding: 20px; color: #909296;">No standings recorded.</td></tr>`;
    }
    
    $("#global-leaderboard-list").html(listHtml);
    
    let myS = sData.standings.find(item => item.citizenid === globalMyCitizenId);
    if (myS) {
        $("#global-leaderboard-my-stats").text(`${getLoc("my_stats") || "My Stats:"} ${getLoc("rank") || "Rank"} #${myS.rank} | ${getLoc("average_elo") || "Average ELO:"} ${myS.averageElo}`);
    } else {
        $("#global-leaderboard-my-stats").text(`${getLoc("my_stats") || "My Stats:"} ${getLoc("rank") || "Rank"} - | ${getLoc("average_elo") || "Average ELO:"} 1000`);
    }
}


/* --- Table Color Picker Logic --- */
let colorPickerData = null;

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === "openColorPicker") {
        colorPickerData = {
            gameType: data.gameType,
            itemName: data.itemName,
            price: data.price
        };
        $("#table-color-picker-modal").css("display", "flex").hide().fadeIn(300);
    }
});

$(document).on('click', '#close-color-picker-btn', function() {
    $("#table-color-picker-modal").fadeOut(200);
    $.post('https://ak4y-boardGames/selectColor', JSON.stringify({
        model: null,
        itemName: colorPickerData ? colorPickerData.itemName : null
    }));
    colorPickerData = null;
});

$(document).on('click', '.tcp-color-item', function() {
    if (!colorPickerData) return;
    let selectedModel = $(this).attr('data-model');
    $("#table-color-picker-modal").fadeOut(200);
    $.post('https://ak4y-boardGames/selectColor', JSON.stringify({
        model: selectedModel,
        gameType: colorPickerData.gameType,
        itemName: colorPickerData.itemName,
        price: colorPickerData.price
    }));
    colorPickerData = null;
});

// --- Chess 3D UI Logic ---
const pieceIconMap = {
    'pawn': '♟',
    'knight': '♞',
    'bishop': '♝',
    'rook': '♜',
    'queen': '♛',
    'king': '♚'
};

window.addEventListener('message', function(event) {
    if (event.data.action === "updateChess3DUI") {
        const container = document.getElementById("chess-3d-ui-container");
        if (!container) return;
        
        const pieces = event.data.pieces;
        // Keep track of which IDs are currently drawn
        const drawnIds = new Set();
        
        pieces.forEach(p => {
            const id = `chess-3d-${p.id}`;
            drawnIds.add(id);
            
            let el = document.getElementById(id);
            const iconChar = pieceIconMap[p.type] || '♟';
            if (!el) {
                el = document.createElement("div");
                el.id = id;
                container.appendChild(el);
            }
            // Always update class and icon in case a different piece captured this position
            el.className = `chess-3d-piece ${p.color}`;
            el.innerHTML = `<span>${iconChar}</span>`;
            
            el.style.left = p.x + "%";
            el.style.top = p.y + "%";
            el.style.display = "flex";
        });
        
        // Hide elements that are no longer sent
        Array.from(container.children).forEach(child => {
            if (!drawnIds.has(child.id)) {
                child.style.display = "none";
            }
        });
    } else if (event.data.action === "movePiece3DUI") {
        let el = document.getElementById(`chess-3d-${event.data.id}`);
        if (el) {
            el.style.left = event.data.x + "%";
            el.style.top = event.data.y + "%";
        }
    } else if (event.data.action === "showChess3DUI") {
        const container = document.getElementById("chess-3d-ui-container");
        if (container) container.style.display = "block";
    } else if (event.data.action === "hideChess3DUI") {
        const container = document.getElementById("chess-3d-ui-container");
        if (container) container.style.display = "none";
    }
});

$(document).ready(function() {
    const lobbyModal = document.getElementById('universal-lobby-modal');
    if (lobbyModal) {
        let isLobbyModalVisible = $(lobbyModal).is(":visible");
        const observer = new MutationObserver(function(mutations) {
            let currentVisible = $(lobbyModal).is(":visible");
            if (currentVisible !== isLobbyModalVisible) {
                isLobbyModalVisible = currentVisible;
                if (currentVisible) {
                    window.hadChess3DUIOpenFromLobby = $("#chess-3d-ui-container").is(":visible");
                    if (window.hadChess3DUIOpenFromLobby) {
                        $("#chess-3d-ui-container").hide();
                    }
                } else {
                    if (window.hadChess3DUIOpenFromLobby) {
                        if (!$("#game-payment-modal").is(":visible")) {
                            $("#chess-3d-ui-container").show();
                        } else {
                            window.hadChess3DUIOpen = true; 
                        }
                        window.hadChess3DUIOpenFromLobby = false;
                    }
                }
            }
        });
        observer.observe(lobbyModal, { attributes: true, attributeFilter: ['style', 'class'] });
    }
});
