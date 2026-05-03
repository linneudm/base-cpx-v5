$(document).ready(function () {
  let uiVisible = false;

  const imageProviders = [
    (model) => `https://docs.fivem.net/vehicles/${model}.webp`,
    (model) => `https://docs.fivem.net/vehicles/${model}.png`,
  ];

  function buildFallbackSvg(modelName) {
    const name = (modelName || "vehicle").toUpperCase();
    const svg = `<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 640 240'>
<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'><stop stop-color='#0f172a'/><stop offset='1' stop-color='#1e293b'/></linearGradient></defs>
<rect width='640' height='240' fill='url(#g)'/>
<path d='M110 150h420l-18-34c-10-18-26-30-46-34l-76-14c-23-4-47-4-70 0l-76 14c-20 4-36 16-46 34z' fill='#334155'/>
<circle cx='185' cy='160' r='26' fill='#0b1220'/><circle cx='455' cy='160' r='26' fill='#0b1220'/>
<text x='320' y='215' text-anchor='middle' fill='#67e8f9' font-family='Segoe UI, Arial' font-size='24' letter-spacing='2'>${name}</text>
</svg>`;
    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;
  }

  function setVehicleImage(modelName) {
    const model = (modelName || "adder")
      .toLowerCase()
      .replace(/[^a-z0-9_]/g, "");
    const fallback = buildFallbackSvg(model || "vehicle");
    let providerIndex = 0;

    const loadNext = () => {
      if (providerIndex >= imageProviders.length) {
        $("#vehicleImage").attr("src", fallback);
        return;
      }

      const testImage = new Image();
      const url = imageProviders[providerIndex](model);
      testImage.onload = function () {
        $("#vehicleImage").attr("src", url);
      };
      testImage.onerror = function () {
        providerIndex += 1;
        loadNext();
      };
      testImage.src = url;
    };

    loadNext();
  }

  function showFuelUi() {
    if (uiVisible) return;
    uiVisible = true;
    $("#fuelWrap").show();
    $("#fuelPanel").removeClass("nui-exit").addClass("nui-enter");
  }

  function hideFuelUi() {
    if (!uiVisible) return;
    uiVisible = false;
    $("#fuelPanel").removeClass("nui-enter").addClass("nui-exit");
    $("#fuelPanel").one("animationend", function () {
      if (!uiVisible) {
        $("#fuelWrap").hide();
      }
    });
  }

  window.addEventListener("message", function (event) {
    const data = event.data || {};

    if (data.show !== undefined) {
      if (data.show === true) {
        if (data.title !== undefined) $("#title").text(data.title);
        if (data.legends !== undefined) $("#legends").text(data.legends);
        if (data.vehicle !== undefined) $("#vehicle").text(data.vehicle);
        if (data.vehicleModel !== undefined) setVehicleImage(data.vehicleModel);
        showFuelUi();
      } else {
        hideFuelUi();
      }
    }

    if (data.tank !== undefined) $("#tank").text(data.tank);
    if (data.price !== undefined) $("#price").text(data.price);
    if (data.lts !== undefined) $("#lts").text(data.lts);
    if (data.vehicle !== undefined) $("#vehicle").text(data.vehicle);
    if (data.vehicleModel !== undefined) setVehicleImage(data.vehicleModel);
  });
});
