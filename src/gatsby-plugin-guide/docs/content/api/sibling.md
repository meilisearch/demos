---
sort: 6
related:
- /api/siblings/
- /api/parent/
- /api/children/
---

# Sibling action

Nikita stores the hierarchical tree of the actions running in a Nikita session. The sibling is the action with the same parent and which was executed just before the current action.

The `sibling` property is an alias of `siblings[siblings.length-1]`.

## Properties

It is an object with the following properties:

- `children`   
  The [child actions](/current/api/children/) relative to the current action.
- `metadata`   
  The [metadata properties](/current/api/metadata/) of the action.
- `config`   
  The [configuration properties](/current/api/config/)/ passed to an action call.
- `error`   
  The [error object](/current/guide/error/) in a rejected action.
- `output`   
  The [returned output](/current/api/output/) in a resolved action.

## Usage

The properties are available in the [action handler](/current/api/handler/) under the `sibling` property in the first argument:

```js
nikita
// Call 1st action
.call(() => true)
// Call 2nd action
.call(({sibling}) => {
  // Print the sibling action
  console.info(sibling)
})
```
