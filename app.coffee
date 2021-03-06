express = require 'express'
app = express()
server = require('http').Server(app)
chat_server = require './lib/chat_server'
port = process.env.PORT || 3000

app.use express.static("#{__dirname}/public")

# set up our chat server
chat_server.listen(server)

server.listen port, ->
  console.log "server listening on port #{port}"
