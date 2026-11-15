import { createOptions } from "./createOptions.js";
import { fetchNui } from "./fetchNui.js";

const body = document.body;
const dotsEl = document.getElementById("dots");
const promptEl = document.getElementById("prompt");
const promptKey = document.getElementById("prompt-key");
const promptLabel = document.getElementById("prompt-label");
const promptCount = document.getElementById("prompt-count");
const menuEl = document.getElementById("menu");
const optionsWrapper = document.getElementById("options-wrapper");

const strings = { interact: "Etkileşim" };
const gap = 16 / 1080; // listenin noktadan uzaklığı, ekran yüksekliğine göre

let rows = [];
let selected = 0;
let open = false;
let anchor = null;

function render() {
  rows.forEach((row, i) => row.classList.toggle("selected", open && i === selected));

  const hasRows = rows.length > 0;

  if (rows.length === 1) {
    promptLabel.textContent = rows[0].label;
    promptCount.textContent = "";
  } else {
    // DaddyRP: options that share a title (e.g. an NPC's name) show it instead of the generic word
    const title = hasRows && rows[0].groupTitle && rows.every((row) => row.groupTitle === rows[0].groupTitle) ? rows[0].groupTitle : null;
    promptLabel.textContent = title || strings.interact;
    promptCount.textContent = hasRows ? rows.length : "";
  }

  promptEl.classList.toggle("show", hasRows && !open && !!anchor);
  menuEl.classList.toggle("show", hasRows && open && !!anchor);
  place();
}

// Uyarı noktanın ortasında, liste noktanın sağında; ikisi de ekrandan taşmaz.
function place() {
  if (!anchor) return;

  const w = window.innerWidth;
  const h = window.innerHeight;
  const x = anchor[0] * w;
  const y = anchor[1] * h;

  if (open) {
    const mw = menuEl.offsetWidth;
    const mh = menuEl.offsetHeight;
    let left = x + gap * h;
    if (left + mw > w - 8) left = x - gap * h - mw;
    const top = Math.min(Math.max(y - mh / 2, 8), h - mh - 8);

    menuEl.style.left = `${Math.max(left, 8)}px`;
    menuEl.style.top = `${top}px`;
  } else {
    // transform yalnızca kompozisyonu tetikler, her karede layout hesaplanmaz.
    promptEl.style.transform = `translate(${x}px, ${y}px) translate(-50%, -50%)`;
  }
}

function setDots(list) {
  while (dotsEl.children.length < list.length) {
    const dot = document.createElement("div");
    dot.className = "dot";
    dotsEl.appendChild(dot);
  }

  while (dotsEl.children.length > list.length) dotsEl.lastChild.remove();

  const w = window.innerWidth;
  const h = window.innerHeight;

  list.forEach(([x, y], i) => {
    dotsEl.children[i].style.transform = `translate(${x * w}px, ${y * h}px)`;
  });
}

function clear() {
  optionsWrapper.innerHTML = "";
  rows = [];
  selected = 0;
  open = false;
  render();
}

window.addEventListener("message", (event) => {
  const data = event.data;

  switch (data.event) {
    case "strings": {
      Object.assign(strings, data);
      promptKey.textContent = data.key || "E";
      document.getElementById("hint-key").textContent = data.key || "E";
      document.getElementById("hint-select").textContent = data.select;
      document.getElementById("hint-confirm").textContent = data.confirm;
      document.getElementById("hint-close").textContent = data.close;
      return;
    }

    case "visible": {
      body.style.visibility = data.state ? "visible" : "hidden";
      anchor = null;
      setDots([]);
      return clear();
    }

    case "leftTarget":
      return clear();

    case "setTarget": {
      // Seçenekler yenilenince seçili satır yerinde kalsın.
      const previous = open && rows[selected] ? rows[selected].label : null;
      optionsWrapper.innerHTML = "";
      rows = [];
      selected = 0;

      if (data.options) {
        for (const type in data.options) {
          data.options[type].forEach((option, id) => {
            const row = createOptions(type, option, id + 1);
            if (row) rows.push(row);
          });
        }
      }

      if (data.zones) {
        for (let i = 0; i < data.zones.length; i++) {
          data.zones[i].forEach((option, id) => {
            const row = createOptions("zones", option, id + 1, i + 1);
            if (row) rows.push(row);
          });
        }
      }

      if (previous !== null) selected = Math.max(rows.findIndex((row) => row.label === previous), 0);

      return render();
    }

    case "open":
      open = true;
      selected = 0;
      return render();

    case "close":
      open = false;
      return render();

    case "nav": {
      if (!open || rows.length === 0) return;
      selected = (selected + data.dir + rows.length) % rows.length;
      return render();
    }

    case "confirm": {
      const row = rows[open ? selected : 0];
      if (row) fetchNui("select", row.target);
      return;
    }

    case "frame": {
      const hadAnchor = !!anchor;
      // Liste açıkken nokta ekrandan çıkarsa liste son yerinde kalır.
      if (data.p || !open) anchor = data.p;

      if (!!anchor !== hadAnchor) return render();
      return place();
    }
  }
});
