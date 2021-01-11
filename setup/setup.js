const MeiliSearch = require('meilisearch')
const dataset = require('./Artworks.json')
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
  attributesForFaceting: [
    'Nationality', 'Gender', 'Classification'
  ]
}

const rankingRulesAsc = [
  'asc(DateToSortBy)',
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness'
]
const rankingRulesDesc = [
  'desc(DateToSortBy)',
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness'
]
const defaultRankingRules = [
  'typo',
  'words',
  'proximity',
  'attribute',
  'wordsPosition',
  'exactness'
]

// Split dataset into batches
function batch (array, size) {
  const batchedArray = []
  let index = 0
  while (index < array.length) {
    batchedArray.push(array.slice(index, size + index))
    index += size
  }
  return batchedArray
}

// Add field about Artist number before converting Artist array to string
function addVariousArtistsField (document) {
  if (document.Artist.length > 1) {
    document.VariousArtists = true
  } else {
    document.VariousArtists = false
  }
  return document
}

// Transform array into string so MeiliSearch can highlight the results
function arrayToString (document) {
  for (const [key, value] of Object.entries(document)) {
    if (key === 'Artist' || key === 'ArtistBio') {
      const stringValue = value.join(', ')
      document[key] = stringValue
    }
  }
  return document
}

// Get year from Date field and add it to new field to make sorting by date easier
function normalizeDate (document) {
  const date = document.Date
  const match = (/(\d{4})/).exec(date)
  if (match) {
    document.DateToSortBy = match[0]
  } else {
    document.DateToSortBy = date
  }
  return document
}

// Apply arrayToString and normalizeDate in each document of an array
function dataProcessing (data) {
  const processedDataArray = []
  for (let i = 0; i < data.length; i++) {
    const documentWithExtraField = addVariousArtistsField(data[i])
    const stringifiedDoc = arrayToString(documentWithExtraField)
    const processedDoc = normalizeDate(stringifiedDoc)
    processedDataArray.push(processedDoc)
  }
  return processedDataArray
}

async function populateIndex ({ index, rules, name }, batchedDataSet) {
  await index.updateSettings({ ...settings, rankingRules: rules })
  console.log(`Settings added to ${name} index.`)
  console.log(`Adding documents to ${name}...`)
  for (let i = 0; i < batchedDataSet.length; i++) {
    const { updateId } = await index.addDocuments(batchedDataSet[i])
    await index.waitForPendingUpdate(updateId, {
      timeOutMs: 100000
    })
  }
}

async function indexIsPopulated (index, dataset) {
  const indexStats = await index.getStats()
  return indexStats.numberOfDocuments === dataset.length
}
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

  for (const index of indexArray) {
    const isPopulated = await indexIsPopulated(index.index, dataset)
    if (isPopulated) {
      console.log(`Index "${index.name}" already exists`)
    } else {
      await populateIndex(index, batchedDataSet)
      console.log(`Documents added to "${index.name}"`)
    }
  }
})()
