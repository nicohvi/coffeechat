util = require 'util'
express = require 'express'
app = express()
server = require('http').Server(app)
io = require 'socket.io-client'
chatServer = require('../lib/chat_server')

socketURL = 'ws://0.0.0:3001'
options = { 'forceNew': true }
chatUsers = ['Frank', 'Adam', 'Tina']

describe 'Chat server', ->
  before (done) ->
    server = require('http').Server(app)
    chatServer.listen(server)
    server.listen 3001
    done()

  after (done) ->
    chatServer.disconnect()
    done()

  describe 'Login', ->

    afterEach (done) ->
      for username in chatUsers
        chatServer.disconnect(username)
      done()

    it 'Should add new user to usernames', (done) ->
      client1 = io.connect(socketURL, options)
      manager = client1.io

      client1.on 'connect', (data) ->
        client1.emit 'add user', chatUsers[0]

      client1.on 'login', (data) ->
        data.numUsers.should.equal(1)
        done()

    it 'Should inform user that a name is already taken', (done) ->
      client1 = io(socketURL, options)

      client1.on 'connect', (data) ->
        client1.emit 'add user', chatUsers[0]

        client1.on 'login', (data) ->
          client2 = io(socketURL, options)

          client2.on 'connect', (data) ->
            client2.emit 'add user', chatUsers[0]

          client2.on 'name taken', (data) ->
            done()

    it 'Should inform already registered users that a new user has joined', (done) ->
      client1 = io(socketURL, options)
      client2 = io(socketURL, options)

      client1.on 'connect', ->
        client1.emit 'add user', chatUsers[0]

      client2.on 'connect', ->
        client2.emit 'add user', chatUsers[1]

      client1.on 'user joined', (data) ->
        data.username.should.equal(chatUsers[1])
        done()

  describe 'Messages', ->

    before (done) ->
      @client1 = io(socketURL, options)
      @client2 = io(socketURL, options)
      @client3 = io(socketURL, options)

      @client1.on 'connect', ->
        @.emit 'add user', chatUsers[0]

      @client2.on 'connect', ->
        @.emit 'add user', chatUsers[1]

      @client3.on 'connect', ->
        @.emit 'add user', chatUsers[2]
        done()

    it 'Should push messages to all users when someone speaks', (done) ->
      message = 'Sup dawgs?'
      @client1.emit 'new message', message

      @client2.on 'new message', (data) ->
        data.username.should.equal(chatUsers[0])
        data.message.should.equal(message)

      @client3.on 'new message', (data) ->
        data.username.should.equal(chatUsers[0])
        data.message.should.equal(message)
        done()

    it 'Should emit *typing* messages to all users when one is typing', (done) ->
      @client1.emit 'typing'

      @client2.on 'typing', (data) ->
        data.username.should.equal(chatUsers[0])

      @client3.on 'typing', (data) ->
        data.username.should.equal(chatUsers[0])
        done()

    it 'Should emit *stop typing* messages to all users when typing stops', (done) ->
      @client1.emit 'stop typing'

      @client2.on 'stop typing', (data) ->
        data.username.should.equal(chatUsers[0])

      @client3.on 'stop typing', (data) ->
        data.username.should.equal(chatUsers[0])
        done()

    it 'Should emit leaving messages when a user disconnects', (done) ->
      chatServer.disconnect(chatUsers[0])

      @client2.on 'user left', (data) ->
        data.username.should.equal(chatUsers[0])

      @client3.on 'user left', (data) ->
        data.username.should.equal(chatUsers[0])
        done()
