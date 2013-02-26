module.exports = ->
  StartChat = require('chat/start_chat')

  $welcome_form = $('form.welcome')
  $name = $welcome_form.find('input.name')

  $welcome_form.modal(
    backdrop: 'static'
    keyboard: false
  )
  $welcome_form.on('shown', ->
    $name.focus()
  )

  $welcome_form.submit( ->
    name = $name.val() || 'Nameless'
    $welcome_form.modal('hide')
    StartChat(name)

    return false
  )
