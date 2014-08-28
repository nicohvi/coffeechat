express = require 'express'
app = express()
server = require('http').Server(app)
# chat_server = require './src/chat_server'
port = process.env.PORT || 3000
io = require('socket.io')(server)

app.use express.static("#{__dirname}/public")

# set up our chat server
# chat_server.listen(server)

server.listen port, ->
  console.log "server listening on port #{port}"

usernames = {}
numUsers = 0

io.on 'connection', (socket) ->
  console.log "connection with socket: #{socket.id}"
  guest = true

  socket.on 'new message', (data) ->
    socket.broadcast.emit 'new message',
      username: socket.username
      message: data

  socket.on 'add user', (username) ->
    console.log "username: #{username}"
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
