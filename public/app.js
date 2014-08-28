(function() {
  $(function() {
    var $chatPage, $currentInput, $inputMessage, $loginPage, $messages, $usernameInput, $window, COLORS, FADE_TIME, TYPING_TIMER, addChatMessage, addChatTyping, addMessageElement, addParticipantsMessage, cleanInput, connected, getTypingMessages, getUsernameColor, lastTypingTime, log, removeChatTyping, sendMessage, setUsername, socket, typing, updateTyping, username;
    TYPING_TIMER = 400;
    FADE_TIME = 150;
    COLORS = ['#e21400', '#91580f', '#f8a700', '#f78b00', '#58dc00', '#287b00', '#a8f07a', '#4ae8c4', '#3b88eb', '#3824aa', '#a700ff', '#d300e7'];
    $window = $(window);
    $usernameInput = $('.usernameInput');
    $messages = $('.messages');
    $inputMessage = $('.inputMessage');
    $loginPage = $('.login.page');
    $chatPage = $('.chat.page');
    username = null;
    lastTypingTime = null;
    connected = false;
    typing = false;
    $currentInput = $usernameInput.focus();
    socket = io();
    addParticipantsMessage = function(data) {
      var message;
      message = '';
      if (data.numUsers === 1) {
        message += "there's 1 participant";
      } else {
        message += "there are " + data.numUsers + " participants.";
      }
      return log(message);
    };
    setUsername = function() {
      username = cleanInput($usernameInput.val().trim());
      if (username) {
        $loginPage.fadeOut();
        $chatPage.show();
        $loginPage.off('click');
        $currentInput = $inputMessage.focus();
        return socket.emit('add user', username);
      }
    };
    sendMessage = function() {
      var message;
      message = $inputMessage.val();
      message = cleanInput(message);
      if (message && connected) {
        $inputMessage.val('');
        addChatMessage({
          username: username,
          message: message
        });
      }
      return socket.emit('new message', message);
    };
    log = function(message, options) {
      var $el;
      $el = $('<li>').addClass('log').text(message);
      return addMessageElement($el, options);
    };
    addChatMessage = function(data, options) {
      var $messageBodySpan, $messageLi, $typingMessages, $usernameSpan, typingClass;
      $typingMessages = getTypingMessages(data);
      if (options == null) {
        options = {};
      }
      if ($typingMessages.length !== 0) {
        options.fade = false;
        $typingMessages.remove();
      }
      $usernameSpan = $('<span>').addClass('username').text(data.username).css('color', getUsernameColor(data.username));
      $messageBodySpan = $('<span>').addClass('messageBody').text(data.message);
      if (data.typing != null) {
        typingClass = 'typing';
      } else {
        typingClass = '';
      }
      console.log(typingClass);
      $messageLi = $('<li>').addClass("message " + typingClass).data('username', data.username).append($usernameSpan, $messageBodySpan);
      return addMessageElement($messageLi, options);
    };
    addChatTyping = function(data) {
      data.typing = true;
      data.message = 'is typing';
      return addChatMessage(data);
    };
    removeChatTyping = function(data) {
      return getTypingMessages(data).fadeOut(function() {
        return $(this).remove();
      });
    };
    addMessageElement = function(el, options) {
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
        $el.hide().fadeIn(FADE_TIME);
      }
      if (options.prepend) {
        $messages.prepend($el);
      } else {
        $messages.append($el);
      }
      return $messages[0].scrollTop = $messages[0].scrollHeight;
    };
    cleanInput = function(input) {
      return $('<div>').text(input).text();
    };
    updateTyping = function() {
      var callback;
      if (connected) {
        if (!typing) {
          typing = true;
          socket.emit('typing');
        }
        lastTypingTime = (new Date()).getTime();
        callback = function() {
          var timeDiff, typingTimer;
          typingTimer = (new Date()).getTime();
          timeDiff = typingTimer - lastTypingTime;
          if (timeDiff >= TYPING_TIMER && typing) {
            socket.emit('stop typing');
            return typing = false;
          }
        };
        return setTimeout(callback, TYPING_TIMER);
      }
    };
    getTypingMessages = function(data) {
      return $('.typing.message').filter(function(i) {
        return $(this).data('username') === data.username;
      });
    };
    getUsernameColor = function(username) {
      var hash, i, index, letter, _i, _len;
      hash = 7;
      for (i = _i = 0, _len = username.length; _i < _len; i = ++_i) {
        letter = username[i];
        hash = username.charCodeAt(i) + (hash << 5) - hash;
      }
      index = Math.abs(hash % COLORS.length);
      return COLORS[index];
    };
    $window.on('keydown', function(event) {
      if (event.ctrlKey || event.metaKey || event.altKey) {
        $currentInput.focus();
      }
      if (event.which === 13) {
        if (username) {
          sendMessage();
          socket.emit('stop typing');
          return typing = false;
        } else {
          return setUsername();
        }
      }
    });
    $inputMessage.on('input', function() {
      return updateTyping();
    });
    $loginPage.on('click', function() {
      return $currentInput.focus();
    });
    $inputMessage.on('click', function() {
      return $inputMessage.focus();
    });
    socket.on('login', function(data) {
      var message;
      connected = true;
      message = 'Welcome to Coffeechat! ';
      log(message, {
        prepend: true
      });
      return addParticipantsMessage(data);
    });
    socket.on('new message', function(data) {
      return addChatMessage(data);
    });
    socket.on('user joined', function(data) {
      log("" + data.username + " joined");
      return addParticipantsMessage(data);
    });
    socket.on('user left', function(data) {
      log("" + data.username + " left");
      addParticipantsMessage(data);
      return removeChatTyping(data);
    });
    socket.on('typing', function(data) {
      return addChatTyping(data);
    });
    return socket.on('stop typing', function(data) {
      return removeChatTyping(data);
    });
  });

}).call(this);
