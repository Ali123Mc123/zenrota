// Turkish capitals (i -> İ) for the uppercase titles.
document.documentElement.lang = 'tr';
// The English logo word keeps a plain capital I.
document.addEventListener('DOMContentLoaded', () => document.querySelectorAll('[data-locale="paintball"]').forEach((el) => (el.lang = 'en')));

console.log("discord.gg/debux | Tebex : debux.tebex.io");

var isLobbyOpen = false;
var selectLobbyDetails = {
  map: 0,
  time: 5,
  player: 10,
  lobbyName: "",
  gameMode: "",
  weapon: "",
};
let currentLocales = {};
var playerMarketData = {};
var lobbyCreatePrice = 0;

window.addEventListener("message", async function (event) {
  if (event.data.action == "openPaintballMenu") {
    isLobbyOpen = false;
    $(".categoryMenu").removeClass("useCategory");
    $(`#categoryMenu-1`).addClass("useCategory");
    $(".container").css("display", "flex");
    $(".container-c-leftside").css("display", "flex");
    $(".LobbyListMenu").css("display", "flex");
    currentLocales = event.data.locales;
    lobbyCreatePrice = event.data.LobbyCreatePrice || 0;
    const createButtonText =
      lobbyCreatePrice > 0
        ? `${currentLocales["create_lobby_button"]} ($${lobbyCreatePrice})`
        : currentLocales["create_lobby_button"];
    $(".createLobbyButtonCL t").html(createButtonText);
    $(".LobbyPlayer").css("opacity", "1");
    $(".LobbyPlayer").css("pointer-events", "auto");
    $(".Keys").empty();
    updateLocales();
    event.data.data.forEach((item) => {
      $(".Keys").append(
        `<div class="Key">
          <div class="KeyName">${item.Key}</div>
          <div class="KeyInfo">${item.Label}</div>
        </div>`
      );
    });
  } else if (event.data.action == "requestBaseUrl") {
    try {
      const baseUrl = await convertImage(event.data.headShotTxd);
      $.post(
        `https://BakiTelli_paintballv2/resolveBaseUrl`,
        JSON.stringify({ url: baseUrl })
      );
    } catch (error) {
      console.error("Error converting image:", error);
    }
  } else if (event.data.action == "getData") {
    $(".container-c-c-Lobbys").empty();
    $(".container-topside-profileside-text > p").text("$" + event.data.Money);
    $(".container-topside-profileside-text > t").text(event.data.Name);
    $(".container-topside-profileside > img").attr("src", event.data.Profile);
    playerMarketData = event.data.MarketData || {};
    lobbyCreatePrice = event.data.LobbyCreatePrice || 0;
    const createButtonText =
      lobbyCreatePrice > 0
        ? `${currentLocales["create_lobby_button"]} ($${lobbyCreatePrice})`
        : currentLocales["create_lobby_button"];
    $(".createLobbyButtonCL t").html(createButtonText);
  } else if (event.data.action == "addLobby") {
    const password = event.data.data.password;
    const lockedClass =
      password && password !== null && password !== "" ? "locked" : "opened";
    $(".container-c-c-Lobbys").append(
      `
                    <div class="container-c-c-Lobby">
                <div class="container-c-c-l-TopSide">
                  <div class="LobbyName">${event.data.data.lobbyName}</div>
                  <div class="lobbyLocked ${lockedClass}">
                    <div></div>
                  </div>
                </div>
                <div class="LobbyMap" style="background-image: url(${event.data.data.mapImg})">

                </div>
                <div class="LobbyTimePlayer">
                  <div class="LobbyTime">
                    <img src="./img/time_icon.svg" />
                    <t>Time</t>
                    <div>${event.data.data.time}M</div>
                  </div>
                  <div class="LobbyPlayers">
                    <img src="./img/player_icon.svg" />
                    <t>Player</t>
                    <div>${event.data.data.totalPlayer}/${event.data.data.player}</div>
                  </div>
                </div>
                <div class="LobbySettingText">${currentLocales["lobby_settings"]};</div>
                <div class="LobbyGameMode">
                  <img src="./img/gamemode_icon.svg" />
                  <t>${currentLocales["game_mode"]}</t>
                  <div>${event.data.data.gameMode}</div>
                </div>
                <div class="LobbyGameWeapon">
                  <img src="./img/gameweapon_icon.svg" />
                  <t>${currentLocales["weapon"]}</t>
                  <div>${event.data.data.weapon}</div>
                </div>
                <div class="LobbyJoin" onclick="clickAction('joinLobby', '${event.data.data.lobbyName}')">${currentLocales["lobby_join"]}</div>
              </div>
      `
    );
  } else if (event.data.action == "joinedTeam") {
    DefaultClose("noClosed");
    $(".LobbyBG").css("display", "flex");
    isLobbyOpen = true;
    if (event.data.update == false) {
      if (event.data.status == "player") {
        $("#lobbyin_Setting").css("opacity", "0.5");
        $("#lobbyin_Setting").css("pointer-events", "none");
        $(".playMatchButton").css("opacity", "0.5");
        $(".playMatchButton").css("pointer-events", "none");
      } else {
        $("#lobbyin_Setting").css("opacity", "1");
        $("#lobbyin_Setting").css("pointer-events", "auto");
        $(".playMatchButton").css("opacity", "1");
        $(".playMatchButton").css("pointer-events", "auto");
      }
      if (event.data.team == "red") {
        $(".joinBlue").css("opacity", "1");
        $(".joinBlue").css("pointer-events", "auto");
        $(".joinRed").css("opacity", "0.5");
        $(".joinRed").css("pointer-events", "none");
      } else {
        $(".joinRed").css("opacity", "1");
        $(".joinRed").css("pointer-events", "auto");
        $(".joinBlue").css("opacity", "0.5");
        $(".joinBlue").css("pointer-events", "none");
      }
    }
  } else if (event.data.action == "updateLobby") {
    $("#lobbyin_LobbyName").text(event.data.lobby.name);
    $("#lobbyin_GameMode").text(event.data.lobby.gameMode);
    $("#lobbyin_GameWeapon").text(event.data.lobby.weapon);
    $("#lobbyin_TotalPlayer").text(
      event.data.lobby.totalPlayer + "/" + event.data.lobby.player
    );
    $("#lobbyin_Time").text(event.data.lobby.time + "M");
  } else if (event.data.action == "exitLobby") {
    DefaultClose("noClosed");
  } else if (event.data.action == "updateMarketData") {
    playerMarketData = event.data.data;
    updateMarketItems();
  } else if (event.data.action == "closeAll") {
    $(".container").css("display", "none");
    $(".LobbyBG").css("display", "none");
  } else if (event.data.action == "gameStarted") {
    $(".gameInsideUI").css("display", "flex");
  } else if (event.data.action == "showCountdown") {
    // Her sayı bir sonraki gelene kadar (en fazla 1 sn) ekranda kalır; önceki sayının
    // gizleme zamanlayıcısı iptal edilir ki 2 ve 1 erken silinmesin.
    clearTimeout(window.pbCountdownHide);
    $(".Timer").text(event.data.time).css("display", "block").show();
    window.pbCountdownHide = setTimeout(() => {
      $(".Timer").css("display", "none").hide();
    }, 1000);
  } else if (event.data.action == "showScoreboard") {
    if (event.data.show) {
      $(".gameInsideUI").show();
      $(".scoreboardSide").show();
    } else {
      $(".scoreboardSide").hide();
    }
  } else if (event.data.action == "hideScoreboard") {
    $(".scoreboardSide").hide();
  } else if (event.data.action == "updateTimer") {
    $(".InsidescoreboardTime > t").text(event.data.time);

    if ($(".bigScoreboard").is(":visible")) {
      $(".BigScoreboardTimeBG > t").text(event.data.time);
    }
  } else if (event.data.action == "updateScore") {
    $(".redScoreboard > p").text(event.data.red);
    $(".blueScoreboard > p").text(event.data.blue);

    if ($(".bigScoreboard").is(":visible")) {
      $(".blueBigScoreboardVersus").text(event.data.blue);
      $(".redBigScoreboardVersus").text(event.data.red);
    }
  } else if (event.data.action == "showResult") {
    if (event.data.result === "win") {
      $(".winner-text").show();
      setTimeout(() => {
        $(".winner-text").hide();
      }, 4500);
    } else if (event.data.result === "lose") {
      $(".lose-text").show();
      setTimeout(() => {
        $(".lose-text").hide();
      }, 4500);
    }
  } else if (event.data.action == "killMessage") {
    const killData = event.data.data;

    if (killData) {
      const killerName = killData.killerName || "Unknown";
      const killedName = killData.killedName || "Unknown";
      const wasKilledByPlayer = killData.wasKilledByPlayer;

      const messageId = Date.now() + Math.random();

      const killMessageHtml = `
          <div class="killboardMessageSide" data-message-id="${messageId}" style="transform: translateX(100%); transition: transform 0.5s ease;">
              <div class="killboardMessage">
                  <t>${killerName}</t>
                  <img src="./img/weapon_photo.svg" />
                  <t2>${killedName}</t2>
              </div>
              <div class="killboardLine"></div>
          </div>
      `;

      $(".killboardMessages").prepend(killMessageHtml);

      const currentMessage = $(
        `.killboardMessages .killboardMessageSide[data-message-id="${messageId}"]`
      );

      setTimeout(() => {
        currentMessage.css("transform", "translateX(0)");
      }, 50);

      setTimeout(() => {
        currentMessage.css("transform", "translateX(100%)");

        setTimeout(() => {
          currentMessage.remove();
        }, 500);
      }, 4000);

      if ($(".killboardMessages .killboardMessageSide").length > 5) {
        $(".killboardMessages .killboardMessageSide:last-child").remove();
      }
    }

    if (event.data.scoreboardData) {
      updateBigScoreboard(event.data.scoreboardData);
    }
  } else if (event.data.action == "showBigScoreboard") {
    const data = event.data.data;

    $(".blueBigScoreboardVersus").text(data.blueScore || 0);
    $(".redBigScoreboardVersus").text(data.redScore || 0);

    const timeStr = formatScoreboardTime(data.timeRemaining || 0);
    $(".BigScoreboardTimeBG > t").text(timeStr);

    $(".bigScoreboardBluePlayers").empty();
    if (data.bluePlayers && data.bluePlayers.length > 0) {
      data.bluePlayers.forEach((player) => {
        $(".bigScoreboardBluePlayers").append(`
          <div>
            <img src="${player.mugshot}" />
            <t>${player.name}</t>
            <div class="bigScoreboardBluePlayerRight">
              <div class="bigScoreboardDeath">${player.deaths} ${currentLocales["death"]}</div>
              <div class="bigScoreboardKills">${player.kills} ${currentLocales["kills"]}</div>
            </div>
          </div>
        `);
      });
    }

    $(".bigScoreboardRedPlayers").empty();
    if (data.redPlayers && data.redPlayers.length > 0) {
      data.redPlayers.forEach((player) => {
        $(".bigScoreboardRedPlayers").append(`
          <div>
            <img src="${player.mugshot}" />
            <t>${player.name}</t>
            <div class="bigScoreboardBluePlayerRight">
              <div class="bigScoreboardDeath">${player.deaths} ${currentLocales["death"]}</div>
              <div class="bigScoreboardKills">${player.kills} ${currentLocales["kills"]}</div>
            </div>
          </div>
        `);
      });
    }

    $(".bigScoreboard").fadeIn(200);
  } else if (event.data.action == "hideBigScoreboard") {
    $(".bigScoreboard").fadeOut(200);
  } else if (event.data.action == "hideAll") {
    $(".Timer").hide();
    $(".gameInsideUI").hide();
    $(".winner-text").hide();
    $(".lose-text").hide();
  }
});

