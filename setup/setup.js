const MeiliSearch = require('meilisearch')
const dataset = require('./Artworks.json')
require('dotenv').config()

;(async () => {
  // Create client
  const client = new MeiliSearch({
    host: process.env.VUE_APP_MEILISEARCH_HOST,
    apiKey: process.env.VUE_APP_MEILISEARCH_API_KEY
  })

  // Create Index
  await client.createIndex('artWorks', { primaryKey: 'ObjectID' })
  const index = client.getIndex('artWorks')
  console.log('Index "artWorks" created.')

  // Add settings
  const settings = {
    distinctAttribute: null,
    searchableAttributes: [
      'Title',
      'Artist',
      'ArtistBio',
      'Nationality',
      'Gender',
      'BeginDate',
      'Date',
      'Medium',
      'Department'
    ],
    displayedAttributes: [
      'Title',
      'Artist',
      'ArtistBio',
      'Nationality',
      'Gender',
      'BeginDate',
      'Date',
      'Medium',
      'Dimensions',
      'URL',
      'Department',
      'Classification',
      'ThumbnailURL'
    ],
    stopWords: ['a', 'an', 'the'],
    synonyms: { },
    attributesForFaceting: [
      'Nationality', 'Gender', 'Medium', 'Classification'
    ]
  }
  await index.updateSettings(settings)
  console.log('Settings added to "artWorks" index.')

  // Add documents
  const batchedDataSet = batch(dataset, 500)
  console.log('Adding documents...')
  for (let i = 0; i < batchedDataSet.length; i++) {
    const { updateId } = await index.addDocuments(batchedDataSet[i])
    await index.waitForPendingUpdate(updateId, {
      timeOutMs: 100000
    })
  }
  console.log('Documents added to "artWorks" index.')
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

// Transform array into string so MeiliSearch can highlight the results

function arrayToString (document) {
  for (const [key, value] of Object.entries(document)) {
      if (Array.isArray(value)) {
          let stringValue = value.join(', ')
          document[key] = stringValue
      }
  }
  return document
}

function normalizeDate (document) {
  const date = document.Date 
  const match = (/(\d{4})/).exec(date) 
}