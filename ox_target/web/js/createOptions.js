const optionsWrapper = document.getElementById("options-wrapper");

/**
 * Builds one row of the options list. The row keeps what the client needs to run it.
 * @returns {HTMLDivElement | undefined}
 */
export function createOptions(type, data, id, zoneId) {
  if (data.hide) return;

  const option = document.createElement("div");
  const icon = document.createElement("i");
  const label = document.createElement("p");

  icon.className = `fa-fw ${data.icon || "fa-solid fa-circle"} option-icon`;
  if (data.iconColor) icon.style.color = data.iconColor;

  label.className = "option-label";
  label.textContent = data.label;

  option.className = "option-container";
  option.append(icon, label);
  option.target = [type, id, zoneId];
  option.label = data.label;
  // not option.title: that is the element's tooltip attribute, and undefined there becomes the text "undefined"
  option.groupTitle = typeof data.title === "string" && data.title !== "" ? data.title : null;

  optionsWrapper.appendChild(option);

  return option;
}
