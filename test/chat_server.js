(function() {
  var app, chatUsers, chat_server, express, ioc, server, socketURL;

  express = require('express');

  app = express();

  server = require('http').Server(app);

  ioc = require('socket.io-client');

  chat_server = require('../lib/chat_server');

  socketURL = 'ws://0.0.0:3001';

  chatUsers = ['Frank', 'Adam', 'Tina'];

  describe('Chat server', function() {
    before(function(done) {
      server = require('http').Server(app);
      chat_server.listen(server);
      server.listen(3001);
      return done();
    });
    after(function(done) {
      return done();
    });
    it('Should add new user to usernames', function(done) {
      var client1;
      client1 = ioc('ws://0.0.0.0:3001');
      client1.on('connect', function(data) {
        return client1.emit('add user', chatUsers[0]);
      });
      return client1.on('login', function(data) {
        chat_server.usernames[chatUsers[0]].should.equal('Frank');
        return done();
      });
    });
    return it('Should inform user that a name is already taken', function(done) {
      var client1, client2;
      client1 = ioc(socketURL);
      client2 = ioc(socketURL);
      client1.on('connect', function(data) {
        return client1.emit('add user', chatUsers[0]);
      });
      client2.on('connect', function(data) {
        return client2.emit('add user', chatUsers[0]);
      });
      return client2.on('used name', function() {
        Object.keys(chat_server.usernames).length.should.equal(1);
        return done();
      });
    });
  });

}).call(this);
