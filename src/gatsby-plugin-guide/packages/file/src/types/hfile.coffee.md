
# `nikita.file.types.hfile`

HFile is an XML format used accros Hadoop components which contains keys and
value properties.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'merge':
            type: 'boolean'
            description: '''
            Read the target if it exists and merge its content, optional.
            '''
          'source':
            type: ['object', 'string']
            description: '''
            Default configuration properties or the path to a default
            configuration file to get initial value from, optional.
            '''
          'target':
            type: 'string'
            description: '''
            Configuration file where to write, required.
            '''
          'properties':
            type: 'object'
            description: '''
            Configuration properties to write, required.
            '''
          'transform':
            oneOf: [{typeof: 'function'}, {type: 'null'}]
            default: null
            description: '''
            User defined function used to transform properties.
            '''
          # File configuration properties
          'backup':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/backup'
          'backup_mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/backup_mode'
          'eof':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/eof'
          'encoding':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/encoding'
            default: 'utf8'
          'uid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/uid'
          'gid':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/gid'
          'mode':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/mode'
          'local':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/local'
          'unlink':
            $ref: 'module://@nikitajs/file/src/index#/definitions/config/properties/unlink'

## Handler

    handler = ({config, tools: {log}}) ->
      fnl_props = {}
      org_props = {}
      # Read target properties
      log message: "Read target properties from '#{config.target}'", level: 'DEBUG', module: '@nikita/file/lib/types/hfile'
      # Populate org_props and, if merge, fnl_props
      try
        {data} = await @fs.base.readFile
          encoding: config.encoding
          target: config.target
        org_props = parse data
        if config.merge
          fnl_props = {}
          for k, v of org_props then fnl_props[k] = v
      catch err
        throw err unless err.code is 'NIKITA_FS_CRS_TARGET_ENOENT'
      # Read source properties
      if config.source and typeof config.source is 'string'
        log message: "Read source properties from #{config.source}", level: 'DEBUG', module: '@nikita/file/lib/types/hfile'
        # Populate config.source
        {data} = await @fs.base.readFile
          $ssh: false if config.local
          encoding: config.encoding
          target: config.target
        config.source = parse data
      # Merge source properties
      if config.source
        # Note, source properties overwrite current ones by source, not sure
        # if this is the safest approach
        log message: "Merge source properties", level: 'DEBUG', module: '@nikita/file/lib/types/hfile'
        for k, v of config.source
          v = "#{v}" if typeof v is 'number'
          fnl_props[k] = v if fnl_props[k] is undefined or fnl_props[k] is null
      # Merge user properties
      log message: "Merge user properties", level: 'DEBUG', module: '@nikita/file/lib/types/hfile'
      for k, v of config.properties
        v = "#{v}" if typeof v is 'number'
        unless v?
          delete fnl_props[k]
        else if Array.isArray v
          fnl_props[k] = v.join ','
        else if typeof v isnt 'string'
          throw Error "Invalid value type '#{typeof v}' for property '#{k}'"
        else fnl_props[k] = v
      # Apply transformation
      fnl_props = config.transform fnl_props if config.transform
      # Final merge
      keys = {}
      for k in Object.keys(org_props) then keys[k] = true
      for k in Object.keys(fnl_props) then keys[k] = true unless keys[k]?
      keys = Object.keys keys
      for k in keys
        continue unless org_props[k] isnt fnl_props[k]
        log message: "Property '#{k}' was '#{org_props[k]}' and is now '#{fnl_props[k]}'", level: 'WARN', module: '@nikita/file/lib/types/hfile'
      await @file
        content: stringify fnl_props
        target: config.target
        source: undefined
        backup: config.backup
        backup_mode: config.backup_mode
        eof: config.eof
        encoding: config.encoding
        uid: config.uid
        gid: config.gid
        mode: config.mode
        local: config.local
        unlink: config.unlink
      
## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions

## `parse(xml, [property])`

Parse an xml document and retrieve one or multiple properties.

Retrieve all properties: `properties = parse(xml)`
Retrieve a property: `value = parse(xml, property)`

    parse = (markup, property) ->
      properties = {}
      doc = new xmldom.DOMParser().parseFromString markup
      for propertyChild in doc.documentElement.childNodes
        continue unless propertyChild.tagName?.toUpperCase() is 'PROPERTY'
        name = value = undefined
        for child in propertyChild.childNodes
          if child.tagName?.toUpperCase() is 'NAME'
            name = child.childNodes[0].nodeValue
          if child.tagName?.toUpperCase() is 'VALUE'
            value = child.childNodes[0]?.nodeValue or ''
        return value if property and name is property and value?
        properties[name] = value if name and value?
      return properties

## `stringify(properties)`

Convert a property object into a valid Hadoop XML markup. Properties are
ordered by name.

Convert an object into a string:

```
markup = stringify({
  'fs.defaultFS': 'hdfs://namenode:8020'
});
```

Convert an array into a string:

```
stringify([{
  name: 'fs.defaultFS', value: 'hdfs://namenode:8020'
}])
```

    stringify = (properties) ->
      markup = builder.create 'configuration', version: '1.0', encoding: 'UTF-8'
      if Array.isArray properties
        properties.sort (el1, el2) -> el1.name > el2.name
        for {name, value} in properties
          property = markup.ele 'property'
          property.ele 'name', name
          property.ele 'value', value
      else
        ks = Object.keys properties
        ks.sort()
        for k in ks
          property = markup.ele 'property'
          property.ele 'name', k
          property.ele 'value', properties[k]
      markup.end pretty: true

## Dependencies

    xmldom = require 'xmldom'
    builder = require 'xmlbuilder'
