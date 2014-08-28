$ ->

  # constants
  TYPING_TIMER = 400 # ms
  FADE_TIME = 150 # ms
  COLORS = [
    '#e21400', '#91580f', '#f8a700', '#f78b00',
    '#58dc00', '#287b00', '#a8f07a', '#4ae8c4',
    '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
  ]

  $window = $(window)
  $usernameInput = $('.usernameInput')
  $messages = $('.messages')
  $inputMessage = $('.inputMessage')

  $loginPage = $('.login.page')
  $chatPage = $('.chat.page')

  username = null
  lastTypingTime = null

  connected = false
  typing = false
  $currentInput = $usernameInput.focus()

  socket = io()

  addParticipantsMessage = (data) ->
    message = ''
    if data.numUsers == 1
      message += "there's 1 participant"
    else
      message += "there are #{data.numUsers} participants."
    log(message)

  setUsername = ->
    username = cleanInput($usernameInput.val().trim())

    if(username)
      $loginPage.fadeOut()
      $chatPage.show()
      $loginPage.off('click')
      $currentInput = $inputMessage.focus()

      socket.emit 'add user', username

  sendMessage = ->
    message = $inputMessage.val()
    message = cleanInput(message)

    if message && connected
      $inputMessage.val('')
      addChatMessage
        username: username
        message: message

    socket.emit 'new message', message

  log = (message, options) ->
    $el = $('<li>').addClass('log').text(message)
    addMessageElement($el, options)

  addChatMessage = (data, options) ->
    $typingMessages = getTypingMessages(data)
    options = { } unless options?
    if $typingMessages.length != 0
      options.fade = false
      $typingMessages.remove()

    $usernameSpan = $('<span>')
            .addClass('username')
            .text(data.username)
            .css('color', getUsernameColor(data.username))

    $messageBodySpan = $('<span>').addClass('messageBody').text(data.message)
    if data.typing? then typingClass = 'typing' else typingClass = ''
    console.log typingClass
    $messageLi = $('<li>')
                .addClass("message #{typingClass}")
                .data('username', data.username)
                .append($usernameSpan, $messageBodySpan)

    addMessageElement($messageLi, options)

  addChatTyping = (data) ->
    data.typing = true
    data.message = 'is typing'
    addChatMessage(data)

  removeChatTyping = (data) ->

    getTypingMessages(data).fadeOut(-> $(@).remove())

  addMessageElement = (el, options) ->
    $el = $(el)

    # default options
    options = {} unless options?
    options.fade = true unless options.fade?
    options.prepend = false unless options.prepend?

    $el.hide().fadeIn(FADE_TIME) if options.fade
    if options.prepend then $messages.prepend($el) else $messages.append($el)

    $messages[0].scrollTop = $messages[0].scrollHeight

  # screw markup
  cleanInput = (input) ->
    $('<div>').text(input).text()

  updateTyping = ->
    if connected
      if !typing
        typing = true
        socket.emit 'typing'
      lastTypingTime = (new Date()).getTime()

      callback = ->
        typingTimer = (new Date()).getTime()
        timeDiff = typingTimer - lastTypingTime
        if timeDiff >= TYPING_TIMER && typing
          socket.emit 'stop typing'
          typing = false

      setTimeout(callback, TYPING_TIMER)

  getTypingMessages = (data) ->
    $('.typing.message').filter (i) ->
      $(this).data('username') == data.username

  getUsernameColor = (username) ->
    hash = 7

    for letter, i in username
      hash = username.charCodeAt(i) + ( hash << 5) - hash

    index = Math.abs(hash % COLORS.length)
    COLORS[index]

  $window.on 'keydown', (event) ->

    if event.ctrlKey || event.metaKey || event.altKey
      $currentInput.focus()

    if event.which == 13
      if(username)
        sendMessage()
        socket.emit 'stop typing'
        typing = false
      else
        setUsername()

  $inputMessage.on 'input', ->
    updateTyping()

  $loginPage.on 'click', ->
    $currentInput.focus()

  $inputMessage.on 'click', ->
    $inputMessage.focus()

  socket.on 'login', (data) ->
    connected = true
    message = 'Welcome to Coffeechat! '
    log message, { prepend: true }
    addParticipantsMessage(data)

  socket.on 'new message', (data) ->
    addChatMessage(data)

  socket.on 'user joined', (data) ->
    log "#{data.username} joined"
    addParticipantsMessage(data)

  socket.on 'user left', (data) ->
    log "#{data.username} left"
    addParticipantsMessage(data)
    removeChatTyping(data)

  socket.on 'typing', (data) ->
    addChatTyping(data)

  socket.on 'stop typing', (data) ->
    removeChatTyping(data)
