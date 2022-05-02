import './style.css'
import { instantMeiliSearch } from "@meilisearch/instant-meilisearch";
import instantsearch from "instantsearch.js";
import { searchBox, hits, configure } from 'instantsearch.js/es/widgets'



const searchClient = instantMeiliSearch(
  "http://127.0.0.1:7700",
  "apiKey",
  {
    limitPerRequest: 30
  }
)
const booksTypoIndex = instantsearch({
  indexName: "books_typo",
  searchClient: searchClient
});

booksTypoIndex.addWidgets([  
  configure({
    attributesToSnippet: ['shortDescription:40']
  }), 
  hits({
    transformItems(items) {
      return items.map(item => ({
        ...item,
        authors: item.authors.join(", ")
      }));
    },
    container: "#hits-2",
    templates: {
      item: `
      <div>
        <div class="hit-name">
          {{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}
        </div>
        <div class="hit-info">by {{authors}}</div>
        <div class="hit-info isbn"><span class="field-name">ISBN:</span> {{#helpers.highlight}}{ "attribute": "isbn" }{{/helpers.highlight}}</div>
        <img src="{{thumbnailUrl}}" align="left" />
        <div class="hit-description">{{#helpers.highlight}}{ "attribute": "shortDescription" }{{/helpers.highlight}}</div>
      </div>
      `
    }
  })
]);

booksTypoIndex.start();

const booksIndex = instantsearch({
  indexName: "books_default",
  searchClient: searchClient,
    searchFunction(helper) {
    booksTypoIndex.helper.setQuery(helper.state.query).search()
    helper.search()
      
  }
});

booksIndex.addWidgets([
  configure({
    attributesToSnippet: ['shortDescription:40']
  }),
  searchBox({
    container: "#searchbox"
  }),
  hits({
    transformItems(items) {
      return items.map(item => ({
        ...item,
        authors: item.authors.join(", ")
      }));
    },
    container: "#hits-1",
    templates: {
      item: `
      <div>
        <div class="hit-name">
          {{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}
        </div>
        <div class="hit-info">by {{authors}}</div>
        <div class="hit-info isbn"><span class="field-name">ISBN:</span> {{#helpers.highlight}}{ "attribute": "isbn" }{{/helpers.highlight}}</div>
        <img src="{{thumbnailUrl}}" align="left" />
        <div class="hit-description">{{#helpers.highlight}}{ "attribute": "shortDescription" }{{/helpers.highlight}}</div>
      </div>
      `
    }
  })
]);

booksIndex.start();
