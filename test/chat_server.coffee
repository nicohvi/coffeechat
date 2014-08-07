express = require 'express'
app = express()
server = require('http').Server(app)
ioc = require 'socket.io-client'
chat_server = require('../lib/chat_server')

socketURL = 'ws://0.0.0:3001'
chatUsers = ['Frank', 'Adam', 'Tina']

describe 'Chat server', ->
  before (done) ->
    server = require('http').Server(app)
    chat_server.listen(server)
    server.listen 3001
    done()

  after (done) ->
    done()

  it 'Should add new user to usernames', (done) ->
    client1 = ioc('ws://0.0.0.0:3001')

    client1.on 'connect', (data) ->
      client1.emit 'add user', chatUsers[0]

    client1.on 'login', (data) ->
      chat_server.usernames[chatUsers[0]].should.equal('Frank')
      done()

  it 'Should inform user that a name is already taken', (done) ->
    client1 = ioc(socketURL)
    client2 = ioc(socketURL)

    client1.on 'connect', (data) ->
      client1.emit 'add user', chatUsers[0]

    client2.on 'connect', (data) ->
      client2.emit 'add user', chatUsers[0]

    client2.on 'used name', ->
      Object.keys(chat_server.usernames).length.should.equal(1)
      done()
