###
The plugin enrich the config object with default values defined in the JSON
schema. Thus, it mst be defined after every module which modify the config
object.
###

stream = require 'stream'
{merge, mutate} = require 'mixme'
Ajv = require('ajv').default
ajv_keywords = require 'ajv-keywords'
ajv_formats = require "ajv-formats"
utils = require '../../utils'

instanceofDef = require 'ajv-keywords/dist/definitions/instanceof'
instanceofDef.CONSTRUCTORS['Error'] = Error
instanceofDef.CONSTRUCTORS['stream.Writable'] = stream.Writable
instanceofDef.CONSTRUCTORS['stream.Readable'] = stream.Readable

parse = (uri) ->
  matches = /^(\w+:)\/\/(.*)/.exec uri
  throw utils.error 'NIKITA_SCHEMA_MALFORMED_URI', [
    'uri must start with a valid protocol'
    'such as "module://" or "registry://",'
    "got #{JSON.stringify uri}."
  ] unless matches
  protocol: matches[1]
  pathname: matches[2]

module.exports =
  name: '@nikitajs/core/src/plugins/tools/schema'
  hooks:
    'nikita:normalize':
      handler: (action) ->
        # Handler execution
        # action = await handler.apply null, arguments
        action.tools ?= {}
        # Get schema from parent action
        if action.parent?.tools.schema
          action.tools.schema = action.parent.tools.schema
          return action
        # Instantiate a new schema
        ajv = new Ajv
          $data: true
          allErrors: true
          useDefaults: true
          allowUnionTypes: true # eg type: ['boolean', 'integer']
          strict: true
          strictRequired: false # see https://github.com/ajv-validator/ajv/issues/1571
          coerceTypes: 'array'
          loadSchema: (uri) ->
            new Promise (accept, reject) ->
              try
                {protocol, pathname} = parse uri
              catch err then return reject err
              switch protocol
                when 'module:'
                  try
                    action = require.main.require pathname
                    accept definitions: action.metadata.definitions
                  catch err
                    reject utils.error 'NIKITA_SCHEMA_INVALID_MODULE', [
                      'the module location is not resolvable,'
                      "module name is #{JSON.stringify pathname}."
                    ]
                when 'registry:'
                  module = pathname.split '/'
                  action = await action.registry.get module
                  if action
                    accept definitions: action.metadata.definitions
                  else
                    reject utils.error 'NIKITA_SCHEMA_UNREGISTERED_ACTION', [
                      'the action is not registered inside the Nikita registry,'
                      "action namespace is #{JSON.stringify module.join '.'}."
                    ]
                else
                  reject utils.error 'NIKITA_SCHEMA_UNSUPPORTED_PROTOCOL', [
                    'the $ref instruction reference an unsupported protocol,'
                    "got #{JSON.stringify protocol}."
                  ]
        ajv_keywords ajv
        ajv_formats ajv
        ajv.addKeyword
          keyword: "filemode"
          type: ['integer', 'string']
          compile: (value) ->
            return (data, schema, parentData) ->
              if typeof data is 'string' and /^\d+$/.test data
                schema.parentData[schema.parentDataProperty] = parseInt data, 8
              true
          metaSchema:
            type: 'boolean'
            enum: [true]
        action.tools.schema =
          ajv: ajv
          add: (schema, name) ->
            return unless schema
            ajv.addSchema schema, name
          addMetadata: (name, future) ->
            schema = ajv.getSchema('nikita').schema
            current = schema.definitions.metadata.properties[name]
            return false if utils.object.match current, future
            ajv.removeSchema('nikita')
            schema = merge schema, definitions: metadata: properties: [name]: future
            ajv.addSchema(schema, 'nikita')
            true
          validate: (action, schema) ->
            try
              schema ?= action.metadata.definitions
              schema =
                definitions: schema
                type: 'object'
                allOf: [
                  properties: ( (obj={}) ->
                    obj[k] = $ref: "#/definitions/#{k}" for k, v of schema
                    obj
                  )()
                ,
                  properties: 
                    metadata:
                      $ref: 'nikita#/definitions/metadata'
                ]
              validate = await ajv.compileAsync schema
            catch err
              unless err.code
                err.code = 'NIKITA_SCHEMA_INVALID_DEFINITION'
                err.message = "#{err.code}: #{err.message}"
              throw err
            return if validate utils.object.filter action, ['error', 'output']
            utils.error 'NIKITA_SCHEMA_VALIDATION_CONFIG', [
              if validate.errors.length is 1
              then 'one error was found in the configuration of '
              else 'multiple errors were found in the configuration of '
              if action.metadata.namespace.length
              then "action `#{action.metadata.namespace.join('.')}`"
              else "root action"
              if action.metadata.namespace.join('.') is 'call' and action.metadata.module isnt '@nikitajs/core/src/actions/call'
              then " in module #{action.metadata.module}"
              ':'
              validate.errors
              .map (err) ->
                msg = ' '+err.schemaPath+' '+ajv.errorsText([err]).replace /^data\//, ''
                msg += (
                  for key, value of err.params
                    continue if key is 'missingProperty'
                    ", #{key} is #{JSON.stringify value}"
                ).join '' if err.params
                msg
              .sort()
              .join(';')
            ].join('')+'.'
        await action.plugins.call
          name: 'nikita:schema'
          args: action: action, ajv: ajv, schema:
            definitions:
              metadata:
                type: 'object'
                properties: {}
              tools:
                type: 'object'
                properties: {}
          # TODO: write a test and document before activation
          # hooks: action.hooks['nikita:schema']
          handler: ({action, ajv, schema}) ->
            ajv.addSchema schema, 'nikita'
        action
    'nikita:schema': ({schema}) ->
      mutate schema.definitions.metadata.properties,
        schema:
          type: 'boolean'
          default: true
          description: '''
          Set to `false` to disable schema validation in the
          current action.
          '''
