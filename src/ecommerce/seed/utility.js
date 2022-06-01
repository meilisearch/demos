async function sleep(ms) {
  return await new Promise(resolve => setTimeout(resolve, ms))
}

exports.watchUpdates = async (client, uid) => {
  const standardSpeed = 500
  let allProcessed = false
  console.log(`Start update watch for ${uid}`)
  console.log('-------------')
  while (!allProcessed) {
    try {
      const updates = await client.index(uid).getTasks()
      const processed = updates.results.filter(
        update => update.status === 'succeeded'
      )
      const processing = updates.results.filter(
        update => update.status === 'processing'
      )
      const enqueued = updates.results.filter(
        update => update.status === 'enqueued'
      )
      console.log(`${uid}:`)
      console.log(
        `${processed.length} / ${updates.results.length} have been processed`
      )
      console.log(
        `${processing.length} / ${updates.results.length} is being processed`
      )
      console.log(
        `${enqueued.length} / ${updates.results.length} still enqueued`
      )
      console.log('-------------')
      if (enqueued.length === 0) allProcessed = true
      await sleep(standardSpeed)
    } catch (e) {
      console.error(e)
    }
  }
  console.log(`All documents and attributes are added to "${uid}"`)
}
