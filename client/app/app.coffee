module.exports = ->
  Playground = require('playground/playground')
  Welcome   = require('welcome')

  new Welcome((name) ->
    new Playground(name)
  )
