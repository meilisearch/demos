
const assert = require('assert')
const nikita = require('..')

describe('core', () => {
  it('load nikita', async () => {
    const {stdout} = await nikita.execute({
      command: 'hostname'
    });
    assert(typeof stdout === 'string')
  })
})
