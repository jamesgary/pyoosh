(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.brunch = true;
})();

window.require.register("app", function(exports, require, module) {
  
  module.exports = function() {
    var $name, $welcome_form, StartChat;
    StartChat = require('chat/start_chat');
    $welcome_form = $('form.welcome');
    $name = $welcome_form.find('input.name');
    $welcome_form.modal({
      backdrop: 'static',
      keyboard: false
    });
    $welcome_form.on('shown', function() {
      return $name.focus();
    });
    return $welcome_form.submit(function() {
      var name;
      name = $name.val() || 'Nameless';
      $welcome_form.modal('hide');
      StartChat(name);
      return false;
    });
  };
  
});
window.require.register("chat/websocket_connection", function(exports, require, module) {
  var WebsocketConnection;

  module.exports = WebsocketConnection = (function() {
    var HOST, NOISY;

    HOST = 'localhost:8080';

    NOISY = true;

    function WebsocketConnection(name, onReceive) {
      this.ws = new WebSocket("ws://" + HOST + "?name=" + (escape(name)));
      this.ws.onmessage = function(e) {
        return onReceive(JSON.parse(e.data).chat);
      };
      if (NOISY) {
        this.ws.onopen = function() {
          return console.log("socket connected :D");
        };
        this.ws.onclose = function() {
          return console.log("socket closed :(");
        };
      }
    }

    WebsocketConnection.prototype.send = function(msg) {
      return this.ws.send(msg);
    };

    return WebsocketConnection;

  })();
  
});
