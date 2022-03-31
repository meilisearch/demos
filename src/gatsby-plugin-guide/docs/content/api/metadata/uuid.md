---
navtitle: uuid
---

# Metadata "uuid"

The `uuid` metadata property identifies a Nikita session. It is shared between all the child actions and contains a universally unique identifier (UUID) value in the [RFC4122](https://www.ietf.org/rfc/rfc4122.txt) format.

* Type: `string`
* Read-only

## Usage

The property is accessed inside the [action handler](/current/api/handler/).

```js
nikita
.call(({metadata: {uuid}}) => {
  // Print the value
  console.info(uuid)
  // The output looks like:
  // 419196e4-48af-4eb6-9dba-4e05653f8007
})
```
