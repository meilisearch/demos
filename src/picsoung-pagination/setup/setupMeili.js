import { MeiliSearch } from 'meilisearch'
const { default: dataset } = await import('./movies.json', { 
  assert: { type: 'json' } 
});
import { watchTasks, populateIndex } from './setupFunctions.js'
import * as dotenv from 'dotenv'
dotenv.config()
const DEFAULT_INDEX = 'movies'

;(async () => {
  // Create client
  const client = new MeiliSearch({
    host: process.env.VITE_MEILI_HOST,
    apiKey: process.env.VITE_MEILI_ADMIN_API_KEY
  })

  // Create index and add documents
  await populateIndex(DEFAULT_INDEX, dataset, client)

  // Watch tasks
  await watchTasks(client, DEFAULT_INDEX)
})()