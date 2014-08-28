(function() {
  var app, chat_server, express, port, server;

  express = require('express');

  app = express();

  server = require('http').Server(app);

  chat_server = require('./lib/chat_server');

  port = 3000;

  app.use(express["static"]("" + __dirname + "/public"));

  chat_server.listen(server);

  server.listen(port, function() {
    return console.log("server listening on port " + port);
  });

}).call(this);
