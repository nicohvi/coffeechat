$ ->

  # socket.io variables
  connected = false
  username = null
  socket = io()

  # DOM elements
  $loginPage = $('.login')
  $chatPage = $('.chat')
  $messages = $('.messages')
  $username = $('.username-input')
  $messageInput = $('.new-message')
  $input = $username.focus()

  # entry point
  addUser = ->
    username = cleanInput $username.val().trim()
    socket.emit('add user', username) if username

  sendMessage = ->
    message = cleanInput $input.val().trim()

    if message && connected
      $input.val('')
      addChatMessage
        username: username
        message: message

      socket.emit 'new message', message

  cleanInput = (input) ->
    $('<div/>').text(input).text()

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

  $chatPage.on 'click', (event) ->
    $input.focus()

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
    addSystemMessage message,
      prepend: true

  socket.on 'user joined', (data) ->
    return unless connected
    message = "#{data.username} has joined the chat.
              Total user count: #{data.numUsers}."
    addSystemMessage(message)

  socket.on 'new message', (data) ->
    addChatMessage(data)

  socket.on 'user left', (data) ->
    return unless connected
    message = "#{data.username} has made like Elvis and left the building.
    Total user count: #{data.numUsers}."
    addSystemMessage(message)
