(() => {
  const activeKeys = new Set();
  const keyMap = {
    KeyA: "Left",
    KeyD: "Right",
    KeyW: "Top",
    KeyS: "Bottom",
  };

  const isEditableTarget = (target) => {
    if (!target) return false;
    const tag = (target.tagName || "").toUpperCase();
    return tag === "INPUT" || tag === "TEXTAREA" || target.isContentEditable;
  };

  const sendRotate = async (direction) => {
    try {
      const resourceName =
        typeof GetParentResourceName === "function"
          ? GetParentResourceName()
          : null;

      if (!resourceName) return;

      await fetch(`https://${resourceName}/Rotate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ direction }),
      });
    } catch (_) {
      // Ignore fetch errors to avoid breaking UI inputs.
    }
  };

  const tick = () => {
    if (!activeKeys.size) return;
    activeKeys.forEach((keyCode) => {
      const direction = keyMap[keyCode];
      if (direction) sendRotate(direction);
    });
  };

  window.addEventListener("keydown", (event) => {
    if (event.repeat || isEditableTarget(event.target)) return;
    if (!keyMap[event.code]) return;

    activeKeys.add(event.code);
    event.preventDefault();
  });

  window.addEventListener("keyup", (event) => {
    if (!keyMap[event.code]) return;

    activeKeys.delete(event.code);
    event.preventDefault();
  });

  window.addEventListener("blur", () => {
    activeKeys.clear();
  });

  setInterval(tick, 75);
})();
