usernames = {}
numUsers = 0
chatServer = null

exports.listen = (server) ->
  chatServer = io = require('socket.io')(server)

  io.on 'connection', (socket) ->
    guest = true

    socket.on 'add user', (username) ->
      return socket.emit 'used name' if usernames[username]?

      socket.username = username
      usernames[username] = username
      ++numUsers

      guest = false
      socket.emit 'login',
        username: username
        numUsers: nullmUsers

      socket.broadcast.emit 'user joined',
        username: socket.username
        numUsers: numUsers

    socket.on 'new message', (message) ->
      socket.broadcast.emit 'new message',
        username: socket.username
        message: message


    socket.on 'typing', ->
      socket.broadcast.emit 'typing',
        username: socket.username

    socket.on 'stop typing', ->
      socket.broadcast.emit 'stop typing',
        username: socket.username

    socket.on 'disconnect', ->
      console.log "disconnect called #{socket.username}"
      unless guest
        delete usernames[socket.username]
        --numUsers

        socket.broadcast.emit 'user left',
          username: socket.username
          numUsers: numUsers

exports.usernames = usernames
