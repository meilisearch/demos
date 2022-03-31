
module.exports =
  array_filter: (arr, handler) ->
    fail = Symbol()
    (
      await Promise.all arr.map (item) ->
        if await handler(item) then item else fail
    ).filter (i) -> i isnt fail
  is: (obj) ->
    # promise && !!promise.then
    return !!obj and (typeof obj is 'object' || typeof obj is 'function') and typeof obj.then is 'function'
