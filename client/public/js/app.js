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
    var Playground, Welcome;
    Playground = require('playground/playground');
    Welcome = require('welcome');
    return new Welcome(function(name) {
      return new Playground(name);
    });
  };
  
});
window.require.register("playground/playground", function(exports, require, module) {
  var Playground, Renderer, WebsocketReactor, raf;

  WebsocketReactor = require('playground/websocket_reactor');

  Renderer = require('playground/renderer');

  raf = require('raf');

  module.exports = Playground = (function() {

    function Playground(name) {
      var $canvas, $messageDisplay, $messageInput, canvasTarget, renderer, wsr;
      wsr = new WebsocketReactor(name);
      canvasTarget = null;
      $messageDisplay = $('.chat-container .messages');
      $messageInput = $('.chat-container input.message');
      $messageInput.keypress(function(e) {
        if (e.which === 13) {
          wsr.send({
            chat: this.value
          });
          return this.value = '';
        }
      });
      $canvas = $('.playground canvas');
      $canvas.mousemove(function(e) {
        var parentOffset, x, y;
        parentOffset = $(this).offset();
        x = e.pageX - parentOffset.left;
        y = e.pageY - parentOffset.top;
        return canvasTarget = [x, y];
      });
      $canvas.mouseleave(function(e) {
        return canvasTarget = null;
      });
      renderer = new Renderer($('.playground canvas').get(0));
      wsr.registerListener('chat', function(data) {
        var output;
        if (data.from) {
          output = "<b>" + data.from + "</b>: " + data.msg;
        } else {
          output = "<i>" + data.msg + "</i>";
        }
        return $messageDisplay.append("<p>" + output + "</p>");
      });
      wsr.registerListener('playground', function(data) {
        raf(function() {
          return wsr.send({
            playground: {
              target: canvasTarget
            }
          });
        });
        return renderer.draw(data);
      });
    }

    return Playground;

  })();
  
});
window.require.register("playground/renderer", function(exports, require, module) {
  var HEIGHT, Renderer, WIDTH;

  WIDTH = 400;

  HEIGHT = 300;

  module.exports = Renderer = (function() {

    function Renderer(canvas) {
      canvas.width = WIDTH;
      canvas.height = HEIGHT;
      this.ctx = canvas.getContext("2d");
      this.ctx.strokeStyle = "#222";
      this.ctx.lineWidth = 1;
    }

    Renderer.prototype.draw = function(data) {
      var p, pos, _i, _len, _ref, _results;
      this.ctx.clearRect(0, 0, WIDTH, HEIGHT);
      _ref = data.particles;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        pos = p.pos;
        this.ctx.fillStyle = p.mass > 1.5 ? "#00bb00" : "#22ff22";
        this.ctx.beginPath();
        this.ctx.arc(pos.x, pos.y, p.radius, 0, 2 * Math.PI, false);
        this.ctx.fill();
        _results.push(this.ctx.stroke());
      }
      return _results;
    };

    return Renderer;

  })();
  
});
window.require.register("playground/websocket_reactor", function(exports, require, module) {
  var HOST, NOISY, WebsocketReactor;

  HOST = 'localhost:8080';

  NOISY = true;

  module.exports = WebsocketReactor = (function() {

    function WebsocketReactor(name) {
      var _this = this;
      this.listeners = [];
      this.ws = new WebSocket("ws://" + HOST + "?name=" + (escape(name)));
      this.ws.onmessage = function(wsData) {
        var listener, value, _i, _len, _ref, _results;
        wsData = JSON.parse(wsData.data);
        _ref = _this.listeners;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listener = _ref[_i];
          if (value = wsData[listener.key]) {
            _results.push(listener.callback(value));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
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

    WebsocketReactor.prototype.registerListener = function(key, callback) {
      return this.listeners.push({
        key: key,
        callback: callback
      });
    };

    WebsocketReactor.prototype.send = function(msg) {
      return this.ws.send(JSON.stringify(msg));
    };

    return WebsocketReactor;

  })();
  
});
window.require.register("raf", function(exports, require, module) {
  
  module.exports = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };
  
});
window.require.register("welcome", function(exports, require, module) {
  var Welcome;

  module.exports = Welcome = (function() {

    function Welcome(onSubmit) {
      var $name, $welcome_form;
      $welcome_form = $('form.welcome');
      $name = $welcome_form.find('input.name');
      $welcome_form.modal({
        backdrop: 'static',
        keyboard: false
      });
      $welcome_form.on('shown', function() {
        return $name.focus();
      });
      $welcome_form.submit(function() {
        $welcome_form.modal('hide');
        onSubmit($name.val());
        return false;
      });
    }

    return Welcome;

  })();
  
});
