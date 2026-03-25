import './style.css'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import instantsearch from 'instantsearch.js'
import { searchBox, infiniteHits, configure, stats } from 'instantsearch.js/es/widgets'


const MEILISEARCH_HOST = import.meta.env.VITE_MEILI_HOST
const MEILISEARCH_API_KEY = import.meta.env.VITE_MEILI_SEARCH_API_KEY

const searchClient = instantMeiliSearch(
  MEILISEARCH_HOST,
  MEILISEARCH_API_KEY,
  {
    limitPerRequest: 30
  }
)

const HIT_TEMPLATE = `
  <img class="hit-thumbnail" src="{{thumbnailUrl}}" alt="" loading="lazy" />
  <div class="hit-body">
    <div class="hit-name">{{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}</div>
    <div class="hit-authors">by {{authors}}</div>
    <div class="hit-isbn"><span class="field-name">ISBN:</span> {{#helpers.highlight}}{ "attribute": "isbn" }{{/helpers.highlight}}</div>
    <div class="hit-description">{{#helpers.snippet}}{ "attribute": "shortDescription" }{{/helpers.snippet}}</div>
  </div>
`

function transformItems (items) {
  return items.map(item => ({
    ...item,
    authors: Array.isArray(item.authors) ? item.authors.join(', ') : (item.authors ?? '')
  }))
}

const booksTypoIndex = instantsearch({
  indexName: 'books_typo',
  searchClient
})

booksTypoIndex.addWidgets([
  configure({
    attributesToSnippet: ['shortDescription:40']
  }),
  stats({
    container: '#count-2',
    templates: {
      text: ({ nbHits }) => `${nbHits.toLocaleString()} result${nbHits !== 1 ? 's' : ''}`
    }
  }),
  infiniteHits({
    transformItems,
    container: '#hits-2',
    templates: {
      item: HIT_TEMPLATE,
      empty: '<div class="ais-Hits--empty">No results found.</div>',
      showMoreText: 'Load more'
    }
  })
])

booksTypoIndex.start()

const booksIndex = instantsearch({
  indexName: 'books_default',
  searchClient,
  searchFunction (helper) {
    booksTypoIndex.helper.setQuery(helper.state.query).search()
    helper.search()
  }
})

booksIndex.addWidgets([
  configure({
    attributesToSnippet: ['shortDescription:40']
  }),
  searchBox({
    container: '#searchbox'
  }),
  stats({
    container: '#count-1',
    templates: {
      text: ({ nbHits }) => `${nbHits.toLocaleString()} result${nbHits !== 1 ? 's' : ''}`
    }
  }),
  infiniteHits({
    transformItems,
    container: '#hits-1',
    templates: {
      item: HIT_TEMPLATE,
      empty: '<div class="ais-Hits--empty">No results found.</div>',
      showMoreText: 'Load more'
    }
  })
])

booksIndex.start()
