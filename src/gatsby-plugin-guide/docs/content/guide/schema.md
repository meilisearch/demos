---
sort: 12
---

# Schema definitions

The configuration schema validates the [properties](/current/api/config/) provided to and returned by an action. 

Schema definition is optional but all the actions available in Nikita define a schema. It is used for validation but it also provides additional functionalities such as default values and coercion.

An action can partially or fully inherit from the properties of other actions. Nikita unifies the declaration of schemas using the `definitions` metadata property.

When the action properties don't conform with the schema, the action is rejected with the `NIKITA_SCHEMA_VALIDATION_CONFIG` error.

Schema leverages the [JSON Schema](https://ajv.js.org/json-schema.html) specification. Literally, it is a JavaScript object with validation keywords. Internally, the [Ajv](https://ajv.js.org/) library is used.

## Basic schema definition

To define a schema, use to the `definitions` metadata. For example, when registering an action:

```js
nikita
// Registering an action with schema
.registry.register('my_action', {
  metadata: {
    // highlight-range{1-10}
    definitions: {
      'config': {
        type: 'object',
        properties: {
          'my_config': {
            type: 'string',
            default: 'my value',
            description: 'My configuration property.'
          }
        }
      }
    }
  },
  handler: ({config}) => {
    // Print config
    console.info(config)
  }
})
// Call an action
.my_action()
// Prints:
// { my_config: 'my value' }
```

The above example defines the configuration property `my_config`. It is of type `string`, the default value is `my value` and it has a description. 

It is also possible to provide the `definition` metadata when calling the action. The same action as above could be written as:

```js
nikita
// Call an action
.call({
  // highlight-range{1-10}
  $definitions: {
    'config': {
      type: 'object',
      properties: {
        'my_config': {
          type: 'string',
          default: 'my value',
          description: 'My configuration property.'
        }
      }
    }
  }
}, ({config}) => {
  // Print config
  console.info(config)
})
// Prints:
// { my_config: 'my value' }
```

## Required property

To define a property as required, use the [`required` keyword](https://ajv.js.org/json-schema.html#required) and pass an array of strings with property names: 

```js
nikita
// Registering an action with a required property
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          // highlight-range{1-3}
          'my_config': {
            type: 'string'
          }
        },
        // highlight-next-line
        required: ['my_config']
      }
    }
  },
  handler: ({config}) => {
    // Print config
    console.info(config)
  }
})
// Calling `my_action` with `my_config` fulfills
.my_action({my_config: 'my value'})
// Prints:
// { my_config: 'my value' }
// Calling `my_action` without `my_config` rejects an error
.my_action()
// Catch error
.catch(err => {
  // Print the error message
  console.info(err.message)
})
// Prints:
// NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration of action `my_action`: #/definitions/config/required config should have required property 'my_config'.
```

To define a property as conditionally required property, use the [`if`/`then`/`else` properties](https://ajv.js.org/json-schema.html#if-then-else). The following example defines the `my_config` property required only when the value of `my_flag` is `true`:

```js
nikita
// Registering an action with a conditionally required property
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          // highlight-range{1-3}
          'my_flag': {
            type: 'boolean',
          },
          'my_config': {
            type: 'string'
          }
        },
        // highlight-range{1-2}
        if: {properties: {'my_flag': {const: true}}},
        then: {required: ['my_config']}
      }
    }
  },
  handler: ({config}) => {
    // Print config
    console.info(config)
  }
})
// Calling `my_action` with `my_flag: false` fulfills
.my_action({
  my_flag: false
})
// Prints:
// { my_flag: false }
// Calling `my_action` with `my_config` defined fulfills
.my_action({
  my_config: 'my value'
})
// Prints:
// { my_config: 'my value' }
// Calling `my_action` without `my_flag: true` rejects an error
.my_action({my_flag: true})
// Catch error
.catch(err => {
  // Print the error message
  console.info(err.message)
})
// Prints:
// NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors were found in the configuration of action `my_action`: #/definitions/config/if config should match "then" schema, failingKeyword is "then"; #/definitions/config/then/required config should have required property 'my_config'.
```

## Coercing data types

Type coercion is about changing a value from one data type to another. For example, an integer could be converted to a string with numeric characters.

Based on the schema definitions, the action arguments are automatically converted to the targeted types before executing the action handler. In this example, the `my_config` configuration is defined as a string. If a user call the action with an integer, it is coerced to a string:

```js
nikita
// Registering an action
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          'my_config': {
            // highlight-next-line
            type: 'string'
          }
        }
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Pass a number to `my_config`
.my_action({
  // highlight-next-line
  my_config: 100
})
// Prints:
// string
```

Follow the [Ajv documentation](https://ajv.js.org/coercion.html) to learn all the possible type coercions.

## Multiple data types

Multiple types can be defined by setting the `type` property as an array:

```js
nikita
nikita
// Registering an action with multiple data types properties
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          'my_config': {
            // highlight-next-line
            type: ['string', 'number']
          }
        },
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Calling `my_action` passing a number to `my_config` prints "number"
.my_action({my_config: 10})
// Calling `my_action` passing a string to `my_config` prints "string"
.my_action({my_config: 'my value'})
```

Be careful when using the alternative [`oneOf` keyword](https://ajv.js.org/json-schema.html#oneof). Because coercion is activated, the rule will fail if the value is compatible with multiple types. For example, the following declaration will fail if the property can be converted to both a `string` and a `number`:

```json
{
  ...
  "my_config": {
    "oneOf": [
      {"type": "string"},
      {"type": "number"},
    ]
  }
}
```

Refers the [Ajv documentation](https://ajv.js.org/coercion.html#coercion-from-string-values) to learn more.

## Referencing internal properties

To reference a property defined in another action, use the `$ref` keyword.

To reference a property of the current action, use the `$ref` keyword in a combination with `definitions`:

```js
nikita
// Registering an action with referenced properties
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          'my_config': {
            // highlight-next-line
            $ref: '#/definitions/my_referenced_config'
          }
        }
      },
      // highlight-range{1-3}
      'my_referenced_config': {
        type: 'string'
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Calling `my_action` prints "string", because the number type coerced to string.
.my_action({my_config: 10})
```

## Referencing external properties

To reference a property in an external action, Nikita introduces two discovery mechanisms.

The `module://` prefix search for the action exported in the location defined after the prefix. It uses the [Node.js module discovery algorithm](https://nodejs.org/api/modules.html#modules_all_together).

```js
nikita
// Registering an action with referenced properties
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          // highlight-range{1-3}
          'my_config': {
            $ref: 'module://@nikitajs/core/lib/actions/fs/base/readdir#/definitions/config/properties/target'
          }
        }
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Calling `my_action` prints "string", because the number type coerced to string.
.my_action({my_config: 10})
```

The `registry://` prefix search for an action present in the [registry](/current/guide/registry/):

```js
nikita
// Registering an action
.registry.register(['my', 'first', 'action'], {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          // highlight-range{1-3}
          'my_config': {
            type: 'string'
          }
        }
      }
    }
  }
})
// Registering an action with referenced properties
.registry.register(['my', 'second', 'action'], {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          // Referencing via registry
          // highlight-range{1-3}
          'my_config': {
            $ref: 'registry://my/first/action#/definitions/config/properties/my_config'
          }
        }
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Calling `my.second.action` prints "string", because the number type coerced to string.
.my.second.action({my_config: 10})
```

## Pattern properties

An object with dynamic keys is validated with the [`patternProperties` keyword](https://ajv.js.org/json-schema.html#patternproperties). The value of this keyword is a map where keys are regular expressions and the values are JSON Schemas.

In this example, all the keys starting with `my_` must be of type `string`:
 
```js
nikita
// Registering an action with the pattern property
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        // highlight-range{1-5}
        patternProperties: {
          'my_.*': {
            type: 'string'
          }
        }
      }
    }
  },
  handler: ({config}) => {
    // Print the config type
    console.info(typeof config.my_config)
  }
})
// Calling `my_action` prints "string", because the number type coerced to string.
.my_action({my_config: 10})
```

## Disallowing additional properties

By default, not all properties must be defined in the schema. Additional properties are not evaluated and are passed as-is. To enforce the schema definition of every property, use the [`additionalProperties` keyword](https://ajv.js.org/json-schema.html#additionalproperties) with the `false` value.

The following example disallows passing any properties other than `my_config`: 

```js
nikita
// Registering an action disallowing additional properties
.registry.register('my_action', {
  metadata: {
    definitions: {
      'config': {
        type: 'object',
        properties: {
          'my_config': {
            type: 'string'
          }
        },
        // Disallow additional properties
        // highlight-next-line
        additionalProperties: false
      }
    }
  }
})
// Calling `my_action` with the `my_another_config` config will not be fulfilled
.my_action({my_another_config: 10})
// Catch error
.catch(err => {
  // Print error message
  console.info(err.message)
})
// Prints:
// NIKITA_SCHEMA_VALIDATION_CONFIG: one error was found in the configuration of action `my_action`: #/definitions/config/additionalProperties config should NOT have additional properties, additionalProperty is "my_another_config".
```