$(document).on("keydown", function (event) {
  switch (event.keyCode) {
    case 27:
      if (isLobbyOpen == false) {
        DefaultClose();
      }
      break;
  }
});

function DefaultClose(type) {
  if (type == null) {
    $.post(`https://BakiTelli_paintballv2/close`);
  }
  $(".container").css("display", "none");
  $(".LobbyListMenus").css("display", "none");
  $(".LobbyCreate").css("display", "none");
  $(".LobbyBG").css("display", "none");
  $(".productList").css("display", "none");
  $(".gameInsideUI").css("display", "none");
  isLobbyOpen = false;
}

function clickAction(action, index) {
  if (action == "categoryMenu") {
    $(".categoryMenu").removeClass("useCategory");
    $(`#categoryMenu-${index}`).addClass("useCategory");
    if (index == 2) {
      $(".LobbyCreate").css("display", "none");
      $(".LobbyListMenu").css("display", "none");
      $(".productList").css("display", "flex");
      $.post(
        `https://BakiTelli_paintballv2/action`,
        JSON.stringify({
          action: "openMarket",
        }),
        function (data) {
          if (data.action == "openMarket") {
            $(".container-c-c-products").empty();
            playerMarketData = data.playerData || {};

            Object.entries(data.data || {})
              .sort(([, a], [, b]) => {
                if (a.price === "default") return -1;
                if (b.price === "default") return 1;
                return a.price - b.price;
              })
              .forEach(([key, item], index) => {
                const playerItem = playerMarketData[key] || {
                  owned: false,
                  equipped: false,
                };
                const isDefault = item.price === "default";
                const priceText = isDefault ? "Default" : `$ ${item.price}`;

                let buttonHtml = "";
                if (isDefault || playerItem.owned) {
                  if (playerItem.equipped) {
                    buttonHtml = `
                      <div class="productBottomButton" style="background: rgba(76, 255, 109, 0.15); color: rgba(76, 255, 109, 0.8);">
                        <t>${currentLocales["equipped_text"]}</t>
                      </div>`;
                  } else {
                    buttonHtml = `
                      <div class="productBottomButton" onclick="clickAction('equipItem', '${key}')" style="background: #c8102e; color: #fff;">
                        <t>${currentLocales["equip"]}</t>
                      </div>`;
                  }
                } else {
                  buttonHtml = `
                    <div class="productBottomButton" onclick="clickAction('buyItem', '${key}')">
                      <img src="./img/productbottom_icon.svg" />
                      <t>${currentLocales["buy_it"]}</t>
                    </div>`;
                }

                $(".container-c-c-products").append(
                  `
                  <div class="container-c-c-product" data-item-key="${key}">
                  <div class="productTopText">
                    <t>${item.label}</t>
                    <p>${item.type}</p>
                  </div>
                  <div class="productImage" style="background-image: url(${item.image})"></div>
                  <div class="productBottom">
                    <div class="productPrice">${priceText}</div>
                    ${buttonHtml}
                  </div>
                </div>
                  `
                );
              });
          }
        }
      );
    } else if (index == 1) {
      $(".LobbyListMenu").css("display", "flex");
      $(".productList").css("display", "none");
      $(".LobbyCreate").css("display", "none");
    }
  } else if (action == "searchLobby") {
    const search = index.toLowerCase();
    $(".container-c-c-Lobby").each(function () {
      const lobbyName = $(this).find(".LobbyName").text().toLowerCase();

      if (lobbyName.includes(search)) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  } else if (action == "searchProduct") {
    const search = index.toLowerCase();
    $(".container-c-c-product").each(function () {
      const productName = $(this)
        .find(".productTopText > t")
        .text()
        .toLowerCase();
      if (productName.includes(search)) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  } else if (action == "createLobbyMenu") {
    $(".categoryMenu").removeClass("useCategory");
    $(".LobbyListMenu").css("display", "none");
    $(".productList").css("display", "none");
    $(".LobbyCreate").css("display", "flex");
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
      }),
      function (data) {
        if (data.action == "createLobbyMenu") {
          $(".createLobbyPassword > input").val("");

          lobbyCreatePrice = data.data.lobbyCreatePrice || 0;
          const createButtonText =
            lobbyCreatePrice > 0
              ? `${currentLocales["create_lobby_button"]} ($${lobbyCreatePrice})`
              : currentLocales["create_lobby_button"];
          $(".createLobbyButtonCL t").html(createButtonText);

          selectLobbyDetails.time = 5;
          $(".createLobbyContainer.LobbyTime > t").text(
            selectLobbyDetails.time
          );

          selectLobbyDetails.lobbyName = data.data.lobbyName;
          $("#lobbyName").val(selectLobbyDetails.lobbyName);

          selectLobbyDetails.player = 10;
          $(".createLobbyContainer.LobbyPlayer > t").text(
            selectLobbyDetails.player
          );

          $(".createLobbyMaps").empty();
          selectLobbyDetails.map = 1;
          data.data.maps.forEach((map, index) => {
            $(".createLobbyMaps").append(
              `<div class="createLobbyMap" onclick="clickAction('selectMap', ${
                index + 1
              })" id="map-${index + 1}" style="background-image: url(${
                map.map_img
              })"></div>`
            );
          });
          $("#map-" + selectLobbyDetails.map).addClass("selectMap");

          const $gameModeSelect = $(".createLobbyGameMode.gameMode > select");
          $gameModeSelect.empty();
          Object.entries(data.data.gameModes).forEach(([key, gameMode]) => {
            $gameModeSelect.append(
              `<option id="${key}" value="${key}">${gameMode.label}</option>`
            );
          });
          $gameModeSelect.val("KillHunt");
          selectLobbyDetails.gameMode = "KillHunt";

          const $weaponSelect = $(".createLobbyGameMode.gameWeapon > select");
          $weaponSelect.empty();
          Object.entries(data.data.weapons).forEach(([key, weapon]) => {
            $weaponSelect.append(
              `<option id="${key}" value="${key}">${weapon.label}</option>`
            );
          });
          $weaponSelect.val("pistol");
          selectLobbyDetails.weapon = "pistol";

          if (selectLobbyDetails.gameMode === "RandomArsenal") {
            $weaponSelect.prop("disabled", true);
            $weaponSelect.css("opacity", "0.5");
          } else {
            $weaponSelect.prop("disabled", false);
            $weaponSelect.css("opacity", "1");
          }
        }
      }
    );
  } else if (action == "selectMap") {
    selectLobbyDetails.map = index;
    $(".createLobbyMap").removeClass("selectMap");
    $("#map-" + index).addClass("selectMap");
  } else if (action == "selectTime") {
    if (index == 1) {
      if (selectLobbyDetails.time > 1) {
        selectLobbyDetails.time--;
      }
    } else {
      if (selectLobbyDetails.time < 30) {
        selectLobbyDetails.time++;
      }
    }
    $(".createLobbyContainer.LobbyTime > t").text(selectLobbyDetails.time);
  } else if (action == "selectPlayer") {
    if (index == 1) {
      if (selectLobbyDetails.player > 2) {
        selectLobbyDetails.player -= 2;
      }
    } else {
      if (selectLobbyDetails.player < 10) {
        selectLobbyDetails.player += 2;
      }
    }
    $(".createLobbyContainer.LobbyPlayer > t").text(selectLobbyDetails.player);
  } else if (action == "createLobby") {
    selectLobbyDetails.password = $(".createLobbyPassword > input").val();
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
        data: selectLobbyDetails,
      })
    );
  } else if (action == "joinTeam") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
        team: index,
      })
    );
  } else if (action == "quitLobby") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
      })
    );
  } else if (action == "lobbySettings") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
      }),
      function (data) {
        if (data.action == "lobbySettings") {
          $(".LobbyBG").css("display", "none");
          $(".container").css("display", "flex");
          $(".container-c-leftside").css("display", "none");
          $(".LobbyCreate").css("display", "flex");
          $("#lobbyName").val(data.data.lobbyName);
          $(".createLobbyPassword > input").val(data.data.password);
          selectLobbyDetails.time = data.data.time;
          $(".createLobbyContainer.LobbyTime > t").text(
            selectLobbyDetails.time
          );
          selectLobbyDetails.player = data.data.player;
          $(".createLobbyContainer.LobbyPlayer > t").text(
            selectLobbyDetails.player
          );
          selectLobbyDetails.gameMode = data.data.gameMode;
          $(".createLobbyGameMode.gameMode > select").val(
            selectLobbyDetails.gameMode
          );
          selectLobbyDetails.weapon = data.data.weapon;
          $(".createLobbyGameMode.gameWeapon > select").val(
            selectLobbyDetails.weapon
          );
          selectLobbyDetails.map = data.data.map;
          $("#map-" + selectLobbyDetails.map).addClass("selectMap");

          const $weaponSelect = $(".createLobbyGameMode.gameWeapon > select");
          if (data.data.gameMode === "RandomArsenal") {
            $weaponSelect.prop("disabled", true);
            $weaponSelect.css("opacity", "0.5");
          } else {
            $weaponSelect.prop("disabled", false);
            $weaponSelect.css("opacity", "1");
          }

          $(".LobbyPlayer").css("opacity", "0.5");
          $(".LobbyPlayer").css("pointer-events", "none");

          $(".createLobbyButtonCL t").html(currentLocales["update_lobby"]);
        }
      }
    );
  } else if (action == "joinLobby") {
    const clickedLobby = $(".LobbyName")
      .filter(function () {
        return $(this).text() === index;
      })
      .closest(".container-c-c-Lobby");
    const isLocked = clickedLobby.find(".lobbyLocked").hasClass("locked");
    if (isLocked) {
      $(".containerPopupBG").css("display", "flex");
      $(".containerPopup > t").text(index);
    } else {
      $.post(
        `https://BakiTelli_paintballv2/action`,
        JSON.stringify({
          action: "joinLobbyPassword",
          password: false,
          lobbyName: index,
        })
      );
    }
  } else if (action == "joinLobbyPassword") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
        password: $(".containerPopup > input").val(),
        lobbyName: $(".containerPopup > t").text(),
      })
    );
    $(".containerPopup > input").val("");
    $(".containerPopupBG").css("display", "none");
  } else if (action == "buyItem") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
        itemKey: index,
      })
    );
  } else if (action == "equipItem") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: action,
        itemKey: index,
      })
    );
  } else if (action == "playMatch" || action == "startMatch") {
    $.post(
      `https://BakiTelli_paintballv2/action`,
      JSON.stringify({
        action: "startMatch",
      })
    );
  }
}

