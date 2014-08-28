class Chat extends EventEmitter

  constructor: (@el) ->
    console.log 'w0t'
    @FADE_TIME = 150 # ms
    @TYPING_TIMER = 400 # ms
    @COLORS = [
      '#e21400', '#91580f', '#f8a700', '#f78b00',
      '#58dc00', '#287b00', '#a8f07a', '#4ae8c4',
      '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
    ]

    @typing = false
    @messages = $('.messages')
    @inputMessage = $('.inputMessage')
    @initHandlers()
    @initBindings()

  initHandlers: ->
    @.on 'keydown', (event) =>
      if event.which == 13
        @typing = false
        @sendMessage()
      else
        @inputMessage.focus()

    @.on 'welcome', (data) =>
      @el.show()
      @username = data.username
      message = 'Welcome to Coffeechat!'
      @log(message, { prepend: true })
      @addParticipantsMessage(data.numUsers)

    @.on 'message', (data) =>
      @buildChatMessage(data.username, data.message)

    @.on 'user joined', (data) =>
      @log("#{data.username} joined")
      @addParticipantsMessage(data.numUsers)

    @.on 'user left', (data) =>
      @log("#{data.username} left")
      @addParticipantsMessage(data.numUsers)
      @removeTypingMessage(data.username)

    @.on 'typing_message', (username) =>
      @addTypingMessage(username)

    @.on 'remove_typing_message', (username) =>
      @removeTypingMessage(username)

  initBindings: ->
    @inputMessage.on 'input', =>
      @updateTyping()

    @el.on 'click', =>
      @inputMessage.focus()

  sendMessage: ->
    message = @inputMessage.val()
    if message?
      @inputMessage.val('')
      @buildChatMessage(@username, message)
      @.emit 'new message', message

  log: (message, options) ->
    $el = $('<li>').addClass('log').text(message)
    @addMessageElement($el, options)

  getUsernameColor: (username) ->
    hash = 7
    for letter, i in username
      hash = username.charCodeAt(i) + ( hash << 5) - hash

    index = Math.abs(hash % @COLORS.length)
    @COLORS[index]

  buildChatMessage: (username, message, options) ->

    options = { } unless options?
    $typingMessage = @getTypingMessages(username)

    if $typingMessage.length > 0
      options.fade = false # only fade IF there is a typing message for this user.
      $typingMessage.remove()

    $usernameSpan = $('<span>')
            .addClass('username')
            .text(username)
            .css('color', @getUsernameColor(username))

    $messageBodySpan = $('<span>').addClass('messageBody').text(message)
    if options.typing? then typingClass = 'typing' else typingClass = ''
    $messageLi = $('<li>')
                .addClass("message #{typingClass}")
                .data('username', username)
                .append($usernameSpan, $messageBodySpan)

    @addMessageElement($messageLi, options)

  addMessageElement: (el, options) ->
    $el = $(el)

    # default options
    options = { } unless options?
    options.fade = true unless options.fade?
    options.prepend = false unless options.prepend?

    $el.hide().fadeIn(@FADE_TIME) if options.fade
    if options.prepend then @messages.prepend($el) else @messages.append($el)

    @messages[0].scrollTop = @messages[0].scrollHeight

  addParticipantsMessage: (numUsers) ->
    if numUsers == 1 then message = "There's 1 participant." else message = "There are #{numUsers} participants."
    @log(message)

  updateTyping: ->
    unless @typing
      @typing = true
      @.emit 'typing'
    lastTypingTime = (new Date()).getTime()

    callback = =>
      typingTimer = (new Date()).getTime()
      timeDiff = typingTimer - lastTypingTime
      if timeDiff >= @TYPING_TIMER && @typing
        @.emit 'stop typing'
        @typing = false

    setTimeout(callback, @TYPING_TIMER)

  addTypingMessage: (username) ->
    options = { }
    options.typing = true
    message = 'is typing'
    @buildChatMessage(username, message, options)

  removeTypingMessage: (username) ->
    @getTypingMessages(username).fadeOut(-> $(@).remove())

  getTypingMessages: (username) ->
    $('.typing.message').filter (i) ->
      $(this).data('username') == username

@Chat = Chat
