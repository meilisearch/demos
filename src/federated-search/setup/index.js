const { MeiliSearch } = require('meilisearch')
const moviesSettings = require('./moviesSettings')
const actorsSettings = require('./actorsSettings')
const { watchTasks, populateIndex } = require('./setupFunctions')
const moviesDataset = require('./movies.json')
const actorsDataset = require('./actors.json')
const MOVIES_INDEX = 'movies'
const ACTORS_INDEX = 'actors'

require('dotenv').config()

;(async () => {
    const client = new MeiliSearch({
      host: process.env.NEXT_PUBLIC_MEILISEARCH_HOST,
      apiKey: process.env.NEXT_PUBLIC_MEILISEARCH_ADMIN_API_KEY
    })
  
    const indexArray = [
        { uid: MOVIES_INDEX, settings: moviesSettings, dataset: moviesDataset },
        { uid: ACTORS_INDEX, settings: actorsSettings, dataset: actorsDataset  }
      ]
      // Create index and add settings and documents
      await Promise.all(
        indexArray.map(async index => {
          await populateIndex(index, client)
        })
      )
    
      // Watch tasks
      const waitForProcessing = indexArray.map(async index => {
        await watchTasks(client, index.uid)
      })
    
      Promise.all(waitForProcessing)
})()


