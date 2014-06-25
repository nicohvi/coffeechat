# coffeechat

Real-time chat application leveraging [nodejs](http://nodejs.org),
[express](http://expressjs.com) and [socket.io](http://socket.io) on
the server-side, and [react](http://facebook.github.io/react/) client-side.
Coffeescript all the things!

## Architecture

Server-side

```coffeescript
# app.coffee
express = require 'express'
http = require 'http'
chatServer = require './lib/chat_server'

app = express()
server = http.createServer(app)

# setup chatServer
chatServer.listen(server)

# the one route we need
app.get '/', (res, req) ->
  res.render('index.jade')

# chat_server.coffee
socketio = require 'socket.io'

exports.listen = (server) ->
  io = socketio.listen(server)

  io.sockets.on 'connection', (socket) ->
    # handle guest nicks and give the user the ability to
    # change nicks etc.
    # Also add handlers for disconnectins so we know which names
    # are available.
```

Client-side

```jade
<!-- index.jade -->
doctype html
html
  head
    meta(charset='utf-8')
    title coffeechat
    meta(name='description', content='Have a chat and a coffee')
    link(href="//fonts.googleapis.com/css?family=Inconsolata:400,700" rel="stylesheet" type="text/css")
    link(href="/assets/stylesheets/application.css" rel="stylesheet" type="text/css"

  body
    #app
    script(src="//cdn.socket.io/socket.io-1.0.6.js")
    script(src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.js")
    script(src="/assets/application.js")
```

Coffeescript

```coffeescript
  # organize client side code using react :-)
  # start the client-side socket.io on document ready perhaps?
```
