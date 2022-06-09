require('dotenv').config()
const { watchUpdates } = require('./utility')
const { MeiliSearch } = require('meilisearch')

const client = new MeiliSearch({
  host: process.env.NEXT_PUBLIC_MEILI_HOST_NAME,
  apiKey: process.env.NEXT_PUBLIC_MEILI_API_KEY,
})

const INDEX_NAME = 'products'

const index = client.index(INDEX_NAME)

const data = require('./data.json')

;(async () => {
  console.log(`Adding Filterable and Sortable Attributes to "${INDEX_NAME}"`)
  await index.updateFilterableAttributes([
    'brand',
    'category',
    'tag',
    'rating',
    'reviews_count',
    'price',
  ])
  await index.updateSortableAttributes(['reviews_count', 'rating', 'price'])

  console.log(`Adding Documents to "${INDEX_NAME}"`)
  await index.updateDocuments(data)
  console.log('=============')

  await watchUpdates(client, INDEX_NAME)
})()
