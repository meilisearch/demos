import { setupFunctions } from './setup'
setupFunctions.launchMeili = jest.fn()

describe('batch', () => {
  const array = [1, 2, 3, 4, 5, 6]
  const size = 2
  let result
  test('should return an array', () => {
    result = setupFunctions.batch(array, size)
    expect(result).toBeInstanceOf(Array)
  })
  test('should split an array into batches of the given size', () => {
    result = setupFunctions.batch(array, size)
    const expectedLength = array.length / size
    const expectedArray = [[1, 2], [3, 4], [5, 6]]
    expect(result.length).toEqual(expectedLength)
    expect(result).toEqual(expectedArray)
  })
})

describe('addVariousArtistsField', () => {
  const document = { Artist: ['Pablo Picasso'] }
  let returnedDocument
  test('should add an extra field to the document passed as parameter', () => {
    returnedDocument = setupFunctions.addVariousArtistsField(document)
    expect(returnedDocument).toHaveProperty('VariousArtists')
  })
  test('newly added field should return false if array length of the Artist field is equal to 1', () => {
    returnedDocument = setupFunctions.addVariousArtistsField(document)
    expect(returnedDocument.VariousArtists).toBe(false)
  })
  test('newly added field should return true if array length of the Artist field is greater than 1', () => {
    const document2 = { Artist: ['Vincent Van Gogh', 'Auguste Renoir'] }
    returnedDocument = setupFunctions.addVariousArtistsField(document2)
    expect(returnedDocument.VariousArtists).toBe(true)
  })
})

describe('arrayFieldToString', () => {
  let string
  let result
  test('should transform the array passed as parameter into a string', () => {
    const array = ['Meili']
    string = 'Meili'
    result = setupFunctions.arrayFieldToString(array)
    expect(result).not.toBeInstanceOf(Array)
    expect(result).toEqual(string)
  })
  test('should add a comma and a space after each element of the array', () => {
    const array2 = ['Meili', 'Search']
    result = setupFunctions.arrayFieldToString(array2)
    const expectedResult = 'Meili, Search'
    expect(result).toEqual(expectedResult)
  })
  test('should return the element passed as parameter if it is not an array', () => {
    const object = { meili: 'search' }
    result = setupFunctions.arrayFieldToString(object)
    expect(result).toEqual(object)
  })
})

describe('normalizeDate', () => {
  const document = { Artist: ['Pablo Picasso'], Date: '1881' }
  let result
  test('should add a new field to the document passed as parameter', () => {
    result = setupFunctions.normalizeDate(document)
    expect(result).toHaveProperty('DateToSortBy')
  })
  test('DateToSortBy field should be equal to the year of the date field if a year exists', () => {
    result = setupFunctions.normalizeDate(document)
    expect(result.DateToSortBy).toEqual('1881')
    const document2 = { Artist: ['Auguste Renoir'], Date: '25/02/1841' }
    const result2 = setupFunctions.normalizeDate(document2)
    expect(result2.DateToSortBy).toEqual('1841')
  })
  test('DateToSortBy field should be equal to the date field if no year exists', () => {
    const documentWithNoYear = { Artist: ['René Magritte'], Date: 'Unknown' }
    result = setupFunctions.normalizeDate(documentWithNoYear)
    expect(result.DateToSortBy).toEqual(documentWithNoYear.Date)
  })
})

describe('dataProcessing', () => {
  const data = [{ Artist: ['Auguste Renoir'], Date: '25/02/1841' }, { Artist: ['Pablo Picasso'], Date: '1881' }]
  let result
  test('should return an array', () => {
    result = setupFunctions.dataProcessing(data)
    expect(result).toBeInstanceOf(Array)
  })
  test('each document of the returned array should have a DateToSortBy, a VariousArtists fields', () => {
    result = setupFunctions.dataProcessing(data)
    expect(result[0]).toHaveProperty('DateToSortBy')
    expect(result[1]).toHaveProperty('DateToSortBy')
    expect(result[0]).toHaveProperty('VariousArtists')
    expect(result[1]).toHaveProperty('VariousArtists')
  })
  test('each document of the returned array should have its array fields transformed into strings', () => {
    result = setupFunctions.dataProcessing(data)
    expect(result[0].Artist).not.toBeInstanceOf(Array)
    expect(result[1].Artist).not.toBeInstanceOf(Array)
  })
})

describe('sleep', () => {
  const ms = 500
  test('should return a Promise', () => {
    jest.useFakeTimers()
    const result = setupFunctions.sleep(ms)
    jest.runAllTimers()
    expect(result).toBeInstanceOf(Promise)
  })
  test('should call setTimeOut with the time in ms passed as parameter', () => {
    jest.useFakeTimers()
    setupFunctions.sleep(ms)
    jest.runAllTimers()
    expect(setTimeout).toHaveBeenCalledWith(expect.any(Function), ms)
  })
})

describe('meiliUpdates', () => {
  const consoleLogSpy = jest.spyOn(console, 'log').mockImplementation(() => {})
  const updates = [{ status: 'processed' }, { status: 'processed' }, { status: 'processed' }, { status: 'processed' }]
  const index = { getAllUpdateStatus: jest.fn().mockImplementation(() => { return updates }) }
  const client = { getIndex: jest.fn().mockReturnValue(index) }
  const uid = 'art'
  test('should log into the console the update status', async () => {
    jest.spyOn(setupFunctions, 'sleep').mockImplementation(() => {})
    await setupFunctions.meiliUpdates(client, uid)
    expect(consoleLogSpy).toHaveBeenCalledWith(`Start update watch for ${uid}`)
    expect(consoleLogSpy).toHaveBeenCalledWith('-------------')
    expect(consoleLogSpy).toHaveBeenCalledWith(`${uid}:`)
    expect(consoleLogSpy).toHaveBeenCalledWith('4 / 4 have been processed')
  })
  test('should call sleep function with 500 ms', () => {
    const sleepFn = jest.spyOn(setupFunctions, 'sleep').mockImplementation(() => {})
    expect(sleepFn).toHaveBeenCalledWith(500)
  })
})
