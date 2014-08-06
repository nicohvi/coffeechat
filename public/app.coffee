$ ->

  # constants
  TYPING_TIMER = 1000 # ms
  FADE_TIME = 150 # ms
  COLORS = [
    '#e21400', '#91580f', '#f8a700', '#f78b00',
    '#58dc00', '#287b00', '#a8f07a', '#4ae8c4',
    '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
  ]

  # socket attributes
  connected = false
  username = null
  socket = io()
  typing = false
  lastTypingTime = null

  # DOM elements
  $loginPage = $('.login')
  $chatPage = $('.chat')
  $messages = $('.messages')
  $username = $('.username-input')
  $messageInput = $('.new-message')
  $input = $username.focus()

  addUser = ->
    username = cleanInput $username.val().trim()
    socket.emit('add user', username) if username

  connect = ->
    connected = true
    $loginPage.fadeOut();
    $chatPage.show();
    $loginPage.off('click');
    $input = $messageInput.focus();

  sendMessage = ->
    message = cleanInput $input.val().trim()

    if message && connected
      $input.val('')
      addChatMessage { username: username, message: message }
      socket.emit 'new message', message

  cleanInput = (input) ->
    $('<div/>').text(input).text()

  addParticipantsMessage = (data) ->
    if data.numUsers == 1 then message = 'There\'s 1 participant.'
    else message = "There are #{data.numUsers} participants."
    log(message)

  log = (message, options) ->
    $el = $('<li class="log" />').text(message)
    addMessageElement($el, options)

  addChatMessage = (data, options) ->
    options = {} unless options?

    if getTypingMessages(data).length > 0
      options.fade = false

    $userEl = $('<span class="username" />')
      .text(data.username)
      .css('color', getUsernameColor(data.username))
    $messageBodyEl = $('<span class="message-body" />')
      .text(data.message)

    if data.typing then typingClass = 'typing' else typingClass = ''

    $messageEl = $('<li class="message" />')
      .data('username', data.username)
      .addClass(typingClass)
      .append($userEl, $messageBodyEl)

    addMessageElement($messageEl, options)

  addTypingMessage = (data) ->
    data.typing = true
    data.message = ' is typing. If you write something, he might stop.'
    addChatMessage(data)

  removeTypingMessage = (data) ->
    getTypingMessages(data).fadeOut -> $(@).remove()

  addMessageElement = ($el, options) ->
    options = {} unless options?
    options.fade = true unless options.fade?
    options.prepend = false unless options.prepend?

    $el.hide().fadeIn(FADE_TIME) if options.fade
    if options.prepend then $messages.prepend($el) else $messages.append($el)

    $messages[0].scrollTop = $messages[0].scrollHeight

  updateTyping = ->
    return unless connected

    unless typing
      typing = true
      socket.emit 'typing'

    # find out if the user has stopped typing
    lastTypingTime = new Date().getTime()

    setTimeout(
      ->
        now = new Date().getTime()
        offset = now - lastTypingTime
        if offset >= TYPING_TIMER && typing
          socket.emit 'stop typing'
          typing = false
      ,
      TYPING_TIMER)

  getTypingMessages = (data) ->
    $('.typing.message').filter ->
      $(@).data('username') == data.username

  getUsernameColor = (username) ->
    hash = 7
    for letter, i in username
      hash = username.charCodeAt(i) + (hash << 5) - hash
    index = Math.abs hash % COLORS.length
    COLORS[index]

  # event listeners

  $(@).keydown (event) ->
    $input.focus()
    if event.which == 13
      if connected
        sendMessage()
        typing = false
        socket.emit 'stop typing'
      else
        addUser()

  $chatPage.on 'click', (event) ->
    $input.focus()

  $loginPage.on 'click', (event) ->
    $input.focus()

  $messageInput.on 'input', ->
    updateTyping()

  # socket.io listeners

  socket.on 'used name', ->
    $errorEl = $('<div class="notice"/>')
      .text("Username already in use, bruv.")
    $('.form').prepend($errorEl)

  socket.on 'login', (data) ->
    connect()
    message = "Welcome to Coffeechat, #{data.username}."

    log message, { prepend: true }
    addParticipantsMessage(data)

  socket.on 'user joined', (data) ->
    return if data.username == username
    log("#{data.username} has joined the chat.")
    addParticipantsMessage(data)

  socket.on 'new message', (data) ->
    addChatMessage(data)

  socket.on 'typing', (data) ->
    addTypingMessage(data)

  socket.on 'stop typing', (data) ->
    removeTypingMessage(data)

  socket.on 'user left', (data) ->
    log("#{data.username} has made like Elvis.")
    addParticipantsMessage(data)
    removeChatTyping(data)
