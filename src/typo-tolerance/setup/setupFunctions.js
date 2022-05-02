async function populateIndex (settings, { uid, typoTolerance }, dataset, client) {
    await client.index(uid).updateSettings({ ...settings, typoTolerance: typoTolerance })
    return await client.index(uid).addDocuments(dataset)
  }

async function sleep (ms) {
    return await new Promise((resolve) => setTimeout(resolve, ms))
}

async function watchTasks (client, uid) {
    const standardSpeed = 500
    let allProcessed = false
    console.log(`Start update watch for ${uid}`)
    console.log('-------------')
    while (!allProcessed) {
      try {
        const tasks = await client.index(uid).getTasks()
        const processed = tasks.results.filter(update => update.status === 'succeeded')
        const processing = tasks.results.filter(update => update.status === 'processing')
        const enqueued = tasks.results.filter(update => update.status === 'enqueued')
        console.log(`${uid}:`)
        console.log('Adding documents')
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
    populateIndex,
    sleep,
    watchTasks
  }
  
  module.exports = setupFunctions
