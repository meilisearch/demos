---
sort: 7
related:
- /api/children/
- /api/sibling/
- /api/siblings/
---

# Parent action

Nikita stores the hierarchical tree of the actions running in a Nikita session. The parent is an action of the higher level in the session tree. All Nikita's actions have a parent action except the root Nikita action instantiating a Nikita session.

The parent action is accessed inside the [action handler](/current/api/handler/) in the `parent` property of the first argument. It is an object containing all the action properties.

```js
nikita
// Call an action
.call(({parent}) => {
  // Print the parent action
  console.info(parent)
})
```
