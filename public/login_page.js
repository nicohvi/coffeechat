(function() {
  var LoginPage,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  LoginPage = (function(_super) {
    var cleanInput;

    __extends(LoginPage, _super);

    function LoginPage(el) {
      this.el = el;
      this.usernameInput = $('.usernameInput');
      this.initHandlers();
    }

    LoginPage.prototype.initHandlers = function() {
      return this.on('keydown', (function(_this) {
        return function(event) {
          if (event.ctrlKey || event.metaKey || event.altKey) {
            _this.usernameInput.focus();
          }
          if (event.which === 13) {
            return _this.setUsername();
          }
        };
      })(this));
    };

    LoginPage.prototype.setUsername = function() {
      return this.emit('username', cleanInput(this.usernameInput.val().trim()));
    };

    cleanInput = function(input) {
      return $('<div>').text(input).text();
    };

    LoginPage.prototype.handleError = function(error) {
      return $('<div>').addClass('error').text(error).prependTo(this.el);
    };

    LoginPage.prototype.close = function() {
      return this.el.fadeOut();
    };

    return LoginPage;

  })(EventEmitter);

  this.LoginPage = LoginPage;

}).call(this);
