const { MeiliSearch } = require('meilisearch')
const dataset = require('./Artworks.json')
const { setupFunctions } = require('./setup')
const dataProcessing = setupFunctions.dataProcessing
const batch = setupFunctions.batch
const populateIndex = setupFunctions.populateIndex
const meiliUpdates = setupFunctions.meiliUpdates
require('dotenv').config()

const settings = {
  distinctAttribute: null,
  searchableAttributes: [
    'Artist',
    'Title',
    'ArtistBio',
    'Nationality',
    'Gender',
    'Date',
    'Medium',
    'Department',
    'MultipleArtists',
    'DateToSortBy'
  ],
  displayedAttributes: [
    'Title',
    'Artist',
    'ArtistBio',
    'Nationality',
    'Gender',
    'Date',
    'Medium',
    'Dimensions',
    'URL',
    'Department',
    'Classification',
    'ThumbnailURL',
    'MultipleArtists',
    'DateToSortBy'
  ],
  stopWords: ['a', 'an', 'the'],
  synonyms: { },
  filterableAttributes: [
    'Nationality', 'Gender', 'Classification'
  ]
}

const rankingRulesAsc = [
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness',
  'asc(DateToSortBy)'
]
const rankingRulesDesc = [
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness',
  'desc(DateToSortBy)'
]
const defaultRankingRules = [
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness'
]

;(async () => {
  // Create client
  const client = new MeiliSearch({
    host: process.env.VUE_APP_MEILISEARCH_HOST,
    apiKey: process.env.VUE_APP_MEILISEARCH_API_KEY
  })

  // Process documents
  const processedDataSet = dataProcessing(dataset)

  // Add documents batches array
  const batchedDataSet = batch(processedDataSet, 10000)

  // Get or create indexes
  const artWorksIndex = await client.getOrCreateIndex('artWorks', { primaryKey: 'ObjectID' })
  const artWorksAscIndex = await client.getOrCreateIndex('artWorksAsc', { primaryKey: 'ObjectID' })
  const artWorksDescIndex = await client.getOrCreateIndex('artWorksDesc', { primaryKey: 'ObjectID' })

  // Create Indexes array
  const indexArray = [
    { name: 'artWorks', index: artWorksIndex, rules: defaultRankingRules },
    { name: 'artWorksAsc', index: artWorksAscIndex, rules: rankingRulesAsc },
    { name: 'artWorksDesc', index: artWorksDescIndex, rules: rankingRulesDesc }
  ]

  const filteredArray = await Promise.all(
    indexArray.map(async index => await index.index.getStats()))
    .then(res =>
      indexArray.filter((index, i) => {
        if (res[i].numberOfDocuments === dataset.length) {
          return console.log(`Index "${index.name}" already exists`)
        } else return true
      })
    )

  await Promise.all(filteredArray.map(async index => await populateIndex(settings, index, batchedDataSet)))
  const waitForProcessing = filteredArray.map(async index => await meiliUpdates(client, index.name))
  Promise.all(waitForProcessing)
})()
