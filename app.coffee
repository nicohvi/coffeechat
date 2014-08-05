express = require 'express'
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)
port = 3000

server.listen port, ->
  console.log "server listening on port #{port}"


app.use express.static("#{__dirname}/public")
# chatServer.listen(server)

# app.get '/', (res, req) ->
  # res.render 'index.jade'

  # do all the chat things :-)

  # piggyback on the http server
usernames = {}
numUsers = 0

io.on 'connection', (socket) ->
  guest = true

  socket.on 'new message', (message) ->
    socket.broadcast.emit 'new message',
      username: socket.username
      message: message

  socket.on 'add user', (username) ->
    return socket.emit 'used name' if usernames[username]?

    socket.username = username
    usernames[username] = username
    ++numUsers

    guest = false
    socket.emit 'login',
      username: username
      numUsers: numUsers

    socket.broadcast.emit 'user joined',
      username: socket.username
      numUsers: numUsers

  # advanced shit
  socket.on 'typing', ->
    socket.broadcast.emit 'typing',
      username: socket.username

  socket.on 'stop typing', ->
    socket.broadcast.emit 'stop typing',
      username: socket.username

  socket.on 'disconnect', ->
    unless guest
      delete usernames[socket.username]
      --numUsers

      socket.broadcast.emit 'user left',
        username: socket.username
        numUsers: numUsers
