WebsocketReactor = require('playground/websocket_reactor')
Renderer = require('playground/renderer')
raf = require('raf')

module.exports = class Playground
  constructor: (name) ->
    @wsr = new WebsocketReactor(name)
    @canvasTarget = null

    @$messageDisplay = $('.chat-container .messages')
    @$messageInput   = $('.chat-container input.message')
    @$canvas         = $('.playground canvas')
    @renderer        = new Renderer(@$canvas.get(0))

    @attachMessageListener()
    @attachCanvasListener()
    @attachWsrListener()

  # private

  attachMessageListener: ->
    @$messageInput.keypress((e) =>
      if e.which == 13 # enter key
        @wsr.send(chat: e.target.value)
        e.target.value = ''
    )

  attachCanvasListener: ->
    @$canvas.mousemove((e) =>
      parentOffset = $(e.target).offset()
      x = e.pageX - parentOffset.left
      y = e.pageY - parentOffset.top
      @canvasTarget = [x, y]
    )
    @$canvas.mouseleave((e) => @canvasTarget = null)

  attachWsrListener: ->
    @wsr.registerListener('chat', (data) =>
      if data.from # from a user
        output = "<b>#{ data.from }</b>: #{ data.msg }"
      else # from the 'system'
        output = "<i>#{ data.msg }</i>"
      @$messageDisplay.append("<p>#{ output }</p>")
    )
    @wsr.registerListener('playground', (data) =>
      raf( => @wsr.send(playground: target: @canvasTarget))
      @renderer.draw(data)
    )
