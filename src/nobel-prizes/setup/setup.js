const { MeiliSearch } = require('meilisearch')
const dataset = require('./prizes.json')
const index_uid = "prizes"

;(async () => {
    // Create client
    const client = new MeiliSearch({
        host: 'http://127.0.0.1:7700',
        apiKey: 'masterKey'
    })

    // Create Index if it does not already exist
    console.log("before")
    await client.createIndex(index_uid)
    console.log("after")
    console.log(`Index ${index_uid} created.`);

    // Add settings
    const settings = {
        distinctAttribute: null,
        searchableAttributes: ["*"],
        displayedAttributes: ["*"],
        stopWords: ["a", "an", "the"],
        synonyms: { },
        filterableAttributes: [
          "year",
          "category"
        ]
      }
    await client.index(index_uid).updateSettings(settings)
    console.log(`Settings added to ${index_uid} index`)

    // Add documents
    await client.index(index_uid).addDocumentsInBatches(dataset)
    
    console.log(`Documents added to ${index_uid} index.`);

})()
