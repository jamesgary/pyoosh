module.exports = class WebsocketConnection
  HOST = 'localhost:8080'
  NOISY = true

  # callback will take one argument in the form of
  # { msg: String, from: String|null }
  # assume a null `from` is a system notification
  constructor: (name, onReceive) ->
    @ws = new WebSocket("ws://#{ HOST }?name=#{ escape(name) }")
    @ws.onmessage = (e) -> onReceive(JSON.parse(e.data).chat)

    if NOISY
      @ws.onopen  = -> console.log("socket connected :D")
      @ws.onclose = -> console.log("socket closed :(")

  send: (msg) ->
    @ws.send(msg)
