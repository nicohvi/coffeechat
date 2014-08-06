$ ->

  # constants
  TYPING_TIMER = 1000 # ms
  FADE_TIMER = 2000 # ms
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

  sendMessage = ->
    message = cleanInput $input.val().trim()

    if message && connected
      $input.val('')
      addChatMessage message, { username: username }
      typing = false
      socket.emit 'new message', message

  cleanInput = (input) ->
    $('<div/>').text(input).text()

  updateTyping = ->
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

  # adding messages to $messages
  addChatMessage = (message, options) ->
    options = {} unless options?
    $userEl = $('<span class="username" />')
      .text(options.username)
    $messageBodyEl = $('<span class="message-body" />')
      .text(message)
    $messageEl = $('<li class="message" />')
      .data('username', options.username)
      .append($userEl, $messageBodyEl)
    addMessageElement($messageEl, options)

  addSystemMessage = (message, options) ->
    options = {} unless options?
    if options.typing? then typingClass = "typing" else typingClass = ""
    $messageBodyEl = $('<span class="message-body" />')
      .text(message)
    $messageEl = $("<li class=\"message system #{typingClass}\" />")
      .append($messageBodyEl)
    $messageEl.data('username', options.username) if options.username?
    addMessageElement($messageEl, options)

  addMessageElement = ($el, options) ->
    options = {} unless options?
    removeTypingMessages(options.username) if options.username?
    if options.prepend? then $messages.prepend($el) else $messages.append($el)
    # scroll to the newest message
    if options.fade?
      setTimeout(
        ->
          $el.remove()
        ,
        FADE_TIMER)
    $messages[0].scrollTop = $messages[0].scrollHeight

  removeTypingMessages = (username) ->
    $typingMessages = $('.system.typing').filter((i) ->
      $(@).data('username') == username
    )
    $typingMessages.remove()

  # event handlers
  $(@).keydown (event) ->
    if event.which == 13
      if username? then sendMessage() else addUser()

  $chatPage.on 'click', (event) ->
    $input.focus()

  $loginPage.on 'click', (event) ->
    $input.focus()

  $messageInput.on 'input', ->
    return unless connected
    updateTyping()


  # socket.io listeners

  socket.on 'used name', ->
    username = null
    error = "Username already in use, bruv."
    $errorEl = $('<div class="notice"/>')
      .text(error)
    $('.form').prepend($errorEl)
    $input.addClass('error')

  socket.on 'login', (data) ->
    connected = true
    $loginPage.fadeOut()
    $chatPage.show()
    $loginPage.off('click')
    $input = $messageInput.focus()
    message = "Welcome to Coffeechat, #{data.username}."
    addSystemMessage message, { prepend: true }

  socket.on 'user joined', (data) ->
    return unless connected
    message = "#{data.username} has joined the chat.
              Total user count: #{data.numUsers}."
    addSystemMessage(message)

  socket.on 'new message', (data) ->
    return unless connected
    message = data.message
    addChatMessage message, { username: data.username }

  socket.on 'typing', (data) ->
    return unless connected ||  data.username == username
    message = "#{data.username} is typing, if you start typing as well
              he might stop."
    addSystemMessage message, { username: data.username, typing: true }

  socket.on 'stop typing', (data) ->
    return unless connected ||  data.username == username
    message = "#{data.username} has stopped typing, he probably regrets what
              he wanted to say - awkward."
    addSystemMessage message, { fade: true, typing: true, username: data.username }

  socket.on 'user left', (data) ->
    return unless connected
    message = "#{data.username} has made like Elvis and left the building.
    Total user count: #{data.numUsers}."
    addSystemMessage message
