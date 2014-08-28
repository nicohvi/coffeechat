(function() {
  var Chat,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Chat = (function(_super) {
    __extends(Chat, _super);

    function Chat(el) {
      this.el = el;
      console.log('w0t');
      this.FADE_TIME = 150;
      this.TYPING_TIMER = 400;
      this.COLORS = ['#e21400', '#91580f', '#f8a700', '#f78b00', '#58dc00', '#287b00', '#a8f07a', '#4ae8c4', '#3b88eb', '#3824aa', '#a700ff', '#d300e7'];
      this.typing = false;
      this.messages = $('.messages');
      this.inputMessage = $('.inputMessage');
      this.initHandlers();
      this.initBindings();
    }

    Chat.prototype.initHandlers = function() {
      this.on('keydown', (function(_this) {
        return function(event) {
          if (event.which === 13) {
            _this.typing = false;
            return _this.sendMessage();
          } else {
            return _this.inputMessage.focus();
          }
        };
      })(this));
      this.on('welcome', (function(_this) {
        return function(data) {
          var message;
          _this.el.show();
          _this.username = data.username;
          message = 'Welcome to Coffeechat!';
          _this.log(message, {
            prepend: true
          });
          return _this.addParticipantsMessage(data.numUsers);
        };
      })(this));
      this.on('message', (function(_this) {
        return function(data) {
          return _this.buildChatMessage(data.username, data.message);
        };
      })(this));
      this.on('user joined', (function(_this) {
        return function(data) {
          _this.log("" + data.username + " joined");
          return _this.addParticipantsMessage(data.numUsers);
        };
      })(this));
      this.on('user left', (function(_this) {
        return function(data) {
          _this.log("" + data.username + " left");
          _this.addParticipantsMessage(data.numUsers);
          return _this.removeTypingMessage(data.username);
        };
      })(this));
      this.on('typing_message', (function(_this) {
        return function(username) {
          return _this.addTypingMessage(username);
        };
      })(this));
      return this.on('remove_typing_message', (function(_this) {
        return function(username) {
          return _this.removeTypingMessage(username);
        };
      })(this));
    };

    Chat.prototype.initBindings = function() {
      this.inputMessage.on('input', (function(_this) {
        return function() {
          return _this.updateTyping();
        };
      })(this));
      return this.el.on('click', (function(_this) {
        return function() {
          return _this.inputMessage.focus();
        };
      })(this));
    };

    Chat.prototype.sendMessage = function() {
      var message;
      message = this.inputMessage.val();
      if (message != null) {
        this.inputMessage.val('');
        this.buildChatMessage(this.username, message);
        return this.emit('new message', message);
      }
    };

    Chat.prototype.log = function(message, options) {
      var $el;
      $el = $('<li>').addClass('log').text(message);
      return this.addMessageElement($el, options);
    };

    Chat.prototype.getUsernameColor = function(username) {
      var hash, i, index, letter, _i, _len;
      hash = 7;
      for (i = _i = 0, _len = username.length; _i < _len; i = ++_i) {
        letter = username[i];
        hash = username.charCodeAt(i) + (hash << 5) - hash;
      }
      index = Math.abs(hash % this.COLORS.length);
      return this.COLORS[index];
    };

    Chat.prototype.buildChatMessage = function(username, message, options) {
      var $messageBodySpan, $messageLi, $typingMessage, $usernameSpan, typingClass;
      if (options == null) {
        options = {};
      }
      $typingMessage = this.getTypingMessages(username);
      if ($typingMessage.length > 0) {
        options.fade = false;
        $typingMessage.remove();
      }
      $usernameSpan = $('<span>').addClass('username').text(username).css('color', this.getUsernameColor(username));
      $messageBodySpan = $('<span>').addClass('messageBody').text(message);
      if (options.typing != null) {
        typingClass = 'typing';
      } else {
        typingClass = '';
      }
      $messageLi = $('<li>').addClass("message " + typingClass).data('username', username).append($usernameSpan, $messageBodySpan);
      return this.addMessageElement($messageLi, options);
    };

    Chat.prototype.addMessageElement = function(el, options) {
      var $el;
      $el = $(el);
      if (options == null) {
        options = {};
      }
      if (options.fade == null) {
        options.fade = true;
      }
      if (options.prepend == null) {
        options.prepend = false;
      }
      if (options.fade) {
        $el.hide().fadeIn(this.FADE_TIME);
      }
      if (options.prepend) {
        this.messages.prepend($el);
      } else {
        this.messages.append($el);
      }
      return this.messages[0].scrollTop = this.messages[0].scrollHeight;
    };

    Chat.prototype.addParticipantsMessage = function(numUsers) {
      var message;
      if (numUsers === 1) {
        message = "There's 1 participant.";
      } else {
        message = "There are " + numUsers + " participants.";
      }
      return this.log(message);
    };

    Chat.prototype.updateTyping = function() {
      var callback, lastTypingTime;
      if (!this.typing) {
        this.typing = true;
        this.emit('typing');
      }
      lastTypingTime = (new Date()).getTime();
      callback = (function(_this) {
        return function() {
          var timeDiff, typingTimer;
          typingTimer = (new Date()).getTime();
          timeDiff = typingTimer - lastTypingTime;
          if (timeDiff >= _this.TYPING_TIMER && _this.typing) {
            _this.emit('stop typing');
            return _this.typing = false;
          }
        };
      })(this);
      return setTimeout(callback, this.TYPING_TIMER);
    };

    Chat.prototype.addTypingMessage = function(username) {
      var message, options;
      options = {};
      options.typing = true;
      message = 'is typing';
      return this.buildChatMessage(username, message, options);
    };

    Chat.prototype.removeTypingMessage = function(username) {
      return this.getTypingMessages(username).fadeOut(function() {
        return $(this).remove();
      });
    };

    Chat.prototype.getTypingMessages = function(username) {
      return $('.typing.message').filter(function(i) {
        return $(this).data('username') === username;
      });
    };

    return Chat;

  })(EventEmitter);

  this.Chat = Chat;

}).call(this);
