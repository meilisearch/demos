

Promise.all([
  new Promise (resolve, reject) ->
    resolve 1
,
  new Promise (resolve, reject) ->
    reject 2
,
  new Promise (resolve, reject) ->
    resolve 3
]).then (...args) ->
  console.log 'resolved', args
, (err) ->
  console.log 'rejected', err