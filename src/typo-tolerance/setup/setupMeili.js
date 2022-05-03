const { MeiliSearch } = require('meilisearch')
const dataset = require('./books.json')
const { watchTasks, populateIndex } = require('./setupFunctions')

const DEFAULT_INDEX = 'books_default'
const TYPO_TOLERANT_INDEX = 'books_typo'

const settings = {
  distinctAttribute: null,
  searchableAttributes: [
    'title',
    'isbn',
    'authors',
    'shortDescription'
  ],
  displayedAttributes: [
    'title',
    'isbn',
    'authors',
    'shortDescription',
    'thumbnailUrl'
  ]
}

const defaultTypoTolerance = {
  minWordSizeForTypos: {
    oneTypo: 5,
    twoTypos: 9
  }
}
const customTypoTolerance = {
  disableOnAttributes: ['isbn'],
  minWordSizeForTypos: {
    oneTypo: 2,
    twoTypos: 4
  }
}

;(async () => {
  // Create client
  const client = new MeiliSearch({
    host: 'http://127.0.0.1:7700',
    apiKey: 'masterKey'
  })

  const indexArray = [
    { uid: DEFAULT_INDEX, typoTolerance: defaultTypoTolerance },
    { uid: TYPO_TOLERANT_INDEX, typoTolerance: customTypoTolerance }
  ]
  // Create index and add settings and documents
  await Promise.all(
    indexArray.map(async index => {
      await client.createIndex(index.uid)
      await populateIndex(settings, index, dataset, client)
    })
  )

  // Watch tasks

  const waitForProcessing = indexArray.map(async index => {
    await watchTasks(client, index.uid)
  })

  Promise.all(waitForProcessing)
})()
