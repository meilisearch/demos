---
sort: 6
---

# Assertions

Assertions are executed after the [action handler](/current/api/handler/) to validate the result of its execution.

Assertions `assert` and `unassert` validate the [output](/current/api/output/) returned by the action. Other assertions exist and are prefixed with `assert_` or `unassert_` for their negation. On failure, an [error](/current/guide/error/) is thrown with the `NIKITA_INVALID_ASSERTION` code. 

For example, the `unassert_exists` ensures that a file or a directory is not present once the `nikita.fs.remove` action is executed:

```js
(async () => {
  await nikita.fs.remove({
    // highlight-next-line
    $unassert_exists: '/tmp/a_dir',
    recursive: true,
    target: '/tmp/a_dir'
  })
})()
```

Multiple assertions can be combined, in which case, all assertions must succeed. The following example contains 2 assertions applied to `nikita.fs.mkdir` action that creates a directory. The first one, `assert`, ensures the creation of the directory, otherwise the `status` property would be `false`. The second one, `assert_exists`, validates the existence of the directory:

```js
(async () => {
  await nikita.fs.mkdir({
    // highlight-range{1-2}
    $assert: {status: true},
    $assert_exists: '/tmp/a_dir',
    target: "/tmp/a_dir"
  })
})()
```

## `assert`

Asserts the [output](/current/api/output/) of the action after its execution.

Depending on the value of `assert` the assertion has different behavior. When the `assert` value is:

- a **boolean**, a **string**, a **number**, a regular expression, `null` or `undefined`, it asserts it matches the action output.

> Note, a boolean value returned by the handler is interpreted as a value of the [`status` property](/current/guide/status/) of the output object; when `null`, the `status` value is inherited from child actions or it is `false` in lack of children. You can enable the [`raw_output` metadata](/current/api/metadata/raw_output/) to disable this behaviour.

- an **object**, it asserts it partially matches the action output.

- a **function**, the argument is a context object including the `config` object. It is run synchronously after the handler of the action and must return `true` for the assertion to pass.

- an **array of functions**, all its elements must return `true` for the assertion to pass.

```js
(async () => {
  await nikita
  // Null
  .call({
    // highlight-next-line
    $assert: null,
    // disable output interpretation
    $raw_output: true,
    $handler: () => null
  })
  // Boolean
  .call({
    // highlight-next-line
    $assert: true,
    // disable output interpretation
    $raw_output: true,
    $handler: () => true
  })
  // Number
  .call({
    // highlight-next-line
    $assert: 1,
    $handler: () => 1
  })
  // String
  .call({
    // highlight-next-line
    $assert: 'ok',
    $handler: () => 'ok'
  })
  // Object
  .call({
    // highlight-next-line
    $assert: {first: true},
    $handler: () => {
      return {first: true, second: false}
    }
  })
  // Function
  .call({
    // highlight-range{1-3}
    $assert: ({config}) => {
      return config.my_config == 'my_value'
    },
    $handler: ({config}) => {
      config.my_config = 'my_value'
    }
  })
  // Array of functions
  .call({
    // highlight-range{1-7}
    $assert: [
      ({config}) => {
        return config.my_config == 'my_value'
      },
      // always asserts
      () => true
    ],
    $handler: ({config}) => {
      config.my_config = 'my_value'
    }
  })
})()
```

## `unassert`

Negatively asserts [the action output](/current/api/output/) after its execution. It is a negation of the `assert` property.

Depending on the value of `unassert` the assertion has different behavior. When the `unassert` value is:

- a **boolean**, a **string**, a **number**, a regular expression, `null` or `undefined`, it asserts it doesn't match the action output.

- an **object**, it asserts it doesn't partially match the action output.

- a **function**, the argument is a context object including the `config` object. It is run synchronously after the handler of the action and must return `false` for the assertion to pass.

- an **array of functions**, all its elements must return `false` for the assertion to pass.

```js
(async () => {
  await nikita
  // Null
  .call({
    // highlight-next-line
    $unassert: null,
    $handler: () => true
  })
  // Boolean
  .call({
    // highlight-next-line
    $unassert: false,
    $handler: () => true
  })
  // Number
  .call({
    // highlight-next-line
    $unassert: 1,
    $handler: () => 2
  })
  // String
  .call({
    // highlight-next-line
    $unassert: 'ko',
    $handler: () => 'ok'
  })
  // Object
  .call({
    // highlight-next-line
    $unassert: {first: false, second: false},
    $handler: () => {
      return {first: true, second: false}
    }
  })
  // Function
  .call({
    // highlight-range{1-3}
    $unassert: ({config}) => {
      return config.my_config == 'my_wrong_value'
    },
    $handler: ({config}) => {
      config.my_config = 'my_value'
    }
  })
  // Array of functions
  .call({
    // highlight-range{1-7}
    $unassert: [
      ({config}) => {
        return config.my_config == 'my_wrong_value'
      },
      // always asserts
      () => false
    ],
    $handler: ({config}) => {
      config.my_config = 'my_value'
    }
  })
})()
```

## `assert_exists`

Asserts a file or a directory exists after the execution of the action.

The `assert_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence:

```js
(async () => {
  await nikita
  // String
  .fs.mkdir({
    // highlight-next-line
    $assert_exists: '/tmp/a_dir',
    target: "/tmp/a_dir"
  })
  // Array of strings
  .file.touch({
    // highlight-range{1-4}
    $assert_exists: [
      '/tmp/a_dir',
      '/tmp/a_dir/a_file',
    ],
    target: "/tmp/a_dir/a_file"
  })
})()
```

## `unassert_exists`

Asserts a file or a directory doesn't exist after the execution of the action. It is a negation of the `assert_exists` property.

The `unassert_exists` value could be a **string** a an **array of strings**. It is evaluated as paths to files or directories to check for existence:

```js
(async () => {
  await nikita
  // String
  .fs.remove({
    // highlight-next-line
    $unassert_exists: '/tmp/a_dir/a_file',
    target: "/tmp/a_dir/a_file"
  })
  // Array of strings
  .fs.remove({
    // highlight-range{1-4}
    $unassert_exists: [
      '/tmp/a_dir',
      '/tmp/a_dir/a_file',
    ],
    recursive: true,
    target: "/tmp/a_dir"
  })
})()
```