const $weaponSelect = $(".createLobbyGameMode.gameWeapon > select");
$weaponSelect.on("change", function () {
  selectLobbyDetails.weapon = $(this).val();
});

const $gameModeSelect = $(".createLobbyGameMode.gameMode > select");
$gameModeSelect.on("change", function () {
  selectLobbyDetails.gameMode = $(this).val();

  const $weaponSelect = $(".createLobbyGameMode.gameWeapon > select");
  if ($(this).val() === "RandomArsenal") {
    $weaponSelect.prop("disabled", true);
    $weaponSelect.css("opacity", "0.5");
  } else {
    $weaponSelect.prop("disabled", false);
    $weaponSelect.css("opacity", "1");
  }
});

function updateMarketItems() {
  $(".container-c-c-product").each(function () {
    const itemKey = $(this).data("item-key");
    const playerItem = playerMarketData[itemKey] || {
      owned: false,
      equipped: false,
    };
    const productBottomButton = $(this).find(".productBottomButton");
    const productPrice = $(this).find(".productPrice");

    const isDefault = productPrice.text() === "Default";

    if (isDefault || playerItem.owned) {
      if (playerItem.equipped) {
        productBottomButton
          .html(
            `
          <t>${currentLocales["equipped_text"]}</t>
        `
          )
          .css({
            background: "rgba(76, 255, 109, 0.15)",
            color: "rgba(76, 255, 109, 0.8)",
          })
          .attr("onclick", "");
      } else {
        productBottomButton
          .html(
            `
          <t>${currentLocales["equip"]}</t>
        `
          )
          .css({
            background: "rgba(255, 193, 7, 0.15)",
            color: "rgba(255, 193, 7, 0.8)",
          })
          .attr("onclick", `clickAction('equipItem', '${itemKey}')`);
      }
    } else {
      productBottomButton
        .html(
          `
        <img src="./img/productbottom_icon.svg" />
        <t>Buy it</t>
      `
        )
        .css({
          background: "rgba(255, 255, 255, 0.08)",
          color: "rgba(255, 255, 255, 0.32)",
        })
        .attr("onclick", `clickAction('buyItem', '${itemKey}')`);
    }
  });
}

