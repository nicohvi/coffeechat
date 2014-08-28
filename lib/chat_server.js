(function() {
  var chatServer, numUsers, usernames;

  usernames = {};

  numUsers = 0;

  chatServer = null;

  exports.listen = function(server) {
    var io;
    chatServer = io = require('socket.io')(server);
    return io.on('connection', function(socket) {
      var guest;
      guest = true;
      socket.on('add user', function(username) {
        if (usernames[username] != null) {
          return socket.emit('used name');
        }
        socket.username = username;
        usernames[username] = username;
        ++numUsers;
        guest = false;
        socket.emit('login', {
          username: username,
          numUsers: numUsers
        });
        return socket.broadcast.emit('user joined', {
          username: socket.username,
          numUsers: numUsers
        });
      });
      socket.on('new message', function(message) {
        return socket.broadcast.emit('new message', {
          username: socket.username,
          message: message
        });
      });
      socket.on('typing', function() {
        return socket.broadcast.emit('typing', {
          username: socket.username
        });
      });
      socket.on('stop typing', function() {
        return socket.broadcast.emit('stop typing', {
          username: socket.username
        });
      });
      return socket.on('disconnect', function() {
        if (!guest) {
          delete usernames[socket.username];
          --numUsers;
          return socket.broadcast.emit('user left', {
            username: socket.username,
            numUsers: numUsers
          });
        }
      });
    });
  };

  exports.usernames = usernames;

}).call(this);
