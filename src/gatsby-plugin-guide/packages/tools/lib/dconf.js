// Generated by CoffeeScript 2.6.1
// # `nikita.tools.dconf`

// dconf is a low-level configuration system and settings management used by
// Gnome. It is a replacemet of gconf, replacing its XML based database with a
// BLOB based database.

// ## Example

// ```js
// const {$status} = await nikita.tools.dconf({
//   properties: {
//     '/org/gnome/desktop/datetime/automatic-timezone': 'true'
//   }
// });
// console.info(`Property was modified: ${$status}`)
// ```

// ## Note

// Run the command "dconf-editor" to navigate the database with a UI.

// ## Schema definitions
var definitions, handler;

definitions = {
  config: {
    type: 'object',
    properties: {
      'properties': {
        type: 'object',
        patternProperties: {
          '^/.*$': {
            type: ['string', 'boolean', 'number'],
            description: `A value of a key.`
          }
        },
        additionalProperties: false
      }
    },
    required: ['properties']
  }
};

// ## Handler
handler = async function({config}) {
  var k, key, ref, ref1, v, value;
  ref = config.properties;
  // Normalize properties
  for (k in ref) {
    v = ref[k];
    if (typeof v === 'string') {
      continue;
    }
    config.properties[k] = v.toString();
  }
  ref1 = config.properties;
  for (key in ref1) {
    value = ref1[key];
    // Execute
    await this.execute({
      command: `dconf read ${key} | grep -x "${value}" && exit 3
dconf write ${key} "${value}"`,
      code_skipped: 3
    });
  }
  return void 0;
};

// ## Exports
module.exports = {
  handler: handler,
  metadata: {
    definitions: definitions
  }
};