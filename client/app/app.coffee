$( ->
  ws = new WebSocket("ws://localhost:8080")
  $messageDisplay = $('.chat-container .messages')
  $messageInput   = $('.chat-container input.message')

  displayMessage = (from, msg) ->
    $messageDisplay.append("<p><b>#{ from }</b>: #{ msg }</p>")

  $messageInput.keypress( (e) ->
    if e.which == 13 # enter key
      ws.send(JSON.stringify(from: 'me', msg: @value))
      @value = ''
  )

  ws.onopen  = -> console.log("socket connected :D")
  ws.onclose = -> console.log("socket closed :(")
  ws.onmessage = (e) ->
    console.log e
    data = JSON.parse(e.data)
    displayMessage(data.from, data.msg)
)
