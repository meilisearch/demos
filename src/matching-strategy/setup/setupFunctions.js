async function populateIndex (uid, dataset, client) {
  return await client.index(uid).addDocuments(dataset)
}

async function sleep (ms) {
  return await new Promise((resolve) => setTimeout(resolve, ms))
}

async function watchTasks (client, uid) {
  let allProcessed = false
  console.log(`Start update watch for ${uid}`)
  console.log('-------------')
  while (!allProcessed) {
    try {
      const tasks = await client.index(uid).getTasks()
      console.log(`${uid} index: adding documents`)
      console.log('-------------')
      await client.index(uid).waitForTasks(tasks)
      allProcessed = true
    } catch (e) {
      console.error(e)
    }
  }
  console.log(`All documents added to "${uid}"`)
}

export {
  populateIndex,
  sleep,
  watchTasks
}
