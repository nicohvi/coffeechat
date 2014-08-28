(function() {
  var App;

  App = (function() {
    function App() {
      this.loginPage = new LoginPage($('.login.page'));
      this.socket = io();
      this.chat = new Chat($('.chat.page'));
      this.window = $(window);
      this.initHandlers();
      this.initSocketbindings();
      this.initBindings();
    }

    App.prototype.initHandlers = function() {
      this.loginPage.on('username', (function(_this) {
        return function(username) {
          return _this.socket.emit('add user', username);
        };
      })(this));
      this.chat.on('new message', (function(_this) {
        return function(message) {
          return _this.socket.emit('new message', message);
        };
      })(this));
      this.chat.on('typing', (function(_this) {
        return function() {
          return _this.socket.emit('typing');
        };
      })(this));
      return this.chat.on('stop typing', (function(_this) {
        return function() {
          return _this.socket.emit('stop typing');
        };
      })(this));
    };

    App.prototype.initSocketbindings = function() {
      this.socket.on('name taken', (function(_this) {
        return function() {
          var message;
          message = 'Name already taken, bro.';
          return _this.loginPage.handleError(message);
        };
      })(this));
      this.socket.on('login', (function(_this) {
        return function(data) {
          _this.loginPage.close();
          _this.loginPage = null;
          return _this.chat.trigger('welcome', [data]);
        };
      })(this));
      this.socket.on('user joined', (function(_this) {
        return function(data) {
          return _this.chat.trigger('user joined', [data]);
        };
      })(this));
      this.socket.on('new message', (function(_this) {
        return function(data) {
          return _this.chat.trigger('message', [data]);
        };
      })(this));
      this.socket.on('user left', (function(_this) {
        return function(data) {
          return _this.chat.trigger('user left', [data]);
        };
      })(this));
      this.socket.on('typing', (function(_this) {
        return function(data) {
          console.log("called");
          return _this.chat.trigger('typing_message', [data.username]);
        };
      })(this));
      return this.socket.on('stop typing', (function(_this) {
        return function(data) {
          return _this.chat.trigger('remove_typing_message', [data.username]);
        };
      })(this));
    };

    App.prototype.initBindings = function() {
      return this.window.on('keydown', (function(_this) {
        return function(event) {
          var target;
          if (_this.loginPage != null) {
            target = _this.loginPage;
          } else {
            target = _this.chat;
          }
          return target.trigger('keydown', [event]);
        };
      })(this));
    };

    return App;

  })();

  this.App = App;

}).call(this);
