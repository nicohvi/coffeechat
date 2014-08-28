util = require 'util'
io = require('socket.io')
users = { }

exports.listen = (server) ->
  @socketServer = io(server)

  @socketServer.on 'connection', (socket) ->
    guest = true

    socket.on 'add user', (username) ->
      if users[username]?
        return socket.emit 'used name',
          username: username
          numUsers: numUsers()

      socket.username = username
      users[username] =
        socket: socket

      guest = false
      socket.emit 'login',
        username: username
        numUsers: numUsers()

      socket.broadcast.emit 'user joined',
        username: socket.username
        numUsers: numUsers()

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
      console.log "called with username: #{socket.username}"
      unless guest
        delete users[socket.username]

        socket.broadcast.emit 'user left',
          username: socket.username
          numUsers: numUsers()

exports.users = users

exports.numUsers = numUsers = ->
  Object.keys(users).length

exports.disconnect = (username=null) ->

  if username?
    user = users[username]
    user.socket.disconnect() if user?
  else # close the server
    @socketServer.engine.close()
