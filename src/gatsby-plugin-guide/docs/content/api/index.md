---
navtitle: API
sort: 2
---

# Action API

An action is the single unit of work in Nikita. Technically, it is a simple JavaScript object consisting of well-defined properties as well as some specific properties related to each action. Such actions include writing a file in a given format, executing a shell command, or controlling the life cycle of a Unix service.

The most important and only required property is the [`handler` function](/current/api/handler/), which does all the work. Handlers are designed to be stateless. They take some input information, do some work and send back some output information. They are executed sequentially, in the order of declaration. They may themselves call other actions to achieve their purpose. Thus, despite being executed sequentially, actions are organized as hierarchical trees.

The handler receives all the properties of the action as an argument. We call those properties [configuration](/current/api/config/). They are available as `config` property and can define default values when declaring the action. Also, the user may overwrite any of the configuration properties. Thus, they are used to contextualize the handler.

Nikita's actions always return [Javascript Promise](https://nodejs.dev/learn/understanding-javascript-promises). To access the [action output](/current/api/output/), you have to call an asynchronous function and "await" for the result of Promise.

Remember, in the end, an action is a JavaScript object with the mandatory property `handler`, and some configuration properties. Some properties are common to all Nikita actions, such as the [`shy`](/current/api/metadata/shy/) or the [`relax`](/current/api/metadata/relax/) [metadata properties](/current/api/metadata/), or they can be specific to an action, such as the `target` configuration property of the [`nikita.file` action](/current/actions/file/) indicating the path where the content is written.

## Composition

* [Arguments](/current/api/args/) (array)   
  Original arguments passed on an action call.
* [Children](/current/api/children/) (array)   
  Actions executed in the handler of a parent action.
* [Config](/current/api/config/) (object)   
  Configuration properties are used to contextualize the handler function.
* [Context](/current/api/context/) (function)   
  When action handlers are defined as traditional function expressions, they are executed with an action context. This context is useful to call child actions.
* [Handler](/current/api/handler/) (function, required)   
  Define the function that an action implements to get things done.
* [Metadata](/current/api/metadata/) (object)   
  Contextualize or modify the execution of Nikita's action.
* [Output](/current/api/output/) (object)   
  Action output is the result returned by Nikita's actions.
* [Parent action](/current/api/parent/) (object)   
  An action of the higher level in the session tree.
* [Sibling action](/current/api/sibling/) (object)   
  An action with the same parent and which was executed just before the current action.
* [Siblings](/current/api/siblings/) (array)   
  Actions at the same hierarchical level executed before the current action.
* [Tools](/current/api/tools/) (object)   
  Provide additional functionalities to Nikita's actions.
