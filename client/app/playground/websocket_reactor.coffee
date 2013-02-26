HOST = 'localhost:8080'
NOISY = true

module.exports = class WebsocketReactor
  # callback will take one argument in the form of
  # { msg: String, from: String|null }
  # assume a null `from` is a system notification
  constructor: (name) ->
    @listeners = []
    @ws = new WebSocket("ws://#{ HOST }?name=#{ escape(name) }")
    @ws.onmessage = (wsData) =>
      wsData = JSON.parse(wsData.data)
      for listener in @listeners
        if value = wsData[listener.key]
          listener.callback(value)

    if NOISY
      @ws.onopen  = -> console.log("socket connected :D")
      @ws.onclose = -> console.log("socket closed :(")

  # when a message with key `key` is received,
  # execute `func(message[key])`
  registerListener: (key, callback) ->
    @listeners.push { key: key, callback: callback }

  send: (msg) ->
    @ws.send(JSON.stringify(msg))
