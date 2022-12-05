import './style.css'
import './meilisearch.min.css'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import instantsearch from 'instantsearch.js'
import { searchBox, hits, configure } from 'instantsearch.js/es/widgets'
const MEILISEARCH_HOST = import.meta.env.VITE_MEILI_HOST
const MEILISEARCH_API_KEY = import.meta.env.VITE_MEILI_SEARCH_API_KEY

const searchClient = instantMeiliSearch(
  MEILISEARCH_HOST,
  MEILISEARCH_API_KEY,
  {
    limitPerRequest: 30
  }
)

const moviesIndex = instantsearch({
  indexName: 'movies',
  searchClient,
})

moviesIndex.addWidgets([
  configure({
    attributesToSnippet: ['shortDescription:40']
  }),
  searchBox({
    container: '#searchbox',
    cssClasses: {
      form: 'search-form',
      input: [
        'input',
        'search-input'
      ],
      reset: 'search-input-reset'
    }
  }),
  hits({
    container: '#hits-1',
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
      empty (results, { html }) {
        return html`<div class="body"> Sorry, no results matching your request 😔 </div>`
      }
    }
  })
])

moviesIndex.start()
