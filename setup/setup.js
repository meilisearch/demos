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

;(async () => {
  // Create client
  const client = new MeiliSearch({
    host: process.env.VUE_APP_MEILISEARCH_HOST,
    apiKey: process.env.VUE_APP_MEILISEARCH_API_KEY
  })

  // Create Index or get the existing one
  const index = await client.getOrCreateIndex('artWorks', { primaryKey: 'ObjectID' })

  // Check if index is populated
  const stats = await index.getStats()

  if (stats.numberOfDocuments === dataset.length) {
    console.log('Index "artWorks" is already populated')
    return
  }

  console.log('Index "artWorks" created.')

  // Add settings
  await index.updateSettings(settings)
  console.log('Settings added to "artWorks" index.')

  // Process documents
  const processedDataSet = dataProcessing(dataset)

  // Add documents
  const batchedDataSet = batch(processedDataSet, 10000)
  console.log('Adding documents...')
  batchedDataSet.forEach(async (batch) => {
    const { updateId } = await index.addDocuments(batch)
    await index.waitForPendingUpdate(updateId, {
      timeOutMs: 100000
    })
  })

  console.log('Documents added to "artWorks" index.')

  // ArtWorks with ASC order
  const indexAsc = await client.getOrCreateIndex('artWorksAsc', { primaryKey: 'ObjectID' })
  settings.rankingRules = rankingRulesAsc
  await indexAsc.updateSettings(settings)
  console.log('Settings added to "artWorksAsc" index.')

  console.log('Adding documents...')
  batchedDataSet.forEach(async (batch) => {
    const { updateId } = await indexAsc.addDocuments(batch)
    await index.waitForPendingUpdate(updateId, {
      timeOutMs: 100000
    })
  })
  console.log('Documents added to "artWorksAsc" index.')

  // ArtWorks with DESC order
  const indexDesc = await client.getOrCreateIndex('artWorksDesc', { primaryKey: 'ObjectID' })
  settings.rankingRules = rankingRulesDesc
  await indexDesc.updateSettings(settings)
  console.log('Settings added to "artWorksDesc" index.')
  console.log('Adding documents...')
  batchedDataSet.forEach(async (batch) => {
    const { updateId } = await indexDesc.addDocuments(batch)
    await index.waitForPendingUpdate(updateId, {
      timeOutMs: 100000
    })
  })
  console.log('Documents added to "artWorksDesc" index.')
})()

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
