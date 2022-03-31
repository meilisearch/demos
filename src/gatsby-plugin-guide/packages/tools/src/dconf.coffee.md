
# `nikita.tools.dconf`

dconf is a low-level configuration system and settings management used by
Gnome. It is a replacemet of gconf, replacing its XML based database with a
BLOB based database.

## Example

```js
const {$status} = await nikita.tools.dconf({
  properties: {
    '/org/gnome/desktop/datetime/automatic-timezone': 'true'
  }
});
console.info(`Property was modified: ${$status}`)
```

## Note

Run the command "dconf-editor" to navigate the database with a UI.

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'properties':
            type: 'object'
            patternProperties:
              '^/.*$':
                type: ['string', 'boolean', 'number']
                description: '''
                A value of a key.
                '''
            additionalProperties: false
        required: ['properties']

## Handler

    handler = ({config}) ->
      # Normalize properties
      for k, v of config.properties
        continue if typeof v is 'string'
        config.properties[k] = v.toString()
      # Execute
      await @execute (
        command: """
        dconf read #{key} | grep -x "#{value}" && exit 3
        dconf write #{key} "#{value}"
        """
        code_skipped: 3
      ) for key, value of config.properties
      undefined

## Exports

    module.exports =
      handler: handler
      metadata:
        definitions: definitions
