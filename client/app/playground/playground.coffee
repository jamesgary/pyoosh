WebsocketReactor = require('playground/websocket_reactor')
Renderer = require('playground/renderer')
raf = require('raf')

module.exports = class Playground
  constructor: (name) ->
    wsr = new WebsocketReactor(name)

    $messageDisplay = $('.chat-container .messages')
    $messageInput   = $('.chat-container input.message')
    $messageInput.keypress((e) ->
      if e.which == 13 # enter key
        wsr.send(chat: @value)
        @value = ''
    )

    renderer = new Renderer($('.playground canvas').get(0))

    wsr.registerListener('chat', (data) ->
      if data.from
        output = "<b>#{ data.from }</b>: #{ data.msg }"
      else
        output = "<i>#{ data.msg }</i>"
      $messageDisplay.append("<p>#{ output }</p>")
    )
    wsr.registerListener('playground', (data) ->
      raf( -> wsr.send(playground: '!')) # ping back
      renderer.draw(data)
    )
