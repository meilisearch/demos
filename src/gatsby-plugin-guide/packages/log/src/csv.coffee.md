
# `nikita.log.csv`

Write logs to the host filesystem in the CSV format.

## Schema definitions

The `log.csv` action leverages the [`log.fs` action](/current/actions/log/fs/)
and honors all its configuration properties.

    definitions =
      config:
        type: 'object'
        allOf: [
          properties:
            serializer:
              type: 'object'
              default: {}
              description: '''
              Internal property, expose access to the serializer object passed
              to the `log.fs` action.
              '''
        ,
          $ref: 'module://@nikitajs/log/src/fs#/definitions/config'
        ]

## Handler

    handler = ({config}) ->
      serializer =
        'nikita:action:start': ({action}) ->
          return unless action.metadata.header
          walk = (parent) ->
            precious = parent.metadata.header
            results = []
            results.push precious unless precious is undefined
            results.push ...(walk parent.parent) if parent.parent
            results
          headers = walk action
          header = headers.reverse().join ' : '
          "header,,#{JSON.stringify header}\n"
        'text': (log) ->
          "#{log.type},#{log.level},#{JSON.stringify log.message}\n"
      config.serializer = merge serializer, config.serializer
      @log.fs config

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## Dependencies

    {merge} = require 'mixme'
