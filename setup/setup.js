const MeiliSearch = require('meilisearch')
const dataset = require('./Artworks.json')

;(async () => {
    // Create client
    const client = new MeiliSearch({
        host: 'http://127.0.0.1:7700'
    })

    // Create Index
    await client.createIndex('artWorks', { primaryKey: 'ObjectID' })
    const index = client.getIndex('artWorks')
    console.log('Index "artWorks" created.');

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
        stopWords: ["a", "an", "the"],
        synonyms: { },
        attributesForFaceting: [
            'Nationality', 'Gender', 'Medium', 'Classification'
        ]
      }
    await index.updateSettings(settings)
    console.log('Settings added to "artWorks" index.');
    
    // Add documents
    const batchedDataSet = batch(dataset, 500)
    console.log('Adding documents...');
    for (let i = 0; i < batchedDataSet.length; i++) {
        let { updateId } = await index.addDocuments(batchedDataSet[i])
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
