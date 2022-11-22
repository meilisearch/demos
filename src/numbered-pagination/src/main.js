import './style.css'
import './meilisearch.min.css'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import instantsearch from 'instantsearch.js'
import { searchBox, hits, stats, pagination, hitsPerPage } from 'instantsearch.js/es/widgets'

const MEILISEARCH_HOST = import.meta.env.VITE_MEILI_HOST
const MEILISEARCH_API_KEY = import.meta.env.VITE_MEILI_SEARCH_API_KEY

const searchClient = instantMeiliSearch(
  MEILISEARCH_HOST,
  MEILISEARCH_API_KEY,
  {
    finitePagination: true
  }
)

const moviesIndex = instantsearch({
  indexName: 'movies',
  searchClient
})

moviesIndex.addWidgets([
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
  stats({
    container: '#stats',
    cssClasses: {
      root: 'stats-container',
      text: [
        'body',
        'body-l'
      ]
    },
    templates: {
      text (data, { html }) {
        let count = ''

        if (data.hasManyResults) {
          count += `${data.nbHits} results`
        } else if (data.hasOneResult) {
          count += '1 result'
        } else {
          count += 'no result'
        }

        return html`<span class="stats-bold align-with-results">${count} <span class="stats-regular">found in</span> ${data.processingTimeMS}ms</span>`
      }
    }
  }),
  hits({
    container: '#hits',
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
  }),
  hitsPerPage({
    container: '#hits-per-page',
    items: [
      { label: '9 hits per page', value: 9, default: true },
      { label: '18 hits per page', value: 18 },
      { label: '36 hits per page', value: 36 },
    ],
    cssClasses: {
      select: 'select-page-menu',
    }
  }),
  pagination({
    container: '#pagination',
    cssClasses: {
      link: 'body text-valhalla-500'
    },
    templates: {
      first: 'First',
      previous: 'Previous',
      next: 'Next',
      last: 'Last',
    },
  })  
])

moviesIndex.start()
