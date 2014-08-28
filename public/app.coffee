class App

  constructor: ->
    @loginPage = new LoginPage($('.login.page'))
    @socket = io()
    @chat = new Chat($('.chat.page'))
    @initHandlers()
    @initSocketbindings()
    @initBindings() #

  initHandlers: ->
    @loginPage.on 'username', (username) =>
      @socket.emit 'add user', username

    @chat.on 'new message', (message) =>
      @socket.emit 'new message', message

    @chat.on 'typing', =>
      @socket.emit 'typing'

    @chat.on 'stop typing', =>
      @socket.emit 'stop typing'

  initSocketbindings: ->
    @socket.on 'name taken', =>
      message = 'Name already taken, bro.'
      @loginPage.handleError(message)

    @socket.on 'login', (data) =>
      @loginPage.close()
      @loginPage = null
      @chat.trigger 'welcome', [data]

    @socket.on 'user joined', (data) =>
      @chat.trigger 'user joined', [data]

    @socket.on 'new message', (data) =>
      @chat.trigger 'message', [data]

    @socket.on 'user left', (data) =>
      @chat.trigger 'user left', [data]

    @socket.on 'typing', (data) =>
      @chat.trigger 'typing_message', [data.username]

    @socket.on 'stop typing', (data) =>
      @chat.trigger 'remove_typing_message', [data.username]

  initBindings: ->
    $(window).on 'keydown', (event) =>
      if @loginPage? then target = @loginPage else target = @chat
      target.trigger 'keydown', [event]

@App = App
