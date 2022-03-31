
nikita = require '../../src'
registry = require '../../src/registry'
{tags, config} = require '../test'
they = require('mocha-they')(config)

describe 'actions.call', ->
  return unless tags.api

  it 'call action from global registry', ->
    try
      await nikita.call ->
        registry.register 'my_function', ({config}) ->
          pass_a_key: config.a_key
      await nikita.call ->
        {pass_a_key} = await nikita.my_function a_key: 'a value'
        pass_a_key.should.eql 'a value'
    finally ->
      nikita.call ->
        registry.unregister 'my_function'
  
  they 'call a module exporting a function', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        content: '''
        module.exports = ({config}) => {
          return config
        }
        '''
        target: "#{tmpdir}/my_module.js"
      result = await @call "#{tmpdir}/my_module.js", my_key: 'my value'
      result.should.containEql my_key: 'my value'
  
  they 'call a module exporting an object', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        content: '''
        module.exports = {
          metadata: {
            header: 'hello'
          },
          handler: ({config, metadata}) => {
            return {config, metadata}
          }
        }
        '''
        target: "#{tmpdir}/my_module.js"
      {config, metadata} = await @call "#{tmpdir}/my_module.js", my_key: 'my value'
      config.should.containEql
        my_key: 'my value'
      metadata.should.containEql
        header: 'hello'
        module: "#{tmpdir}/my_module.js"
  
  they 'call a module dont overwrite argument', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        content: '''
        module.exports = {
          metadata: {
            argument_to_config: 'a_boolean',
            definitions: {
              config: {
                type: 'object',
                properties: {
                  a_boolean: {
                    type: 'boolean',
                    default: true
                  }
                }
              }
            }
          },
          handler: ({config, metadata}) => {
            return {config, metadata}
          }
        }
        '''
        target: "#{tmpdir}/my_module.js"
      {config, metadata} = await @call "#{tmpdir}/my_module.js"
      config.should.eql
        a_boolean: true
      metadata.should.containEql
        argument: undefined
