
# `nikita.kv.memory`

## Source Code

    module.exports = ->
      store = {}
      set: (key, value) ->
        store[key] ?= {}
        store[key].value = value
        store[key].promises ?= []
        while promise = store[key].promises.shift()
          promise.call null, store[key].value
      get: (key) ->
        new Promise (resolve) ->
          if store[key]?.value
            resolve store[key]?.value
          else
            store[key] ?= {}
            store[key].promises ?= []
            store[key].promises.push resolve
