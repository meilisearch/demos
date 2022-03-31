
{tags} = require '../../test'
nikita = require '../../../src'

describe 'plugins.metadata.definitions', ->
  return unless tags.api

  it 'expose ajv', ->
    nikita ({tools: {schema}}) ->
      schema.ajv.should.be.an.Object()

  it.skip 'validate strict mode', ->
    # Despite strict mode activated in AJV,
    # This generates a log and execute the handler
    # instead of raising an error
    nikita
      $definitions: config:
        type: 'object'
        properties:
          'parent':
            required: ['child']
    , ->
      console.log 'called but why, the doc say the contrary'

  it 'config is valid', ->
    nikita ->
      {a_string, an_integer} = await @call
        $definitions: config:
          type: 'object'
          properties:
            'a_string': type: 'string'
            'an_integer': type: 'integer', minimum: 1
        a_string: 'a value'
        an_integer: 1
      , ({config}) -> config
      a_string.should.be.a.String()
      an_integer.should.be.a.Number()
  
  describe 'plugins', ->
    
    it 'with `metadata.disabled` as `true`', ->
      # No validation occured when disabled
      nikita
      .call
        $disabled: true
        $definitions: config:
          type: 'object'
          properties:
            'a_string': type: 'string'
          required: ['a_string']
      , -> throw Error 'KO'
      .should.be.resolved()
        
    it 'with `metadata.disabled` as `false`', ->
      # Validation occured when not disabled
      nikita
      .call
        $disabled: false
        $definitions: config:
          type: 'object'
          properties:
            'a_string': type: 'string'
          required: ['a_string']
      , -> throw Error 'KO'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
    
    it 'run after the condition plugin', ->
      definitions =
        config:
          type: 'object'
          properties:
            'a_string': type: 'string'
          required: ['a_string']
      # No validation occured when condition failed
      nikita
      .call
        $definitions: definitions
        $if: false
      , -> throw Error 'KO'
      .should.be.resolved()
      # Validation occured if condition succeed
      nikita
      .call
        $definitions: definitions
        $if: true
      , -> throw Error 'KO'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  describe 'errors', ->

    it 'ensure schema is an object in root action', ->
      nikita
        $definitions: true
        $handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_INVALID_DEFINITION:'
        'schema is invalid:'
        'data/definitions must be object'
      ].join ' '

    it 'ensure schema is an object in child action', ->
      nikita.call
        $definitions: true
        $handler: (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_INVALID_DEFINITION:'
        'schema is invalid:'
        'data/definitions must be object'
      ].join ' '

    it 'invalid with one error', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'an_integer': type: 'integer', 'minimum': 1
        a_string: 1
        an_integer: 0
      , (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/definitions/config/properties/an_integer/minimum config/an_integer must be >= 1,'
        'comparison is ">=", limit is 1.'
      ].join ' '

    it 'nice message with additionalProperties', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'a_string': type: 'string'
          additionalProperties: false
        a_string: 'ok'
        lonely_duck: true
      , (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/definitions/config/additionalProperties config must NOT have additional properties,'
        'additionalProperty is "lonely_duck".'
      ].join ' '
  
  describe 'constructor', ->

    it 'useDefaults', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'a_string':
              type: 'string'
              default: 'a value'
        $handler: ({config}) ->
          config.a_string.should.eql 'a value'

    it.skip 'coerceTypes', ->
      # Option is currently disactivated because it is unclear wether we shall
      # accept its rule or create ours. For example, `true` is cast to string `"true"`
      # and string `""` is cast to `null` which might not be what we want.
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'int_to_string':
              type: 'string'
            'string_to_boolean':
              type: 'boolean'
        $handler: ({config}) ->
          config.int_to_string.should.eql '1234'
          config.string_to_boolean.should.be.false()
        int_to_string: 1234
        string_to_boolean: ''
  
  describe 'ajv-keywords', ->

    it 'instanceof valid', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        a_regexp: /.*/
      -> ({config}) ->
          'ok'.should.match config.a_regexp

    it 'instanceof invalid', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'a_regexp': instanceof: 'RegExp'
        a_regexp: 'invalid'
      , (->)
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of action `call`:'
        '#/definitions/config/properties/a_regexp/instanceof config/a_regexp must pass "instanceof" keyword validation.'
      ].join ' '

  describe 'custom keywords', ->

    it 'filemode true with string casted to octal', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'mode':
              type: ['integer', 'string']
              filemode: true
        mode: '744'
      , ({config}) ->
        config.mode.should.eql 0o0744

    it 'filemode false is invalid', ->
      nikita.call
        $definitions: config:
          type: 'object'
          properties:
            'mode':
              type: ['integer', 'string']
              filemode: false
        mode: '744'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_INVALID_DEFINITION'
        
