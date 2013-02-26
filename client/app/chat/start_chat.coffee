module.exports = (name) ->
  WebsocketConnection = require('chat/websocket_connection')

  $messageDisplay = $('.chat-container .messages')
  $messageInput   = $('.chat-container input.message')

  chat = new WebsocketConnection(name, (msg) ->
    if msg.from
      output = "<b>#{ msg.from }</b>: #{ msg.msg }"
    else
      output = "<i>#{ msg.msg }</i>"
    $messageDisplay.append("<p>#{ output }</p>")
  )

  $messageInput.keypress((e) ->
    if e.which == 13 # enter key
      chat.send(@value)
      @value = ''
  )
