---
sort: 3
---

# Guide

The Nikita API is simple and concise. It also powerful and comes with a lot of functionalities. This section detail the subtleties of the API organized by topics. A lot of efforts were made to illustrate each topic with clear examples.

## Recommendation

Before going through the documentation, you must be familiar with the core concept of Nikita described in the [tutorial](/current/guide/tutorial/).

## Content

The topics of this section are organized by relevance, the first ones being considered as the most relevant ones. 

* [Tutorial](/current/guide/tutorial/)   
  Get started with Nikita's core concepts from installing to using advanced concepts.
* [Call and user-defined handlers](/current/guide/call/)   
  Nikita gives you the choice between calling your own function, which we call handlers, or calling a registered function by its name.
* [Action promise](/current/guide/promise/)   
  Nikita's actions always return [JavaScript Promise](https://nodejs.dev/learn/understanding-javascript-promises) and provide the guarantee that all actions are executed sequentially according to their declaration.
* [Status](/current/guide/status/)   
  The status is information indicating whether an action had any impact or not. Its meaning may differ from one action to another, for example: touching a file, modification of a configuration file, checking if a port is open, ...
* [Local and remote (SSH) execution](/current/guide/local_remote/)   
  Actions are designed to run transparently either locally or remotely through SSH.
* [Conditions](/current/guide/conditions/)   
  Conditions are executed before the [action handlers](/current/api/handler/) to control and guarantee its execution.
* [Assertions](/current/guide/assertions/)   
  Assertions are executed after the [action handlers](/current/api/handler/) to validate the result of its execution.
* [Debugging and Logging](/current/guide/logging_debugging/)   
  Nikita provides multiple mechanisms to report, dive into the logs and intercept instructions. Most of them can be instantaneously activated and you are provided with simple building blocks to quickly write your own.
* [Control Flow](/current/guide/control_flow/)   
  Nikita runs every action sequentially. This behavior ensures there are no conflicts between two commands executed simultaneously. Moreover, this sequential nature is aligned with SSH which executes one command at a time over a given connection.
* [Error handling](/current/guide/error/)   
  Nikita rejects errors when they occur with the [action promise](/current/guide/promise/). When a promise rejects, the control jumps to the closest rejection handler.
