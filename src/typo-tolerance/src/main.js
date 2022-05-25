import './style.css'
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
const booksTypoIndex = instantsearch({
  indexName: 'books_typo',
  searchClient
})

booksTypoIndex.addWidgets([
  configure({
    attributesToSnippet: ['shortDescription:40']
  }),
  hits({
    transformItems (items) {
      return items.map(item => {
        let authors = ''
        if (Array.isArray(item.authors)) authors = item.authors.join(', ')

        return {
          ...item,
          authors
        }
      })
    },
    container: '#hits-2',
    templates: {
      item: `
      <div>
        <div class="hit-name">
          {{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}
        </div>
        <div class="hit-info">by {{authors}}</div>
        <div class="hit-info isbn"><span class="field-name">ISBN:</span> {{#helpers.highlight}}{ "attribute": "isbn" }{{/helpers.highlight}}</div>
        <img src="{{thumbnailUrl}}"/>
        <div class="hit-description">{{#helpers.highlight}}{ "attribute": "shortDescription" }{{/helpers.highlight}}</div>
      </div>
      `
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
  hits({
    transformItems (items) {
      return items.map(item => {
        let authors = ''
        if (Array.isArray(item.authors)) authors = item.authors.join(', ')

        return {
          ...item,
          authors
        }
      })
    },
    container: '#hits-1',
    templates: {
      item: `
      <div>
        <div class="hit-name">
          {{#helpers.highlight}}{ "attribute": "title" }{{/helpers.highlight}}
        </div>
        <div class="hit-info">by {{authors}}</div>
        <div class="hit-info isbn"><span class="field-name">ISBN:</span> {{#helpers.highlight}}{ "attribute": "isbn" }{{/helpers.highlight}}</div>
        <img src="{{thumbnailUrl}}"/>
        <div class="hit-description">{{#helpers.highlight}}{ "attribute": "shortDescription" }{{/helpers.highlight}}</div>
      </div>
      `
    }
  })
])

booksIndex.start()