function formatScoreboardTime(seconds) {
  if (seconds <= 0) {
    return "00:00";
  }
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes.toString().padStart(2, "0")}:${remainingSeconds
    .toString()
    .padStart(2, "0")}`;
}

function convertImage(txd, outputFormat = "image/png") {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = "Anonymous";
    img.onload = () => {
      try {
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");
        if (!ctx) {
          throw new Error("Failed to get 2D context.");
        }
        canvas.height = img.naturalHeight;
        canvas.width = img.naturalWidth;
        ctx.drawImage(img, 0, 0);
        resolve(canvas.toDataURL(outputFormat));
        canvas.remove();
      } catch (error) {
        reject(error);
      } finally {
        img.remove();
      }
    };
    img.onerror = () => reject(new Error("Failed to load image."));
    img.src = `https://nui-img/${txd}/${txd}`;
  });
}

function updateBigScoreboard(data) {
  if (!$(".bigScoreboard").is(":visible")) {
    return;
  }

  $(".blueBigScoreboardVersus").text(data.blueScore || 0);
  $(".redBigScoreboardVersus").text(data.redScore || 0);

  const timeStr = formatScoreboardTime(data.timeRemaining || 0);
  $(".BigScoreboardTimeBG > t").text(timeStr);

  $(".bigScoreboardBluePlayers").empty();
  if (data.bluePlayers && data.bluePlayers.length > 0) {
    data.bluePlayers.forEach((player) => {
      $(".bigScoreboardBluePlayers").append(`
        <div>
          <img src="${player.mugshot}" />
          <t>${player.name}</t>
          <div class="bigScoreboardBluePlayerRight">
            <div class="bigScoreboardDeath">${player.deaths} ${currentLocales["death"]}</div>
            <div class="bigScoreboardKills">${player.kills} ${currentLocales["kills"]}</div>
          </div>
        </div>
      `);
    });
  }

  $(".bigScoreboardRedPlayers").empty();
  if (data.redPlayers && data.redPlayers.length > 0) {
    data.redPlayers.forEach((player) => {
      $(".bigScoreboardRedPlayers").append(`
        <div>
          <img src="${player.mugshot}" />
          <t>${player.name}</t>
          <div class="bigScoreboardBluePlayerRight">
            <div class="bigScoreboardDeath">${player.deaths} ${currentLocales["death"]}</div>
            <div class="bigScoreboardKills">${player.kills} ${currentLocales["kills"]}</div>
          </div>
        </div>
      `);
    });
  }
}

function updateLocales() {
  document.querySelectorAll("[data-locale]").forEach((element) => {
    const key = element.getAttribute("data-locale");
    if (currentLocales[key]) {
      if (
        element.tagName.toLowerCase() === "input" ||
        element.tagName.toLowerCase() === "textarea"
      ) {
        element.placeholder = currentLocales[key];
      } else {
        element.textContent = currentLocales[key];
      }
    }
  });
}
