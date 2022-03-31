---
sort: 6
related:
- /api/sibling/
- /api/parent/
- /api/children/
---

# Siblings

Nikita stores the hierarchical tree of the actions running in a Nikita session. The siblings are the actions at the same hierarchical level executed before the current action.

It is an array of [`sibling`](/current/api/sibling/) actions ordered according to their execution. Thus, the last index of the sibling array is the last executed sibling action.

The array of sibling actions is available in the [action handler](/current/api/handler/) as the `siblings` property in the first argument:

```js
nikita
// Call 1st action
.call(() => true)
// Call 2nd action
.call(({siblings}) => {
  // Print the sibling action
  console.info(siblings)
})
```
