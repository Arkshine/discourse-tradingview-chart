import { apiInitializer } from "discourse/lib/api";
import { tryCatch } from "../lib/util";

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();

  const allowedGroupIds = new Set(
    settings.allowed_groups.split("|").map(Number)
  );
  const userAllowed =
    allowedGroupIds.has(0 /* everyone */) ||
    currentUser?.groups.some((group) => allowedGroupIds.has(group.id));

  window.I18n.translations[window.I18n.locale].js.composer.tradingview_sample =
    settings.default_chart_options;

  if (userAllowed) {
    api.onToolbarCreate((toolbar) => {
      toolbar.addButton({
        title: themePrefix("tradingview"),
        id: "tradingview-widget",
        group: "insertions",
        icon: "chart-simple",
        perform: (toolbarEvent) => {
          toolbarEvent.applySurround(
            "\n[wrap=tradingview]\n",
            "\n[/wrap]\n",
            "tradingview_sample",
            { multiline: false }
          );
        },
      });
    });
  }

  function renderTradingview(element, helper) {
    const options = element.textContent
      .trim()
      .replace(/“/g, '"')
      .replace(/”/g, '"')
      .replace(/‘/g, "'")
      .replace(/’/g, "'");

    const { data, error } = tryCatch(() => JSON.parse(options));

    if (error) {
      // eslint-disable-next-line no-console
      console.error("Error parsing JSON:", error);
      return;
    }

    if (!data.height) {
      element.classList.add("dynamic-container");
    }

    element.textContent = "";

    helper.renderGlimmer(
      element,
      <template>
        <div class="tradingview-widget-container">
          <div class="tradingview-widget-container__widget"></div>
          <div class="tradingview-widget-copyright">
            <a
              href="https://www.tradingview.com/"
              rel="noopener noreferrer"
              target="_blank"
            >
              <span class="blue-text">Track all markets on TradingView</span>
            </a>
          </div>
          {{! template-lint-disable no-forbidden-elements }}
          <script
            type="text/javascript"
            src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js"
            async
          >
            {{options}}
          </script>
        </div>
      </template>
    );
  }

  api.decorateCookedElement((element, helper) => {
    if (!helper.renderGlimmer) {
      return;
    }

    const widgetElements = element.querySelectorAll(
      "[data-wrap='tradingview']"
    );
    if (!widgetElements.length) {
      return;
    }

    widgetElements.forEach((widgetElement) => {
      renderTradingview(widgetElement, helper);
    });
  });
});
