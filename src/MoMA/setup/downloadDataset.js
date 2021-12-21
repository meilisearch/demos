const Fs = require('fs')
const Path = require('path')
const Axios = require('axios')
const filePath = Path.resolve(__dirname, 'Artworks.json')

async function downloadDataset () {
  const url = 'https://github.com/MuseumofModernArt/collection/raw/master/Artworks.json'
  const path = Path.resolve(__dirname, 'Artworks.json')
  const writer = Fs.createWriteStream(path)

  const response = await Axios({
    url,
    method: 'GET',
    responseType: 'stream'
  })

  response.data.pipe(writer)

  return new Promise((resolve, reject) => {
    writer.on('finish', resolve)
    writer.on('error', reject)
  })
}

async function checkAndDownloadIfNeeded () {
  const exists = Fs.existsSync(filePath)
  if (exists) {
    console.log('The file already exists.')
  } else {
    console.log('Downloading dataset...')
    await downloadDataset()
    console.log('Dataset downloaded')
  }
}

checkAndDownloadIfNeeded()
