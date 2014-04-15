// Generated by CoffeeScript 1.7.1

/*
    Shape view
 */

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Application.View.Shape = (function(_super) {
    __extends(Shape, _super);

    function Shape() {
      return Shape.__super__.constructor.apply(this, arguments);
    }

    Shape.prototype.$shape = null;

    Shape.prototype.prevAngle = 0;

    Shape.prototype.angle = 0;

    Shape.prototype.lastTime = 0;

    Shape.prototype.modelHandler = {
      'change:x change:y change:angle': function() {
        var shape, time, timeSub, transition;
        if (!this.$shape) {
          return;
        }
        shape = this.model.attributes;
        transition = {
          left: shape.x * POOL.CELL_SIZE,
          top: shape.y * POOL.CELL_SIZE
        };
        if (this.model.changed.angle != null) {
          transition.rotate = shape.angle > this.prevAngle || (this.prevAngle === 3 && shape.angle === 0) ? '+=90deg' : '-=90deg';
          this.prevAngle = this.model.changed.angle;
        }
        time = new Date().getTime();
        timeSub = time - this.lastTime;
        if (timeSub > ANIMATE_TIME) {
          timeSub = ANIMATE_TIME;
        }
        this.$shape.stop(true, false).css(transition);
        return this.lastTime = time;
      },
      setShape: function() {
        var shape;
        shape = this.model.attributes;
        this.$shape = $(Application.shapesView[shape.index][0]);
        this.prevAngle = shape.angle;
        this.$shape.stop().css({
          left: shape.x * POOL.CELL_SIZE,
          top: shape.y * POOL.CELL_SIZE,
          rotate: shape.angle * 90
        });
        this.$el.html(this.$shape);
        return this.lastTime = new Date().getTime();
      }
    };

    Shape.prototype.initialize = function() {
      var event, handler, _ref, _results;
      _ref = this.modelHandler;
      _results = [];
      for (event in _ref) {
        handler = _ref[event];
        _results.push(this.listenTo(this.model, event, handler));
      }
      return _results;
    };

    return Shape;

  })(Backbone.View);

  Application.View.Pool = (function(_super) {
    __extends(Pool, _super);

    function Pool() {
      return Pool.__super__.constructor.apply(this, arguments);
    }

    Pool.prototype.template = 'tplPool';

    Pool.prototype.shapeView = null;

    Pool.prototype.$body = null;

    Pool.prototype.$score = null;

    Pool.prototype.$cells = null;

    Pool.prototype.addShape = function() {
      var $cells, $shape, node, shape, _i, _len;
      $cells = this.$cells;
      shape = this.shapeView.model.attributes;
      if (shape.y < 0 || shape.y - shape.shape.length > $cells.length) {
        return;
      }
      $shape = $($(Application.shapesView[shape.index][shape.angle]).html());
      $shape.css({
        left: "+=" + (shape.x * POOL.CELL_SIZE) + "px",
        top: "+=" + (shape.y * POOL.CELL_SIZE) + "px"
      });
      this.$body.append($shape);
      for (_i = 0, _len = $shape.length; _i < _len; _i += 2) {
        node = $shape[_i];
        $cells[Math.floor(node.offsetTop / POOL.CELL_SIZE)][Math.floor(node.offsetLeft / POOL.CELL_SIZE)] = $(node);
      }
      return null;
    };

    Pool.prototype.poolHandler = {
      onPutShape: function() {
        return this.addShape();
      },
      overflow: function() {},
      lines: function(lines, score) {
        var $cell, $cells, cell, index, key, line, transit, x, y, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4;
        this.$score.text(score);
        $cells = this.$cells;
        transit = {};
        for (index = _i = 0, _len = lines.length; _i < _len; index = ++_i) {
          line = lines[index];
          _ref = $cells[line];
          for (x = _j = 0, _len1 = _ref.length; _j < _len1; x = ++_j) {
            $cell = _ref[x];
            $cell.css({
              scale: 0
            });
            _.delay(function($cell) {
              return $cell.remove();
            }, ANIMATE_TIME, $cell);

            /*
            $cell.transition({scale: 0}, ANIMATE_TIME, do($cell)->
                            -> $cell.remove())
             */
            $cells[line][x] = null;
            for (y = _k = _ref1 = line - 1; _ref1 <= 0 ? _k <= 0 : _k >= 0; y = _ref1 <= 0 ? ++_k : --_k) {
              if (!$cells[y][x]) {
                continue;
              }
              key = y * POOL.WIDTH + x;
              if (transit[key] == null) {
                transit[key] = {
                  node: $cells[y][x],
                  top: 0
                };
              }
              transit[key].top += POOL.CELL_SIZE;
            }
          }
        }
        for (_l = 0, _len2 = lines.length; _l < _len2; _l++) {
          line = lines[_l];
          _ref2 = $cells[line];
          for (x = _m = 0, _len3 = _ref2.length; _m < _len3; x = ++_m) {
            $cell = _ref2[x];
            for (y = _n = _ref3 = line - 1; _ref3 <= 0 ? _n <= 0 : _n >= 0; y = _ref3 <= 0 ? ++_n : --_n) {
              if ($cells[y][x]) {
                _ref4 = [$cells[y][x], $cells[y + 1][x]], $cells[y + 1][x] = _ref4[0], $cells[y][x] = _ref4[1];
              }
            }
          }
        }
        for (key in transit) {
          cell = transit[key];
          cell.node.css({
            top: '+=' + cell.top
          });
        }
        return null;
      }
    };

    Pool.prototype.modelHandler = {
      action: function(name, vars) {
        if (this.poolHandler[name] != null) {
          return this.poolHandler[name].apply(this, vars);
        }
      }
    };

    Pool.prototype.init = function(params) {
      this.$cells = Application.matrixEmpty(POOL.WIDTH, POOL.HEIGHT, null);
      this.$el.css({
        left: params.x,
        top: params.y
      });
      this.$body = this.$('.jsPoolBody');
      this.$score = this.$('.jsPoolScore');
      this.shapeView = new Application.View.Shape({
        model: this.model.shape
      });
      this.$body.append(this.shapeView.$el);
      this.model.trigger('action', 'reset');
      return this.model.trigger('action', 'start');
    };

    return Pool;

  })(Backbone.View);

}).call(this);

//# sourceMappingURL=poolView.map
