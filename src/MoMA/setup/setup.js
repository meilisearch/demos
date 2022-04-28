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
  let date = document.Date
  if (date == null) {
    document.DateToSortBy = 0
  } else {
    date = date.replace(/\((.*)\)/, '$1') // removes parenthesis
    date = date.replace(/.*([0-9]{4}).*/, '$1') // fetch the 4 first digits if exist
    date = date.replace(/^[^0-9]{4}.*/, '0') // Change all fields with no valid year ( 4 digits in a row ) to 0
    document.DateToSortBy = parseInt(date) // parse all values to int
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

async function populateIndex (indexUID, batchedDataSet, client) {
  console.log(`Adding documents to ${indexUID}...`)
  const allBatches = batchedDataSet.map(async batch =>
    await client.index(indexUID).addDocuments(batch)
  )
  const promiseBatches = await Promise.all(allBatches)
  return promiseBatches
}

async function addSettings (indexUID, settings, client) {
  await client.index(indexUID).updateSettings(settings)
  console.log(`Settings added to ${indexUID} index.`)
}

async function sleep (ms) {
  return await new Promise((resolve) => setTimeout(resolve, ms))
}

async function watchUpdates (client, uid) {
  const standardSpeed = 500
  let allProcessed = false
  console.log(`Start update watch for ${uid}`)
  console.log('-------------')
  while (!allProcessed) {
    try {
      const updates = await client.index(uid).getTasks()
      const processed = updates.results.filter(update => update.status === 'succeeded')
      const processing = updates.results.filter(update => update.status === 'processing')
      const enqueued = updates.results.filter(update => update.status === 'enqueued')
      console.log(`${uid}:`)
      console.log(`${processed.length} / ${updates.results.length} have been processed`)
      console.log(`${processing.length} / ${updates.results.length} is being processed`)
      console.log(`${enqueued.length} / ${updates.results.length} still enqueued`)
      console.log('-------------')
      if (enqueued.length === 0) allProcessed = true
      await setupFunctions.sleep(standardSpeed)
    } catch (e) {
      console.error(e)
    }
  }
  console.log(`All documents added to "${uid}"`)
}

const setupFunctions = {
  batch,
  addVariousArtistsField,
  arrayFieldToString,
  normalizeDate,
  dataProcessing,
  populateIndex,
  sleep,
  watchUpdates,
  addSettings
}

module.exports = setupFunctions
