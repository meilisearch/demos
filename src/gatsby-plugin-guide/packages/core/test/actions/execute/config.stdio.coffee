
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.stdio', ->
  return unless tags.posix
    
  it 'invalid', ->
    nikita.execute
      command: 'abc'
      stdio: 1234
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        
  it 'valid string', ->
    nikita.execute
      command: 'abc'
      stdio: 'overlapped'
    , (->)
        
  it 'valid integer', ->
    nikita.execute
      command: 'abc'
      stdio: 1
    , (->)
        
  it 'valid array', ->
    nikita.execute
      command: 'abc'
      stdio: ['overlapped', 'overlapped']
    , (->)
