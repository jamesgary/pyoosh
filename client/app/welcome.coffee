module.exports = class Welcome
  constructor: (onSubmit) ->
    $welcome_form = $('form.welcome')
    $name = $welcome_form.find('input.name')

    $welcome_form.modal(backdrop: 'static', keyboard: false)
    $welcome_form.on('shown', -> $name.focus())

    $welcome_form.submit( ->
      $welcome_form.modal('hide')
      onSubmit($name.val())
      return false
    )
