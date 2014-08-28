usernames = {}
numUsers = 0
util = require 'util'

exports.listen = (server) =>
  @io = require('socket.io')(server)

  @io.on 'connection', (socket) ->
    guest = true

    socket.on 'new message', (data) ->
      socket.broadcast.emit 'new message',
        username: socket.username
        message: data

    socket.on 'add user', (username) ->
      return socket.emit 'name taken' if usernames[username]?
      socket.username = username
      usernames[username] = username
      ++numUsers
      guest = false

      socket.emit 'login',
        numUsers: numUsers

      socket.broadcast.emit 'user joined',
        username: socket.username
        numUsers: numUsers

    socket.on 'typing', ->
      socket.broadcast.emit 'typing',
        username: socket.username

    socket.on 'stop typing', ->
      socket.broadcast.emit 'stop typing',
        username: socket.username

    socket.on 'disconnect', =>
      unless guest
        delete usernames[socket.username]
        --numUsers

        socket.broadcast.emit 'user left',
          username: socket.username
          numUsers: numUsers


# export methods used in tests

exports.disconnect = (username) =>
  for id,socket of @io.sockets.connected
    if socket.username == username
      socket.disconnect()
      delete usernames[socket.username]
      --numUsers
