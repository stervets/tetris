// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Application.shapes = [];

  Application.Model.Controller = {};

  Application.matrixEmpty = function(width, height, val) {
    var line, matrix, _dummy, _i;
    if (val == null) {
      val = 0;
    }
    line = (function() {
      var _i, _results;
      _results = [];
      for (_dummy = _i = 0; 0 <= width ? _i < width : _i > width; _dummy = 0 <= width ? ++_i : --_i) {
        _results.push(val);
      }
      return _results;
    })();
    matrix = [];
    for (_dummy = _i = 0; 0 <= height ? _i < height : _i > height; _dummy = 0 <= height ? ++_i : --_i) {
      matrix.push(line.slice(0));
    }
    return matrix;
  };

  Application.lineCopy = function(source, value) {
    var line, val, _i, _len;
    line = [];
    if (value != null) {
      for (_i = 0, _len = source.length; _i < _len; _i++) {
        val = source[_i];
        line.push(val ? value : 0);
      }
    } else {
      line = source.slice(0);
    }
    return line;
  };

  Application.matrixCopy = function(source, value) {
    var line, matrix, _i, _len;
    matrix = [];
    for (_i = 0, _len = source.length; _i < _len; _i++) {
      line = source[_i];
      matrix.push(value != null ? Application.lineCopy(line, value) : line.slice(0));
    }
    return matrix;
  };


  /* Generate rotated shapes and align */

  Application.initShapes = function() {
    var getShapeMatrix, matrix, matrixRot90, num, shape, _i, _len, _results;
    matrixRot90 = function(source) {
      var cell, i, j, len, matrix, row, _i, _j, _len, _len1;
      matrix = Application.matrixCopy(source);
      len = matrix.length - 1;
      for (i = _i = 0, _len = source.length; _i < _len; i = ++_i) {
        row = source[i];
        for (j = _j = 0, _len1 = row.length; _j < _len1; j = ++_j) {
          cell = row[j];
          matrix[j][len - i] = source[i][j];
        }
      }
      return matrix;
    };
    getShapeMatrix = function(shape) {
      var line, lineStart, matrix, shapeWidth, _dummy, _i;
      shapeWidth = shape[0].length;
      lineStart = Math.floor(shapeWidth / 2 - shape.length / 2);
      matrix = [];
      for (line = _i = 0; 0 <= shapeWidth ? _i < shapeWidth : _i > shapeWidth; line = 0 <= shapeWidth ? ++_i : --_i) {
        matrix.push(line >= lineStart && line - lineStart < shape.length ? shape[line - lineStart] : (function() {
          var _j, _results;
          _results = [];
          for (_dummy = _j = 0; 0 <= shapeWidth ? _j < shapeWidth : _j > shapeWidth; _dummy = 0 <= shapeWidth ? ++_j : --_j) {
            _results.push(0);
          }
          return _results;
        })());
      }
      return matrix;
    };
    _results = [];
    for (num = _i = 0, _len = SHAPES.length; _i < _len; num = ++_i) {
      shape = SHAPES[num];
      matrix = Application.shapes[num] = [];
      matrix[0] = getShapeMatrix(shape);
      matrix[1] = matrixRot90(matrix[0]);
      matrix[2] = matrixRot90(matrix[1]);
      _results.push(matrix[3] = matrixRot90(matrix[2]));
    }
    return _results;
  };

  Application.shapesView = [];

  Application.initShapesView = function() {
    var $shape, index, line, shape, shapes, val, x, y, _i, _len, _ref, _results;
    _ref = Application.shapes;
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      shapes = _ref[index];
      Application.shapesView.push([]);
      _results.push((function() {
        var _j, _k, _l, _len1, _len2, _len3, _results1;
        _results1 = [];
        for (_j = 0, _len1 = shapes.length; _j < _len1; _j++) {
          shape = shapes[_j];
          $shape = $(Application.Templates.tplShape()).css({
            width: shape.length * POOL.CELL_SIZE,
            height: shape.length * POOL.CELL_SIZE
          });
          for (y = _k = 0, _len2 = shape.length; _k < _len2; y = ++_k) {
            line = shape[y];
            for (x = _l = 0, _len3 = line.length; _l < _len3; x = ++_l) {
              val = line[x];
              if (val) {
                $shape.append(Application.Templates.tplCell({
                  top: y * POOL.CELL_SIZE,
                  left: x * POOL.CELL_SIZE,
                  index: index + 1
                }));
              }
            }
          }
          _results1.push(Application.shapesView[index].push($shape[0].outerHTML));
        }
        return _results1;
      })());
    }
    return _results;
  };


  /* Main shapes stack */

  Application.Model.ShapeStack = (function(_super) {
    __extends(ShapeStack, _super);

    function ShapeStack() {
      return ShapeStack.__super__.constructor.apply(this, arguments);
    }

    ShapeStack.prototype.defaults = {
      shapes: []
    };

    ShapeStack.prototype.reset = function() {
      return this.set('shapes', []);
    };

    ShapeStack.prototype.getShape = function(index) {
      var len;
      len = index - this.attributes.shapes.length + 2;
      if (len > 0) {
        this.generateShapes(len);
      }
      return {
        index: this.attributes.shapes[index][0],
        angle: this.attributes.shapes[index][1]
      };
    };

    ShapeStack.prototype.generateShapes = function(num) {
      var i, maxAngle, shape, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= num ? _i < num : _i > num; i = 0 <= num ? ++_i : --_i) {
        shape = rand(SHAPES.length - 1);
        maxAngle = SHAPE_ANGLES[shape] || 4;
        _results.push(this.attributes.shapes.push([shape, rand(maxAngle - 1)]));
      }
      return _results;
    };

    ShapeStack.prototype.init = function() {
      var data, key;
      this.generateShapes(250);
      return;
      key = 'shapes';
      if (data = window.localStorage.getItem(key)) {
        return this.attributes.shapes = JSON.parse(data);
      } else {
        this.generateShapes(350);
        return window.localStorage.setItem(key, JSON.stringify(this.attributes.shapes));
      }
    };

    return ShapeStack;

  })(Backbone.Model);


  /* Shape model */

  Application.Model.Shape = (function(_super) {
    __extends(Shape, _super);

    function Shape() {
      return Shape.__super__.constructor.apply(this, arguments);
    }

    Shape.prototype.defaults = {
      index: 1000000,
      angle: 0,
      x: 0,
      y: 0,
      drop: -1,
      shape: null,
      size: 0
    };

    Shape.prototype.setShape = function(index, angle) {
      var size;
      if (angle == null) {
        angle = 0;
      }
      size = Application.shapes[index][0].length;
      this.set({
        index: index,
        shape: Application.shapes[index],
        size: size,
        angle: angle,
        x: Math.floor(POOL.WIDTH / 2 - size / 2),
        y: -size
      });
      return this.trigger('setShape');
    };

    return Shape;

  })(Backbone.Model);

  Application.keyMap = {};

  Application.keyMapper = function(controller, key, action) {
    return Application.keyMap[key] = {
      controller: controller,
      action: action
    };
  };


  /* Hook keys */

  Application.hook = function() {
    $(window).focus(function() {
      return $(document).focus();
    });
    return $(document).keydown(function(e) {
      var map;
      map = Application.keyMap[e.keyCode];
      if (map != null) {
        map.controller.trigger('action', map.action);
        return e.preventDefault();
      }
    });
  };


  /*
  Application.switchView = (viewName)->
      view.trigger('hide') for name, view of Application.GameView when viewName isnt name
      Application.GameView[viewName].trigger('showDelay')
   */

  Application.switchView = function(viewName) {
    var name, view, _ref;
    _ref = Application.GameView;
    for (name in _ref) {
      view = _ref[name];
      if (viewName !== name) {
        view.trigger('hide');
      }
    }
    return Application.GameView[viewName].trigger('showDelay');
  };

  Application.createMenu = function(menuTitle, menuItems, context) {
    var menu, menuItem, menuView, title, trigger;
    menu = new Application.Collection.Menu();
    menu.setTitle(menuTitle);
    menuView = new Application.View.Menu({
      collection: {
        Menu: menu
      }
    });
    if (context == null) {
      context = menu;
    }
    for (title in menuItems) {
      trigger = menuItems[title];
      menuItem = new Application.Model.MenuItem({
        title: title,
        triggerHandler: trigger,
        context: context
      });
      menu.add(menuItem);
    }
    return {
      collection: menu,
      view: menuView
    };
  };

  Application.clearCollection = function(collection) {
    var model, _results;
    _results = [];
    while (collection.length > 0) {
      model = collection.at(0);
      collection.remove(model);
      _results.push(model.trigger('destroy'));
    }
    return _results;
  };


  /* Start application */

  Application.onStart(function() {
    $('head').append(Application.Templates.tplStyle({
      POOL: POOL,
      poolWidth: POOL.WIDTH * POOL.CELL_SIZE,
      poolHeight: POOL.HEIGHT * POOL.CELL_SIZE
    }));
    Application.initShapes();
    Application.initShapesView();
    Application.shapeStack = new Application.Model.ShapeStack();
    Application.Pool = new Application.Collection.Pool();
    Application.Controller = new Application.Collection.Controller();
    Application.Sound = new Application.Collection.Sound();
    Application.GameView = {};
    Application.Lobby = new Application.Model.Lobby();
    Application.GameView.Lobby = new Application.View.Lobby({
      model: Application.Lobby
    });
    Application.Game = new Application.Model.Game();
    Application.GameMainView = new Application.View.Game({
      model: Application.Game
    });
    Application.hook();
    Application.Game["switch"](GAME_MODE.SINGLE_PLAYER);
    return $('body').click(function() {
      var pool;
      if (pool = Application.Pool.at(0)) {
        return pool.setSpell(SPELL.GROUND, 2);
      }
    });

    /*
    particle = new Application.Particle
        x: 100
        y: 100
    
    $('body').append particle.$el
    
    $('body').click ->
        for i in [0...10]
            x = i*20
            particle.launch(x, 0, 1, x+(i-10/2)*POOL.CELL_SIZE)
        particle.message('Combo x2', 1)
     */
  });

}).call(this);

//# sourceMappingURL=index.map
