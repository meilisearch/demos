const { MeiliSearch } = require('meilisearch')
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
function arrayFieldToString (fieldValue) {
  if (Array.isArray(fieldValue)) {
    return fieldValue.join(', ')
  }
  return fieldValue
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

// Apply arrayFieldToString and normalizeDate in each document of an array
function dataProcessing (data) {
  const processedDataArray = data.map(doc => {
    const documentWithExtraField = addVariousArtistsField(doc)
    const stringifiedDoc = {
      ...documentWithExtraField,
      Artist: arrayFieldToString(documentWithExtraField.Artist),
      ArtistBio: arrayFieldToString(documentWithExtraField.ArtistBio)
    }
    const processedDoc = normalizeDate(stringifiedDoc)
    return processedDoc
  })
  return processedDataArray
}

async function populateIndex ({ index, rules, name }, batchedDataSet) {
  await index.updateSettings({ ...settings, rankingRules: rules })
  console.log(`Settings added to ${name} index.`)
  console.log(`Adding documents to ${name}...`)
  const allBatches = batchedDataSet.map(async batch =>
    await index.addDocuments(batch)
  )
  const promiseBatches = await Promise.all(allBatches)
  return promiseBatches
}

async function sleep (ms) {
  return await new Promise((resolve) => setTimeout(resolve, ms))
}

async function meiliUpdates (client, uid) {
  const standardSpeed = 500
  let allProcessed = false
  console.log(`Start update watch for ${uid}`)
  console.log('-------------')
  while (!allProcessed) {
    try {
      const updates = await client.index(uid).getAllUpdateStatus()
      const processed = updates.filter(update => update.status === 'processed')
      const enqueued = updates.filter(update => update.status === 'enqueued')
      console.log(`${uid}:`)
      console.log(`${processed.length} / ${updates.length} have been processed`)
      console.log(`${enqueued.length} / ${updates.length} still enqueued`)
      console.log('-------------')
      if (enqueued.length === 0) allProcessed = true
      await setupFunctions.sleep(standardSpeed)
    } catch (e) {
      console.error(e)
    }
  }
  console.log(`All documents added to "${uid}"`)
}

const launchMeili = (async () => {
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

  await Promise.all(filteredArray.map(async index => await populateIndex(index, batchedDataSet)))
  const waitForProcessing = filteredArray.map(async index => await meiliUpdates(client, index.name))
  Promise.all(waitForProcessing)
})()

const setupFunctions = {
  launchMeili,
  batch,
  addVariousArtistsField,
  arrayFieldToString,
  normalizeDate,
  dataProcessing,
  populateIndex,
  sleep,
  meiliUpdates
}

module.exports = { setupFunctions }
