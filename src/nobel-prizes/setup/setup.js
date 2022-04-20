const { MeiliSearch } = require('meilisearch')
const dataset = require('./prizes.json')
const indexUID = "prizes"

;(async () => {
    // Create client
    const client = new MeiliSearch({
        host: 'http://127.0.0.1:7700',
        apiKey: 'masterKey'
    })

    // Create Index if it does not already exist
    console.log("before")
    await client.createIndex(indexUID)
    console.log("after")
    console.log(`Index ${indexUID} created.`);

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
    await client.index(indexUID).updateSettings(settings)
    console.log(`Settings added to ${indexUID} index`)

    // Add documents
    await client.index(indexUID).addDocumentsInBatches(dataset)
    
    console.log(`Documents added to ${indexUID} index.`);

})()
