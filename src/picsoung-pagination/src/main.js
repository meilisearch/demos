import "./style.css";
import "./meilisearch.min.css";
import { instantMeiliSearch } from "@meilisearch/instant-meilisearch";
import instantsearch from "instantsearch.js";
import {
  searchBox,
  hits,
  configure,
  pagination,
  hitsPerPage,
} from "instantsearch.js/es/widgets";
import { connectConfigure } from "instantsearch.js/es/connectors";
const MEILISEARCH_HOST = import.meta.env.VITE_MEILI_HOST;
const MEILISEARCH_API_KEY = import.meta.env.VITE_MEILI_SEARCH_API_KEY;

const searchClient = instantMeiliSearch(MEILISEARCH_HOST, MEILISEARCH_API_KEY, {
  limitPerRequest: 30,
  finitePagination: true,
});

const moviesIndex = instantsearch({
  indexName: "movies",
  searchClient,
});

const renderConfigure = (renderOptions, isFirstRender) => {
  const { refine, widgetParams } = renderOptions;

  if (isFirstRender) {
    const leftInfo = document.getElementById("left-info");
    const rightInfo = document.getElementById("right-info");
    const button = document.createElement("button");
    const pre = document.createElement("pre");
    const code = document.createElement("code");
    button.className = "btn btn-dodger-blue btn-lg";
    pre.className = "my-1";
    code.className = "body body-code";

    widgetParams.container.appendChild(leftInfo);
    widgetParams.container.appendChild(rightInfo);
    rightInfo.appendChild(pre);
    pre.appendChild(code);
  }

  if (renderOptions.instantSearchInstance.helper) {
    widgetParams.searchParameters.hitsPerPage =
      renderOptions.instantSearchInstance.helper.lastResults.hitsPerPage;
    widgetParams.searchParameters.page =
      renderOptions.instantSearchInstance.helper.lastResults.page;
  }

  widgetParams.container.querySelector("code").innerHTML = JSON.stringify(
    widgetParams.searchParameters,
    null,
    2
  );
};

// Create the custom widget
const customConfigure = connectConfigure(renderConfigure, () => {});

// Create options for hits select
let nb_options = 5;
let nb_hits_items = [];
for (let i = 1; i <= nb_options + 1; i++) {
  let nb_hits = i * import.meta.env.VITE_DEFAULT_PAGE_SIZE;
  let item = {
    label: `${nb_hits} hits per page`,
    value: nb_hits,
  };
  nb_hits_items.push(item);
}
nb_hits_items[0].default = true;

moviesIndex.addWidgets([
  searchBox({
    container: "#searchbox",
    cssClasses: {
      form: "search-form",
      input: ["input", "search-input"],
      reset: "search-input-reset",
    },
  }),
  customConfigure({
    container: document.querySelector("#configure"),
    searchParameters: {
      hitsPerPage: import.meta.env.VITE_DEFAULT_PAGE_SIZE,
    },
  }),
  hits({
    container: "#hits-1",
    templates: {
      item: `
      <div>
        <div class="title title-caps mb-5">
          {{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}
        </div>
        <img src="{{poster}}"/>
        <div class="hit-description body">{{#helpers.highlight}}{ "attribute": "overview" }{{/helpers.highlight}}</div>
      </div>
      `,
      empty(results, { html }) {
        return html`<div class="body">
          Sorry, no results matching your request 😔
        </div>`;
      },
    },
  }),
  hitsPerPage({
    container: "#hits-per-page",
    items: nb_hits_items,
    cssClasses: {
      select: "select-page-menu",
    },
  }),
  pagination({
    container: "#pagination",
    cssClasses: {
      link: "body text-dodger-blue-500",
    },
  }),
]);

moviesIndex.start();
