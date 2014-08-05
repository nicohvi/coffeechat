$ ->

  # socket.io magic
  socket = io()
  connected = false
  $messages = $('.messages')
  $username = $('.username-input')
  $messageInput = $('.new-message')
  $input = $username.focus()
  username = null

  # entry point
  addUser = ->
    # username = cleanInput $username.val().trim()
    username = $username.val().trim()
    if username
      # $loginPage.fadeOut()
      # $chatPage.show()
      # no more need to login
      # $loginPage.off('click')
      $input = $messageInput.focus()

      socket.emit 'add user', username

  sendMessage = ->
    message = $input.val()

    if connected
      $input.val('')
      addChatMessage
        username: username
        message: message

      socket.emit 'new message', message

  addChatMessage = (data, options) ->
    $userEl = $('<span class="username" />')
      .text(data.username)
    $messageBodyEl = $('<span class="message-body" />')
      .text(data.message)
    $messageEl = $('<li class="message" />')
      .data('username', data.username)
      .append($userEl, $messageBodyEl)
    addMessageElement($messageEl, options)

  # event handlers
  $(@).keydown (event) ->
    if event.which == 13
      if username? then sendMessage() else addUser()

  addSystemMessage = (message, options) ->
    $messageBodyEl = $('<span class="message-body" />')
      .text(message)
    $messageEl = $('<li class="message system"/>')
      .append($messageBodyEl)
    addMessageElement($messageEl, options)

  addMessageElement = ($el, options) ->
    options = {} unless options?
    if options.prepend then $messages.prepend($el) else $messages.append($el)
    # scroll to the newest message
    $messages[0].scrollTop = $messages[0].scrollHeight

  socket.on 'login', (data) ->
    connected = true
    message = "Welcome to Coffeechat, #{data.username}."
    addSystemMessage message,
      prepend: true

  socket.on 'user joined', (data) ->
    message = "#{data.username} has joined the chat.
              There are now #{data.numUsers} connnected."
    addSystemMessage(message)

  socket.on 'new message', (data) ->
    addChatMessage(data)
