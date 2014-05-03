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

    Shape.prototype.$drop = null;

    Shape.prototype.prevAngle = 0;

    Shape.prototype.angle = 0;

    Shape.prototype.lastTime = 0;

    Shape.prototype.appendDrop = function() {
      var css, shape;
      shape = this.model.attributes;
      this.$drop = $(Application.shapesView[shape.index][0]);
      css = {
        left: shape.x * POOL.CELL_SIZE,
        top: shape.drop * POOL.CELL_SIZE,
        rotate: shape.angle * 90,
        opacity: 0
      };
      this.$drop.css(css);
      return this.$el.append(this.$drop);
    };

    Shape.prototype.modelHandler = {
      'change:drop': function() {
        if (this.$drop != null) {
          return this.$drop.css({
            top: this.model.attributes.drop * POOL.CELL_SIZE,
            opacity: DROP_SHAPE_OPACITY
          });
        } else {
          return this.appendDrop();
        }
      },
      'change:x change:y change:angle': function() {
        var shape, transition;
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
        this.$shape.css(transition);
        if (this.$drop != null) {
          transition.top = shape.drop * POOL.CELL_SIZE;
          transition.opacity = DROP_SHAPE_OPACITY;
          return this.$drop.css(transition);
        }
      },
      setShape: function() {
        var css, shape;
        shape = this.model.attributes;
        this.$shape = $(Application.shapesView[shape.index][0]);
        this.prevAngle = shape.angle;
        css = {
          left: shape.x * POOL.CELL_SIZE,
          top: shape.y * POOL.CELL_SIZE,
          rotate: shape.angle * 90
        };
        this.$shape.css(css);
        if (this.$drop != null) {
          this.$drop.remove();
          this.$drop = null;
        }
        return this.$el.html(this.$shape);
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
        var shape;
        shape = Application.shapeStack.getShape(this.model.attributes.index + 3);
        this.$next[0].html(this.$next[1].html());
        this.$next[1].html(this.$next[2].html());
        this.$next[2].html(Application.shapesView[shape.index][shape.angle]);
        return this.addShape();
      },
      overflow: function() {},
      lines: function(lines, score) {
        var $cell, $cells, index, line, transit, x, y, _i, _j, _k, _len, _len1, _ref, _ref1;
        this.$score.text(score);
        $cells = this.$cells;
        transit = {};
        for (index = _i = 0, _len = lines.length; _i < _len; index = ++_i) {
          line = lines[index];
          _ref = $cells[line];
          for (x = _j = 0, _len1 = _ref.length; _j < _len1; x = ++_j) {
            $cell = _ref[x];
            _.delay(function(x, y, particle) {
              return particle.launch(x, y, 'white');
            }, 100, x * POOL.CELL_SIZE, line * POOL.CELL_SIZE, this.particle);
            $cell.remove();
            $cells[line][x] = null;
            for (y = _k = line; line <= 0 ? _k < 0 : _k > 0; y = line <= 0 ? ++_k : --_k) {
              if (!($cells[y][x] || $cells[y - 1][x])) {
                continue;
              }
              _.delay(function($cell, y) {
                return $cell.css({
                  top: y
                });
              }, ANIMATE_TIME, $cells[y - 1][x], y * POOL.CELL_SIZE);
              _ref1 = [$cells[y][x], $cells[y - 1][x]], $cells[y - 1][x] = _ref1[0], $cells[y][x] = _ref1[1];
            }
          }
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
      var index, shape, _i;
      this.$next = [];
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
      this.$('.jsShapeNext').css({
        scale: 0.5
      });
      for (index = _i = 0; _i <= 2; index = ++_i) {
        this.$next[index] = this.$(".jsShapeNext" + index);
        shape = Application.shapeStack.getShape(index + 1);
        this.$next[index].html(Application.shapesView[shape.index][shape.angle]);
      }
      this.$body.append(this.shapeView.$el);
      this.particle = new Application.Particle;
      this.$body.append(this.particle.$el);
      this.model.trigger('action', 'reset');
      return this.model.trigger('action', 'start');
    };

    return Pool;

  })(Backbone.View);

}).call(this);

//# sourceMappingURL=poolView.map
