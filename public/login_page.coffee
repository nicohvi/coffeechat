class LoginPage extends EventEmitter

  constructor: (@el) ->
    @usernameInput = $('.usernameInput')
    @initHandlers()

  initHandlers: ->
    @.on 'keydown', (event) =>

      if event.ctrlKey || event.metaKey || event.altKey
        @usernameInput.focus()

      @setUsername() if event.which == 13 # try to log in if enter is pressed.

  setUsername: ->
    @.emit 'username', cleanInput(@usernameInput.val().trim())

  cleanInput = (input) ->
    $('<div>').text(input).text()

  handleError: (error) ->
    $('<div>').addClass('error').text(error).prependTo(@el)

  close: ->
    @el.fadeOut()

@LoginPage = LoginPage
